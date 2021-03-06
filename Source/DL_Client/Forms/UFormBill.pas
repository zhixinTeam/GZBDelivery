{*******************************************************************************
  ����: dmzn@163.com 2014-09-01
  ����: �������
*******************************************************************************}
unit UFormBill;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit, cxCheckBox;

type
  TfFormBill = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditCard: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditID: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditCus: TcxTextEdit;
    dxlytmLayout1Item3: TdxLayoutItem;
    dxGroupLayout1Group2: TdxLayoutGroup;
    EditCName: TcxTextEdit;
    dxlytmLayout1Item4: TdxLayoutItem;
    EditMan: TcxTextEdit;
    dxlytmLayout1Item5: TdxLayoutItem;
    EditDate: TcxTextEdit;
    dxlytmLayout1Item6: TdxLayoutItem;
    EditFirm: TcxTextEdit;
    dxlytmLayout1Item7: TdxLayoutItem;
    EditArea: TcxTextEdit;
    dxlytmLayout1Item8: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxlytmLayout1Item9: TdxLayoutItem;
    EditSName: TcxTextEdit;
    dxlytmLayout1Item10: TdxLayoutItem;
    EditMax: TcxTextEdit;
    dxlytmLayout1Item11: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxlytmLayout1Item12: TdxLayoutItem;
    dxGroupLayout1Group5: TdxLayoutGroup;
    dxlytmLayout1Item13: TdxLayoutItem;
    EditType: TcxComboBox;
    dxGroupLayout1Group6: TdxLayoutGroup;
    dxGroupLayout1Group7: TdxLayoutGroup;
    dxGroupLayout1Group3: TdxLayoutGroup;
    EditTrans: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditMemo: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditWorkAddr: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditFQ: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    EditLineGroup: TcxComboBox;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Item11: TdxLayoutItem;
    PrintHY: TcxCheckBox;
    EditMValue: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditPValue: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    dxLayout1Group6: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditFQPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesChange(Sender: TObject);
    procedure EditMValuePropertiesChange(Sender: TObject);
    procedure EditPValuePropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FCardData, FComentData: TStrings;
    //��Ƭ����
    FNewBillID: string;
    //���ᵥ��
    FBuDanFlag: string;
    //�������
    procedure InitFormData;
    //��ʼ������
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
  UDataModule, USysBusiness, USysDB, USysGrid, USysConst;

class function TfFormBill.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr,nStockNo: string;
    nP: PFormCommandParam;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  try
    CreateBaseFormItem(cFI_FormBillNew, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nStr := nP.FParamB;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormBill.Create(Application) do
  try
    Caption := '�������';
    ActiveControl := EditTruck;

    FCardData.Text := PackerDecodeStr(nStr);
    {$IFNDEF BATAFTERLINE}
    nStockNo           := FCardData.Values['XCB_Cement'];

    nStr := 'Select D_ParamB From %s Where D_Name=''%s'' and D_Value=''%s''';
    nStr := Format(nStr, [sTable_SysDict, 'BatStockGroup', nStockNo]);
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount > 0 then
      begin
        nStockNo := Fields[0].AsString;
      end;
    end;

    FCardData.Values['XCB_Cement'] := nStockNo;
    
    FComentData.Text := YT_GetBatchCode(FCardData);
    {$ENDIF}
    InitFormData;

    if nPopedom = 'MAIN_D04' then //����
    begin
      FBuDanFlag := sFlag_Yes;
      {$IFDEF SaleBudanMValue}
      dxLayout1Item12.Visible       := True;
      dxLayout1Item13.Visible       := True;
      EditValue.Properties.ReadOnly := True;
      {$ELSE}
      dxLayout1Item12.Visible       := False;
      dxLayout1Item13.Visible       := False;
      EditValue.Properties.ReadOnly := False;
      {$ENDIF}
    end
    else
    begin
      FBuDanFlag := sFlag_No;
      dxLayout1Item12.Visible       := False;
      dxLayout1Item13.Visible       := False;
      EditValue.Properties.ReadOnly := False;
    end;

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA  := ShowModal;

      if FParamA = mrOK then
           FParamB := FNewBillID
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBill.FormID: integer;
begin
  Result := cFI_FormBill;
end;

procedure TfFormBill.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    PrintHY.Checked := nIni.ReadBool(Name, 'PrintHY', False);
    //�泵����
  finally
    nIni.Free;
  end;

  FCardData := TStringList.Create;
  FComentData := TStringList.Create;

  {$IFDEF PrintHYEach}
  dxLayout1Item11.Visible := True;
  {$ELSE}
  dxLayout1Item11.Visible := False;
  PrintHY.Checked := False;
  {$ENDIF}

  AdjustCtrlData(Self);
  LoadFormConfig(Self);
end;

procedure TfFormBill.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIni.WriteBool(Name, 'PrintHY', PrintHY.Checked);
  finally
    nIni.Free;
  end;

  SaveFormConfig(Self);
  ReleaseCtrlData(Self);
  FCardData.Free;
  FComentData.Free;
end;

//Desc: �س���
procedure TfFormBill.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditValue then
         BtnOK.Click
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

procedure TfFormBill.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nChar: Char;
begin
  nChar := Char(VK_SPACE);
  EditLadingKeyPress(EditTruck, nChar);
end;

//------------------------------------------------------------------------------
procedure TfFormBill.InitFormData;
begin
  with FCardData do
  begin
    if FComentData.Text <> '' then
    begin
      Values['XCB_CementCode'] := FComentData.Values['XCB_CementCode'];
      Values['XCB_CementCodeID'] := FComentData.Values['XCB_CementCodeID'];
      Values['XCB_CementValue'] := FComentData.Values['XCB_CementValue'];
    end;
    //���κ�

    EditID.Text     := Values['XCB_ID'];
    EditCard.Text   := Values['XCB_CardId'];
    EditCus.Text    := Values['XCB_Client'];
    EditCName.Text  := Values['XCB_ClientName'];
    EditMan.Text    := Values['XCB_CreatorNM'];
    EditDate.Text   := Values['XCB_CDate'];
    EditFirm.Text   := Values['XCB_FirmName'];
    EditArea.Text   := Values['pcb_name'];
    EditStock.Text  := Values['XCB_Cement'];
    EditSName.Text  := Values['XCB_CementName'];
    EditMax.Text    := Values['XCB_RemainNum'];
    EditFQ.Text     := Values['XCB_CementCode'];
    EditTrans.Text  := Values['XCB_TransName'];
    EditWorkAddr.Text:= Values['XCB_WorkAddr'];
  end;

  if EditLineGroup.ItemIndex < 0 then
    LoadZTLineGroup(EditLineGroup.Properties.Items);
end;

function TfFormBill.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '���ƺų���Ӧ����2λ';
  end else

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    nHint := '����д��Ч�İ�����';
    if not Result then Exit;
                    
    nVal := StrToFloat(EditValue.Text);
    Result := FloatRelation(nVal, StrToFloat(FCardData.Values['XCB_RemainNum']),
              rtLE);
    nHint := '�ѳ����������';
  end;
end;

//Desc: ����
procedure TfFormBill.BtnOKClick(Sender: TObject);
var nPrint: Boolean;
    nList,nTmp,nStocks: TStrings;
    nCK: string;
begin
  if not IsDataValid then Exit;
  //check valid
  
  {$IFDEF BuDanJY}
  if FBuDanFlag = sFlag_Yes then
  begin
    if Trim(EditFQ.Text) = '' then
    begin
      ShowMsg('������Ų���Ϊ��',sHint);
      Exit;
    end;

    if Trim(EditLineGroup.Text) = '' then
    begin
      ShowMsg('ͨ�����鲻��Ϊ��',sHint);
      Exit;
    end;

    if StrToFloatDef(EditPValue.Text,0) <= 0 then
    begin
      ShowMsg('Ƥ�ض���Ӧ������',sHint);
      Exit;
    end;

    if StrToFloatDef(EditMValue.Text,0) <= 0 then
    begin
      ShowMsg('ë�ض���Ӧ������',sHint);
      Exit;
    end;
  end;
  {$ENDIF}

  nCK := '';
  {$IFDEF SpecifyCk}
  GetCusSpecialSet(FCardData.Values['XCB_Client'], FCardData.Values['XCB_Cement'], nCk);
  if nCK <> '' then
  begin
    if IsNumber(FCardData.Values['XCB_CementValue'], True) and
    (StrToFloat(FCardData.Values['XCB_CementValue']) < StrToFloat(EditValue.Text)) then
    begin
      ShowMsg('����ͻ�����������',sHint);
      Exit;
    end;
  end;
  {$ENDIF}

  nStocks := TStringList.Create;
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    nList.Clear;
    nPrint := False;
    LoadSysDictItem(sFlag_PrintBill, nStocks);
    //���ӡƷ��

    //+++++: start loop
    nTmp.Values['Type'] := FCardData.Values['XCB_CementType'];
    nTmp.Values['StockNO'] := FCardData.Values['XCB_Cement'];
    nTmp.Values['StockName'] := FCardData.Values['XCB_CementName'];
    nTmp.Values['Price'] := '0.00';
    nTmp.Values['Value'] := EditValue.Text;

    nList.Add(PackerEncodeStr(nTmp.Text));
    //new bill

    if (not nPrint) and (FBuDanFlag <> sFlag_Yes) then
      nPrint := nStocks.IndexOf(FCardData.Values['XCB_Cement']) >= 0;
    //-----: end loop,�˴�����Ӷ�����ϸ

    with nList do
    begin
      Values['Bills'] := PackerEncodeStr(nList.Text);
      Values['ZhiKa'] := PackerEncodeStr(FCardData.Text);
      Values['Truck'] := EditTruck.Text;
      Values['Lading'] := sFlag_TiHuo;
      Values['Memo']  := Trim(EditMemo.Text);
      Values['IsVIP'] := GetCtrlData(EditType);
      Values['Seal'] := FCardData.Values['XCB_CementCodeID'];
      Values['HYDan'] := EditFQ.Text;
      Values['BuDan'] := FBuDanFlag;
      Values['LineGroup'] := GetCtrlData(EditLineGroup);
      if (dxLayout1Item12.Visible) then
      begin
        Values['PValue'] := EditPValue.Text;
        Values['MValue'] := EditMValue.Text;
      end;

      if PrintHY.Checked  then
           Values['PrintHY'] := sFlag_Yes
      else Values['PrintHY'] := sFlag_No;
    end;

    FNewBillID := SaveBill(PackerEncodeStr(nList.Text));
    //call mit bus
    if FNewBillID = '' then Exit;
  finally
    nList.Free;
  end;

  if FBuDanFlag <> sFlag_Yes then
    SetBillCard(FNewBillID, EditTruck.Text, True);
  //����ſ�

  if nPrint then
    PrintBillReport(FNewBillID, True);
  //print report

  ModalResult := mrOk;
  ShowMsg('���������ɹ�', sHint);
end;

procedure TfFormBill.EditFQPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  inherited;
  nP.FParamA := FCardData.Text;
  CreateBaseFormItem(cFI_FormGetYTBatch, '', @nP);

  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOk) then Exit;

  FComentData.Text := PackerDecodeStr(nP.FParamB);
  InitFormData;
end;

procedure TfFormBill.EditTruckPropertiesChange(Sender: TObject);
var
  nStr: string;
begin
  inherited;
  //��ȡɾ����¼�����Ƥ��ֵ
  if (dxLayout1Item12.Visible) and (Trim(EditTruck.Text) <> '') then
  begin
    nStr := ' Select L_PValue From S_BillBak Where L_Truck = ''%s'' and L_PValue > 0 order by R_ID desc ';
    nStr := Format(nStr, [Trim(EditTruck.Text)]);
    
    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
      EditPValue.Text := Fields[0].AsString;
  end;
end;

procedure TfFormBill.EditMValuePropertiesChange(Sender: TObject);
begin
  inherited;
  if (Trim(EditPValue.Text) <> '') and (Trim(EditMValue.Text) <> '') then
  begin
    EditValue.Text := FloatToStr(StrToFloatDef(EditMValue.Text,0)-StrToFloatDef(EditPValue.Text,0));
  end;
end;

procedure TfFormBill.EditPValuePropertiesChange(Sender: TObject);
begin
  inherited;
  if (Trim(EditPValue.Text) <> '') and (Trim(EditMValue.Text) <> '') then
  begin
    EditValue.Text := FloatToStr(StrToFloatDef(EditMValue.Text,0)-StrToFloatDef(EditPValue.Text,0));
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormBill, TfFormBill.FormID);
end.
