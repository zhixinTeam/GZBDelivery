{*******************************************************************************
  ����: dmzn@163.com 2012-4-22
  ����: Ӳ������ҵ��
*******************************************************************************}
unit UHardBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, UMgrDBConn, UMgrParam, DB,
  UBusinessWorker, UBusinessConst, UBusinessPacker, UMgrQueue, UMITConst,
  UMgrHardHelper, U02NReader, UMgrERelay,UFormCtrl,
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF} UMgrRemotePrint,
  UMgrLEDDisp, UMgrRFID102, UBlueReader, UMgrTTCEM100, UPurWebOrders,
  UMgrTTCEK720, UMgrVoiceNet, UMgrTTCEDispenser, UMgrSendCardNo, UMgrBXFontCard;

const
  sBlueCard  = 'bluecard';
  sHyCard    = 'hycard';
  
type

  PZTBDSet = ^TZTBDSet;
  TZTBDSet = record
    FCompensateDai: Integer;
    FOwnBD: Integer;
    FLastBD: Integer;
    FLastPCode: string;
  end;
const
  cSizeZTBDSet       = SizeOf(TZTBDSet);

procedure WhenReaderCardArrived(const nReader: THHReaderItem);
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
procedure WhenTTCE_K720_ReadCard(const nItem: PK720ReaderItem);

procedure WhenTTCE_K720_ReadCardByTTCEDispenser(const nItem: PDispenserItem);
//���������Զ�����(�°�����)
function DoTTCEDispenserIssCard(const nItem: PDispenserItem): Boolean;
//���ӱ�ǩ����(�°�����)
function DoTruckSnapInfo(const nCard:string; nList:TStringList):Boolean;
//���ӱ�ǩ����ǩ�������͵�С��չʾ
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
procedure WhenBlueReaderCardArrived(nHost: TBlueReaderHost; nCard: TBlueReaderCard);
//���¿��ŵ����ͷ
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
//�ֳ���ͷ���¿���
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
//�ֳ���ͷ���ų�ʱ
procedure WhenBusinessMITSharedDataIn(const nData: string);
//ҵ���м����������
function GetStockType(nBill: string):string;
//��ȡƷ�ּ��
function GetJSTruck(const nTruck,nBill: string): string;
//��ȡ��������ʾ����
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
//����������

//������Ϣ��΢��ƽ̨
procedure SendMsgToWebMall(const nLid:string;const MsgType:Integer;
                           const nBillType:string;const nWOID:string='');

//������Ϣ
function Do_send_event_msg(const nXmlStr: string): string;

//�޸����϶���״̬
procedure ModifyWebOrderStatus(const nType,nLId,nSender,nDesc:string;
 nStatus:Integer=c_WeChatStatusFinished;const AWebOrderID:string='');
//�޸����϶���״̬
function Do_ModifyWebOrderStatus(const nXmlStr: string): string;

procedure LEDDisplayNew(const nTunnel: string; nContent: string = '';
                     nTitle: string = '');
function SaveBusinessCardInfo(const nTruck,nCard,nBill,nLine: string): Boolean;

implementation

uses
  ULibFun, USysDB, USysLoger, UTaskMonitor, UWorkerBusinessCommand;

const
  sPost_In   = 'in';
  sPost_Out  = 'out';

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
function CallBusinessCommand(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessSaleBill(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessSaleBill);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2018-08-18
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���(����)
function CallBusinessSaleBillSingle(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessSaleBillSingle);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2015-08-06
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessPurchaseOrder(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessPurchaseOrder);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Desc: �����м���ϵĲɹ����ݶ���
function CallBusinessPurchaseOrderSingle(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessPurchaseOrderSingle);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2016-06-02
//Parm: ����;����;����;���
//Desc: �����м���ϵĶ̵����ݶ���
function CallBusinessDuanDao(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessDuanDao);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-10-16
//Parm: ����;����;����;���
//Desc: ����Ӳ���ػ��ϵ�ҵ�����
function CallHardwareCommand(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_HardwareCommand);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-3-23
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingBills(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2014-09-18
//Parm: ��λ;�������б�
//Desc: ����nPost��λ�ϵĽ���������
function SaveLadingBills(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2018-08-18
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�(����)
function GetLadingBillsSingle(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBillSingle(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2018-08-18
//Parm: ��λ;�������б�
//Desc: ����nPost��λ�ϵĽ���������(����)
function SaveLadingBillsSingle(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBillSingle(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: �ſ���
//Desc: ��ȡ�ſ�ʹ������
function GetCardUsed(const nCard: string; var nCardType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut);

  if Result then
       nCardType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2019-04-05
//Parm: �ſ���
//Desc: ��ȡ�ɹ���������
function GetOrderCType(const nCard: string; var nOrderCType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetOrderCType, nCard, '', @nOut);

  if Result then
       nOrderCType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2019-04-05
//Parm: �ſ���
//Desc: ��ȡ�̵���������
function GetDuanDaoCType(const nCard: string; var nOrderCType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetDuanDaoCType, nCard, '', @nOut);

  if Result then
       nOrderCType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2019-04-05
//Parm: ���ݺ� ����
//Desc: ��ȡ���������µ���Ϣ
function GetWebOrderID(const nID, nType: string; var nWebOrderID: string;
                       var nWeight: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetWebOrderID, nID, nType, @nOut);

  if Result then
  begin
    nWebOrderID := nOut.FData;
    nWeight     := nOut.FExtParam;
  end
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: �ſ���;��λ;�ɹ����б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingOrders(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2015-08-06
//Parm: ��λ;�ɹ����б�
//Desc: ����nPost��λ�ϵĲɹ�������
function SaveLadingOrders(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_SavePostOrders, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: ��λ;�ɹ����б�
//Desc: ����nPost��λ�ϵĲɹ�������
function SaveLadingOrders_KS(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_AlterPostOrders, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: �ſ���;��λ;�̵����б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ķ̵����б�
function GetDuanDaoItems(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2015-08-06
//Parm: ��λ;�̵����б�
//Desc: ����nPost��λ�ϵĶ̵�������
function SaveDuanDaoItems(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessDuanDao(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2013-07-21
//Parm: �¼�����;��λ��ʶ
//Desc:
procedure WriteHardHelperLog(const nEvent: string; nPost: string = '');
begin
  gSysLoger.AddLog(THardwareHelper, 'Ӳ���ػ�����', nEvent);
end;

procedure LEDDisplayNew(const nTunnel: string; nContent: string = '';
                     nTitle: string = '');
begin
  WriteHardHelperLog(Format('LEDDisplayNew:%s.Content:%s.Title:%s',
                          [nTunnel, nContent, nTitle]));
  if Trim(nTitle) = '' then
    nTitle := cBXDataNull;
  if Trim(nContent) = '' then
    nContent := cBXDataNull;
  gBXFontCardManager.Display(nTitle, nContent, nTunnel);
end;

//Date: 2016/5/5
//Parm: ���������
//Desc: ����������̧��
procedure BlueOpenDoor(const nReader: string;const nReaderType: string = '');
var nIdx: Integer;
begin
  nIdx := 0;
  if nReader <> '' then
  while nIdx < 5 do
  begin
    if nReaderType = sBlueCard then
    begin
      gHardwareHelper.OpenDoor(nReader);
      WriteHardHelperLog('����������̧��:' + nReader);
    end
    else
    if nReaderType = sHyCard then
    begin
      gHYReaderManager.OpenDoor(nReader);
      WriteHardHelperLog('���������̧��:' + nReader);
    end
    else
    begin
      if gHardwareHelper.ConnHelper then
           gHardwareHelper.OpenDoor(nReader)
      else gHYReaderManager.OpenDoor(nReader);
    end;
    
    Inc(nIdx);
  end;
end;

//Date: 2012-4-22
//Parm: ����
//Desc: ��nCard���н���
procedure MakeTruckIn(const nCard,nReader: string; const nDB: PDBWorker;
                      const nReaderType: string = '');
var nStr,nTruck,nCardType: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
    nRet: Boolean;
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('MakeTruckIn����.' + ':::Reader [ ' + nReader + ' ] ');
  {$ENDIF}
  if gTruckQueueManager.IsTruckAutoIn and (GetTickCount -
     gHardwareHelper.GetCardLastDone(nCard, nReader) < 2 * 60 * 1000) then
  begin
    gHardwareHelper.SetReaderCard(nReader, nCard);
    Exit;
  end; //ͬ��ͷͬ��,��2�����ڲ������ν���ҵ��.

  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;

  if nCardType = sFlag_Provide then
    nRet := GetLadingOrders(nCard, sFlag_TruckIn, nTrucks) else
  if nCardType = sFlag_Sale then
    nRet := GetLadingBills(nCard, sFlag_TruckIn, nTrucks) else
  if nCardType = sFlag_DuanDao then
    nRet := GetDuanDaoItems(nCard, sFlag_TruckIn, nTrucks) else
  if nCardType = sFlag_SaleSingle then
    nRet := GetLadingBillsSingle(nCard, sFlag_TruckIn, nTrucks) else nRet := False;

  if not nRet then
  begin
    nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    if nCardType = sFlag_DuanDao then
      gDisplayManager.Display(nReader, '�ſ���Ч');
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckNone) or (FStatus = sFlag_TruckIn) then Continue;
    //δ����,���ѽ���

    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],����ˢ����Ч.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if nTrucks[0].FStatus = sFlag_TruckIn then
  begin
    if gTruckQueueManager.IsTruckAutoIn then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
    end else
    begin
      if gTruckQueueManager.TruckReInfactFobidden(nTrucks[0].FTruck) or
         (nCardType <> sFlag_Sale) then
      begin
        BlueOpenDoor(nReader, nReaderType);
        //̧��

        nStr := '����[ %s ]�ٴ�̧�˲���.';
        nStr := Format(nStr, [nTrucks[0].FTruck]);
        WriteHardHelperLog(nStr, sPost_In);
      end;
    end;

    if nCardType = sFlag_DuanDao then
    begin
      nStr := '%s����';
      nStr := Format(nStr, [nTrucks[0].FTruck]);
      WriteHardHelperLog(nStr, sPost_In);
      gDisplayManager.Display(nReader, nStr);
    end;

    Exit;
  end;

  if (nCardType <> sFlag_Sale) and (nCardType <> sFlag_SaleSingle) then
  begin
    if nCardType = sFlag_Provide then
      nRet := SaveLadingOrders(sFlag_TruckIn, nTrucks) else
    if nCardType = sFlag_DuanDao then
      nRet := SaveDuanDaoItems(sFlag_TruckIn, nTrucks) else nRet := False;
    //xxxxx

    if not nRet then
    begin
      nStr := '����[ %s ]��������ʧ��.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;

    if gTruckQueueManager.IsTruckAutoIn then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
    end else
    begin
      BlueOpenDoor(nReader, nReaderType);
      //̧��
    end;

    nStr := '%s�ſ�[%s]����̧�˳ɹ�';
    nStr := Format(nStr, [BusinessToStr(nCardType), nCard]);
    WriteHardHelperLog(nStr, sPost_In);

    if nCardType = sFlag_DuanDao then
    begin
      nStr := '%s����';
      nStr := Format(nStr, [nTrucks[0].FTruck]);
      WriteHardHelperLog(nStr, sPost_In);
      gDisplayManager.Display(nReader, nStr);
    end;

    Exit;
  end;
  //�����۴ſ�ֱ��̧��

  nPLine := nil;
  //nPTruck := nil;

  with gTruckQueueManager do
  if not IsDelayQueue then //����ʱ����(����ģʽ)
  try
    SyncLock.Enter;
    nStr := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nInt := TruckInLine(nStr, PLineItem(Lines[nIdx]).FTrucks);
      if nInt >= 0 then
      begin
        nPLine := Lines[nIdx];
        //nPTruck := nPLine.FTrucks[nInt];
        Break;
      end;
    end;

    if not Assigned(nPLine) then
    begin
      nStr := '����[ %s ]û���ڵ��ȶ�����.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;
  finally
    SyncLock.Leave;
  end;

  if nCardType = sFlag_SaleSingle then
    nRet := SaveLadingBillsSingle(sFlag_TruckIn, nTrucks)
  else
    nRet := SaveLadingBills(sFlag_TruckIn, nTrucks);

  if not nRet then
  begin
    nStr := '����[ %s ]��������ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  with gTruckQueueManager do
  if not IsDelayQueue then //����ģʽ,����ʱ�󶨵���(һ���൥)
  try
    SyncLock.Enter;
    nTruck := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nPLine := Lines[nIdx];
      nInt := TruckInLine(nTruck, PLineItem(Lines[nIdx]).FTrucks);

      if nInt < 0 then Continue;
      nPTruck := nPLine.FTrucks[nInt];

      nStr := 'Update %s Set T_Line=''%s'',T_PeerWeight=%d Where T_Bill=''%s''';
      nStr := Format(nStr, [sTable_ZTTrucks, nPLine.FLineID, nPLine.FPeerWeight,
              nPTruck.FBill]);
      //xxxxx

      gDBConnManager.WorkerExec(nDB, nStr);
      //��ͨ��
    end;
  finally
    SyncLock.Leave;
  end;

  if gTruckQueueManager.IsTruckAutoIn then
  begin
    gHardwareHelper.SetCardLastDone(nCard, nReader);
    gHardwareHelper.SetReaderCard(nReader, nCard);
  end else
  begin
    BlueOpenDoor(nReader, nReaderType);
    //̧��
  end;
end;

procedure SendMsgToWebMall(const nLid:string;const MsgType:Integer;
                           const nBillType:string;const nWOID:string='');
var nBills: TLadingBillItems;
    nXmlStr,nData:string;
    nIdx:Integer;
    nNetWeight:Double;
    nTransName:string;
    nWebOrderId, nSQL, nWeight:string;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  {$IFNDEF EnableWebMall}
  Exit;
  {$ENDIF}

  if (nBillType=sFlag_Sale) or (nBillType=sFlag_SaleSingle) then
  begin
    //�����������Ϣ
    if not GetLadingBills(nLid, sFlag_BillDone, nBills) then
    begin
      Exit;
    end;
  end
  else if nBillType=sFlag_Provide then
  begin
    //���زɹ�������Ϣ
    if not GetLadingOrders(nLid, sFlag_BillDone, nBills) then
    begin
      Exit;
    end;
  end
  else begin
    Exit;
  end;

  nWebOrderId := nWOID;
  if nWebOrderId = '' then
  begin
    GetWebOrderID(nLid,nBillType,nWebOrderId,nWeight);
  end;

  if nWebOrderId='' then Exit;

  for nIdx := Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    nTransName := Ftransname;
    if nTransName = '' then nTransName := '-1';
    nNetWeight := FValue;
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
        +'	      <TransName>%s</TransName>'
        +'	      <NetWeight>%f</NetWeight>'
        +'	      <Searial>%s</Searial>'
        +'	      <OutFact></OutFact>'
        +'	      <OutMan></OutMan>'
        +'	      <OrderNo>%s</OrderNo>'
        +'	  </Item>	'
        +'</Items>'
        +'   <remark/>'
        +'</DATA>';
    nXmlStr := Format(nXmlStr,[gSysParam.FFactory, FCusID, MsgType,//cSendWeChatMsgType_DelBill,
               FID, FCard, FTruck, FStockNo, FStockName, FCusID,
               FCusName, nTransName, nNetWeight, Fworkaddr, nWebOrderId]);
    nXmlStr := PackerEncodeStr(nXmlStr);

    {$IFDEF MicroMsgDelaySend}
    nData := '΢����Ϣ�ӳ�����';
    {$ELSE}
    nData := Do_send_event_msg(nXmlStr);
    {$ENDIF}


    nList := TStringList.Create;
    try
      nList.Values['WXData'] := nXmlStr;

      if nData <> '' then
      begin
        WriteHardHelperLog(nData, sPost_Out);
        //loged

        with nList do
        begin
          Values['Type'] := nBillType;
          Values['Sender'] := '';
          Values['SenderDesc'] := '';
          Values['Key'] := nLId;
          Values['Business'] := IntToStr(cBC_WeChat_send_event_msg);
          //Values['WXData'] := nXmlStr;
        end;

        TWorkerBusinessCommander.CallMe(cBC_WeChat_SaveAutoSync,
          PackerEncodeStr(nList.Text), '', @nOut);
        //save autuo sync
      end;
    finally
      nList.Free;
    end;
  end;
end;

//������Ϣ
function Do_send_event_msg(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if TWorkerBusinessCommander.CallMe(cBC_WeChat_send_event_msg, nXmlStr, '', @nOut) then
       Result := nOut.FData
  else WriteHardHelperLog(nOut.FData);
end;

//�޸����϶���״̬
procedure ModifyWebOrderStatus(const nType,nLId,nSender,nDesc:string;
  nStatus:Integer;const AWebOrderID:string);
var
  nXmlStr,nData,nSql:string;
  nWebOrderId:string;
  nIdx:Integer;
  FNetWeight:Double;
  nWeight: string;
  nList: TStrings;
  nOut: TWorkerBusinessCommand;
begin
  {$IFNDEF EnableWebMall}
  Exit;
  {$ENDIF}

  FNetWeight := 0;
  nWebOrderId := AWebOrderID;
  nWeight := '';
//  {$IFNDEF GZBXS}
  if nWebOrderId='' then//������ִ�� ����ִ��
//  {$ENDIF}
  begin
    GetWebOrderID(nLId,nType,nWebOrderId,nWeight);
    FNetWeight := StrToFloatDef(nWeight, 0);
  end;

  if (nType = sFlag_Sale) or (nType = sFlag_SaleSingle) then
  begin
    WriteHardHelperLog('��������״̬,΢�ŵ��ݺ�: ' + nWebOrderId);
  end else
  if nType = sFlag_Provide then
  begin
    WriteHardHelperLog('���²ɹ�״̬,΢�ŵ��ݺ�: ' + nWebOrderId);
  end;

  if nWebOrderId='' then Exit;

  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
            +'<DATA>'
            +'<head><ordernumber>%s</ordernumber>'
            +'<status>%d</status>'
            +'<NetWeight>%f</NetWeight>'
            +'</head>'
            +'</DATA>';
  nXmlStr := Format(nXmlStr,[nWebOrderId,nStatus,FNetWeight]);
  nXmlStr := PackerEncodeStr(nXmlStr);

  nList := TStringList.Create;
  try
    nList.Values['WXData'] := nXmlStr;
    {$IFDEF MicroMsgDelaySend}
    nData := '΢��״̬�ӳ�����';
    {$ELSE}
    nData := Do_ModifyWebOrderStatus(nXmlStr);
    {$ENDIF}

    if nData <> '' then
    begin
      WriteHardHelperLog(nData, sPost_Out);
      //loged
      
      with nList do
      begin
        Values['Type'] := nType;
        Values['Sender'] := nSender;
        Values['SenderDesc'] := nDesc;
        Values['Key'] := nLId;
        Values['Business'] := IntToStr(cBC_WeChat_complete_shoporders);
        //Values['WXData'] := nXmlStr;
      end;

      TWorkerBusinessCommander.CallMe(cBC_WeChat_SaveAutoSync,
        PackerEncodeStr(nList.Text), '', @nOut);
      //save autuo sync
    end;
  finally
    nList.Free;
  end;
end;

//�޸����϶���״̬
function Do_ModifyWebOrderStatus(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if not TWorkerBusinessCommander.CallMe(cBC_WeChat_complete_shoporders, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//Date: 2012-4-22
//Parm: ����;��ͷ;��ӡ��;���鵥��ӡ��
//Desc: ��nCard���г���
procedure MakeTruckOut(const nCard,nReader,nPrinter: string;
  const nHYPrinter: string = '';const nReaderType: string = '');
var nStr,nCardType: string;
    nIdx: Integer;
    nRet: Boolean;
    nTrucks: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('MakeTruckOut����.' + ':::Reader [ ' + nReader + ' ] ');
  {$ENDIF}

  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;

  if nCardType = sFlag_Provide then
    nRet := GetLadingOrders(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Sale then
    nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_DuanDao then
    nRet := GetDuanDaoItems(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_SaleSingle then
    nRet := GetLadingBillsSingle(nCard, sFlag_TruckIn, nTrucks) else nRet := False;

  if not nRet then
  begin
    nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    if nCardType = sFlag_DuanDao then
      gDisplayManager.Display(nReader, '�ſ���Ч');
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�����.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if nCardType = sFlag_Provide then
    nRet := SaveLadingOrders(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Sale then
    nRet := SaveLadingBills(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_SaleSingle then
    nRet := SaveLadingBillsSingle(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_DuanDao then
    nRet := SaveDuanDaoItems(sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    nStr := '����[ %s ]��������ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  BlueOpenDoor(nReader, nReaderType);
  //̧��
  //����΢���̳�
  if nCardType = sFlag_Provide then
    SendMsgToWebMall(nTrucks[0].FZhiKa,cSendWeChatMsgType_OutFactory,nCardType)
  else
  begin
    if Length(Trim(nTrucks[0].FDispatchNo)) < 1 then
    begin
      SendMsgToWebMall(nTrucks[0].FID,cSendWeChatMsgType_OutFactory,nCardType);
    end;
  end;
  //����һ�δ�ӡ

  //for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[0] do
  begin
    {$IFDEF PrintBillMoney}
    if CallBusinessCommand(cBC_GetZhiKaMoney, FZhiKa,'',@nOut) then
         nStr := #8 + nOut.FData
    else nStr := #8 + '0';
    {$ELSE}
    nStr := '';
    {$ENDIF}

    if nCardType = sFlag_SaleSingle then
      nStr := nStr + #7 + sFlag_Sale
    else
      nStr := nStr + #7 + nCardType;
    //�ſ�����

    {$IFDEF PrintHYEach}
    if Trim(FHYDan) <> '' then
    begin
      if CallBusinessCommand(cBC_SyncYTBatchCodeInfo, FHYDan,'',@nOut) then
      begin
        if nHYPrinter <> '' then
          nStr := nStr + #6 + nHYPrinter;
        //���鵥��ӡ��
      end
      else
      begin
        nStr := '����[ %s ]����[ %s ]ͬ�����컯�鵥[ %s ]��Ϣʧ��.';
        nStr := Format(nStr, [FTruck, FID, FHYDan]);

        WriteHardHelperLog(nStr, sPost_Out);
      end;
    end;
    {$ELSE}
    if nHYPrinter <> '' then
      nStr := nStr + #6 + nHYPrinter;
    //���鵥��ӡ��
    {$ENDIF}

    if nPrinter = '' then
         gRemotePrinter.PrintBill(FID + nStr)
    else gRemotePrinter.PrintBill(FID + #9 + nPrinter + nStr); //��ӡ����

    if nCardType = sFlag_Provide then
         ModifyWebOrderStatus(nCardType, FZhiKa, 'MakeTruckOut', 'ˢ������')
    else
    begin
      if Length(Trim(nTrucks[0].FDispatchNo)) < 1 then
        ModifyWebOrderStatus(nCardType, FID, 'MakeTruckOut', 'ˢ������');
    end;
  end;

  if nCardType = sFlag_DuanDao then
  begin
    nStr := '%s����';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    gDisplayManager.Display(nReader, nStr);
  end;
end;

//Date: 2016-5-4
//Parm: ����;��ͷ;��ӡ��;���鵥��ӡ��
//Desc: ��nCard���г�
function MakeTruckOutM100(var nCType: string;const nCard,nReader,nPrinter: string;
  const nHYPrinter: string = '';const nReaderType: string = ''): Boolean;
var nStr,nCardType: string;
    nIdx: Integer;
    nRet: Boolean;
    nTrucks: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;
  nCType := nCardType;
  if nCardType = sFlag_Provide then
    nRet := GetLadingOrders(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Sale then
    nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_DuanDao then
    nRet := GetDuanDaoItems(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_SaleSingle then
    nRet := GetLadingBillsSingle(nCard, sFlag_TruckIn, nTrucks) else nRet := False;

  if not nRet then
  begin
    nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);
    Result := True;
    //�ſ�����Ч

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);
    Result := True;
    //�ſ�����Ч

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�����.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if nCardType = sFlag_Provide then
    nRet := SaveLadingOrders(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Sale then
    nRet := SaveLadingBills(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_SaleSingle then
    nRet := SaveLadingBillsSingle(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_DuanDao then
    nRet := SaveDuanDaoItems(sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    nStr := '����[ %s ]��������ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  BlueOpenDoor(nReader, nReaderType);
  //̧��
  //����΢���̳�
  if nCardType = sFlag_Provide then
    SendMsgToWebMall(nTrucks[0].FZhiKa,cSendWeChatMsgType_OutFactory,nCardType)
  else
  begin
    if Length(Trim(nTrucks[0].FDispatchNo)) < 1 then
    begin
      SendMsgToWebMall(nTrucks[0].FID,cSendWeChatMsgType_OutFactory,nCardType);
    end;
  end;
  //����һ�δ�ӡ

  {$IFDEF PrintHYEach}
  with nTrucks[0] do
  begin
    if Trim(FHYDan) <> '' then
    begin
      if not CallBusinessCommand(cBC_SyncYTBatchCodeInfo, FHYDan,'',@nOut) then
      begin
        nStr := '����[ %s ]����[ %s ]ͬ�����컯�鵥[ %s ]��Ϣʧ��.';
        nStr := Format(nStr, [FTruck, FID, FHYDan]);

        WriteHardHelperLog(nStr, sPost_Out);
      end;
    end;
  end;
  {$ENDIF}

  //for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[0] do
  begin
    {$IFDEF PrintBillMoney}
    if CallBusinessCommand(cBC_GetZhiKaMoney, FZhiKa,'',@nOut) then
         nStr := #8 + nOut.FData
    else nStr := #8 + '0';
    {$ELSE}
    nStr := '';
    {$ENDIF}

    if nCardType = sFlag_SaleSingle then
      nStr := nStr + #7 + sFlag_Sale
    else
      nStr := nStr + #7 + nCardType;
    //�ſ�����

    if nHYPrinter <> '' then
      nStr := nStr + #6 + nHYPrinter;
    //���鵥��ӡ��

    if nPrinter = '' then
         gRemotePrinter.PrintBill(FID + nStr)
    else gRemotePrinter.PrintBill(FID + #9 + nPrinter + nStr);

    if nCardType = sFlag_Provide then
         ModifyWebOrderStatus(nCardType, FZhiKa, 'MakeTruckOutM100', 'ˢ������')
    else
    begin
      if Length(Trim(nTrucks[0].FDispatchNo)) < 1 then
      begin
        ModifyWebOrderStatus(nCardType, FID, 'MakeTruckOutM100', 'ˢ������');
      end;
    end;
  end;
  //��ӡ����

  Result := True;
end;

//Date: 2012-10-19
//Parm: ����;��ͷ
//Desc: ��⳵���Ƿ��ڶ�����,�����Ƿ�̧��
procedure MakeTruckPassGate(const nCard,nReader: string; const nDB: PDBWorker;
                            const nReaderType: string = '');
var nStr: string;
    nIdx: Integer;
    nTrucks: TLadingBillItems;
begin
  if not GetLadingBills(nCard, sFlag_TruckOut, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫͨ����բ�ĳ���.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if gTruckQueueManager.TruckInQueue(nTrucks[0].FTruck) < 0 then
  begin
    nStr := '����[ %s ]���ڶ���,��ֹͨ����բ.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  BlueOpenDoor(nReader, nReaderType);
  //̧��

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    nStr := 'Update %s Set T_InLade=%s Where T_Bill=''%s'' And T_InLade Is Null';
    nStr := Format(nStr, [sTable_ZTTrucks, sField_SQLServer_Now, nTrucks[nIdx].FID]);

    gDBConnManager.WorkerExec(nDB, nStr);
    //�������ʱ��,�������򽫲��ٽк�.
  end;
end;

//Date: 2019-10-26
//Parm: ����;��ͷ
//Desc: ̧��ͬʱ���ɹ�բ��¼
procedure MakeTruckPassGateEx(const nCard, nReader : string; const nDB: PDBWorker;
                            const nReaderType: string = '');
var nStr: string;
    nMaxNum,nIdx: Integer;
    nTruck: string;
    nLastTime: TDateTime;
    nCanSave,nAdd,nOpenDoor: Boolean;
    nCardEx: string;
    FList: TStrings;
begin
  nCanSave := False;
  nOpenDoor:= False;
  nAdd     := True;
  nMaxNum  := 3;
  FList:=TStringList.Create;
  try
    nStr := ' Update %s Set C_State = ''2'' Where (%s - C_InDate >= 2) ';
    nStr := Format(nStr, [sTable_CardMT, sField_SQLServer_Now]);
    gDBConnManager.WorkerExec(nDB, nStr); //����������³��ѳ���
    
    SplitStr(nCard, FList, 0, ',', False);

    for nIdx := 0 to FList.Count - 1 do
    begin
      nCardEx := Copy(FList[nIDx],2,MaxInt);
      nStr := ' Select T_Truck, T_Card from %s where T_Card like ''%%%s%%'' and T_CardUse=''Y''';
      nStr := Format(nStr,[sTable_Truck, nCardEx]);
      with gDBConnManager.WorkerQuery(nDB, nStr) do
      begin
        if RecordCount <= 0 then
        begin
          nStr := '���ӱ�ǩ[ %s ]�޶�Ӧ�ĳ�����.';
          nStr := Format(nStr, [nCardEx]);

          WriteHardHelperLog(nStr);
          Continue;
        end;
        nTruck := Fields[0].AsString;
        nCardEx:= Fields[1].AsString;
      end;

      nStr := ' Select D_Value from %s where D_Name=''%s''';
      nStr := Format(nStr,[sTable_SysDict, 'MTMaxTruckNum']);
      with gDBConnManager.WorkerQuery(nDB, nStr) do
      begin
        if RecordCount > 0 then
        begin
          nMaxNum := Fields[0].AsInteger;
        end;
      end;

      nStr := ' Select distinct C_Card from %s where C_State=''1'' ';
      nStr := Format(nStr,[sTable_CardMT]);
      with gDBConnManager.WorkerQuery(nDB, nStr) do
      begin
        if RecordCount < nMaxNum then
        begin
           nCanSave := True;
        end;
      end;

      nStr := ' Select distinct C_Card from %s where C_Card=''%s'' ';
      nStr := Format(nStr,[sTable_CardMT,nCardEx]);
      with gDBConnManager.WorkerQuery(nDB, nStr) do
      begin
        if RecordCount > 0 then
        begin
          nAdd := False;
        end;
      end;

      if not nCanSave then
      begin
        nStr := '���ڳ����Ѵ�������������:' + inttostr(nMaxNum);

        WriteHardHelperLog(nStr);
        Exit;
      end;
      if nAdd = True then
      begin
        nStr := MakeSQLByStr([SF('C_Card', nCardEx),
                SF('C_Truck', nTruck),
                SF('C_State', '1'),
                SF('C_InDate', sField_SQLServer_Now, sfVal)
                ], sTable_CardMT, '', True);
        gDBConnManager.WorkerExec(nDB, nStr);
        nOpenDoor := True;
      end
      else
      begin
        nStr := Format('C_Card = ''%s''', [nCardEx]);
        nStr := MakeSQLByStr([
                SF('C_Truck', nTruck),
                SF('C_State', '1'),
                SF('C_InDate', sField_SQLServer_Now, sfVal)
                ], sTable_CardMT, nStr, False);
        gDBConnManager.WorkerExec(nDB, nStr);
        nOpenDoor := True;
      end;
    end;
    if nOpenDoor then
    begin
      BlueOpenDoor(nReader, nReaderType);
      //̧��
    end;
  finally
    FList.Free;
  end;
end;

//Date: 2019-10-26
//Parm: ����;��ͷ
//Desc: ̧��ͬʱ���ɹ�բ��¼
procedure MakeTruckPassGateOut(const nCard, nReader : string; const nDB: PDBWorker;
                            const nReaderType: string = '');
var nStr: string;
    nTruck: string;
    nLastTime: TDateTime;
    nOpenDoor: Boolean;
    nIdx: Integer;
    nCardEx: string;
    FList: TStrings;
begin
  nOpenDoor:= False;

  FList:=TStringList.Create;
  try
    SplitStr(nCard, FList, 0, ',', False);

    for nIdx := 0 to FList.Count - 1 do
    begin
      nCardEx := Copy(FList[nIDx],2,MaxInt);

      nStr := ' Select distinct C_Card from %s where C_Card=''%s'' ';
      nStr := Format(nStr,[sTable_CardMT,nCardEx]);
      with gDBConnManager.WorkerQuery(nDB, nStr) do
      begin
        if RecordCount > 0 then
        begin
          nOpenDoor := True;
        end;
      end;

      nStr := Format('C_Card = ''%s''', [nCardEx]);
      nStr := MakeSQLByStr([
              SF('C_State', '2'),
              SF('C_OutDate', sField_SQLServer_Now, sfVal)
              ], sTable_CardMT, nStr, False);
      gDBConnManager.WorkerExec(nDB, nStr);
    end;
    if nOpenDoor then
    begin
      BlueOpenDoor(nReader, nReaderType);
      //̧��
    end;
  finally
    FList.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure WriteNearReaderLog(const nEvent: string);
begin
  gSysLoger.AddLog(T02NReader, '�ֳ����������', nEvent);
end;

//Date: 2018-11-26
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ��ж������
function MakeTruckYSStockTunnel(const nCard,nTunnel,nCardType: string) : Boolean;
var nStr, nStockNo, nStockName : string;
    nIdx,i: Integer;
    nTrucks: TLadingBillItems;
    nDBConn: PDBWorker;
begin
  WriteNearReaderLog('MakeTruckYSStockTunnel����.'+' �ſ�:'+nCard+' ͨ����'+nTunnel);

  Result := False;
  if nCardType = sFlag_Provide then
    Result := GetLadingOrders(nCard, 'X', nTrucks);

  if not Result then
  begin
    nStr := '��ȡ�ſ�[ %s ]ҵ�񵥾���Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    {$IFDEF StockTunnel}
     {$IFDEF LedNew}
     LEDDisplayNew(nTunnel, '', '�ſ���Ч');
     {$ELSE}
     gDisplayManager.Display(nTunnel, '�ſ���Ч');
     {$ENDIF}
    {$ENDIF}
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û�ж�Ӧ������Ϣ.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    {$IFDEF StockTunnel}
     {$IFDEF LedNew}
     LEDDisplayNew(nTunnel, '', '�ſ���Ч');
     {$ELSE}
     gDisplayManager.Display(nTunnel, '�ſ���Ч');
     {$ENDIF}
    {$ENDIF}
    Exit;
  end;

  for nIdx := Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FNextStatus='X') or (FNextStatus='M') then Continue;
    //δװ����װ

    nStr := nTrucks[0].FTruck + '״̬'+ FNextStatus +'��������';
    WriteNearReaderLog(nStr);
    Exit;
  end;

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db
    nStr := ' Select D_ParamB From %s Where D_Name=''%s'' And D_Value = ''%s'' ';
    nStr := Format(nStr, [sTable_SysDict, 'StockTunnel',nTunnel]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    begin
      if RecordCount > 0 then
      begin
        nStockNo   := Fields[0].AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;

  if Trim(nTrucks[0].FStockNo) <> nStockNo then
  begin
    Result := False;

    nStr := '����Ʒ��:'+ nTrucks[0].FStockNo + '���Ʒ��'+ nStockNo +'��ͬ';
    WriteNearReaderLog(nStr);
    Exit; 
  end;

  with nTrucks[0] do
  begin
    FYSValid  := 'Y';
    FKZValue  :=  0;
    FMemo     := 'ˢ���Զ�����';
  end;
  
  if nCardType = sFlag_Provide then
    Result := SaveLadingOrders('X', nTrucks);
  if not Result then
  begin
    nStr := '����[ %s ]����ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  nStr := nTrucks[0].FTruck + StringOfChar(' ', 12 - Length(nTrucks[0].FTruck));
  nStr := nStr + nTrucks[0].FStockName;
  //xxxxx
 {$IFDEF LedNew}
  for i := 0 to 3 do
  begin
    LEDDisplayNew(nTunnel, '', nStr);
  end;
 {$ELSE}
   gDisplayManager.Display(nTunnel, nStr);
 {$ENDIF}
end;

//Date: 2012-4-22
//Parm: ��ͷ����
//Desc: ��nReader�����Ŀ��������嶯��
procedure WhenReaderCardArrived(const nReader: THHReaderItem);
var nStr,nSQL,nHYStr,nReaderType,nCard : string;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardArrived����.');
  {$ENDIF}

  {$IFDEF UseELableOpenDoor}
  if nReader.FType = rtGate then
  begin
    if Assigned(nReader.FOptions) then
         nReaderType := nReader.FOptions.Values['ReaderType']
    else nReaderType := '';

    if Assigned(nReader.FOptions) then
    begin
      WriteHardHelperLog('���ӱ�ǩ��:'+nReader.FCard);
      with gParamManager.ActiveParam^ do
      try
        nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
        if not Assigned(nDBConn) then
        begin
          WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
          Exit;
        end;

        if not nDBConn.FConn.Connected then
          nDBConn.FConn.Connected := True;

        nStr := 'Select * From $TB Where T_Truck=''$CD'' ';
        nStr := MacroValue(nStr, [MI('$TB', sTable_Truck), MI('$CD', nReader.FCard)]);

        with gDBConnManager.WorkerQuery(nDBConn, nStr) do
        if RecordCount > 0 then
        begin
          //
        end;
          
        if nReader.FOptions.Values['CardIn'] = sFlag_Yes then
        begin
          MakeTruckPassGateEx(nReader.FCard, nReader.FID, nDBConn, nReaderType);
          Exit;
        end
        else if nReader.FOptions.Values['CardOut'] = sFlag_Yes then
        begin
          MakeTruckPassGateOut(nReader.FCard, nReader.FID, nDBConn, nReaderType);
          Exit;
        end;
      finally
        gDBConnManager.ReleaseConnection(nDBConn);
      end;
    end;
//    if nReader.FID <> '' then
//      BlueOpenDoor(nReader.FID, nReaderType);
    //̧��
   // Exit;
  end;
  {$ENDIF}

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db
      nStr := Format('�ſ���[ %s ]ͨ����[ %s ].', [nReader.FCard,nReader.FID]);
      WriteHardHelperLog(nStr);

    nStr := 'Select C_Card, C_Used From $TB Where C_Card=''$CD'' or ' +
            'C_Card2=''$CD'' or C_Card3=''$CD''';
    nStr := MacroValue(nStr, [MI('$TB', sTable_Card), MI('$CD', nReader.FCard)]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nCard:= Fields[0].AsString;
      nStr := Fields[0].AsString;

      {$IFDEF TruckInLoop}
      if Fields[1].AsString = sFlag_Provide then
      begin
        nSQL := 'Select O_CType From $TB Where O_Card=''$CD''';
        nSQL := MacroValue(nSQL, [MI('$TB', sTable_Order), MI('$CD', nStr)]);
        with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
        begin
          if RecordCount < 0 then
          begin
            nStr := Format('�ſ���[ %s ]ƥ��ʧ��.', [nReader.FCard]);
            WriteHardHelperLog(nStr);
            Exit;
          end;

          if (Copy(nReader.FID, 1, 1) = 'V') and
             (Fields[0].AsString = sFlag_OrderCardL) then
          begin
            nStr := 'ԭ������ʱ����ֹ�������.';
            WriteHardHelperLog(nStr);
            Exit;
          end;
        end;
      end else
      begin
        if Copy(nReader.FID, 1, 1) = 'V' then
        begin
          nStr := '��ԭ���Ϲ̶�����ֹ�������.';
          WriteHardHelperLog(nStr);
          Exit;
        end;
      end;
      {$ENDIF}
    end else
    begin
      nStr := Format('�ſ���[ %s ]ƥ��ʧ��.', [nReader.FCard]);
      WriteHardHelperLog(nStr);
      Exit;
    end;

    if Assigned(nReader.FOptions) then
         nReaderType := nReader.FOptions.Values['ReaderType']
    else nReaderType := '';
    {$IFDEF StockTunnel}
    if (Assigned(nReader.FOptions)) and
      (Trim(nReader.FOptions.Values['Tunnel']) <> '') then
    begin
      WriteHardHelperLog('��������Ӧͨ��:'+Trim(nReader.FOptions.Values['Tunnel']));
      if MakeTruckYSStockTunnel(nCard,Trim(nReader.FOptions.Values['Tunnel']),nReaderType) then
      begin
        if nReader.FID <> '' then
          BlueOpenDoor(nReader.FID, nReaderType);
        //̧��
      end;
    end;
    {$ENDIF}
    try
      if nReader.FType = rtIn then
      begin
        MakeTruckIn(nStr, nReader.FID, nDBConn, nReaderType);
      end else

      if nReader.FType = rtOut then
      begin
        if Assigned(nReader.FOptions) then
             nHYStr := nReader.FOptions.Values['HYPrinter']
        else nHYStr := '';
        MakeTruckOut(nStr, nReader.FID, nReader.FPrinter, nHYStr, nReaderType);
      end else

      if nReader.FType = rtGate then
      begin
        if nReader.FID <> '' then
          BlueOpenDoor(nReader.FID, nReaderType);
        //̧��
      end else

      if nReader.FType = rtQueueGate then
      begin
        if nReader.FID <> '' then
          MakeTruckPassGate(nStr, nReader.FID, nDBConn, nReaderType);
        //̧��
      end;
    except
      On E:Exception do
      begin
        WriteHardHelperLog(E.Message);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//��������
procedure PlayVoice(const nText:string);
begin
  gNetVoiceHelper.PlayVoice(nText);
end;

function SavePurchBillAutoOutCard(var nOrderFailed: Boolean;
                                  const nCard, nECard, nTunnel: string;
                                  const nID: string = ''):Boolean;
var
  nTruck, nStr, nStockName, nHint :string;
  nLen, nIdx: Integer;
  nWebOrderItem: TPurWebOrderItems;
  nList: TStrings;
  nOrder: string;
  nRet: Boolean;
  Amsg: string;
begin
  Result := False;
  nOrderFailed := False;
  nTruck := GetTruckNoByELabel(nECard);
  if nTruck = '' then
  begin
    nStr := '%s�ɹ����ӱ�ǩ��Ч';
    nStr := Format(nStr, [nECard]);
    WriteHardHelperLog(nStr);
    //PlayVoice(nStr);
    Exit;
  end;

  if Length(nTruck) < 3 then
  begin
    nStr := '���ƺ�%s���ȷǷ�';
    nStr := Format(nStr, [nTruck]);
    WriteHardHelperLog(nStr);
    PlayVoice(nStr);
    Exit;
  end;

  if not TruckMultipleCard(nTruck, nStr) then
  begin
    WriteHardHelperLog(nStr);
    PlayVoice(nStr);
    Exit;
  end;

  if not CheckSaveOrderOK(nTruck, nStr) then
  begin
    WriteHardHelperLog('   ' + nStr);
    PlayVoice(nStr);
    Exit;
  end;
  
  if not GetPurchWebOrders(nTruck) then
  begin
    nOrderFailed := True;
    nStr := '%s��ȡ�����µ���Ϣʧ��';
    nStr := Format(nStr, [nTruck]);
    WriteHardHelperLog(nStr);
    PlayVoice(nStr);
    Exit;
  end;

  nLen := Length(gPurWebOrderItems);
  if nLen > 0 then
  for nIdx := 0 to nLen - 1 do
  begin
    nWebOrderItem := gPurWebOrderItems[nIdx];
    if not CheckOrderValidate(nWebOrderItem) then
    begin
      nStr := '%sУ��ɹ���ͬ��Ч��ʧ��';
      nStr := Format(nStr, [nTruck]);
      WriteHardHelperLog(nStr);
      PlayVoice(nStr);
      Exit;
    end;
    //У�鹩Ӧ�̽���������
    {$IFDEF UseOrderDayNum}
      Amsg := '';
      if not GetDayNumInfo(nWebOrderItem.FGoodsID,nWebOrderItem.FProvID,Amsg) then
      begin
        nStr := '%s���ڲֿ������޷�����ж��';
        nStr := Format(nStr, [nTruck]);
        WriteHardHelperLog(nStr);
        PlayVoice(nStr);
        Exit;
      end;
      if Amsg <> '' then
      begin
        nStr := '%s�������ƽ���ʱ���ѹ�,�޷�����';
        nStr := Format(nStr, [nTruck]);
        WriteHardHelperLog(nStr);
        PlayVoice(nStr);
        Exit;
      end;
    {$ENDIF}
    nList := TStringList.Create;
    try
      with nList, nWebOrderItem do
      begin
        Values['SQID'] := Ffac_order_no;
        Values['Area'] := '';
        Values['Truck'] := Ftracknumber;
        Values['Project'] := Ffac_order_no;
        Values['CardType'] := sFlag_OrderCardL; 

        Values['ProviderID'] := FProvID;
        Values['ProviderName'] := FProvName;
        Values['StockNO'] := FGoodsID;
        Values['StockName'] := FGoodsname;
        Values['Value'] := FData;
    
        Values['WebOrderID'] := FOrdernumber;
        nStockName := Values['StockName'];
      end;

      nOrder := SaveOrder(PackerEncodeStr(nList.Text));
      if nOrder='' then
      begin
        nStr := '%s����ɹ���ʧ��';
        nStr := Format(nStr, [nTruck]);
        WriteHardHelperLog(nStr);
        Exit;
      end;

      SaveWebOrderMatch(nOrder, nWebOrderItem.FOrdernumber);
    finally
      nList.Free;
    end;
    WriteHardHelperLog('    ' + nOrder + '��ʼ���濨�ţ�' + nCard);
    nRet := SaveOrderCard(nOrder, nCard);
    if nRet then
    begin
      WriteHardHelperLog('    ' + nCard + '׼������');
      {$IFDEF UseTTCEDispenser}
      if not gDispenserManager.SendCardOut(nID, nHint) then
      {$ELSE}
      if not gK720ReaderManager.SendCardOutF(nTunnel) then
      {$ENDIF}
      begin
        nStr := '����%s�Զ�����ʧ��';
        nStr := Format(nStr, [nTruck]);
        WriteHardHelperLog(nStr + ':' + nHint);
        PlayVoice(nStr);
        Exit;
      end;
      nStr := 'Ʒ��%s����%s�����ɹ�������ȡ��';
      nStr := Format(nStr, [nStockName, nTruck]);
      WriteHardHelperLog(nStr);
      PlayVoice(nStr);
      Result := True;
    end;
  end;
end;

//Date: 2014-10-25
//Parm: ��ͷ����
//Desc: �����ͷ�ſ�����
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
var
  i, nIdx : Integer;
  nTruck, nStr, nTunnels, nTunnel :string;
  nItem: PDispenserItem;
  nList: TStringList;
  nBool: Boolean;
  nOut: TWorkerBusinessCommand;
begin
  //{$IFDEF DEBUG}
  if gSysParam.FHYReaderLog = 'Y' then
  begin
    WriteHardHelperLog(Format('�����ǩ %s:%s', [nReader.FTunnel, nReader.FCard]));
  end;
  //{$ENDIF}

  if Assigned(nReader.FOptions) then
  begin
    if nReader.FVirtual then
    begin
       case nReader.FVType of
       rt900 :
        gHardwareHelper.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard, False);
       rt02n :
        g02NReader.SetReaderCard(nReader.FHost, nReader.FCard);
       end;
    end else
    begin
      g02NReader.ActiveELabel(nReader.FTunnel, nReader.FCard);
      if nReader.FOptions.Values['Opendoor'] = 'Y' then
      begin
        gHYReaderManager.OpenDoor(nReader.FID);
      end;
      if nReader.FOptions.Values['TruckSnap'] = 'Y' then
      begin
        WriteHardHelperLog('���ӱ�ǩ��'+nReader.FCard);
        nBool    :=  CallBusinessSaleBill(cBC_AlterTruckSnap, nReader.FCard,'',@nOut);
        nTruck   := nOut.FData;
        if  Trim(nTruck) <> '' then
        begin
          nTunnels := nReader.FOptions.Values['tunnel'];
          nList := TStringList.Create;
          try
            nList.Text := StringReplace(nTunnels, ',', #13#10, [rfReplaceAll]);
            for nIdx := 0 to nList.Count - 1 do
            begin
              nTunnel := nList[nIdx];

              nStr := nTruck + StringOfChar(' ', 12 - Length(nTruck));
              nStr := nStr + 'ǩ���ɹ�';
              //xxxxx
             {$IFDEF LedNew}
              for i := 0 to 3 do
              begin
                LEDDisplayNew(nTunnel, '', nStr);
                WriteHardHelperLog(nStr);
              end;
             {$ELSE}
               gDisplayManager.Display(nTunnel, nStr);
             {$ENDIF}
            end;
         finally
           nList.Free;
         end;
       end;
      end;
    end;
    
    {$IFDEF PurELabelAutoCard}
    if (CompareText('NET', nReader.FOptions.Values['SendCard']) = 0) then
    begin
      {$IFDEF UseTTCEDispenser}
      nItem := gDispenserManager.FindDispenser(nReader.FOptions.Values['Dispenser']);

      if Assigned(nItem) then
      begin
        nItem.FOptions.Values['ELabelFCard'] := nReader.FCard;
        nItem.FOptions.Values['ELabelFTunnel'] := nReader.FTunnel;
        WriteHardHelperLog(Format('�����ǩ������[ %s ]SendCard %s:%s',
                                 [nItem.FID, nReader.FCard, nReader.FTunnel]));
        DoTTCEDispenserIssCard(nItem);
      end
      else
      begin
        WriteHardHelperLog(Format('�����ǩδ�ҵ�������[ %s ],�޷�ִ�з���ҵ��',
                                 [nItem.FID]));
      end;
      {$ELSE}
      gELabelFCard := nReader.FCard;
      gELabelFTunnel := nReader.FTunnel;
      WriteHardHelperLog(Format('�����ǩSendCard %s:%s', [gELabelFCard, gELabelFTunnel]));
      {$ENDIF}
    end;
    {$ENDIF}
  end else
  if nReader.FVirtual then
  begin
     case nReader.FVType of
     rt900 :
      gHardwareHelper.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard, False);
     rt02n :
      g02NReader.SetReaderCard(nReader.FHost, nReader.FCard);
     end;
  end else
  begin
    g02NReader.ActiveELabel(nReader.FTunnel, nReader.FCard);
    if nReader.FOptions.Values['Opendoor'] = 'Y' then
    begin
      gHYReaderManager.OpenDoor(nReader.FID);
    end;
  end;
end;

procedure WhenBlueReaderCardArrived(nHost: TBlueReaderHost; nCard: TBlueReaderCard);
begin
  {$IFDEF DEBUG}
  //WriteHardHelperLog(Format('���������� %s:%s', [nReader.FTunnel, nReader.FCard]));
  {$ENDIF}

  gHardwareHelper.SetReaderCard(nHost.FReaderID, nCard.FCard, False);
end;

//------------------------------------------------------------------------------
//Date: 2017/3/29
//Parm: ����һ������
//Desc: ��������һ��������Ϣ
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
var nStr: string;
    nRetain: Boolean;
    nCType,nOrderCType,nReaderType: string;
begin
  nRetain := False;
  //init

  {$IFDEF DEBUG}
  nStr := '����һ����������'  + nItem.FID + ' ::: ' + nItem.FCard;
  WriteHardHelperLog(nStr);
  {$ENDIF}

  if Assigned(nItem.FOptions) then
       nReaderType := nItem.FOptions.Values['ReaderType']
  else nReaderType := '';

  try
    if not nItem.FVirtual then Exit;
    case nItem.FVType of
    rtOutM100 :
    begin
      nRetain := MakeTruckOutM100(nCType,nItem.FCard, nItem.FVReader,
                                  nItem.FVPrinter, nItem.FVHYPrinter,nReaderType);

      if nCType = sFlag_Provide then
      begin
        GetOrderCType(nItem.FCard, nOrderCType);
        WriteHardHelperLog('�ɹ���������:' + nOrderCType);
        if nOrderCType = sFlag_OrderCardG then
          nRetain := False;
      end
      else if nCType = sFlag_DuanDao then
      begin
        GetDuanDaoCType(nItem.FCard, nOrderCType);
        WriteHardHelperLog('�̵���������:' + nOrderCType);
        if nOrderCType = sFlag_OrderCardG then
          nRetain := False;
      end;
      if nRetain then
        WriteHardHelperLog('�̿���ִ��״̬:'+'������:'+nCType+'����:�̿�')
      else
        WriteHardHelperLog('�̿���ִ��״̬:'+'������:'+nCType+'����:�̿����¿�');
    end
    else
      gHardwareHelper.SetReaderCard(nItem.FVReader, nItem.FCard, False);
    end;
  finally
    gM100ReaderManager.DealtWithCard(nItem, nRetain)
  end;
end;

//lih 2018-02-03
//���������Զ�����
procedure WhenTTCE_K720_ReadCard(const nItem: PK720ReaderItem);
var
  nStr, nCard, nECard, nETunnel: string;
  nLast: Int64;
  nGetPurFailed: Boolean;
begin
  //{$IFDEF DEBUG}
  nStr := '���緢����'  + nItem.FID + ' ::: ' + nItem.FCard;
  WriteHardHelperLog(nStr);
  //{$ENDIF}

  if nCard <> nItem.FCard then
  begin
    nCard := nItem.FCard;

    if not CheckCardOK(nCard, nStr) then
    begin
      WriteHardHelperLog(' ::: ' + nStr);
      PlayVoice(nStr);
      if gK720ReaderManager.RecoveryCardF(nItem.FTunnel) then
        WriteHardHelperLog(' ::: �ſ�' + nCard + '�������');
      Exit;
    end;

    if gECard <> gELabelFCard then
    begin
      gECard := gELabelFCard;//gELabelItem.FCard;
      nETunnel := gELabelFTunnel;//gELabelItem.FTunnel;
      WriteHardHelperLog(' ::: �ϴε��ӱ�ǩ��' + gLastECard + '   ��ǰ���ӱ�ǩ��' + gECard);

      nLast := Trunc((GetTickCount - gLastTime) / 1000);
      WriteHardHelperLog(' ::: ���ʱ����' + IntToStr(nLast) + 's');
      if (gECard = gLastECard) and (gLastTime <> 0) and (nLast < 300) then
      begin
        WriteHardHelperLog(' ::: ���ӱ�ǩ'+gECard+'��ȡ���ʱ��С��300s');
        gLastECard := gECard;
        gELabelFCard := '';
        gECard := '';
        Exit;
      end;
      
      if not SavePurchBillAutoOutCard(nGetPurFailed, nCard, gECard, nETunnel) then
      begin
        WriteHardHelperLog(' ::: ͨ��[' + nETunnel + ']ELabel: [' + gECard + ']����ʧ�ܣ�');
        gLastTime := GetTickCount;
        gLastECard := gECard;
        gECard := '';
        Exit;
      end;
      WriteHardHelperLog(' ::: ���ӱ�ǩ'+gECard+'ҵ�����');
      gLastTime := GetTickCount;
      gLastECard := gECard;
      gECard := '';
    end;
  end;
end;


// 2018-11-28
//���������Զ�����(�°�����)
procedure WhenTTCE_K720_ReadCardByTTCEDispenser(const nItem: PDispenserItem);
var
  nStr: string;
begin
  //{$IFDEF DEBUG}
  nStr := '���緢����'  + nItem.FID + ' ::: ' + nItem.FNowCard;
  WriteHardHelperLog(nStr);
  //{$ENDIF}
end;

//���ӱ�ǩ����ǩ�������͵�С��չʾ
function DoTruckSnapInfo(const nCard:string; nList:TStringList):Boolean;
var
  nSql: string;
begin
  //
end;

// 2018-11-29
//���ӱ�ǩ�Զ�����(�°�����)
function DoTTCEDispenserIssCard(const nItem: PDispenserItem): Boolean;
var
  nStr, nCard, nECard, nETunnel, nHint: string;
  nLast, nLastTime: Int64;
  nGetPurFailed : Boolean;
begin
  Result := False;

  if not Assigned(nItem.FOptions) then
  begin
    nStr := '���緢����'  + nItem.FID + ' ::: Option�ڵ�δ����' ;
    Exit;
  end;

  with nItem.FOptions do
  begin
    //if Values['ECard'] <> Values['ELabelFCard'] then
    begin
      Values['ECard'] := Values['ELabelFCard'];//gELabelItem.FCard;
      nETunnel := Values['ELabelFTunnel'];//gELabelItem.FTunnel;
      WriteHardHelperLog(' ::: �ϴε��ӱ�ǩ��' + Values['LastECard']
                          + '   ��ǰ���ӱ�ǩ��' + Values['ECard']);

      nLastTime := StrToInt64Def(Values['LastTime'], 0);
      nLast := Trunc((GetTickCount - nLastTime) / 1000);
      WriteHardHelperLog(' ::: ���ʱ����' + IntToStr(nLast) + 's');

      if (Values['ECard'] = Values['LastECard']) and (nLastTime <> 0) and (nLast < 60) then
      begin
        WriteHardHelperLog(' ::: ���ӱ�ǩ'+Values['ECard']+'��ȡ���ʱ��С��60s');
        Values['LastECard'] := Values['ECard'];
        Values['ELabelFCard'] := '';
        Values['ECard'] := '';
        Exit;
      end;

      nCard := gDispenserManager.GetCardNo(nItem.FID, nHint, False);

      if nCard = '' then
      begin
        nStr := '���緢����'  + nItem.FID + ' ::: ��ȡ����ʧ��,' + nHint;
        WriteHardHelperLog(nStr);
        PlayVoice('��ȡ����ʧ��');
        Exit;
      end;

      if (nCard = Values['LastTCard']) and (Values['ECard'] <> Values['LastECard']) then
      begin
        WriteHardHelperLog(' ::: ���ӱ�ǩ'+Values['ECard']+'��ǰ����'+
                           nCard + '���ϴΰ쿨�ɹ�����' + Values['LastTCard']+
                           'һ��,ҵ����ֹ');
        Exit;
      end;

      if not CheckCardOK(nCard, nStr) then
      begin
        WriteHardHelperLog(' ::: ' + nStr);
        PlayVoice(nStr);
        if gDispenserManager.RecoveryCard(nItem.FID, nHint) then
          WriteHardHelperLog(' ::: �ſ�' + nCard + '�������');
        Exit;
      end;

      if not SavePurchBillAutoOutCard(nGetPurFailed, nCard, Values['ECard'], nETunnel, nItem.FID) then
      begin
        WriteHardHelperLog(' ::: ͨ��[' + nETunnel + ']ELabel: [' + Values['ECard'] + ']����ʧ�ܣ�');
        if nGetPurFailed then//��ȡ����ʧ�ܵ������Ϊ10��
          Values['LastTime'] := IntToStr(GetTickCount - 50000)
        else
          Values['LastTime'] := IntToStr(GetTickCount);
        Values['LastECard'] := Values['ECard'];
        Values['ECard'] := '';
        Exit;
      end;
      WriteHardHelperLog(' ::: ���ӱ�ǩ'+Values['ECard']+'ҵ�����');
      Values['LastTime'] := IntToStr(GetTickCount);;
      Values['LastECard'] := Values['ECard'];
      Values['LastTCard'] := nCard;
      Values['ECard'] := '';
    end;
  end;
end;

//Date: 2012-4-24
//Parm: ����;ͨ��;�Ƿ����Ⱥ�˳��;��ʾ��Ϣ
//Desc: ���nTuck�Ƿ������nTunnelװ��
function IsTruckInQueue(const nTruck,nTunnel: string; const nQueued: Boolean;
 var nHint: string; var nPTruck: PTruckItem; var nPLine: PLineItem;
 const nStockType: string = ''): Boolean;
var i,nIdx,nInt: Integer;
    nLineItem: PLineItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('ͨ��[ %s ]��Ч.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if (nIdx < 0) and (nStockType <> '') and (
       ((nStockType = sFlag_Dai) and IsDaiQueueClosed) or
       ((nStockType = sFlag_San) and IsSanQueueClosed)) then
    begin
      for i:=Lines.Count - 1 downto 0 do
      begin
        if Lines[i] = nPLine then Continue;
        nLineItem := Lines[i];
        nInt := TruckInLine(nTruck, nLineItem.FTrucks);

        if nInt < 0 then Continue;
        //���ڵ�ǰ����
        if not StockMatch(nPLine.FStockNo, nLineItem) then Continue;
        //ˢ��������е�Ʒ�ֲ�ƥ��

        nIdx := nPLine.FTrucks.Add(nLineItem.FTrucks[nInt]);
        nLineItem.FTrucks.Delete(nInt);
        //Ų���������µ�

        nHint := 'Update %s Set T_Line=''%s'' ' +
                 'Where T_Truck=''%s'' And T_Line=''%s''';
        nHint := Format(nHint, [sTable_ZTTrucks, nPLine.FLineID, nTruck,
                nLineItem.FLineID]);
        gTruckQueueManager.AddExecuteSQL(nHint);

        nHint := '����[ %s ]��������[ %s->%s ]';
        nHint := Format(nHint, [nTruck, nLineItem.FName, nPLine.FName]);
        WriteNearReaderLog(nHint);
        Break;
      end;
    end;
    //��װ�ص�����

    if nIdx < 0 then
    begin
      nHint := Format('����[ %s ]����[ %s ]������.', [nTruck, nPLine.FName]);
      Exit;
    end;

    nPTruck := nPLine.FTrucks[nIdx];
//    nPTruck.FStockName := nPLine.FName;
//    //ͬ��������
    Result := True;

    if (not nQueued) or (nIdx < 1) then Exit;
    //��������,��ͷ��

    //--------------------------------------------------------------------------
    nInt := -1;
    //init

    for i:=nPline.FTrucks.Count-1 downto 0 do
    if PTruckItem(nPLine.FTrucks[i]).FStarted then
    begin
      nInt := i;
      Break;
    end;

    if nInt < 0 then Exit;
    //û����װ������,�����Ŷ�

    if nIdx - nInt <> 1 then
    begin
      nHint := '����[ %s ]��Ҫ��[ %s ]�ŶӵȺ�.';
      nHint := Format(nHint, [nPTruck.FTruck, nPLine.FName]);

      Result := False;
      Exit;
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-1-21
//Parm: ͨ����;������;
//Desc: ��nTunnel�ϴ�ӡnBill��α��
function PrintBillCode(const nTunnel,nBill: string; var nHint: string): Boolean;
var nStr: string;
    nTask: Int64;
    nOut: TWorkerBusinessCommand;
begin
  Result := True;
  if not gMultiJSManager.CountEnable then Exit;

  nTask := gTaskMonitor.AddTask('UHardBusiness.PrintBillCode', cTaskTimeoutLong);
  //to mon
  
  if not CallHardwareCommand(cBC_PrintCode, nBill, nTunnel, @nOut) then
  begin
    nStr := '��ͨ��[ %s ]���ͷ�Υ����ʧ��,����: %s';
    nStr := Format(nStr, [nTunnel, nOut.FData]);  
    WriteNearReaderLog(nStr);
  end;

  gTaskMonitor.DelTask(nTask, True);
  //task done
end;

//Date: 2012-4-24
//Parm: ����;ͨ��;������;��������
//Desc: ����nTunnel�ĳ�������������
function TruckStartJS(const nTruck,nTunnel,nBill: string;
  var nHint: string; const nAddJS: Boolean = True): Boolean;
var nIdx: Integer;
    nTask: Int64;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('ͨ��[ %s ]��Ч.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if nIdx < 0 then
    begin
      nHint := Format('����[ %s ]�Ѳ��ٶ���.', [nTruck]);
      Exit;
    end;

    Result := True;
    nPTruck := nPLine.FTrucks[nIdx];

    for nIdx:=nPLine.FTrucks.Count - 1 downto 0 do
      PTruckItem(nPLine.FTrucks[nIdx]).FStarted := False;
    nPTruck.FStarted := True;

    if PrintBillCode(nTunnel, nBill, nHint) and nAddJS then
    begin
      nTask := gTaskMonitor.AddTask('UHardBusiness.AddJS', cTaskTimeoutLong);
      //to mon
      
      gMultiJSManager.AddJS(nTunnel, nTruck, nBill, nPTruck.FDai, True);
      gTaskMonitor.DelTask(nTask);
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-07-17
//Parm: ��������
//Desc: ��ѯnBill�ϵ���װ��
function GetHasDai(const nBill: string): Integer;
var nStr: string;
    nIdx: Integer;
    nDBConn: PDBWorker;
begin
  if not gMultiJSManager.ChainEnable then
  begin
    Result := 0;
    Exit;
  end;

  Result := gMultiJSManager.GetJSDai(nBill);
  if Result > 0 then Exit;

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteNearReaderLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select T_Total From %s Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      Result := Fields[0].AsInteger;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;


function IsTruckInTunnel(const nTunnel, nStockNO: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBConn: PDBWorker;
begin
  Result := False;
  //init

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteNearReaderLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select D_Value From %s Where D_Name=''%s'' And ' +
            'D_Memo Like ''%%%s%%'' And D_ParamB Like ''%%%s%%''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_MaterailTunnel,
            nTunnel, nStockNO]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
         Result := True
    else Result := False;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

function IsTunnelStockNo(const nTunnel, nStockNO: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBConn: PDBWorker;
begin
  Result := False;
  //init

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteNearReaderLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := ' Select Z_ID From %s Where Z_ID = ''%s'' And Z_StockNo = ''%s'' ' ;
    nStr := Format(nStr, [sTable_ZTLines, nTunnel, nStockNO]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
         Result := True
    else Result := False;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2016/10/13
//Parm: ���ƺ�;������Ϣ
//Desc: С����ʾ����
function MakeShowTxt(const nTruck, nExt:string): string;
var nStr: string;
begin
  nStr := Copy(nTruck, Length(nTruck) - 5, 6);
  Result := Dbc2Sbc(nStr + StringOfChar(' ', 12 - Length(nStr)) + nExt);
end;

//Date: 2019-3-10
//Parm: �������;װ����ID;װ��������
//Desc: ����װ����
function SaveTruckLine(const nID,nLineID,nLineName: string): Boolean;
var nOut: TWorkerBusinessCommand;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nList.Values['ID'] := nID;
    nList.Values['LineID'] := nLineID;
    nList.Values['LineName'] := nLineName;
    Result := CallBusinessCommand(cBC_SaveTruckLine, nList.Text, '', @nOut);
  finally
    nList.Free;
  end;
end;

//Date: 2018-11-26
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ��ж������
procedure MakeTruckXieHuo(const nCard,nTunnel,nCardType: string);
var nStr, nStockNo, nStockName : string;
    nIdx,i: Integer;
    nTrucks: TLadingBillItems;
    nRet : Boolean;
    nDBConn: PDBWorker;
begin
  WriteNearReaderLog('MakeTruckXieHuo����.'+' �ſ�:'+nCard+' ͨ����'+nTunnel);

  nRet := False;
  if nCardType = sFlag_Provide then
    nRet := GetLadingOrders(nCard, sFlag_TruckBFM, nTrucks);

  if not nRet then
  begin
    nStr := '��ȡ�ſ�[ %s ]ҵ�񵥾���Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    {$IFDEF YanShouOnlyShow}
     {$IFDEF LedNew}
     LEDDisplayNew(nTunnel, '', '�ſ���Ч');
     {$ELSE}
     gDisplayManager.Display(nTunnel, '�ſ���Ч');
     {$ENDIF}
    {$ENDIF}
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û�ж�Ӧ������Ϣ.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    {$IFDEF YanShouOnlyShow}
     {$IFDEF LedNew}
     LEDDisplayNew(nTunnel, '', '�ſ���Ч');
     {$ELSE}
     gDisplayManager.Display(nTunnel, '�ſ���Ч');
     {$ENDIF}
    {$ENDIF}
    Exit;
  end;

  for nIdx := Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckBFM) or (FNextStatus = sFlag_TruckBFM) then Continue;
    //δװ����װ
    if FStatus = 'I' then
    begin
      nStr := nTrucks[0].FTruck + StringOfChar(' ', 12 - Length(nTrucks[0].FTruck));
      nStr := nStr + nTrucks[0].FStockName;
     {$IFDEF LedNew}
      for i := 0 to 3 do
      begin
        LEDDisplayNew(nTunnel, '', nStr);
      end;
     {$ELSE}
        gDisplayManager.Display(nTunnel, nStr);
     {$ENDIF}
      Exit;
    end;
    Exit;
  end;

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db
    nStr := ' Select D_ParamB, D_Value From %s Where D_Name=''%s'' And D_Memo Like ''%%%s%%'' ';
    nStr := Format(nStr, [sTable_SysDict, sFlag_KSTunnelStock,nTunnel]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    begin
      if RecordCount > 0 then
      begin
        nStockNo   := Fields[0].AsString;
        nStockName := Fields[1].AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
  //����Ʒ����Ϣ
  for nIdx := Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    FStockNo   := nStockNo;
    FStockName := nStockName;
  end;

  nRet := False;
  if nCardType = sFlag_Provide then
    nRet := SaveLadingOrders_KS(sFlag_TruckBFM, nTrucks);
  if not nRet then
  begin
    nStr := '����[ %s ]ж����ж��ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if nCardType = sFlag_Provide then
    nRet := SaveLadingOrders(sFlag_TruckOut, nTrucks);
  if not nRet then
  begin
    nStr := '����[ %s ]ж�����Զ�����ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  nStr := nTrucks[0].FTruck + StringOfChar(' ', 12 - Length(nTrucks[0].FTruck));
  nStr := nStr + nTrucks[0].FStockName;
  //xxxxx
 {$IFDEF LedNew}
  for i := 0 to 3 do
  begin
    LEDDisplayNew(nTunnel, '', nStr);
  end;
 {$ELSE}
   gDisplayManager.Display(nTunnel, nStr);
 {$ENDIF}
end;

//Date: 2017-11-05
//Parm: ����
//Desc: ��ѯnTruck���ڵ����������ƥ��
function CanLadingInLine(const nTruck,nLine: string;var nIsVIP:Boolean):Boolean;
var nStr,nTruckCus,nLineCus: string;
   nWorker,nWorkerA: PDBWorker;
begin
  Result:= False;
  nIsVIP:= False;

  nWorker := nil;
  nWorkerA:= nil;
  try
    nStr := 'Select * From %s Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZTLines, nLine]);

    with gDBConnManager.SQLQuery(nStr, nWorkerA) do
    if RecordCount > 0 then
    begin
      nIsVIP:=  (FieldByName('Z_CusLine').AsString='Y');
      nLineCus:= FieldByName('Z_CusLine').AsString;
      //xxxxx
    end;

    if not nIsVIP then
    begin
      WriteNearReaderLog(Format('%s Ϊ �ǿͻ��ض�����ר��ͨ�������ͨ��', [nLine]));
      Result:= True;
      Exit;
    end;

    WriteNearReaderLog(Format('%s Ϊ�ض�������%s ר��ͨ��������ͨ��ƥ����', [nLine, nLineCus]));
    //
    nStr := 'Select * From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      Result := nLineCus=FieldByName('T_CusLine').AsString;
      //xxxxx
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
    gDBConnManager.ReleaseConnection(nWorkerA);

    if Result then
         WriteNearReaderLog(Format('%s %s ƥ����ͨ��', [nTruck,nLine]))
    else WriteNearReaderLog(Format('ƥ����δͨ����%s ��ֹ�� %s װ��', [nTruck,nLine]));
  end;
end;

//Date: 2012-4-24
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�д�װװ������
procedure MakeTruckLadingDai(const nCard: string; nTunnel: string);
var nStr,nCardType: string;
    nBool, nRet: Boolean;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;

    function IsJSRun: Boolean;
    begin
      Result := False;
      if nTunnel = '' then Exit;
      Result := gMultiJSManager.IsJSRun(nTunnel);

      if Result then
      begin
        nStr := 'ͨ��[ %s ]װ����,ҵ����Ч.';
        nStr := Format(nStr, [nTunnel]);
        WriteNearReaderLog(nStr);
      end;
    end;
begin
  WriteNearReaderLog('MakeTruckLadingDai����.');

  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;

  {$IFDEF AddKSYW}
  if (nCardType = sFlag_Provide) then
  begin
    MakeTruckXieHuo(nCard, nTunnel, nCardType);
    Exit;
  end;
  {$ENDIF}

  if nCardType = sFlag_Provide then
  begin
    if not GetLadingOrders(nCard, sFlag_TruckXH, nTrucks) then
    begin
      nStr := '��ȡ�ſ�[ %s ]���մ��ɹ�����Ϣʧ��.';
      nStr := Format(nStr, [nCard]);

      WriteNearReaderLog(nStr);
      gDisplayManager.Display(nTunnel, '�ſ���Ч');
      Exit;
    end;

    if Length(nTrucks) < 1 then
    begin
      nStr := '�ſ�[ %s ]û����Ҫ���ճ���.';
      nStr := Format(nStr, [nCard]);

      WriteNearReaderLog(nStr);
      gDisplayManager.Display(nTunnel, '�ſ���Ч');
      Exit;
    end;

    nStr := '';
    nInt := 0;

    for nIdx:=Low(nTrucks) to High(nTrucks) do
    with nTrucks[nIdx] do
    begin
      if (FStatus = sFlag_TruckXH) or (FNextStatus = sFlag_TruckXH) then
      begin
        FYSValid  := sFlag_Yes;
        FPoundID  := nTunnel;
        FSelected := True;

        Inc(nInt);
        Continue;
      end;

      FSelected := False;
      nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�ж��.';
      nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    end;

    if nInt < 1 then
    begin
      WriteHardHelperLog(nStr);

      nStr := MakeShowTxt(nTrucks[0].FTruck,
              '�� ' + TruckStatusToStr(nTrucks[0].FNextStatus));
      gDisplayManager.Display(nTunnel, nStr);
      Exit;
    end;

    if (nTunnel <> '') and (not
       IsTruckInTunnel(nTunnel, nTrucks[0].FStockNo)) then
    begin
      nStr := MakeShowTxt(nTrucks[0].FTruck, '�뻻��ж��');
      gDisplayManager.Display(nTunnel, nStr);
      Exit;
    end;

    for nIdx:=Low(nTrucks) to High(nTrucks) do
    with nTrucks[nIdx] do
    begin
      if not FSelected then Continue;
      if FStatus <> sFlag_TruckXH then Continue;

      nStr := '����[ %s ]�ٴ�ˢ��ж��.';
      nStr := Format(nStr, [FTruck]);
      WriteNearReaderLog(nStr);

      nStr := MakeShowTxt(FTruck, FStockName);
      WriteNearReaderLog(nStr);
      gDisplayManager.Display(nTunnel, nStr);

      Exit;
    end;

    if not SaveLadingOrders(sFlag_TruckXH, nTrucks) then
    begin
      nStr := '����[ %s ]ˢ��ж��ʧ��.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteNearReaderLog(nStr);
      Exit;
    end;

    nStr := MakeShowTxt(nTrucks[0].FTruck, nTrucks[0].FStockName);
    gDisplayManager.Display(nTunnel, nStr);

    Exit;
  end;

  if IsJSRun then Exit;
  //tunnel is busy

  if nCardType = sFlag_SaleSingle then
    nRet := GetLadingBillsSingle(nCard, sFlag_TruckZT, nTrucks)
  else
    nRet := GetLadingBills(nCard, sFlag_TruckZT, nTrucks);
  if not nRet then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫջ̨�������.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //���¶�λ�������ڳ���
    if IsJSRun then Exit;
  end;

  if gTruckQueueManager.IsDaiForceQueue then
  begin
    nBool := True;
    for nIdx:=Low(nTrucks) to High(nTrucks) do
    begin
      nBool := nTrucks[nIdx].FNextStatus = sFlag_TruckZT;
      //δװ��,����Ŷ�˳��
      if not nBool then Break;
    end;
  end
  else
    nBool := False;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, nBool, nStr,
         nPTruck, nPLine, sFlag_Dai) then
  begin
    WriteNearReaderLog(nStr);
    Exit;
  end; //���ͨ��

  {$IFDEF UseDaiJYStockNo}
  if (nTunnel <> '') and (not
      IsTunnelStockNo(nTunnel, nTrucks[0].FStockNo)) then
  begin
    nStr := '������Ʒ����ͨ��Ʒ�ֲ�ͬ';
    gDisplayManager.Display(nTunnel, nStr);
    WriteNearReaderLog('ͨ��'+ nTunnel + nStr);
    Exit;
  end;
  {$ENDIF}

  nStr := '';
  nInt := 0;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckZT) or (FNextStatus = sFlag_TruckZT) then
    begin
      FSelected := Pos(FID, nPTruck.FHKBills) > 0;
      if FSelected then
      begin
        FLineGroup := nPLine.FLineGroup;
        Inc(nInt);
      end;
      //ˢ��ͨ����Ӧ�Ľ�����

      Continue;
    end;

    FSelected := False;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�ջ̨���.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt < 1 then
  begin
    WriteHardHelperLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    SaveTruckLine(FID, nTunnel, nPLine.FName);
  end;
  
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if not FSelected then Continue;
    if FStatus <> sFlag_TruckZT then Continue;

    nStr := '��װ����[ %s ]�ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nPTruck.FTruck]);
    WriteNearReaderLog(nStr);

    if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr,
       GetHasDai(nPTruck.FBill) < 1) then
      WriteNearReaderLog(nStr);

      
    {$IFDEF PackMachine}
    SaveBusinessCardInfo(FTruck, nCard, FID, nTunnel);
    {$ENDIF}
    Exit;
  end;

  if nCardType = sFlag_SaleSingle then
    nRet := SaveLadingBillsSingle(sFlag_TruckZT, nTrucks)
  else
    nRet := SaveLadingBills(sFlag_TruckZT, nTrucks);
  if not nRet then
  begin
    nStr := '����[ %s ]ջ̨���ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr) then
    WriteNearReaderLog(nStr);

  {$IFDEF PackMachine}
  SaveBusinessCardInfo(nTrucks[0].FTruck, nCard, nTrucks[0].FID, nTunnel);
  {$ENDIF}

  Exit;
end;

//Date: 2012-4-25
//Parm: ����;ͨ��
//Desc: ��ȨnTruck��nTunnel�����Ż�
procedure TruckStartFH(const nTruck: PTruckItem; const nLine: PLineItem);
var
   i : Integer;
   nStr,nTmp,nCardUse: string;
   nField: TField;
   nWorker: PDBWorker;
begin
  nWorker := nil;
  try
    nTmp := '';
    nStr := 'Select * From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nTruck.FTruck]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nField := FindField('T_Card');
      if Assigned(nField) then
        nTmp := nField.AsString;
      //xxxxx

      nField := FindField('T_CardUse');
      if Assigned(nField) then
        nCardUse := nField.AsString;
      //xxxxx

      if nCardUse = sFlag_No then
        nTmp := '';
      //xxxxx
    end;

    g02NReader.SetRealELabel(nLine.FLineID, nTmp);
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  for i := 0 to 2 do
  begin
    gERelayManager.LineOpen(nLine.FLineID);
    //�򿪷Ż�

    nStr := nTruck.FTruck + StringOfChar(' ', 12 - Length(nTruck.FTruck));
    nTmp := nLine.FName + FloatToStr(nTruck.FValue);
    nStr := nStr + nLine.FName + StringOfChar(' ', 12 - Length(nTmp)) +
            FloatToStr(nTruck.FValue);
    //xxxxx

    gERelayManager.ShowTxt(nLine.FLineID, nStr);
  end;
  //��ʾ����
  {$IFDEF SanLed}
  nStr := nLine.FName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nTruck.FValue);
  LEDDisplayNew(nLine.FLineID, nStr, nTruck.FTruck);
  {$ENDIF}
end;

//Date: 2012-4-24
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�д�װװ������
procedure MakeTruckLadingSan(const nCard,nTunnel: string);
var nStr, nCardType: string;
    nBool, nRet: Boolean;
    nIdx: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
    nIsVIP : Boolean;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckLadingSan����.');
  {$ENDIF}

  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;

  {$IFDEF AddKSYW}
  if (nCardType = sFlag_Provide)  then
  begin
    MakeTruckXieHuo(nCard, nTunnel, nCardType);
    Exit;
  end;
  {$ENDIF}

  if nCardType = sFlag_SaleSingle then
    nRet := GetLadingBillsSingle(nCard, sFlag_TruckFH, nTrucks)
  else
    nRet := GetLadingBills(nCard, sFlag_TruckFH, nTrucks);

  if not nRet then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ�Żҳ���.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    {$IFDEF AllowMultiM}
    if FStatus = sFlag_TRuckBFM then
    begin
      FStatus := sFlag_TruckFH;
    end;
    //���غ�������(״̬��������Ƥ��,��ֹ�������)
    {$ENDIF}

    if (FStatus = sFlag_TruckFH) or (FNextStatus = sFlag_TruckFH) then Continue;
    //δװ����װ

    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷��Ż�.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if gTruckQueueManager.IsSanForceQueue then
  begin
    nBool := True;
    for nIdx:=Low(nTrucks) to High(nTrucks) do
    begin
      nBool := nTrucks[nIdx].FNextStatus = sFlag_TruckFH;
      //δװ��,����Ŷ�˳��
      if not nBool then Break;
    end;
  end
  else
    nBool := False;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, nBool, nStr,
         nPTruck, nPLine, sFlag_San) then
  begin
    WriteNearReaderLog(nStr);
    //loged

    nIdx := Length(nTrucks[0].FTruck);
    if nBool and (Pos('�Ⱥ�', nStr) > 0) then
      nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '���ŶӵȺ�'
    else
      nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '�뻻��װ��';
    gERelayManager.ShowTxt(nTunnel, nStr);
    {$IFDEF SanLed}
    if nBool and (Pos('�Ⱥ�', nStr) > 0) then
      LEDDisplayNew(nTunnel, '���ŶӵȺ�', nTrucks[0].FTruck)
    else
      LEDDisplayNew(nTunnel, '�뻻��װ��', nTrucks[0].FTruck);
    {$ENDIF}
    Exit;
  end; //���ͨ��

  nIsVIP:= False;
  if not CanLadingInLine(nTrucks[0].FTruck, nTunnel, nIsVIP) then
  begin
    WriteNearReaderLog(nStr);
    //loged

    nIdx := Length(nTrucks[0].FTruck);
    nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '��ǰΪר�ó���';
    nStr := '��ǰר�ó����뻻��װ��';
    gERelayManager.ShowTxt(nTunnel, nStr);
    Exit;
  end; //���ͨ��

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    SaveTruckLine(FID, nTunnel, nPLine.FName);
  end;

  if nTrucks[0].FStatus = sFlag_TruckFH then
  begin
    nStr := 'ɢװ����[ %s ]�ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    TruckStartFH(nPTruck, nPLine);

    {$IFDEF FixLoad}
    WriteNearReaderLog('��������װ��::'+nTunnel+'@'+nCard);
    //���Ϳ��ź�ͨ���ŵ�����װ��������
    gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
    //���ε���
    gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
    {$ENDIF}
    
    Exit;
  end;

  nTrucks[0].FLineGroup := nPLine.FLineGroup;

  if nCardType = sFlag_SaleSingle then
    nRet := SaveLadingBillsSingle(sFlag_TruckFH, nTrucks)
  else
    nRet := SaveLadingBills(sFlag_TruckFH, nTrucks);

  if not nRet then
  begin
    nStr := '����[ %s ]�ŻҴ����ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  TruckStartFH(nPTruck, nPLine);
  //ִ�зŻ�
  {$IFDEF FixLoad}
  WriteNearReaderLog('��������װ��::'+nTunnel+'@'+nCard);
  //���Ϳ��ź�ͨ���ŵ�����װ��������
  gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
  //���ε���
  gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
  {$ENDIF}
end;

//Date: 2012-4-24
//Parm: ����;����
//Desc: ��nHost.nCard�µ�������������
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
begin 
  if nHost.FType = rtOnce then
  begin
    if nHost.FFun = rfOut then
         MakeTruckOut(nCard, '', nHost.FPrinter)
    else MakeTruckLadingDai(nCard, nHost.FTunnel);
  end else

  if nHost.FType = rtKeep then
  begin
    MakeTruckLadingSan(nCard, nHost.FTunnel);
  end;
end;

//Date: 2012-4-24
//Parm: ����;����
//Desc: ��nHost.nCard��ʱ����������
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardOut�˳�.');
  {$ENDIF}

  if Assigned(nHost.FOptions) then
  begin
    if nHost.FOptions.Values['YanShou'] = sFlag_Yes then
    begin
      Exit;
    end;
  end;

  {$IFDEF FixLoad}
  WriteHardHelperLog('ֹͣ����װ��::'+nHost.FTunnel+'@Close');
  //���Ϳ��ź�ͨ���ŵ�����װ��������
  gSendCardNo.SendCardNo(nHost.FTunnel+'@Close');
  {$ENDIF}

  {$IFDEF SanLed}
  LEDDisplayNew(nHost.FTunnel, '��ˢ��', '��ӭ����');
  {$ENDIF}

  gERelayManager.LineClose(nHost.FTunnel);
  Sleep(100);

  if nHost.FETimeOut then
       gERelayManager.ShowTxt(nHost.FTunnel, '���ӱ�ǩ������Χ')
  else gERelayManager.ShowTxt(nHost.FTunnel, nHost.FLEDText);
  Sleep(100);
end;

//------------------------------------------------------------------------------
//Date: 2012-12-16
//Parm: �ſ���
//Desc: ��nCardNo���Զ�����(ģ���ͷˢ��)
procedure MakeTruckAutoOut(const nCardNo: string);
var nReader: string;
begin
  if gTruckQueueManager.IsTruckAutoOut then
  begin
    nReader := gHardwareHelper.GetReaderLastOn(nCardNo);
    if nReader <> '' then
      gHardwareHelper.SetReaderCard(nReader, nCardNo);
    //ģ��ˢ��
  end;
end;

//Date: 2012-12-16
//Parm: ��������
//Desc: ����ҵ���м����Ӳ���ػ��Ľ�������
procedure WhenBusinessMITSharedDataIn(const nData: string);
begin
  WriteHardHelperLog('�յ�Bus_MITҵ������:::' + nData);
  //log data

  if Pos('TruckOut', nData) = 1 then
    MakeTruckAutoOut(Copy(nData, Pos(':', nData) + 1, MaxInt));
  //auto out
end;

function GetStockType(nBill: string):string;
var nStr, nStockMap: string;
    nWorker: PDBWorker;
begin
  Result := 'C';
  nStr := 'Select L_StockNO From %s ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nStockMap := Fields[0].AsString;

      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, 'StockBrandShow', nStockMap]);
      with gDBConnManager.WorkerQuery(nWorker, nStr) do
      if RecordCount > 0 then
      begin
        Result := Fields[0].AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  {$IFNDEF PreShowEx}//������ʾ���ٽ�ȡ
  Result := Copy(Result, 1, 4);
  {$ENDIF}
end;

//Date: 2015-01-14
//Parm: ���ƺ�;������
//Desc: ��ʽ��nBill��������Ҫ��ʾ�ĳ��ƺ�
function GetJSTruck(const nTruck,nBill: string): string;
var nStr: string;
    nLen: Integer;
    nWorker: PDBWorker;
begin
  Result := nTruck;
  if nBill = '' then Exit;

  {$IFDEF JSTruck}
  nStr := GetStockType(nBill);
  if nStr = '' then Exit;

  nLen := cMultiJS_Truck - 2;
  Result := Copy(nStr, 1, 2) +    //ȡǰ��λ
            Copy(nTruck, Length(nTruck) - nLen + 1, nLen);
  Exit;
  {$ENDIF}
end;

//Date: 2013-07-17
//Parm: ������ͨ��
//Desc: ����nTunnel�������
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
var nStr: string;
    nDai: Word;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nDai := nTunnel.FHasDone - nTunnel.FLastSaveDai;
  if nDai <= 0 then Exit;
  //invalid dai num

  if nTunnel.FLastBill = '' then Exit;
  //invalid bill

  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Bill'] := nTunnel.FLastBill;
    nList.Values['Dai'] := IntToStr(nDai);

    nStr := PackerEncodeStr(nList.Text);
    CallHardwareCommand(cBC_SaveCountData, nStr, '', @nOut)
  finally
    nList.Free;
  end;
end;

function SaveBusinessCardInfo(const nTruck,nCard,nBill,nLine: string): Boolean;
var nList: TStrings;
    nOut: TWorkerBusinessCommand;
    nID,nDefDept: string;
begin
  nList := TStringList.Create;
  try
    nList.Values['Truck'] := nTruck;
    nList.Values['Bill'] := nBill;
    nList.Values['Card'] := nCard;
    nList.Values['Line'] := nLine;

    Result := CallBusinessCommand(cBC_SaveBusinessCard, nList.Text, '', @nOut);
  finally
    nList.Free;
  end;
end;

end.
