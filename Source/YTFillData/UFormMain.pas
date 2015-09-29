unit UFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, DB, ADODB;

type
  TfFormMain = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    BtnConn: TButton;
    BtnFill: TButton;
    ADOConnection1: TADOConnection;
    Query1: TADOQuery;
    ADOExec: TADOQuery;
    procedure BtnConnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnFillClick(Sender: TObject);
  private
    { Private declarations }
    FStep: Integer;
    //分析进度
    FListA,FListB: TStrings;
    procedure InitUIByStep;
    procedure EnumFillNeeded;
    function YT_NewID(const nTable: string): string;
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}

uses
  ULibFun, UFormConn, UFormCtrl;

var
  gPath: string;

resourcestring
  sHint = '提示';

procedure TfFormMain.FormCreate(Sender: TObject);
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath + 'Config.ini', gPath + 'Config.ini', gPath + 'DBConn.ini');

  FStep := 1;
  InitUIByStep;

  FListA := TStringList.Create;
  FListB := TStringList.Create;
  LoadFormConfig(Self);
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FListA.Free;
  FListB.Free;
end;

//------------------------------------------------------------------------------
function DBConn(const nConnStr: string): Boolean;
begin
  with fFormMain do
  try
    ADOConnection1.Close;
    ADOConnection1.ConnectionString := nConnStr;
    ADOConnection1.Connected := True;
    Result := ADOConnection1.Connected;
  except
    Result := False;
  end;
end;

procedure TfFormMain.BtnConnClick(Sender: TObject);
begin
  if ShowConnectDBSetupForm(@DBConn) then
  try
    ADOConnection1.Close;
    ADOConnection1.ConnectionString := BuildConnectDBStr();     
    ADOConnection1.Connected := True;

    FStep := 2;
    InitUIByStep;
    EnumFillNeeded;
  except
    ShowMsg('无法连接到数据库', sHint);
  end;
end;

procedure TfFormMain.InitUIByStep;
begin
  BtnConn.Enabled := FStep = 1;
  BtnFill.Enabled := FStep > 1;
end;

procedure TfFormMain.EnumFillNeeded;
var nStr: string;
begin
  Memo1.Text := '正在检索需同步的数据...';
  Application.ProcessMessages;
  FListA.Clear;

  nStr := 'select xlb.xlb_id,xlb.xlb_ladeid,DTP_Lade from XS_Lade_Base xlb ' +
          '  left join DB_Turn_ProduOut on DTP_Lade=xlb.xlb_id ' +
          'where xlb.xlb_ladeid like ''TH%'' and DTP_Lade is null ';
  //xxxxxx

  with Query1 do
  begin
    Close;
    SQL.Text := nStr;
    Open;

    if RecordCount < 1 then
    begin
      Memo1.Text := '没有需要同步的数据.';
      Exit;
    end;

    First;
    while not Eof do
    begin
      nStr := '记录: %s 提单: %s';
      nStr := Format(nStr, [Fields[0].AsString, Fields[1].AsString]);
      Memo1.Lines.Add(nStr);

      FListA.Add(Fields[0].AsString);
      Next;
    end;

    nStr := Format('合计: %d 笔', [RecordCount]);
    Memo1.Lines.Add(nStr);
  end;
end;

function TfFormMain.YT_NewID(const nTable: string): string;
begin
  with ADOExec do
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

function DateTime2StrOracle(const nDT: TDateTime): string;
var nStr :string;
begin
  nStr := 'to_date(''%s'', ''yyyy-mm-dd hh24-mi-ss'')';
  Result := Format(nStr, [DateTime2Str(nDT)]);
end;

procedure TfFormMain.BtnFillClick(Sender: TObject);
var nStr,nPID: string;
    nIdx: Integer;
begin
  if FListA.Count < 1 then
  begin
    ShowMsg('没有需要同步的数据', sHint);
    Exit;
  end;

  Memo1.Clear;
  FListB.Clear;
  FListB.Add('begin');
  //init sql list

  for nIdx:=0 to FListA.Count - 1 do
  begin
    nStr := 'Select * From XS_Lade_Base' +
            ' left join XS_Lade_Detail on XLD_Lade=xlb_id ' +
            'where xlb_id=''%s''';
    nStr := Format(nStr, [FListA[nIdx]]);

    with Query1 do
    begin
      Memo1.Lines.Add(Format('--%d/%d.', [nIdx+1, FListA.Count]));
      Application.ProcessMessages;
      
      Close;
      SQL.Text := nStr;
      Open;

      nPID := YT_NewID('DB_TURN_PRODUOUT');
      nStr := MakeSQLByStr([SF('DTP_ID', nPID),
              SF('DTP_Card', FieldByName('xld_card').AsString),
              SF('DTP_ScaleBill', FieldByName('xlb_ladeid').AsString),
              SF('DTP_Origin',  '101'),

              SF('DTP_Vehicle', FieldByName('XLB_CarCode').AsString),
              SF('DTP_OutDate', 'trunc(sysdate)', sfVal),
              SF('DTP_Material', FieldByName('XLB_Cement').AsString),
              SF('DTP_CementCode', FieldByName('XLB_CementCode').AsString),
              SF('DTP_Lade', FieldByName('XLB_ID').AsString),

              //SF('DTP_Scale',  nBills[nIdx].FPData.FStation),
              SF('DTP_Creator', 'yt_autofill'),
              SF('DTP_CDate', DateTime2StrOracle(FieldByName('XLB_CDate').AsDateTime),sfVal),
              //SF('DTP_SecondScale',  nBills[nIdx].FMData.FStation),
              //SF('DTP_GMan', nBills[nIdx].FMData.FOperator),
              SF('DTP_GDate', DateTime2StrOracle(FieldByName('XLB_CDate').AsDateTime),sfVal),

              SF('DTP_Firm', FieldByName('XLB_Firm').AsString),
              SF('DTP_GWeight', FieldByName('XLD_GWeight').AsFloat, sfVal),
              SF('DTP_TWeight', FieldByName('XLD_TWeight').AsFloat, sfVal),
              SF('DTP_NWeight', FieldByName('XLD_NWeight').AsFloat, sfVal),

              SF('DTP_ISBalance', '0'),
              SF('DTP_IsSupply', '0'),
              SF('DTP_Status', '1'),
              SF('DTP_Del', '0')
              ], 'DB_Turn_ProduOut', '', True);
      FListB.Add(nStr + ';'); //水泥熟料出厂表

      nStr := MakeSQLByStr([SF('DTU_ID', YT_NewID('DB_TURN_PRODUDTL')),
              SF('DTU_Del', '0'),
              SF('DTU_PID', nPID),
              SF('DTU_LadeID', FieldByName('XLB_ID').AsString),
              SF('DTU_Firm', FieldByName('XLB_Firm').AsString),
              SF('DTU_GWeight', FieldByName('XLD_GWeight').AsFloat, sfVal),
              SF('DTU_TWeight', FieldByName('XLD_TWeight').AsFloat, sfVal),
              SF('DTU_NWeight', FieldByName('XLD_NWeight').AsFloat, sfVal)
              ], 'DB_Turn_ProduDtl', '', True);
      FListB.Add(nStr + ';'); //水泥熟料出厂明细表
    end;
  end;

  nStr := 'commit;' + #13#10 +
          'exception' + #13#10 +
          ' when others then rollback; raise;' + #13#10 +
          'end;';
  FListB.Add(nStr);

  Memo1.Text := FListB.Text;
end;

end.
