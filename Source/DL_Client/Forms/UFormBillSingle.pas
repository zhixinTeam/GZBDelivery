{*******************************************************************************
  作者: dmzn@163.com 2014-09-01
  描述: 开提货单
*******************************************************************************}
unit UFormBillSingle;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxMaskEdit,
  cxDropDownEdit, cxListView, cxTextEdit, cxMCListBox, dxLayoutControl,
  StdCtrls, cxButtonEdit, cxCheckBox;

type
  TfFormBillSingle = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    ListInfo: TcxMCListBox;
    dxLayout1Item4: TdxLayoutItem;
    ListBill: TcxListView;
    EditValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayout1Item7: TdxLayoutItem;
    BtnAdd: TButton;
    dxLayout1Item10: TdxLayoutItem;
    BtnDel: TButton;
    dxLayout1Item11: TdxLayoutItem;
    EditLading: TcxComboBox;
    dxLayout1Item12: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Group8: TdxLayoutGroup;
    dxLayout1Group7: TdxLayoutGroup;
    EditFQ: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item6: TdxLayoutItem;
    EditType: TcxComboBox;
    dxLayout1Group3: TdxLayoutGroup;
    PrintGLF: TcxCheckBox;
    dxLayout1Item13: TdxLayoutItem;
    dxLayout1Item14: TdxLayoutItem;
    PrintHY: TcxCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditStockPropertiesChange(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure EditFQPropertiesEditValueChanged(Sender: TObject);
  protected
    { Protected declarations }
    FBuDanFlag: string;
    //补单标记
    procedure LoadFormData;
    procedure LoadStockList;
    //载入数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, DB, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker,
  UDataModule, USysPopedom, USysBusiness, USysDB, USysGrid, USysConst,
  UFormWait;

type
  TCommonInfo = record
    FZhiKa: string;
    FCusID: string;
    FMoney: Double;
    FOnlyMoney: Boolean;
    FIDList: string;
    FShowPrice: Boolean;
    FPriceChanged: Boolean;

    FCard: string;
    FTruck: string;
    FPlan: PSalePlanItem;
  end;

  TStockItem = record
    FType: string;
    FStockNO: string;
    FStockName: string;
    FStockSeal: string;
    FPrice: Double;
    FValue: Double;
    FSelecte: Boolean;
  end;

var
  gInfo: TCommonInfo;
  gStockList: array of TStockItem;
  //全局使用

class function TfFormBillSingle.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nBool,nBuDan: Boolean;
    nInfo: TCommonInfo;
    nP: PFormCommandParam;
begin
  Result := nil;
//  if GetSysValidDate < 1 then Exit;

  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  try
    nBuDan := nPopedom = 'MAIN_N02';
    FillChar(nInfo, SizeOf(nInfo), #0);
    gInfo := nInfo;

    CreateBaseFormItem(cFI_FormGetZhika, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    gInfo.FCard  := '';
    gInfo.FZhiKa := nP.FParamB;
    gInfo.FCusID := nP.FParamC;

    {$IFDEF UseK3SalePlan}
    if not nBuDan then
    begin
      CreateBaseFormItem(cFI_Form_HT_SalePlan, nPopedom, nP);
      if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

      with gInfo do
      begin
        FCard := nP.FParamB;
        FTruck:= nP.FParamD;
        FPlan := Pointer(Integer(nP.FParamC));
      end;
    end;
    {$ENDIF}
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormBillSingle.Create(Application) do
  try
    ShowWaitForm(Application.MainForm, '正在加载数据', True);
    try
      LoadFormData;
      //try load data
    finally
      CloseWaitForm;
    end;

    if not BtnOK.Enabled then Exit;
    gInfo.FShowPrice := gPopedomManager.HasPopedom(nPopedom, sPopedom_ViewPrice);

    Caption := '开 提 货 单';
    nBool := not gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);
    EditLading.Properties.ReadOnly := nBool;

    if nBuDan then //补单
         FBuDanFlag := sFlag_Yes
    else FBuDanFlag := sFlag_No;

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := gInfo.FIDList
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBillSingle.FormID: integer;
begin
  Result := cFI_FormBillSingle;
end;

procedure TfFormBillSingle.FormCreate(Sender: TObject);
var nStr: string;
    nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nStr := nIni.ReadString(Name, 'FQLabel', '');
    if nStr <> '' then
      dxLayout1Item5.Caption := nStr;
    //xxxxx

    PrintHY.Checked := nIni.ReadBool(Name, 'PrintHY', False);
    //随车开单

    LoadMCListBoxConfig(Name, ListInfo, nIni);
    LoadcxListViewConfig(Name, ListBill, nIni);
  finally
    nIni.Free;
  end;

  {$IFDEF PrintGLF}
  dxLayout1Item13.Visible := True;
  {$ELSE}
  dxLayout1Item13.Visible := False;
  PrintGLF.Checked := False;
  {$ENDIF}

  {$IFDEF PrintHYEach}
  dxLayout1Item14.Visible := True;
  {$ELSE}
  dxLayout1Item14.Visible := False;
  PrintHY.Checked := False;
  {$ENDIF}

  AdjustCtrlData(Self);
end;

procedure TfFormBillSingle.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIni.WriteBool(Name, 'PrintHY', PrintHY.Checked);
    SaveMCListBoxConfig(Name, ListInfo, nIni);
    SavecxListViewConfig(Name, ListBill, nIni);
  finally
    nIni.Free;
  end;

  ReleaseCtrlData(Self);
end;

//Desc: 回车键
procedure TfFormBillSingle.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditStock then ActiveControl := EditValue else
    if Sender = EditValue then ActiveControl := BtnAdd else
    if Sender = EditTruck then ActiveControl := EditStock else

    if Sender = EditLading then
         ActiveControl := EditTruck
    else Perform(WM_NEXTDLGCTL, 0, 0);
  end;

  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 载入界面数据
procedure TfFormBillSingle.LoadFormData;
var nStr,nTmp: string;
    nDB: TDataSet;
    nIdx: integer;
begin
  BtnOK.Enabled := False;
  nDB := LoadZhiKaInfo(gInfo.FZhiKa, ListInfo, nStr);

  if Assigned(nDB) then
  with gInfo do
  begin
    FCusID := nDB.FieldByName('Z_Customer').AsString;
    FPriceChanged := nDB.FieldByName('Z_TJStatus').AsString = sFlag_TJOver;
    
    SetCtrlData(EditLading, nDB.FieldByName('Z_Lading').AsString);
    FMoney := GetZhikaValidMoney(gInfo.FZhiKa, gInfo.FOnlyMoney);
  end else
  begin
    ShowMsg(nStr, sHint); Exit;
  end;

  BtnOK.Enabled := IsCustomerCreditValid(gInfo.FCusID);
  if not BtnOK.Enabled then Exit;
  //to verify credit

  SetLength(gStockList, 0);
  nStr := 'Select * From %s Where D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, gInfo.FZhiKa]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nStr := '';
    nIdx := 0;
    SetLength(gStockList, RecordCount);

    First;  
    while not Eof do
    with gStockList[nIdx] do
    begin
      FType := FieldByName('D_Type').AsString;
      FStockNO := FieldByName('D_StockNo').AsString;
      FStockName := FieldByName('D_StockName').AsString;
      FPrice := FieldByName('D_Price').AsFloat;

      FValue := 0;
      FSelecte := False;

      if gInfo.FPriceChanged then
      begin
        nTmp := '品种:[ %-8s ] 原价:[ %.2f ] 现价:[ %.2f ]' + #32#32;
        nTmp := Format(nTmp, [FStockName, FieldByName('D_PPrice').AsFloat, FPrice]);
        nStr := nStr + nTmp + #13#10;
      end;

      Inc(nIdx);
      Next;
    end;
  end else
  begin
    nStr := Format('纸卡[ %s ]没有可提的水泥品种,已终止.', [gInfo.FZhiKa]);
    ShowDlg(nStr, sHint);
    BtnOK.Enabled := False; Exit;
  end;

  if gInfo.FPriceChanged then
  begin
    nStr := '管理员已调整纸卡[ %s ]的价格,明细如下: ' + #13#10#13#10 +
            AdjustHintToRead(nStr) + #13#10 +
            '请询问客户是否接受新单价,接受点"是"按钮.' ;
    nStr := Format(nStr, [gInfo.FZhiKa]);

    {$IFNDEF NoShowPriceChange}
    BtnOK.Enabled := QueryDlg(nStr, sHint);
    if not BtnOK.Enabled then Exit;
    {$ENDIF}

    nStr := 'Update %s Set Z_TJStatus=Null Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, gInfo.FZhiKa]);
    FDM.ExecuteSQL(nStr);
  end;

  EditType.ItemIndex := 0;
  LoadStockList;
  //load stock into window 

  if Integer(gInfo.FPlan) > 0 then //使用销售计划
  begin
    EditTruck.Properties.ReadOnly := True;
    EditTruck.Text := gInfo.FPlan.FTruck;

    EditStock.Properties.ReadOnly := True;
    nIdx := EditStock.Properties.Items.IndexOf(gInfo.FPlan.FStockName);
    EditStock.ItemIndex := nIdx;

    EditValue.Properties.ReadOnly := True;
    EditValue.Text := FloatToStr(gInfo.FPlan.FValue);
    ActiveControl := BtnAdd;
  end else

  if Length(gInfo.FCard) > 0  then //零售刷卡
  begin
    EditTruck.Text := gInfo.FTruck;
    ActiveControl  := EditValue;
  end else
  begin
    ActiveControl := EditTruck;
  end;
end;

//Desc: 刷新水泥列表到窗体
procedure TfFormBillSingle.LoadStockList;
var nStr: string;
    i,nIdx: integer;
begin
  AdjustCXComboBoxItem(EditStock, True);
  nIdx := ListBill.ItemIndex;

  ListBill.Items.BeginUpdate;
  try
    ListBill.Clear;
    for i:=Low(gStockList) to High(gStockList) do
    if gStockList[i].FSelecte then
    begin
      with ListBill.Items.Add do
      begin
        Caption := gStockList[i].FStockName;
        SubItems.Add(EditTruck.Text);
        SubItems.Add(FloatToStr(gStockList[i].FValue));

        Data := Pointer(i);
        ImageIndex := cItemIconIndex;
      end;
    end else
    begin
      nStr := Format('%d=%s', [i, gStockList[i].FStockName]); 
      EditStock.Properties.Items.Add(nStr);
    end;
  finally
    ListBill.Items.EndUpdate;
    if ListBill.Items.Count > nIdx then
      ListBill.ItemIndex := nIdx;
    //xxxxx

    AdjustCXComboBoxItem(EditStock, False);
    EditStock.ItemIndex := 0;
  end;
end;

//Dessc: 选择品种
procedure TfFormBillSingle.EditStockPropertiesChange(Sender: TObject);
var nInt: Int64;
    nIni: TIniFile;
begin
  dxGroup2.Caption := '提单明细';
  if EditStock.ItemIndex < 0 then Exit;

  with gStockList[StrToInt(GetCtrlData(EditStock))] do
  if FPrice > 0 then
  begin
    nInt := Float2PInt(gInfo.FMoney / FPrice, cPrecision, False);
    EditValue.Text := FloatToStr(nInt / cPrecision);

    if gInfo.FShowPrice then
      dxGroup2.Caption := Format('提单明细 单价:%.2f元/吨', [FPrice]);
    //xxxxx
  end;

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    EditFQ.Text := nIni.ReadString('EditFQ', GetCtrlData(EditStock), '');
  finally
    nIni.Free;
  end;
  //读取对应品种的封签号
end;

function TfFormBillSingle.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditStock then
  begin
    Result := EditStock.ItemIndex > -1;
    nHint := '请选择水泥类型';
  end else

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '车牌号长度应大于2位';
  end else

  if Sender = EditLading then
  begin
    Result := EditLading.ItemIndex > -1;
    nHint := '请选择有效的提货方式';
  end else

  if Sender = EditFQ then
  begin
    EditFQ.Text := Trim(EditFQ.Text);
    Result := (Length(EditFQ.Text) > 0) or (not VerifyFQSumValue);
    nHint := '出厂编号不能为空';
  end;  

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    nHint := '请填写有效的办理量';

    if not Result then Exit;
    if not OnVerifyCtrl(EditStock, nHint) then Exit;

    with gStockList[StrToInt(GetCtrlData(EditStock))] do
    if FPrice > 0 then
    begin
      nVal := StrToFloat(EditValue.Text);
      nVal := Float2Float(nVal, cPrecision, False);
      Result := FloatRelation(gInfo.FMoney / FPrice, nVal, rtGE, cPrecision);

      nHint := '已超出可办理量';
      if not Result then Exit;

      if FloatRelation(gInfo.FMoney / FPrice, nVal, rtEqual, cPrecision) then
      begin
        nHint := '';
        Result := QueryDlg('确定要按最大可提货量全部开出吗?', sAsk);
        if not Result then ActiveControl := EditValue;
      end;
    end else
    begin
      Result := False;
      nHint := '单价[ 0 ]无效';
    end;
  end;
end;

//Desc: 添加
procedure TfFormBillSingle.BtnAddClick(Sender: TObject);
var nIdx: Integer;
    nSend, nMax, nVal: Double;
begin
  if IsDataValid then
  begin
    nIdx := StrToInt(GetCtrlData(EditStock));
    with gStockList[nIdx] do
    begin
      if (FType = sFlag_San) and (ListBill.Items.Count > 0) then
      begin
        ShowMsg('散装水泥不能混装', sHint);
        ActiveControl := EditStock;
        Exit;
      end;

      EditFQ.Text := Trim(EditFQ.Text);
      nMax := GetHYMaxValue;
      nSend:= GetFQValueByStockNo(EditFQ.Text);
      nVal := nSend + StrToFloat(EditValue.Text);

      if VerifyFQSumValue then
      begin
        if FloatRelation(nMax, nVal, rtLE, cPrecision) then
        begin
          ShowMsg('出厂封签号已超发,请更换封签号', sHint);
          ActiveControl := EditFQ;
          Exit;
        end;

        if FloatRelation(nMax * 0.9, nVal, rtLE, cPrecision) then
        begin
          ShowDlg('出厂封签号已发90%,请及时通知化验室更新.', sWarn);
        end;  
      end;

      FStockSeal := Trim(EditFQ.Text);
      FValue := StrToFloat(EditValue.Text);
      FValue := Float2Float(FValue, cPrecision, False);
      FSelecte := True;

      EditTruck.Properties.ReadOnly := True;
      gInfo.FMoney := gInfo.FMoney - FPrice * FValue;
    end;

    LoadStockList;
    ActiveControl := BtnOK;
  end;
end;

//Desc: 删除
procedure TfFormBillSingle.BtnDelClick(Sender: TObject);
var nIdx: integer;
begin
  if ListBill.ItemIndex > -1 then
  begin
    nIdx := Integer(ListBill.Items[ListBill.ItemIndex].Data);
    with gStockList[nIdx] do
    begin
      FSelecte := False;
      gInfo.FMoney := gInfo.FMoney + FPrice * FValue;
    end;

    LoadStockList;
    EditTruck.Properties.ReadOnly := ListBill.Items.Count > 0;
  end;
end;

//Desc: 保存
procedure TfFormBillSingle.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nPrint: Boolean;
    nList,nTmp,nStocks: TStrings;
    nCard, nStr : string;
begin
  if ListBill.Items.Count < 1 then
  begin
    ShowMsg('请先办理提货单', sHint); Exit;
  end;
  
  {$IFDEF UseELableAsCard}
  if not IsEleCardVaidEx(EditTruck.Text) then
  begin
    ShowMsg('车辆未办理电子标签或电子标签未启用！请联系管理员', sHint); Exit;
  end;
  {$ENDIF}

  nStocks := TStringList.Create;
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    {$IFDEF VerifyK3Stock} //新安中联: 验证品种能否发货
    nList.Clear;
    for nIdx:=Low(gStockList) to High(gStockList) do
     with gStockList[nIdx],nTmp do
      if FSelecte then nList.Add(FStockNO);
    //xxxxx

    if not IsStockValid(CombinStr(nList, ',')) then Exit;
    {$ENDIF}

    nList.Clear;
    nPrint := False;
    LoadSysDictItem(sFlag_PrintBill, nStocks);
    //需打印品种

    for nIdx:=Low(gStockList) to High(gStockList) do
    with gStockList[nIdx],nTmp do
    begin
      if not FSelecte then Continue;
      //xxxxx

      Values['Type'] := FType;
      Values['StockNO'] := FStockNO;
      Values['StockName'] := FStockName;
      Values['Seal']  := FStockSeal;
      Values['Price'] := FloatToStr(FPrice);
      Values['Value'] := FloatToStr(FValue);

      if PrintGLF.Checked  then
           Values['PrintGLF'] := sFlag_Yes
      else Values['PrintGLF'] := sFlag_No;

      if PrintHY.Checked  then
           Values['PrintHY'] := sFlag_Yes
      else Values['PrintHY'] := sFlag_No;

      if Integer(gInfo.FPlan) > 0 then
      begin
        Values['IsPlan'] := sFlag_Yes;
        Values['OrderNo']:= gInfo.FPlan.FOrderNo;
        Values['InterID']:= gInfo.FPlan.FInterID;
        Values['EntryID']:= gInfo.FPlan.FEntryID;
      end else Values['IsPlan'] := sFlag_No;

      nList.Add(PackerEncodeStr(nTmp.Text));
      //new bill

      if (not nPrint) and (FBuDanFlag <> sFlag_Yes) then
        nPrint := nStocks.IndexOf(FStockNO) >= 0;
      //xxxxx
    end;

    with nList do
    begin
      Values['Bills'] := PackerEncodeStr(nList.Text);
      Values['ZhiKa'] := gInfo.FZhiKa;
      Values['Truck'] := EditTruck.Text;
      Values['Lading'] := GetCtrlData(EditLading);
      Values['IsVIP'] := GetCtrlData(EditType);
      Values['BuDan'] := FBuDanFlag;
      Values['Card'] := gInfo.FCard;
    end;

    BtnOK.Enabled := False;
    try
      ShowWaitForm(Self, '正在保存', True);
      gInfo.FIDList := SaveBillSingle(PackerEncodeStr(nList.Text));
    finally
      BtnOK.Enabled := True;
      CloseWaitForm;
    end;
    //call mit bus
    if gInfo.FIDList = '' then Exit;
  finally
    nTmp.Free;
    nList.Free;
    nStocks.Free;
  end;

  {$IFNDEF UseELableAsCard}
  if (FBuDanFlag <> sFlag_Yes) and (gInfo.FCard = '') then
    SetBillCard(gInfo.FIDList, EditTruck.Text, True, sFlag_SaleSingle);
  //办理磁卡
  {$ELSE}
    nCard := '';
    nStr := 'Select T_Card From %s Where T_Truck = ''%s'' and T_CardUse=''%s'' ';
    nStr := Format(nStr, [sTable_Truck, EditTruck.Text, sFlag_Yes]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nCard := Fields[0].AsString;
    end;
    nStr := 'Update %s Set L_Card=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nCard, gInfo.FIDList]);
    FDM.ExecuteSQL(nStr);
  {$ENDIF}

  if nPrint then
    PrintBillReport(gInfo.FIDList, True);
  //print report

  ModalResult := mrOk;
  ShowMsg('提货单保存成功', sHint);
end;

procedure TfFormBillSingle.EditFQPropertiesEditValueChanged(Sender: TObject);
var nIni: TIniFile;
begin
  inherited;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIni.WriteString('EditFQ', GetCtrlData(EditStock), EditFQ.Text);
  finally
    nIni.Free;
  end;
  //保存封签号
end;

initialization
  gControlManager.RegCtrl(TfFormBillSingle, TfFormBillSingle.FormID);
end.
