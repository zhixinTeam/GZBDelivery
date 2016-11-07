unit UFormMaterailTunnel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, UFormBase, cxContainer,
  cxEdit, cxTextEdit, cxMaskEdit, cxButtonEdit;

type
  TfFormMaterailTunnel = class(TfFormNormal)
    EditStockNO: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditTunnel: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditStockNOPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    FRID: string;
    procedure LoadFormData(const nID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormMaterailTunnel: TfFormMaterailTunnel;

implementation

{$R *.dfm}

uses
  UMgrControl, USysConst, UDataModule, USysDB, ULibFun;

class function TfFormMaterailTunnel.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormMaterailTunnel.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '验收通道 - 添加';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '验收通道 - 修改';
      FRID := nP.FParamA;
    end;

    LoadFormData(FRID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormMaterailTunnel.FormID: integer;
begin
  Result := cFI_FormMaterailTunnel;
end;

procedure TfFormMaterailTunnel.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where D_ID=%s And D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, nID, sFlag_MaterailTunnel]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      EditStockNO.Text   := FieldByName('D_ParamB').AsString;
      EditStockName.Text := FieldByName('D_Value').AsString;

      EditTunnel.Text    := FieldByName('D_Memo').AsString;
    end;
  end;
end;

procedure TfFormMaterailTunnel.BtnOKClick(Sender: TObject);
var nSQL: string;
begin
  inherited;
  EditStockNO.Text := Trim(EditStockNO.Text);
  if EditStockNO.Text = '' then
  begin
    ShowMsg('原材料编号不能为空', sHint);
    ActiveControl := EditStockNO;
    Exit;
  end;

  EditTunnel.Text := Trim(EditTunnel.Text);
  if EditTunnel.Text = '' then
  begin
    ShowMsg('通道编号不能为空', sHint);
    ActiveControl := EditTunnel;
    Exit;
  end;

  if FRID <> '' then
  begin
    nSQL := 'Update %s Set D_Memo=''%s'',D_Value=''%s'',D_ParamB=''%s'' ' +
            'Where D_ID=%s';
    nSQL := Format(nSQL, [sTable_SysDict, EditTunnel.Text, EditStockName.Text,
            EditStockNO.Text, FRID]);
    FDM.ExecuteSQL(nSQL);
  end else
  begin
    nSQL := 'Select * From %s Where D_Name=''%s'' And D_Memo=''%s'' ' +
            'And D_ParamB=''%s''';
    nSQL := Format(nSQL, [sTable_SysDict, sFlag_MaterailTunnel,
            EditTunnel.Text, EditStockNO.Text]);

    if FDM.QueryTemp(nSQL).RecordCount < 1 then
    begin
      nSQL := 'Insert Into Sys_Dict(D_Name, D_Desc, D_Value, D_Memo, D_ParamB) ' +
              'Values(''%s'', ''原材料卸货通道'', ''%s'', ''%s'', ''%s'')';
      nSQL := Format(nSQL, [sFlag_MaterailTunnel, EditStockName.Text,
              EditTunnel.Text, EditStockNO.Text]);
      FDM.ExecuteSQL(nSQL);
    end; 
  end;

  ModalResult := mrOk;
  ShowMsg('原材料刷卡通道信息保存成功', sHint);
end;

procedure TfFormMaterailTunnel.EditStockNOPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  nP.FParamA := Trim(EditStockNO.Text);
  CreateBaseFormItem(cFI_FormGetMeterail, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    EditStockNO.Text := nP.FParamB;
    EditStockName.Text := nP.FParamC;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormMaterailTunnel, TfFormMaterailTunnel.FormID);
end.
