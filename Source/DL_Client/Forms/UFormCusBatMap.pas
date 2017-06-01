unit UFormCusBatMap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLabel;

type
  TfFormCusBatMap = class(TfFormNormal)
    EditAddrID: TcxComboBox;
    dxLayout1Item5: TdxLayoutItem;
    EditLineType: TcxComboBox;
    dxLayout1Item9: TdxLayoutItem;
    EditCusID: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    EditIsVip: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FRecord: string;
    procedure LoadFormData(const nID: String='');
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;

    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

var
  fFormCusBatMap: TfFormCusBatMap;

implementation

{$R *.dfm}

uses
  ULibFun, USysConst, USysDB, UMgrControl, USysBusiness,
  UDataModule, UFormBase, UAdjustForm, UFormCtrl;

class function TfFormCusBatMap.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nPP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nPP := nParam
  else Exit;

  with TfFormCusBatMap.Create(Application) do
  try
    if nPP.FCommand = cCmd_AddData then
    begin
      Caption := '关联品种批次 - 新增';
      FRecord := '';
    end else

    if nPP.FCommand = cCmd_EditData then
    begin
      Caption := '关联品种批次 - 修改';
      FRecord := nPP.FParamA;
    end else

    if nPP.FCommand = cCmd_EditData then
    begin
      Caption := '关联品种批次 - 查看';
      FRecord := nPP.FParamA;

      BtnOK.Enabled := False;
    end else Exit;

    LoadFormData(FRecord);
    nPP.FCommand := cCmd_ModalResult;
    nPP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormCusBatMap.FormID: integer;
begin
  Result := cFI_FormCusBatMap;
end;

function TfFormCusBatMap.OnVerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
begin
  Result := True;
end;

procedure TfFormCusBatMap.LoadFormData(const nID: string);
var nSQL: string;
begin
  if Length(nID) < 1 then Exit;
  //无记录

  nSQL := 'Select * From %s Where R_ID=%s';
  nSQL := Format(nSQL, [sTable_YT_CusBatMap, nID]);
  with FDM.QuerySQL(nSQL) do
  if RecordCount > 0 then
  begin
    SetCtrlData(EditCusID, FieldByName('M_CusID').AsString);
    SetCtrlData(EditIsVip, FieldByName('M_IsVip').AsString);
    SetCtrlData(EditAddrID, FieldByName('M_AddrID').AsString);
    SetCtrlData(EditLineType, FieldByName('M_LineGroup').AsString);
  end;
end;

procedure TfFormCusBatMap.FormCreate(Sender: TObject);
begin
  inherited;
  AdjustCtrlData(Self);
  LoadFormConfig(Self);

  LoadCustomer(EditCusID.Properties.Items, 'C_Index=1');
  //加载客户
  LoadCustomer(EditAddrID.Properties.Items, 'C_XuNi=''Y''');
  //加载工地

  LoadZTLineGroup(EditLineType.Properties.Items);
  //载入栈台类型列表
end;

procedure TfFormCusBatMap.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);
end;

procedure TfFormCusBatMap.BtnOKClick(Sender: TObject);
var nSQL, nW: string;
begin
  inherited;
  if FRecord <> '' then nW := SF('R_ID', FRecord);

  nSQL := MakeSQLByStr([
          SF('M_CusPY', GetPinYinOfStr(EditCusID.Text)),
          SF('M_CusID', GetCtrlData(EditCusID)),
          SF('M_CusName', EditCusID.Text),

          SF('M_AddrID', GetCtrlData(EditAddrID)),
          SF('M_AddrName', EditAddrID.Text),

          SF('M_LineGroup', GetCtrlData(EditLineType)),
          SF('M_IsVip', GetCtrlData(EditIsVip))
          //SF('M_Line', GetCtrlData(EditLine)),
          //SF('M_LineName', EditLine.Text)
          ], sTable_YT_CusBatMap, nW, FRecord='');
  FDM.ExecuteSQL(nSQL);

  ShowMsg('保存批次管理成功', sHint);
  ModalResult := mrOK;
end;

initialization
  gControlManager.RegCtrl(TfFormCusBatMap, TfFormCusBatMap.FormID);
end.
