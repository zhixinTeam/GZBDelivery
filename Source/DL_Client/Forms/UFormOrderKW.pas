{*******************************************************************************
  作者: dmzn@163.com 2018-12-14
  描述: 开提货单
*******************************************************************************}
unit UFormOrderKW;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxListView,
  cxDropDownEdit, cxTextEdit, cxMaskEdit, cxButtonEdit, cxMCListBox,
  dxLayoutControl, StdCtrls;

type
  TfFormOrderKW = class(TfFormNormal)
    dxLayout1Item10: TdxLayoutItem;
    EditStockNo: TcxComboBox;
    EditStockName: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Item5: TdxLayoutItem;
    ListQuery: TcxListView;
    EditProName: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditOID: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditProID: TcxComboBox;
    dxLayout1Item8: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditSalesManPropertiesChange(Sender: TObject);
    procedure EditNamePropertiesEditValueChanged(Sender: TObject);
    procedure EditStockNoKeyPress(Sender: TObject; var Key: Char);
    procedure BtnOKClick(Sender: TObject);
    procedure EditZKPropertiesEditValueChanged(Sender: TObject);
    procedure EditStockNoPropertiesEditValueChanged(Sender: TObject);
    procedure EditProIDPropertiesEditValueChanged(Sender: TObject);
  protected
    { Private declarations }
    FListA: TStrings;
    nL_Value,nL_Money,AL_Money: Double;
    nD_ID,nD_OID,nO_StockNo,nO_StockName,nO_Truck:string;
    ASaleID,ASaleMan,ACusID,ACusName,ACus_PY,ACus_Area,AL_ZhiKa,AL_Project:string;
    FShowPrice: Boolean;
    //显示单价
    procedure InitFormData(const nID: string);
    //载入数据
    procedure ClearCustomerInfo;
    function LoadCustomerInfo(nID: string;
      const nIsCode: Boolean= False): Boolean;
    //载入客户
    procedure WriteOptionLog(const LID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UFormBase, UMgrControl, UAdjustForm, UDataModule,
  USysPopedom, USysGrid, USysDB, USysConst, USysBusiness;

var
  gParam: PFormCommandParam = nil;
  //全局使用

class function TfFormOrderKW.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var
  nModifyStr: string;
begin
  Result := nil;
  if Assigned(nParam) then
    gParam := nParam
  else Exit;
  
  nModifyStr :=gParam.FParamA;

  with TfFormOrderKW.Create(Application) do
  try
    Caption := '采购订单勘误';

    FListA.Text := nModifyStr;
    InitFormData('');
    FShowPrice := gPopedomManager.HasPopedom(nPopedom, sPopedom_ViewPrice);
    
    gParam.FCommand := cCmd_ModalResult;
    gParam.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormOrderKW.FormID: integer;
begin
  Result := cFI_FormOrderKW;
end;

procedure TfFormOrderKW.FormCreate(Sender: TObject);
begin
  FListA    := TStringList.Create;
  dxGroup1.AlignVert := avTop;
end;

procedure TfFormOrderKW.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ReleaseCtrlData(Self);
  FListA.Free;
end;

//------------------------------------------------------------------------------
procedure TfFormOrderKW.InitFormData(const nID: string);
var
  nStr: string;
begin
  dxGroup1.AlignVert := avTop;

  nStr := ' Select * From P_Orderdtl od Inner Join P_Order oo on od.D_OID=oo.O_ID ' +
          ' where D_ID = ''%s'' ';
  nStr := Format(nStr,[FListA.Strings[0]]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;

    with ListQuery.Items.Add do
    begin
      Caption := FieldByName('D_OID').AsString;
      SubItems.Add(FieldByName('O_StockNo').AsString);
      SubItems.Add(FieldByName('O_StockName').AsString);
      SubItems.Add(FieldByName('O_Truck').AsString);
      ImageIndex := cItemIconIndex;
    end;

    nD_ID        := FieldByName('D_ID').AsString;
    nD_OID       := FieldByName('D_OID').AsString;
    nO_StockNo   := FieldByName('O_StockNo').AsString;
    nO_StockName := FieldByName('O_StockName').AsString;
    nO_Truck     := FieldByName('O_Truck').AsString;
  end;
  ActiveControl := EditStockNo;
  EditStockNo.Clear;

  nStr := ' Select distinct O_StockNo+''-''+O_StockName as O_StockNo From P_Order where O_Truck = ''%s'' and O_ID <> ''%s''  ';
  nStr := Format(nStr, [nO_Truck,nD_OID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;
    while not Eof do
    begin
      EditStockNo.Properties.Items.Add(FieldByName('O_StockNo').AsString);
      Next;
    end;
  end;

  if EditStockNo.Properties.Items.Count > 0 then
    EditStockNo.ItemIndex := 0;

  EditProID.Clear;
  nStr := ' Select distinct O_ProID+''-''+O_ProName as O_ProID From P_Order where O_Truck = ''%s'' and O_ID <> ''%s''  ';
  nStr := Format(nStr, [nO_Truck,nD_OID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;
    while not Eof do
    begin
      EditProID.Properties.Items.Add(FieldByName('O_ProID').AsString);
      Next;
    end;
  end;
  if EditProID.Properties.Items.Count > 0 then
    EditProID.ItemIndex := 0;
end;

//Desc: 清理客户信息
procedure TfFormOrderKW.ClearCustomerInfo;
begin

end;

//Desc: 载入nID客户的信息
function TfFormOrderKW.LoadCustomerInfo(nID: string;
  const nIsCode: Boolean): Boolean;
var nDS: TDataSet;
    nStr,nZhiKa,nCusName,nSaleMan: string;
begin
  Result := False;
  ClearCustomerInfo;

  if nIsCode then
  begin
    nZhiKa := nID;
  end else nZhiKa := '';

  //----------------------------------------------------------------------------
  if nZhiKa = '' then
  begin
    nStr := 'Z_ID=Select Z_ID, Z_Name From %s ' +
            'Where Z_Customer=''%s'' And Z_ValidDays>%s And ' +
            'IsNull(Z_InValid, '''')<>''%s'' And ' +
            'IsNull(Z_Freeze, '''')<>''%s'' Order By Z_ID';
    nStr := Format(nStr, [sTable_ZhiKa, nID, sField_SQLServer_Now,
            sFlag_Yes, sFlag_Yes]);
    //xxxxx
  end else
  begin
    nStr := 'Z_ID=Select Z_ID, Z_Name From %s Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, nZhiKa]);
  end;
end;

procedure TfFormOrderKW.EditSalesManPropertiesChange(Sender: TObject);
var nStr: string;
begin
end;

procedure TfFormOrderKW.EditNamePropertiesEditValueChanged(Sender: TObject);
begin
end;

//Desc: 选择客户
procedure TfFormOrderKW.EditStockNoKeyPress(Sender: TObject; var Key: Char);
var nStr: string;
    nP: TFormCommandParam;
begin

end;

procedure TfFormOrderKW.BtnOKClick(Sender: TObject);
var
  nStr, nSQL: string;
begin
  if Trim(EditStockName.Text) = '' then
  begin
    ShowMsg('物料信息不能为空', sHint);
    Exit;
  end;
  //更改明细信息
  nSQL := 'Update %s Set D_OID = ''%s'' Where D_ID=''%s''';
  nSQL := Format(nSQL, [sTable_OrderDtl,Trim(EditOID.Text), nD_ID]);
  FDM.ExecuteSQL(nSQL);
  WriteOptionLog(nD_ID);

  //更新磅单信息
  nStr := 'Update Sys_PoundLog Set P_CusID=''%s'',P_CusName=''%s'',P_MID=''%s'',P_MName=''%s''  Where P_Order=''%s''';
  nStr := Format(nStr, [Copy(EditProID.Text,1,Pos('-',EditProID.Text)-1),Trim(EditProName.Text),Copy(EditStockNo.Text,1,Pos('-',EditStockNo.Text)-1),
  Trim(EditStockName.Text),nD_ID]);
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;

  nStr := '勘误完成';
  ShowMsg(nStr, sHint);
end;

procedure TfFormOrderKW.WriteOptionLog(const LID: string);
var nEvent: string;
begin
  nEvent := '';

  try
    nEvent := nEvent + '采购订单由 [ %s ] --> [ %s ];';
    nEvent := Format(nEvent, [nD_OID, Trim(EditOID.Text)]);

    if nEvent <> '' then
    begin
      nEvent := '采购明细单 [ %s ] 记录已被修改:' + nEvent;
      nEvent := Format(nEvent, [LID]);
    end;
    if nEvent <> '' then
    begin
      FDM.WriteSysLog(sFlag_BillItem, LID, nEvent);
    end;
  except
  end;
end;

procedure TfFormOrderKW.EditZKPropertiesEditValueChanged(Sender: TObject);
var
  nStr : string;
begin
  inherited;
end;

procedure TfFormOrderKW.EditStockNoPropertiesEditValueChanged(
  Sender: TObject);
var
  nStr:string;
begin
  inherited;
  nStr := ' Select O_StockName,O_ID,O_ProID,O_ProName From P_Order where O_Truck = ''%s'' '+
          ' and O_ID <> ''%s'' and O_StockNo = ''%s'' and O_ProID = ''%s'' ';
  nStr := Format(nStr, [nO_Truck,nD_OID, Copy(EditStockNo.Text,1,Pos('-',EditStockNo.Text)-1), Copy(EditProID.Text,1,Pos('-',EditProID.Text)-1)]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      EditStockName.Text := FieldByName('O_StockName').AsString;
      EditOID.Text       := FieldByName('O_ID').AsString;
      EditProName.Text   := FieldByName('O_ProName').AsString;
    end
    else
    begin
      EditStockName.Text := '';
      EditOID.Text       := '';
      EditProName.Text   := '';
    end;
  end;
end;

procedure TfFormOrderKW.EditProIDPropertiesEditValueChanged(
  Sender: TObject);
var
  nStr:string;
begin
  inherited;
  nStr := ' Select O_StockName,O_ID,O_ProID,O_ProName From P_Order where O_Truck = ''%s'' '+
          ' and O_ID <> ''%s'' and O_StockNo = ''%s'' and O_ProID = ''%s'' ';
  nStr := Format(nStr, [nO_Truck,nD_OID, Copy(EditStockNo.Text,1,Pos('-',EditStockNo.Text)-1), Copy(EditProID.Text,1,Pos('-',EditProID.Text)-1)]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      EditStockName.Text := FieldByName('O_StockName').AsString;
      EditOID.Text       := FieldByName('O_ID').AsString;
      EditProName.Text   := FieldByName('O_ProName').AsString;
    end
    else
    begin
      EditStockName.Text := '';
      EditOID.Text       := '';
      EditProName.Text   := '';
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormOrderKW, TfFormOrderKW.FormID);
end.
