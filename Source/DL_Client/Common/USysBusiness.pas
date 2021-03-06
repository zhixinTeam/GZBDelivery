{*******************************************************************************
  ����: dmzn@163.com 2010-3-8
  ����: ϵͳҵ����
*******************************************************************************}
unit USysBusiness;

interface
{$I Link.inc}
uses
  Windows, DB, Classes, Controls, SysUtils, UBusinessPacker, UBusinessWorker,
  UBusinessConst, ULibFun, UAdjustForm, UFormCtrl, UDataModule, UDataReport,
  UFormBase, cxMCListBox, UMgrPoundTunnels, UMgrCamera, USysConst, HKVNetSDK,
  USysDB, USysLoger, UFormInputbox;

type
  TLadingStockItem = record
    FID: string;         //���
    FType: string;       //����
    FName: string;       //����
    FParam: string;      //��չ
  end;

  TDynamicStockItemArray = array of TLadingStockItem;
  //ϵͳ���õ�Ʒ���б�

  PZTLineItem = ^TZTLineItem;
  TZTLineItem = record
    FID       : string;      //���
    FName     : string;      //����
    FStock    : string;      //Ʒ��
    FWeight   : Integer;     //����
    FValid    : Boolean;     //�Ƿ���Ч
    FPrinterOK: Boolean;     //�����
  end;

  PZTTruckItem = ^TZTTruckItem;
  TZTTruckItem = record
    FTruck    : string;      //���ƺ�
    FLine     : string;      //ͨ��
    FBill     : string;      //�����
    FValue    : Double;      //�����
    FDai      : Integer;     //����
    FTotal    : Integer;     //����
    FInFact   : Boolean;     //�Ƿ����
    FIsRun    : Boolean;     //�Ƿ�����    
  end;

  TZTLineItems = array of TZTLineItem;
  TZTTruckItems = array of TZTTruckItem;

  PSalePlanItem = ^TSalePlanItem;
  TSalePlanItem = record
    FOrderNo: string;        //������
    FInterID: string;        //������
    FEntryID: string;        //������
    FStockID: string;        //���ϱ��
    FStockName: string;      //��������

    FTruck: string;          //���ƺ���
    FValue: Double;          //������
    FSelected: Boolean;      //״̬
  end;
  TSalePlanItems = array of TSalePlanItem;
  
//------------------------------------------------------------------------------
function AdjustHintToRead(const nHint: string): string;
//������ʾ����
function WorkPCHasPopedom: Boolean;
//��֤�����Ƿ�����Ȩ
function GetSysValidDate: Integer;
//��ȡϵͳ��Ч��
function GetTruckEmptyValue(nTruck: string): Double;
function GetSerialNo(const nGroup,nObject: string; nUseDate: Boolean = True): string;
//��ȡ���б��
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
//����Ʒ���б�
function GetCardUsed(const nCard: string): string;
//��ȡ��Ƭ����

function SynEmptyBillYT(const nBillID: string): Boolean;
//ͬ���ճ�����������

function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
//��ȡϵͳ�ֵ���
function LoadSaleMan(const nList: TStrings; const nWhere: string = ''): Boolean;
//��ȡҵ��Ա�б�
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
//��ȡ�ͻ��б�
function LoadCustomerInfo(const nCID: string; const nList: TcxMCListBox;
 var nHint: string): TDataSet;
//����ͻ���Ϣ
function LoadStockItems(const nList: TStrings): Boolean;
//��ȡ����Ʒ���б�

function IsZhiKaNeedVerify: Boolean;
//ֽ���Ƿ���Ҫ���
function IsPrintZK: Boolean;
//�Ƿ��ӡֽ��
function DeleteZhiKa(const nZID: string): Boolean;
//ɾ��ָ��ֽ��
function LoadZhiKaInfo(const nZID: string; const nList: TcxMCListBox;
 var nHint: string): TDataset;
//����ֽ��
function GetZhikaValidMoney(nZhiKa: string; var nFixMoney: Boolean): Double;
//ֽ�����ý�
function GetCustomerValidMoney(nCID: string; const nLimit: Boolean = True;
 const nCredit: PDouble = nil): Double;
//�ͻ����ý��
function GetDayNumInfo(const nStockNo:string; const nProID:string;var nMsg:string):Boolean;
//��ȡ���չ�Ӧ���ѽ�����
function GetProMaxNum(const nStockNo:string):Double;
//��ȡ��Ӧ�̿����õ�����ս�����

function SyncRemoteCustomer: Boolean;
//ͬ��Զ���û�
function ModRemoteCustomer(const nCusID : string): Boolean;
//�޸�Զ���û�
function SyncRemoteSaleMan: Boolean;
//ͬ��Զ��ҵ��Ա
function SyncRemoteProviders: Boolean;
//ͬ��Զ���û�
function SyncRemoteMeterails: Boolean;
//ͬ��Զ��ҵ��Ա
function SaveXuNiCustomer(const nName,nSaleMan: string): string;
//����ʱ�ͻ�
function IsAutoPayCredit: Boolean;
//�ؿ�ʱ������
function SaveCustomerPayment(const nCusID,nCusName,nSaleMan: string;
 const nType,nPayment,nMemo: string; const nMoney: Double;
 const nCredit: Boolean = True): Boolean;
//����ؿ��¼
function SaveCustomerCredit(const nCusID,nMemo: string; const nCredit: Double;
 const nEndTime: TDateTime): Boolean;
//�������ü�¼
function IsCustomerCreditValid(const nCusID: string): Boolean;
//�ͻ������Ƿ���Ч

function YT_ReadCardInfo(var nCard: string): Boolean;
//��ȡ����XS_Card_Base��Ƭ��Ϣ
function YT_VerifyCardInfo(var nCard: string; nParam: string = ''): Boolean;
//��֤�ܷ񿪵�
function YT_GetBatchCode(const nList: TStrings): string;
//��ȡ�������κ�
function IsStockValid(const nStocks: string): Boolean;
//Ʒ���Ƿ���Է���
function SaveBill(const nBillData: string): string;
//���潻����
function DeleteBill(const nBill: string): Boolean;
//ɾ��������
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
//�����������
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
//����������
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean;
  nType: string = 'S'): Boolean;
//Ϊ����������ſ�
function SaveBillCard(const nBill, nCard: string): Boolean;
//���潻�����ſ�
function LogoutBillCard(const nCard: string): Boolean;
//ע��ָ���ſ�
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;

function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//��ȡָ����λ�Ľ������б�
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
//���뵥����Ϣ���б�
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems;var nMHint:string;
 const nTunnel: PPTTunnelItem = nil): Boolean;
//����ָ����λ�Ľ�����

function get_WLFYshoporderbyno(const nStr: string): string;
//�����������˵��Ż�ȡ������Ϣ

function GetReaderCard(const nReader,nType: string): string;
//��ȡָ����ͷ����Ч����
function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
//��ȡָ���������ѳ�Ƥ����Ϣ
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems): Boolean;
//���泵��������¼
function ReadPoundCard(var nReader: string;
  const nTunnel: string; nReadOnly: String = ''): string;
//��ȡָ����վ��ͷ�ϵĿ���
procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
//ץ��ָ��ͨ��
function GetTruckLastTime(const nTruck: string): Integer;
//�����ϴι�����¼
function GetTruckIsQueue(const nTruck: string): Boolean;
//��ȡ�����Ƿ��ڶ�����
function GetTruckIsOut(const nTruck: string): Boolean;
//��ȡ�����Ƿ��ѳ���
function GetTruckRealLabel(const nTruck: string): string;
//��ȡ�����󶨵ĵ��ӱ�ǩ
function GetRealLabelTruck(const nELabel: string): string;
//��ȡ���ӱ�ǩ��Ӧ�󶨵ĳ���
function GetELabelBillOrder(const nELabel: string): string;
//��ȡ���ӱ�ǩ��Ӧ�ĵ���
function GetBillOrderType(const nBillID: string): string;
//��ȡ���Ŷ�Ӧ������
function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
//�򿪶�������բ
function RemoteImportPounds(const nData: string): Boolean;
//�����������
function IsTunnelOK(const nTunnel: string): Boolean;
//��ѯͨ����դ�Ƿ�����
function IsTruckQueue(const nTruck: string): Boolean;
//��ѯ�����Ƿ��ڶ�����
procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
//����ͨ�����̵ƿ���
procedure GetPoundAutoWuCha(var nWCValZ, nWCValF: Double;
  const nVal: Double; const nStation: string = '');
//��ȡ�Զ��������
procedure ProberShowTxt(const nTunnel, nText: string);
//���췢��С��

function GetTruckNO(const nTruck: WideString; const nLong: Integer=12): string;
function GetValue(const nValue: Double): string;
//��ʾ��ʽ��
function AdjustBillStatus(const nLID, nStatus, nNextStatus: string): Boolean;
//У��״̬(����ɢװ������ι�����ë�س�������)
function SaveOrderBase(const nOrderData: string): string;
//����ɹ����뵥
function DeleteOrderBase(const nOrder: string): Boolean;
//ɾ���ɹ����뵥
function SaveOrder(const nOrderData: string): string;
//����ɹ���
function DeleteOrder(const nOrder: string): Boolean;
//ɾ���ɹ���

//����ɹ���ͬ
function SavePurchaseContract(const nData:string):string;

//����ɹ���ͬ
function ModifyPurchaseContract(const nData:string):string;

//ɾ���ɹ���ͬ
function DeletePurchaseContract(const nData: string): Boolean;

//function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
////�����������
function SetOrderCard(const nOrder,nTruck: string; nVerify: Boolean): Boolean;
//Ϊ�ɹ�������ſ�
function SaveOrderCard(const nOrder, nCard: string): Boolean;
//����ɹ����ſ�
function LogoutOrderCard(const nCard: string): Boolean;
//ע��ָ���ſ�
function ChangeOrderTruckNo(const nOrder,nTruck: string): Boolean;
//�޸ĳ��ƺ�
function GetGYOrderBaseValue(const nOrder: string): string;
//��ȡ�ɹ����뵥������Ϣ
procedure SaveWebOrderDelMsg(const nLID, nBillType: string);
//����������Ϣ

function GetPurchaseOrders(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//��ȡָ����λ�Ĳɹ����б�
function GetPurchaseOrdersKS(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//��ȡָ����λ�Ĳɹ����б�
function SavePurchaseOrders(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem = nil): Boolean;
//����ָ����λ�Ĳɹ���

function SaveDDBases(const nDDData: string): string;
//����̵�������Ϣ
function DeleteDDBase(const nBase: string): Boolean;
//ɾ���̵�������Ϣ
function DeleteDDDetial(const nDID: string): Boolean;
//ɾ���̵���ϸ
function SaveDDCard(const nBID, nCard: string): Boolean;
//�󶨶̵��ſ�
function LogoutDDCard(const nCard: string): Boolean;
//ע���̵��ſ�
function GetDuanDaoItems(const nCard,nPost: string;
  var nBills: TLadingBillItems): Boolean;
//��ȡָ����λ�Ķ̵���ϸ�б�
function SaveDuanDaoItems(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem=nil): Boolean;
//����ָ����λ�Ķ̵���ϸ

procedure LoadOrderItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);

function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean = False): Boolean;
//��ȡ��������
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
//��ͣ�����
function ChangeDispatchMode(const nMode: Byte): Boolean;
//�л�����ģʽ

function GetHYMaxValue: Double;
function GetHYValueByStockNo(const nNo: string): Double;
//��ȡ���鵥�ѿ���

function IsWeekValid(const nWeek: string; var nHint: string): Boolean;
//�����Ƿ���Ч
function IsWeekHasEnable(const nWeek: string): Boolean;
//�����Ƿ�����
function IsNextWeekEnable(const nWeek: string): Boolean;
//��һ�����Ƿ�����
function IsPreWeekOver(const nWeek: string): Integer;
//��һ�����Ƿ����
function SaveCompensation(const nSaleMan,nCusID,nCusName,nPayment,nMemo: string;
 const nMoney: Double): Boolean;
//�����û�������

//------------------------------------------------------------------------------
procedure PrintSaleContractReport(const nID: string; const nAsk: Boolean);
//��ӡ��ͬ
function PrintZhiKaReport(const nZID: string; const nAsk: Boolean): Boolean;
//��ӡֽ��
function PrintShouJuReport(const nSID: string; const nAsk: Boolean): Boolean;
//��ӡ�վ�
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
//��ӡ�����
function PrintOrderReport(const nOrder: string;  const nAsk: Boolean;const nMul: Boolean = False): Boolean;
//��ӡ�ɹ���
function PrintPoundReport(const nPound: string; nAsk: Boolean;const nMul: Boolean = False): Boolean;
//��ӡ��
function PrintDuanDaoReport(const nID: string; nAsk: Boolean): Boolean;
//��ӡ�̵���
function PrintHuaYanReport(const nHID, nStockName,nOutFact,nLID: string;
  const nAsk: Boolean): Boolean;
function PrintHeGeReport(const nHID: string; const nAsk: Boolean): Boolean;
//���鵥,�ϸ�֤

//��ȡ�ͻ�ע����Ϣ
function getCustomerInfo(const nXmlStr: string): string;

function IsAsternStock(const nStockName :string): Boolean;

function GetHYMBInfo(const nCusID,nStockName :string):string;

//��ȡ�ͻ�ע����Ϣ
function getCustomerInfoEx(const nData: string): string;

//�ͻ���΢���˺Ű�
function get_Bindfunc(const nXmlStr: string): string;

//������Ϣ
function send_event_msg(const nXmlStr: string): string;

//�����̳��û�
function edit_shopclients(const nXmlStr: string): string;
//�����̳��û�
function edit_shopclientsEx(const nData: string): string;

//�����Ʒ
function edit_shopgoods(const nXmlStr: string): string;

//��ȡ������Ϣ
function get_shoporders(const nXmlStr: string): string;

//���¶���״̬
function complete_shoporders(const nXmlStr: string): string;

function VerifyPoundWarning(var nHint: string; var nWarnVal: Double): Boolean;
//����Ƥ��Ԥ������
function PoundDaiWCEx:Boolean;
//���ô�װ�����ͨ�����ܱ���
function AddManualEventRecord(nEID, nKey, nEvent:string;
    nFrom: string = '����'; nSolution: string=sFlag_Solution_YN;
    nDepartmen: string=sFlag_DepDaTing; nReset: Boolean = False;
    nMemo: string=''): Boolean;
//��Ӵ����������¼
function VerifyManualEventRecord(const nEID: string; var nHint: string;
    const nWant: string = 'Y'; const nUpdateHint: Boolean = True): Boolean;
//����¼��Ƿ�ͨ������
function VerifyManualEventRecordEx(const nEID: string; var nHint: string;
 const nWant: string = 'Y'; const nUpdateHint: Boolean = True): Boolean;
//����¼��Ƿ�ͨ������
function DealManualEvent(const nEID, nResult: string): Boolean;
//�¼�����

function LoadZTLineGroup(const nList: TStrings; const nWhere: string = ''): Boolean;
//��ȡջ̨������Ϣ
function LoadZTLines(const nList: TStrings; const nWhere: string = ''): Boolean;
//��ȡջ̨��Ϣ
function AddManualEventRecordOver(nEID, nKey, nEvent:string;
    nFrom: string = '����'; nSolution: string=sFlag_Solution_YN;
    nDepartmen: string=sFlag_DepDaTing; nReset: Boolean = False;
    nMemo: string=''): Boolean;
//����Զ��������������¼��ֱ���Ѵ���״̬��

function GetBillType(const nLID:string; var nDispatchNo:string): Boolean;

function ReadWxHdOrderId(const nLID:string):string;
//��ȡ΢�źϵ���
function LoadCk(const nList: TStrings): Boolean;
//��ȡ��λ��ŵ�nList��
function GetCusName(const nCusID: string): string;
//��ȡ�ͻ�����
function VerifyFQSumValue: Boolean;
//�Ƿ�У���ǩ��
function GetFQValueByStockNo(const nStock: string): Double;
//��ȡ��ǩ���ѷ���
//----------------------------------------------------------------
//��������
function SaveOrderBaseSingle(const nOrderData: string): string;
//����ɹ����뵥
function DeleteOrderBaseSingle(const nOrder: string): Boolean;
//ɾ���ɹ����뵥
function SavePurchaseContractSingle(const nData:string):string;
//����ɹ���ͬ
function ModifyPurchaseContractSingle(const nData:string):string;
//�޸Ĳɹ���ͬ
function DeletePurchaseContractSingle(const nData: string): Boolean;
//ɾ���ɹ���ͬ
function SaveOrderSingle(const nOrderData: string): string;
//����ɹ���
function DeleteOrderSingle(const nOrder: string): Boolean;
//ɾ���ɹ���
function SaveOrderCardSingle(const nOrder, nCard: string): Boolean;
//����ɹ����ſ�
function LogoutOrderCardSingle(const nCard: string): Boolean;
//ע��ָ���ſ�
function ChangeOrderTruckNoSingle(const nOrder,nTruck: string): Boolean;
//�޸ĳ��ƺ�
function GetGYOrderBaseValueSingle(const nOrder: string): string;
//��ȡ�ɹ����뵥������Ϣ
function GetPurchaseOrdersSingle(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//��ȡָ����λ�Ĳɹ����б�
function SavePurchaseOrdersSingle(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem = nil): Boolean;
//����ָ����λ�Ĳɹ���
function RemoteImportPoundsSingle(const nData: string): Boolean;
//�����������

function IsEleCardVaidEx(const nTruckNo: string): Boolean;
//��֤�������ӱ�ǩ


function SaveBillSingle(const nBillData: string): string;
//���潻����
function DeleteBillSingle(const nBill: string): Boolean;
//ɾ��������
function SaveBillCardSingle(const nBill, nCard: string): Boolean;
//���潻�����ſ�
function LogoutBillCardSingle(const nCard: string): Boolean;
//ע��ָ���ſ�

function getPrePInfo(const nTruck:string;var nPrePValue: Double; var nPrePMan: string;
  var nPrePTime: TDateTime):Boolean;
//��ȡԤ��Ƥ�س���Ԥ����Ϣ

function GetPOrderDtlStatus(const nID:string):Boolean;
//�ж��Ƿ���Թ���

function GetPrePValueSet: Double;
//��ȡϵͳ�趨Ƥ��
procedure SaveTruckPrePValue(const nTruck, nValue: string);
//����Ԥ��Ƥ��
procedure UpdateTruckStatus(const nID: string);
//�޸ĳ���״̬
function SaveTruckPrePicture(const nTruck: string;const nTunnel: PPTTunnelItem): Boolean;
//����nTruck��Ԥ��Ƥ����Ƭ

function GetLadingBillsSingle(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//��ȡָ����λ�Ľ������б�
function SaveLadingBillsSingle(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem = nil): Boolean;
//����ָ����λ�Ľ�����
function IsLocalStock(const nStockNo: string): Boolean;
function GetCusSpecialSet(const nCusID, nStockNo: string;
                          var nCk: string): Boolean;
//��ȡ�ͻ������趨
//-----------------------------------------------------------------

implementation

//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(nEvent);
end;

//------------------------------------------------------------------------------
//Desc: ����nHintΪ�׶��ĸ�ʽ
function AdjustHintToRead(const nHint: string): string;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nList.Text := nHint;
    for nIdx:=0 to nList.Count - 1 do
      nList[nIdx] := '��.' + nList[nIdx];
    Result := nList.Text;
  finally
    nList.Free;
  end;
end;

//Desc: ��֤�����Ƿ�����Ȩ����ϵͳ
function WorkPCHasPopedom: Boolean;
begin
  Result := gSysParam.FSerialID <> '';
  if not Result then
  begin
    ShowDlg('�ù�����Ҫ����Ȩ��,�������Ա����.', sHint);
  end;
end;

//------------------------------------------------------------------------------
//Desc: ������ЧƤ��
function GetTruckEmptyValue(nTruck: string): Double;
var nStr: string;
begin
  nStr := 'Select T_PValue From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsFloat
  else Result := 0;
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ�ҵ���������
function CallBusinessCommand(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessSaleBill(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessSaleBill);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2018-08-16
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���(����)
function CallBusinessSaleBillSingle(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessSaleBillSingle);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessPurchaseOrder(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessPurchaseOrder);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2019-07-09
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessPurchaseOrderSingle(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessPurchaseOrderSingle);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2016-06-02
//Parm: ����;����;����;���
//Desc: �����м���ϵĶ̵����ݶ���
function CallBusinessDuanDao(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessDuanDao);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-10-01
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessHardware(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017-10-26
//Parm: ����;����;����;�����ַ;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessWechat(const nCmd: Integer; const nData,nExt,nSrvURL: string;
  const nOut: PWorkerWebChatData; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerWebChatData;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FRemoteUL := nSrvURL;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //close hint param
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessWebchat);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017-10-26
//Parm: ����;����;����;�����ַ;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessHHJY(const nCmd: Integer; const nData,nExt,nSrvURL: string;
  const nOut: PWorkerHHJYData; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerHHJYData;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FRemoteUL := nSrvURL;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //close hint param

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessHHJY);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-04
//Parm: ����;����;ʹ�����ڱ���ģʽ
//Desc: ����nGroup.nObject���ɴ��б��
function GetSerialNo(const nGroup,nObject: string; nUseDate: Boolean): string;
var nStr: string;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Group'] := nGroup;
    nList.Values['Object'] := nObject;

    if nUseDate then
         nStr := sFlag_Yes
    else nStr := sFlag_No;

    if CallBusinessCommand(cBC_GetSerialNO, nList.Text, nStr, @nOut) then
      Result := nOut.FData;
    //xxxxx
  finally
    nList.Free;
  end;   
end;

//Desc: ��ȡϵͳ��Ч��
function GetSysValidDate: Integer;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_IsSystemExpired, '', '', @nOut) then
       Result := StrToInt(nOut.FData)
  else Result := 0;
end;

function GetCardUsed(const nCard: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut) then
    Result := nOut.FData;
  //xxxxx
end;

function SynEmptyBillYT(const nBillID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := False;
  if CallBusinessCommand(cBC_SyncStockBill, nBillID, '', @nOut) then
    Result := True;
  //xxxxx
end;

//Desc: ��ȡ��ǰϵͳ���õ�ˮ��Ʒ���б�
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select D_Value,D_Memo,D_ParamB From $Table ' +
          'Where D_Name=''$Name'' Order By D_Index ASC';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_StockItem)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    SetLength(nItems, RecordCount);
    if RecordCount > 0 then
    begin
      nIdx := 0;
      First;

      while not Eof do
      begin
        nItems[nIdx].FType := FieldByName('D_Memo').AsString;
        nItems[nIdx].FName := FieldByName('D_Value').AsString;
        nItems[nIdx].FID := FieldByName('D_ParamB').AsString;

        Next;
        Inc(nIdx);
      end;
    end;
  end;

  Result := Length(nItems) > 0;
end;

//------------------------------------------------------------------------------
//Date: 2014-06-19
//Parm: ��¼��ʶ;���ƺ�;ͼƬ�ļ�
//Desc: ��nFile�������ݿ�
procedure SavePicture(const nID, nTruck, nMate, nFile: string);
var nStr: string;
    nRID: Integer;
begin
  FDM.ADOConn.BeginTrans;
  try
    nStr := MakeSQLByStr([
            SF('P_ID', nID),
            SF('P_Name', nTruck),
            SF('P_Mate', nMate),
            SF('P_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Picture, '', True);
    //xxxxx

    if FDM.ExecuteSQL(nStr) < 1 then Exit;
    nRID := FDM.GetFieldMax(sTable_Picture, 'R_ID');

    nStr := 'Select P_Picture From %s Where R_ID=%d';
    nStr := Format(nStr, [sTable_Picture, nRID]);
    FDM.SaveDBImage(FDM.QueryTemp(nStr), 'P_Picture', nFile);

    FDM.ADOConn.CommitTrans;
  except
    FDM.ADOConn.RollbackTrans;
  end;
end;


//Desc: ����ͼƬ·��
function MakePicName: string;
begin
  while True do
  begin
    Result := gSysParam.FPicPath + IntToStr(gSysParam.FPicBase) + '.jpg';
    if not FileExists(Result) then
    begin
      Inc(gSysParam.FPicBase);
      Exit;
    end;

    DeleteFile(Result);
    if FileExists(Result) then Inc(gSysParam.FPicBase)
  end;
end;

//Date: 2014-06-19
//Parm: ͨ��;�б�
//Desc: ץ��nTunnel��ͼ��
procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
const
  cRetry = 2;
  //���Դ���
var nStr: string;
    nIdx,nInt: Integer;
    nLogin,nErr: Integer;
    nPic: NET_DVR_JPEGPARA;
    nInfo: TNET_DVR_DEVICEINFO;
begin
  nList.Clear;
  if not Assigned(nTunnel.FCamera) then Exit;
  //not camera

  if not DirectoryExists(gSysParam.FPicPath) then
    ForceDirectories(gSysParam.FPicPath);
  //new dir

  if gSysParam.FPicBase >= 100 then
    gSysParam.FPicBase := 0;
  //clear buffer

  nLogin := -1;
  NET_DVR_Init();
  try
    for nIdx:=1 to cRetry do
    begin
      nLogin := NET_DVR_Login(PChar(nTunnel.FCamera.FHost),
                   nTunnel.FCamera.FPort,
                   PChar(nTunnel.FCamera.FUser),
                   PChar(nTunnel.FCamera.FPwd), @nInfo);
      //to login

      nErr := NET_DVR_GetLastError;
      if nErr = 0 then break;

      if nIdx = cRetry then
      begin
        nStr := '��¼�����[ %s.%d ]ʧ��,������: %d';
        nStr := Format(nStr, [nTunnel.FCamera.FHost, nTunnel.FCamera.FPort, nErr]);
        WriteLog(nStr);
        Exit;
      end;
    end;

    nPic.wPicSize := nTunnel.FCamera.FPicSize;
    nPic.wPicQuality := nTunnel.FCamera.FPicQuality;

    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
    begin
      if nTunnel.FCameraTunnels[nIdx] = MaxByte then continue;
      //invalid

      for nInt:=1 to cRetry do
      begin
        nStr := MakePicName();
        //file path

        NET_DVR_CaptureJPEGPicture(nLogin, nTunnel.FCameraTunnels[nIdx],
                                   @nPic, PChar(nStr));
        //capture pic

        nErr := NET_DVR_GetLastError;
        if nErr = 0 then
        begin
          nList.Add(nStr);
          Break;
        end;

        if nIdx = cRetry then
        begin
          nStr := 'ץ��ͼ��[ %s.%d ]ʧ��,������: %d';
          nStr := Format(nStr, [nTunnel.FCamera.FHost,
                   nTunnel.FCameraTunnels[nIdx], nErr]);
          WriteLog(nStr);
        end;
      end;
    end;
  finally
    if nLogin > -1 then
      NET_DVR_Logout(nLogin);
    NET_DVR_Cleanup();
  end;
end;

//------------------------------------------------------------------------------
//Date: 2010-4-13
//Parm: �ֵ���;�б�
//Desc: ��SysDict�ж�ȡnItem�������,����nList��
function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
var nStr: string;
begin
  nList.Clear;
  nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                      MI('$Name', nItem)]);
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount > 0 then
  with Result do
  begin
    First;

    while not Eof do
    begin
      nList.Add(FieldByName('D_Value').AsString);
      Next;
    end;
  end else Result := nil;
end;

//Desc: ��ȡҵ��Ա�б�nList��,������������
function LoadSaleMan(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'S_ID=Select S_ID,S_PY,S_Name From %s ' +
          'Where IsNull(S_InValid, '''')<>''%s'' %s Order By S_PY';
  nStr := Format(nStr, [sTable_Salesman, sFlag_Yes, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['S_ID']));
  
  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//Desc: ��ȡ�ͻ��б�nList��,������������
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'C_ID=Select C_ID,C_Name From %s ' +
          'Where 1=1 %s Order By C_PY';
  nStr := Format(nStr, [sTable_Customer, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['C_ID']));

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

function LoadStockItems(const nList: TStrings): Boolean;
var nStr: string;
begin
  nStr := 'D_ParamB=Select D_ParamB,D_Value From %s ' +
          'Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['D_ParamB']));

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//��֤�������ӱ�ǩ
function IsEleCardVaidEx(const nTruckNo: string): Boolean;
var
  nSql:string;
begin
  Result := False;

  nSql := 'select * from %s where T_Truck = ''%s'' ';
  nSql := Format(nSql,[sTable_Truck,nTruckNo]);

  with FDM.QueryTemp(nSql) do
  begin
    if recordcount>0 then
    begin
      if FieldByName('T_CardUse').AsString = sFlag_Yes then//����
      begin
        if (FieldByName('T_Card').AsString <> '') or (FieldByName('T_Card2').AsString <> '') then
        begin
          Result := True;
        end;
      end;
    end;
  end;
end;

//Desc: ����nCID�ͻ�����Ϣ��nList��,���������ݼ�
function LoadCustomerInfo(const nCID: string; const nList: TcxMCListBox;
 var nHint: string): TDataSet;
var nStr: string;
begin
  nStr := 'Select cus.*,S_Name as C_SaleName From $Cus cus ' +
          ' Left Join $SM sm On sm.S_ID=cus.C_SaleMan ' +
          'Where C_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$Cus', sTable_Customer), MI('$ID', nCID),
          MI('$SM', sTable_Salesman)]);
  //xxxxx

  nList.Clear;
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount > 0 then
  with nList.Items,Result do
  begin
    Add('�ͻ����:' + nList.Delimiter + FieldByName('C_ID').AsString);
    Add('�ͻ�����:' + nList.Delimiter + FieldByName('C_Name').AsString + ' ');
    Add('��ҵ����:' + nList.Delimiter + FieldByName('C_FaRen').AsString + ' ');
    Add('��ϵ��ʽ:' + nList.Delimiter + FieldByName('C_Phone').AsString + ' ');
    Add('����ҵ��Ա:' + nList.Delimiter + FieldByName('C_SaleName').AsString);
  end else
  begin
    Result := nil;
    nHint := '�ͻ���Ϣ�Ѷ�ʧ';
  end;
end;

//Desc: ����nSaleMan���µ�nNameΪ��ʱ�ͻ�,���ؿͻ���
function SaveXuNiCustomer(const nName,nSaleMan: string): string;
var nID: Integer;
    nStr: string;
    nBool: Boolean;
begin
  nStr := 'Select C_ID From %s ' +
          'Where C_XuNi=''%s'' And C_SaleMan=''%s'' And C_Name=''%s''';
  nStr := Format(nStr, [sTable_Customer, sFlag_Yes, nSaleMan, nName]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
    Exit;
  end;

  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Insert Into %s(C_Name,C_PY,C_SaleMan,C_XuNi) ' +
            'Values(''%s'',''%s'',''%s'', ''%s'')';
    nStr := Format(nStr, [sTable_Customer, nName, GetPinYinOfStr(nName),
            nSaleMan, sFlag_Yes]);
    FDM.ExecuteSQL(nStr);

    nID := FDM.GetFieldMax(sTable_Customer, 'R_ID');
    Result := FDM.GetSerialID2('KH', sTable_Customer, 'R_ID', 'C_ID', nID);

    nStr := 'Update %s Set C_ID=''%s'' Where R_ID=%d';
    nStr := Format(nStr, [sTable_Customer, Result, nID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Insert Into %s(A_CID,A_Date) Values(''%s'', %s)';
    nStr := Format(nStr, [sTable_CusAccount, Result, FDM.SQLServerNow]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
    //commit if need
  except
    Result := '';
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: ���ʱ�����ö��
function IsAutoPayCredit: Boolean;
var nStr: string;
begin
  nStr := 'Select D_Value From $T Where D_Name=''$N'' and D_Memo=''$M''';
  nStr := MacroValue(nStr, [MI('$T', sTable_SysDict), MI('$N', sFlag_SysParam),
                           MI('$M', sFlag_PayCredit)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsString = sFlag_Yes
  else Result := False;
end;

//Desc: ����nCusID��һ�λؿ��¼
function SaveCustomerPayment(const nCusID,nCusName,nSaleMan: string;
 const nType,nPayment,nMemo: string; const nMoney: Double;
 const nCredit: Boolean): Boolean;
var nStr: string;
    nBool: Boolean;
    nVal,nLimit: Double;
begin
  Result := False;
  nVal := Float2Float(nMoney, cPrecision, False);
  //adjust float value

  if nVal < 0 then
  begin
    nLimit := GetCustomerValidMoney(nCusID, False);
    //get money value
    
    if (nLimit <= 0) or (nLimit < -nVal) then
    begin
      nStr := '�ͻ�: %s ' + #13#10#13#10 +
              '��ǰ���Ϊ[ %.2f ]Ԫ,�޷�֧��[ %.2f ]Ԫ.';
      nStr := Format(nStr, [nCusName, nLimit, -nVal]);
      
      ShowDlg(nStr, sHint);
      Exit;
    end;
  end;

  nLimit := 0;
  //no limit

  if nCredit and (nVal > 0) and IsAutoPayCredit then
  begin
    nStr := 'Select A_CreditLimit From %s Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nCusID]);

    with FDM.QueryTemp(nStr) do
    if (RecordCount > 0) and (Fields[0].AsFloat > 0) then
    begin
      if FloatRelation(nVal, Fields[0].AsFloat, rtGreater) then
           nLimit := Float2Float(Fields[0].AsFloat, cPrecision, False)
      else nLimit := nVal;

      nStr := '�ͻ�[ %s ]��ǰ���ö��Ϊ[ %.2f ]Ԫ,�Ƿ���?' +
              #32#32#13#10#13#10 + '���"��"������[ %.2f ]Ԫ�Ķ��.';
      nStr := Format(nStr, [nCusName, Fields[0].AsFloat, nLimit]);

      if not QueryDlg(nStr, sAsk) then
        nLimit := 0;
      //xxxxx
    end;
  end;

  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Update %s Set A_InMoney=A_InMoney+%.2f Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nVal, nCusID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Insert Into %s(M_SaleMan,M_CusID,M_CusName,' +
            'M_Type,M_Payment,M_Money,M_Date,M_Man,M_Memo) ' +
            'Values(''%s'',''%s'',''%s'',''%s'',''%s'',%.2f,%s,''%s'',''%s'')';
    nStr := Format(nStr, [sTable_InOutMoney, nSaleMan, nCusID, nCusName, nType,
            nPayment, nVal, FDM.SQLServerNow, gSysParam.FUserID, nMemo]);
    FDM.ExecuteSQL(nStr);

    if (nLimit > 0) and (
       not SaveCustomerCredit(nCusID, '�ؿ�ʱ���', -nLimit, Now)) then
    begin
      nStr := '����δ֪����,���³���ͻ�[ %s ]���ò���ʧ��.' + #13#10 +
              '���ֶ������ÿͻ����ö��.';
      nStr := Format(nStr, [nCusName]);
      ShowDlg(nStr, sHint);
    end;

    if not nBool then
      FDM.ADOConn.CommitTrans;
    Result := True;
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: ����nCusID��һ�����ż�¼
function SaveCustomerCredit(const nCusID,nMemo: string; const nCredit: Double;
 const nEndTime: TDateTime): Boolean;
var nStr: string;
    nVal: Double;
    nBool: Boolean;
begin
  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nVal := Float2Float(nCredit, cPrecision, False);
    //adjust float value

    nStr := 'Insert Into %s(C_CusID,C_Money,C_Man,C_Date,C_End,C_Memo) ' +
            'Values(''%s'', %.2f, ''%s'', %s, ''%s'', ''%s'')';
    nStr := Format(nStr, [sTable_CusCredit, nCusID, nVal, gSysParam.FUserID,
            FDM.SQLServerNow, DateTime2Str(nEndTime), nMemo]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Update %s Set A_CreditLimit=A_CreditLimit+%.2f Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nVal, nCusID]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
    Result := True;
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Date: 2014-09-14
//Parm: �ͻ����
//Desc: ��֤nCusID�Ƿ����㹻��Ǯ,������û�й���
function IsCustomerCreditValid(const nCusID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_CustomerHasMoney, nCusID, '', @nOut) then
       Result := nOut.FData = sFlag_Yes
  else Result := False;
end;

//Date: 2014-10-13
//Desc: ͬ��ҵ��Ա��DLϵͳ
function SyncRemoteSaleMan: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncSaleMan, '', '', @nOut);
end;

//Date: 2014-10-13
//Desc: ͬ���û���DLϵͳ       cBC_SyncModCustomer
function SyncRemoteCustomer: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncCustomer, '', '', @nOut);
end;

//Desc: �޸��û���DLϵͳ
function ModRemoteCustomer(const nCusID : string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncModCustomer, nCusID, '', @nOut);
end;

//Desc: ͬ����Ӧ�̵�DLϵͳ
function SyncRemoteProviders: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncProvider, '', '', @nOut);
end;

//Date: 2014-10-13
//Desc: ͬ��ԭ���ϵ�DLϵͳ
function SyncRemoteMeterails: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncMaterails, '', '', @nOut);
end;

//Date: 2014-09-25
//Parm: ���ƺ�
//Desc: ��ȡnTruck�ĳ�Ƥ��¼
function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetTruckPoundData, nTruck, '', @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nPoundData);
  //xxxxx
end;

//Date: 2014-09-25
//Parm: ��������
//Desc: ����nData��������
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessCommand(cBC_SaveTruckPoundData, nStr, '', @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  nList := TStringList.Create;
  try
    CapturePicture(nTunnel, nList);
    //capture file

    for nIdx:=0 to nList.Count - 1 do
      SavePicture(nOut.FData, nData[0].FTruck,
                              nData[0].FStockName, nList[nIdx]);
    //save file
  finally
    nList.Free;
  end;
end;

//Date: 2014-10-02
//Parm: ͨ����
//Desc: ��ȡnTunnel��ͷ�ϵĿ���
function ReadPoundCard(var nReader: string;
    const nTunnel: string; nReadOnly: String = ''): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nReader:= '';
  //����

  if CallBusinessHardware(cBC_GetPoundCard, nTunnel, nReadOnly, @nOut)  then
  begin
    Result := Trim(nOut.FData);
    nReader:= Trim(nOut.FExtParam);
  end;
end;

function get_WLFYshoporderbyno(const nStr: string): string;
//�����������˵��Ż�ȡ������Ϣ
var nOut: TWorkerHHJYData;
begin
  if CallBusinessHHJY(cBC_FYWLGetSaleInfo, nStr, '', '', @nOut) then
    Result := nOut.FData
  else Result := '';
end;

//Date: 2018-04-16
//Parm: ��ͷ;����
//Desc: ��ȡnReader�ϵ���Ч����
function GetReaderCard(const nReader,nType: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessHardware(cBC_GetReaderCard, nReader, nType, @nOut) then
       Result := Trim(nOut.FData)
  else Result := '';
end;

//------------------------------------------------------------------------------
//Date: 2014-10-01
//Parm: ͨ��;����
//Desc: ��ȡ������������
function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean): Boolean;
var nIdx: Integer;
    nSLine,nSTruck: string;
    nListA,nListB: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    if nRefreshLine then
         nSLine := sFlag_Yes
    else nSLine := sFlag_No;

    Result := CallBusinessHardware(cBC_GetQueueData, nSLine, '', @nOut);
    if not Result then Exit;

    nListA.Text := PackerDecodeStr(nOut.FData);
    nSLine := nListA.Values['Lines'];
    nSTruck := nListA.Values['Trucks'];

    nListA.Text := PackerDecodeStr(nSLine);
    SetLength(nLines, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nLines[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FID       := Values['ID'];
      FName     := Values['Name'];
      FStock    := Values['Stock'];
      FValid    := Values['Valid'] <> sFlag_No;
      FPrinterOK:= Values['Printer'] <> sFlag_No;

      if IsNumber(Values['Weight'], False) then
           FWeight := StrToInt(Values['Weight'])
      else FWeight := 1;
    end;

    nListA.Text := PackerDecodeStr(nSTruck);
    SetLength(nTrucks, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nTrucks[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FTruck    := Values['Truck'];
      FLine     := Values['Line'];
      FBill     := Values['Bill'];

      if IsNumber(Values['Value'], True) then
           FValue := StrToFloat(Values['Value'])
      else FValue := 0;

      FInFact   := Values['InFact'] = sFlag_Yes;
      FIsRun    := Values['IsRun'] = sFlag_Yes;
           
      if IsNumber(Values['Dai'], False) then
           FDai := StrToInt(Values['Dai'])
      else FDai := 0;

      if IsNumber(Values['Total'], False) then
           FTotal := StrToInt(Values['Total'])
      else FTotal := 0;
    end;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

//Date: 2014-10-01
//Parm: ͨ����;��ͣ��ʶ
//Desc: ��ͣnTunnelͨ���������
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nEnable then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  CallBusinessHardware(cBC_PrinterEnable, nTunnel, nStr, @nOut);
end;

//Date: 2014-10-07
//Parm: ����ģʽ
//Desc: �л�ϵͳ����ģʽΪnMode
function ChangeDispatchMode(const nMode: Byte): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_ChangeDispatchMode, IntToStr(nMode), '',
            @nOut);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: ֽ���Ƿ���Ҫ���
function IsZhiKaNeedVerify: Boolean;
var nStr: string;
begin
  nStr := 'Select D_Value From $T Where D_Name=''$N'' and D_Memo=''$M''';
  nStr := MacroValue(nStr, [MI('$T', sTable_SysDict), MI('$N', sFlag_SysParam),
                           MI('$M', sFlag_ZhiKaVerify)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsString = sFlag_Yes
  else Result := False;
end;

//Desc: �Ƿ��ӡֽ��
function IsPrintZK: Boolean;
var nStr: string;
begin
  nStr := 'Select D_Value From $T Where D_Name=''$N'' and D_Memo=''$M''';
  nStr := MacroValue(nStr, [MI('$T', sTable_SysDict), MI('$N', sFlag_SysParam),
                           MI('$M', sFlag_PrintZK)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsString = sFlag_Yes
  else Result := False;
end;

//Desc: ɾ�����ΪnZID��ֽ��
function DeleteZhiKa(const nZID: string): Boolean;
var nStr: string;
    nBool: Boolean;
begin
  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Delete From %s Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, nZID]);
    Result := FDM.ExecuteSQL(nStr) > 0;

    nStr := 'Delete From %s Where D_ZID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKaDtl, nZID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Update %s Set M_ZID=M_ZID+''_d'' Where M_ZID=''%s''';
    nStr := Format(nStr, [sTable_InOutMoney, nZID]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
    //commit if need
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: ����nZID����Ϣ��nList��,�����ز�ѯ���ݼ�
function LoadZhiKaInfo(const nZID: string; const nList: TcxMCListBox;
 var nHint: string): TDataset;
var nStr: string;
begin
  nStr := 'Select zk.*,sm.S_Name,cus.C_Name From $ZK zk ' +
          ' Left Join $SM sm On sm.S_ID=zk.Z_SaleMan ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          'Where Z_ID=''$ID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
             MI('$Con', sTable_SaleContract), MI('$SM', sTable_Salesman),
             MI('$Cus', sTable_Customer), MI('$ID', nZID)]);
  //xxxxx

  nList.Clear;
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount = 1 then
  with nList.Items,Result do
  begin
    Add('ֽ�����:' + nList.Delimiter + FieldByName('Z_ID').AsString);
    Add('ҵ����Ա:' + nList.Delimiter + FieldByName('S_Name').AsString+ ' ');
    Add('�ͻ�����:' + nList.Delimiter + FieldByName('C_Name').AsString + ' ');
    Add('��Ŀ����:' + nList.Delimiter + FieldByName('Z_Project').AsString + ' ');
    
    nStr := DateTime2Str(FieldByName('Z_Date').AsDateTime);
    Add('�쿨ʱ��:' + nList.Delimiter + nStr);
  end else
  begin
    Result := nil;
    nHint := 'ֽ������Ч';
  end;
end;

//Date: 2014-09-14
//Parm: ֽ����;�Ƿ�����
//Desc: ��ȡnZhiKa�Ŀ��ý�Ŷ
function GetZhikaValidMoney(nZhiKa: string; var nFixMoney: Boolean): Double;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetZhiKaMoney, nZhiKa, '', @nOut) then
  begin
    Result := StrToFloat(nOut.FData);
    nFixMoney := nOut.FExtParam = sFlag_Yes;
  end else Result := 0;
end;

//Desc: ��ȡnCID�û��Ŀ��ý��,�������ö�򾻶�
function GetCustomerValidMoney(nCID: string; const nLimit: Boolean;
 const nCredit: PDouble): Double;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nLimit then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  if CallBusinessCommand(cBC_GetCustomerMoney, nCID, nStr, @nOut) then
  begin
    Result := StrToFloat(nOut.FData);
    if Assigned(nCredit) then
      nCredit^ := StrToFloat(nOut.FExtParam);
    //xxxxx
  end else
  begin
    Result := 0;
    if Assigned(nCredit) then
      nCredit^ := 0;
    //xxxxx
  end;
end;

function GetDayNumInfo(const nStockNo:string; const nProID:string;var nMsg:string):Boolean;
var
  nSql :string;
  nSumNum,nOutNum,nNum: Double;
  FStart, FEnd : TDate;
begin
  Result := True;
  nMsg   := '';
  nSql := ' Select M_Status, M_DayNum From %s where M_ID = ''%s'' ';
  nSql := Format(nSql,[sTable_Materails,nStockNo]);
  with FDM.QueryTemp(nSql) do
  begin
    if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    nSumNum := Fields[1].AsFloat;
  end;

  nSql := ' Select P_Status, P_Value, P_EndDate From %s where P_StockNo = ''%s'' and P_ID = ''%s'' ';
  nSql := Format(nSql,[sTable_Pro_Order, nStockNo,nProID]);
  with FDM.QueryTemp(nSql) do
  begin
    if (RecordCount > 0) and (Fields[0].AsString = sFlag_Yes) then
    begin
      if Str2DateTime(FieldByName('P_EndDate').AsString) < Now then
        nMsg := '�������ƽ���ʱ���ѹ�,�޷�����';
      nSumNum := Fields[1].AsFloat;
    end;
  end;
  //��ѯ���ն�Ӧ��Ӧ��ԭ�����ѳ�����
  FStart := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FEnd   := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  nSql := ' Select sum(D_Value) From %s od, %s o Where od.D_OID=o.O_ID and od.D_OutFact is not null '+
    ' and o.O_ProID=''%s'' and o.O_StockNo =''%s'' and  (o.O_Date >=''%s'' and o.O_Date<''%s'') ';
  nSql := Format(nSql,[sTable_OrderDtl,sTable_Order,nProID,nStockNo,Date2Str(FStart),Date2Str(FEnd+1)]);
  with FDM.QueryTemp(nSql) do
  begin
    if (RecordCount < 1) then
      nOutNum := 0
    else
    begin
      nOutNum := Fields[0].AsFloat;
    end;
  end;
  //��ѯ���չ�Ӧ��ԭ���ϵ���δ������
  nSql := ' Select COUNT(*) from %s o where o.O_ProID=''%s'' and o.O_StockNo = ''%s'' ' +
    ' and (o.O_Date >=''%s'' and o.O_Date<''%s'') and  ' +
    ' not exists(Select R_ID from P_OrderDtl od where o.O_ID=od.D_OID and od.D_Status = ''O'' ) ';
  nSql := Format(nSql,[sTable_Order,nProID,nStockNo,Date2Str(FStart),Date2Str(FEnd+1)]);
  with FDM.QueryTemp(nSql) do
  begin
    if (RecordCount < 1) then
      nNum := 50
    else
    begin
      nNum := (Fields[0].AsInteger+1) * 50;
    end;
  end;
  if nNum + nOutNum > nSumNum then
    Result := False;
end;

function GetProMaxNum(const nStockNo:string):Double;
var
  nSql :string;
  nSumNum, nUsedNum: Double;
begin
  Result := 0;
  nSql := ' Select M_DayNum From %s where M_ID = ''%s'' ';
  nSql := Format(nSql,[sTable_Materails,nStockNo]);
  with FDM.QueryTemp(nSql) do
  begin
    if (RecordCount < 1) then Exit;
    nSumNum := Fields[0].AsFloat;
  end;

  nSql := ' Select  sum(P_Value) From %s where P_StockNo = ''%s'' ';
  nSql := Format(nSql,[sTable_Pro_Order, nStockNo]);
  with FDM.QueryTemp(nSql) do
  begin
    if (RecordCount < 1)  then
      nUsedNum := 0
    else
      nUsedNum := Fields[0].AsFloat;
  end;
  Result := nSumNum - nUsedNum;
end;

//Date: 2014-10-16
//Parm: Ʒ���б�(s1,s2..)
//Desc: ��֤nStocks�Ƿ���Է���
function IsStockValid(const nStocks: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_CheckStockValid, nStocks, '', @nOut);
end;

//Date: 2015-09-13
//Parm: ��Ƭ���[in];��Ƭ��Ϣ[out]
//Desc: ������ϵͳ�ж�ȡָ����Ƭ����Ϣ
function YT_ReadCardInfo(var nCard: string): Boolean;
var nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_ReadYTCard, nCard, '', @nOut, False);
  if not Result then
  begin
    nCard := nOut.FBase.FErrDesc;
    Exit;
  end;

  nList := TStringList.Create;
  try
    nList.Text := PackerDecodeStr(nOut.FData);
    nCard := nList[0];
    //cBC_ReadYTCard��ȡָ�������ȡ����,ȡ��һ��
  finally
    nList.Free;
  end;
end;

//Date: 2015-09-14
//Parm: ��Ƭ����[in];��ʾ��Ϣ[out];����
//Desc: ��֤nCard�ܷ񿪾��������
function YT_VerifyCardInfo(var nCard: string; nParam: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  if nParam = '' then
    nParam := sFlag_LoadExtInfo;
  //xxxxx

  Result := CallBusinessCommand(cBC_VerifyYTCard, nCard, nParam, @nOut, False);
  if Result then
       nCard := nOut.FData
  else nCard := nOut.FBase.FErrDesc;
end;

//Date: 2016/10/13
//Parm: ���쿨��Ϣ
//Desc: ��ȡ���κ�
function YT_GetBatchCode(const nList: TStrings): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetYTBatchCode, PackerEncodeStr(nList.Text),
     '', @nOut, False) then
  begin
    Result := PackerDecodeStr(nOut.FData);
  end else

  begin
    Result := '';
    ShowMsg(nOut.FBase.FErrDesc, sHint);
  end;
end;

//Date: 2014-09-15
//Parm: ��������
//Desc: ���潻����,���ؽ��������б�
function SaveBill(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessSaleBill(cBC_SaveBills, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-15
//Parm: ��������
//Desc: ɾ��nBillID����
function DeleteBill(const nBill: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_DeleteBill, nBill, '', @nOut);
end;

//Date: 2014-09-15
//Parm: ������;�³���
//Desc: �޸�nBill�ĳ���ΪnTruck.
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_ModifyBillTruck, nBill, nTruck, @nOut);
end;

//Date: 2014-09-30
//Parm: ������;ֽ��
//Desc: ��nBill������nNewZK�Ŀͻ�
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaleAdjust, nBill, nNewZK, @nOut);
end;

//Date: 2014-09-17
//Parm: ������;���ƺ�;У���ƿ�����
//Desc: ΪnBill�������ƿ�
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean;
  nType: string): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nBill;
  nP.FParamB := nTruck;
  nP.FParamC := nType;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2014-09-17
//Parm: ��������;�ſ�
//Desc: ��nBill.nCard
function SaveBillCard(const nBill, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillCard, nBill, nCard, @nOut);
end;

//Date: 2014-09-17
//Parm: �ſ���
//Desc: ע��nCard
function LogoutBillCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_LogoffCard, nCard, '', @nOut);
end;

//Date: 2014-09-17
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
    Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Date: 2014-09-18
//Parm: ��λ;�������б�;��վͨ��
//Desc: ����nPost��λ�ϵĽ���������
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems; var nMHint:string;
 const nTunnel: PPTTunnelItem): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);
  if nOut.FExtParam = '-1' then
  begin
    nMHint := nOut.FData;
    Result := False;
  end;
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //��������
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nList);
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/19
//Parm:
//Desc: ����ɹ����뵥
function SaveOrderBase(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SaveOrderBase, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Desc: ����ɹ����뵥
function SaveOrderBaseSingle(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrderSingle(cBC_SaveOrderBase, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

function DeleteOrderBase(const nOrder: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_DeleteOrderBase, nOrder, '', @nOut);
end;

function DeleteOrderBaseSingle(const nOrder: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrderSingle(cBC_DeleteOrderBase, nOrder, '', @nOut);
end;

//����ɹ���ͬ
function SavePurchaseContract(const nData:string):string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SavePurchaseContract, nData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//����ɹ���ͬ
function SavePurchaseContractSingle(const nData:string):string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrderSingle(cBC_SavePurchaseContract, nData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//�޸Ĳɹ���ͬ
function ModifyPurchaseContract(const nData:string):string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_ModifyPurchaseContract, nData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//�޸Ĳɹ���ͬ
function ModifyPurchaseContractSingle(const nData:string):string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrderSingle(cBC_ModifyPurchaseContract, nData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//ɾ���ɹ���ͬ
function DeletePurchaseContract(const nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_DeletePurchaseContract, nData, '', @nOut);
end;

//ɾ���ɹ���ͬ
function DeletePurchaseContractSingle(const nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrderSingle(cBC_DeletePurchaseContract, nData, '', @nOut);
end;

//Date: 2014-09-15
//Parm: ��������
//Desc: ����ɹ���,���زɹ������б�
function SaveOrder(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SaveOrder, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Desc: ����ɹ���,���زɹ������б�
function SaveOrderSingle(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrderSingle(cBC_SaveOrder, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-15
//Parm: ��������
//Desc: ɾ��nBillID����
function DeleteOrder(const nOrder: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_DeleteOrder, nOrder, '', @nOut);
end;

//Desc: ɾ��nBillID����
function DeleteOrderSingle(const nOrder: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrderSingle(cBC_DeleteOrder, nOrder, '', @nOut);
end;

//Date: 2014-09-17
//Parm: ������;���ƺ�;У���ƿ�����
//Desc: ΪnBill�������ƿ�
function SetOrderCard(const nOrder,nTruck: string; nVerify: Boolean): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nOrder;
  nP.FParamB := nTruck;
  nP.FParamC := sFlag_Provide;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2014-09-17
//Parm: ��������;�ſ�
//Desc: ��nBill.nCard
function SaveOrderCard(const nOrder, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_SaveOrderCard, nOrder, nCard, @nOut);
end;

//Desc: ��nBill.nCard
function SaveOrderCardSingle(const nOrder, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrderSingle(cBC_SaveOrderCard, nOrder, nCard, @nOut);
end;

//Date: 2014-09-17
//Parm: �ſ���
//Desc: ע��nCard
function LogoutOrderCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_LogOffOrderCard, nCard, '', @nOut);
end;

//Desc: ע��nCard
function LogoutOrderCardSingle(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrderSingle(cBC_LogOffOrderCard, nCard, '', @nOut);
end;

//Date: 2014-09-15
//Parm: ������;�³���
//Desc: �޸�nOrder�ĳ���ΪnTruck.
function ChangeOrderTruckNo(const nOrder,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_ModifyBillTruck, nOrder, nTruck, @nOut);
end;

//Desc: �޸�nOrder�ĳ���ΪnTruck.
function ChangeOrderTruckNoSingle(const nOrder,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrderSingle(cBC_ModifyBillTruck, nOrder, nTruck, @nOut);
end;

//------------------------------------------------------------------------------
//Date: 2015/9/20
//Parm: ��Ӧ�������
//Desc: ��ȡ�ɹ����뵥������Ϣ
function GetGYOrderBaseValue(const nOrder: string): string;
var nOut: TWorkerBusinessCommand;
begin
   if CallBusinessPurchaseOrder(cBC_GetGYOrderValue, nOrder, '', @nOut) and
     (nOut.FData<>'') then
        Result := PackerDecodeStr(nOut.FData)
   else Result := '';
end;

//Date: 2017-11-22
//Parm: ��������,�̳����뵥
//Desc: ����ɾ��������Ϣ
procedure SaveWebOrderDelMsg(const nLID, nBillType: string);
var nStr, nWebOrderID: string;
    nBool: Boolean;
begin
  nStr := 'Select WOM_WebOrderID From %s Where WOM_LID=''%s'' ';
  nStr := Format(nStr, [sTable_WebOrderMatch, nLID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount <= 0 then
      Exit;
    //�ֹ���
    nWebOrderID := Fields[0].AsString;
  end;

  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Insert Into %s(WOM_WebOrderID,WOM_LID,WOM_StatusType,' +
            'WOM_MsgType,WOM_BillType) Values(''%s'',''%s'',%d,' +
            '%d,''%s'')';
    nStr := Format(nStr, [sTable_WebOrderMatch, nWebOrderID, nLID, c_WeChatStatusDeleted,
            cSendWeChatMsgType_DelBill, nBillType]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
  except
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: ��ȡ�ɹ����뵥������Ϣ
function GetGYOrderBaseValueSingle(const nOrder: string): string;
var nOut: TWorkerBusinessCommand;
begin
   if CallBusinessPurchaseOrderSingle(cBC_GetGYOrderValue, nOrder, '', @nOut) and
     (nOut.FData<>'') then
        Result := PackerDecodeStr(nOut.FData)
   else Result := '';
end;

//Date: 2014-09-17
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetPurchaseOrders(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

function GetPurchaseOrdersKS(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders_KS, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetPurchaseOrdersSingle(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrderSingle(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Date: 2014-09-18
//Parm: ��λ;�������б�;��վͨ��
//Desc: ����nPost��λ�ϵĽ���������
function SavePurchaseOrders(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_SavePostOrders, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //��������
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nList);
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

//Desc: ����nPost��λ�ϵĽ���������
function SavePurchaseOrdersSingle(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrderSingle(cBC_SavePostOrders, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //��������
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nList);
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

//Date: 2016-06-02
//Parm: ���̵�����
//Desc: ����̵���,���ض̵������б�
function SaveDDBases(const nDDData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessDuanDao(cBC_SaveBills, nDDData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2016-06-02
//Parm: �̵�����
//Desc: ɾ��nBillID����
function DeleteDDBase(const nBase: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_DeleteBill, nBase, '', @nOut);
end;

function DeleteDDDetial(const nDID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_DeleteOrder, nDID, '', @nOut);
end;

//Date: 2016-06-02
//Parm: �̵����,�ſ���
//Desc: �󶨴ſ�nCard
function SaveDDCard(const nBID, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_SaveBillCard, nBID, nCard, @nOut);
end;

//Date: 2016-06-02
//Parm: �ſ���
//Desc: ע��nCard
function LogoutDDCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_LogoffCard, nCard, '', @nOut);
end;

//Date: 2016-06-02
//Parm: �ſ���;��λ;�̵����б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ķ̵����б�
function GetDuanDaoItems(const nCard,nPost: string;
  var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Date: 2016-06-02
//Parm: ��λ;�̵����б�;��վͨ��
//Desc: ����nPost��λ�ϵĶ̵�������
function SaveDuanDaoItems(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessDuanDao(cBC_SavePostBills, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //��������
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nList);
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;


//Date: 2014-09-17
//Parm: ��������; MCListBox;�ָ���
//Desc: ��nItem����nMC
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('���ƺ���:%s %s', [nDelimiter, FTruck]));
    Add(Format('��ǰ״̬:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('��������:%s %s', [nDelimiter, FId]));
    Add(Format('��������:%s %.3f ��', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '��װ' else nStr := 'ɢװ';

    Add(Format('Ʒ������:%s %s', [nDelimiter, nStr]));
    Add(Format('Ʒ������:%s %s', [nDelimiter, FStockName]));
    
    Add(Format('%s ', [nDelimiter]));
    Add(Format('����ſ�:%s %s', [nDelimiter, FCard]));
    Add(Format('��������:%s %s', [nDelimiter, BillTypeToStr(FIsVIP)]));
    Add(Format('�ͻ�����:%s %s', [nDelimiter, FCusName]));
  end;
end;

//Date: 2014-09-17
//Parm: ��������; MCListBox;�ָ���
//Desc: ��nItem����nMC
procedure LoadOrderItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('���ƺ���:%s %s', [nDelimiter, FTruck]));
    Add(Format('��ǰ״̬:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('�ɹ�����:%s %s', [nDelimiter, FZhiKa]));
//    Add(Format('��������:%s %.3f ��', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '��װ' else nStr := 'ɢװ';

    Add(Format('Ʒ������:%s %s', [nDelimiter, nStr]));
    Add(Format('Ʒ������:%s %s', [nDelimiter, FStockName]));
    
    Add(Format('%s ', [nDelimiter]));
    Add(Format('�ͻ��ſ�:%s %s', [nDelimiter, FCard]));
    Add(Format('��������:%s %s', [nDelimiter, BillTypeToStr(FIsVIP)]));
    Add(Format('�� Ӧ ��:%s %s', [nDelimiter, FCusName]));
  end;
end;

//------------------------------------------------------------------------------
//Desc: ÿ���������
function GetHYMaxValue: Double;
var nStr: string;
begin
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_HYValue]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsFloat
  else Result := 0;
end;

//Desc: ��ȡnNoˮ���ŵ��ѿ���
function GetHYValueByStockNo(const nNo: string): Double;
var nStr: string;
begin
  nStr := 'Select R_SerialNo,Sum(H_Value) From %s ' +
          ' Left Join %s on H_SerialNo= R_SerialNo ' +
          'Where R_SerialNo=''%s'' Group By R_SerialNo';
  nStr := Format(nStr, [sTable_StockRecord, sTable_StockHuaYan, nNo]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[1].AsFloat
  else Result := -1;
end;

//Desc: ���nWeek�Ƿ���ڻ����
function IsWeekValid(const nWeek: string; var nHint: string): Boolean;
var nStr: string;
begin
  nStr := 'Select W_End,$Now From $W Where W_NO=''$NO''';
  nStr := MacroValue(nStr, [MI('$W', sTable_InvoiceWeek),
          MI('$Now', FDM.SQLServerNow), MI('$NO', nWeek)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsDateTime + 1 > Fields[1].AsDateTime;
    if not Result then
      nHint := '�ý��������ѽ���';
    //xxxxx
  end else
  begin
    Result := False;
    nHint := '�ý�����������Ч';
  end;
end;

//Desc: ���nWeek�Ƿ�������
function IsWeekHasEnable(const nWeek: string): Boolean;
var nStr: string;
begin
  nStr := 'Select Top 1 * From $Req Where R_Week=''$NO''';
  nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq), MI('$NO', nWeek)]);
  Result := FDM.QueryTemp(nStr).RecordCount > 0;
end;

//Desc: ���nWeek����������Ƿ�������
function IsNextWeekEnable(const nWeek: string): Boolean;
var nStr: string;
begin
  nStr := 'Select Top 1 * From $Req Where R_Week In ' +
          '( Select W_NO From $W Where W_Begin > (' +
          '  Select Top 1 W_Begin From $W Where W_NO=''$NO''))';
  nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq),
          MI('$W', sTable_InvoiceWeek), MI('$NO', nWeek)]);
  Result := FDM.QueryTemp(nStr).RecordCount > 0;
end;

//Desc: ���nWeeǰ��������Ƿ��ѽ������
function IsPreWeekOver(const nWeek: string): Integer;
var nStr: string;
begin
  nStr := 'Select Count(*) From $Req Where (R_ReqValue<>R_KValue) And ' +
          '(R_Week In ( Select W_NO From $W Where W_Begin < (' +
          '  Select Top 1 W_Begin From $W Where W_NO=''$NO'')))';
  nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq),
          MI('$W', sTable_InvoiceWeek), MI('$NO', nWeek)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsInteger
  else Result := 0;
end;

//Desc: �����û�������
function SaveCompensation(const nSaleMan,nCusID,nCusName,nPayment,nMemo: string;
 const nMoney: Double): Boolean;
var nStr: string;
    nBool: Boolean;
begin
  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Update %s Set A_Compensation=A_Compensation+%s Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nMoney), nCusID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Insert Into %s(M_SaleMan,M_CusID,M_CusName,M_Type,M_Payment,' +
            'M_Money,M_Date,M_Man,M_Memo) Values(''%s'',''%s'',''%s'',' +
            '''%s'',''%s'',%s,%s,''%s'',''%s'')';
    nStr := Format(nStr, [sTable_InOutMoney, nSaleMan, nCusID, nCusName,
            sFlag_MoneyFanHuan, nPayment, FloatToStr(nMoney),
            FDM.SQLServerNow, gSysParam.FUserID, nMemo]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
    Result := True;
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ӡ��ʶΪnID�����ۺ�ͬ
procedure PrintSaleContractReport(const nID: string; const nAsk: Boolean);
var nStr: string;
    nParam: TReportParamItem;
begin
  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ���ۺ�ͬ?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select sc.*,S_Name,C_Name From $SC sc ' +
          '  Left Join $SM sm On sm.S_ID=sc.C_SaleMan ' +
          '  Left Join $Cus cus On cus.C_ID=sc.C_Customer ' +
          'Where sc.C_ID=''$ID''';

  nStr := MacroValue(nStr, [MI('$SC', sTable_SaleContract),
          MI('$SM', sTable_Salesman), MI('$Cus', sTable_Customer),
          MI('$ID', nID)]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s] �����ۺ�ͬ����Ч!!';
    nStr := Format(nStr, [nID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := 'Select * From %s Where E_CID=''%s''';
  nStr := Format(nStr, [sTable_SContractExt, nID]);
  FDM.QuerySQL(nStr);

  nStr := gPath + sReportDir + 'SaleContract.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.Dataset2.DataSet := FDM.SqlQuery;
  FDR.ShowReport;
end;

//Desc: ��ӡֽ��
function PrintZhiKaReport(const nZID: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡֽ��?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select zk.*,C_Name,S_Name From %s zk ' +
          ' Left Join %s cus on cus.C_ID=zk.Z_Customer' +
          ' Left Join %s sm on sm.S_ID=zk.Z_SaleMan ' +
          'Where Z_ID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKa, sTable_Customer, sTable_Salesman, nZID]);
  
  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := 'ֽ����Ϊ[ %s ] �ļ�¼����Ч';
    nStr := Format(nStr, [nZID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := 'Select * From %s Where D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, nZID]);
  if FDM.QuerySQL(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] ��ֽ������ϸ';
    nStr := Format(nStr, [nZID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'ZhiKa.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.Dataset2.DataSet := FDM.SqlQuery;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: ��ӡ�վ�
function PrintShouJuReport(const nSID: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ�վ�?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where R_ID=%s';
  nStr := Format(nStr, [sTable_SysShouJu, nSID]);
  
  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := 'ƾ����Ϊ[ %s ] ���վ�����Ч!!';
    nStr := Format(nStr, [nSID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'ShouJu.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: ��ӡ�����
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
var nStr, nWeborderID : string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ�����?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nBill := AdjustListStrFormat(nBill, '''', True, ',', False);
  //�������
  
  nStr := ' Select *, C_NAME, L_Value as L_ValueEx '+
          ' From %s b Left Join %s c On b.L_CusID=c.C_ID Where L_ID In(%s)';
  nStr := Format(nStr, [sTable_Bill, sTable_Customer, nBill]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] �ļ�¼����Ч!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;
  nWeborderID := FDM.SqlTemp.FieldByName('L_WebOrderID').AsString;
  
  nStr := gPath + sReportDir + 'LadingBill.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;
  if Length(nWeborderID) > 1 then
  begin
    nStr := ' Select *, C_NAME, L_Value as L_ValueEx ' +
            ' From %s b Left Join %s c On b.L_CusID=c.C_ID Where L_WebOrderID = ''%s'' ';
    nStr := Format(nStr, [sTable_Bill, sTable_Customer, nWeborderID]);
    if FDM.QuerySQL(nStr).RecordCount > 1 then
    begin
      nParam.FName  := 'HKRecords';
      nParam.FValue := '';

      with FDM.SqlQuery do
      while not Eof do
      try
        nStr := FieldByName('L_ID').AsString;
        nParam.FValue := nParam.FValue + nStr + '.';
      finally
        Next;
      end;
    end
    else
    begin
      nParam.FName  := 'HKRecords';
      nParam.FValue := '';

      if FDM.SqlTemp.FieldByName('L_HKRecord').AsString <> '' then
      begin
        nStr := ' Select *, C_NAME, L_Value as  L_ValueEx '+
                ' From %s b Left Join %s c On b.L_CusID=c.C_ID Where L_HKRecord =''%s''';
        nStr := Format(nStr, [sTable_Bill, sTable_Customer,
                FDM.SqlTemp.FieldByName('L_HKRecord').AsString]);
        //xxxxx

        if FDM.QuerySQL(nStr).RecordCount > 0 then
        begin
          with FDM.SqlQuery do
          while not Eof do
          try
            nStr := FieldByName('L_ID').AsString;
            nParam.FValue := nParam.FValue + nStr + '.';
          finally
            Next;
          end;
        end;
      end else FDM.SqlQuery := FDM.SqlTemp;
    end;
  end
  else
  begin
    nParam.FName  := 'HKRecords';
    nParam.FValue := '';

    if FDM.SqlTemp.FieldByName('L_HKRecord').AsString<>'' then
    begin
      nStr := ' Select *, C_NAME, L_Value as L_ValueEx '+
              ' From %s b Left Join %s c On b.L_CusID=c.C_ID Where L_HKRecord =''%s''';
      nStr := Format(nStr, [sTable_Bill, sTable_Customer,
              FDM.SqlTemp.FieldByName('L_HKRecord').AsString]);
      //xxxxx

      if FDM.QuerySQL(nStr).RecordCount > 0 then
      begin
        with FDM.SqlQuery do
        while not Eof do
        try
          nStr := FieldByName('L_ID').AsString;
          nParam.FValue := nParam.FValue + nStr + '.';
        finally
          Next;
        end;
      end;
    end else FDM.SqlQuery := FDM.SqlTemp;
  end;
  FDR.AddParamItem(nParam);  

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.Dataset2.DataSet := FDM.SqlQuery;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;


//Date: 2012-4-1
//Parm: �ɹ�����;��ʾ;���ݶ���;��ӡ��
//Desc: ��ӡnOrder�ɹ�����
function PrintOrderReport(const nOrder: string;  const nAsk: Boolean;const nMul: Boolean = False): Boolean;
var nStr: string;
    nDS: TDataSet;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ�ɹ���?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;
  if nMul then
  begin
    nStr := 'Select * From %s oo Inner Join %s od on oo.O_ID=od.D_OID Where D_ID In (%s)';
  end
  else
  begin
    nStr := 'Select * From %s oo Inner Join %s od on oo.O_ID=od.D_OID Where D_ID=''%s''';
  end;
  nStr := Format(nStr, [sTable_Order, sTable_OrderDtl, nOrder]);

  nDS := FDM.QueryTemp(nStr);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nStr := '�ɹ���[ %s ] ����Ч!!';
    nStr := Format(nStr, [nOrder]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + 'Report\PurchaseOrder.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2012-4-15
//Parm: ��������;�Ƿ�ѯ��
//Desc: ��ӡnPound������¼
function PrintPoundReport(const nPound: string; nAsk: Boolean;const nMul: Boolean = False): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ������?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  if nMul then
    nStr := ' Select * From %s Where P_ID In (%s)'
  else
    nStr := ' Select * From %s Where P_ID=''%s'' ';

  nStr := Format(nStr, [sTable_PoundLog, nPound]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���ؼ�¼[ %s ] ����Ч!!';
    nStr := Format(nStr, [nPound]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'Pound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result  then
  begin
    nStr := 'Update %s Set P_PrintNum=P_PrintNum+1 Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nPound]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/4/4
//Parm: �̵�ID;�Ƿ��ӡ
//Desc: ��ӡ�̵���ϸ
function PrintDuanDaoReport(const nID: string; nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ�̵���?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where T_ID=''%s''';
  nStr := Format(nStr, [sTable_Transfer, nID]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '�̵���¼[ %s ] ����Ч!!';
    nStr := Format(nStr, [nID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'DuanDao.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: ��ȡnStockƷ�ֵı����ļ�
function GetReportFileByStock(const nStock: string): string;
begin
  Result := GetPinYinOfStr(nStock);

  if Pos('dj', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42_DJ.fr3'
  else if Pos('gsysl', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_gsl.fr3'
  else if Pos('kzf', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_kzf.fr3'
  else if Pos('qz', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_qz.fr3'
  else if Pos('32', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan32.fr3'
  else if Pos('42', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42.fr3'
  else if Pos('52', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42.fr3'
  else Result := '';
end;

//Desc: ��ӡ��ʶΪnHID�Ļ��鵥
function PrintHuaYanReport(const nHID, nStockName,nOutFact,nLID: string;
  const nAsk: Boolean): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '�Ƿ�Ҫ��ӡ���鵥?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  if not CallBusinessCommand(cBC_SyncYTBatchCodeInfo, nHID, '', @nOut) then Exit;

  if nLID = '' then
  begin
    nStr := 'Select OutFact=''%s'',* From %s Where Paw_Analy=''%s''';
    nStr := Format(nStr, [nOutFact,sTable_YT_Batchcode, nHID]);
  end
  else
  begin
    nStr := 'Select * From %s a , %s b Where a.PAW_Analy = b.L_HYDan and b.L_ID=''%s''';
    nStr := Format(nStr, [sTable_YT_Batchcode, sTable_Bill, nLID]);
  end;

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] �Ļ��鵥��¼����Ч!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := GetReportFileByStock(nStockName);

  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: ��ӡ��ʶΪnID�ĺϸ�֤
function PrintHeGeReport(const nHID: string; const nAsk: Boolean): Boolean;
var nStr,nSR: string;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '�Ƿ�Ҫ��ӡ�ϸ�֤?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  nSR := 'Select R_SerialNo,P_Stock,P_Name,P_QLevel From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,C_Name From $HY hy ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_ID in ($ID)';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nHID)]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] �Ļ��鵥��¼����Ч!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'HeGeZheng.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2015/1/18
//Parm: ���ƺţ����ӱ�ǩ���Ƿ����ã��ɵ��ӱ�ǩ
//Desc: ����ǩ�Ƿ�ɹ����µĵ��ӱ�ǩ
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;
var nP: TFormCommandParam;
begin
  nP.FParamA := nTruck;
  nP.FParamB := nOldCard;
  nP.FParamC := nIsUse;
  CreateBaseFormItem(cFI_FormMakeRFIDCard, '', @nP);

  nRFIDCard := nP.FParamB;
  nIsUse    := nP.FParamC;
  Result    := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2016/8/7
//Parm: ���ƺ�
//Desc: �鿴�����ϴι���ʱ����
function GetTruckLastTime(const nTruck: string): Integer;
var nStr: string;
    nNow, nPDate, nMDate: TDateTime;
begin
  Result := -1;
  //Ĭ������

  nStr := 'Select Top 1 %s as T_Now,P_PDate,P_MDate ' +
          'From %s Where P_Truck=''%s'' Order By P_ID Desc';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_PoundLog, nTruck]);
  //ѡ�����һ�ι���

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nNow   := FieldByName('T_Now').AsDateTime;
    nPDate := FieldByName('P_PDate').AsDateTime;
    nMDate := FieldByName('P_MDate').AsDateTime;

    if nPDate > nMDate then
         Result := Trunc((nNow - nPDate) * 24 * 60 * 60)
    else Result := Trunc((nNow - nMDate) * 24 * 60 * 60);
  end;
end;

function GetTruckIsQueue(const nTruck: string): Boolean;
var nStr: string;
    nNow, nPDate, nMDate: TDateTime;
begin
  Result := False;
  //Ĭ�ϲ�����
  nStr := ' Select T_InQueue From %s Where T_Truck=''%s'' and T_InQueue Is Not Null ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := True;
  end;
end;

function GetTruckIsOut(const nTruck: string): Boolean;
var nStr: string;
    nNow, nPDate, nMDate: TDateTime;
begin
  Result := False;
  //Ĭ�ϲ�����
  nStr := ' Select T_InQueue From %s Where T_Truck=''%s'' and T_InQueue Is Not Null and isnull(T_Valid,''Y'') = ''N'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := True;
  end;
end;

//Date: 2017/5/18
//Parm: ���ƺ���
//Desc: ��ȡ�������õĵ��ӱ�ǩ
function GetTruckRealLabel(const nTruck: string): string;
var nStr: string;
begin
  Result := '';
  //Ĭ������

  nStr := 'Select Top 1 T_Card From %s ' +
          'Where T_Truck=''%s'' And T_CardUse=''%s'' And T_Card Is not NULL';
  nStr := Format(nStr, [sTable_Truck, nTruck, sFlag_Yes]);
  //ѡ��ó���һ���е��ӱ�ǩ�ļ�¼

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString;
end;

//��ȡ���ӱ�ǩ��Ӧ�󶨵ĳ���
function GetRealLabelTruck(const nELabel: string): string;
var nStr: string;
begin
  Result := '';
  //Ĭ������

  nStr := 'Select Top 1 T_Truck From %s ' +
          'Where  T_Card=''%s'' And T_CardUse=''%s'' And T_Card Is not NULL';
  nStr := Format(nStr, [sTable_Truck, nELabel, sFlag_Yes]);
  //ѡ��ó���һ���е��ӱ�ǩ�ļ�¼

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString;
end;

//��ȡ���ӱ�ǩ��Ӧ�ĵ���
function GetELabelBillOrder(const nELabel: string): string;
var nStr: string;
begin
  Result := '';
  //���ȴ�����������ң��Ҳ�����ȥ�ɹ�����������
  nStr := ' Select L_ID From %s Where L_Card = ''%s'' ';
  nStr := Format(nStr, [sTable_Bill, nELabel]);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
    Exit;
  end;
  //���ȴ�����������ң��Ҳ�����ȥ�ɹ�����������
  nStr := ' Select O_ID From %s Where O_Card = ''%s'' ';
  nStr := Format(nStr, [sTable_Order, nELabel]);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
  end;
end;

//��ȡ���Ŷ�Ӧ������
function GetBillOrderType(const nBillID: string): string;
var nStr: string;
begin
  Result := '';
  //���ȴ�����������ң��Ҳ�����ȥ�ɹ�����������
  nStr := ' Select L_ID From %s Where L_ID = ''%s'' ';
  nStr := Format(nStr, [sTable_Bill, nBillID]);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := sFlag_SaleSingle;
    Exit;
  end;
  //���ȴ�����������ң��Ҳ�����ȥ�ɹ�����������
  nStr := ' Select O_ID From %s Where O_ID = ''%s'' ';
  nStr := Format(nStr, [sTable_Order, nBillID]);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := sFlag_Provide;
  end;
end;

//Date: 2017/3/6
//Parm: ���������[nReader];����������[nType]
//Desc: �򿪵�բ
function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_OpenDoorByReader, nReader, nType,
            @nOut, False);
end;

function RemoteImportPounds(const nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_ImportOrderPoundS, nData, '', @nOut);
end;

function RemoteImportPoundsSingle(const nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrderSingle(cBC_ImportOrderPoundS, nData, '', @nOut);
end;

//Date: 2014-07-03
//Parm: ͨ����
//Desc: ��ѯnTunnel�Ĺ�դ״̬�Ƿ�����
function IsTunnelOK(const nTunnel: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_IsTunnelOK, nTunnel, '', @nOut);
  if not Result then Exit;
  Result := nOut.FData = sFlag_Yes;
end;

function IsTruckQueue(const nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_IsTruckQueue, nTruck, '', @nOut);
end;

procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nOpen then
       nStr := sFlag_Yes
  else nStr := sFlag_No;
  CallBusinessHardware(cBC_TunnelOC, nTunnel, nStr, @nOut);
end;

//��ȡ�ͻ�ע����Ϣ
function getCustomerInfo(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_getCustomerInfo, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

function IsAsternStock(const nStockName :string): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Value=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundAsternM, nStockName]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := True;
  //xxxxx
end;

function GetHYMBInfo(const nCusID,nStockName :string):string;
var nStr: string;
begin
  Result := nStockName;
  nStr := 'Select S_StockNameEx From %s Where S_CusID=''%s'' and S_StockName=''%s'' ';
  nStr := Format(nStr, [sTable_HYMBWH, nCusID, nStockName]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString;
  //xxxxx
end;


//------------------------------------------------------------------------------
//��ȡ�ͻ�ע����Ϣ
function getCustomerInfoEx(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_getCustomerInfo, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//�ͻ���΢���˺Ű�
function get_Bindfunc(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_get_Bindfunc, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//������Ϣ
function send_event_msg(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_send_event_msg, nXmlStr, '', @nOut,false) then
    Result := nOut.FData;
end;

//�����̳��û�
function edit_shopclients(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_edit_shopclients, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//�����̳��û�
function edit_shopclientsEx(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_edit_shopclients, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//�����Ʒ
function edit_shopgoods(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_edit_shopgoods, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//��ȡ������Ϣ
function get_shoporders(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_get_shoporders, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//���¶���״̬
function complete_shoporders(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if not CallBusinessCommand(cBC_WeChat_complete_shoporders, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//Date: 2016/11/27
//Parm: ��������
//Desc: �ж��Ƿ�����Ԥ����Χ
function VerifyPoundWarning(var nHint: string; var nWarnVal: Double): Boolean;
var nStr, nWarn: string;
begin
  nWarn := '';
  Result:= False;
  //init

  nStr := 'Select D_Value from %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundWarning]);


  with FDM.QueryTemp(nStr, False) do
  if RecordCount > 0 then nWarn := Fields[0].AsString;

  if  Length(nWarn) = 0 then
  begin
     nHint := '������Ƥ��Ԥ����Χ';
     Exit;
  end;

  Result := True;
  nWarnVal := StrToFloatDef(nWarn, 0);
end;

//Date: 2016/11/27
//Parm: ��������
//Desc: ����쳣�¼�����
function AddManualEventRecord(nEID, nKey, nEvent:string;
    nFrom: string; nSolution: string; nDepartmen: string;
    nReset: Boolean; nMemo: string): Boolean;
var nSQL, nStr: string;
    nUpdate: Boolean;
begin
  Result := False;
  //init

  if Trim(nSolution) = '' then
  begin
    WriteLog('��ѡ������.');
    Exit;
  end;

  nSQL := 'Select * From %s Where E_ID=''%s''';
  nSQL := Format(nSQL, [sTable_ManualEvent, nEID]);
  with FDM.QuerySQL(nSQL) do
  if RecordCount > 0 then
  begin
    nStr := '�¼���¼:[ %s ]�Ѵ���';
    nStr := Format(nStr, [nEID]);
    WriteLog(nStr);

    if not nReset then Exit;

    nUpdate := True;
  end else nUpdate := False;

  nStr := SF('E_ID', nEID);
  nSQL := MakeSQLByStr([
          SF('E_ID', nEID),
          SF('E_Key', nKey),
          SF('E_Result', ''),
          SF('E_From', nFrom),
          SF('E_Memo', nMemo),
          
          SF('E_Event', nEvent), 
          SF('E_Solution', nSolution),
          SF('E_Departmen', nDepartmen),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  FDM.ExecuteSQL(nSQL);
end;

//Date: 2016/11/27
//Parm: �¼�ID;Ԥ�ڽ��;���󷵻�
//Desc: �ж��¼��Ƿ���
function VerifyManualEventRecord(const nEID: string; var nHint: string;
    const nWant: string; const nUpdateHint: Boolean): Boolean;
var nSQL, nStr: string;
begin
  Result := False;
  //init

  nSQL := 'Select E_Result, E_Event, E_ParamB  From %s Where E_ID=''%s''';
  nSQL := Format(nSQL, [sTable_ManualEvent, nEID]);

  with FDM.QuerySQL(nSQL) do
  if RecordCount > 0 then
  begin
    nStr := Trim(FieldByName('E_Result').AsString);
    if nStr = '' then
    begin
      if nUpdateHint then
        nHint := FieldByName('E_Event').AsString;
      Exit;
    end;

    if nStr <> nWant then
    begin
      if nUpdateHint then
        nHint := '����ϵ����Ա������Ʊ����';
      Exit;
    end;

    if nUpdateHint then
      nHint  := FieldByName('E_ParamB').AsString;
    Result := True;
  end;
end;

function PoundDaiWCEx:Boolean;
var nSQL, nStr: string;
begin
  Result := False;

  nSQL := ' Select D_Value From %s Where D_Name = ''%s'' and D_Memo = ''%s'' ';
  nSQL := Format(nSQL, [sTable_SysDict, 'SysParam','PoundDaiWCEx']);
  with FDM.QuerySQL(nSQL) do
  if RecordCount > 0 then
  begin
    nStr := Trim(FieldByName('D_Value').AsString);
    if nStr = 'Y' then
    begin
      Result := True;
    end;
  end;
end;

//Parm: �¼�ID;Ԥ�ڽ��;���󷵻�
//Desc: �ж��¼��Ƿ���
function VerifyManualEventRecordEx(const nEID: string; var nHint: string;
 const nWant: string; const nUpdateHint: Boolean): Boolean;
var nStr: string;
begin
  Result := True;
  nStr := 'Select E_Result, E_Event From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    nStr := Trim(FieldByName('E_Result').AsString);
    if nStr = '' then
    begin
      if nUpdateHint then
        nHint := FieldByName('E_Event').AsString;
      Result := False;
      Exit;
    end;

    if nStr <> nWant then
    begin
      if nUpdateHint then
        nHint := '����ϵ����Ա������Ʊ����';
      Result := False;
      Exit;
    end;

    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/4/1
//Parm: �������¼�ID;������
//Desc: ��������һ��������Ϣ
function DealManualEvent(const nEID, nResult: string): Boolean;
var nStr,nSQL,nMsg: string;
    m, f, nValue: Double;
    nList, nListB: TStrings;
    nBills: TLadingBillItems;
begin
  Result := True;

  if (Copy(nEID, Length(nEID), 1) = sFlag_ManualD) and (nResult = sFLag_Yes) then
  begin //ɢװ����,���ҵ�������
    nStr := '';
    Result := False;
    //Ĭ�ϴ���ʧ��

    nSQL := 'Select E_Memo From %s Where E_ID=''%s''';
    nSQL := Format(nSQL, [sTable_ManualEvent, nEID]);

    with FDM.QueryTemp(nSQL) do
    if RecordCount > 0 then
    begin
      nList := TStringList.Create;
      nListB:= TStringList.Create;
      try
        SplitStr(FieldByName('E_Memo').AsString, nList, 0, ';', False);

        if not GetLadingBills(nList.Values['Pound_Card'], sFlag_TruckBFM,
          nBills) then
          Exit;

        nStr := nBills[0].FProject;
        //ԭʼ��Ʊ��

        if not (YT_ReadCardInfo(nStr) and
          YT_VerifyCardInfo(nStr, sFlag_AllowZeroNum)) then
        begin
          ShowDlg(nStr, sHint);
          Exit;
        end;

        nListB.Text := PackerDecodeStr(nStr);
        //��ȡ����
        m := StrToFloat(nListB.Values['XCB_RemainNum']);
        //����ʣ����

        nValue := StrToFloat(nList.Values['Pound_MValue'])-nBills[0].FPData.FValue;

        f := nValue - nBills[0].FValue;
        //�������;��ز��
        nStr := '�������[%s]��������:' + #13#10 +
                '��.�������: %s��' + #13#10 +
                '��.�� Ʊ ��: %s��' + #13#10 +
                '��.����ʣ��: %s��' + #13#10 +
                '��.��������: %s��' + #13#10 +
                '��˶���Ϣ!';
        nStr := Format(nStr, [nBills[0].FID, FloatToStr(nValue),
                FloatToStr(nBills[0].FValue),FloatToStr(m),FloatToStr(f)]);
        WriteLog(nStr);
        //xxxxx

        with nBills[0] do
        begin
          with FMData do
          begin
            FStation := nList.Values['MStation'];
            FValue := StrToFloat(nList.Values['Pound_MValue']);
            FOperator := gSysParam.FUserID;
          end;

          nStr := '';
          m := f - m;
          //�������Ƿ���
          if m > 0 then
          begin
            nStr := '�ͻ�[ %s.%s ]������û���㹻����,��������:' + #13#10#13#10 +
                    '��.�������: %s' + #13#10 +
                    '��.�������: %.2f��' + #13#10 +
                    '��.�� �� ��: %.2f��' + #13#10+#13#10 +
                    '�뵽��Ʊ�Ұ���������.���п��������,����"��"��ť����.';
            //xxxxx

            nStr := Format(nStr, [FCusID, FCusName,
                    FProject, nValue, m]);
            WriteLog(nStr);
            if not QueryDlg(nStr, sHint) then Exit;

            while True do
            begin
              if not ShowInputBox('�������µ��������:', 'ɢװ����ҵ��', nStr) then
                Exit;
              nStr := Trim(nStr);

              if (nStr = '') or  (CompareText(nStr, nBills[0].FProject) = 0) then
              begin
                ShowMsg('����������', sHint);
                Continue;
              end;

              FMemo := nStr;
              FKZValue := m;
              Break;
            end;
          end;

          //ɢװ������Ϣ

          FPoundID := sFlag_Yes;
          //��Ǹ����г�������
          {$IFDEF SanCFNeedPound}
          Result := SaveLadingBills(sFlag_TruckFH, nBills,nMsg);
          {$ELSE}
          Result := SaveLadingBills(sFlag_TruckBFM,nBills,nMsg);
          {$ENDIF}
          //�������
        end;
      finally
        FreeAndNil(nList);
      end;
    end;
  end;
end;

//Date: 2017/11/28
//Parm: ��������
//lih: ����Զ������¼�����ֱ���Ѵ���
function AddManualEventRecordOver(nEID, nKey, nEvent:string;
    nFrom: string; nSolution: string; nDepartmen: string;
    nReset: Boolean; nMemo: string): Boolean;
var nSQL, nStr: string;
    nUpdate: Boolean;
begin
  Result := False;
  //init

  if Trim(nSolution) = '' then
  begin
    WriteLog('��ѡ������.');
    Exit;
  end;

  nSQL := 'Select * From %s Where E_ID=''%s''';
  nSQL := Format(nSQL, [sTable_ManualEvent, nEID]);
  with FDM.QuerySQL(nSQL) do
  if RecordCount > 0 then
  begin
    nStr := '�¼���¼:[ %s ]�Ѵ���';
    nStr := Format(nStr, [nEID]);
    WriteLog(nStr);

    if not nReset then Exit;

    nUpdate := True;
  end else nUpdate := False;

  nStr := SF('E_ID', nEID);
  nSQL := MakeSQLByStr([
          SF('E_ID', nEID),
          SF('E_Key', nKey),
          SF('E_Result', sFlag_Yes),
          SF('E_From', nFrom),
          SF('E_Memo', nMemo),

          SF('E_Event', nEvent),
          SF('E_Solution', nSolution),
          SF('E_Departmen', nDepartmen),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  FDM.ExecuteSQL(nSQL);
end;

//Desc: ��ȡջ̨�����б�nList��,������������
function LoadZTLineGroup(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'D_Value=Select D_Value,D_Memo,D_ParamB From %s ' +
          'Where D_Name=''%s'' %s Order By D_Value';
  nStr := Format(nStr, [sTable_SysDict, sFlag_ZTLineGroup, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['D_Value']));

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//Desc: ��ȡջ̨�б�nList��,������������
function LoadZTLines(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'Z_ID=Select Z_ID,Z_Name From %s ' +
          'Where Z_Index>=0 %s Order By Z_Index';
  nStr := Format(nStr, [sTable_ZTLines, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['Z_ID']));

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//------------------------------------------------------------------------------
//Date: 2017/4/9
//Parm: [Out]��װ�����;[Out]��װ�����;[In]����;[In]�ذ�
//Desc: ��ȡ��վ���
procedure GetPoundAutoWuCha(var nWCValZ, nWCValF: Double;
    const nVal: Double; const nStation: string);
var nSQL: string;
begin
  nWCValZ := 0;
  nWCValF := 0;
  //init

  if nVal <= 0 then Exit;
  //��Ʊ��Ϊ0

  nSQL := 'Select * From %s Where P_Start < %s and P_End >= %s';
  nSQL := Format(nSQL, [sTable_PoundDaiWC, FloatToStr(nVal), FloatToStr(nVal)]);

  if Length(nStation) > 0 then
    nSQL := nSQL + ' And P_Station=''' + nStation + '''';

  with FDM.QuerySQL(nSQL) do
  if RecordCount > 0 then
  begin
    if FieldByName('P_Percent').AsString = sFlag_Yes then
    begin     //�������������
      nWCValZ := nVal * 1000 * FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := nVal * 1000 * FieldByName('P_DaiWuChaF').AsFloat;
    end else

    begin     //���̶�ֵ�������
      nWCValZ := FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := FieldByName('P_DaiWuChaF').AsFloat;
    end;
  end;
end;

procedure ProberShowTxt(const nTunnel, nText: string);
var nOut: TWorkerBusinessCommand;
begin
  CallBusinessHardware(cBC_ShowTxt, nTunnel, nText, @nOut);
end;

function GetBillType(const nLID:string;var nDispatchNo:string): Boolean;
var
  nSQL, nXmlStr, nData, nWebOrderID:string;
  i:Integer;
begin
  Result := False;

  nSQL := 'Select L_DispatchNo From %s Where L_ID = ''%s'' ';
  nSQL := Format(nSQL, [sTable_Bill, nLID]);
  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
  begin
    if Trim(FieldByName('L_DispatchNo').AsString) <> '' then
    begin
      nDispatchNo := Trim(FieldByName('L_DispatchNo').AsString);
      Result      := True;
    end;
  end;
end;

//��ȡ΢�źϵ���
function ReadWxHdOrderId(const nLID:string):string;
var
  nSQL, nXmlStr, nData, nWebOrderID:string;
  nListA,nListB:TStringList;
  i:Integer;
  nWebOrderCount:Integer;
  nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nSQL := 'Select WOM_WebOrderID From %s Where WOM_LID=''%s''';
  nSQL := Format(nSQL, [sTable_WebOrderMatch, nLID]);

  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
  begin
    nWebOrderID := FieldByName('WOM_WebOrderID').AsString;
    nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'      <NO>%s</NO>'
            +'      <status>0</status>'  //-1  ����    0  �����ɹ�
            +'</head>'
            +'</DATA>';

    nXmlStr := Format(nXmlStr,[gSysParam.FFactory, nWebOrderID]);
    WriteLog(nXmlStr);
    nXmlStr := PackerEncodeStr(nXmlStr);

    if CallBusinessCommand(cBC_WeChat_get_shoporderbyno, nXmlStr, '', @nOut, False) then
      nData := nOut.FData
    else begin
      ShowMsg('δ��ѯ�������̳Ƕ�����ϸ��Ϣ�����鶩�����Ƿ���ȷ',sHint);
      Writelog('δ��ѯ�������̳Ƕ�����ϸ��Ϣ�����鶩�����Ƿ���ȷ');
      Exit;
    end;
    //�������Ƕ�����Ϣ
    nData := PackerDecodeStr(nData);
    Writelog('get_shoporderbyno res:'+nData);
    nListA := TStringList.Create;
    nListB := TStringList.Create;
    try
      nListA.Text := nData;
      for i := nListA.Count-1 downto 0 do
      begin
        if Trim(nListA.Strings[i])='' then
        begin
          nListA.Delete(i);
        end;
      end;

      nWebOrderCount := nListA.Count;
      for i := 0 to nWebOrderCount-1 do
      begin
        nListB.CommaText := nListA.Strings[i];
        Result := nListB.Values['hd_fac_order_no'];
      end;
    finally
      nListB.Free;
      nListA.Free;
    end;
  end else
  begin
    ShowMsg(nLID + 'δ��ѯ�������������', sHint);
    WriteLog(nLID + 'δ��ѯ�������������');
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017-10-17
//Parm: ���ƺ�;��������
//Desc: ��nTruck����Ϊ����ΪnLen���ַ���
function GetTruckNO(const nTruck: WideString; const nLong: Integer): string;
var nStr: string;
    nIdx,nLen,nPos: Integer;
begin
  nPos := 0;
  nLen := 0;

  for nIdx:=Length(nTruck) downto 1 do
  begin
    nStr := nTruck[nIdx];
    nLen := nLen + Length(nStr);

    if nLen >= nLong then Break;
    nPos := nIdx;
  end;

  Result := Copy(nTruck, nPos, Length(nTruck));
  nIdx := nLong - Length(Result);
  Result := Result + StringOfChar(' ', nIdx);
end;

function GetValue(const nValue: Double): string;
var nStr: string;
begin
  nStr := Format('      %.2f', [nValue]);
  Result := Copy(nStr, Length(nStr) - 6 + 1, 6);
end;

function AdjustBillStatus(const nLID, nStatus, nNextStatus: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Update %s Set L_Status=''%s'',L_NextStatus=''%s'' Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nStatus, nNextStatus, nLID]);
  FDM.ExecuteSQL(nStr);

  Result := True;
end;

//Desc: ��ȡ��λ��ŵ�nList��
function LoadCk(const nList: TStrings): Boolean;
var nStr: string;
begin
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_HYPackers]);

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    nStr := ','+Fields[0].AsString;
    SplitStr(nStr, nList, 0, ',', False);
  end;

  Result := nList.Count > 0;
end;

function GetCusName(const nCusID: string): string;
var nStr: string;
begin
  Result := nCusID;
  nStr := ' Select C_Name From %s Where C_ID=''%s'' ';
  nStr := Format(nStr, [sTable_Customer, nCusID]);

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
  end;
end;

function VerifyFQSumValue: Boolean;
var nStr: string;
begin
  Result := False;
  //Ĭ�ϲ��ж�

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_VerifyFQValue]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString = sFlag_Yes;
end;

function GetFQValueByStockNo(const nStock: string): Double;
var nSQL: string;
begin
  Result := 0;
  if nStock = '' then Exit;

  nSQL := 'Select Sum(L_Value) From %s Where L_Seal=''%s'' ' +
          'and L_Date > GetDate() - 30';   //һ�����ڵ��ܼ�
  nSQL := Format(nSQL, [sTable_Bill, nStock]);
  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
end;

//Date: 2018-08-16
//Parm: ��������
//Desc: ���潻����,���ؽ��������б�
function SaveBillSingle(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessSaleBillSingle(cBC_SaveBills, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2018-08-16
//Parm: ��������
//Desc: ɾ��nBillID����
function DeleteBillSingle(const nBill: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBillSingle(cBC_DeleteBill, nBill, '', @nOut);
end;

//Date: 2018-08-16
//Parm: ��������;�ſ�
//Desc: ��nBill.nCard
function SaveBillCardSingle(const nBill, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBillSingle(cBC_SaveBillCard, nBill, nCard, @nOut);
end;

//Date: 2018-08-16
//Parm: �ſ���
//Desc: ע��nCard
function LogoutBillCardSingle(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBillSingle(cBC_LogoffCard, nCard, '', @nOut);
end;

function getPrePInfo(const nTruck:string;var nPrePValue: Double; var nPrePMan: string;
  var nPrePTime: TDateTime):Boolean;
var
  nStr:string;
begin
  Result := False;
  nPrePValue := 0;
  nPrePMan := '';
  nPrePTime := 0;

  nStr := 'select T_PrePValue,T_PrePMan,T_PrePTime from %s where t_truck=''%s'' and T_PrePUse=''%s''';
  nStr := format(nStr,[sTable_Truck,nTruck,sflag_yes]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      nPrePTime := FieldByName('T_PrePTime').asDateTime;
      nPrePValue := FieldByName('T_PrePValue').asFloat;;
      nPrePMan := FieldByName('T_PrePMan').asString;
      Result := True;
    end;
  end;
end;

function GetPOrderDtlStatus(const nID:string):Boolean;
var
  nStr:string;
begin
  Result := True;

  nStr   := ' Select D_Status, D_NextStatus from %s where D_ID = ''%s'' ';
  nStr   := format(nStr,['P_OrderDtl',nID]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      if (Trim(FieldByName('D_Status').asString) = 'M')
        and (Trim(FieldByName('D_NextStatus').asString) = 'M')  then
      begin
        Result := False;
      end;
    end;
  end;
end;

function GetPrePValueSet: Double;
var nStr: string;
begin
  Result := 30;//init

  nStr := 'Select D_Value From $Table ' +
          'Where D_Name=''$Name'' and D_Memo=''$Memo''';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_SysParam),
                            MI('$Memo', sFlag_SetPValue)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
      nStr := Fields[0].AsString;
    if IsNumber(nStr,True) then
      Result := StrToFloatDef(nStr,30);
  end;
end;

procedure SaveTruckPrePValue(const nTruck, nValue: string);
var nStr: string;
begin
  {$IFNDEF NoUpdatePrePValue}
  nStr := 'update %s set T_PrePValue=%s,T_PrePMan=''%s'',T_PrePTime=%s '
          + ' where t_truck=''%s'' and T_PrePUse=''%s''';
  nStr := format(nStr,[sTable_Truck,nValue,gSysParam.FUserName
                      ,sField_SQLServer_Now,nTruck,sflag_yes]);
  FDM.ExecuteSQL(nStr);
  {$ENDIF}
end;

procedure UpdateTruckStatus(const nID: string);
var nStr: string;
begin
  nStr := 'update %s set D_Status=''%s'',D_NextStatus=''%s'', D_IsMT = 1 '
          + ' where D_ID=''%s''';
  nStr := format(nStr,[sTable_OrderDtl,sFlag_TruckBFM,
                       sFlag_TruckBFM,nID]);
  FDM.ExecuteSQL(nStr);
end;

//Date: 2014-09-18
//Parm: ���ƺ�;��վͨ��
//Desc: ����nTruck��Ԥ��Ƥ����Ƭ
function SaveTruckPrePicture(const nTruck: string;const nTunnel: PPTTunnelItem): Boolean;
var nStr,nRID: string;
    nIdx: Integer;
    nList: TStrings;
begin
  Result := False;
  nRID := '';
  nStr := 'Select R_ID From %s Where T_Truck =''%s'' order by R_ID desc ';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount <= 0 then
      Exit;
    nRID := Fields[0].AsString;
  end;

  nStr := 'Delete from %s where P_ID=''%s'' ';
  nStr := format(nStr,[sTable_Picture, nRID]);
  FDM.ExecuteSQL(nStr);

  if Assigned(nTunnel) then //��������
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nList);    //nLogin,
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nRID, nTruck, '', nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

//Date: 2018-08-16
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingBillsSingle(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBillSingle(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Date: 2018-08-16
//Parm: ��λ;�������б�;��վͨ��
//Desc: ����nPost��λ�ϵĽ���������
function SaveLadingBillsSingle(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBillSingle(cBC_SavePostBills, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //��������
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nList);
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

function IsLocalStock(const nStockNo: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := 'select D_Memo from %s where D_ParamB=''%s'' and D_Index=2';
  nStr := Format(nStr,[sTable_SysDict,nStockNo]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := True;
    end;
  end;
end;

//Desc: ��ȡ�ͻ������趨
function GetCusSpecialSet(const nCusID, nStockNo: string;
                          var nCk: string): Boolean;
var nStr: string;
begin
  Result := False;
  nCk := '';

  nStr := 'Select * From %s Where M_CusID like ''%s'' and M_StockNo = ''%s'' ';
  nStr := Format(nStr, [sTable_YT_CusBatMap, nCusID, nStockNo]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nCk := Trim(FieldByName('M_Ck').AsString);
      Result := FieldByName('M_IsVip').AsString = sFlag_TypeVIP;
    end;
  end;
end;

end.
