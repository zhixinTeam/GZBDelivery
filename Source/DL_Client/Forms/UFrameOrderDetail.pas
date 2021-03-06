{*******************************************************************************
  ����: fendou116688@163.com 2015/8/10
  ����: �ɹ�������ѯ
*******************************************************************************}
unit UFrameOrderDetail;

{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxCheckBox;

type
  TfFrameOrderDetail = class(TfFrameNormal)
    cxtxtdt1: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxtxtdt2: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    pmPMenu1: TPopupMenu;
    mniN1: TMenuItem;
    cxtxtdt3: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxtxtdt4: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditBill: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Check1: TcxCheckBox;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure mniN1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure Check1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //ʱ������
    FJBWhere: string;
    //��������
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //��ѯSQL
    function GetVal(const nRow: Integer; const nField: string): string;
    //��ȡָ���ֶ�
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness,
  UBusinessConst, USysConst, USysDB, UDataModule,UFormBase,UBusinessPacker;

class function TfFrameOrderDetail.FrameID: integer;
begin
  Result := cFI_FrameOrderDetail;
end;

procedure TfFrameOrderDetail.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  FJBWhere := '';
  InitDateRange(Name, FStart, FEnd);
  {$IFDEF AddKSYW}
  N8.Visible := True;
  {$ELSE}
  N8.Visible := False;
  {$ENDIF}

  {$IFDEF GZBHC}
  N9.Visible := True;
  {$ELSE}
  N9.Visible := False;
  {$ENDIF}
end;

procedure TfFrameOrderDetail.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameOrderDetail.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  {$IFDEF AddKSYW}
  Result := ' Select *,(D_MValue-D_PValue-D_KZValue) as D_NetWeight, ' +
            ' isnull(D_StockNo, O_StockNo) as O_StockNoEx, ' +
            ' isnull(D_StockName, O_StockName) as O_StockNameEx ' +
            ' From $OD od Left Join $OO oo on od.D_OID=oo.O_ID ';
  //xxxxxx
  {$ELSE}
  Result := 'Select *,(D_MValue-D_PValue-D_KZValue) as D_NetWeight ' +
            'From $OD od Left Join $OO oo on od.D_OID=oo.O_ID ';
  {$ENDIF}

  if FJBWhere = '' then
  begin
    Result := Result + 'Where (D_InTime>=''$S'' and D_InTime <''$End'')';

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;

  if Check1.Checked then
       Result := MacroValue(Result, [MI('$OD', sTable_OrderDtlBak)])
  else Result := MacroValue(Result, [MI('$OD', sTable_OrderDtl)]);

  Result := MacroValue(Result, [MI('$OD', sTable_OrderDtl),MI('$OO', sTable_Order),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;


//Desc: ����ɸѡ
procedure TfFrameOrderDetail.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: ִ�в�ѯ
procedure TfFrameOrderDetail.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'O_ProId like ''%%%s%%'' Or O_ProName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'oo.O_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text]);
    InitFormData(FWhere);
  end;

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FWhere := 'od.D_ID like ''%%%s%%''';
    FWhere := Format(FWhere, [EditBill.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: ���Ӱ��ѯ
procedure TfFrameOrderDetail.mniN1Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    FJBWhere := '(D_InTime>=''%s'' and D_InTime <''%s'')';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/8/13
//Parm: 
//Desc: ��ѯδ���
procedure TfFrameOrderDetail.N2Click(Sender: TObject);
begin
  inherited;
  try
    FJBWhere := '(D_OutFact Is Null)';
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/8/13
//Parm: 
//Desc: ɾ��δ��ɼ�¼
procedure TfFrameOrderDetail.N3Click(Sender: TObject);
var nStr, nSQL, nP, nID, nOrderID,nCardType: string;
    nOutFact : Boolean;
    nIdx: Integer;
    nVal, nFreeze: Double;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nID := SQLQuery.FieldByName('D_ID').AsString;
    if not QueryDlg('ȷ��ɾ���òɹ�����ô?', sAsk) then Exit;

    nP       := SQLQuery.FieldByName('D_MDate').AsString;
    nOrderID := SQLQuery.FieldByName('D_OID').AsString;
    nCardType:= SQLQuery.FieldByName('O_CType').AsString;

    nFreeze  := SQLQuery.FieldByName('O_Value').AsFloat;
    nVal     := SQLQuery.FieldByName('D_NetWeight').AsFloat;

    if nP <> '' then
         nOutFact := True
    else nOutFact := False;

    nStr := Format('Select * From %s Where 1<>1', [sTable_OrderDtl]);
    //only for fields
    nP := '';

    with FDM.QueryTemp(nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
      if (Fields[nIdx].DataType <> ftAutoInc) and
         (Pos('D_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //�����ֶ�,������ɾ��
      System.Delete(nP, Length(nP), 1);
    end;

    FDM.ADOConn.BeginTrans;
    try
      if nOutFact then
      begin
        nSQL := 'Update $OrderBase Set B_SentValue=B_SentValue-$Val ' +
                'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'')';
        nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
                MI('$Order', sTable_Order),MI('$ID', nOrderID),
                MI('$Val', FloatToStr(nVal))]);
        FDM.ExecuteSQL(nSQL);
        //������������
      end else
      begin
        if nCardType = sFlag_OrderCardL then
        begin
          nSQL := 'Update $OrderBase Set B_FreezeValue=B_FreezeValue-$FreezeVal  ' +
                  'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'') and '+
                  'B_Value>0'; 

          nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
                  MI('$Order', sTable_Order),MI('$ID', nOrderID),
                  MI('$FreezeVal', FloatToStr(nFreeze))]);
          FDM.ExecuteSQL(nSQL);

          nSQL := 'Update $Order Set O_Value=0.00 Where O_ID=''$ID'''; 
          nSQL := MacroValue(nSQL, [MI('$Order', sTable_Order),MI('$ID', nOrderID)]);
          FDM.ExecuteSQL(nSQL);
          //��ֹ���ν���ɾ���ظ�������
        end;
      end;  

      nStr := 'Insert Into $DB($FL,D_DelMan,D_DelDate) ' +
              'Select $FL,''$User'',$Now From $DL Where D_ID=''$ID''';
      nStr := MacroValue(nStr, [MI('$DB', sTable_OrderDtlBak),
              MI('$FL', nP), MI('$User', gSysParam.FUserID),
              MI('$Now', sField_SQLServer_Now),
              MI('$DL', sTable_OrderDtl), MI('$ID', nID)]);
      FDM.ExecuteSQL(nStr);
    
      nStr := 'Delete From %s Where D_ID=''%s''';
      nStr := Format(nStr, [sTable_OrderDtl, nID]);
      FDM.ExecuteSQL(nStr);

      FDM.ADOConn.CommitTrans;
      InitFormData(FWhere);
      ShowMsg('ɾ�����', sHint);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('ɾ��ʧ��', sError);
    end;
  end;

  InitFormData('');
end;

procedure TfFrameOrderDetail.Check1Click(Sender: TObject);
begin
  inherited;
  InitFormData(FWhere);
end;

procedure TfFrameOrderDetail.N4Click(Sender: TObject);
var nStr: String;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('D_ID').AsString;
    PrintOrderReport(nStr, False);
  end;
end;

procedure TfFrameOrderDetail.N6Click(Sender: TObject);
var
  nStr:string;
  nDID: string;//�ɹ���ϸ��
  nDOID:string;//�ɹ�����
  npcid:string;//�ɹ���ͬ����
  nprovider_name,ncon_materiel_name:string;
  nNetWeight:Double;//���أ�ë��-Ƥ��
  nP: TFormCommandParam;
  nPopedom:string;
  function GetPcid(const noid:string;var npcid,nprovname,nmatename:string):Boolean;
  var
    nSql:string;
    nDs:TDataSet;
  begin
    Result := False;
    nSql := 'select O_ProName,O_StockName,pcid from %s where O_ID=''%s''';
    nSql := Format(nSql,[sTable_Order,noid]);
    nDs := fdm.QueryTemp(nSql);
    npcid := nDs.FieldByName('pcid').AsString;
    nprovname := nDs.FieldByName('O_ProName').AsString;
    nmatename := nDs.FieldByName('O_StockName').AsString;
    if npcid='' then
    begin
      Exit;
    end;
    Result := True;
  end;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nNetWeight := SQLQuery.FieldByName('D_NetWeight').AsFloat;
    if nNetWeight<=0 then
    begin
      ShowMsg('���ι���δ��ɣ��޷���������',sHint);
      Exit;
    end;
    
    nDOID := SQLQuery.FieldByName('D_OID').AsString;
    if nDOID='' then
    begin
      ShowMsg('δ�����ɹ��������޷���������',sHint);
      Exit;
    end;

    if not GetPcid(nDOID,npcid,nprovider_name,ncon_materiel_name) then
    begin
      ShowMsg('δ�����ɹ���ͬ,�޷���������',sHint);
      Exit;
    end;

    nStr := 'select * from %s where pcid=''%s''';
    nStr := Format(nStr,[sTable_PurchaseContractDetail,npcid]);
    if fdm.QueryTemp(nStr).RecordCount<=0 then
    begin
      ShowMsg('�����Ĳɹ���ͬ��ָ����Ϣ���޷���������',sHint);
      Exit;
    end;
    nDID := SQLQuery.FieldByName('D_ID').AsString;

    with TStringList.Create do
    begin
      Values['pcid'] := npcid;
      Values['provider_name'] := nprovider_name;
      Values['con_materiel_name'] := ncon_materiel_name;
      Values['NetWeight'] := FloatToStr(nNetWeight);
      Values['DID'] := nDID;
      nPopedom := Text;
      Free;
    end;

    nStr := 'select * from %s where D_ID=''%s''';
    nStr := Format(nStr,[sTable_PurchaseAssayResult,nDID]);
    //�鿴������
    if fdm.QueryTemp(nStr).RecordCount>0 then
    begin
      np.FCommand := cCmd_ViewData;
      CreateBaseFormItem(cFI_FormPurchaseAssayRes, nPopedom, @np);
      if (np.FCommand = cCmd_ModalResult) and (np.FParamA = mrOK) then
      begin
        InitFormData(FWhere);
      end;
    end
    //¼�뻯����
    else begin
      np.FCommand := cCmd_AddData;
      CreateBaseFormItem(cFI_FormPurchaseAssayRes, nPopedom, @np);
      if (np.FCommand = cCmd_ModalResult) and (np.FParamA = mrOK) then
      begin
        InitFormData(FWhere);
      end;
    end;
  end;
end;

procedure TfFrameOrderDetail.N8Click(Sender: TObject);
var nStr,nHint,nStatus,nNextStatus: string;
    nIdx: Integer;
    nRet: Boolean;
    gBills: TLadingBillItems;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr        := SQLQuery.FieldByName('D_ID').AsString;
    nStatus     := SQLQuery.FieldByName('D_Status').AsString;
    nNextStatus := SQLQuery.FieldByName('D_NextStatus').AsString;
    if (nStatus = 'M') and (nNextStatus = 'M') then
    begin
      nRet := GetPurchaseOrdersKS(nStr, sFlag_TruckIn, gBills);
      gBills[0].FIsKS := 2;
      nRet := SavePurchaseOrders(sFlag_TruckOut, gBills);
      if nRet then
      begin
        InitFormData(FWhere);
        ShowMsg('�ϴ��ɹ���', sHint);
      end
      else
      begin
        InitFormData(FWhere);
        ShowMsg('�ϴ�ʧ�ܣ�', sHint);
      end;
    end;
  end;
end;

procedure TfFrameOrderDetail.N9Click(Sender: TObject);
var
  nID   : string;
  nList : TStrings;
  nP: TFormCommandParam;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ����ļ�¼', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('D_ID').AsString;

  nList := TStringList.Create;
  try
    nList.Add(nID);

    nP.FCommand := cCmd_EditData;
    nP.FParamA := nList.Text;
    CreateBaseFormItem(cFI_FormOrderKW, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;

  finally
    nList.Free;
  end;
end;

procedure TfFrameOrderDetail.N10Click(Sender: TObject);
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ��ӡ�ļ�¼', sHint); Exit;
  end;

  nList := TStringList.Create;
  try
    for nIdx := 0 to cxView1.DataController.RowCount - 1  do
    begin

      nStr := GetVal(nIdx,'D_ID');
      if nStr = '' then
        Continue;

      nList.Add(nStr);
    end;

    nStr := AdjustListStrFormat2(nList, '''', True, ',', False);
    PrintOrderReport(nStr, False,True);
  finally
    nList.Free;
  end;
end;

function TfFrameOrderDetail.GetVal(const nRow: Integer;
  const nField: string): string;
var nVal: Variant;
begin
  nVal   := cxView1.ViewData.Rows[nRow].Values[
            cxView1.GetColumnByFieldName(nField).Index];
  //xxxxx

  if VarIsNull(nVal) then
       Result := ''
  else Result := nVal;
end;

procedure TfFrameOrderDetail.BtnEditClick(Sender: TObject);
begin
  //
end;

initialization
  gControlManager.RegCtrl(TfFrameOrderDetail, TfFrameOrderDetail.FrameID);
end.
