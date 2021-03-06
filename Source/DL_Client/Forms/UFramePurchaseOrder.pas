{*******************************************************************************
  ����: fendou116688@163.com 2015/8/8
  ����: �ɹ���������
*******************************************************************************}
unit UFramePurchaseOrder;

{$I Link.Inc}
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
  TfFramePurchaseOrder = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N6: TMenuItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Check1: TcxCheckBox;
    editTruck: TcxButtonEdit;
    dxLayout1Item9: TdxLayoutItem;
    dxLayout1Group1: TdxLayoutGroup;
    dxLayout1Group2: TdxLayoutGroup;
    N4: TMenuItem;
    N5: TMenuItem;
    N7: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure Check1Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //ʱ������
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;

    procedure SendMsgToWebMall(const nOid: string);
    procedure ModifyWebOrderStatus(const nOid: string);
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl,UDataModule, UFrameBase, UFormBase, USysBusiness,
  USysConst, USysDB, UFormDateFilter, UFormInputbox,UBusinessConst,
  UBusinessPacker, USysLoger;

//------------------------------------------------------------------------------
class function TfFramePurchaseOrder.FrameID: integer;
begin
  Result := cFI_FrameOrder;
end;

procedure TfFramePurchaseOrder.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFramePurchaseOrder.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: ���ݲ�ѯSQL
function TfFramePurchaseOrder.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select oo.* From $OO oo ';
  //xxxxx

  if nWhere = '' then
       Result := Result + ' Where (O_Date >=''$ST'' and O_Date<''$End'') '
  else Result := Result + ' Where (' + nWhere + ')';

  if Check1.Checked then
       Result := MacroValue(Result, [MI('$OO', sTable_OrderBak)])
  else Result := MacroValue(Result, [MI('$OO', sTable_Order)]);

  Result := MacroValue(Result, [MI('$OO', sTable_Order),
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: ���
procedure TfFramePurchaseOrder.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormOrder, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: �޸�
procedure TfFramePurchaseOrder.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('O_ID').AsString;
  CreateBaseFormItem(cFI_FormOrder, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: ɾ��
procedure TfFramePurchaseOrder.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('O_ID').AsString;
  if not QueryDlg('ȷ��Ҫɾ�����Ϊ[ ' + nStr + ' ]�Ķ�����?', sAsk) then Exit;

  {$IFDEF EnableWebMall}
  try
    //���͹��ں���Ϣ
    SendMsgToWebMall(SQLQuery.FieldByName('O_ID').AsString);
    nStr := 'update %s set WOM_deleted=''%s'' where WOM_LID=''%s''';
    nStr := Format(nStr,[sTable_WebOrderMatch,sFlag_Yes,SQLQuery.FieldByName('O_ID').AsString]);
    fdm.ExecuteSQL(nStr);
    //�޸��̳Ƕ���״̬
    ModifyWebOrderStatus(SQLQuery.FieldByName('O_ID').AsString);
  except
    //�������쳣
  end;
  {$ENDIF}
  nStr := SQLQuery.FieldByName('O_ID').AsString;

  {$IFDEF PurchaseOrderSingle}
  if gSysParam.FIsMT = 1 then
  begin
    if DeleteOrderSingle(nStr) then ShowMsg('�ѳɹ�ɾ����¼', sHint);
  end
  else
  begin
    if DeleteOrder(nStr) then ShowMsg('�ѳɹ�ɾ����¼', sHint);
  end;
  {$ELSE}
  if DeleteOrder(nStr) then ShowMsg('�ѳɹ�ɾ����¼', sHint);
  {$ENDIF}

  InitFormData('');
end;

//Desc: �鿴����
procedure TfFramePurchaseOrder.cxView1DblClick(Sender: TObject);
begin
end;

//Desc: ����ɸѡ
procedure TfFramePurchaseOrder.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: ִ�в�ѯ
procedure TfFramePurchaseOrder.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'O_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'O_SaleMan like ''%%%s%%'' Or O_SaleMan like ''%%%s%%''';
    FWhere := Format(FWhere, [EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'O_ProPY like ''%%%s%%'' Or O_ProName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end
  else if Sender=editTruck then
  begin
    editTruck.Text := Trim(editTruck.Text);
    if editTruck.Text='' then Exit;

    FWhere := 'o_truck like ''%%%s%%''';
    FWhere := Format(FWhere, [editTruck.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFramePurchaseOrder.N1Click(Sender: TObject);
var nOrderID, nTruck: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;
  nOrderID := SQLQuery.FieldByName('O_ID').AsString;
  nTruck   := SQLQuery.FieldByName('O_Truck').AsString;

  if SetOrderCard(nOrderID, nTruck, True) then
    ShowMsg('����ſ��ɹ�', sHint);
  //����ſ�
end;

procedure TfFramePurchaseOrder.N2Click(Sender: TObject);
var nCard: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nCard := SQLQuery.FieldByName('O_Card').AsString;
  {$IFDEF PurchaseOrderSingle}
  if gSysParam.FIsMT = 1 then
  begin
    if LogoutOrderCardSingle(nCard) then
      ShowMsg('ע���ſ��ɹ�', sHint);
    //����ſ�
  end
  else
  begin
    if LogoutOrderCard(nCard) then
      ShowMsg('ע���ſ��ɹ�', sHint);
    //����ſ�
  end;
  {$ELSE}
  if LogoutOrderCard(nCard) then
    ShowMsg('ע���ſ��ɹ�', sHint);
  //����ſ�
  {$ENDIF}
end;

procedure TfFramePurchaseOrder.N3Click(Sender: TObject);
var nStr,nTruck: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('O_Truck').AsString;
    nTruck := nStr;
    if not ShowInputBox('�������µĳ��ƺ���:', '�޸�', nTruck, 15) then Exit;

    if (nTruck = '') or (nStr = nTruck) then Exit;
    //��Ч��һ��

    nStr := SQLQuery.FieldByName('O_ID').AsString;
    {$IFDEF PurchaseOrderSingle}
    if gSysParam.FIsMT = 1 then
    begin
      if ChangeOrderTruckNoSingle(nStr, nTruck) then
      begin
        InitFormData(FWhere);
        ShowMsg('���ƺ��޸ĳɹ�', sHint);
      end;
    end
    else
    begin
      if ChangeOrderTruckNo(nStr, nTruck) then
      begin
        InitFormData(FWhere);
        ShowMsg('���ƺ��޸ĳɹ�', sHint);
      end;
    end;
    {$ELSE}
    if ChangeOrderTruckNo(nStr, nTruck) then
    begin
      InitFormData(FWhere);
      ShowMsg('���ƺ��޸ĳɹ�', sHint);
    end;
    {$ENDIF}
  end;
end;

procedure TfFramePurchaseOrder.Check1Click(Sender: TObject);
begin
  inherited;
  InitFormData('');
end;

procedure TfFramePurchaseOrder.ModifyWebOrderStatus(const nOid: string);
var
  nWebOrderId:string;
  nXmlStr,nData,nSql:string;
begin
  {$IFNDEF EnableWebMall}
  Exit;
  {$ENDIF}
  
  nWebOrderId := '';
  //��ѯ�����̳Ƕ���
  nSql := 'select WOM_WebOrderID from %s where WOM_LID=''%s''';
  nSql := Format(nSql,[sTable_WebOrderMatch,nOid]);
  with FDM.QueryTemp(nSql) do
  begin
    if recordcount>0 then
    begin
      nWebOrderId := FieldByName('WOM_WebOrderID').asstring;
    end;
  end;
  if nWebOrderId='' then Exit;

  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
      +'<DATA>'
      +'<head><ordernumber>%s</ordernumber>'
      +'<status>%d</status>'
      +'</head>'
      +'</DATA>';
  nXmlStr := Format(nXmlStr,[nWebOrderId,2]);
  nXmlStr := PackerEncodeStr(nXmlStr);

  nData := complete_shoporders(nXmlStr);
  gSysLoger.AddLog(TfFramePurchaseOrder,'ModifyWebOrderStatus',nData);
  if ndata<>'' then
  begin
    ShowMsg(nData,sHint);
  end;
end;

procedure TfFramePurchaseOrder.SendMsgToWebMall(const nOid: string);
var
  nXmlStr,nData:string;
begin
  {$IFNDEF EnableWebMall}
  Exit;
  {$ENDIF}
  
  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
        +'<DATA>'
        +'<head>'
        +'<Factory>%s</Factory>'
        +'<ToUser>%s</ToUser>'
        +'<MsgType>%d</MsgType>'
        +'</head>'
        +'<Items>'
        +'	  <Item>'
        +'	      <BillID>%s</BillID>'
        +'	      <Card>%s</Card>'
        +'	      <Truck>%s</Truck>'
        +'	      <StockNo>%s</StockNo>'
        +'	      <StockName>%s</StockName>'
        +'	      <CusID>%s</CusID>'
        +'	      <CusName>%s</CusName>'
        +'	      <CusAccount>0</CusAccount>'
        +'	      <MakeDate></MakeDate>'
        +'	      <MakeMan></MakeMan>'
        +'	      <TransID></TransID>'
        +'	      <TransName></TransName>'
        +'	      <Searial></Searial>'
        +'	      <OutFact></OutFact>'
        +'	      <OutMan></OutMan>'
        +'	  </Item>	'
        +'</Items>'
        +'   <remark/>'
        +'</DATA>';

  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,
      SQLQuery.FieldByName('o_proid').AsString,
      cSendWeChatMsgType_DelBill,
      SQLQuery.FieldByName('o_id').AsString,
      SQLQuery.FieldByName('o_card').AsString,
      SQLQuery.FieldByName('o_truck').AsString,
      SQLQuery.FieldByName('o_stockno').AsString,
      SQLQuery.FieldByName('o_stockname').AsString,
      SQLQuery.FieldByName('o_proid').AsString,
      SQLQuery.FieldByName('o_proname').AsString]);
  nXmlStr := PackerEncodeStr(nXmlStr);
  nData := send_event_msg(nXmlStr);

  gSysLoger.AddLog(TfFramePurchaseOrder,'SendMsgToWebMall',nData);
  if ndata<>'' then
  begin
    ShowMsg(nData,sHint);
  end;
end;

procedure TfFramePurchaseOrder.N5Click(Sender: TObject);
var nCard, nStr, nTruck, nSql, nCardEx : string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;
  nCard  := SQLQuery.FieldByName('O_Card').AsString;
  nTruck := SQLQuery.FieldByName('O_Truck').AsString;

  if Length(nCard) = 0 then Exit;
  
  if Copy(nCard,1,1) <> 'E' then
  begin
    ShowMsg('���ǵ��ӱ�ǩ,��ѡ����ӱ�ǩ', sHint); Exit;
  end;

  nSql := ' select * from %s where T_Truck = ''%s'' ';
  nSql := Format(nSql,[sTable_Truck,nTruck]);

  with FDM.QueryTemp(nSql) do
  begin
    if recordcount>0 then
    begin
      nCardEx := FieldByName('T_Card').AsString;
    end;
  end;

  try
    nStr := ' Update %s Set O_Card=''%s'' Where O_Card=''%s'' ';
    nStr := Format(nStr, [sTable_Order, nCardEx, nCard]);
    fdm.ExecuteSQL(nStr);

    nStr := ' Update %s Set D_Card=''%s'' Where D_Card=''%s'' ';
    nStr := Format(nStr, [sTable_OrderDtl, nCardEx, nCard]);
    fdm.ExecuteSQL(nStr);
  except

  end;
  InitFormData(FWhere);
  ShowMsg('���ӱ�ǩ����ɹ�', sHint);
end;

procedure TfFramePurchaseOrder.N7Click(Sender: TObject);
var nCard, nStr, nTruck, nSql : string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;
  nCard  := SQLQuery.FieldByName('O_Card').AsString;
  nTruck := SQLQuery.FieldByName('O_Truck').AsString;

  if Length(nCard) = 0 then Exit;
  
  if Copy(nCard,1,1) <> 'E' then
  begin
    ShowMsg('���ǵ��ӱ�ǩ,��ѡ����ӱ�ǩ', sHint); Exit;
  end;

  try
    nStr := ' Update %s Set O_Card=Null Where O_Card=''%s'' ';
    nStr := Format(nStr, [sTable_Order, nCard]);
    fdm.ExecuteSQL(nStr);

    nStr := ' Update %s Set D_Card=Null Where D_Card=''%s'' ';
    nStr := Format(nStr, [sTable_OrderDtl, nCard]);
    fdm.ExecuteSQL(nStr);
  except

  end;
  InitFormData(FWhere);
  ShowMsg('���ӱ�ǩע���ɹ�', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFramePurchaseOrder, TfFramePurchaseOrder.FrameID);
end.
