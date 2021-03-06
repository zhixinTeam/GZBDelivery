{*******************************************************************************
����: fendou116688@163.com 2016/10/31
����: �ɹ���ϸ����
*******************************************************************************}
unit UFormOrderDtl;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, UFormBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutControl, cxCheckBox,
  cxLabel, StdCtrls, cxMaskEdit, cxDropDownEdit, cxMCListBox, cxMemo,
  cxTextEdit, cxButtonEdit;

type
  TfFormOrderDtl = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group5: TdxLayoutGroup;
    EditTunnelID: TcxButtonEdit;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    EditTunnelName: TcxTextEdit;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Group4: TdxLayoutGroup;
    EditStock: TcxButtonEdit;
    dxLayoutControl1Item6: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayoutControl1Item7: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditStockKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FOrderID,FDetailID: string;
    //���ݱ�ʶ
    procedure InitFormData(const nID: string);
    //��������
    function SetData(Sender: TObject; const nData: string): Boolean;
    //�������
    procedure WriteOptionLog;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UFormCtrl, UAdjustForm, USysBusiness,
  USysGrid, USysDB, USysConst;

type
  TDataOldItem = record
    FID        : string;
    FName      : string;
    FProID     : string;
    FProName   : string;
    FUpdate    : Boolean;
  end;

var
  gForm: TfFormOrderDtl = nil;
  //ȫ��ʹ��
  gOldData: TDataOldItem;
  //ԭʼͨ������

class function TfFormOrderDtl.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
   cCmd_EditData:
    with TfFormOrderDtl.Create(Application) do
    begin
      FDetailID             := nP.FParamA;
      FOrderID              := nP.FParamB;
      EditTunnelID.Text     := nP.FParamA;
      EditTunnelName.Text   := nP.FParamB;
      EditStock.Text        := nP.FParamC;
      EditStockName.Text    := nP.FParamD;
      Caption := '�ֳ�ͨ����Ʒ�� - �޸�';

      InitFormData(FDetailID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end; 
end;

class function TfFormOrderDtl.FormID: integer;
begin
  Result := cFI_FormOrderDtl;
end;

//------------------------------------------------------------------------------
procedure TfFormOrderDtl.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormOrderDtl.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  gForm := nil;
  Action := caFree;
  ReleaseCtrlData(Self);
end;

procedure TfFormOrderDtl.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormOrderDtl.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
  begin
    Key := 0; Close;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��������
function TfFormOrderDtl.SetData(Sender: TObject; const nData: string): Boolean;
begin
  Result := False;
end;

//Date: 2009-6-2
//Parm: ��Ӧ�̱��
//Desc: ����nID��Ӧ�̵���Ϣ������
procedure TfFormOrderDtl.InitFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    //��¼ԭʼ����
    gOldData.FID        := EditStock.Text;
    gOldData.FName      := EditStockName.Text;
    gOldData.FProID     := EditTunnelID.Text;
    gOldData.FProName   := EditTunnelName.Text;
  end;
end;

//Desc: ��������
procedure TfFormOrderDtl.BtnOKClick(Sender: TObject);
var nSQL, nStr: string;
    nP: TFormCommandParam;
begin
  FDM.ADOConn.BeginTrans;
  try

    nSQL := MakeSQLByStr([
             SF('D_ParamB', EditStock.Text),
             SF('D_Desc', EditStockName.Text)
             ],sTable_SysDict,
             SF('D_Name', 'StockTunnel')+ ' and '+SF('D_Value', EditTunnelID.Text),False);
    FDM.ExecuteSQL(nSQL);

    FDM.ADOConn.CommitTrans;
    WriteOptionLog;
    //--д�������־
    ModalResult := mrOK;
    ShowMsg('�����ѱ���', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('���ݱ���ʧ��', 'δ֪ԭ��');
  end;
end;

procedure TfFormOrderDtl.EditStockKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;
  if (Key = Char(VK_RETURN)) or (Key = Char(VK_Space))  then
  begin
    Key := #0;

    if Sender = EditStock then
    begin
      CreateBaseFormItem(cFI_FormGetMeterail, '', @nP);
      if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOk) then Exit;

      EditStock.Text := nP.FParamB;
      EditStockName.Text := nP.FParamC;
    end;
  end;
end;

procedure TfFormOrderDtl.WriteOptionLog;
var nEvent: string;
begin
  nEvent := '';

  if gOldData.FID <> EditStock.Text then
  begin
    nEvent := nEvent + 'ԭ���ϱ���� [ %s ] --> [ %s ];';
    nEvent := Format(nEvent, [gOldData.FID, EditStock.Text]);
  end;
  if gOldData.FName <> EditStockName.Text then
  begin
    nEvent := nEvent + 'ԭ���������� [ %s ] --> [ %s ];';
    nEvent := Format(nEvent, [gOldData.FName, EditStockName.Text]);
  end;
  if nEvent <> '' then
  begin
    nEvent := 'ͨ����Ʒ�� [ %s ] �����ѱ��޸�:' + nEvent;
    nEvent := Format(nEvent, [gOldData.FID]);
  end;

  if nEvent <> '' then
  begin
    FDM.WriteSysLog('StockTunnel', EditTunnelID.Text, nEvent);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormOrderDtl, TfFormOrderDtl.FormID);
end.
