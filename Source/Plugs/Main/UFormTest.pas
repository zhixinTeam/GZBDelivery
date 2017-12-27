unit UFormTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormBase, StdCtrls, ExtCtrls;

type
  TBaseForm1 = class(TBaseForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    Edit1: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FListA,FListB: TStrings;
    procedure WriteLog(const nMsg: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TFormCreateResult; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  UBusinessWorker, UBusinessPacker, UBusinessConst, UMgrControl, UMgrDBConn,
  UPlugConst, USysDB, USysLoger, ULibFun, DB, ADODB;

var
  gForm: TBaseForm1 = nil;


class function TBaseForm1.CreateForm(const nPopedom: string;
  const nParam: Pointer): TFormCreateResult;
begin
  if not Assigned(gForm) then
    gForm := TBaseForm1.Create(Application);
  //xxxxx
  
  Result.FFormItem := gForm;
  gForm.Show;
end;

class function TBaseForm1.FormID: integer;
begin
  Result := cFI_FormTest1;
end;

procedure TBaseForm1.FormCreate(Sender: TObject);
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
end;

procedure TBaseForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  gForm := nil;
  FListA.Free;
  FListB.Free;
end;

function CallBusinessCommand(const nCmd: Integer; const nData,nParma: string;
  const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPack: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPack := nil;
  nWorker := nil;
  try
    nPack := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);

    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nParma;
    nStr := nPack.PackIn(@nIn);

    Result := nWorker.WorkActive(nStr);
    if not Result then
    begin
      ShowDlg(nStr, '');
      Exit;
    end;

    nPack.UnPackOut(nStr, nOut);
  finally
    gBusinessPackerManager.RelasePacker(nPack);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015-09-16
//Parm: 表名;数据链路
//Desc: 生成nTable的唯一记录号
function YT_NewID(const nTable: string; const nWorker: PDBWorker): string;
begin
  with nWorker.FExec do
  begin
    Close;
    SQL.Text := '{call GetID(?,?)}';

    Parameters.Clear;
    Parameters.CreateParameter('P1', ftString , pdInput, Length(nTable), nTable);
    Parameters.CreateParameter('P2', ftString, pdOutput, 20, '') ;
    ExecSQL;

    Result := Parameters.ParamByName('P2').Value;
  end;
end;

type
  TMyThread = class(TThread)
  private
    FCPU: Integer;
    FDBSQL: PDBWorker;
    FDBYT: PDBWorker;
  protected
    FMsg: string;
    procedure Execute; override;
    procedure SyncLog;
  public
    constructor Create(const nCPU: Integer);
    destructor Destroy; override;
    procedure StopMe;
  end;

var
  gThreads: array of TMyThread;


{ TMyThread }

constructor TMyThread.Create;
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FCPU := nCPU;
end;

destructor TMyThread.Destroy;
begin

  inherited;
end;

procedure TMyThread.StopMe;
begin
  Terminate;
  WaitFor;
  Free;
end;

procedure TBaseForm1.WriteLog(const nMsg: string);
begin
  Memo1.Lines.Add(nMsg);
end;

procedure TMyThread.SyncLog;
begin
  gForm.WriteLog(FMsg);
end;

procedure TMyThread.Execute;
var nStr: string;
    nInt: Integer;
begin
  SetThreadIdealProcessor(Handle, FCPU);
  while not Terminated do
  try
    FDBYT := gDBConnManager.GetConnection(sFlag_DB_YT, nInt);
    FMsg := Format('%d in --->', [FCPU]);
    Synchronize(SyncLog);

    nStr := YT_NewID('XS_LADE_BASE', FDBYT);
    FMsg := Format('%d out <---', [FCPU]);
    Synchronize(SyncLog);

    nStr := 'insert into t_t2(id,name) values(1,''' + nStr + ''')';
    gDBConnManager.WorkerExec(FDBYT, nStr);
  finally
    gDBConnManager.ReleaseConnection(FDBSQL);
    gDBConnManager.ReleaseConnection(FDBYT); 
  end;   

end;

//------------------------------------------------------------------------------
procedure TBaseForm1.Button1Click(Sender: TObject);
var nIdx: Integer;
begin
  if Length(gThreads) < 1 then
  begin
    SetLength(gThreads, 2);
    for nIdx:=Low(gThreads) to High(gThreads) do
      gThreads[nIdx] := TMyThread.Create(nIdx mod 4);
    //xxxxx
  end else
  begin
    for nIdx:=Low(gThreads) to High(gThreads) do
      gThreads[nIdx].StopMe;
    SetLength(gThreads, 0);
  end;
end;

initialization
  gControlManager.RegCtrl(TBaseForm1, TBaseForm1.FormID);
end.
