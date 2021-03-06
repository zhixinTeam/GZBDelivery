{*******************************************************************************
  ����: dmzn@163.com 2014-10-20
  ����: �Զ�����ͨ����
*******************************************************************************}
unit UFramePoundAutoItem;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMgrPoundTunnels, UBusinessConst, UFrameBase, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, StdCtrls,
  UTransEdit, ExtCtrls, cxRadioGroup, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLabel, ULEDFont;

type
  TfFrameAutoPoundItem = class(TBaseFrame)
    GroupBox1: TGroupBox;
    EditValue: TLEDFontNum;
    GroupBox3: TGroupBox;
    ImageGS: TImage;
    Label16: TLabel;
    Label17: TLabel;
    ImageBT: TImage;
    Label18: TLabel;
    ImageBQ: TImage;
    ImageOff: TImage;
    ImageOn: TImage;
    HintLabel: TcxLabel;
    EditTruck: TcxComboBox;
    EditMID: TcxComboBox;
    EditPID: TcxComboBox;
    EditMValue: TcxTextEdit;
    EditPValue: TcxTextEdit;
    EditJValue: TcxTextEdit;
    Timer1: TTimer;
    EditBill: TcxComboBox;
    EditZValue: TcxTextEdit;
    GroupBox2: TGroupBox;
    RadioPD: TcxRadioButton;
    RadioCC: TcxRadioButton;
    EditMemo: TcxTextEdit;
    EditWValue: TcxTextEdit;
    RadioLS: TcxRadioButton;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    cxLabel10: TcxLabel;
    Timer2: TTimer;
    Timer_ReadCard: TTimer;
    TimerDelay: TTimer;
    MemoLog: TZnTransMemo;
    Timer_SaveFail: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer_ReadCardTimer(Sender: TObject);
    procedure TimerDelayTimer(Sender: TObject);
    procedure Timer_SaveFailTimer(Sender: TObject);
  private
    { Private declarations }
    FCardUsed: string;
    //��Ƭ����
    FLEDContent: string;
    //��ʾ������
    FIsWeighting, FIsSaving: Boolean;
    //���ر�ʶ,�����ʶ
    FPoundTunnel: PPTTunnelItem;
    //��վͨ��
    FLastGS,FLastBT,FLastBQ: Int64;
    //�ϴλ
    FBillItems: TLadingBillItems;
    FUIData,FInnerData: TLadingBillItem;
    //��������
    FLastCardDone: Int64;
    FLastCard, FCardTmp, FLastReader, FLastBusinessCard: string;
    //�ϴο���, ��ʱ����, ���������
    FELabelList: TStrings;
    //���ӱ�ǩ�б�
    FListA: TStrings;
    FSampleIndex: Integer;
    FValueSamples: array of Double;
    //���ݲ���
    FVirPoundID: string;
    //����ذ����
    FOnlyELable: Boolean;
    //�Ƿ�ֻ�е��ӱ�ǩ
    FAutoTruckOut : Boolean;
    //�Ƿ��Զ�����
    FBarrierGate,FDaiZNoGan: Boolean;
    //�Ƿ���õ�բ
    FCardOnPound : Boolean;
    //�Ƿ����ˢ��
    FPoundMinNetWeight: Double;
    //������Сֵ(����������ҵ��ʹ��)
    FEmptyPoundInit, FDoneEmptyPoundInit: Int64;
    //�հ���ʱ,���������հ�
    FEmptyPoundIdleLong, FEmptyPoundIdleShort: Int64;
    //�հ�ʱ����
    FIsChkPoundStatus : Boolean;
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //��������
    procedure SetImageStatus(const nImage: TImage; const nOff: Boolean);
    //����״̬
    procedure SetTunnel(const nTunnel: PPTTunnelItem);
    //����ͨ��
    procedure OnPoundDataEvent(const nValue: Double);
    procedure OnPoundData(const nValue: Double);
    //��ȡ����
    procedure LoadBillItems(const nCard: string);
    //��ȡ������
    procedure LoadBillItemsELabel(const nCard: string);
    //��ȡ������(���ӱ�ǩ)
    function VerifySanValue(var nValue: Double): Boolean;
    //����ɢװ����
    procedure InitSamples;
    procedure AddSample(const nValue: Double);
    function IsValidSamaple: Boolean;
    //�������
    function CheckTruckMaxValue(const nTruck: string): Boolean;
    //��֤ë��
    function CheckTruckMValue(const nTruck: string): Boolean;
    //��֤���ض�λ
    function SavePoundSale(var nHint : string): Boolean;
    function SavePoundData(var nHint:string): Boolean;
    //�������
    procedure WriteLog(nEvent: string);
    //��¼��־
    procedure PlayVoice(const nStrtext: string);
    //��������
    procedure LEDDisplay(const nContent: string);
    //LED��ʾ
    procedure PlayVoiceEx(const nStrtext: string);
    //���Ÿڲ�������
    function ChkPoundStatus:Boolean;
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //����̳�
    property PoundTunnel: PPTTunnelItem read FPoundTunnel write SetTunnel;
    //�������
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UFormBase, {$IFDEF HR1847}UKRTruckProber,{$ELSE}UMgrTruckProbe,{$ENDIF}
  UMgrRemoteVoice, UMgrVoiceNet, UDataModule, USysBusiness,UBusinessPacker,
  USysLoger, USysConst, USysDB, UFormInputbox, UMgrLEDDisp;

const
  cFlag_ON    = 10;
  cFlag_OFF   = 20;

class function TfFrameAutoPoundItem.FrameID: integer;
begin
  Result := 0;
end;

procedure TfFrameAutoPoundItem.OnCreateFrame;
begin
  inherited;
  FPoundTunnel := nil;
  FIsWeighting := False;
  
  FEmptyPoundInit := 0;
  FListA := TStringList.Create;
  FELabelList := TStringList.Create;
end;

procedure TfFrameAutoPoundItem.OnDestroyFrame;
begin
  gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
  //�رձ�ͷ�˿�
  FListA.Free;
  FELabelList.Free;
  inherited;
end;

//Desc: ��������״̬ͼ��
procedure TfFrameAutoPoundItem.SetImageStatus(const nImage: TImage;
  const nOff: Boolean);
begin
  if nOff then
  begin
    if nImage.Tag <> cFlag_OFF then
    begin
      nImage.Tag := cFlag_OFF;
      nImage.Picture.Bitmap := ImageOff.Picture.Bitmap;
    end;
  end else
  begin
    if nImage.Tag <> cFlag_ON then
    begin
      nImage.Tag := cFlag_ON;
      nImage.Picture.Bitmap := ImageOn.Picture.Bitmap;
    end;
  end;
end;

procedure TfFrameAutoPoundItem.WriteLog(nEvent: string);
var nInt: Integer;
begin
  with MemoLog do
  try
    Lines.BeginUpdate;
    if Lines.Count > 20 then
     for nInt:=1 to 10 do
      Lines.Delete(0);
    //�������

    Lines.Add(DateTime2Str(Now) + #9 + nEvent);
  finally
    Lines.EndUpdate;
    Perform(EM_SCROLLCARET,0,0);
    Application.ProcessMessages;
  end;
end;

procedure WriteSysLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameAutoPoundItem, '�Զ�����ҵ��', nEvent);
end;

//------------------------------------------------------------------------------
//Desc: ��������״̬
procedure TfFrameAutoPoundItem.Timer1Timer(Sender: TObject);
begin
  SetImageStatus(ImageGS, GetTickCount - FLastGS > 5 * 1000);
  SetImageStatus(ImageBT, GetTickCount - FLastBT > 5 * 1000);
  SetImageStatus(ImageBQ, GetTickCount - FLastBQ > 5 * 1000);
end;

//Desc: �رպ��̵�
procedure TfFrameAutoPoundItem.Timer2Timer(Sender: TObject);
begin
  Timer2.Tag := Timer2.Tag + 1;
  if Timer2.Tag < 10 then Exit;

  Timer2.Tag := 0;
  Timer2.Enabled := False;

  {$IFNDEF MITTruckProber}
    {$IFDEF HR1847}
    gKRMgrProber.TunnelOC(FPoundTunnel.FID,False);
    {$ELSE}
    gProberManager.TunnelOC(FPoundTunnel.FID,False);
    {$ENDIF}
  {$ENDIF}
end;

//Desc: ����ͨ��
procedure TfFrameAutoPoundItem.SetTunnel(const nTunnel: PPTTunnelItem);
begin
  FPoundTunnel := nTunnel;
  FEmptyPoundIdleLong := -1;
  FEmptyPoundIdleShort:= -1;

  FPoundTunnel := nTunnel;
  SetUIData(True);

  FDaiZNoGan    := False;
  FOnlyELable   := False;
  FCardOnPound  := False;
  FAutoTruckOut := False;
  if Assigned(FPoundTunnel.FOptions) then
  with FPoundTunnel.FOptions do
  begin
    FVirPoundID  := Values['VirPoundID'];
    
    {$IFDEF UseELableAsCard}
    FOnlyELable  := Values['OnlyELable']  = sFlag_Yes;
    if FOnlyELable then
      WriteLog('ֻ�е��ӱ�ǩ��������');
    {$ENDIF}
    FBarrierGate := Values['BarrierGate'] = sFlag_Yes;

    FCardOnPound := Values['CardOnPound'] = sFlag_Yes;
    FAutoTruckOut:= Values['AutoTruckOut']= sFlag_Yes;

    FEmptyPoundIdleLong   := StrToInt64Def(Values['EmptyIdleLong'], 60);
    FEmptyPoundIdleShort  := StrToInt64Def(Values['EmptyIdleShort'], 5);
    FPoundMinNetWeight    := StrToFloatDef(Values['MinNetWeight'], 0);
  end;
end;

//Desc: ���ý�������
procedure TfFrameAutoPoundItem.SetUIData(const nReset,nOnlyData: Boolean);
var nStr: string;
    nInt: Integer;
    nVal: Double;
    nItem: TLadingBillItem;
begin
  if nReset then
  begin
    FillChar(nItem, SizeOf(nItem), #0);
    //init

    with nItem do
    begin
      FPModel := sFlag_PoundPD;
      FFactory := gSysParam.FFactNum;
    end;

    FUIData := nItem;
    FInnerData := nItem;
    if nOnlyData then Exit;

    SetLength(FBillItems, 0);
    EditValue.Text := '0.00';
    EditBill.Properties.Items.Clear;

    FIsSaving    := False;
    FEmptyPoundInit := 0;

    if not FIsWeighting then
    begin
      gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
      //�رձ�ͷ�˿�

      Timer_ReadCard.Enabled := True;
      //��������
    end;
  end;

  with FUIData do
  begin
    EditBill.Text := FID;
    EditTruck.Text := FTruck;
    EditMID.Text := FStockName;
    EditPID.Text := FCusName;

    EditMValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);

    if (FValue > 0) and (FMData.FValue > 0) and (FPData.FValue > 0) then
    begin
      nVal := FMData.FValue - FPData.FValue;
      EditJValue.Text := Format('%.2f', [nVal]);
      EditWValue.Text := Format('%.2f', [FValue - nVal]);
    end else
    begin
      EditJValue.Text := '0.00';
      EditWValue.Text := '0.00';
    end;

    RadioPD.Checked := FPModel = sFlag_PoundPD;
    RadioCC.Checked := FPModel = sFlag_PoundCC;
    RadioLS.Checked := FPModel = sFlag_PoundLS;

    RadioLS.Enabled := (FPoundID = '') and (FID = '');
    //�ѳƹ�����������,������ʱģʽ
    RadioCC.Enabled := FID <> '';
    //ֻ�������г���ģʽ

    EditBill.Properties.ReadOnly := (FID = '') and (FTruck <> '');
    EditTruck.Properties.ReadOnly := FTruck <> '';
    EditMID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    EditPID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    //�����������

    EditMemo.Properties.ReadOnly := True;
    EditMValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditPValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditJValue.Properties.ReadOnly := True;
    EditZValue.Properties.ReadOnly := True;
    EditWValue.Properties.ReadOnly := True;
    //������������

    if FTruck = '' then
    begin
      EditMemo.Text := '';
      Exit;
    end;
  end;

  nInt := Length(FBillItems);
  if nInt > 0 then
  begin
    if nInt > 1 then
         nStr := '���۲���'
    else nStr := '����';

    if FCardUsed = sFlag_Provide then nStr := '��Ӧ';
    if FCardUsed = sFlag_DuanDao then nStr := '��ʱ';

    if FUIData.FNextStatus = sFlag_TruckBFP then
    begin
      RadioCC.Enabled := False;
      EditMemo.Text := nStr + '��Ƥ��';
    end else
    begin
      RadioCC.Enabled := True;
      EditMemo.Text := nStr + '��ë��';
    end;
  end;
end;

//Date: 2017-01-17
//Parm: Ʒ��
//Desc: �ж�nStock�Ƿ�����ȥ�ֳ�װ����ι���
function AllowMultiM(const nStock: string): Boolean;
var nIdx: Integer;
begin
  Result := False;

  with gSysParam do
   for nIdx:=Low(FPoundMultiM) to High(FPoundMultiM) do
    if FPoundMultiM[nIdx] = nStock then
    begin
      Result := True;
      Break;
    end;
end;

//Date: 2014-09-19
//Parm: �ſ��򽻻�����
//Desc: ��ȡnCard��Ӧ�Ľ�����
procedure TfFrameAutoPoundItem.LoadBillItems(const nCard: string);
var nRet, nValidELabel: Boolean;
    nIdx,nInt,nIDxEx: Integer;
    nBills: TLadingBillItems;
    nStr,nHint,nVoice, nLabel,nMsg: string;
    nIsPreTruck:Boolean;
    nPrePValue: Double;
    nPrePMan: string;
    nPrePTime: TDateTime;
    nStatus, nNextStatus: string;
begin
  nStr := Format('��ȡ������[ %s ],��ʼִ��ҵ��.', [nCard]);
  WriteLog(nStr);

  FCardUsed := GetCardUsed(nCard);
  if FCardUsed = sFlag_Provide then
     nRet := GetPurchaseOrders(nCard, sFlag_TruckBFP, nBills) else
  if FCardUsed=sFlag_DuanDao then
     nRet := GetDuanDaoItems(nCard, sFlag_TruckBFP, nBills) else
  if FCardUsed=sFlag_Sale then
     nRet := GetLadingBills(nCard, sFlag_TruckBFP, nBills) else
  if FCardUsed=sFlag_SaleSingle then
     nRet := GetLadingBillsSingle(nCard, sFlag_TruckBFP, nBills) else nRet := False;

  if (not nRet) or (Length(nBills) < 1)
  then
  begin
    nVoice := '��ȡ�ſ���Ϣʧ��,����ϵ����Ա';
    PlayVoice(nVoice);
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;

  nIsPreTruck := getPrePInfo(nBills[0].FTruck,nPrePValue,nPrePMan,nPrePTime);
  nHint := '';
  nInt := 0;
  if not GetPOrderDtlStatus(nBills[0].FID) then
  begin
    nVoice := '��һ��ҵ��δ��������ȥж�Ͽ�ˢ���������ٽ��й������أ�';
    PlayVoice(nVoice);
    WriteSysLog(nVoice);
    Exit;
  end;
  
  {$IFDEF PoundTruckQueue}
  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    nRet := IsTruckQueue(FTruck);
    if not nRet then
    begin
      nStr := '[n1]%s���ڵ��ȶ�����,���ܹ���';
      nStr := Format(nStr, [FTruck]);
      PlayVoice(nStr);
      Exit;
    end;
  end;
  {$ENDIF}

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    {$IFDEF TruckAutoIn}
    if FStatus=sFlag_TruckNone then
    begin
      if FCardUsed = sFlag_Provide then
      begin
        if gSysParam.FIsKS = 1 then
          FIsKS := 1
        else
          FIsKS := 0;
        {$IFDEF PurchaseOrderSingle}
        if gSysParam.FIsMT = 1 then
        begin
          nRet := SavePurchaseOrdersSingle(sFlag_TruckIn, nBills);
        end
        else
        begin
          nRet := SavePurchaseOrders(sFlag_TruckIn, nBills);
        end;
        {$ELSE}
        nRet := SavePurchaseOrders(sFlag_TruckIn, nBills);
        {$ENDIF}
        if nRet then
        begin
          ShowMsg('���������ɹ�', sHint);
          LoadBillItems(FCardTmp);
          Exit;
        end else
        begin
          ShowMsg('��������ʧ��', sHint);
        end;
      end
      else
      if FCardUsed = sFlag_Sale then
      begin
        if gSysParam.FIsKS = 1 then
          FIsKS := 1
        else
          FIsKS := 0;
        {$IFNDEF UseNJYQueue}
        if not GetTruckIsQueue(FTruck) then
        begin
          nStr := '[n1]%s���ܹ���,��ȴ�';
          nStr := Format(nStr, [FTruck]);
          PlayVoice(nStr);
          Exit;
        end;
        if GetTruckIsOut(FTruck) then
        begin
          nStr := '[n1]%s�ѳ�ʱ����,����ϵ����Ա����';
          nStr := Format(nStr, [FTruck]);
          PlayVoice(nStr);
          Exit;
        end;
        {$ENDIF}
        if SaveLadingBills(sFlag_TruckIn, nBills,nMsg) then
        begin
          ShowMsg('���������ɹ�', sHint);
          LoadBillItems(FCardTmp);
          Exit;
        end else
        begin
          ShowMsg('��������ʧ��', sHint);
        end;
      end
      else
      if FCardUsed = sFlag_SaleSingle then
      begin
        if SaveLadingBillsSingle(sFlag_TruckIn, nBills) then
        begin
          ShowMsg('���������ɹ�', sHint);
          LoadBillItems(FCardTmp);
          Exit;
        end else
        begin
          ShowMsg('��������ʧ��', sHint);
        end;
      end
      else
      if FCardUsed = sFlag_DuanDao then
      begin
        if SaveDuanDaoItems(sFlag_TruckIn, nBills) then
        begin
          ShowMsg('���������ɹ�', sHint);
          LoadBillItems(FCardTmp);
          Exit;
        end else
        begin
          ShowMsg('��������ʧ��', sHint);
        end;
      end;
    end;
    {$ENDIF}
    if (FCtype=sFlag_CardGuDing) and nIsPreTruck and (gSysParam.FIsKS = 1) and (FCardUsed = sFlag_Provide) then
    begin
      if Trim(FID) = '' then
      begin
        nVoice := '�޽�����¼,����ϵ����Ա�˹�������,�ٽ��й������أ�';
        PlayVoice(nVoice);
        WriteSysLog(nVoice);
        Exit;
      end;
    end;
    //���ڿ�+Ԥ��Ƥ��
    if (FCtype=sFlag_CardGuDing) and nIsPreTruck and (gSysParam.FIsKS = 1) and (FCardUsed = sFlag_Provide) then
    begin
      //Ƥ�ع��ڻ�Ƥ��Ϊ0�������±���Ƥ��
      if nPrePValue < 0.00001 then
      begin
//        nStr := 'Ԥ��Ƥ����δ���ã�������Ԥ��Ƥ�غ��ٴι������أ�';
//        PlayVoice(nStr);
//        WriteSysLog(nStr);
//        Exit;
        FStatus := sFlag_TruckIn;
        FNextStatus := sFlag_TruckBFP;
        FillChar(FPData, SizeOf(FPData), 0);
        FillChar(FMData, SizeOf(FMData), 0);
      end
      //Ƥ����Ч������ë��
      else begin
        FNextStatus := sFlag_TruckBFM;
        with nBills[0] do
        begin
          FPData.FValue := nPrePValue;
          FPData.FOperator := nPrePMan;
          FPData.FDate := nPrePTime;
        end;
      end;
    end
    else
    if (FStatus <> sFlag_TruckBFP) and (FNextStatus = sFlag_TruckZT) then
      FNextStatus := sFlag_TruckBFP;
    //״̬У��

    {$IFDEF AllowMultiM}
    if (FStatus = sFlag_TruckBFM) and AllowMultiM(FStockNo) then
    begin
      FStatus     := sFlag_TruckFH;
      FNextStatus := sFlag_TruckBFM;
    end;
    //�����ι���
    {$ENDIF}
    //��ֹ˾���ֳ���ˢ�� �����ι����쳣

    FSelected := (FNextStatus = sFlag_TruckBFP) or
                 (FNextStatus = sFlag_TruckBFM);
    //�ɳ���״̬�ж�

    if FSelected then
    begin
      Inc(nInt);
      Continue;
    end;

    nStr := '��.����:[ %s ] ״̬:[ %-6s -> %-6s ]   ';
    if nIdx < High(nBills) then nStr := nStr + #13#10;

    nStr := Format(nStr, [FID,
            TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
    nHint := nHint + nStr;

    nVoice := '���� %s ���ܹ���,Ӧ��ȥ %s ';
    nVoice := Format(nVoice, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt = 0 then
  begin
    PlayVoice(nVoice);
    //����״̬�쳣

    nHint := '�ó�����ǰ���ܹ���,��������: ' + #13#10#13#10 + nHint;
    WriteSysLog(nStr);
    SetUIData(True);
    Exit;
  end;

  EditBill.Properties.Items.Clear;
  SetLength(FBillItems, nInt);
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if FSelected then
    begin
      FPoundID := '';
      //�ñ����������;
      
      if nInt = 0 then
           FInnerData := nBills[nIdx]
      else FInnerData.FValue := FInnerData.FValue + FValue;
      //�ۼ���

      EditBill.Properties.Items.Add(FID);
      FBillItems[nInt] := nBills[nIdx];
      Inc(nInt);
    end;
  end;

  FInnerData.FPModel := sFlag_PoundPD;
  FUIData := FInnerData;
  SetUIData(False);

  nInt := GetTruckLastTime(FUIData.FTruck);
  if (nInt > 0) and (nInt < FPoundTunnel.FCardInterval) then
  begin
    nStr := '��վ[ %s.%s ]: ����[ %s ]��ȴ� %d �����ܹ���';
    nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
            FUIData.FTruck, FPoundTunnel.FCardInterval - nInt]);
    WriteSysLog(nStr);
    SetUIData(True);
    Exit;
  end;
  //ָ��ʱ���ڳ�����ֹ����
  if not FOnlyELable then
  begin
    if FVirPoundID <> '' then
    begin
      nLabel := GetTruckRealLabel(FUIData.FTruck);
      if nLabel <> '' then
      begin
        nHint := ReadPoundCard(nStr, FVirPoundID);


        if (nHint <> '') and (FELabelList.IndexOf(nHint) < 0) then
          FELabelList.Add(nHint);

        nStr := '��վ[ %s.%s ]: ����[ %s.%s ]��ǰ���ӱ�ǩ�б�[ %s ]';
        nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
                FUIData.FTruck, nLabel, FELabelList.Text]);
        WriteSysLog(nStr);

        nValidELabel := False;
        for nIdx := 0 to FELabelList.Count - 1 do
        begin
          if Pos(nLabel, FELabelList.Strings[nIdx]) > 0 then
          begin
            nValidELabel := True;
            WriteSysLog('���ӱ�ǩƥ������.nLabel::'+nLabel+',nHint'+FELabelList.Strings[nIdx]);
            Break;
          end;
        end;

        if not nValidELabel then
        begin
          if nHint = '' then
          begin
            nStr := 'δʶ�����ǩ,���ƶ�����.';
            PlayVoice(nStr);
          end
          else
          if Pos(nLabel, nHint) < 1 then
          begin
            nStr := '���ӱ�ǩ��ƥ��,�����°�.';
            PlayVoice(nStr);
          end;

          nStr := '��վ[ %s.%s ]: ����[ %s.%s ]���ӱ�ǩ��ƥ��[ %s ],��ֹ�ϰ�';
          nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
                  FUIData.FTruck, nLabel, nHint]);
          WriteSysLog(nStr);
          SetUIData(True);
          Exit;
        end;
      end;
    end;
  end;
  //�жϳ����Ƿ��λ

  InitSamples;
  //��ʼ������

  if not FPoundTunnel.FUserInput then
  if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
         OnPoundDataEvent, True) then
  begin
    nHint := '���ӵذ���ͷʧ�ܣ�����ϵ����Ա���Ӳ������';
    WriteSysLog(nHint);

    nVoice := nHint;
    PlayVoice(nVoice);
    
    SetUIData(True);
    Exit;
  end;

  Timer_ReadCard.Enabled := False;
  FDoneEmptyPoundInit := 0;
  FIsWeighting := True;
  //ֹͣ����,��ʼ����

  if FBarrierGate then
  begin
    nStr := '[n1]%sˢ���ɹ����ϰ�,��Ϩ��ͣ��';
    nStr := Format(nStr, [FUIData.FTruck]);
    PlayVoice(nStr);
    //�����ɹ���������ʾ

    {$IFNDEF DEBUG}
    OpenDoorByReader(FLastReader);
    //������բ
    {$ENDIF}

    for nIDxEx := 0 to 1 do
    begin
      OpenDoorByReader(FLastReader);
      Sleep(500);
      Application.ProcessMessages;
    end;

  end;  
  //�����ϰ�
end;

//------------------------------------------------------------------------------
//Desc: �ɶ�ʱ��ȡ������
procedure TfFrameAutoPoundItem.Timer_ReadCardTimer(Sender: TObject);
var nStr,nCard,nLabel: string;
    nLast, nDoneTmp: Int64;
    nIdx : Integer;
begin
  if gSysParam.FIsManual then Exit;
  Timer_ReadCard.Tag := Timer_ReadCard.Tag + 1;
  if Timer_ReadCard.Tag < 5 then Exit;

  Timer_ReadCard.Tag := 0;
  if FIsWeighting then Exit;

  try
    WriteLog('���ڶ�ȡ�ſ���.');
    {$IFNDEF DEBUG}
      if not FOnlyELable then
        nCard := Trim(ReadPoundCard(FLastReader, FPoundTunnel.FID))
      else
      begin
        //ֻ�е��ӱ�ǩ������������Ҫ�������ͷ��ʶ
        nCard := ReadPoundCard(FLastReader, FPoundTunnel.FID);
        if nCard = '' then Exit;
        nCard := Copy(nCard,2,Length(nCard)-1);
        WriteLog('���ӱ�ǩ��'+nCard);
        nCard :=  GetELabelBillOrder(nCard);
        if FOnlyELable then
          WriteLog('ֻ�е��ӱ�ǩ��������');
      end;
    {$ENDIF}
    if nCard = '' then Exit;

    if nCard <> FLastCard then
         nDoneTmp := 0
    else nDoneTmp := FLastCardDone;
    //�¿�ʱ����

    if nCard <> FLastBusinessCard then//�¿�ʱ��յ��ӱ�ǩ�б�
    begin
      FLastBusinessCard := nCard;
      FELabelList.Clear;
    end
    else
    begin
      nLabel := GetReaderCard(FLastReader, 'RFID102');//��ȡ�õ��ӱ�ǩ����
      if (nLabel <> '') and (FELabelList.IndexOf(nLabel) < 0) then
      FELabelList.Add(nLabel);
    end;

    {$IFDEF DEBUG}
    nStr := '��վ[ %s.%s ]: ��ȡ���¿���::: %s =>�ɿ���::: %s';
    nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
            nCard, FLastCard]);
    WriteSysLog(nStr);
    {$ENDIF}

    nLast := Trunc((GetTickCount - nDoneTmp) / 1000);
    if (nDoneTmp <> 0) and (nLast < FPoundTunnel.FCardInterval)  then
    begin
      nStr := '��վ[ %s.%s ]: �ſ�[ %s ]��ȴ� %d �����ܹ���';
      nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
              nCard, FPoundTunnel.FCardInterval - nLast]);
      WriteSysLog(nStr);
      Exit;
    end;

    if not FCardOnPound then
    begin
      if Not ChkPoundStatus then Exit;
      //���ذ�״̬ �粻Ϊ�հ����򺰻� �˳�����
    end;

    FCardTmp := nCard;
    EditBill.Text := nCard;
    if not FOnlyELable then
      LoadBillItems(EditBill.Text)
    else
      LoadBillItemsELabel(EditBill.Text);
  except
    on E: Exception do
    begin
      nStr := Format('��վ[ %s.%s ]: ',[FPoundTunnel.FID,
              FPoundTunnel.FName]) + E.Message;
      WriteSysLog(nStr);

      SetUIData(True);
      //����������
    end;
  end;
end;

//Date: 2015-09-22
//Parm: ����[in];������[out]
//Desc: ���㾻�رȶ��������˶���,û����Ϊ0.
function TfFrameAutoPoundItem.VerifySanValue(var nValue: Double): Boolean;
var nStr, nHint, nOverStr: string;
    f,m,hRemNum,hDiffNum: Double;
    nHdID:string;
    nXmlStr,nDispatchNo,nData:string;
    nListA, nListB : TStrings;
begin
  Result := False;
  nStr := FInnerData.FProject;

  if not (YT_ReadCardInfo(nStr) and
     YT_VerifyCardInfo(nStr, sFlag_AllowZeroNum)) then
  begin
    PlayVoice('��ȡ����ʧ��,����ϵ����Ա����');
    WriteSysLog(nStr);

    nStr := GetTruckNO(FUIData.FTruck) + '��ȡ����ʧ��';
    LEDDisplay(nStr);
    Exit;
  end;

  FListA.Text := PackerDecodeStr(nStr);
  //��ȡ����
  m := StrToFloat(FListA.Values['XCB_RemainNum']);
  //����ʣ����

  f := nValue - FInnerData.FValue;
  //�������;��ز��

  nStr := '�������[%s]��������:' + #13#10 +
          '��.�������: %.2f��' + #13#10 +
          '��.�� Ʊ ��: %.2f��' + #13#10 +
          '��.����ʣ��: %.2f��' + #13#10 +
          '��.��������: %.2f��' + #13#10 +
          '��˶���Ϣ';
  nStr := Format(nStr, [FInnerData.FID, nValue, FInnerData.FValue, m, f]);
  WriteSysLog(nStr);

  m := f - m;
  //�������Ƿ���

  if m > 0 then
  begin
    {$IFDEF AutoPoundInManual}
    nStr := 'ɢװ��������%.2f��,��ȴ���ƱԱ����';
    nStr := Format(nStr, [m]);
    PlayVoice(nStr);

    nStr := 'ɢװ��������,��ȴ�����';
    LEDDisplay(nStr);
    {$ENDIF}

    nHint := '�ͻ�[ %s.%s ]������û���㹻����,��������:' + #13#10#13#10 +
             '��.�������: %s' + #13#10 +
             '��.���ƺ���: %s' + #13#10 +
             '��.ˮ��Ʒ��: %s' + #13#10 +
             '��.�������: %.2f��' + #13#10 +
             '��.�� �� ��: %.2f��' + #13#10+#13#10 +
             '�뵽��Ʊ�Ұ���������,Ȼ���ٴγ���.';
    //xxxxx

    nHint := Format(nHint, [FInnerData.FCusID, FInnerData.FCusName,
            FInnerData.FProject,FInnerData.FTruck,FInnerData.FStockName, nValue, m]);
    //xxxxx

    {$IFDEF AutoPoundInManual}
    WriteSysLog(nHint);
    nHint := nHint + '���п��������,����"��"��ť����.';
    if not QueryDlg(nHint, sHint) then Exit;

    nStr := '';
    while true do
    begin
      if not ShowInputBox('�������µ��������:', '����ҵ��', nStr) then Exit;
      nStr := Trim(nStr);

      if (nStr = '') or  (CompareText(nStr, FInnerData.FProject) = 0) then
      begin
        ShowMsg('��������Ч����', sHint);
        Continue;
      end;

      FUIData.FMemo := nStr;
      FUIData.FKZValue := m;

      nValue := m;
      Result := True; Break;
    end;
    {$ELSE}
    nHdID := FInnerData.FHdOrderId;
    if (nHdID <> '-1') and (nHdID <> '') then
    begin
      nStr := nHdID;

      if not (YT_ReadCardInfo(nStr) and
         YT_VerifyCardInfo(nStr, sFlag_AllowZeroNum)) then
      begin
        PlayVoice('��ȡ�ϵ�����ʧ��,����ϵ����Ա����');
        WriteSysLog(nStr);

        nStr := GetTruckNO(FUIData.FTruck) + '��ȡ�ϵ�ʧ��';
        LEDDisplay(nStr);

        Exit;
      end;

      FListA.Text := PackerDecodeStr(nStr);
      //��ȡ����
      hRemNum := StrToFloat(FListA.Values['XCB_RemainNum']);
      //�ϵ�����ʣ����
      nStr := nHdID;
      WriteSysLog(FloatToStr(m)+'   '+nStr+'�ϵ�����ʣ������'+ FloatToStr(hRemNum));

      hDiffNum := m - hRemNum;
      if hDiffNum > 0 then
      begin
        if not VerifyManualEventRecord(FInnerData.FID + sFlag_ManualD, nHint, 'I') then
        begin //��ƱԱ���Ժ���Ϊ˾��ж�����ٴι�����
          nStr := 'MStation=%s;m=%.2f;Pound_PValue=%.2f;Pound_MValue=%.2f;Pound_Card=%s';
          nStr := Format(nStr, [FPoundTunnel.FID,m,
                  FUIData.FPData.FValue, FUIData.FMData.FValue,FUIData.FCard]);

          AddManualEventRecord(FInnerData.FID + sFlag_ManualD, FInnerData.FTruck, nHint,
            sFlag_DepBangFang, sFlag_Solution_YNI, sFlag_DepDaTing, True, nStr);

          nStr := 'ɢװ��������%.2f��,����ϵ��ƱԱ����';
          nStr := Format(nStr, [m]);
          PlayVoice(nStr);

          nStr := GetTruckNO(FUIData.FTruck) + '����%.2f��';
          nStr := Format(nStr, [m]);
          LEDDisplay(nStr);
          Exit;
        end;
      end else
      begin
        nOverStr := 'MStation=%s;m=%.2f;Pound_PValue=%.2f;Pound_MValue=%.2f;Pound_Card=%s';
        nOverStr := Format(nOverStr, [FPoundTunnel.FID,m,
                FUIData.FPData.FValue, FUIData.FMData.FValue,FUIData.FCard]);

        AddManualEventRecordOver(FInnerData.FID + sFlag_ManualD, FInnerData.FTruck, nHint,
            sFlag_DepBangFang, sFlag_Solution_YNI, sFlag_DepDaTing, True, nOverStr);
      end;
    end else
    begin
      {$IFDEF UseWLFYInfo}
      if GetBillType(FInnerData.FID,nDispatchNo) then
      begin
        nXmlStr := PackerEncodeStr(nDispatchNo);
        nData   := get_WLFYshoporderbyno(nXmlStr);

        nListA := TStringList.Create;
        nListB := TStringList.Create;
        try
          nListA.Text := nData;
          nListB.Text := PackerDecodeStr(nListA[0]);
          if Pos('-',nListB.Values['extDispatchNo']) > 0 then
            nHdID  := Copy(nListB.Values['extDispatchNo'],Pos('-',nListB.Values['extDispatchNo'])+1,MaxInt)
          else
            nHdID  := '-1';
          FUIData.FextDispatchNo := nListB.Values['mergeSysDispatchNo'];
        finally
          nListA.Free;
          nListB.Free;
        end;
      end
      else
      begin
        nHdID := ReadWxHdOrderId(FInnerData.FID);
      end;
      {$ELSE}
      nHdID := ReadWxHdOrderId(FInnerData.FID);
      {$ENDIF}
      if (nHdID <> '-1') and (nHdID <> '') then
      begin
        nStr := nHdID;

        if not (YT_ReadCardInfo(nStr) and
           YT_VerifyCardInfo(nStr, sFlag_AllowZeroNum)) then
        begin
          PlayVoice('��ȡ�ϵ�����ʧ��,����ϵ����Ա����');
          WriteSysLog(nStr);

          nStr := GetTruckNO(FUIData.FTruck) + '��ȡ�ϵ�ʧ��';
          LEDDisplay(nStr);
          Exit;
        end;

        FListA.Text := PackerDecodeStr(nStr);
        //��ȡ����
        hRemNum := StrToFloat(FListA.Values['XCB_RemainNum']);
        //�ϵ�����ʣ����
        nStr := nHdID;
        WriteSysLog(FloatToStr(m)+'   '+nStr+'�ϵ�����ʣ������'+ FloatToStr(hRemNum));

        hDiffNum := m - hRemNum;
        if hDiffNum > 0 then
        begin
          if not VerifyManualEventRecord(FInnerData.FID + sFlag_ManualD, nHint, 'I') then
          begin //��ƱԱ���Ժ���Ϊ˾��ж�����ٴι�����
            nStr := 'MStation=%s;m=%.2f;Pound_PValue=%.2f;Pound_MValue=%.2f;Pound_Card=%s';
            nStr := Format(nStr, [FPoundTunnel.FID,m,
                    FUIData.FPData.FValue, FUIData.FMData.FValue,FUIData.FCard]);

            AddManualEventRecord(FInnerData.FID + sFlag_ManualD, FInnerData.FTruck, nHint,
              sFlag_DepBangFang, sFlag_Solution_YNI, sFlag_DepDaTing, True, nStr);

            nStr := 'ɢװ��������%.2f��,����ϵ��ƱԱ����';
            nStr := Format(nStr, [m]);
            PlayVoice(nStr);

            nStr := GetTruckNO(FUIData.FTruck) + '����%.2f��';
            nStr := Format(nStr, [m]);
            LEDDisplay(nStr);
            Exit;
          end;
        end else
        begin
          nOverStr := 'MStation=%s;m=%.2f;Pound_PValue=%.2f;Pound_MValue=%.2f;Pound_Card=%s';
          nOverStr := Format(nOverStr, [FPoundTunnel.FID,m,
                  FUIData.FPData.FValue, FUIData.FMData.FValue,FUIData.FCard]);

          AddManualEventRecordOver(FInnerData.FID + sFlag_ManualD, FInnerData.FTruck, nHint,
              sFlag_DepBangFang, sFlag_Solution_YNI, sFlag_DepDaTing, True, nOverStr);
        end;
      end else
      if not VerifyManualEventRecord(FInnerData.FID + sFlag_ManualD, nHint, 'I') then
      begin //��ƱԱ���Ժ���Ϊ˾��ж�����ٴι�����
        nStr := 'MStation=%s;m=%.2f;Pound_PValue=%.2f;Pound_MValue=%.2f;Pound_Card=%s';
        nStr := Format(nStr, [FPoundTunnel.FID,m,
                FUIData.FPData.FValue, FUIData.FMData.FValue,FUIData.FCard]);

        AddManualEventRecord(FInnerData.FID + sFlag_ManualD, FInnerData.FTruck, nHint,
          sFlag_DepBangFang, sFlag_Solution_YNI, sFlag_DepDaTing, True, nStr);

        nStr := 'ɢװ��������%.2f��,����ϵ��ƱԱ����';
        nStr := Format(nStr, [m]);
        PlayVoice(nStr);

        nStr := GetTruckNO(FUIData.FTruck) + '����%.2f��';
        nStr := Format(nStr, [m]);
        LEDDisplay(nStr);
        Exit;
      end;
    end;

    FUIData.FMemo := nStr;
    FUIData.FKZValue := m;
    FUIData.FHdOrderId := nHdID;

    nValue := m;
    Result := True;
    {$ENDIF}
  end else
  begin
    nValue := 0;
    Result := True;
  end;
end;

//Date: 2018-03-28
//Parm: ���ƺ�
//Desc: ��֤nTruck�Ƿ�����
function TfFrameAutoPoundItem.CheckTruckMaxValue(const nTruck: string): Boolean;
var nStr, nStatus: string;
    nVal: Double;
begin
  Result := True;
  nStr   := ' Select T_MaxBillNum From %s Where T_Truck=''%s'' ';
  nStr   := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr),FUIData do
  if RecordCount > 0 then
  begin
    nVal := Fields[0].AsFloat;
    if nVal <= 0 then Exit;

    Result := nVal >= FUIData.FMData.FValue - FUIData.FPData.FValue;
    if Result then Exit;

    nStr := '����[ %s ]�س���������,��������:' + #13#10 +
            '��.��������: %.2f��' + #13#10 +
            '��.��ǰ����: %.2f��' + #13#10 +
            '��.�� �� ��: %.2f��' + #13#10 +
            '�Ƿ��������?';
    nStr := Format(nStr, [FTruck, nVal, FMData.FValue - FPData.FValue, FMData.FValue - FPData.FValue - nVal]);

    Result := VerifyManualEventRecord(FID + sFlag_ManualF, nStr, sFlag_Yes, False);
    if Result then Exit; //����Ա����

    AddManualEventRecord(FID + sFlag_ManualF, FTruck, nStr, sFlag_DepBangFang,
      sFlag_Solution_YN, sFlag_DepJianZhuang, True);
    WriteSysLog(nStr);

    {$IFDEF AllowMultiM}//ɢװ�����ι���ʱ��������ë�����޺���У������״̬
    if FType = sFlag_Dai then
      nStatus := sFlag_TruckZT
    else
      nStatus := sFlag_TruckFH;

    AdjustBillStatus(FID, nStatus, sFlag_TruckBFM);

    nStr := '�����[%s]����[%s]״̬У��Ϊ:��ǰ״̬[%s],��һ״̬[%s]';
    nStr := Format(nStr, [FID, FTruck, nStatus, sFlag_TruckBFM]);
    WriteSysLog(nStr);
    {$ENDIF}

    nStr := '[n1]%s����%.2f��,�뷵��ж��.';
    nStr := Format(nStr, [FTruck, FMData.FValue - FPData.FValue]);
    PlayVoice(nStr);

    nStr := GetTruckNO(FTruck) + '�뷵��ж��';
    LEDDisplay(nStr);
  end;
end;

//Desc: ��������
function TfFrameAutoPoundItem.SavePoundSale(var nHint : string): Boolean;
var nStr : string;
    nVal,nNet, nWarn: Double;
    gBills: TLadingBillItems;
    nRet: Boolean;
begin
  nHint  := '';
  Result := False;
  //init
  FDaiZNoGan := False;

  with FUIData do
  if FNextStatus = sFlag_TruckBFP then
  begin
    if not VerifyPoundWarning(nHint, nWarn) then
    begin
      if not VerifyManualEventRecord(FID + sFlag_ManualA, nHint) then
      begin
        AddManualEventRecord(FID + sFlag_ManualA, FTruck, nHint);

        WriteSysLog(nHint);
        PlayVoice(nHint);
        LEDDisplay(nHint);
        Exit;
      end;
    end;
    //����Ƥ��Ԥ����Χ

    nNet := GetTruckEmptyValue(FTruck);
    nVal := nNet * 1000 - FPData.FValue * 1000;

    if (nNet > 0) and (nWarn > 0) and (Abs(nVal) > nWarn) then
    begin
      {$IFDEF AutoPoundInManual}
      nHint := '����[n1]%sƤ�����ϴ�,��ȴ�����Ա����';
      nHint := Format(nHint, [FTruck]);
      PlayVoice(nHint);
      {$ENDIF}

      nHint := '����[ %s ]ʵʱƤ�����ϴ�,��������:' + #13#10 +
              '��.ʵʱƤ��: %.2f��' + #13#10 +
              '��.��ʷƤ��: %.2f��' + #13#10 +
              '��.�����: %.2f����' + #13#10 +
              '�Ƿ��������?';
      nHint := Format(nHint, [FTruck, FPData.FValue,
              nNet, nVal]);
      //xxxxx

      {$IFDEF AutoPoundInManual}
      WriteSysLog(nHint);
      if not QueryDlg(nHint, sHint) then Exit;
      {$ELSE}
      if not VerifyManualEventRecord(FID + sFlag_ManualB, nHint) then
      begin
        AddManualEventRecord(FID + sFlag_ManualB, FTruck, nHint);
        WriteSysLog(nHint);

        nHint := '[n1]%sƤ�س���Ԥ��,��ȴ�����Ա����';
        nHint := Format(nHint, [FTruck]);
        PlayVoice(nHint);

        nStr := GetTruckNO(FTruck) + 'Ƥ�س���Ԥ��';
        LEDDisplay(nStr);

        Exit;
      end; //�ж�Ƥ���Ƿ񳬲�
      {$ENDIF}
    end;
  end;

  if FUIData.FNextStatus = sFlag_TruckBFM then
  begin
    if gSysParam.FPoundMMax and (FUIData.FMData.FValue > 0) then
      if not CheckTruckMValue(FUIData.FTruck) then Exit;
    //����ë������
    if gSysParam.FPoundJMax and (FUIData.FMData.FValue > 0)
       and (FUIData.FPData.FValue > 0)
       and (FUIData.FMData.FValue - FUIData.FPData.FValue > 0)
       and (FUIData.FType <> sFlag_Dai)
    then
    begin
      if not CheckTruckMaxValue(FUIData.FTruck) then Exit;
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) and
     (FUIData.FYSValid <> sFlag_Yes) then //�ǿճ�����
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      PlayVoice('Ƥ��ӦС��ë��,����ϵ����Ա����');

      nStr := GetTruckNO(FUIData.FTruck) + 'Ƥ�ش���ë��';
      LEDDisplay(nStr);

      Exit;
    end;

    nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;
    //����
    nVal := nNet * 1000 - FInnerData.FValue * 1000;
    //�뿪Ʊ�����(����)

    with gSysParam,FBillItems[0] do
    begin
      {$IFDEF DaiStepWuCha}
      if (FType = sFlag_Dai) then
        GetPoundAutoWuCha(FPoundDaiZ, FPoundDaiF, FInnerData.FValue);
      //xxxxx
      {$ELSE}
      if FDaiPercent and (FType = sFlag_Dai) then
      begin
        if nVal > 0 then
             FPoundDaiZ := Float2Float(FInnerData.FValue * FPoundDaiZ_1 * 1000,
                                       cPrecision, False)
        else FPoundDaiF := Float2Float(FInnerData.FValue * FPoundDaiF_1 * 1000,
                                       cPrecision, False);
      end;
      {$ENDIF}

      {$IFDEF DaiWCInManual}
      if (FType = sFlag_Dai) and (PoundDaiWCEx) then
      begin
        nStr := '����[ %s ]����δ�����������ϴ����Ϣ:' + #13#10 +
                '�����Ϻ�,���ȷ�����¹���.';
        nStr := Format(nStr, [FTruck]);

        if not VerifyManualEventRecordEx(FID + sFlag_ManualC, nStr) then
        begin
          nStr := '����[ %s ]����δ�����������ϴ����Ϣ:' + #13#10 +
                '�����Ϻ�,���ȷ�����¹���.';
          nStr := Format(nStr, [FTruck]);
          PlayVoice(nStr);

          nStr := GetTruckNO(FTruck) + '��ȥ��װ���';
          LEDDisplay(nStr);
          Exit;
        end;
      end;
      {$ENDIF}

      if ((FType = sFlag_Dai) and (
          ((nVal > 0) and (FPoundDaiZ > 0) and (nVal > FPoundDaiZ)) or
          ((nVal < 0) and (FPoundDaiF > 0) and (-nVal > FPoundDaiF))))then
      begin
        {$IFDEF AutoPoundInManual}
        nHint := '����[n1]%s�����뿪Ʊ�����ϴ�,��ȴ�����Ա����';
        nHint := Format(nHint, [FTruck]);
        PlayVoice(nHint);
        {$ENDIF}

        nHint := '����[ %s ]ʵ��װ�������ϴ�,��������:' + #13#10 +
                '��.������: %.2f��' + #13#10 +
                '��.װ����: %.2f��' + #13#10 +
                '��.�����: %.2f����' + #13#10 +
                '��ȷ���Ƿ���Թ���';
        nHint := Format(nHint, [FTruck, FInnerData.FValue, nNet, nVal]);

        {$IFDEF AutoPoundInManual}
        WriteSysLog(nHint);
        if not QueryDlg(nHint, sHint) then Exit;
        {$ELSE}
        if not VerifyManualEventRecord(FID + sFlag_ManualC, nHint) then
        begin
          FLastCardDone := GetTickCount;
          AddManualEventRecord(FID + sFlag_ManualC, FTruck, nHint,
            sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepJianZhuang);
          WriteSysLog(nHint);

          nHint := '����[n1]%s����[n2]%.2f��,��Ʊ��[n2]%.2f��,'+
                   '�����[n2]%.2f����,��ȥ��װ���';
          nHint := Format(nHint, [FTruck,nNet,FInnerData.FValue,nVal]);

          {$IFDEF PlayVoiceWithOutWeight}
          nHint := '����[n1]%sʵ��װ�������ϴ�,��ȥ��װ���';
          nHint := Format(nHint, [FTruck]);
          {$ENDIF}
          {$IFDEF GZBXS}
          nHint := '����[n1]%s���س�����Χ,���˻�ջ̨';
          nHint := Format(nHint, [FTruck]);
          {$ENDIF}

          {$IFDEF OnlyDaiZWuPlayVoice}
          if (nVal > 0) and (FPoundDaiZ > 0) and (nVal > FPoundDaiZ) then
          begin
            nHint := '[n1]%s�����ڴ˵ȴ�������Ա����';
            nHint := Format(nHint, [FTruck]);
            PlayVoice(nHint);
            FDaiZNoGan := True;
          end;
          if (nVal < 0) and (FPoundDaiF > 0) and (-nVal > FPoundDaiF) then
          begin
            nHint := '[n1]%s�����ڴ˵ȴ�������Ա����';
            nHint := Format(nHint, [FTruck]);
//            PlayVoice(nHint);
            WriteSysLog('��װ����' + nHint);
          end;
          {$ELSE}
          PlayVoice(nHint);
          {$ENDIF}

          nStr := GetTruckNO(FTruck) + '��ȥ��װ���';
          LEDDisplay(nStr);

          Exit;
        end;
        {$ENDIF}
      end;

      FUIData.FMemo := '';
      FUIData.FKZValue := 0;
      //��ʼ����������

      if FCardUsed <> sFlag_SaleSingle then
      begin
        if (nVal > 0) and (FType = sFlag_San) and (not VerifySanValue(nNet)) then
        begin
          nHint := '��������,����ϵ����Ա����';
          Exit;
        end;
        //ɢװ���س���������ʱ,��֤�Ƿ񷢳�
      end;
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) and
     (FUIData.FYSValid = sFlag_Yes) then //����ģʽ,���س�
  with FUIData do
  begin
    nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;
    nNet := Trunc(nNet * 1000);
    //����

    if nNet > 0 then
    if nNet > gSysParam.FEmpTruckWc then
    begin
      nVal := nNet - gSysParam.FEmpTruckWc;
      nStr := '����[n1]%s[p500]�ճ���������[n2]%.2f����,��˾����ϵ˾������Ա��鳵��';
      nStr := Format(nStr, [FBillItems[0].FTruck, Float2Float(nVal, cPrecision, True)]);
      WriteSysLog(nStr);
      PlayVoice(nStr);
      Exit;
    end;
    FUIData.FMData.FValue := FUIData.FPData.FValue;
  end;

  with FBillItems[0] do
  begin
    FPModel := FUIData.FPModel;
    FFactory := gSysParam.FFactNum;
    FextDispatchNo := FUIData.FextDispatchNo;
    FHdOrderId     := FUIData.FHdOrderId;

    with FPData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := FUIData.FPData.FValue;
      FOperator := gSysParam.FUserID;
    end;

    with FMData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := FUIData.FMData.FValue;
      FOperator := gSysParam.FUserID;
    end;

    FMemo := FUIData.FMemo;
    FKZValue := FUIData.FKZValue;
    //ɢװ������Ϣ

    FPoundID := sFlag_Yes;
    //��Ǹ����г�������
    if FCardUsed = sFlag_SaleSingle then
      Result := SaveLadingBillsSingle(FNextStatus, FBillItems, FPoundTunnel)
    else
      Result := SaveLadingBills(FNextStatus, FBillItems, nHint, FPoundTunnel);
    //�������

    //�ƹ�ë�غ�ֱ�ӳ���
    if FOnlyELable then
    begin
      if (FNextStatus = sFlag_TruckBFM) or (FNextStatus = sFlag_TruckOut) then
      begin
        WriteLog(FID+'�ƹ�ë��,ֱ�ӳ�����');
        SaveLadingBillsSingle(sFlag_TruckOut, FBillItems);
      end;
    end;
  end;

  if not Result then
  begin
    if nHint <> '' then
      PlayVoice(nHint)
    else
      PlayVoice('��������ʧ�ܣ������¹���');

    nStr := GetTruckNO(FUIData.FTruck) + '��������ʧ��';
    LEDDisplay(nStr);
    WriteSysLog(nStr);
  end;

end;

//------------------------------------------------------------------------------
//Desc: ԭ���ϻ���ʱ
function TfFrameAutoPoundItem.SavePoundData(var nHint:string): Boolean;
var nStr: string;
    nVal: Double;
    nRet: Boolean;
    gBills: TLadingBillItems;
    nIsPreTruck:Boolean;
    nPrePValue: Double;
    nPrePMan: string;
    nPrePTime: TDateTime;
begin
  Result := False;
  //init
  nHint  := '';

  with FUIData do
  begin
    nIsPreTruck := getPrePInfo(FTruck,nPrePValue,nPrePMan,nPrePTime);
    //���ڿ�+Ԥ��Ƥ��
    if (FCtype=sFlag_CardGuDing) and nIsPreTruck and (gSysParam.FIsKS = 1)
      and (FCardUsed = sFlag_Provide) then
    begin
      //����С���趨�������±���Ƥ��
      if (StrToFloatDef(EditValue.Text,0) < GetPrePValueSet) then
      begin
        SaveTruckPrePValue(FTruck,EditValue.Text);
        UpdateTruckStatus(FUIData.FID);
        SaveTruckPrePicture(FTruck,FPoundTunnel);

        Result := True;
        Exit;
      end;
      FPData.FValue :=  nPrePValue;
      FPData.FOperator := nPrePMan;
      FPData.FDate := nPrePTime;
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      WriteLog('Ƥ��ӦС��ë��');

      nHint := GetTruckNO(FUIData.FTruck) + 'Ƥ�ش���ë��';
      LEDDisplay(nHint);
      Exit;
    end;

    if FPoundMinNetWeight > 0 then
    begin
      nVal := FUIData.FMData.FValue - FUIData.FPData.FValue;
      //����

      if nVal < FPoundMinNetWeight then
      begin
        nHint := '����[%.2f<%.2f(����)]������ҵ��.';
        nHint := Format(nHint, [nVal, FPoundMinNetWeight]);
        WriteLog(nHint);

        nHint := '����[ %s ]����[%.2f<%.2f(����)]��Ч,�����汾�γ���.';
        nHint := Format(nHint, [FUIData.FTruck, nVal, FPoundMinNetWeight]);
        WriteSysLog(nHint);

        nHint := '����[ %s ]���γ�����Ч,���°�.';
        nHint := Format(nHint, [FUIData.FTruck]);
        PlayVoice(nHint);

        nHint := GetTruckNO(FUIData.FTruck) + '����С������';
        LEDDisplay(nHint);
        Exit;
      end;
    end;
  end;

  nStr := FBillItems[0].FNextStatus;
  //�ݴ���һ״̬

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //�����û���������

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx

    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;

    if gSysParam.FIsKS = 1 then
      FIsKS := 1
    else
      FIsKS := 0;
  end;

  if FCardUsed = sFlag_Provide then
    {$IFDEF PurchaseOrderSingle}
    if gSysParam.FIsMT = 1 then
      Result := SavePurchaseOrdersSingle(nStr, FBillItems,FPoundTunnel)
    else
      Result := SavePurchaseOrders(nStr, FBillItems,FPoundTunnel)
    {$ELSE}
      Result := SavePurchaseOrders(nStr, FBillItems,FPoundTunnel)
    {$ENDIF}
  else Result := SaveDuanDaoItems(nStr, FBillItems, FPoundTunnel);
  //�������

  //�ƹ�ë�غ�ֱ�ӳ���   P_TransBase
  WriteSysLog('��ʼ����ƹ�ë��,ֱ�ӳ�����'+FBillItems[0].FID);
  if (FOnlyELable) or (FAutoTruckOut) then
  begin
    if FCardUsed = sFlag_Provide then
    begin
      nStr := 'Select D_NextStatus From %s Where D_ID=''%s'' ';
      nStr := Format(nStr, [sTable_OrderDtl,FBillItems[0].FID]);

      with FDM.QueryTemp(nStr) do
      begin
        if (RecordCount > 0) then
        begin
          nStr := Fields[0].AsString;
        end
        else
          Exit;
      end;
      WriteSysLog('������һ״̬Ϊ��'+nStr);

      if (nStr = sFlag_TruckOut) then
      begin
        WriteSysLog('�ƹ�ë��,ֱ�ӳ�����');
        SavePurchaseOrdersSingle(sFlag_TruckOut, FBillItems);
      end;
    end
    else
    begin
      nStr := 'Select T_NextStatus From %s Where T_ID = ''%s'' ';
      nStr := Format(nStr, [sTable_Transfer,FBillItems[0].FID]);

      with FDM.QueryTemp(nStr) do
      begin
        if (RecordCount > 0) then
        begin
          nStr := Fields[0].AsString;
        end
        else
          Exit;
      end;
      WriteSysLog('������һ״̬Ϊ��'+nStr);

      if (nStr = sFlag_TruckOut) then
      begin
        WriteSysLog('�ڵ��ƹ�ë��,ֱ�ӳ�����');
        SaveDuanDaoItems(sFlag_TruckOut, FBillItems);
      end;
    end;
  end;

  if not Result then
  begin
    PlayVoice('��������ʧ�ܣ������¹���');

    nStr := GetTruckNO(FUIData.FTruck) + '��������ʧ��';
    LEDDisplay(nStr);
    WriteSysLog(nStr);
  end;

end;

//Desc: ��ȡ��ͷ����
procedure TfFrameAutoPoundItem.OnPoundDataEvent(const nValue: Double);
begin
  try
    if FIsSaving then Exit;
    //���ڱ��档����

    OnPoundData(nValue);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      SetUIData(True);
    end;
  end;
end;

//Desc: �����ͷ����
procedure TfFrameAutoPoundItem.OnPoundData(const nValue: Double);
var nRet: Boolean;
    nInt: Int64;
    nIDxEx : Integer;
    nStr, nHint: string;
begin
  nHint   := '';
  FLastBT := GetTickCount;
  EditValue.Text := Format('%.2f', [nValue]);

  if not FIsWeighting then Exit;
  //���ڳ�����
  if gSysParam.FIsManual then Exit;
  //�ֶ�ʱ��Ч

  if nValue < FPoundTunnel.FPort.FMinValue then //�հ�
  begin
    if FEmptyPoundInit = 0 then
      FEmptyPoundInit := GetTickCount;
    nInt := GetTickCount - FEmptyPoundInit;

    if (nInt > FEmptyPoundIdleLong * 1000) then
    begin
      FIsWeighting :=False;
      Timer_SaveFail.Enabled := True;

      WriteSysLog('ˢ����˾������Ӧ,�˳�����.');
      Exit;
    end;
    //�ϰ�ʱ��,�ӳ�����

    if (nInt > FEmptyPoundIdleShort * 1000) and   //��֤�հ�
       (FDoneEmptyPoundInit>0) and (GetTickCount-FDoneEmptyPoundInit>nInt) then
    begin
      FIsWeighting :=False;
      Timer_SaveFail.Enabled := True;

      WriteSysLog('˾�����°�,�˳�����.');
      Exit;
    end;
    //�ϴα���ɹ���,�հ���ʱ,��Ϊ�����°�

    Exit;
  end else
  begin
    FEmptyPoundInit := 0;
    if FDoneEmptyPoundInit > 0 then
      FDoneEmptyPoundInit := GetTickCount;
    //����������Ϻ�δ�°�
  end;

  AddSample(nValue);
  if not IsValidSamaple then Exit;
  //������֤��ͨ��

  if Length(FBillItems) < 1 then Exit;
  //�޳�������

  if (FCardUsed = sFlag_Provide) or (FCardUsed = sFlag_DuanDao) then
  begin
    if FInnerData.FPData.FValue > 0 then
    begin
      if nValue <= FInnerData.FPData.FValue then
      begin
        FUIData.FPData := FInnerData.FMData;
        FUIData.FMData := FInnerData.FPData;

        FUIData.FPData.FValue := nValue;
        FUIData.FNextStatus := sFlag_TruckBFP;
        //�л�Ϊ��Ƥ��
      end else
      begin
        FUIData.FPData := FInnerData.FPData;
        FUIData.FMData := FInnerData.FMData;

        FUIData.FMData.FValue := nValue;
        FUIData.FNextStatus := sFlag_TruckBFM;
        //�л�Ϊ��ë��
      end;
    end else FUIData.FPData.FValue := nValue;
  end else
  if FBillItems[0].FNextStatus = sFlag_TruckBFP then
       FUIData.FPData.FValue := nValue
  else FUIData.FMData.FValue := nValue;

  SetUIData(False);
  //���½���

  {$IFDEF MITTruckProber}
    if not IsTunnelOK(FPoundTunnel.FID) then
  {$ELSE}
    {$IFDEF HR1847}
    if not gKRMgrProber.IsTunnelOK(FPoundTunnel.FID) then
    {$ELSE}
    if not gProberManager.IsTunnelOK(FPoundTunnel.FID) then
    {$ENDIF}
  {$ENDIF}
  begin
    PlayVoice('����δͣ��λ,���ƶ�����.');
    //LEDDisplay(nStr);

    InitSamples;
    Exit;
  end;

  nStr := GetTruckNO(FUIData.FTruck) + '����:' + GetValue(nValue);
  ProberShowTxt(FPoundTunnel.FID, nStr);

  {$IFDEF PVlueVoice}
  if (FCardUsed = sFlag_Sale) or (FCardUsed = sFlag_SaleSingle) then
  begin
    with FUIData do
    if FNextStatus = sFlag_TruckBFP then
    begin
      nStr := '����[n1]%sƤ��[n2]%.2f��';
      nStr := Format(nStr, [FUIData.FTruck,Float2Float(nValue, 1000)]);
      PlayVoice(nStr);
    end;
  end;
  {$ENDIF}
  
  FIsSaving := True;
  if (FCardUsed = sFlag_Sale) or (FCardUsed = sFlag_SaleSingle) then
       nRet := SavePoundSale(nHint)
  else nRet := SavePoundData(nHint);

  if not nRet then
  begin
    if nHint <> '' then
    begin
      nStr := nHint;
    end
    else
    begin
      nStr := '���ݱ���ʧ��,�����¹���.';
    end;
    PlayVoice(nStr);


    nStr := GetTruckNO(FUIData.FTruck) + nStr;
    {$IFDEF MITTruckProber}
    ProberShowTxt(FPoundTunnel.FID, nStr);
    {$ELSE}
    gProberManager.ShowTxt(FPoundTunnel.FID, nStr);
    {$ENDIF}
    
    nStr := GetTruckNO(FUIData.FTruck) + '���ݱ���ʧ��';
    {$IFDEF MITTruckProber}
    ProberShowTxt(FPoundTunnel.FID, nStr);
    {$ELSE}
    gProberManager.ShowTxt(FPoundTunnel.FID, nStr);
    {$ENDIF}
  end;

  {$IFDEF VoiceToDoor}
  if not nRet then
  begin
    nStr := '[n1]%s����ʧ��,�봦��';
    nStr := Format(nStr, [FUIData.FTruck]);
    WriteSysLog(nStr);
    PlayVoiceEx(nStr);
  end;
  {$ENDIF}

  {$IFDEF VoiceToDoorEx}
  if not nRet then
  begin
    nStr := '[n1]%s����ʧ��,�����¹���';
    nStr := Format(nStr, [FUIData.FTruck]);
    WriteSysLog(nStr);
    PlayVoice(nStr);
  end;
  {$ENDIF}

  if nRet then
  begin
    {$IFDEF XSLedShow}
    nStr := FUIData.FTruck + '-' + FUIData.FStockName;
    if Length(nStr) > 24 then
      nStr := Copy(nStr, 1, 24);
    {$ELSE}
    nStr := GetTruckNO(FUIData.FTruck) + '����:' + GetValue(nValue);
    {$ENDIF}
    LEDDisplay(nStr);

    TimerDelay.Enabled := True;
  end
  else Timer_SaveFail.Enabled := True;

  if not FDaiZNoGan then
  begin
    if FBarrierGate then
    begin
      nInt := 0;
      {$IFDEF ERROPENONEDOOR}
      if not nRet then
      begin
        nInt := 10;
        OpenDoorByReader(FLastReader, sFlag_Yes);
        Exit;
      end;
      {$ELSE}
      //�ɹ�����ʧ�ܲ�̧��
//      if (FCardUsed = sFlag_Provide) then
//      begin
//        if not nRet then
//           nInt := 5;
//      end;
      {$ENDIF}

      if IsAsternStock(FUIData.FStockName) then
      begin
        nInt := 10;
        OpenDoorByReader(FLastReader, sFlag_Yes); //������բ(���)

        for nIDxEx := 0 to 1 do
        begin
          OpenDoorByReader(FLastReader, sFlag_Yes);
          Sleep(500);
          Application.ProcessMessages;
        end;
      end;
      if nInt = 0 then
      begin
        OpenDoorByReader(FLastReader, sFlag_No);

        for nIDxEx := 0 to 1 do
        begin
          OpenDoorByReader(FLastReader, sFlag_No);
          Sleep(500);
          Application.ProcessMessages;
        end;
      end;
      //�򿪸���բ
    end;
  end;
end;

procedure TfFrameAutoPoundItem.TimerDelayTimer(Sender: TObject);
var nStr: string;
begin
  try
    TimerDelay.Enabled := False;
    WriteSysLog(Format('�Գ���[ %s ]�������.', [FUIData.FTruck]));

    {$IFDEF VoiceMValue}
    if (FCardUsed = sFlag_Sale) and (FUIData.FType = sFlag_San) and
       (FUIData.FNextStatus = sFlag_TruckBFM) then
    begin
      nStr := '����[n1]%së��[n2]%.2f��[p500]����[n2]%.2f��,���°�';
      nStr := Format(nStr, [FUIData.FTruck,
              Float2Float(FUIData.FMData.FValue, 1000),
              Float2Float(FUIData.FMData.FValue - FUIData.FPData.FValue, 1000)]);
      PlayVoice(nStr);
    end else PlayVoice(#9 + FUIData.FTruck);
    //��������
    {$ELSE}
    PlayVoice(#9 + FUIData.FTruck);
    //��������
    {$ENDIF}

    FLastCard     := FCardTmp;
    FLastCardDone := GetTickCount;
    FDoneEmptyPoundInit := GetTickCount;
    //����״̬

    if not FBarrierGate then
      FIsWeighting := False;
    //�����޵�բʱ����ʱ�������

    {$IFDEF MITTruckProber}
        TunnelOC(FPoundTunnel.FID, True);
    {$ELSE}
      {$IFDEF HR1847}
      gKRMgrProber.TunnelOC(FPoundTunnel.FID, True);
      {$ELSE}
      gProberManager.TunnelOC(FPoundTunnel.FID, True);
      {$ENDIF}
    {$ENDIF} //�����̵�
      
    Timer2.Enabled := True;
    SetUIData(True);
  except
    on E: Exception do
    begin
      nStr := '��վ[ %s.%s ]: %s';
      WriteSysLog(Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ������
procedure TfFrameAutoPoundItem.InitSamples;
var nIdx: Integer;
begin
  SetLength(FValueSamples, FPoundTunnel.FSampleNum);
  FSampleIndex := Low(FValueSamples);

  for nIdx:=High(FValueSamples) downto FSampleIndex do
    FValueSamples[nIdx] := 0;
  //xxxxx
end;

//Desc: ��Ӳ���
procedure TfFrameAutoPoundItem.AddSample(const nValue: Double);
begin
  FValueSamples[FSampleIndex] := nValue;
  Inc(FSampleIndex);

  if FSampleIndex >= FPoundTunnel.FSampleNum then
    FSampleIndex := Low(FValueSamples);
  //ѭ������
end;

//Desc: ��֤�����Ƿ��ȶ�
function TfFrameAutoPoundItem.IsValidSamaple: Boolean;
var nIdx: Integer;
    nVal: Integer;
begin
  Result := False;

  for nIdx:=FPoundTunnel.FSampleNum-1 downto 1 do
  begin
    if FValueSamples[nIdx] < FPoundTunnel.FPort.FMinValue then Exit;
    //����������

    nVal := Trunc(FValueSamples[nIdx] * 1000 - FValueSamples[nIdx-1] * 1000);
    if Abs(nVal) >= FPoundTunnel.FSampleFloat then Exit;
    //����ֵ����
  end;

  Result := True;
end;

procedure TfFrameAutoPoundItem.PlayVoice(const nStrtext: string);
begin
  {$IFNDEF DEBUG}
  if (Assigned(FPoundTunnel.FOptions)) and
     (CompareText('NET', FPoundTunnel.FOptions.Values['Voice']) = 0) then
       gNetVoiceHelper.PlayVoice(nStrtext, FPoundTunnel.FID, 'pound')
  else gVoiceHelper.PlayVoice(nStrtext);
  {$ENDIF}
end;

procedure TfFrameAutoPoundItem.Timer_SaveFailTimer(Sender: TObject);
begin
  inherited;
  try
    FDoneEmptyPoundInit := GetTickCount;
    Timer_SaveFail.Enabled := False;
    SetUIData(True);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

procedure TfFrameAutoPoundItem.LEDDisplay(const nContent: string);
begin
  {$IFDEF BFLED}
  WriteSysLog(Format('LEDDisplay:%s.%s', [FPoundTunnel.FID, nContent]));
  if Assigned(FPoundTunnel.FOptions) And
     (UpperCase(FPoundTunnel.FOptions.Values['LEDEnable'])='Y') then
  begin
    if FLEDContent = nContent then Exit;
    FLEDContent := nContent;
    gDisplayManager.Display(FPoundTunnel.FID, nContent);
  end;
  {$ENDIF}
end;

procedure TfFrameAutoPoundItem.PlayVoiceEx(const nStrtext: string);
begin
  {$IFNDEF DEBUG}
  if (Assigned(FPoundTunnel.FOptions)) and
     (CompareText('NET', FPoundTunnel.FOptions.Values['Voice']) = 0) then
  begin
    WriteSysLog(Format('NetVoicePlayEx:%s.%s', [FPoundTunnel.FOptions.Values['VoiceEx']
                                                , nStrtext]));
    gNetVoiceHelper.PlayVoice(nStrtext,
    FPoundTunnel.FOptions.Values['VoiceEx'], 'door')
  end
  else gVoiceHelper.PlayVoice(nStrtext);
  {$ENDIF}
end;

function TfFrameAutoPoundItem.ChkPoundStatus: Boolean;
var nIdx:Integer;
    nHint : string;
begin
  Result:= True;
  try
    FIsChkPoundStatus:= True;
    if not FPoundTunnel.FUserInput then
    if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
           OnPoundDataEvent, True) then
    begin
      nHint := '���ذ������ӵذ���ͷʧ�ܣ�����ϵ����Ա���Ӳ������';
      WriteSysLog(nHint);
      PlayVoice(nHint);
    end;

    for nIdx:= 0 to 5 do
    begin
      Sleep(500);  Application.ProcessMessages;
      if StrToFloatDef(Trim(EditValue.Text), -1) > FPoundTunnel.FPort.FMinValue then
      begin
        Result:= False;
        nHint := '���ذ����ذ��������� %s ,���ܽ��г�����ҵ';
        nhint := Format(nHint, [EditValue.Text]);
        WriteSysLog(nHint);

        PlayVoice('���ܽ��г�����ҵ,��س�������Ա���°�');
        Break;
      end;
    end;
  finally
    FIsChkPoundStatus:= False;
    SetUIData(True);
  end;
end;

procedure TfFrameAutoPoundItem.LoadBillItemsELabel(const nCard: string);
var nRet: Boolean;
    nIdx,nInt,nIDxEx: Integer;
    nBills: TLadingBillItems;
    nStr,nHint,nVoice, nLabel,nMsg: string;
begin
  nStr := Format('��ȡ������[ %s ],��ʼִ��ҵ��.', [nCard]);
  WriteLog(nStr);

  FCardUsed := GetBillOrderType(nCard);
  if FCardUsed = sFlag_Provide then
     nRet := GetPurchaseOrdersSingle(nCard, sFlag_TruckBFP, nBills) else
  if FCardUsed=sFlag_SaleSingle then
     nRet := GetLadingBillsSingle(nCard, sFlag_TruckBFP, nBills) else nRet := False;

  if (not nRet) or (Length(nBills) < 1)
  then
  begin
    nVoice := '��ȡ�ſ���Ϣʧ��,����ϵ����Ա';
    PlayVoice(nVoice);
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;

  nHint := '';
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    {$IFDEF TruckAutoIn}
    if FStatus=sFlag_TruckNone then
    begin
      if FCardUsed = sFlag_Provide then
      begin
        {$IFDEF PurchaseOrderSingle}
        if gSysParam.FIsMT = 1 then
          nRet := SavePurchaseOrdersSingle(sFlag_TruckIn, nBills)
        else
          nRet := SavePurchaseOrders(sFlag_TruckIn, nBills);
        {$ELSE}
        nRet := SavePurchaseOrders(sFlag_TruckIn, nBills);
        {$ENDIF}
        if nRet then
        begin
          ShowMsg('���������ɹ�', sHint);
          LoadBillItemsELabel(FCardTmp);
          Exit;
        end else
        begin
          ShowMsg('��������ʧ��', sHint);
        end;
      end
      else
      if FCardUsed = sFlag_Sale then
      begin
        if SaveLadingBills(sFlag_TruckIn, nBills,nMsg) then
        begin
          ShowMsg('���������ɹ�', sHint);
          LoadBillItemsELabel(FCardTmp);
          Exit;
        end else
        begin
          ShowMsg('��������ʧ��', sHint);
        end;
      end
      else
      if FCardUsed = sFlag_SaleSingle then
      begin
        if SaveLadingBillsSingle(sFlag_TruckIn, nBills) then
        begin
          ShowMsg('���������ɹ�', sHint);
          LoadBillItemsELabel(FCardTmp);
          Exit;
        end else
        begin
          ShowMsg('��������ʧ��', sHint);
        end;
      end
      else
      if FCardUsed = sFlag_DuanDao then
      begin
        if SaveDuanDaoItems(sFlag_TruckIn, nBills) then
        begin
          ShowMsg('���������ɹ�', sHint);
          LoadBillItemsELabel(FCardTmp);
          Exit;
        end else
        begin
          ShowMsg('��������ʧ��', sHint);
        end;
      end;
    end;
    {$ENDIF}
    if (FStatus <> sFlag_TruckBFP) and (FNextStatus = sFlag_TruckZT) then
      FNextStatus := sFlag_TruckBFP;
    //״̬У��

    FSelected := (FNextStatus = sFlag_TruckBFP) or
                 (FNextStatus = sFlag_TruckBFM);
    //�ɳ���״̬�ж�

    if FSelected then
    begin
      Inc(nInt);
      Continue;
    end;

    nStr := '��.����:[ %s ] ״̬:[ %-6s -> %-6s ]   ';
    if nIdx < High(nBills) then nStr := nStr + #13#10;

    nStr := Format(nStr, [FID,
            TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
    nHint := nHint + nStr;

    nVoice := '���� %s ���ܹ���,Ӧ��ȥ %s ';
    nVoice := Format(nVoice, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt = 0 then
  begin
    PlayVoice(nVoice);
    //����״̬�쳣

    nHint := '�ó�����ǰ���ܹ���,��������: ' + #13#10#13#10 + nHint;
    WriteSysLog(nStr);
    SetUIData(True);
    Exit;
  end;

  EditBill.Properties.Items.Clear;
  SetLength(FBillItems, nInt);
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if FSelected then
    begin
      FPoundID := '';
      //�ñ����������;
      
      if nInt = 0 then
           FInnerData := nBills[nIdx]
      else FInnerData.FValue := FInnerData.FValue + FValue;
      //�ۼ���

      EditBill.Properties.Items.Add(FID);
      FBillItems[nInt] := nBills[nIdx];
      Inc(nInt);
    end;
  end;

  FInnerData.FPModel := sFlag_PoundPD;
  FUIData := FInnerData;
  SetUIData(False);

  nInt := GetTruckLastTime(FUIData.FTruck);
  if (nInt > 0) and (nInt < FPoundTunnel.FCardInterval) then
  begin
    nStr := '��վ[ %s.%s ]: ����[ %s ]��ȴ� %d �����ܹ���';
    nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
            FUIData.FTruck, FPoundTunnel.FCardInterval - nInt]);
    WriteSysLog(nStr);
    SetUIData(True);
    Exit;
  end;
  //ָ��ʱ���ڳ�����ֹ����
  if not FOnlyELable then
  begin
    if FVirPoundID <> '' then
    begin
      nLabel := GetTruckRealLabel(FUIData.FTruck);
      if nLabel <> '' then
      begin
        nHint := ReadPoundCard(nStr, FVirPoundID);
        if (nHint = '') or (Pos(nLabel, nHint) < 1) then
        begin
          nStr := 'δʶ�����ǩ,���ƶ�����.';
          PlayVoice(nStr);

          nStr := '��վ[ %s.%s ]: ����[ %s.%s ]���ӱ�ǩ��ƥ��[ %s ],��ֹ�ϰ�';
          nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
                  FUIData.FTruck, nLabel, nHint]);
          WriteSysLog(nStr);
          SetUIData(True);
          Exit;
        end;
      end;
    end;
  end;
  //�жϳ����Ƿ��λ

  InitSamples;
  //��ʼ������

  if not FPoundTunnel.FUserInput then
  if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
         OnPoundDataEvent, True) then
  begin
    nHint := '���ӵذ���ͷʧ�ܣ�����ϵ����Ա���Ӳ������';
    WriteSysLog(nHint);

    nVoice := nHint;
    PlayVoice(nVoice);
    
    SetUIData(True);
    Exit;
  end;

  Timer_ReadCard.Enabled := False;
  FDoneEmptyPoundInit := 0;
  FIsWeighting := True;
  //ֹͣ����,��ʼ����

  if FBarrierGate then
  begin
    nStr := '[n1]%sˢ���ɹ����ϰ�,��Ϩ��ͣ��';
    nStr := Format(nStr, [FUIData.FTruck]);
    PlayVoice(nStr);
    //�����ɹ���������ʾ

    {$IFNDEF DEBUG}
    OpenDoorByReader(FLastReader);
    //������բ

    for nIDxEx := 0 to 1 do
    begin
      OpenDoorByReader(FLastReader);
      Sleep(500);
      Application.ProcessMessages;
    end;
    {$ENDIF}
  end;  
  //�����ϰ�
end;

function TfFrameAutoPoundItem.CheckTruckMValue(
  const nTruck: string): Boolean;
var nStr, nStatus: string;
    nVal: Double;
begin
  Result := True;
  nStr   := ' Select T_MValueMax From %s Where T_Truck=''%s'' ';
  nStr   := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr),FUIData do
  if RecordCount > 0 then
  begin
    nVal := Fields[0].AsFloat;
    if nVal <= 0 then Exit;

    Result := nVal >= FUIData.FMData.FValue;
    if Result then Exit;

    nStr := '����[ %s ]�س���������,��������:' + #13#10 +
            '��.ë������: %.2f��' + #13#10 +
            '��.��ǰë��: %.2f��' + #13#10 +
            '��.�� �� ��: %.2f��' + #13#10 +
            '�Ƿ��������?';
    nStr := Format(nStr, [FTruck, nVal, FMData.FValue, FMData.FValue-nVal]);

    Result := VerifyManualEventRecord(FID + sFlag_ManualF, nStr, sFlag_Yes, False);
    if Result then Exit; //����Ա����

    AddManualEventRecord(FID + sFlag_ManualF, FTruck, nStr, sFlag_DepBangFang,
      sFlag_Solution_YN, sFlag_DepDaTing, True);
    WriteSysLog(nStr);

    {$IFDEF AllowMultiM}//ɢװ�����ι���ʱ��������ë�����޺���У������״̬
    if FType = sFlag_Dai then
      nStatus := sFlag_TruckZT
    else
      nStatus := sFlag_TruckFH;

    AdjustBillStatus(FID, nStatus, sFlag_TruckBFM);

    nStr := '�����[%s]����[%s]״̬У��Ϊ:��ǰ״̬[%s],��һ״̬[%s]';
    nStr := Format(nStr, [FID, FTruck, nStatus, sFlag_TruckBFM]);
    WriteSysLog(nStr);
    {$ENDIF}

    nStr := '[n1]%së��%.2f��,�뷵��ж��.';
    nStr := Format(nStr, [FTruck, FMData.FValue]);
    PlayVoice(nStr);

    nStr := GetTruckNO(FTruck) + '�뷵��ж��';
    LEDDisplay(nStr);
  end;
end;

end.
