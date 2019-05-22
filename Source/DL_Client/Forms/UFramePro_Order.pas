{*******************************************************************************
  作者: 584701820@qq.com 2019/5/11
  描述: 供应商原材料进厂限制
*******************************************************************************}
unit UFramePro_Order;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxCheckBox;

type
  TfFramePro_Order = class(TfFrameNormal)
    EditStockName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N6: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure Check1Click(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl,UDataModule, UFrameBase, UFormBase, USysBusiness,
  USysConst, USysDB, UFormDateFilter, UFormInputbox;

//------------------------------------------------------------------------------
class function TfFramePro_Order.FrameID: integer;
begin
  Result := cFI_FramePro_Order;
end;

procedure TfFramePro_Order.OnCreateFrame;
begin
  inherited;
end;

procedure TfFramePro_Order.OnDestroyFrame;
begin
  inherited;
end;

//Desc: 数据查询SQL
function TfFramePro_Order.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From $Pro_Order ';
  //xxxxx

  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$Pro_Order', sTable_Pro_Order)]);

end;

//Desc: 关闭
procedure TfFramePro_Order.BtnExitClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if not IsBusy then
  begin
    nParam.FCommand := cCmd_FormClose;
    CreateBaseFormItem(cFI_FormPro_Order, '', @nParam); Close;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 添加
procedure TfFramePro_Order.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormPro_Order, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFramePro_Order.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要编辑的记录', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('P_ID').AsString;
  CreateBaseFormItem(cFI_FormPro_Order, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: 删除
procedure TfFramePro_Order.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('P_ID').AsString;
  if not QueryDlg('确定要删除编号为[ ' + nStr + ' ]的记录吗?', sAsk) then Exit;

  nSQL := 'Delete From %s Where P_ID = ''%s'' ';
  nSQL := Format(nSQL, [sTable_Pro_Order, nStr]);
  FDM.ExecuteSQL(nSQL);

  ShowMsg('已成功删除记录', sHint);

  InitFormData('');
end;

//Desc: 查看内容
procedure TfFramePro_Order.cxView1DblClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nParam.FCommand := cCmd_ViewData;
    nParam.FParamA := SQLQuery.FieldByName('P_ID').AsString;
    //CreateBaseFormItem(cFI_FormOrderBase, PopedomItem, @nParam);
  end;
end;

//Desc: 执行查询
procedure TfFramePro_Order.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditStockName then
  begin
    EditStockName.Text := Trim(EditStockName.Text);
    if EditStockName.Text = '' then Exit;

    FWhere := ' P_StockNo like ''%%%s%%'' Or P_StockName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditStockName.Text, EditStockName.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := ' P_PY like ''%%%s%%'' Or P_Name like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFramePro_Order.Check1Click(Sender: TObject);
begin
  inherited;
  InitFormData('');
end;

initialization
  gControlManager.RegCtrl(TfFramePro_Order, TfFramePro_Order.FrameID);
end.
