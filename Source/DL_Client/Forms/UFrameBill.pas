{*******************************************************************************
  作者: dmzn@163.com 2009-6-22
  描述: 开提货单
*******************************************************************************}
unit UFrameBill;

{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, Menus,
  UBitmapPanel, cxSplitter, cxLookAndFeels, cxLookAndFeelPainters,
  cxCheckBox;

type
  TfFrameBill = class(TfFrameNormal)
    EditCus: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    EditLID: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Edit1: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    dxLayout1Item10: TdxLayoutItem;
    CheckDelete: TcxCheckBox;
    dxlytmLayout1Item11: TdxLayoutItem;
    EditYTCard: TcxButtonEdit;
    N10: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure CheckDeleteClick(Sender: TObject);
    procedure N10Click(Sender: TObject);
  protected
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    FGL: Boolean;
    FShadowWeight: Double;
    //影子重量
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
    {*查询SQL*}
    procedure SendMsgToWebMall(const nBillno:string);
    procedure ModifyWebOrderStatus(const nLId:string);
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter,UBusinessConst,
  UBusinessPacker,USysLoger;

//------------------------------------------------------------------------------
class function TfFrameBill.FrameID: integer;
begin
  Result := cFI_FrameBill;
end;

procedure TfFrameBill.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
  FShadowWeight := -1;
end;

procedure TfFrameBill.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 数据查询SQL
function TfFrameBill.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  FEnableBackDB := True;

  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select *, c.C_NAME From $Bill Left Join S_Customer c On L_CusID=c.C_ID ';
  //提货单

  if (nWhere = '') or FUseDate then
  begin
    Result := Result + 'Where (L_Date>=''$ST'' and L_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  {$IFDEF GLlade}
  FGL := PopedomItem = 'MAIN_N03';
  if FGL then
    Result := Result + 'And L_CardUsed = ''$CU'''
  else
    Result := Result + 'And (L_CardUsed <> ''$CU'' or L_CardUsed is null)';

  if not gPopedomManager.HasPopedom(PopedomItem, sPopedom_FullReport) then
  begin
    if FShadowWeight < 0 then
    begin
      FShadowWeight := 0;
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ShadowWeight]);

      with FDM.QueryTemp(nStr) do
      if RecordCount > 0 then
      begin
        FShadowWeight := Fields[0].AsFloat;
      end;
    end;

    if FShadowWeight > 0 then
    begin
      nStr := ' And L_MValue<%f';
      Result := Result +  Format(nStr, [FShadowWeight]);
    end;
  end;

  Result := MacroValue(Result, [
        MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1)),
        MI('$CU', sFlag_SaleSingle)]);
  {$ELSE}
  Result := MacroValue(Result, [
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
  {$ENDIF}

  if CheckDelete.Checked then
       Result := MacroValue(Result, [MI('$Bill', sTable_BillBak)])
  else Result := MacroValue(Result, [MI('$Bill', sTable_Bill)]);
end;

procedure TfFrameBill.AfterInitFormData;
begin
  FUseDate := True;
end;

function TfFrameBill.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'L_Price';
end;

//Desc: 执行查询
procedure TfFrameBill.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditLID then
  begin
    EditLID.Text := Trim(EditLID.Text);
    if EditLID.Text = '' then Exit;

    FUseDate := Length(EditLID.Text) <= 3;
    {$IFDEF AllUseDate}
    FUseDate := True;
    {$ENDIF}
    FWhere := 'L_ID like ''%' + EditLID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FUseDate := Length(EditTruck.Text) <= 3;
    {$IFDEF AllUseDate}
    FUseDate := True;
    {$ENDIF}
    FWhere := Format('L_Truck like ''%%%s%%''', [EditTruck.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditYTCard then
  begin
    EditYTCard.Text := Trim(EditYTCard.Text);
    if EditYTCard.Text = '' then Exit;

    FUseDate := Length(EditYTCard.Text) <= 3;
    {$IFDEF AllUseDate}
    FUseDate := True;
    {$ENDIF}
    FWhere := Format('L_Project like ''%%%s%%''', [EditYTCard.Text]);
    InitFormData(FWhere); 
  end;
end;

//Desc: 未开始提货的提货单
procedure TfFrameBill.N4Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
   10: FWhere := Format('(L_Status=''%s'')', [sFlag_BillNew]);
   20: FWhere := 'L_OutFact Is Null'
   else Exit;
  end;

  FUseDate := False;
  InitFormData(FWhere);
end;

//Desc: 日期筛选
procedure TfFrameBill.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//Desc: 查询删除
procedure TfFrameBill.CheckDeleteClick(Sender: TObject);
begin
  InitFormData('');
end;

//------------------------------------------------------------------------------
//Desc: 开提货单
procedure TfFrameBill.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if FGL then
    CreateBaseFormItem(cFI_FormBillSingle, PopedomItem, @nP)
  else
    CreateBaseFormItem(cFI_FormBill, PopedomItem, @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 删除
procedure TfFrameBill.BtnDelClick(Sender: TObject);
var
  nID: string;
  nStr, nHasOut: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nHasOut := Trim(SQLQuery.FieldByName('L_OutFact').AsString);
  if nHasOut <> '' then
  begin
    if not gSysParam.FIsAdmin then Exit;

    nStr := '编号[ %s ]车辆已出厂, 请确认是否删除?';
    nStr := Format(nStr, [SQLQuery.FieldByName('L_ID').AsString]);
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := '确定要删除编号为[ %s ]的单据吗?';
  nStr := Format(nStr, [SQLQuery.FieldByName('L_ID').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  {$IFDEF UseWXServiceEx}
  try
    gSysLoger.AddLog(TfFrameBill, '删除销售单', SQLQuery.FieldByName('L_ID').AsString);
    SaveWebOrderDelMsg(SQLQuery.FieldByName('L_ID').AsString,sFlag_Sale);
  except
    ShowMsg('插入微信端消息推送失败.',sHint);
  end;
  //插入删除推送
  {$ENDIF}

  {$IFDEF EnableWebMall}
  try
    //推送公众号消息
    SendMsgToWebMall(SQLQuery.FieldByName('L_ID').AsString);
    nStr := 'update %s set WOM_deleted=''%s'' where WOM_LID=''%s''';
    nStr := Format(nStr,[sTable_WebOrderMatch,sFlag_Yes,SQLQuery.FieldByName('L_ID').AsString]);
    fdm.ExecuteSQL(nStr);
    //修改商城订单状态
    ModifyWebOrderStatus(SQLQuery.FieldByName('L_ID').AsString);
  except
    //不处理异常
  end;
  {$ENDIF}

  if FGL then
  begin
    if DeleteBillSingle(SQLQuery.FieldByName('L_ID').AsString) then
    begin
      InitFormData(FWhere);
      ShowMsg('提货单已删除', sHint);
    end;
  end
  else
  begin
    if DeleteBill(SQLQuery.FieldByName('L_ID').AsString) then
    begin
      InitFormData(FWhere);
      ShowMsg('提货单已删除', sHint);
    end;
  end;
end;

//Desc: 打印提货单
procedure TfFrameBill.N1Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillReport(nStr, False);
  end;
end;

procedure TfFrameBill.PMenu1Popup(Sender: TObject);
begin
  N3.Enabled := gPopedomManager.HasPopedom(PopedomItem, sPopedom_Edit);
  //销售调拨
end;

//Desc: 修改未进厂车牌号
procedure TfFrameBill.N5Click(Sender: TObject);
var nStr,nTruck: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_Truck').AsString;
    nTruck := nStr;
    if not ShowInputBox('请输入新的车牌号码:', '修改', nTruck, 15) then Exit;

    if (nTruck = '') or (nStr = nTruck) then Exit;
    //无效或一致

    nStr := SQLQuery.FieldByName('L_ID').AsString;
    if ChangeLadingTruckNo(nStr, nTruck) then
    begin
      InitFormData(FWhere);
      ShowMsg('车牌号修改成功', sHint);
    end;
  end;
end;

//Desc: 修改封签号
procedure TfFrameBill.N7Click(Sender: TObject);
var nStr,nID,nSeal: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_Seal').AsString;
    nSeal := nStr;
    if not ShowInputBox('请输入新的封签编号:', '修改', nSeal, 100) then Exit;

    if (nSeal = '') or (nStr = nSeal) then Exit;
    //无效或一致
    nID := SQLQuery.FieldByName('L_ID').AsString;

    nStr := '确定要将交货单[ %s ]的封签号该为[ %s ]吗?';
    nStr := Format(nStr, [nID, nSeal]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Update %s Set L_Seal=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nSeal, nID]);
    FDM.ExecuteSQL(nStr);

    nStr := '修改封签号[ %s -> %s ].';
    nStr := Format(nStr, [SQLQuery.FieldByName('L_Seal').AsString, nSeal]);
    FDM.WriteSysLog(sFlag_BillItem, nID, nStr, False);

    InitFormData(FWhere);
    ShowMsg('封签号修改成功', sHint);
  end;
end;

//Desc: 调拨提货单
procedure TfFrameBill.N3Click(Sender: TObject);
var nStr,nTmp: string;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_AddData;
    CreateBaseFormItem(cFI_FormGetZhika, PopedomItem, @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    nStr := SQLQuery.FieldByName('L_ZhiKa').AsString;
    if nStr = nP.FParamB then
    begin
      ShowMsg('相同纸卡不能调拨', sHint);
      Exit;
    end;

    nStr := 'Select C_ID,C_Name From %s,%s ' +
            'Where Z_ID=''%s'' And Z_Customer=C_ID';
    nStr := Format(nStr, [sTable_ZhiKa, sTable_Customer, nP.FParamB]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('纸卡信息无效', sHint);
        Exit;
      end;

      nStr := '系统将执行提货调拨操作,明细如下: ' + #13#10#13#10 +
              '※.从客户: %s.%s' + #13#10 +
              '※.到客户: %s.%s' + #13#10 +
              '※.品  种: %s.%s' + #13#10 +
              '※.调拨量: %.2f吨' + #13#10#13#10 +
              '确定要执行请点击"是".';
      nStr := Format(nStr, [SQLQuery.FieldByName('L_CusID').AsString,
              SQLQuery.FieldByName('L_CusName').AsString,
              FieldByName('C_ID').AsString,
              FieldByName('C_Name').AsString,
              SQLQuery.FieldByName('L_StockNo').AsString,
              SQLQuery.FieldByName('L_StockName').AsString,
              SQLQuery.FieldByName('L_Value').AsFloat]);
      if not QueryDlg(nStr, sAsk) then Exit;
    end;

    nStr := SQLQuery.FieldByName('L_ID').AsString;
    if BillSaleAdjust(nStr, nP.FParamB) then
    begin
      nTmp := '销售调拨给纸卡[ %s ].';
      nTmp := Format(nTmp, [nP.FParamB]);

      FDM.WriteSysLog(sFlag_BillItem, nStr, nTmp, False);
      InitFormData(FWhere);
      ShowMsg('调拨成功', sHint);
    end;
  end;
end;

procedure TfFrameBill.SendMsgToWebMall(const nBillno: string);
var
  nSql:string;
  nDs:TDataSet;

  nBills: TLadingBillItems;
  nXmlStr,nData:string;
  i:Integer;
  nItem:TLadingBillItem;
begin
  {$IFNDEF EnableWebMall}
  Exit;
  {$ENDIF}
  
  //加载提货单信息
  if not GetLadingBills(nBillno, sFlag_BillDel, nBills) then
  begin
    Exit;
  end;

  //调用web接口发送消息
  for i := Low(nBills) to High(nBills) do
  begin
    nItem := nBills[i];

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
    nXmlStr := Format(nXmlStr,[gSysParam.FFactory, nItem.FCusID,cSendWeChatMsgType_DelBill,
          nItem.FID,nItem.FCard,nitem.FTruck,
          nItem.FStockNo,nItem.FStockName,nItem.FCusID,
          nItem.FCusName]);
    nXmlStr := PackerEncodeStr(nXmlStr);
    nData := send_event_msg(nXmlStr);
    gSysLoger.AddLog(TfFrameBill,'SendMsgToWebMall',nData);

    if ndata<>'' then
    begin
      ShowMsg(nData,sHint);
    end;
  end;
end;

procedure TfFrameBill.N10Click(Sender: TObject);
var nOutFact: string;
begin
  inherited;

  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nOutFact := FormatDateTime('yyyy年mm月dd日',SQLQuery.FieldByName('L_OutFact').AsDateTime);
    PrintHuaYanReport(SQLQuery.FieldByName('L_HYDan').AsString,
      SQLQuery.FieldByName('L_StockName').AsString, nOutFact,
      SQLQuery.FieldByName('L_ID').AsString, True);
  end;
end;

procedure TfFrameBill.ModifyWebOrderStatus(const nLId: string);
var
  nWebOrderId:string;
  nXmlStr,nData,nSql:string;
begin
  {$IFNDEF EnableWebMall}
  Exit;
  {$ENDIF}
  
  nWebOrderId := '';
  //查询网上商城订单
  nSql := 'select WOM_WebOrderID from %s where WOM_LID=''%s''';
  nSql := Format(nSql,[sTable_WebOrderMatch,nLId]);
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
  gSysLoger.AddLog(TfFrameBill,'ModifyWebOrderStatus',nData);
  if ndata<>'' then
  begin
    ShowMsg(nData,sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameBill, TfFrameBill.FrameID);
end.
