{*******************************************************************************
  ����: dmzn@163.com 2017-10-25
  ����: ΢�����ҵ������ݴ���
*******************************************************************************}
unit UWorkerBussinessWebchat;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, DB, ADODB, NativeXml, UBusinessWorker,
  UBusinessPacker, UBusinessConst, UMgrDBConn, UMgrParam, UFormCtrl, USysLoger,
  ZnMD5, ULibFun, USysDB, UMITConst, UMgrChannel, DateUtils, IdURI, HTTPApp,
  {$IFDEF WXChannelPool}Wechat_Intf, {$ELSE}WeChat_soap, {$ENDIF}IdHTTP,
  Graphics,UWorkerSelfRemote, uSuperObject;

const
  cHttpTimeOut          = 10;
  //HostUrl               = 'http://hnzhixinkeji.cn/zshop/ssp';  //'http://192.168.2.112/zshop/ssp';
  Cus_activeCode        = 'ZSHOP001';
  Cus_BindCode          = 'ZSHOP002';
  Cus_ShopOrder         = 'ZSHOP003';
  Cus_syncShopOrder     = 'ZSHOP004';
  Cus_ShopTruck         = 'ZSHOP005';
  Cus_syncTruckState    = 'ZSHOP006';
  Cus_TruckQueuedInfo   = 'ZSHOP012';
type
  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    {$IFDEF WXChannelPool}
    FWXChannel: PChannelItem;
    {$ELSE} //΢��ͨ��
    FWXChannel: ReviceWS;
    {$ENDIF}
    FDataIn, FDataOut: PBWDataBase;
    //��γ���
    FDataOutNeedUnPack: Boolean;
    //��Ҫ���
    FPackOut: Boolean;
    procedure GetInOutData(var nIn, nOut: PBWDataBase); virtual; abstract;
    //�������
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //��֤���
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //����ҵ��
  public
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  end;

  TBusWorkerBusinessWebchat = class(TMITDBWorker)
  private
    FListA, FListB, FListC, FListF : TStrings;
    //list
    FIn: TWorkerWebChatData;
    FOut: TWorkerWebChatData;
    //in out
    FIdHttp: TIdHTTP;
    FUrl: string;
  protected
    procedure ReQuestInit;
    procedure GetInOutData(var nIn, nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function UnPackIn(var nData: string): Boolean;
    procedure BuildDefaultXML;
    function FormatJson(nStrJson: string): string;
    procedure SaveAuditTruck(nList: TStrings; nStatus: string);
    function ParseDefault(var nData: string): Boolean;
    function GetTruckByLine(nStockNo: string): string;
    //����ˮ��Ʒ�ֻ�ȡ������ǰװ������
    function GetStockName(nStockNo: string): string;
    //��ȡ��������
    function GetCusName(nCusID: string): string;
    //��ȡ�ͻ�����
    function Get_ShopordersYY(var nData: string): Boolean;                      // Dl--->WxService
    //��ȡԤԼ������Ϣ
    function GetOrderCreateStatus(nCID, nMID, nOID: string;nValue:Double;
             var nMax:Double;var ReData:string;var nCanCreate:Boolean): Boolean;
    function IsCanCreateWXOrder(var nData: string): Boolean;
    //�µ�У��

    function GetCustomerValidMoney(nCustomer: string): Double;
    //��ȡ�ͻ����ý�
    function GetCustomerValidMoneyFromK3(nCustomer: string): Double;
    //��ȡ�ͻ����ý�(K3)
    function GetInOutValue(nBegin, nEnd, nType: string): string;
    //��ȡ����������ͳ����������
    function SaveDBImage(const nDS: TDataSet; const nFieldName: string; const nStream: TMemoryStream): Boolean;
    function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
    //��ȡϵͳ�ֵ���
    function GetOrderList(var nData: string): Boolean;
    //��ȡ�����б� 4.2�����ѯ�����ͻ���ͬ����
    function GetOrderList_JY(var nData: string): Boolean;
    //��ȡ�����б�(����)
    function GetOrderList_JM(var nData: string): Boolean;
     //��ȡ�����б�(����)
    function GetCustomerValidMoneyEx(nCustomer: string): Double;
    //��ȡ�ͻ����ý�Ex
    function GetOrderList_ZX(var nData: string): Boolean;
     //��ȡ�����б�(����)
    function GetOrderInfo(var nData: string): Boolean;
    //��ȡ������Ϣ

    function VerifyPrintCode(var nData: string): Boolean;
    //��֤������Ϣ
    function GetWaitingForloading(var nData: string): Boolean;
    //������װ��ѯ
    function GetPurchaseContractList(var nData: string): Boolean;
    //��ȡ�ɹ���ͬ�б����������µ�
    function Send_Event_Msg(var nData: string): boolean;
    //������Ϣ
    function Edit_Shopgoods(var nData: string): boolean;
    //�����Ʒ
    function complete_shoporders(var nData: string): Boolean;
    //�޸Ķ���״̬
    function GetCusMoney(var nData: string): Boolean;
    //��ȡ�ͻ��ʽ�
    function GetInOutFactoryTotal(var nData: string): Boolean;
    //����������ѯ���ɹ������������۳�������
    function getDeclareCar(var nData: string): Boolean;
    //���س��������Ϣ
    function UpdateDeclareCar(var nData: string): Boolean;
    //������˽���ϴ����󶨻������ڿ�����
    function DownLoadPic(var nData: string): Boolean;
    //����ͼƬ
    function get_shoporderByTruck(var nData: string): boolean;
    //���ݳ��ƺŻ�ȡ������Ϣ
    function get_QueueInfobyTruck(var nData: string): Boolean;
    //���ݳ��ƺŻ�ȡ������������Ϣ
    function get_LineInfobyTruck(var nData: string): Boolean;
    //�������������Ŷ�ͨ����ѯ
    function get_ClientReportInfo(var nData: string): Boolean;
    //���ݿͻ���Ų�ѯ�ͻ�������Ϣ
    function get_TruckMaxBillNumInfo(var nData: string): Boolean;
    //���ݳ��ƺŻ�ȡ�������ض�����Ϣ
    function GetOrderYYValue(nMID, nOID: string): Currency;
    //��ȡ�µ�����
    function synchronizedYYOrders(var nData: string): Boolean;
    //����״̬ͬ��

    function GetCustomerInfo(var nData: string): Boolean;                       // Dl--->WxService
    //��ȡ�ͻ�ע����Ϣ
    function edit_shopclients(var nData: string): Boolean;                      // Dl--->WxService
    //���̳ǿͻ�
    function Get_Shoporders(var nData: string): boolean;                        // Dl--->WxService
    //��ȡ������Ϣ
    function get_shoporderByNO(var nData: string): boolean;                     // Dl--->WxService
    //���ݶ����Ż�ȡ������Ϣ
    function GetWebStatus(nCode:string):string;
    function GetshoporderStatus(var nData: string): Boolean;
    // ��������״̬��ѯ
    function GetShopTruck(var nData: string): boolean;                          // Dl--->WxService
    //��ȡ������Ϣ
    function SyncShopTruckState(var nData: string): boolean;                    // Dl--->WxService
    //ͬ���������״̬
    function TruckQueuedInfo(var nData: string): boolean;
    //�����Ŷ�֪ͨ
                                                                                // WxService--->Dl
    function SearchClient(var nData: string): Boolean;
    function SearchContractOrder(var nData: string): Boolean;
    function SearchMateriel(var nData: string): Boolean;
    function SearchBill(var nData: string): Boolean;
    function CreateBill(var nData: string): Boolean;
    function SearchSecurityCode(var nData: string): Boolean;
    function QueryTruckQuery(var nData: string): Boolean;
    function BillStats(var nData: string): Boolean;
    function HYDanReport(var nData: string): Boolean;
    function getQuerySaleDtl(var nData: string): Boolean;
    //��ȡ������ϸ��Ϣ
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

//Date: 2012-3-13
//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;
  FWXChannel := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    {$IFDEF WXChannelPool}
    FWXChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(FWXChannel) then
    begin
      nData := '����΢�ŷ���ʧ��(Wechat Web Service No Channel).';
      Exit;
    end;

    with FWXChannel^ do
    begin
      if not Assigned(FChannel) then
        FChannel := CoReviceWSImplService.Create(FMsg, FHttp);
      FHttp.TargetUrl := gSysParam.FSrvRemote;
    end; //config web service channel
    {$ENDIF}

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser := gSysParam.FAppFlag;
      FIP := gSysParam.FLocalIP;
      FMAC := gSysParam.FLocalMAC;
      FTime := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: ' + FunctionName + ' InData:' + FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then
      Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then
        Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      if FPackOut then
      begin
        WriteLog('���');
        nData := FPacker.PackOut(FDataOut);
      end;

      {$IFDEF DEBUG}
      WriteLog('Fun: ' + FunctionName + ' OutData:' + FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end
    else
      DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
    {$IFDEF WXChannelPool}
    gChannelManager.ReleaseChannel(FWXChannel);
    {$ELSE}
    FWXChannel := nil;
    {$ENDIF}
  end;
end;

//Date: 2012-3-22
//Parm: �������;���
//Desc: ����ҵ��ִ����Ϻ����β����
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: �������
//Desc: ��֤��������Ƿ���Ч
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: ��¼nEvent��־
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function TBusWorkerBusinessWebchat.FunctionName: string;
begin
  Result := sBus_BusinessWebchat;
end;

constructor TBusWorkerBusinessWebchat.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListF := TStringList.Create;

  FidHttp := TIdHTTP.Create(nil);
  FidHttp.ConnectTimeout := cHttpTimeOut * 1000;
  FidHttp.ReadTimeout := cHttpTimeOut * 1000;
  inherited;
end;

destructor TBusWorkerBusinessWebchat.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListF);
  FreeAndNil(FidHttp);
  inherited;
end;

function TBusWorkerBusinessWebchat.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
    cWorker_GetPackerName:
      Result := sBus_BusinessWebchat;
  end;
end;

procedure TBusWorkerBusinessWebchat.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TBusWorkerBusinessWebchat.CallMe(const nCmd: Integer; const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var
  nStr: string;
  nIn: TWorkerWebChatData;
  nPacker: TBusinessPackerBase;
  nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessWebchat);
    nPacker.InitData(@nIn, True, False);
    //init

    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessWebchat);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
      nPacker.UnPackOut(nStr, nOut)
    else
      nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

function TBusWorkerBusinessWebchat.UnPackIn(var nData: string): Boolean;
var
  nNode, nTmp: TXmlNode;
begin
  Result := False;
  try
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nData);

    //nNode := FPacker.XMLBuilder.Root.FindNode('Head');
    nNode := FPacker.XMLBuilder.Root;
    if not (Assigned(nNode) and Assigned(nNode.FindNode('Command'))) then
    begin
      nData := '��Ч�����ڵ�(Head.Command Null).';
      Exit;
    end;

    if not Assigned(nNode.FindNode('RemoteUL')) then
    begin
      nData := '��Ч�����ڵ�(Head.RemoteUL Null).';
      Exit;
    end;

    nTmp := nNode.FindNode('Command');
    FIn.FCommand := StrToIntDef(nTmp.ValueAsString, 0);

    nTmp := nNode.FindNode('RemoteUL');
    FIn.FRemoteUL := nTmp.ValueAsString;

    nTmp := nNode.FindNode('Data');
    if Assigned(nTmp) then
      FIn.FData := nTmp.ValueAsString;

    if FIn.FCommand = cBC_WX_CreatLadingOrder then
    begin
      FListA.Clear;

      nTmp := nNode.FindNode('WebOrderID');
      if Assigned(nTmp) then
        FListA.Values['WebOrderID'] := nTmp.ValueAsString;

      nTmp := nNode.FindNode('Truck');
      if Assigned(nTmp) then
        FListA.Values['Truck'] := nTmp.ValueAsString;

      nTmp := nNode.FindNode('Value');
      if Assigned(nTmp) then
        FListA.Values['Value'] := nTmp.ValueAsString;

      nTmp := nNode.FindNode('Phone');
      if Assigned(nTmp) then
        FListA.Values['Phone'] := nTmp.ValueAsString;

      nTmp := nNode.FindNode('Unloading');
      if Assigned(nTmp) then
        FListA.Values['Unloading'] := nTmp.ValueAsString;

      nTmp := nNode.FindNode('IdentityID');
      if Assigned(nTmp) then
        FListA.Values['IdentityID'] := nTmp.ValueAsString;

    end
    else
    begin
      nTmp := nNode.FindNode('ExtParam');
      if Assigned(nTmp) then
        FIn.FExtParam := nTmp.ValueAsString;
    end;
  except

  end;
end;

//Date: 2012-3-22
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TBusWorkerBusinessWebchat.DoDBWork(var nData: string): Boolean;
begin
  UnPackIn(nData);
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;
  FPackOut := False;

  case FIn.FCommand of
    cBC_WX_VerifPrintCode:
      Result := VerifyPrintCode(nData);
    cBC_WX_WaitingForloading:
      Result := GetWaitingForloading(nData);
    cBC_WX_BillSurplusTonnage:
      Result := True;
    cBC_WX_GetOrderInfo:
      Result := {$IFDEF GZBJM} GetOrderList_JM(nData);
                {$ELSE}
                  {$IFDEF GZBZX}
                  GetOrderList_ZX(nData);
                  {$ELSE}
                  GetOrderList(nData);
                  {$ENDIF}
                {$ENDIF}
    cBC_WX_GetOrderList:
      Result := {$IFDEF GZBJM} GetOrderList_JM(nData);
                {$ELSE}
                  {$IFDEF GZBZX}
                  GetOrderList_ZX(nData);
                  {$ELSE}
                  GetOrderList(nData);
                  {$ENDIF}
                {$ENDIF}
    cBC_WX_CreatLadingOrder:
      Result := True;
    cBC_WX_GetPurchaseContract:
      Result := GetPurchaseContractList(nData);
    cBC_WX_getCustomerInfo:
      begin
        FPackOut := True;
        Result := GetCustomerInfo(nData);
      end;
//   cBC_WX_get_Bindfunc         : Result := BindCustomer(nData);
    cBC_WX_send_event_msg:
      begin
        FPackOut := True;
        Result := Send_Event_Msg(nData);
      end;
    cBC_WX_edit_shopclients:
      begin
        FPackOut := True;
        Result := Edit_ShopClients(nData);
      end;
    cBC_WX_edit_shopgoods:
      Result := Edit_Shopgoods(nData);
    cBC_WX_get_shoporders:
      Result := get_shoporders(nData);
    cBC_WX_complete_shoporders:
      begin
        FPackOut := True;
        Result := complete_shoporders(nData);
      end;
    cBC_WX_get_shoporderbyNO:
      begin
        FPackOut := True;
        Result := get_shoporderByNO(nData);
      end;
    cBC_WX_get_shopPurchasebyNO:
      begin
        FPackOut := True;
        Result := get_shoporderByNO(nData);
      end;
    cBC_WX_GetCusMoney:
      Result := GetCusMoney(nData);
    cBC_WX_GetInOutFactoryTotal:
      Result := GetInOutFactoryTotal(nData);
    cBC_WX_GetAuditTruck:
      begin
        FPackOut := True;
        Result := GetShopTruck(nData);
      end;
    cBC_WX_UpLoadAuditTruck:
      begin
        FPackOut := True;
        Result   := SyncShopTruckState(nData);
      end;
    cBC_WX_get_TruckQueuedInfo:
      begin
        FPackOut := True;
        Result   := TruckQueuedInfo(nData);
      end;
    cBC_WX_DownLoadPic:
      begin
        FPackOut := True;
        Result := DownLoadPic(nData);
      end;
    cBC_WX_get_shoporderbyTruck:
      Result := get_shoporderByTruck(nData);
    cBC_WX_get_shoporderbyTruckClt:
      begin
        FPackOut := True;
        Result := get_shoporderByTruck(nData);
      end;
    cBC_WX_get_shoporderStatus:
      begin
        FPackOut := True;
        Result := GetshoporderStatus(nData);
      end;
    cBC_WX_get_QueueInfobyTruck:
      begin
        Result := get_QueueInfobyTruck(nData);
      end;
    cBC_WX_get_LineInfobyTruck:
      begin
        Result := get_LineInfobyTruck(nData);
      end;
    cBC_WX_get_shopYYWebBill:
      begin
        FPackOut := True;
        Result   := Get_ShopordersYY(nData);
      end;
    cBC_WX_SaveCustomerWxOrders  :
      Result := synchronizedYYOrders(nData);
    cBC_WX_IsCanCreateWXOrder  :
    begin
      Result := IsCanCreateWXOrder(nData);
    end;
    cBC_WX_get_ClientReportInfo:
    begin
      Result := get_ClientReportInfo(nData);
    end;
    cBC_WX_get_QuerySaleDtl:
    begin
      Result := getQuerySaleDtl(nData);
    end;
    cBC_WX_get_TruckMaxBillNumInfo:
    begin
      Result := get_TruckMaxBillNumInfo(nData);
    end;
  else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Code: %d Invalid Command).';
      nData := Format(nData, [FIn.FCommand]);
    end;
  end;
end;

//Date: 2017-10-28
//Desc: ��ʼ��XML����
procedure TBusWorkerBusinessWebchat.BuildDefaultXML;
begin
  with FPacker.XMLBuilder do
  begin
    Clear;
    VersionString := '1.0';
    EncodingString := 'utf-8';

    XmlFormat := xfCompact;
    Root.Name := 'DATA';
    //first node
  end;
end;

//Date: 2017-10-26
//Desc: ����Ĭ������
function TBusWorkerBusinessWebchat.ParseDefault(var nData: string): Boolean;
var
  nStr: string;
  nNode: TXmlNode;
begin
  with FPacker.XMLBuilder do
  begin
    Result := False;
    nNode := Root.FindNode('head');

    if not Assigned(nNode) then
    begin
      nData := '��Ч�����ڵ�(WebService-Response.head Is Null).';
      Exit;
    end;

    nStr := nNode.NodeByName('errcode').ValueAsString;
    if nStr <> '0' then
    begin
      nData := 'ҵ��ִ��ʧ��,����: %s.%s';
      nData := Format(nData, [nStr, nNode.NodeByName('errmsg').ValueAsString]);
      Exit;
    end;

    Result := True;
    //done
  end;
end;

function TBusWorkerBusinessWebchat.FormatJson(nStrJson: string): string;
begin
  Result := '';

  Result := StringReplace(nStrJson, '\"', '"', [rfReplaceAll]);
  Result := StringReplace(Result, ':"{', ':{', [rfReplaceAll]);
  Result := StringReplace(Result, '}"', '}', [rfReplaceAll]);
//  Result := '{"sspDL":' + Result + '}';
end;

//Date: 2017-10-25
//Desc: ��ȡ������΢���û��б�
function TBusWorkerBusinessWebchat.GetCustomerInfo(var nData: string): Boolean;
var
  nStr, szUrl: string;
  nIdx: Integer;
  ReJo, ParamJo, BodyJo, OneJo, ReBodyJo: ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream: TStringStream;
begin
  Result   := False;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');
  ParamJo  := SO();
  BodyJo   := SO();
  try
    BodyJo.S['facSerialNo'] := gSysParam.FFactID;
    ParamJo.S['activeCode'] := Cus_activeCode;
    ParamJo.S['body']       := BodyJo.AsString;
    nStr                    := ParamJo.AsString;
   // nStr := Ansitoutf8(nStr);  

    WriteLog('΢���û��б���Σ�' + nStr);

    wParam.Clear;
    wParam.Add(nStr);
    
    //FidHttp������ʼ��
    ReQuestInit;

    szUrl := gSysParam.FSrvUrl + '/customer/searchShopCustomer';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog('΢���û��б���Σ�' + nStr);
    if nStr <> '' then
    begin
      FListA.Clear;
      FListB.Clear;
      ReJo    := SO(nStr);
      if ReJo = nil then Exit;

      if ReJo.S['code'] = '1' then
      begin
        ReBodyJo := So(ReJo['body'].AsString);
        ArrsJa   := ReBodyJo.A['customers'];
        for nIdx := 0 to ArrsJa.Length - 1 do
        begin
          OneJo  := SO(ArrsJa.S[nIdx]);
          with FListB do
          begin
            Values['Phone']  := OneJo.S['phone'];
            Values['BindID'] := OneJo.S['custSerialNo'];
            Values['Name']   := OneJo.S['realName'];
          end;
          FListA.Add(PackerEncodeStr(FListB.Text));
        end;
      end
      else
      begin
        WriteLog('΢���û��б��ѯʧ�ܣ�' + ReJo.S['msg']);
        Exit;
      end;
    end;

    Result := True;
    FOut.FData := FListA.Text;
    FOut.FBase.FResult := True;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

//Date: 2017-10-27
//Desc: ��or����̳��˻�����
function TBusWorkerBusinessWebchat.edit_shopclients(var nData: string): Boolean;
var
  IsBind : Boolean;
  nStr, szUrl: string;
  ReJo, ParamJo, BodyJo: ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream: TStringStream;
begin
  Result   := False;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');
  ParamJo  := SO();
  BodyJo   := SO();

  FListA.Text := PackerDecodeStr(FIn.FData);
  try
    BodyJo.S['atype'] := '0';
    BodyJo.S['type']  := '0';
    if FListA.Values['Action'] = 'add' then
      IsBind := True
    else
      IsBind := False;
    if IsBind  then
    begin
      BodyJo.S['type'] := '1';
      BodyJo.S['atype']:= '1';
    end;

    BodyJo.S['btype']         := FListA.Values['btype'];
    BodyJo.S['clientAccount'] := EncodeBase64(FListA.Values['Account']);
    BodyJo.S['clientName']    := EncodeBase64(FListA.Values['CusName']);
    BodyJo.S['clientNo']      := FListA.Values['CusID'];
    BodyJo.S['custPhone']     := FListA.Values['Phone'];   
    BodyJo.S['custSerialNo']  := FListA.Values['BindID'];    
    BodyJo.S['facSerialNo']   :=  gSysParam.FFactID;

    ParamJo.S['activeCode']  := Cus_BindCode;
    ParamJo.S['body']        := BodyJo.AsString;
    nStr                     := ParamJo.AsString;

   // nStr := Ansitoutf8(nStr);
    if IsBind then
      WriteLog('�̳�' + FListA.Values['Account'] + '�˻�����Σ�' + nStr)
    else
      WriteLog('�̳�' + FListA.Values['Account'] + '�˻������Σ�' + nStr);

    wParam.Clear;
    wParam.Add(nStr);
    
    //FidHttp������ʼ��
    ReQuestInit;

    szUrl := gSysParam.FSrvUrl + '/customer/relClientIAuth';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    if IsBind then
      WriteLog('�̳�' + FListA.Values['Account'] + ' �˻��󶨳��Σ�' + nStr)
    else
      WriteLog('�̳�' + FListA.Values['Account'] + ' �˻������Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo := SO(nStr);

      if ReJo.S['code'] = '1' then
      begin
        Result := True;
        FOut.FData := sFlag_Yes;
        FOut.FBase.FResult := True;
      end
      else
      begin
        if IsBind then
          WriteLog('�������̳��˻�ʧ�ܣ�' + ReJo.S['msg'])
        else
          WriteLog('������̳��˻�ʧ�ܣ�' + ReJo.S['msg']);
        Result     := True;
        FOut.FData := ReJo.S['msg'];
        FOut.FBase.FResult := True;
      end;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

//Date: 2017-10-28
//Parm: �ͻ����[FIn.FData]
//Desc: ��ȡ���ö����б�
function TBusWorkerBusinessWebchat.GetOrderList(var nData: string): Boolean;
var nWorker: PDBWorker;
    nTmp,nStr:string;
    nMoney, nValue: Currency;
    nNode: TXmlNode;
begin
  Result := False;
  BuildDefaultXML;
  nMoney := 0;
  nTmp := Trim(FIn.FData);
  if nTmp='' then Exit;

  FListA.Clear;
  nStr := ' Select distinct * From ' +
        ' (select xcb.XCB_ID,' +                    //�ڲ����
        '  xcb.XCB_CardId,' +                       //���ۿ�Ƭ���
        '  xcb.XCB_Origin,' +                       //��Ƭ��Դ
        '  xcb.XCB_BillID,' +                       //��Դ���ݺ�
        '  xcb.XCB_SetDate,' +                      //��������
        '  xcb.XCB_CardType,' +                     //��Ƭ����
        '  xcb.XCB_SourceType,' +                   //��Դ����
        '  xcb.XCB_Option,' +                       //���Ʒ�ʽ:0,�ص���;1,������
        '  xcb.XCB_Client,' +                       //�ͻ����
        '  xob.XOB_Name as XCB_ClientName,' +       //�ͻ�����
        '  xgd.XOB_Name as XCB_WorkAddr,' +         //���̹���
        '  xcb.XCB_Alias,' +                        //�ͻ�����
        '  xcb.XCB_OperMan,' +                      //ҵ��Ա
        '  xcb.XCB_Area,' +                         //��������
        '  xcb.XCB_CementType as XCB_Cement,' +     //Ʒ�ֱ��
        '  PCM_Name as XCB_CementName,' +           //Ʒ������
        '  xcb.XCB_LadeType,' +                     //�����ʽ
        '  xcb.XCB_Number,' +                       //��ʼ����
        '  xcb.XCB_FactNum,' +                      //�ѿ�����
        '  xcb.XCB_PreNum,' +                       //ԭ������
        '  xcb.XCB_ReturnNum,' +                    //�˻�����
        '  xcb.XCB_OutNum,' +                       //ת������
        '  vcb.XCB_FactRemain,' +                   //ʣ������
        '  xcb.XCB_ValidS,XCB_ValidE,' +            //�����Ч��
        '  xcb.XCB_AuditState,' +                   //���״̬
        '  xcb.XCB_Status,' +                       //��Ƭ״̬:0,ͣ��;1,����;2,���;3,����
        '  xcb.XCB_IsImputed,' +                    //��Ƭ�Ƿ����
        '  xcb.XCB_IsOnly,' +                       //�Ƿ�һ��һƱ
        '  xcb.XCB_Del,' +                          //ɾ�����:0,����;1,ɾ��
        '  xcb.XCB_Creator,' +                      //������
        '  pub.pub_name as XCB_CreatorNM,' +        //��������
        '  xcb.XCB_CDate,' +                        //����ʱ��
        '  xcb.XCB_Firm,' +                         //��������
        '  pbf.pbf_name as XCB_FirmName,' +         //��������
        '  pcb.pcb_id, pcb.pcb_name, ' +            //����Ƭ��
        '  '''' as XCB_TransID, ' +                 //���䵥λ���
        '  '''' as XCB_TransName ' +                //���䵥λ
     //   '  xcg.xob_id as XCB_TransID, ' +             //���䵥λ���
     //   '  xcg.XOB_Name as XCB_TransName ' +          //���䵥λ
        'from XS_Card_Base xcb' +
        '  left join XS_Compy_Base xob on xob.XOB_ID = xcb.XCB_Client' +
        '  left join XS_Compy_Base xgd on xgd.XOB_ID = xcb.xcb_sublader' +
        '  left join PB_Code_Material pcm on pcm.PCM_ID = xcb.XCB_CementType' +
        '  Left Join pb_code_block pcb On pcb.pcb_id=xob.xob_block' +
        '  Left Join pb_basic_firm pbf On pbf.pbf_id=xcb.xcb_firm' +
        '  Left Join PB_USER_BASE pub on pub.pub_id=xcb.xcb_creator ' +
        '  Left Join v_Card_Base1 vcb on vcb.XCB_ID=xcb.XCB_ID ' +
        '  Left Join XS_Card_Freight xcf on xcf.Xcf_Card=xcb.xcb_ID ' +
     //   '  Left Join XS_Compy_Base xcg on xcg.xob_id=xcf.xcf_tran ' +
        //δɾ����������������0����Ƭ���ò��Ҵ��������״̬��δ����
        ' where  xcb.xcb_del=''0'''
              +' and xcb.XCB_Status=''1'''
              +' and vcb.XCB_FactRemain>0'
              +' and xcb.XCB_IsLock<>''1'''
              +' and ((xcb.XCB_AuditState=''201'') or (xcb.XCB_IsOnly=''1''))'
              +' and xcb.XCB_Client = ''%s'' ' +
        'Order By xcb.XCB_SetDate DESC) t Where Rownum <= 100';
        //�����,ȡǰ100��
  nStr := Format(nStr,[nTmp]);

  WriteLog(Format('GetOrderList = > [ ������Ϣ.%s ]', [nStr]));
  //��ѯ���

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_YT), FPacker.XMLBuilder do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('δ��ѯ���ͻ����[ %s ]��Ӧ�Ķ�����Ϣ1.', [nTmp]);
        with Root.NodeNew('EXMG') do
        begin
          NodeNew('MsgTxt').ValueAsString := nData;
          NodeNew('MsgResult').ValueAsString := sFlag_No;
          NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
        end;
        nData := FPacker.XMLBuilder.WriteToString;
        Exit;
      end;

      First;
      nNode := Root.NodeNew('head');
      with nNode do
      begin
        NodeNew('CusId').ValueAsString   := FieldByName('XCB_Client').AsString;
        NodeNew('CusName').ValueAsString := FieldByName('XCB_ClientName').AsString;
      end;

      nNode := Root.NodeNew('Items');
      while not Eof do
      try
        with nNode.NodeNew('Item') do
        begin
          NodeNew('SetDate').ValueAsString := FormatDateTime('YYYY-MM-DD HH:MM:SS',FieldByName('XCB_SetDate').AsDateTime);
          NodeNew('BillNumber').ValueAsString := FieldByName('XCB_CardId').AsString;
          NodeNew('StockNo').ValueAsString := FieldByName('XCB_Cement').AsString;
          if Trim(FieldByName('XCB_CementName').AsString) = '' then
            NodeNew('StockName').ValueAsString := FieldByName('XCB_Cement').AsString
          else
            NodeNew('StockName').ValueAsString := FieldByName('XCB_CementName').AsString;

          if Pos('��',FieldByName('XCB_CementName').AsString) > 0 then
            NodeNew('StockType').ValueAsString := 'D'
          else
            NodeNew('StockType').ValueAsString := 'S';

          //Ĭ������
          NodeNew('ContractType').ValueAsString := '1';

          NodeNew('BillName').ValueAsString     := FieldByName('XCB_CardId').AsString;
          {$IFDEF UseWebYYOrder}
            nValue := FieldByName('XCB_FactRemain').AsCurrency
                     -  GetOrderYYValue(FieldByName('XCB_Cement').AsString,
                                     FieldByName('XCB_CardId').AsString);
                                     
            NodeNew('MaxNumber').ValueAsString    := CurrToStr(nValue);
          {$ELSE}
            nValue := FieldByName('XCB_FactRemain').AsCurrency;
            NodeNew('MaxNumber').ValueAsString    := CurrToStr(nValue);
          {$ENDIF}
          NodeNew('SaleArea').ValueAsString     := FieldByName('XCB_WorkAddr').AsString;       
        end;
      finally
        Next;
      end;
      nNode := Root.NodeNew('EXMG');
      with nNode do
      begin
        NodeNew('MsgTxt').ValueAsString := 'ҵ��ִ�гɹ�';
        NodeNew('MsgResult').ValueAsString := sFlag_Yes;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('��ȡ�����б���:' + nData);
  Result := True;
end;

function TBusWorkerBusinessWebchat.GetOrderInfo(var nData: string): Boolean;
begin

end;

//Date: 2017-11-14
//Parm: ��α��[FIn.FData]
//Desc: ��α��У��
function TBusWorkerBusinessWebchat.VerifyPrintCode(var nData: string): Boolean;
var
  nStr, nCode, nBill_id: string;
  nDs: TDataSet;
  nSprefix: string;
  nIdx, nIdlen: Integer;
begin
  nSprefix := '';
  nIdlen := 0;
  Result := False;
  nCode := FIn.FData;

  BuildDefaultXML;
  if nCode = '' then
  begin
    nData := '��α��Ϊ��.';
    with FPacker.XMLBuilder.Root.NodeNew('EXMG') do
    begin
      NodeNew('MsgTxt').ValueAsString := nData;
      NodeNew('MsgResult').ValueAsString := sFlag_No;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
    nData := FPacker.XMLBuilder.WriteToString;
    Exit;
  end;

  nStr := 'Select B_Prefix, B_IDLen From %s ' + 'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);
  nDs := gDBConnManager.WorkerQuery(FDBConn, nStr);

  if nDs.RecordCount > 0 then
  begin
    nSprefix := nDs.FieldByName('B_Prefix').AsString;
    nIdlen := nDs.FieldByName('B_IDLen').AsInteger;
    nIdlen := nIdlen - length(nSprefix);
  end;

  //�����������
  nBill_id := nSprefix + Copy(nCode, 1, 6) + //YYMMDD
    Copy(nCode, 12, Length(nCode) - 11); //XXXX
  {$IFDEF CODECOMMON}
  //�����������
  nBill_id := nSprefix + Copy(nCode, 1, 6) + //YYMMDD
    Copy(nCode, 12, Length(nCode) - 11); //XXXX
  {$ENDIF}

  {$IFDEF UseERP_K3}
  nBill_id := nSprefix + Copy(nCode, Length(nCode) - nIdlen + 1, nIdlen);
  {$ENDIF}

  //��ѯ���ݿ�
  {$IFDEF SaveCODENO}
    nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
            'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,' +
            'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue,l_project,l_area,' +
            'l_hydan,l_outfact From $Bill b ';
    nStr := nStr + ' Where L_Marking = ''$CD'' ';
    nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', Trim(nCode))]);
  {$ELSE}
    nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
            'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,' +
            'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue,l_project,l_area,' +
            'l_hydan,l_outfact From $Bill b ';
    nStr := nStr + 'Where L_ID=''$CD''';
    nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', nBill_id)]);
  {$ENDIF}
  WriteLog('��α���ѯSQL:' + nStr);

  nDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
  if nDs.RecordCount < 1 then
  begin
    nData := 'δ��ѯ�������Ϣ.';
    with FPacker.XMLBuilder.Root.NodeNew('EXMG') do
    begin
      NodeNew('rspDesc').ValueAsString := nData;
      NodeNew('rspCode').ValueAsString := sFlag_No;
      NodeNew('serialID').ValueAsString := IntToStr(FIn.FCommand);
    end;
    nData := FPacker.XMLBuilder.WriteToString;
    Exit;
  end;

  with FPacker.XMLBuilder do
  begin
    with Root.NodeNew('Items') do
    begin

      nDs.First;

      while not nDs.eof do
        with NodeNew('Item') do
        begin
          {$IFDEF SaveCODENO}
          NodeNew('ID').ValueAsString        := nDs.FieldByName('L_ID').AsString;
          NodeNew('CusID').ValueAsString     := nDs.FieldByName('L_CusID').AsString;
          NodeNew('CusName').ValueAsString   := nDs.FieldByName('L_CusName').AsString;
          NodeNew('Truck').ValueAsString     := nDs.FieldByName('L_Truck').AsString;
          NodeNew('StockNo').ValueAsString   := nDs.FieldByName('L_StockNo').AsString;
          NodeNew('StockName').ValueAsString := nDs.FieldByName('L_StockName').AsString;
          NodeNew('BILL').ValueAsString      := nDs.FieldByName('L_ID').AsString;
          NodeNew('PROJECT').ValueAsString   := nDs.FieldByName('L_ZhiKa').AsString;
          NodeNew('STOCK').ValueAsString     := nDs.FieldByName('L_StockName').AsString;
          NodeNew('CUSNAME').ValueAsString   := nDs.FieldByName('L_CusName').AsString;
          NodeNew('AREA').ValueAsString      := nDs.FieldByName('l_area').AsString;
          NodeNew('WORKADDR').ValueAsString  := nDs.FieldByName('L_Project').AsString;
          NodeNew('TRANSNAME').ValueAsString := '';
          NodeNew('HYDAN').ValueAsString     := nDs.FieldByName('l_hydan').AsString;
          NodeNew('TRUCK').ValueAsString     := nDs.FieldByName('L_Truck').AsString;
          NodeNew('LVALUE').ValueAsString    := nDs.FieldByName('L_Value').AsString;
          if Trim(nDs.FieldByName('l_outfact').AsString) = '' then
            NodeNew('OUTDATE').ValueAsString := 'δ����'
          else
            NodeNew('OUTDATE').ValueAsString   := FormatDateTime('yyyy-mm-dd',nDs.FieldByName('l_outfact').AsDateTime);
          {$ELSE}
          NodeNew('ID').ValueAsString        := nDs.FieldByName('L_ID').AsString;
          NodeNew('BILL').ValueAsString      := nDs.FieldByName('L_ID').AsString;
          NodeNew('PROJECT').ValueAsString   := nDs.FieldByName('L_ZhiKa').AsString;
          NodeNew('CusID').ValueAsString     := nDs.FieldByName('L_CusID').AsString;
          NodeNew('CusName').ValueAsString   := nDs.FieldByName('L_CusName').AsString;
          NodeNew('Truck').ValueAsString     := nDs.FieldByName('L_Truck').AsString;
          NodeNew('StockNo').ValueAsString   := nDs.FieldByName('L_StockNo').AsString;
          NodeNew('StockName').ValueAsString := nDs.FieldByName('L_StockName').AsString;
          NodeNew('STOCK').ValueAsString     := nDs.FieldByName('L_StockName').AsString;
          NodeNew('CUSNAME').ValueAsString   := nDs.FieldByName('L_CusName').AsString;
          NodeNew('AREA').ValueAsString      := nDs.FieldByName('l_area').AsString;
          NodeNew('WORKADDR').ValueAsString  := nDs.FieldByName('L_Project').AsString;
          NodeNew('TRANSNAME').ValueAsString := '';
          NodeNew('HYDAN').ValueAsString     := nDs.FieldByName('l_hydan').AsString;
          NodeNew('TRUCK').ValueAsString     := nDs.FieldByName('L_Truck').AsString;
          NodeNew('LVALUE').ValueAsString    := nDs.FieldByName('L_Value').AsString;

          if Trim(nDs.FieldByName('l_outfact').AsString) = '' then
            NodeNew('OUTDATE').ValueAsString := 'δ����'
          else
            NodeNew('OUTDATE').ValueAsString   := FormatDateTime('yyyy-mm-dd',nDs.FieldByName('l_outfact').AsDateTime);
          {$ENDIF}

          nDs.Next;
        end;
    end;

    with Root.NodeNew('EXMG') do
    begin
      NodeNew('MsgTxt').ValueAsString := 'ҵ��ִ�гɹ�';
      NodeNew('rspDesc').ValueAsString := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString := sFlag_Yes;
      NodeNew('rspCode').ValueAsString := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('��α���ѯ����:' + nData);
  Result := True;
end;

//Date: 2017-11-15
//Desc: ������Ϣ
function TBusWorkerBusinessWebchat.Send_Event_Msg(var nData: string): Boolean;
var
  nStr: string;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nStr := '<?xml version="1.0" encoding="UTF-8"?>' + '<DATA>' + '<head>' + '<Factory>%s</Factory>' + '<ToUser>%s</ToUser>' + '<MsgType>%s</MsgType>' + '</head>' + '<Items>' + '	  <Item>' + '	      <BillID>%s</BillID>' + '	      <Card>%s</Card>' + '	      <Truck>%s</Truck>' + '	      <StockNo>%s</StockNo>' + '	      <StockName>%s</StockName>' + '	      <CusID>%s</CusID>' + '	      <CusName>%s</CusName>' + '	      <CusAccount>0</CusAccount>' + '	      <MakeDate></MakeDate>' + '	      <MakeMan></MakeMan>' + '	      <TransID></TransID>' + '	      <TransName></TransName>' + '	      <Searial></Searial>' + '	      <OutFact></OutFact>' + '	      <OutMan></OutMan>' + '        <NetWeight>%s</NetWeight>' + '	  </Item>	' + '</Items>' + '</DATA>';
  nStr := Format(nStr, [gSysParam.FFactID, FListA.Values['CusID'], FListA.Values['MsgType'], FListA.Values['BillID'], FListA.Values['Card'], FListA.Values['Truck'], FListA.Values['StockNo'], FListA.Values['StockName'], FListA.Values['CusID'], FListA.Values['CusName'], FListA.Values['Value']]);
  WriteLog('�����̳�ģ����Ϣ���' + nStr);
  FWXChannel := GetReviceWS(gSysParam.FSrvRemote);
  nStr := FWXChannel.mainfuncs('send_event_msg', nStr);
  WriteLog('�����̳�ģ����Ϣ����' + nStr);
  with FPacker.XMLBuilder do
  begin
    ReadFromString(nStr);
    if not ParseDefault(nData) then
    begin
      WriteLog('����΢����Ϣʧ��:' + nData + 'Ӧ��:' + nStr);
      Exit;
    end;
  end;

  Result := True;
  FOut.FData := sFlag_Yes;
  FOut.FBase.FResult := True;
end;

function TBusWorkerBusinessWebchat.complete_shoporders(var nData: string): Boolean;
var
  nStr, nSql, ncontractNo, ndlOrderNo: string;
  nDBConn: PDBWorker;
  nIdx: Integer;
  nNetWeight: Double;
  szUrl: string;
  ReJo, ParamJo, BodyJo, OneJo, JoA : ISuperObject;  
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream: TStringStream;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  nNetWeight := 0;
  nDBConn := nil;

  with gParamManager.ActiveParam^ do
  begin
    try
      nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
      if not Assigned(nDBConn) then
      begin
        Exit;
      end;
      if not nDBConn.FConn.Connected then
        nDBConn.FConn.Connected := True;

      //���۾���

      nSql := ' select Case When ((L_HKRecord Is Null) or (L_HKRecord='''')) Then L_Value Else ' +
              ' (Select sum(isnull(L_Value,0)) from S_Bill where L_HKRecord = b.L_HKRecord) End as L_Value, '+
              '  L_Project,l_status,L_ID,L_CardUsed,L_ZhiKa from %s b where l_id=''%s''';
      if FListA.Values['WOM_StatusType'] = '2' then
        nSql := Format(nSql, [sTable_BillBak, FListA.Values['WOM_LID']])
      else
       nSql := Format(nSql, [sTable_Bill, FListA.Values['WOM_LID']]);

      with gDBConnManager.WorkerQuery(nDBConn, nSql) do
      begin
        if recordcount > 0 then
        begin
          if FieldByName('l_status').AsString = sFlag_TruckOut then
            nNetWeight := FieldByName('L_Value').asFloat;
          if Trim(FieldByName('L_CardUsed').AsString) = 'E' then
             ncontractNo  := FieldByName('L_ZhiKa').AsString
          else
            ncontractNo  := FieldByName('L_Project').AsString;
          ndlOrderNo   := FieldByName('L_ID').AsString;
        end;
      end;
      //�ɹ�����
      if nNetWeight < 0.0001 then
      begin
        nSql := 'select a.d_mvalue, a.d_pvalue, a.d_status, b.O_BID  from %s a left join %s b on a.D_OID=b.O_ID where a.d_oid=''%s'' ';
        if FListA.Values['WOM_StatusType'] = '2' then
          nSql := Format(nSql, [sTable_OrderDtlBak, sTable_OrderBak , FListA.Values['WOM_LID']])
        else
          nSql := Format(nSql, [sTable_OrderDtl, sTable_Order , FListA.Values['WOM_LID']]);
        with gDBConnManager.WorkerQuery(nDBConn, nSql) do
        begin
          if recordcount > 0 then
          begin
            if FieldByName('d_status').AsString = sFlag_TruckOut then
              nNetWeight := FieldByName('D_MValue').asFloat - FieldByName('D_PValue').asFloat;
          end;
        end;

        nSql := 'select  b.O_Project, b.O_ID from  %s b  where b.O_ID=''%s'' ';
        nSql := Format(nSql, [sTable_Order , FListA.Values['WOM_LID']]);
        with gDBConnManager.WorkerQuery(nDBConn, nSql) do
        begin
          if recordcount > 0 then
          begin
            ncontractNo:= FieldByName('O_Project').AsString;
            ndlOrderNo := FieldByName('O_ID').AsString;
          end;
        end;
      end;
    finally
      gDBConnManager.ReleaseConnection(nDBConn);
    end;
  end;

  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');
  ParamJo  := SO();
  BodyJo   := SO();
  OneJo    := SO();
  JoA      :=SO('[]');

  FListA.Text := PackerDecodeStr(FIn.FData);
  try
    OneJo.S['billNo']           := FListA.Values['WOM_LID'];
    OneJo.S['contractNo']       := ncontractNo;
    OneJo.S['realQuantity']     := FloatToStr(nNetWeight);
    JoA.AsArray.add(OneJo);

    BodyJo.S['orderNo']         := FListA.Values['WOM_WebOrderID'];
    if FListA.Values['WOM_StatusType'] = '0' then
      BodyJo.S['status']        := '2'
    else if FListA.Values['WOM_StatusType'] = '1' then
      BodyJo.S['status']        := '4'
    else if FListA.Values['WOM_StatusType'] = '2' then
      BodyJo.S['status']        := '6';
    BodyJo.S['facSerialNo']     := gSysParam.FFactID;
    BodyJo.S['realQuantity']    := FloatToStr(nNetWeight);
    BodyJo.S['dlOrderNo']       := ndlOrderNo;
    BodyJo.O['billOrderDetail'] := JoA;
    ParamJo.S['activeCode']     := Cus_syncShopOrder;
    ParamJo.S['body']           := BodyJo.AsString;
    nStr                        := ParamJo.AsString;

    WriteLog(' �̳Ƕ���ͬ����Σ�' + nStr);

    //nStr := UTF8Encode(nStr);
    wParam.Clear;
    wParam.Add(nStr);
    
    //FidHttp������ʼ��
    ReQuestInit;

    szUrl := gSysParam.FSrvUrl + '/order/syncShopOrder';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog(' �̳Ƕ���ͬ�����Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo := SO(nStr);

      if ReJo['code'].AsString = '1' then
      begin
        Result             := True;
        FOut.FData         := sFlag_Yes;
        FOut.FBase.FResult := True;
      end
      else WriteLog(' �̳Ƕ���ͬ��ʧ�ܣ�' + ReJo['msg'].AsString);
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessWebchat.Edit_Shopgoods(var nData: string): boolean;
begin
  Result := True;
  FOut.FData := sFlag_Yes;
  FOut.FBase.FResult := True;
end;

function TBusWorkerBusinessWebchat.Get_Shoporders(var nData: string): boolean;
var
  nStr, szUrl: string;
  nIdx: Integer;
  ReJo, ParamJo, HeaderJo, BodyJo, OneJo: ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream: TStringStream;
begin
  Result := False;
  wParam := TStringList.Create;
  ReStream := TStringstream.Create('');
  ParamJo := SO();
  HeaderJo := SO();
  BodyJo := SO();
  FListA.Text := PackerDecodeStr(FIn.FData);

  try
    //**********************
    BodyJo.S['facSerialNo'] := 'zxygc171223111220640999';   //gSysParam.FFactID;
    BodyJo.S['searchType'] := '1';             //  1 ������   2 ���ƺ�
    BodyJo.S['queryWord'] := '1533096003378'; //FListA.Values['ID'];

    ParamJo.S['activeCode']  := Cus_ShopOrder;
    ParamJo.S['body'] := BodyJo.AsString;
    nStr := ParamJo.AsString;

    WriteLog('΢���û��б���Σ�' + nStr);

    wParam.Clear;
    wParam.Add(nStr);
    //FidHttp������ʼ��
    ReQuestInit;
    
    szUrl := gSysParam.FSrvUrl + '/order/searchShopOrder';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog('�����б��ѯ���Σ�' + nStr);
    if nStr <> '' then
    begin
      FListA.Clear;
      FListB.Clear;
      ReJo := SO(nStr);
      if ReJo = nil then Exit;
      
      if ReJo['code'].AsString = '1' then
      begin
        ArrsJa := ParamJo['Data'].AsArray;

        for nIdx := 0 to ArrsJa.Length - 1 do
        begin
          OneJo := SO(ArrsJa[nIdx].AsString);

          with FListB do
          begin
            Values['order_id']    := OneJo['order_id'].AsString;
            Values['ordernumber'] := OneJo['ordernumber'].AsString;
            Values['goodsID']     := OneJo['goodsID'].AsString;
            Values['goodstype']   := OneJo['goodstype'].AsString;
            Values['goodsname']   := OneJo['goodsname'].AsString;
            Values['data']        := OneJo['data'].AsString;
          end;

          FListA.Add(PackerEncodeStr(FListB.Text));
        end;
        nData := PackerEncodeStr(FListA.Text);
      end
      else
      begin
        WriteLog('�����б��ѯʧ�ܣ�' + OneJo['msg'].AsString);
        Exit;
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessWebchat.Get_ShoporderByNO(var nData: string): boolean;
var
  nStr, nWebOrder, szUrl: string;
  ReJo, ParamJo, BodyJo, OneJo, ReBodyJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam, FListD, FListE : TStrings;
  ReStream: TStringStream;
  nIdx: Integer;
begin
  Result := False;
  nWebOrder := PackerDecodeStr(FIn.FData);
  wParam := TStringList.Create;
  FListD := TStringList.Create;
  FListE := TStringList.Create;
  ReStream := TStringstream.Create('');
  ParamJo := SO();
  BodyJo := SO();
  try
    BodyJo.S['searchType'] := '1';             //  1 ������   2 ���ƺ�
    BodyJo.S['queryWord']  := nWebOrder;
    BodyJo.S['facSerialNo']:= gSysParam.FFactID; //'zxygc171223111220640999';

    ParamJo.S['activeCode']  := Cus_ShopOrder;
    ParamJo.S['body'] := BodyJo.AsString;
    nStr := ParamJo.AsString;
    //nStr := Ansitoutf8(nStr);
    WriteLog('��ȡ������Ϣ���:' + nStr);

    wParam.Clear;
    wParam.Add(nStr);
    //FidHttp������ʼ��
    ReQuestInit;
    
    szUrl := gSysParam.FSrvUrl + '/order/searchShopOrder';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog('��ȡ������Ϣ����:' + nStr);

    if nStr <> '' then
    begin
      FListA.Clear;
      FListB.Clear;
      FListD.Clear;
      FListE.Clear;
      ReJo := SO(nStr);
      if ReJo = nil then Exit;

      if ReJo.S['code'] = '1' then
      begin
        ReBodyJo := SO(ReJo.S['body']);
        if ReBodyJo = nil then Exit;

        ArrsJa := ReBodyJo['details'].AsArray;
        for nIdx := 0 to ArrsJa.Length - 1 do
        begin
          OneJo := SO(ArrsJa[nIdx].AsString);

          with FListE do
          begin
            Values['clientName']      := OneJo.S['clientName'];
            Values['clientNo']        := OneJo.S['clientNo'];
            Values['contractNo']      := OneJo.S['contractNo'];
            Values['engineeringSite'] := OneJo.S['engineeringSite'];
            Values['materielName']    := OneJo.S['materielName'];
            Values['materielNo']      := OneJo.S['materielNo'];
            Values['orderDetailID']   := OneJo.S['orderDetailID'];
            Values['orderDetailType'] := OneJo.S['orderDetailType'];
            Values['quantity']        := FloatToStr(OneJo.D['quantity']) ;
            Values['status']          := OneJo.S['status'];
            Values['transportUnit']   := OneJo.S['transportUnit'];
          end;

          FListD.Add(PackerEncodeStr(FListE.Text));
        end;
        
        FListB.Values['details']      := PackerEncodeStr(FListD.Text);
        FListB.Values['driverId']     := ReBodyJo.S['driverId'];
        FListB.Values['drvName']      := ReBodyJo.S['drvName'];
        FListB.Values['drvPhone']     := ReBodyJo.S['drvPhone'];
        FListB.Values['factoryName']  := ReBodyJo.S['factoryName'];
        FListB.Values['licensePlate'] := ReBodyJo.S['licensePlate'];
        FListB.Values['orderId']      := ReBodyJo.S['orderId'];
        FListB.Values['orderNo']      := ReBodyJo.S['orderNo'];
        FListB.Values['state']        := ReBodyJo.S['state'];
        FListB.Values['totalQuantity']:= FloatToStr(ReBodyJo.D['totalQuantity']);
        FListB.Values['type']         := ReBodyJo.S['type'];
        FListB.Values['realTime']     := ReBodyJo.S['realTime'];
        FListB.Values['orderRemark']  := ReBodyJo.S['orderRemark'];

        nStr := StringReplace(FListB.Text, '\n', #13#10, [rfReplaceAll]);
        FListA.Add(nStr);

        nData := PackerEncodeStr(FListA.Text);

        Result             := True;
        FOut.FData         := nData;
        FOut.FBase.FResult := True;
      end
      else WriteLog('������Ϣʧ�ܣ�' + ReJo.S['msg']);
    end;
  finally
    ReStream.Free;
    wParam.Free;
    FListD.Free;
    FListE.Free;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017-11-20
//Parm: ����
//Desc: ������װ��ѯ
function TBusWorkerBusinessWebchat.GetWaitingForloading(var nData: string): Boolean;
var
  nStr: string;
  nNode: TXmlNode;
begin
  Result := False;

  BuildDefaultXML;

  nStr := 'Select Z_StockNo, COUNT(*) as Num From %s Where Z_Valid=''%s'' group by Z_StockNo';
  nStr := Format(nStr, [sTable_ZTLines, sFlag_Yes]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr), FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nData := '����(%s)δ������Чװ����.';
      nData := Format(nData, [gSysParam.FFactID]);
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString := nData;
        NodeNew('MsgResult').ValueAsString := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;

      Exit;
    end;

    First;

    nNode := Root.NodeNew('Items');
    while not Eof do
    begin
      with nNode.NodeNew('Item') do
      begin
        NodeNew('StockName').ValueAsString := GetStockName(FieldByName('Z_StockNo').AsString);
        NodeNew('LineCount').ValueAsString := FieldByName('Num').AsString;
        NodeNew('TruckCount').ValueAsString := GetTruckByLine(FieldByName('Z_StockNo').AsString);
      end;

      nExt;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  Result := True;
end;

//------------------------------------------------------------------------------
//Date: 2017-11-20
//Parm: ˮ������
//Desc: ��ȡ��ǰ��Ʒ��ˮ������װ������
function TBusWorkerBusinessWebchat.GetTruckByLine(nStockNo: string): string;
var
  nStr, nGroup, nSQL, nGroupID: string;
  nDBWorker: PDBWorker;
  nCount: Integer;
begin
  Result := '0';
  nCount := 0;

  nDBWorker := nil;
  try
    nStr := 'Select * From %s Where T_Valid=''%s'' And T_StockNo=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, sFlag_Yes, nStockNo]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      nCount := RecordCount;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if nCount <= 0 then//���ܴ�������ӳ��
  begin
    nGroup := '';
    nGroupID := '';

    nDBWorker := nil;
    try
      nStr := 'Select M_Group From %s Where M_Status=''%s'' And M_ID=''%s''';
      nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes, nStockNo]);

      with gDBConnManager.SQLQuery(nStr, nDBWorker) do
      begin
        if RecordCount > 0 then
          nGroupID := Fields[0].AsString;
      end;
    finally
      gDBConnManager.ReleaseConnection(nDBWorker);
    end;

    if Length(nGroupID) > 0 then
    begin
      nDBWorker := nil;
      try
        nStr := 'Select M_ID From %s Where M_Status=''%s'' And M_Group=''%s''';
        nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes, nGroupID]);

        with gDBConnManager.SQLQuery(nStr, nDBWorker) do
        begin

          First;
          while not Eof do
          begin
            nGroup := nGroup + Fields[0].AsString + ',';
            nExt;
          end;
          if Copy(nGroup, Length(nGroup), 1) = ',' then
            System.Delete(nGroup, Length(nGroup), 1);
        end;
        nSQL := AdjustListStrFormat(nGroup, '''', True, ',', False);
      finally
        gDBConnManager.ReleaseConnection(nDBWorker);
      end;

      nDBWorker := nil;
      try
        nStr := 'Select * From %s Where T_Valid=''%s'' And T_StockNo In (%s)';
        nStr := Format(nStr, [sTable_ZTTrucks, sFlag_Yes, nSQL]);

        WriteLog('��ѯ������װSQL:' + nStr);
        with gDBConnManager.SQLQuery(nStr, nDBWorker) do
        begin
          nCount := RecordCount;
        end;
      finally
        gDBConnManager.ReleaseConnection(nDBWorker);
      end;
    end;
  end;
  Result := IntToStr(nCount);
end;

//Date: 2017-10-01
//Parm: �ֵ���;�б�
//Desc: ��SysDict�ж�ȡnItem�������,����nList��
function TBusWorkerBusinessWebchat.LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
var
  nStr: string;
  nDBWorker: PDBWorker;
begin
  nDBWorker := nil;
  try
    nList.Clear;
    nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict), MI('$Name', nItem)]);

    Result := gDBConnManager.SQLQuery(nStr, nDBWorker);

    if Result.RecordCount > 0 then
      with Result do
      begin
        First;

        while not Eof do
        begin
          nList.Add(FieldByName('D_Value').AsString);
          nExt;
        end;
      end
    else
      Result := nil;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2017-10-28
//Parm: �ͻ����[FIn.FData]
//Desc: ��ȡ���ö����б�
function TBusWorkerBusinessWebchat.GetPurchaseContractList(var nData: string): Boolean;
var
  nStr, nProID: string;
  nNode: TXmlNode;
  dSet:TDataSet;
  nMaxNumber:Double;
begin
  Result := False;

  try
    nProID := Trim(FIn.FData);
    BuildDefaultXML;

  //nStr := 'select * from %s where provider_code=''%s'' and con_status>0 and con_quantity-con_finished_quantity>0.00001';
  nStr := 'select * from %s where provider_code=''%s'' and con_status>0';
  nStr := format(nStr,[sTable_PurchaseContract,Trim(FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr), FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nStr := 'select B_ID as pcId, ' +
              'B_ProID as provider_code, ' +
              'B_ProName as provider_name, ' +
              'B_ID as con_code, ' +
              'B_StockNo as con_materiel_Code, ' +
              'B_StockName as con_materiel_name, ' +
              '0 as con_price, ' +
              'B_Value as con_quantity, ' +
              'B_SentValue as con_finished_quantity, ' +
              'B_Date as con_date, ' +
              'B_Memo as con_remark' + ' from %s where B_ProID=''%s'' and B_BStatus=''%s''';
      nStr := format(nStr,[sTable_OrderBase,Trim(FIn.FData),sFlag_Yes]);
      dSet := gDBConnManager.WorkerQuery(FDBConn, nStr);
      //�����޺�ͬ�� ִ��������ѯ
      if dSet.RecordCount < 1 then
      begin
        nData := Format('δ��ѯ����Ӧ��[ %s ]��Ӧ�Ķ�����Ϣ.', [FIn.FData]);

        with Root.NodeNew('EXMG') do
        begin
          NodeNew('MsgTxt').ValueAsString := nData;
          NodeNew('MsgResult').ValueAsString := sFlag_No;
          NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
        end;
        nData := FPacker.XMLBuilder.WriteToString;
        Exit;
      end;
    end;

    First;

    nNode := Root.NodeNew('head');
    with nNode do
    begin
      NodeNew('ProvId').ValueAsString   := FieldByName('provider_code').AsString;
      NodeNew('ProvName').ValueAsString := FieldByName('provider_name').AsString;
    end;

    nNode := Root.NodeNew('Items');
    while not Eof do
    begin
      with nNode.NodeNew('Item') do
      begin
        NodeNew('SetDate').ValueAsString    := DateTime2Str(FieldByName('con_date').AsDateTime);
        NodeNew('BillNumber').ValueAsString := FieldByName('pcId').AsString;
        NodeNew('StockNo').ValueAsString    := FieldByName('con_materiel_Code').AsString;
        NodeNew('StockName').ValueAsString  := FieldByName('con_materiel_name').AsString;
        nMaxNumber := FieldByName('con_quantity').AsFloat-FieldByName('con_finished_quantity').AsFloat;
        if nMaxNumber<0.000001 then
          nMaxNumber := 0;
        NodeNew('MaxNumber').ValueAsString  := FloatToStr(nMaxNumber);
        NodeNew('HasLs').ValueAsString      := sFlag_No;
      end;

      nExt;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
    end;
    nData := FPacker.XMLBuilder.WriteToString;
    Result := True;
  finally
    WriteLog('��ȡ�ɹ������б���:' + nData);
  end;
end;

function TBusWorkerBusinessWebchat.GetCusName(nCusID: string): string;
var
  nStr: string;
  nDBWorker: PDBWorker;
begin
  Result := '';

  nDBWorker := nil;
  try
    nStr := 'Select C_Name From %s Where C_ID=''%s'' ';
    nStr := Format(nStr, [sTable_Customer, nCusID]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      Result := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2018-01-05
//Desc: ��ȡָ���ͻ��Ŀ��ý��
function TBusWorkerBusinessWebchat.GetCustomerValidMoney(nCustomer: string): Double;
var
  nStr: string;
  nUseCredit: Boolean;
  nVal, nCredit: Double;
begin
  Result := 0;
  nUseCredit := False;

  nStr := 'Select MAX(C_End) From %s ' + 'Where C_CusID=''%s'' and C_Money>=0 and C_Verify=''%s''';
  nStr := Format(nStr, [sTable_CusCredit, nCustomer, sFlag_Yes]);
  WriteLog('����SQL:' + nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    nUseCredit := (Fields[0].AsDateTime > Str2Date('2000-01-01')) and (Fields[0].AsDateTime > Now());
  //����δ����

  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, nCustomer]);
  WriteLog('�û��˻�SQL:' + nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      Exit;
    end;

    nVal := FieldByName('A_InitMoney').AsFloat + FieldByName('A_InMoney').AsFloat - FieldByName('A_OutMoney').AsFloat - FieldByName('A_Compensation').AsFloat - FieldByName('A_FreezeMoney').AsFloat;
    //xxxxx
    WriteLog('�û��˻����:' + FloatToStr(nVal));
    nCredit := FieldByName('A_CreditLimit').AsFloat;
    nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;
    WriteLog('�û��˻�����:' + FloatToStr(nCredit));
    if nUseCredit then
      nVal := nVal + nCredit;
    WriteLog('�û��˻����ý�:' + FloatToStr(nVal));
    Result := Float2PInt(nVal, cPrecision, False) / cPrecision;
  end;
end;

//Date: 2018-01-05
//Desc: ��ȡָ���ͻ��Ŀ��ý��
function TBusWorkerBusinessWebchat.GetCustomerValidMoneyFromK3(nCustomer: string): Double;
var
  nStr, nCusID: string;
  nUseCredit: Boolean;
  nVal, nCredit: Double;
  nDBWorker: PDBWorker;
begin
  Result := 0;
  nUseCredit := False;

  nStr := 'Select MAX(C_End) From %s ' + 'Where C_CusID=''%s'' and C_Money>=0 and C_Verify=''%s''';
  nStr := Format(nStr, [sTable_CusCredit, FIn.FData, sFlag_Yes]);
  WriteLog('����SQL:' + nStr);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    nUseCredit := (Fields[0].AsDateTime > Str2Date('2000-01-01')) and (Fields[0].AsDateTime > Now());
  //����δ����

  nStr := 'Select A_FreezeMoney,A_CreditLimit,C_Param From %s,%s ' + 'Where A_CID=''%s'' And A_CID=C_ID';
  nStr := Format(nStr, [sTable_Customer, sTable_CusAccount, FIn.FData]);
  WriteLog('�û��˻�SQL:' + nStr);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      Exit;
    end;

    nCusID := FieldByName('C_Param').AsString;
    nVal := FieldByName('A_FreezeMoney').AsFloat;
    nCredit := FieldByName('A_CreditLimit').AsFloat;
  end;

  nDBWorker := nil;
  try
    nStr := 'DECLARE @return_value int, @Credit decimal(28, 10),' + '@Balance decimal(28, 10)' + 'Execute GetCredit ''%s'' , @Credit output , @Balance output ' + 'select @Credit as Credit , @Balance as Balance , ' + '''Return Value'' = @return_value';
    nStr := Format(nStr, [nCusID]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    begin
      if RecordCount < 1 then
      begin
        nStr := 'K3���ݿ��ϱ��Ϊ[ %s ]�Ŀͻ��˻�������.';
        nStr := Format(nStr, [nCustomer]);
        WriteLog(nStr);
        Exit;
      end;

      nVal := -(FieldByName('Balance').AsFloat) - nVal;
      if nUseCredit then
      begin
        nCredit := FieldByName('Credit').AsFloat + nCredit;
        nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;
        nVal := nVal + nCredit;
      end;

      WriteLog('�û��˻����ý�:' + FloatToStr(nVal));

      Result := Float2PInt(nVal, cPrecision, False) / cPrecision;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2018-01-11
//Parm: �ͻ���[FIn.FData]
//Desc: ��ȡ�ͻ��ʽ�
function TBusWorkerBusinessWebchat.GetCusMoney(var nData: string): Boolean;
var
  nMoney: Double;
begin
  Result := False;
  BuildDefaultXML;

  nMoney := 0;
  {$IFDEF UseCustomertMoney}
  nMoney := GetCustomerValidMoney(FIn.FData);
  {$ENDIF}

  {$IFDEF UseERP_K3}
  nMoney := GetCustomerValidMoneyFromK3(FIn.FData);
  {$ENDIF}

  with FPacker.XMLBuilder do
  begin
    with Root.NodeNew('Items') do
    begin
      with NodeNew('Item') do
      begin
        NodeNew('Money').ValueAsString := FloatToStr(nMoney);
      end;
    end;

    with Root.NodeNew('EXMG') do
    begin
      NodeNew('MsgTxt').ValueAsString := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('�ͻ��ʽ��ѯ����:' + nData);
  Result := True;
end;

//����������ѯ���ɹ������������۳�������
function TBusWorkerBusinessWebchat.GetInOutFactoryTotal(var nData: string): Boolean;
var
  nStr, nExtParam: string;
  nType, nStartDate, nEndDate: string;
  nPos: Integer;
  nNode: TXmlNode;
  nStartTime, nEndTime: string;
  nDt: TDateTime;
begin
  Result := True;
  BuildDefaultXML;

  nType := Trim(fin.FData);
  nExtParam := Trim(FIn.FExtParam);
  with FPacker.XMLBuilder do
  begin
    if (nType = '') or (nExtParam = '') then
    begin
      nData := Format('��ѯ����������쳣:[ %s ].', [nType + ',' + nExtParam]);

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString := nData;
        NodeNew('MsgResult').ValueAsString := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;
      Exit;
    end;
  end;

  nPos := Pos('and', nExtParam);
  if nPos > 0 then
  begin
    nStartDate := Copy(nExtParam, 1, nPos - 1) + ' 00:00:00';
    nEndDate := Copy(nExtParam, nPos + 3, Length(nExtParam) - nPos - 2) + ' 23:59:59';
  end;

  nStr := 'Select D_Memo, D_Value From %s Where D_Name =''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_WxItem]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      nStartTime := '';
      nEndTime := '';

      First;

      while not Eof do
      begin
        if Fields[0].AsString = sFlag_InOutBegin then
          nStartTime := Fields[1].AsString;

        if Fields[0].AsString = sFlag_InOutEnd then
          nEndTime := Fields[1].AsString;

        nExt;
      end;

      if (Length(nStartTime) > 0) and (Length(nEndTime) > 0) then
      begin
        nPos := Pos('and', nExtParam);
        if nPos > 0 then
        begin
          nStartDate := Copy(nExtParam, 1, nPos - 1);
          nEndDate := Copy(nExtParam, nPos + 3, Length(nExtParam) - nPos - 2);
        end;
        WriteLog('ʱ�䴦���ʼֵ:��ʼ' + nStartDate + '����' + nEndDate);
        if nStartDate = nEndDate then
        begin
          nStartDate := nStartDate + nStartTime;
          try
            nDt := StrToDateTime(nStartDate);
            nDt := IncDay(nDt, 1);
            nEndDate := FormatDateTime('YYYY-MM-DD', nDt) + nEndTime;
          except
            on E: Exception do
            begin
              nEndDate := nEndDate + ' 23:59:59';
              WriteLog('����ʱ�䴦���쳣:' + e.Message);
            end;
          end;
        end
        else
        begin
          nStartDate := nStartDate + nStartTime;
          nEndDate := nEndDate + nEndTime;
        end;
      end;
    end;
  end;

  WriteLog('��ѯ������ʱ������:' + '��ʼ:' + nStartDate + '����:' + nEndDate);

  FListA.Text := GetInOutValue(nStartDate, nEndDate, nType);

  nStr := 'EXEC SP_InOutFactoryTotal ''' + nType + ''',''' + nStartDate + ''',''' + nEndDate + ''' ';

  with gDBConnManager.WorkerQuery(FDBConn, nStr), FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nData := 'δ��ѯ�������Ϣ.';

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString := nData;
        NodeNew('MsgResult').ValueAsString := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;
      Exit;
    end;

    First;

    nNode := Root.NodeNew('head');
    with nNode do
    begin
      NodeNew('DValue').ValueAsString := FListA.Values['DValue'];
      NodeNew('SValue').ValueAsString := FListA.Values['SValue'];
      NodeNew('TotalValue').ValueAsString := FListA.Values['TotalValue'];
    end;

    nNode := Root.NodeNew('Items');
    while not Eof do
    begin
      with nNode.NodeNew('Item') do
      begin
        NodeNew('StockName').ValueAsString := FieldByName('StockName').AsString;
        NodeNew('TruckCount').ValueAsString := FieldByName('TruckCount').AsString;
        NodeNew('StockValue').ValueAsString := FieldByName('StockValue').AsString;
      end;

      nExt;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('��ѯ������ͳ�Ʒ���:' + nData);
  Result := True;
end;

function TBusWorkerBusinessWebchat.GetInOutValue(nBegin, nEnd, nType: string): string;
var
  nStr, nTable: string;
  nDBWorker: PDBWorker;
  nDValue, nSValue, nTotalValue: Double;
begin
  Result := '';
  nDValue := 0;
  nSValue := 0;
  nTotalValue := 0;

  nDBWorker := nil;
  try
    nStr := 'select distinct L_type as Stock_Type, SUM(L_Value) as Stock_Value from %s ' + ' where L_OutFact >= ''%s'' and L_OutFact <= ''%s'' group by L_Type ';

    if nType = 'SZ' then
      nStr := 'select distinct L_type as Stock_Type, SUM(L_Value) as Stock_Value from %s ' + ' where L_InTime >= ''%s'' and L_InTime <= ''%s'' and L_Status <> ''O'' group by L_Type '
    else if nType = 'P' then
      nStr := 'select distinct ''S'' as Stock_Type ,SUM(D_Value) as Stock_Value from %s ' + ' where D_OutFact >= ''%s'' and D_OutFact <= ''%s''  '
    else if nType = 'PZ' then
      nStr := 'select distinct ''S'' as Stock_Type ,SUM(D_Value) as Stock_Value from %s ' + ' where D_MDate >= ''%s'' and D_MDate <= ''%s'' and D_Status <> ''O''  ';
    if Pos('P', nType) > 0 then
      nTable := sTable_OrderDtl
    else
      nTable := sTable_Bill;
    nStr := Format(nStr, [nTable, nBegin, nEnd]);

    WriteLog('��ѯ����ͳ��SQL:' + nStr);
    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      First;
      while not Eof do
      begin
        nTotalValue := nTotalValue + Fields[1].AsFloat;
        nStr := Fields[0].AsString;
        if nStr = sFlag_Dai then
          nDValue := Fields[1].AsFloat
        else if nStr = sFlag_San then
          nSValue := Fields[1].AsFloat;

        nExt;
      end;
    end;
    FListB.Clear;
    FListB.Values['DValue'] := FormatFloat('0.00', nDValue);
    FListB.Values['SValue'] := FormatFloat('0.00', nSValue);
    FListB.Values['TotalValue'] := FormatFloat('0.00', nTotalValue);
    Result := FListB.Text;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

function TBusWorkerBusinessWebchat.GetStockName(nStockNo: string): string;
var
  nStr: string;
  nDBWorker: PDBWorker;
begin
  Result := '';

  nDBWorker := nil;
  try
    nStr := 'Select Z_Stock From %s Where Z_StockNo=''%s'' ';
    nStr := Format(nStr, [sTable_ZTLines, nStockNo]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      Result := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2018-01-17
//Desc: ��ȡ�ֻ����ᱨ������Ϣ
function TBusWorkerBusinessWebchat.getDeclareCar(var nData: string): Boolean;
var
  nStr, nStatus: string;
  nIdx: Integer;
  nNode, nRoot: TXmlNode;
  nInit: Int64;
begin
  Result := False;
  nStatus := PackerDecodeStr(FIn.FData);

  nStr := '<?xml version="1.0" encoding="UTF-8"?>' + '<DATA>' + '<head><Factory>%s</Factory>' + '<Status>%s</Status>' + '</head>' + '</DATA>';
  nStr := Format(nStr, [gSysParam.FFactID, nStatus]);
  WriteLog('��ȡ�ᱨ������Ϣ���:' + nStr);

  Result := False;
  FWXChannel := GetReviceWS(gSysParam.FSrvRemote);
  nStr := FWXChannel.mainfuncs('getDeclareCar', nStr);

  WriteLog('��ȡ�ᱨ������Ϣ����:' + nStr);

  with FPacker.XMLBuilder do
  begin
    ReadFromString(nStr);
    if not ParseDefault(nData) then
      Exit;
    nRoot := Root.FindNode('items');

    if not Assigned(nRoot) then
    begin
      nData := '��Ч�����ڵ�(WebService-Response.items Is Null).';
      Exit;
    end;

    nInit := GetTickCount;
    FListA.Clear;
    FListB.Clear;
    for nIdx := 0 to nRoot.NodeCount - 1 do
    begin
      nNode := nRoot.Nodes[nIdx];
      if CompareText('item', nNode.Name) <> 0 then
        Continue;

      with FListB, nNode do
      begin
        Values['uniqueIdentifier'] := NodeByName('uniqueIdentifier').ValueAsString;
        Values['serialNo'] := NodeByName('serialNo').ValueAsString;
        Values['carNumber'] := NodeByName('carNumber').ValueAsString;
        Values['drivingLicensePath'] := NodeByName('drivingLicensePath').ValueAsString;
        Values['custName'] := NodeByName('custName').ValueAsString;
        Values['custPhone'] := NodeByName('custPhone').ValueAsString;
        Values['tare'] := NodeByName('tare').ValueAsString;
      end;
      SaveAuditTruck(FlistB, nStatus);
      FListA.Add(PackerEncodeStr(FListB.Text));
      //new item
    end;
  end;
  WriteLog('���泵��������ݺ�ʱ: ' + IntToStr(GetTickCount - nInit) + 'ms');
  Result := True;
  FOut.FData := FListA.Text;
  FOut.FBase.FResult := True;
end;

procedure TBusWorkerBusinessWebchat.SaveAuditTruck(nList: TStrings; nStatus: string);
var
  nStr: string;
begin
//  FDBConn.FConn.BeginTrans;
//  try
//    nStr := 'Delete From %s Where A_Truck=''%s'' ';
//    nStr := Format(nStr, [sTable_AuditTruck, nList.Values['licensePlate']]);
//    gDBConnManager.WorkerExec(FDBConn, nStr);
//
//    nStr := MakeSQLByStr([SF('A_ID', nList.Values['id']),
//                         SF('A_Serial', nList.Values['cnsSerialNo']),
//                         SF('A_Truck', nList.Values['licensePlate']),
//                         SF('A_LicensePath', nList.Values['licensePath']),
//                         SF('A_Status', nStatus),
//                         SF('A_Date', sField_SQLServer_Now, sfVal),
//                         SF('A_WeiXin', nList.Values['realName']),
//                         SF('A_Phone', nList.Values['phone']),
//                         SF('A_PValue', nList.Values['tare'])],
//                         sTable_AuditTruck, '', True);
//    //xxxxx
//
//    gDBConnManager.WorkerExec(FDBConn, nStr);
//
//    FDBConn.FConn.CommitTrans;
//  except
//    FDBConn.FConn.RollbackTrans;
//    raise;
//  end;
end;

//Date: 2009-7-4
//Parm: ���ݼ�;�ֶ���;ͼ������
//Desc: ��nImageͼ�����nDS.nField�ֶ�
function TBusWorkerBusinessWebchat.SaveDBImage(const nDS: TDataSet; const nFieldName: string; const nStream: TMemoryStream): Boolean;
var
  nField: TField;
  nBuf: array[1..MAX_PATH] of Char;
begin
  Result := False;
  nField := nDS.FindField(nFieldName);
  if not (Assigned(nField) and (nField is TBlobField)) then
    Exit;

  try
    if not Assigned(nStream) then
    begin
      nDS.Edit;
      TBlobField(nField).Clear;
      nDS.Post;
      Result := True;
      Exit;
    end;

    nDS.Edit;
    nStream.Position := 0;
    TBlobField(nField).LoadFromStream(nStream);

    nDS.Post;
    Result := True;
  except
    if nDS.State = dsEdit then
      nDS.Cancel;
  end;
end;

//Date: 2018-01-22
//Desc: ������˽���ϴ�����or������ڿ�����
function TBusWorkerBusinessWebchat.UpdateDeclareCar(var nData: string): Boolean;
var
  nStr: string;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nStr := '<?xml version="1.0" encoding="UTF-8"?>' + '<DATA>' + '<head>' + '<UniqueIdentifier>%s</UniqueIdentifier>' + '<AuditStatus>%s</AuditStatus>' + '<AuditRemark>%s</AuditRemark>' + '<AuditUserName>%s</AuditUserName>' + '<IsLongTermCar>%s</IsLongTermCar>' + '</head>' + '</DATA>';
  nStr := Format(nStr, [FListA.Values['ID'], FListA.Values['Status'], FListA.Values['Memo'], FListA.Values['Man'], FListA.Values['Type']]);
  //xxxxx

  WriteLog('��˽�����' + nStr);

  FWXChannel := GetReviceWS(gSysParam.FSrvRemote);
  nStr := FWXChannel.mainfuncs('updateDeclareCar', nStr);

  WriteLog('��˽������' + nStr);

  with FPacker.XMLBuilder do
  begin
    ReadFromString(nStr);
    if not ParseDefault(nData) then
      Exit;
  end;

  Result := True;
  FOut.FData := sFlag_Yes;
  FOut.FBase.FResult := True;
end;

//Date: 2018-01-22
//Desc: ����ͼƬ
function TBusWorkerBusinessWebchat.DownLoadPic(var nData: string): Boolean;
var
  nID, nStr: string;
  nIdx: Int64;
  nDS: TDataSet;
  nIdHTTP: TIdHTTP;
  nStream: TMemoryStream;
begin
//  Result := False;
//  nID := PackerDecodeStr(FIn.FData);
//
//  nStr := 'Select * From %s Where A_ID=''%s'' ';
//  nStr := Format(nStr, [sTable_AuditTruck, nID]);
//
//  nDS := gDBConnManager.WorkerQuery(FDBConn, nStr);
//
//  if nDS.RecordCount < 1 then
//  begin
//    nStr := Format('δ��ѯ������%s�����Ϣ!', [nID]);
//    WriteLog(nStr);
//    Exit;
//  end;
//
//  if nDS.FieldByName('A_LicensePath').AsString = '' then
//  begin
//    nStr := Format('����%s��Ƭ·��Ϊ��!', [nID]);
//    WriteLog(nStr);
//    Exit;
//  end;
//
//  nIdx := GetTickCount;
//
//  nIdHTTP := nil;
//  nStream := nil;
//  try
//    nIdHTTP := TIdHTTP.Create;
//    nStream := TMemoryStream.Create;
//
//    nIdHTTP.Get(gSysParam.FSrvPicUrl+'/'+nDS.FieldByName('A_LicensePath').AsString, nStream);
//    nStream.Position := 0;
//
//    SaveDBImage(nDS, 'A_License', nStream);
//
//    nIdHTTP.Free;
//    nStream.Free;
//  except
//    if Assigned(nIdHTTP) then
//      nIdHTTP.Free;
//    if Assigned(nStream) then
//      nStream.Free;
//    Exit;
//  end;
//  WriteLog('���س���ͼƬ��ʱ: ' + IntToStr(GetTickCount - nIdx) + 'ms');
//
//  Result := True;
//  FOut.FData := sFlag_Yes;
//  FOut.FBase.FResult := True;
end;

//Date: 2018-01-22
//Desc: ͨ�����ƺŻ�ȡ����
function TBusWorkerBusinessWebchat.Get_ShoporderByTruck(var nData: string): boolean;
var
  nStr, nWebOrder, szUrl: string;
  ReJo, ParamJo, BodyJo, OneJo, ReBodyJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam, FListD, FListE : TStrings;
  ReStream: TStringStream;
  nIdx: Integer;
begin
  Result := False;
  nWebOrder := PackerDecodeStr(FIn.FData);
  wParam := TStringList.Create;
  FListD := TStringList.Create;
  FListE := TStringList.Create;
  ReStream := TStringstream.Create('');
  ParamJo := SO();
  BodyJo := SO();
  try
    BodyJo.S['searchType'] := '2';             //  1 ������   2 ���ƺ�
    BodyJo.S['queryWord']  := EncodeBase64(nWebOrder);
    BodyJo.S['facSerialNo']:= gSysParam.FFactID; //'zxygc171223111220640999';

    ParamJo.S['activeCode']  := Cus_ShopOrder;
    ParamJo.S['body'] := BodyJo.AsString;
    nStr := ParamJo.AsString;
    //nStr := Ansitoutf8(nStr);
    WriteLog('��ȡ������Ϣ���:' + nStr);

    wParam.Clear;
    wParam.Add(nStr);
    //FidHttp������ʼ��
    ReQuestInit;
    
    szUrl := gSysParam.FSrvUrl + '/order/searchShopOrder';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog('��ȡ������Ϣ����:' + nStr);

    if nStr <> '' then
    begin
      FListA.Clear;
      FListB.Clear;
      FListD.Clear;
      FListE.Clear;
      ReJo := SO(nStr);
      if ReJo = nil then Exit;

      if ReJo.S['code'] = '1' then
      begin
        ReBodyJo := SO(ReJo.S['body']);
        if ReBodyJo = nil then Exit;

        ArrsJa := ReBodyJo['details'].AsArray;
        for nIdx := 0 to ArrsJa.Length - 1 do
        begin
          OneJo := SO(ArrsJa[nIdx].AsString);

          with FListE do
          begin
            Values['clientName']      := OneJo.S['clientName'];
            Values['clientNo']        := OneJo.S['clientNo'];
            Values['contractNo']      := OneJo.S['contractNo'];
            Values['engineeringSite'] := OneJo.S['engineeringSite'];
            Values['materielName']    := OneJo.S['materielName'];
            Values['materielNo']      := OneJo.S['materielNo'];
            Values['orderDetailID']   := OneJo.S['orderDetailID'];
            Values['orderDetailType'] := OneJo.S['orderDetailType'];
            Values['quantity']        := FloatToStr(OneJo.D['quantity']) ; 
            Values['status']          := OneJo.S['status'];
            Values['transportUnit']   := OneJo.S['transportUnit'];
          end;

          FListD.Add(PackerEncodeStr(FListE.Text));
        end;

        FListB.Values['details']      := PackerEncodeStr(FListD.Text);
        FListB.Values['driverId']     := ReBodyJo.S['driverId'];
        FListB.Values['drvName']      := ReBodyJo.S['drvName'];
        FListB.Values['drvPhone']     := ReBodyJo.S['drvPhone'];
        FListB.Values['factoryName']  := ReBodyJo.S['factoryName'];
        FListB.Values['licensePlate'] := ReBodyJo.S['licensePlate'];
        FListB.Values['orderId']      := ReBodyJo.S['orderId'];
        FListB.Values['orderNo']      := ReBodyJo.S['orderNo'];
        FListB.Values['state']        := ReBodyJo.S['state'];
        FListB.Values['totalQuantity']:= FloatToStr(ReBodyJo.D['totalQuantity']);
        FListB.Values['type']         := ReBodyJo.S['type'];
        FListB.Values['realTime']     := ReBodyJo.S['realTime'];
        FListB.Values['orderRemark']  := ReBodyJo.S['orderRemark'];

        nStr := StringReplace(FListB.Text, '\n', #13#10, [rfReplaceAll]);
        FListA.Add(nStr);

        nData := PackerEncodeStr(FListA.Text);

        Result             := True;
        FOut.FData         := nData;
        FOut.FBase.FResult := True;
      end
      else WriteLog('������Ϣʧ�ܣ�' + ReJo.S['msg']);
    end;
  finally
    ReStream.Free;
    wParam.Free;
    FListD.Free;
    FListE.Free;
  end;
end;


// �����ͻ�������ѯ
function TBusWorkerBusinessWebchat.SearchClient(var nData: string): Boolean;
var nStr, nCusNo : string;
    nRoot, nNode : TXmlNode;
    nReDs: TDataSet;
begin
  Result := False;
  with FPacker.XMLBuilder do
  begin
    try
      WriteLog('�ͻ�������ѯ��Σ�'+nData);
      ReadFromString(nData);
      if not ParseDefault(nData) then Exit;

      try
        nRoot := Root.FindNode('body');
        nCusNo:= nRoot.NodeByName('clientNo').ValueAsString;
      except
        nData:= '���������������!';
        Exit;
      end;

      nStr := ' Select C_ID,  C_Name, C_Phone, C_Account, ''2'' C_Type From %s ' +
              ' Where C_ID= ''%s'' Union ' +
              ' Select P_ID C_ID, P_Name C_Name, P_Phone C_Phone, '' C_Account, ''1'' C_Type From %s ' +
              ' Where P_ID= ''%s'' ';
      nStr := Format(nStr, [sTable_Customer, nCusNo, sTable_Provider, nCusNo]);
      //*****
      nReDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
      if nReDs.RecordCount < 1 then
      begin
        nData:= Format('δ��ѯ���ͻ� %s ��Ϣ!', [nCusNo]);
        Exit;
      end;

      nNode:= Root.NodeNew('body');
      with nNode, nReDs do
      begin
        NodeNew('facSerialNo').ValueAsString:= gSysParam.FFactID;
        NodeNew('clientNo').ValueAsString   := FieldByName('C_ID').AsString;
        NodeNew('clientName').ValueAsString := FieldByName('C_Name').AsString;
        NodeNew('btype').ValueAsString      := FieldByName('C_Type').AsString;
        NodeNew('custSerialNo').ValueAsString := FieldByName('C_ID').AsString;
        NodeNew('status').ValueAsString     := '1';
        NodeNew('custPhone').ValueAsString  := FieldByName('C_Phone').AsString;
        NodeNew('clientAccount').ValueAsString := FieldByName('C_Account').AsString;
      end;
    finally
      begin
        nNode := Root.NodeNew('header');
        with nNode do
        begin
          NodeNew('rspCode').ValueAsString := sFlag_Yes;
          NodeNew('rspDesc').ValueAsString := 'ҵ��ִ�гɹ�';
        end;
      end;
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('�ͻ�������ѯ����:' + nData);
  Result := True;
end;

// �����ͻ�������ѯ
function TBusWorkerBusinessWebchat.SearchContractOrder(var nData: string): Boolean;
var nStr, nCusNo, nType : string;
    nRoot, nNode, nheader, nbody : TXmlNode;
    nReDs: TDataSet;
    nMoney : Double;
begin
  Result:= False;  nMoney:= 0;
  with FPacker.XMLBuilder do
  begin
    try
      WriteLog('�ͻ�������ѯ��Σ�'+nData);
      nCusNo:= FIn.FData;

      //************************************************************************
      //************************************************************************
      Root.Clear;
      nheader:= Root.NodeNew('header');
      with nheader do
      begin
        NodeNew('rspCode').ValueAsString:= '1';
        NodeNew('rspDesc').ValueAsString:= nData;
      end;

      nMoney := GetCustomerValidMoney(nCusNo);
      {$IFDEF UseERP_K3}
      nMoney := GetCustomerValidMoneyFromK3(nCusNo);
      {$ENDIF}

      if nType='1' then
      begin
        nStr := ' Select *, Case When(D_Type=''D'')then 1 else 2 end MType, '+
                          'Case When(ISNULL(Z_OnlyMoney, '''')=''Y'') then CONVERT(Decimal(15,2), (%g/ISNULL(D_Price, 10000))) '+
                          'else CONVERT(Decimal(15,2), (%g/ISNULL(D_Price, 10000))) End MaxValue From %s Left Join %s On D_ZID=Z_ID '+
                ' Where Z_Customer= ''%s'' ';
        nStr := Format(nStr, [sTable_ZhiKa, sTable_ZhiKaDtl, nMoney, nMoney, nCusNo]);
      end
      else
      begin
        nStr := ' Select *,(B_Value-B_SentValue-B_FreezeValue) As B_MaxValue From %s Where B_ProID= ''%s'' ';
        nStr := Format(nStr, [sTable_OrderBase, nCusNo]);
      end;
      //*****
      nReDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
      if nReDs.RecordCount < 1 then
      begin
        nData:= Format('δ��ѯ���ͻ� %s ��Ϣ!', [nCusNo]);
        Exit;
      end;

      nNode:= Root.NodeNew('body');
      with nNode, nReDs do
      begin
        if nType='1' then
        begin
          NodeNew('contractNo').ValueAsString   := FieldByName('Z_ID').AsString;
          NodeNew('contractTime').ValueAsString := FormatDateTime('yyMMddHHmmss', FieldByName('Z_Date').AsDateTime);
          NodeNew('materielNo').ValueAsString   := FieldByName('D_StockNo').AsString;
          NodeNew('materielName').ValueAsString := FieldByName('D_StockNoName').AsString;
          NodeNew('maxCapacity').ValueAsString  := FieldByName('MaxValue').AsString;
          NodeNew('engineeringSite').ValueAsString := FieldByName('Z_Project').AsString;
          NodeNew('materielType').ValueAsString := FieldByName('MType').AsString;
        end
        else
        begin
          NodeNew('contractNo').ValueAsString   := FieldByName('B_ID').AsString;
          NodeNew('contractTime').ValueAsString := FormatDateTime('yyMMddHHmmss', FieldByName('B_Date').AsDateTime);
          NodeNew('materielNo').ValueAsString   := FieldByName('B_StockNo').AsString;
          NodeNew('materielName').ValueAsString := FieldByName('B_StockNoName').AsString;
          NodeNew('maxCapacity').ValueAsString  := FieldByName('B_MaxValue').AsString;
          NodeNew('engineeringSite').ValueAsString := FieldByName('B_Project').AsString;
          NodeNew('materielType').ValueAsString := '1';;
        end;
      end;
      nData := '�����ɹ�';
      Result:= True;
    finally
      begin
        with Root.FindNode('header') do
        begin
          if Result then NodeNew('rspCode').ValueAsString:= '0'
          else NodeNew('rspCode').ValueAsString:= '1';

          NodeNew('rspDesc').ValueAsString:= nData;
        end;

        nData := FPacker.XMLBuilder.WriteToString;
        WriteLog('�ͻ�������ѯ����:' + nData);
      end;
    end;
  end;
end;

// ����������Ϣ��ѯ
function TBusWorkerBusinessWebchat.SearchMateriel(var nData: string): Boolean;
var nStr, nMtlNo, nMType, nWh : string;
    nRoot, nNode, nheader, nbody : TXmlNode;
    nReDs: TDataSet;
begin
  Result := False;
  with FPacker.XMLBuilder do
  begin
    try
      WriteLog('������Ϣ��ѯ��Σ�'+nData);
      ReadFromString(nData);
      if not ParseDefault(nData) then Exit;

      try
        nRoot := Root.FindNode('body');
        nMtlNo:= nRoot.NodeByName('materielNo').ValueAsString;
        nMType:= nRoot.NodeByName('materielType').ValueAsString;
      except
        on Ex : Exception do
        begin
          nData:= '���������������!';
          WriteLog(nData+' '+Ex.Message);
          Exit;
        end;
      end;

      //************************************************************************
      //************************************************************************
      Root.Clear;
      nheader:= Root.NodeNew('header');
      with nheader do
      begin
        NodeNew('rspCode').ValueAsString:= '1';
        NodeNew('rspDesc').ValueAsString:= nData;
      end;

      if nMtlNo<>'' then nWh:= ' And (M_ID='''+nMtlNo+''') ';
      if nMType<>'' then nWh:= nWh + ' And (MType='''+nMtlNo+''') ';

      nStr := ' Select *, Case When(MType=''D'')then 1 else 2 end M_Type From ( ' + 
              ' Select D_ParamB M_ID, D_Value M_Name, D_Memo MType, 1 BusType From ''%s'' Where D_Name=''StockItem''  ' +
              ' Union ' +
              ' Select M_ID, M_Name, ''S'' MType, 2 BusType From ''%s'' ' +
              ' Where 1=1 ' + nWh +
              ' Order by MType';
      nStr := Format(nStr, [sTable_SysDict, sTable_Materails]);
      //*****
      nReDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
      if nReDs.RecordCount < 1 then
      begin
        nData:= 'δ��ѯ�����������Ϣ!';
        Exit;
      end;

      nNode:= Root.NodeNew('body');
      nNode.NodeNew('facSerialNo').ValueAsString:= gSysParam.FFactID;
      nNode.NodeNew('materiels').ValueAsString:= '';

      with nReDs do
      begin
        First;
        while not nReDs.Eof do
        begin
          nNode:= Root.NodeNew('materiel');
          with nNode do
          begin
            NodeNew('materielNo').ValueAsString   := FieldByName('M_ID').AsString;
            NodeNew('materielName').ValueAsString := FieldByName('M_Name').AsString;
            NodeNew('materielType').ValueAsString := FieldByName('M_Type').AsString;
            NodeNew('businessType').ValueAsString := FieldByName('BusType').AsString;
          end;
        end;
      end;
      nData := '�����ɹ�';
      Result:= True;
    finally
      begin
        with Root.FindNode('header') do
        begin
          if Result then NodeNew('rspCode').ValueAsString:= '0'
          else NodeNew('rspCode').ValueAsString:= '1';

          NodeNew('rspDesc').ValueAsString:= nData;
        end;

        nData := FPacker.XMLBuilder.WriteToString;
        WriteLog('������Ϣ����:' + nData);
      end;
    end;
  end;
end;

// �������۶�����Ϣ��ѯ
function TBusWorkerBusinessWebchat.SearchBill(var nData: string): Boolean;
var nStr, nBillNo : string;
    nRoot, nNode, nheader, nbody : TXmlNode;
    nReDs: TDataSet;
begin
  Result := False;
  with FPacker.XMLBuilder do
  begin
    try
      WriteLog('���۶�����ѯ��Σ�'+nData);
      ReadFromString(nData);
      if not ParseDefault(nData) then Exit;

      try
        nRoot := Root.FindNode('body');
        nBillNo:= nRoot.NodeByName('billNo').ValueAsString;

        if nBillNo='' then
        begin
          nData:= '����д�������!';
          Exit;
        end;
      except
        on Ex : Exception do
        begin
          nData:= '���������������!';
          WriteLog(nData+' '+Ex.Message);
          Exit;
        end;
      end;

      //************************************************************************
      //************************************************************************
      Root.Clear;
      nheader:= Root.NodeNew('header');
      with nheader do
      begin
        NodeNew('rspCode').ValueAsString:= '1';
        NodeNew('rspDesc').ValueAsString:= nData;
      end;

      nStr := ' Select * From ''%s'' Where L_ID=''%s''  ';
      nStr := Format(nStr, [sTable_Bill, nBillNo]);
      //*****
      nReDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
      if nReDs.RecordCount < 1 then
      begin
        nData:= 'δ��ѯ����ص���!';
        Exit;
      end;

      nNode:= Root.NodeNew('body');
      with nReDs do
      begin
        First;
        while not nReDs.Eof do
        begin
          with nNode do
          begin
            NodeNew('facSerialNo').ValueAsString:= gSysParam.FFactID;
            NodeNew('billNo').ValueAsString     := FieldByName('L_ID').AsString;

            if FieldByName('L_Status').AsString='O' then
              NodeNew('status').ValueAsString := '300'

            else if ((FieldByName('L_Status').AsString='I')or
                    (FieldByName('L_Status').AsString='P')or
                    (FieldByName('L_Status').AsString='M')Or
                    (FieldByName('L_Status').AsString='F')Or
                    (FieldByName('L_Status').AsString='Z')) then
              NodeNew('status').ValueAsString := '200'

            else if (FieldByName('M_L_StatusID').AsString='')and
                    (FieldByName('L_Card').AsString<>'') then
              NodeNew('status').ValueAsString := '100'

            else NodeNew('status').ValueAsString := '0';

            NodeNew('realQuantity').ValueAsString := FieldByName('L_Value').AsString;
          end;
        end;
      end;
      nData := '�����ɹ�';
      Result:= True;
    finally
      begin
        with Root.FindNode('header') do
        begin
          if Result then NodeNew('rspCode').ValueAsString:= '0'
          else NodeNew('rspCode').ValueAsString:= '1';

          NodeNew('rspDesc').ValueAsString:= nData;
        end;

        nData := FPacker.XMLBuilder.WriteToString;
        WriteLog('���۶�����Ϣ����:' + nData);
      end;
    end;
  end;
end;

// ���������
function TBusWorkerBusinessWebchat.CreateBill(var nData: string): Boolean;
var nStr, nBillNo : string;
    nRoot, nDetails, nDetail, nItem, nheader, nbody : TXmlNode;
    nReDs: TDataSet;
    nIdx : Integer;
begin
  Result := False;
  with FPacker.XMLBuilder do
  begin
    try
      WriteLog('�����������Σ�'+nData);
      ReadFromString(nData);
      if not ParseDefault(nData) then Exit;

      try
        nRoot := Root.FindNode('body');
        nBillNo:= nRoot.NodeByName('orderNo').ValueAsString;
        nBillNo:= nRoot.NodeByName('ctype').ValueAsString;
        nBillNo:= nRoot.NodeByName('type').ValueAsString;
        nBillNo:= nRoot.NodeByName('orderID').ValueAsString;
        nBillNo:= nRoot.NodeByName('totalQuantity').ValueAsString;
        nBillNo:= nRoot.NodeByName('drvName').ValueAsString;
        nBillNo:= nRoot.NodeByName('drvPhone').ValueAsString;
        nBillNo:= nRoot.NodeByName('licensePlate').ValueAsString;
        nBillNo:= nRoot.NodeByName('makeTime').ValueAsString;

        nBillNo:= nRoot.NodeByName('totalQuantity').ValueAsString;
        nBillNo:= nRoot.NodeByName('totalQuantity').ValueAsString;
      except
        on Ex : Exception do
        begin
          nData:= '���������������!';
          WriteLog(nData+' '+Ex.Message);
          Exit;
        end;
      end;
      
      //************************************************************************
      //************************************************************************
      Root.Clear;
      nheader:= Root.NodeNew('header');
      with nheader do
      begin
        NodeNew('rspCode').ValueAsString:= '1';
        NodeNew('rspDesc').ValueAsString:= nData;
      end;

      nStr := ' Select * From ''%s'' Where L_ID=''%s''  ';
      nStr := Format(nStr, [sTable_Bill, nBillNo]);
      //*****
      nReDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
      if nReDs.RecordCount < 1 then
      begin
        nData:= 'δ��ѯ����ص���!';
        Exit;
      end;

      nDetails:= Root.FindNode('details');
      for nIdx:= 0 to nDetails.NodeCount-1 do
      begin
        nItem := nDetails[nIdx];

        FListB.Clear;
        with FListB, nItem do
        begin
          //Values['DtlID']  := NodeByName('orderDetailID').ValueAsString;
          Values['DtlType']   := NodeByName('orderDetailType').ValueAsString;
          Values['CusID']     := NodeByName('clientNo').ValueAsString;
          Values['CusName']   := NodeByName('clientName').ValueAsString;
          Values['ZID']       := NodeByName('contractNo').ValueAsString;
          Values['StockID']   := NodeByName('materielNo').ValueAsString;
          Values['StockName'] := NodeByName('materielName').ValueAsString;
          Values['Value']     := NodeByName('quantity').ValueAsString;
        end;
        FListA.Add(FListB.Text);
      end;
      PackerEncodeStr(FListA.Text);

      nData := '�����ɹ�';
      Result:= True;
    finally
      begin
        with Root.FindNode('header') do
        begin
          if Result then NodeNew('rspCode').ValueAsString:= '0'
          else NodeNew('rspCode').ValueAsString:= '1';

          NodeNew('rspDesc').ValueAsString:= nData;
        end;

        nData := FPacker.XMLBuilder.WriteToString;
        WriteLog('�������������:' + nData);
      end;
    end;
  end;
end;

// �������۶�����α���ѯ�����Σ�
function TBusWorkerBusinessWebchat.SearchSecurityCode(var nData: string): Boolean;
var nStr, nFacID, nSeCode : string;
    nRoot, nNode, nheader, nbody : TXmlNode;
    nReDs: TDataSet;
begin
  Result := False;
  with FPacker.XMLBuilder do
  begin
    try
      WriteLog('��α���ѯ��Σ�'+nData);
      ReadFromString(nData);
      if not ParseDefault(nData) then Exit;

      try
        nRoot := Root.FindNode('body');
        nFacID := nRoot.NodeByName('facSerialNo').ValueAsString;
        nSeCode:= nRoot.NodeByName('securityCode').ValueAsString;

        if nFacID<>gSysParam.FFactID then
        begin
          nData:= '����ID�뵱ǰ������Ϣ��ƥ�䣬����!';
          Exit;
        end;
      except
        on Ex : Exception do
        begin
          nData:= '���������������!';
          WriteLog(nData+' '+Ex.Message);
          Exit;
        end;
      end;

      Root.Clear;
      nheader:= Root.NodeNew('header');
      with nheader do
      begin
        NodeNew('rspCode').ValueAsString:= '1';
        NodeNew('rspDesc').ValueAsString:= nData;
      end;

      nStr := ' Select * From ''%s'' Where R_SerialNo=''%s''  ';
      nStr := Format(nStr, [sTable_StockRecord, nSeCode]);
      //*****
      nReDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
      if nReDs.RecordCount < 1 then
      begin
        nData:= 'δ��ѯ����ص���!';
        Exit;
      end;

      nbody:= Root.NodeNew('body');
      with nReDs, nbody do
      begin
        NodeNew('facSerialNo').ValueAsString:= gSysParam.FFactID;
        NodeNew('clientNo').ValueAsString   := FieldByName('L_ID').AsString;
        NodeNew('realQuantity').ValueAsString := FieldByName('L_Value').AsString;
      end;
      nData := '�����ɹ�';
      Result:= True;
    finally
      begin
        with Root.FindNode('header') do
        begin
          if Result then NodeNew('rspCode').ValueAsString:= '0'
          else NodeNew('rspCode').ValueAsString:= '1';

          NodeNew('rspDesc').ValueAsString:= nData;
        end;

        nData := FPacker.XMLBuilder.WriteToString;
        WriteLog('��α���ѯ����:' + nData);
      end;
    end;
  end;
end;

// ����������Ϣ��ѯ
function TBusWorkerBusinessWebchat.QueryTruckQuery(var nData: string): Boolean;
var nStr, nFacID, nTruckNo, nTruckLine, nTruckRanking : string;
    nRoot, nheader, nbody, nPrincipalQueue, nQueues, nQueue : TXmlNode;
    nReDs, nDataDs: TDataSet;
begin
  Result := False;
  with FPacker.XMLBuilder do
  begin
    try
      WriteLog('�������в�ѯ��Σ�'+nData);
      ReadFromString(nData);
      if not ParseDefault(nData) then Exit;

      try
        nRoot := Root.FindNode('body');
        nFacID  := nRoot.NodeByName('facSerialNo').ValueAsString;
        nTruckNo:= nRoot.NodeByName('licensePlate').ValueAsString;

        if nFacID<>gSysParam.FFactID then
        begin
          nData:= '����ID�뵱ǰ������Ϣ��ƥ�䣬����!';
          Exit;
        end;
      except
        on Ex : Exception do
        begin
          nData:= '���������������!';
          WriteLog(nData+' '+Ex.Message);
          Exit;
        end;
      end;

      Root.Clear;
      nheader:= Root.NodeNew('header');
      with nheader do
      begin
        NodeNew('rspCode').ValueAsString:= '1';
        NodeNew('rspDesc').ValueAsString:= nData;
      end;

      nbody  := Root.NodeNew('body');
      with nbody do
      begin
        NodeNew('facSerialNo').ValueAsString:= gSysParam.FFactID;
        //************************************************************************ �������ڳ�����Ϣ
        if nTruckNo<>'' then
        begin
          nStr := ' Select * From ''%s'' Where L_Status<>''O'' And L_Truck=''%s'' ';
          nStr := Format(nStr, [sTable_Bill, nTruckNo]);
          //*****
          nReDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
          if nReDs.RecordCount < 1 then
          begin
            nData:= 'δ��ѯ���ó���������Ϣ!';
            Exit;
          end;

          nStr := ' Select * From ''%s'' Where T_Truck=''%s'' ';
          nStr := Format(nStr, [sTable_ZTTrucks, nTruckNo]);
          //*****
          nReDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
          if nReDs.RecordCount < 1 then
          begin
            nData:= 'δ��ѯ���ó���������Ϣ!';
            Exit;
          end;
          nTruckLine:= nReDs.FieldByName('T_Line').AsString;

          nStr := ' Select ROW_NUMBER() over(order by T_InFact) RID, * From ''%s'' '+
                  ' Where T_Line=''%s''  Order by T_InFact ';
          nStr := Format(nStr, [sTable_ZTTrucks, nTruckLine]);
          //*****
          nDataDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
          with nDataDs do
          while not Eof do
          begin
            if FieldByName('T_Truck').AsString=nTruckNo then
            begin
              nTruckRanking:= FieldByName('RID').AsString;
              Break;
            end;
            Next;
          end;

          with NodeNew('principalQueue') do
          begin
            NodeNew('materielName').ValueAsString:= nDataDs.FieldByName('T_Stock').AsString;
            NodeNew('lineChannel').ValueAsString := nTruckLine;
            NodeNew('truckCount').ValueAsInteger := nDataDs.RecordCount;
            NodeNew('currentRanking').ValueAsString:= nTruckRanking;
          end;
        end;

        //************************************************************************  ȫ��������Ϣ
        //nStr := 'Select T_Stock, T_Line, COUNT(*) From %s Where T_Line is Not Null Group by T_Stock, T_Line ';
        nStr := 'Select Z_ID, Z_Name, Z_StockNo, Z_Stock, T_Line, ' +
                '	Case When (T_Line IS Null) then 0 else COUNT(*) end LCount From %s ' +
                'Left Join %s on Z_ID=T_Line ' +
                'Group by Z_ID, Z_Name, Z_StockNo, Z_Stock, T_Line ';
        nStr := Format(nStr, [sTable_ZTLines, sTable_ZTTrucks]);
        nDataDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
        if nDataDs.RecordCount>0 then
        with nDataDs do
        begin
          First;
          nQueues:= NodeNew('queues');
          with nQueues do
          begin
            while not Eof do
            begin
              nQueue:= NodeNew('queue');
              with nQueue do
              begin
                NodeNew('materielName').ValueAsString:= FieldByName('Z_Stock').AsString;
                NodeNew('lineChannel').ValueAsString := FieldByName('Z_Name').AsString;
                NodeNew('truckCount').ValueAsInteger := FieldByName('LCount').AsInteger;
              end;
              Next;
            end;
          end;
        end;
      end;
      nData := '�����ɹ�';
      Result:= True;
    finally
      begin
        nheader:= Root.FindNode('header');
        with nheader do
        begin
          if Result then NodeNew('rspCode').ValueAsString:= '0'
          else NodeNew('rspCode').ValueAsString:= '1';

          NodeNew('rspDesc').ValueAsString:= nData;
        end;

        nData := FPacker.XMLBuilder.WriteToString;
        WriteLog('�������в�ѯ����:' + nData);
      end;
    end;
  end;
end;

// �������ۡ��ɹ�ͳ����Ϣ��ѯ
function TBusWorkerBusinessWebchat.BillStats(var nData: string): Boolean;
var nStr, nFacID, nSType, nSDate, nEDate, nType : string;
    nRoot, nheader, nbody, nStatItems, nStatItem : TXmlNode;
    nReDs : TDataSet;
begin
  Result := False;
  with FPacker.XMLBuilder do
  begin
    try
      WriteLog('���ۡ��ɹ�ͳ�Ʋ�ѯ��Σ�'+nData);
      ReadFromString(nData);
      if not ParseDefault(nData) then Exit;

      try
        nRoot := Root.FindNode('body');
        nFacID := nRoot.NodeByName('facSerialNo').ValueAsString;
        nSType := nRoot.NodeByName('statType').ValueAsString;
        nSDate := nRoot.NodeByName('startDate').ValueAsString;
        nEDate := nRoot.NodeByName('endDate').ValueAsString;

        if nFacID<>gSysParam.FFactID then
        begin
          nData:= '����ID�뵱ǰ������Ϣ��ƥ�䣬����!';
          Exit;
        end;
      except
        on Ex : Exception do
        begin
          nData:= '���������������!';
          WriteLog(nData+' '+Ex.Message);
          Exit;
        end;
      end;

      Root.Clear;
      nheader:= Root.NodeNew('header');
      with nheader do
      begin
        NodeNew('rspCode').ValueAsString:= '1';
        NodeNew('rspDesc').ValueAsString:= nData;
      end;

      nbody  := Root.NodeNew('body');
      with nbody do
      begin
        NodeNew('facSerialNo').ValueAsString:= gSysParam.FFactID;
        NodeNew('statType').ValueAsString   := nSType;
        //************************************************************************
        if nSType<>'S' then         //*************  ���۳���
        begin
          nStr := ' Select L_StockNo, L_StockName, L_Type, SUM(L_Value) L_Value, COUNT(*) L_Count From %s ' +
                  ' Where  L_OutFact>=''%s 00:00:00'' and L_OutFact<=''%s 23:59:59'' ' +
                  ' Group  by L_StockNo, L_StockName, L_Type ';
          nStr := Format(nStr, [sTable_Bill, nSDate, nEDate]);
        end
        else if nSType<>'SZ' then   //*************  ���۽���
        begin
          nStr := ' Select L_StockNo, L_StockName, L_Type, SUM(L_Value) L_Value, COUNT(*) L_Count From %s ' +
                  ' Where  L_InTime>=''%s 00:00:00'' and L_InTime<=''%s 23:59:59'' ' +
                  ' Group  by L_StockNo, L_StockName, L_Type ';
          nStr := Format(nStr, [sTable_Bill, nSDate, nEDate]);
        end
        else if nSType<>'P' then    //*************  �ɹ�����
        begin
          nStr := ' Select D_StockNo, D_StockName, D_Type, SUM(D_MValue-D_PValue-ISNULL(D_KZValue, 0)) D_Value, COUNT(*) D_Count From %s ' +
                  ' Where  D_InTime>=''%s 00:00:00'' and D_InTime<=''%s 23:59:59'' ' +
                  ' Group  by D_StockNo, D_StockName, D_Type ';
          nStr := Format(nStr, [sTable_Bill, nSDate, nEDate]);
        end
        else if nSType<>'PZ' then    //*************  �ɹ�����
        begin
          nStr := ' Select D_StockNo, D_StockName, D_Type, SUM(D_MValue-D_PValue-ISNULL(D_KZValue, 0)) D_Value, COUNT(*) D_Count From %s ' +
                  ' Where  D_OutFact>=''%s 00:00:00'' and D_OutFact<=''%s 23:59:59'' ' +
                  ' Group  by D_StockNo, D_StockName, D_Type ';
          nStr := Format(nStr, [sTable_Bill, nSDate, nEDate]);
        end;


        nReDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
        if nReDs.RecordCount < 1 then
        begin
          nData:= 'δ��ѯ�������Ϣ!';
          Exit;
        end;

        nStatItems:= NodeNew('statItems');
        with nStatItems, nReDs do
        begin
            First;
            while not Eof do
            begin
                nStatItem:= NodeNew('statItem');
                with nStatItem do
                begin
                  if FieldByName('L_Type').AsString='D' then
                    nType:= '1' else nType:= '2';

                  NodeNew('materielNo').ValueAsString    := FieldByName('L_StockNo').AsString;
                  NodeNew('materielName').ValueAsString  := FieldByName('L_StockName').AsString;
                  NodeNew('materielType').ValueAsString  := nType;
                  NodeNew('truckCount').ValueAsInteger   := FieldByName('L_Count').AsInteger;
                  NodeNew('totalQuantity').ValueAsInteger:= FieldByName('L_Value').AsInteger;
                end;
                Next;
            end;
        end;
      end;
      nData := '�����ɹ�';
      Result:= True;
    finally
      begin
        with Root.FindNode('header') do
        begin
          if Result then NodeNew('rspCode').ValueAsString:= '0'
          else NodeNew('rspCode').ValueAsString:= '1';

          NodeNew('rspDesc').ValueAsString:= nData;
        end;

        nData := FPacker.XMLBuilder.WriteToString;
        WriteLog('���ۡ��ɹ�ͳ�Ʋ�ѯ����:' + nData);
      end;
    end;
  end;
end;

// �������۶������鵥��ѯ
function TBusWorkerBusinessWebchat.HYDanReport(var nData: string): Boolean;
var nStr, nFacID, nbillNo, nRptType : string;
    nRoot, nheader, nbody, nItems, nItem : TXmlNode;
    nReDs : TDataSet;
begin
  Result := False;
  with FPacker.XMLBuilder do
  begin
    try
      WriteLog('���鵥��ѯ��Σ�'+nData);
      ReadFromString(nData);
      if not ParseDefault(nData) then Exit;

      try
        nRoot := Root.FindNode('body');
        nFacID  := nRoot.NodeByName('facSerialNo').ValueAsString;
        nRptType:= nRoot.NodeByName('reportType').ValueAsString;
        nbillNo := nRoot.NodeByName('billNo').ValueAsString;

        if nFacID<>gSysParam.FFactID then
        begin
          nData:= '����ID�뵱ǰ������Ϣ��ƥ�䣬����!';
          Exit;
        end;
      except
        on Ex : Exception do
        begin
          nData:= '���������������!';
          WriteLog(nData+' '+Ex.Message);
          Exit;
        end;
      end;

      Root.Clear;
      nheader:= Root.NodeNew('header');
      with nheader do
      begin
        NodeNew('rspCode').ValueAsString:= '1';
        NodeNew('rspDesc').ValueAsString:= nData;
      end;

      nbody  := Root.NodeNew('body');
      with nbody do
      begin
        NodeNew('facSerialNo').ValueAsString:= gSysParam.FFactID;
        NodeNew('reportType').ValueAsString := nRptType;
        //************************************************************************
        nStr := ' Select hy.*,sr.*,C_Name From %s HY   ' +
                ' Left Join %s cus on cus.C_ID=HY.H_Custom  ' +
                ' Left Join (  ' +
                '  Select * From S_StockRecord sr Left Join S_StockParam sp on sp.P_ID=sr.R_PID ' +
                '  ) sr on sr.R_SerialNo=H_SerialNo ' +
                ' Where H_Reporter=''%s'' ';
        nStr := Format(nStr, [sTable_StockHuaYan, sTable_Customer, sTable_StockRecord,
                              sTable_StockParam, nbillNo]);
        nReDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
        if nReDs.RecordCount < 1 then
        begin
          nData:= 'δ��ѯ�������Ϣ!';
          Exit;
        end;

        nItems:= NodeNew('reportResults');
        with nItems, nReDs do
        begin
            First;
            while not Eof do
            begin
                nItem:= NodeNew('reportResult');
                with nItem do
                begin
                  NodeNew('CusID').ValueAsString    := FieldByName('H_Custom').AsString;
                  NodeNew('CusName').ValueAsString  := FieldByName('H_CusName').AsString;
                  NodeNew('SerialNo').ValueAsString := FieldByName('R_SerialNo').AsString;
                  NodeNew('RPID').ValueAsString     := FieldByName('R_PID').AsString;
                  NodeNew('Rso3').ValueAsString     := FieldByName('R_SO3').AsString;
                  NodeNew('ShaoShi').ValueAsString  := FieldByName('R_ShaoShi').AsString;
                  NodeNew('ChuNing').ValueAsString  := FieldByName('R_ChuNing').AsString;
                  NodeNew('ZhongNing').ValueAsString:= FieldByName('R_ZhongNing').AsString;
                end;
                Next;
            end;
        end;
      end;
      nData := '�����ɹ�';
      Result:= True;
    finally
      begin
        with Root.FindNode('header') do
        begin
          if Result then NodeNew('rspCode').ValueAsString:= '0'
          else NodeNew('rspCode').ValueAsString:= '1';

          NodeNew('rspDesc').ValueAsString:= nData;
        end;

        nData := FPacker.XMLBuilder.WriteToString;
        WriteLog('���鵥��ѯ����:' + nData);
      end;
    end;
  end;
end;


procedure TBusWorkerBusinessWebchat.ReQuestInit;
begin
  //****************************
  FidHttp.Request.Clear;
  FidHttp.Request.Accept         := 'application/json, text/javascript, */*; q=0.01';
  FidHttp.Request.AcceptLanguage := 'zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3';
  FidHttp.Request.ContentType    := 'application/json;Charset=UTF-8';
  FidHttp.Request.Connection     := 'keep-alive';
end;

function TBusWorkerBusinessWebchat.GetWebStatus(nCode: string): string;
begin
  if nCode='N' then Result:= '0'
  else if nCode='I' then Result:= '3'
  else if nCode='P' then Result:= '3'
  else if (nCode='F')or(nCode='Z') then Result:= '3'
  else if nCode='M' then Result:= '3'
  else if nCode='O' then Result:= '4';
end;

function TBusWorkerBusinessWebchat.GetshoporderStatus(
  var nData: string): Boolean;
var nStr, nFacID, nbillNo, nRptType, nOutTime, nStatus : string;
    nRoot, nheader, nbody, nItems, nItem : TXmlNode;
    nReDs : TDataSet;
    ParamJo, OneJo: ISuperObject;
    ArrsJa: ISuperObject;
    nTotal:Double;
begin
  Result := False;
  with FPacker.XMLBuilder do
  begin
    try
      WriteLog('����״̬��ѯ��Σ�'+nData);
      ReadFromString(nData);
      if not ParseDefault(nData) then Exit;

      try
        nRoot := Root.FindNode('Head');
        nbillNo  := nRoot.NodeByName('Data').ValueAsString;
        nRptType:= nRoot.NodeByName('ExtParam').ValueAsString;
      except
        on Ex : Exception do
        begin
          nData:= '���������������!';
          WriteLog(nData+' '+Ex.Message);
          Exit;
        end;
      end;

      ParamJo:= SO();
      with ParamJo do
      begin
        ParamJo.S['orderNo'] := nbillNo;
        //************************************************************************
        if nRptType='1' then
        begin
          nStr := ' Select * From S_BILL Where L_ID In (Select distinct WOM_LID From S_WebOrderMatch Where WOM_WebOrderID='''+nbillNo+''' ) ';
        end
        else
        begin
          nStr := ' Select * From P_OrderDtl left Join P_Order On D_OID=O_ID left Join P_OrderBase On O_BID=B_ID '+
                  ' Where D_ID In (Select distinct WOM_LID From S_WebOrderMatch Where WOM_WebOrderID='''+nbillNo+''')';
        end;

        nReDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
        if nReDs.RecordCount < 1 then
        begin
          nData:= 'δ��ѯ������������Ϣ!';
          Exit;
        end;


        ArrsJa:= SA([]);
        nTotal:= 0;
        with nReDs do
        begin
          while not Eof do
          begin
            OneJo := SO();

            if nRptType='1' then
            begin
              OneJo.S['billNo']      := FieldByName('L_ID').AsString;
              OneJo.S['contractNo']  := FieldByName('L_ZhiKa').AsString;
              OneJo.D['realQuantity']:= FieldByName('L_Value').AsFloat;

              nTotal  := nTotal + FieldByName('L_Value').AsFloat;
              nOutTime:= FieldByName('L_OutFact').AsString;
              nStatus := GetWebStatus(FieldByName('L_Status').AsString);
            end
            else if nRptType='2' then
            begin
              OneJo.S['BillNo']      := FieldByName('D_ID').AsString;
              OneJo.S['contractNo']  := FieldByName('B_ID').AsString;
              OneJo.D['realQuantity']:= FieldByName('D_Value').AsFloat;

              nTotal  := nTotal + FieldByName('D_Value').AsFloat;
              nOutTime:= FieldByName('D_OutFact').AsString;
              nStatus := GetWebStatus(FieldByName('D_Status').AsString);
            end;
            ArrsJa.O['detail']:= OneJo;

            Next;
          end;

          ParamJo.S['details'] := ArrsJa.AsString;
        end;
      end;
      nData := '�����ɹ�';
      Result:= True;
    finally
      begin
        if Result then ParamJo.S['Code']:= '0'
        else ParamJo.S['Code']:= '1';

        ParamJo.S['outFactoryTime'] := nOutTime;
        ParamJo.S['realTotalQuantity'] := FloatToStr(nTotal);
        ParamJo.S['status'] := nStatus;

        nData := ParamJo.AsString;
        WriteLog('����״̬��ѯ����:' + nData);
      end;
    end;
  end;
end;

function TBusWorkerBusinessWebchat.GetShopTruck(
  var nData: string): boolean;
var
  nStr, nWebOrder, szUrl: string;
  ReJo, ParamJo, BodyJo, OneJo, ReBodyJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam : TStrings;
  ReStream: TStringStream;
  nIdx: Integer;
begin
  Result    := False;
  nWebOrder := PackerDecodeStr(FIn.FData);
  wParam    := TStringList.Create;
  ReStream  := TStringstream.Create('');
  ParamJo   := SO();
  BodyJo    := SO();
  try
    BodyJo.S['reviewStatus'] := nWebOrder;  //04���ᱨ�� 06�����ͨ�� 07����˲���
    BodyJo.S['facSerialNo']  := gSysParam.FFactID; 

    ParamJo.S['activeCode']  := Cus_ShopTruck;
    ParamJo.S['body'] := BodyJo.AsString;
    nStr := ParamJo.AsString;
    //nStr := Ansitoutf8(nStr);
    WriteLog('��ȡ������Ϣ���:' + nStr);

    wParam.Clear;
    wParam.Add(nStr);
    //FidHttp������ʼ��
    ReQuestInit;
    
    szUrl := gSysParam.FSrvUrl + '/truck/searchFacTruck';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog('��ȡ������Ϣ����:' + nStr);

    if nStr <> '' then
    begin
      FListA.Clear;
      FListB.Clear;
      ReJo := SO(nStr);
      if ReJo = nil then Exit;

      if ReJo.S['code'] = '1' then
      begin
        ReBodyJo := SO(ReJo.S['body']);
        if ReBodyJo = nil then Exit;

        ArrsJa := ReBodyJo['facTrucks'].AsArray;
        for nIdx := 0 to ArrsJa.Length - 1 do
        begin
          OneJo := SO(ArrsJa[nIdx].AsString);

          with FListB do
          begin
            Values['id']              := OneJo.S['id'];           //����
            Values['cnsSerialNo']     := OneJo.S['cnsSerialNo'];  //������ʶ��
            Values['licensePath']     := OneJo.S['licensePath'];  //��ʻ֤ͼƬ·��
            Values['licensePlate']    := OneJo.S['licensePlate']; //���ƺ�
            Values['reviewStatus']    := OneJo.S['reviewStatus']; //���״̬
            Values['phone']           := OneJo.S['phone'];         //�绰����
            Values['realName']        := OneJo.S['realName'];      //�ͻ�����
            Values['tare']            := OneJo.S['tare'];          //Ƥ��
          end;
          SaveAuditTruck(FlistB,nWebOrder);
          FListA.Add(PackerEncodeStr(FListB.Text));
        end;
        
        Result             := True;
        FOut.FData         := FListA.Text;
        FOut.FBase.FResult := True;
      end
      else WriteLog('��ȡ������Ϣʧ�ܣ�' + ReJo.S['msg']);
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessWebchat.SyncShopTruckState(
  var nData: string): boolean;
var
  nStr, nSql, ncontractNo: string;
  nDBConn: PDBWorker;
  nIdx: Integer;
  szUrl: string;
  ReJo, ParamJo, BodyJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream: TStringStream;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');
  BodyJo   := SO();
  ParamJo  := SO();

  FListA.Text := PackerDecodeStr(FIn.FData);
  try
    BodyJo.S['licensePlate']    := EncodeBase64(FListA.Values['Truck']);
    BodyJo.S['reviewStatus']    := FListA.Values['Status'];
    BodyJo.S['facSerialNo']     := gSysParam.FFactID;
    BodyJo.S['auditDecision']   := EncodeBase64(FListA.Values['Memo']);
    ParamJo.S['activeCode']     := Cus_syncTruckState;
    ParamJo.S['body']           := BodyJo.AsString;
    nStr                        := ParamJo.AsString;

    WriteLog(' ͬ���������״̬��Σ�' + nStr);

    //nStr := UTF8Encode(nStr);
    wParam.Clear;
    wParam.Add(nStr);
    
    //FidHttp������ʼ��
    ReQuestInit;

    szUrl := gSysParam.FSrvUrl + '/truck/synFacTruck';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog(' ͬ���������״̬���Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo := SO(nStr);

      if ReJo['code'].AsString = '1' then
      begin
        Result             := True;
        FOut.FData         := sFlag_Yes;
        FOut.FBase.FResult := True;
      end
      else WriteLog(' ͬ���������״̬ʧ�ܣ�' + ReJo['msg'].AsString);
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessWebchat.get_QueueInfobyTruck(
  var nData: string): Boolean;
var
  nStr, nTruckNumber, nStockNo : string;
  nNode,  nheader  : TXmlNode;
begin
  Result := False;

  with FPacker.XMLBuilder do
  begin
    try
      ReadFromString(nData);
      nData  := '�����������ʧ��';

      nheader := Root.FindNode('Head');
      //************************************************************
      try
        nTruckNumber := nheader.NodeByName('Data').ValueAsString;

        if nTruckNumber <> '' then
        begin
          nStr := ' Select * From %s Where L_Status <> ''O'' And L_Truck=''%s'' ';
          nStr := Format(nStr, [sTable_Bill, nTruckNumber]);
          //*****
          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
          begin
            if RecordCount < 1 then
            begin
              nData := '�Ҳ����˳��ƺŵ���Ч����.';
              with Root.NodeNew('EXMG') do
              begin
                NodeNew('MsgTxt').ValueAsString     := nData;
                NodeNew('MsgResult').ValueAsString  := sFlag_No;
                NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
              end;
              nData := FPacker.XMLBuilder.WriteToString;
              Exit;
            end;
            nStockNo := FieldByName('L_StockNo').AsString;
          end;
          
        end;
      except
        on Ex : Exception do
        begin
          nData  := nData + '��ѯ����������Ϣʧ��!'+Ex.Message;
          WriteLog(nData);
        end;
      end;
   finally
   end;
  end;

  BuildDefaultXML;

  nStr := ' Select * From %s Where T_Valid = ''%s'' And T_Truck = ''%s'' and T_InFact is not null ';
  nStr := Format(nStr, [sTable_ZTTrucks, sFlag_Yes, nTruckNumber]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr), FPacker.XMLBuilder do
  begin
    if RecordCount > 0 then
    begin
      nData := '����(%s)�ѽ���.';
      nData := Format(nData, [nTruckNumber]);
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString := nData;
        NodeNew('MsgResult').ValueAsString := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;

      Exit;
    end;
  end;
  
  nStr := ' Select * From %s Where T_Valid = ''%s'' And T_StockNo = ''%s'' And T_InQueue Is Null order by T_InTime ';
  nStr := Format(nStr, [sTable_ZTTrucks, sFlag_Yes, nStockNo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr), FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nData := 'Ʒ��(%s)û�д������ĳ���.';
      nData := Format(nData, [nStockNo]);
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString := nData;
        NodeNew('MsgResult').ValueAsString := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;

      Exit;
    end;

    First;

    nNode := Root.NodeNew('Items');
    while not Eof do
    begin
      with nNode.NodeNew('Item') do
      begin
        NodeNew('TruckNo').ValueAsString   := FieldByName('T_Truck').AsString;
        NodeNew('StockNo').ValueAsString   := FieldByName('T_Stock').AsString;
      end;

      nExt;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  Result := True;
end;

function TBusWorkerBusinessWebchat.get_ClientReportInfo(
  var nData: string): Boolean;
var
  nStr, nClientNo, nStockNo, nType : string;
  nStart, nEnd, nSumStr : string;
  nNode,  nheader  : TXmlNode;

  function GetLeftStr(SubStr, Str: string): string;
  begin
    Result := Copy(Str, 1, Pos(SubStr, Str) - 1);
  end;
  function GetRightStr(SubStr, Str: string): string;
  var
     i: integer;
  begin
     i := pos(SubStr, Str);
     if i > 0 then
       Result := Copy(Str
         , i + Length(SubStr)
         , Length(Str) - i - Length(SubStr) + 1)
     else
       Result := '';
  end;
begin
  Result := False;

  with FPacker.XMLBuilder do
  begin
    try
      ReadFromString(nData);
      nData  := '�����������ʧ��';

      nheader := Root.FindNode('Head');
      //************************************************************
      try
        nClientNo := nheader.NodeByName('ClientNo').ValueAsString;
        nType     := nheader.NodeByName('Data').ValueAsString;
        nSumStr   := nheader.NodeByName('ExtParam').ValueAsString;

        nStart    := GetLeftStr('and', nSumStr);
        nEnd      := GetRightStr('and',nSumStr);

        if (nClientNo = '') or (nType = '') then
        begin
          nData := '�����������ʧ��.';
          with Root.NodeNew('EXMG') do
          begin
            NodeNew('MsgTxt').ValueAsString     := nData;
            NodeNew('MsgResult').ValueAsString  := sFlag_No;
            NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
          end;
          nData := FPacker.XMLBuilder.WriteToString;
          Exit;
        end;
      except
        on Ex : Exception do
        begin
          nData  := nData + '��ѯ������Ϣʧ��!'+Ex.Message;
          WriteLog(nData);
        end;
      end;
   finally
   end;
  end;

  BuildDefaultXML;
  if nType = '1' then
  begin
    nStr := ' select L_StockNo, L_StockName, SUM(L_Value) as L_Value, COUNT(*) as nCount  from %s '+
            ' where L_CusID = ''%s'' and L_OutFact >= ''%s'' and L_OutFact <= ''%s'' group by L_StockNo, L_StockName  ';
    nStr := Format(nStr, [sTable_Bill, nClientNo,nStart,nEnd]);
  end
  else
  begin
    nStr := ' select a.O_StockNo as L_StockNo,a.O_StockName as L_StockName, SUM(D_Value) as L_Value, COUNT(*) as nCount  from %s a, %s b '+
            ' where a.O_ID = b.D_OID and a.O_ProID = ''%s'' and b.D_OutFact >= ''%s'' and b.D_OutFact <= ''%s'' group by a.O_StockNo,a.O_StockName  ';
    nStr := Format(nStr, [sTable_Order, sTable_OrderDtl, nClientNo,nStart,nEnd]);
  end;
  //*****
  with gDBConnManager.WorkerQuery(FDBConn, nStr), FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nData := '�˿ͻ��ڱ��ڼ����޵���.';
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;
      Exit;
    end;

    First;
    nNode := Root.NodeNew('Items');
    while not Eof do
    begin
      with nNode.NodeNew('Item') do
      begin
        NodeNew('Value').ValueAsString      := FieldByName('L_Value').AsString;
        NodeNew('StockNo').ValueAsString    := FieldByName('L_StockNo').AsString;
        NodeNew('StockName').ValueAsString  := FieldByName('L_StockName').AsString;
        NodeNew('Count').ValueAsString      := FieldByName('nCount').AsString;
      end;
      
      nExt;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString     := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;

  end;
  
  nData  := FPacker.XMLBuilder.WriteToString;
  Result := True;
end;

function TBusWorkerBusinessWebchat.get_TruckMaxBillNumInfo(
  var nData: string): Boolean;
var
  nStr, nTruckNumber, nStockNo : string;
  nNode,  nheader  : TXmlNode;
begin
  Result := False;

  with FPacker.XMLBuilder do
  begin
    try
      ReadFromString(nData);
      nData  := '�����������ʧ��';

      nheader := Root.FindNode('Head');
      //************************************************************
      try
        nTruckNumber := nheader.NodeByName('Data').ValueAsString;
        if nTruckNumber = '' then
        begin
          nData := '�����������ʧ��.';
          with Root.NodeNew('EXMG') do
          begin
            NodeNew('MsgTxt').ValueAsString     := nData;
            NodeNew('MsgResult').ValueAsString  := sFlag_No;
            NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
          end;
          nData := FPacker.XMLBuilder.WriteToString;
          Exit;
        end;
      except
        on Ex : Exception do
        begin
          nData  := nData + '��ѯ������Ϣʧ��!'+Ex.Message;
          WriteLog(nData);
        end;
      end;
   finally
   end;
  end;

  BuildDefaultXML;

  nStr := ' Select * From %s Where T_Truck = ''%s'' ';
  nStr := Format(nStr, [sTable_Truck, nTruckNumber]);
  //*****
  with gDBConnManager.WorkerQuery(FDBConn, nStr), FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nData := 'δ���ڴ˳�����Ϣ,����ϵ����Ա���.';
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;
      Exit;
    end;

    First;
    nNode := Root.NodeNew('Items');
    while not Eof do
    begin
      with nNode.NodeNew('Item') do
      begin
        NodeNew('MaxBillNum').ValueAsString := FieldByName('T_MaxBillNum').AsString;
        NodeNew('PrePValue').ValueAsString  := FieldByName('T_PrePValue').AsString;
      end;
      
      nExt;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString     := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;

  end;
  
  nData  := FPacker.XMLBuilder.WriteToString;
  Result := True;
end;

function TBusWorkerBusinessWebchat.Get_ShopordersYY(
  var nData: string): Boolean;
var
  nStr, nWebOrder, szUrl: string;
  ReJo, ParamJo, BodyJo, OneJo, ReBodyJo : ISuperObject;
  wParam,FListD: TStrings;
  ReStream: TStringStream;
  nIdx, i : Integer;
  nStart,nEnd : string;
  ArrsM,ArrsN: TSuperArray;
begin
  Result := False;
 // nWebOrder := PackerDecodeStr(FIn.FData);
  nStart := Date2Str(Now);
  nEnd   := Date2Str(Now+1);
  wParam := TStringList.Create;
  FListD := TStringList.Create;
  ReStream := TStringstream.Create('');
  ParamJo := SO();
  BodyJo := SO();
  try
    BodyJo.S['searchType'] := '4';             //1������ 2���ƺ� 3���֤�Ų�ѯ 4ʱ���ѯ
    BodyJo.S['queryWord']  := nStart+';'+nEnd;
    BodyJo.S['facSerialNo']:= gSysParam.FFactID;

    ParamJo.S['activeCode']  := Cus_ShopOrder;
    ParamJo.S['body'] := BodyJo.AsString;
    nStr := ParamJo.AsString;
    //nStr := Ansitoutf8(nStr);
    WriteLog('��ȡ������Ϣ���:' + nStr);

    wParam.Clear;
    wParam.Add(nStr);
    //FidHttp������ʼ��
    ReQuestInit;

    szUrl := gSysParam.FSrvUrl + '/order/searchShopOrder';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog('��ȡ������Ϣ����:' + nStr);

    nStr := StringReplace(nStr, '\"', '"', [rfReplaceAll]) ;
    nStr := StringReplace(nStr, '"[', '[', [rfReplaceAll]) ;
    nStr := StringReplace(nStr, ']"', ']', [rfReplaceAll]) ;

    FListA.Clear;
    FListC.Clear;
    FListD.Clear;

    if nStr <> '' then
    begin
      ReJo := SO(nStr);
      if ReJo = nil then Exit;

      if ReJo.S['code'] = '1' then
      begin
        ArrsM := ReJo.A['body'];
        if ArrsM.Length = 0 then Exit;

        for i:=0 to ArrsM.Length - 1 do
        begin
          ArrsN := ArrsM[i].A['details'];

          OneJo  := SO(ArrsN[0].AsString);
          nStr   := MakeSQLByStr([SF('W_WebOrderID',ArrsM[i].S['orderNo']),
            SF('W_OrderNo',  OneJo.S['contractNo']),
            SF('W_CusID',    OneJo.S['clientNo']),
            SF('W_Customer', OneJo.S['clientName']),
            SF('W_Truck',    ArrsM[i].S['licensePlate']),
            SF('W_MakeTime', ArrsM[i].S['makeTime']),
            SF('W_StockNo',  OneJo.S['materielNo']),
            SF('W_StockName',OneJo.S['materielName']),
            SF('W_Value',    OneJo.D['quantity'], sfVal), //�ݶ�
            SF('W_State',    '0')
            ], sTable_YYWebBill, '', True);
          FListA.Add(nStr);

          nStr := 'Select * from %s where W_WebOrderID = ''%s'' ';
          nStr := Format(nStr, [sTable_YYWebBill, ArrsM[i].S['orderNo']]);
          FListD.Add(nStr);
        end;

        Result             := True;
        FOut.FData         := '��ѯԤԼ���ɹ�!';
        FOut.FBase.FResult := True;
      end
      else WriteLog('������Ϣʧ�ܣ�' + ReJo.S['msg']);
    end;

    if (FListD.Count > 0) then
    try
      FDBConn.FConn.BeginTrans;
      //��������
      for nIdx:=0 to FListD.Count - 1 do
      begin
        with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
        begin
          if RecordCount = 0 then
          begin
            gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
          end;
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    ReStream.Free;
    wParam.Free;
    FListD.Free;
  end;
end;

function TBusWorkerBusinessWebchat.GetOrderYYValue(nMID,
  nOID: string): Currency;
var nStr: string;
    nDBConn : PDBWorker;
    nIdx : Integer;
begin
  Result    := 0;

  nDBConn := gDBConnManager.GetConnection(gParamManager.ActiveParam^.FDB.FID, nIdx);
  try
    if not Assigned(nDBConn) then Exit;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;

    nStr := 'select Sum(W_Value) from %s y ' +
            ' Where W_OrderNo=''%s'' and W_State=''0'' ' +
            ' and not exists(Select R_ID from %s w where y.W_WebOrderID=w.WOM_WebOrderID) ';
          //��������� ��Ч
    nStr := Format(nStr,[sTable_YYWebBill,nOID,sTable_WebOrderMatch]);
    WriteLog('��ȡ' + nOID + '���µ���sql:' + nStr);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    begin
      if RecordCount > 0 then
      begin
        Result := Fields[0].AsCurrency;
//        Result := Float2PInt(Fields[0].AsFloat, cPrecision, False) / cPrecision;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

function TBusWorkerBusinessWebchat.IsCanCreateWXOrder(
  var nData: string): Boolean;
var nStr,nCusID,nOType,nSType,nStockNo,nReFlag,nOrderNo: string;
    nNum, nMax: Double;
    nRoot, nheader: TXmlNode;
    nReDs : TDataSet;
begin
  Result := False;
  nReFlag:= sFlag_No; nMax:= 0;
  WriteLog('�ͻ����������Σ�'+nData);

  with FPacker.XMLBuilder do
  begin
    try
      ReadFromString(nData);
      nData  := '�����������ʧ��';

      nheader := Root.FindNode('Head');
      //************************************************************
      try
        nCusID := nheader.NodeByName('ClientNo').ValueAsString;
        nOType := nheader.NodeByName('Type').ValueAsString;
        nStockNo := nheader.NodeByName('StockNo').ValueAsString;
        nSType := nheader.NodeByName('StockType').ValueAsString;
        nNum   := nheader.NodeByName('MakeQuantity').ValueAsFloatDef(-1);
        nOrderNo := nheader.NodeByName('ContractNo').ValueAsString;

        if (nOType='1') then       ///1  ����   2  �ɹ�
        begin
          if (nCusID='')or(nOType='')or(nSType='')or(nOrderNo='')or(nNum<=0) then
          begin
            nData  := '�������ȱʧ';
            Exit;
          end;
          GetOrderCreateStatus(nCusID,nStockNo,nOrderNo,nNum,nMax,nStr,Result);
          nData := nStr;
        end
        else
        begin
          Result := True;
        end;

        if Result then nReFlag:= sFlag_Yes;
      except
        on Ex : Exception do
        begin
          nData  := nData + '������� �������ʧ��!'+Ex.Message;
          WriteLog(nData);
        end;
      end;
    finally
      begin
        BuildDefaultXML;
        with Root.NodeNew('EXMG') do
        begin
          NodeNew('MsgTxt').ValueAsString     := nData;
          NodeNew('MsgResult').ValueAsString  := nReFlag;
          NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
        end;

        nData := FPacker.XMLBuilder.WriteToString;
        WriteLog('�ͻ����������Σ�' + nData);
      end;
    end;
  end;
end;

function TBusWorkerBusinessWebchat.GetOrderCreateStatus(nCID, nMID,
  nOID: string; nValue: Double; var nMax: Double; var ReData: string;
  var nCanCreate: Boolean): Boolean;
var nStr, nTime, nGID, nMName, nStype: string;
    nMoney,nFMoney,nKDMoney, nRemain: Double;
    nIdx : Integer;
    nVefyWebOrder, nCanLade : Boolean;
    nWorker: PDBWorker;
begin
  Result    := False;
  nCanCreate:= True;
  nMoney := 0;
  nFMoney := 0;
  nKDMoney := 0;

  nVefyWebOrder := False;
  
  nStr := ' Select distinct * From ' +
        ' (select xcb.XCB_ID,' +                    //�ڲ����
        '  xcb.XCB_CardId,' +                       //���ۿ�Ƭ���
        '  xcb.XCB_Origin,' +                       //��Ƭ��Դ
        '  xcb.XCB_BillID,' +                       //��Դ���ݺ�
        '  xcb.XCB_SetDate,' +                      //��������
        '  xcb.XCB_CardType,' +                     //��Ƭ����
        '  xcb.XCB_SourceType,' +                   //��Դ����
        '  xcb.XCB_Option,' +                       //���Ʒ�ʽ:0,�ص���;1,������
        '  xcb.XCB_Client,' +                       //�ͻ����
        '  xob.XOB_Name as XCB_ClientName,' +       //�ͻ�����
        '  xgd.XOB_Name as XCB_WorkAddr,' +         //���̹���
        '  xcb.XCB_Alias,' +                        //�ͻ�����
        '  xcb.XCB_OperMan,' +                      //ҵ��Ա
        '  xcb.XCB_Area,' +                         //��������
        '  xcb.XCB_CementType as XCB_Cement,' +     //Ʒ�ֱ��
        '  PCM_Name as XCB_CementName,' +           //Ʒ������
        '  xcb.XCB_LadeType,' +                     //�����ʽ
        '  xcb.XCB_Number,' +                       //��ʼ����
        '  xcb.XCB_FactNum,' +                      //�ѿ�����
        '  xcb.XCB_PreNum,' +                       //ԭ������
        '  xcb.XCB_ReturnNum,' +                    //�˻�����
        '  xcb.XCB_OutNum,' +                       //ת������
        '  vcb.XCB_FactRemain,' +                   //ʣ������
        '  xcb.XCB_ValidS,XCB_ValidE,' +            //�����Ч��
        '  xcb.XCB_AuditState,' +                   //���״̬
        '  xcb.XCB_Status,' +                       //��Ƭ״̬:0,ͣ��;1,����;2,���;3,����
        '  xcb.XCB_IsImputed,' +                    //��Ƭ�Ƿ����
        '  xcb.XCB_IsOnly,' +                       //�Ƿ�һ��һƱ
        '  xcb.XCB_Del,' +                          //ɾ�����:0,����;1,ɾ��
        '  xcb.XCB_Creator,' +                      //������
        '  pub.pub_name as XCB_CreatorNM,' +        //��������
        '  xcb.XCB_CDate,' +                        //����ʱ��
        '  xcb.XCB_Firm,' +                         //��������
        '  pbf.pbf_name as XCB_FirmName,' +         //��������
        '  pcb.pcb_id, pcb.pcb_name, ' +            //����Ƭ��
        '  '''' as XCB_TransID, ' +                 //���䵥λ���
        '  '''' as XCB_TransName ' +                //���䵥λ
     //   '  xcg.xob_id as XCB_TransID, ' +             //���䵥λ���
     //   '  xcg.XOB_Name as XCB_TransName ' +          //���䵥λ
        'from XS_Card_Base xcb' +
        '  left join XS_Compy_Base xob on xob.XOB_ID = xcb.XCB_Client' +
        '  left join XS_Compy_Base xgd on xgd.XOB_ID = xcb.xcb_sublader' +
        '  left join PB_Code_Material pcm on pcm.PCM_ID = xcb.XCB_CementType' +
        '  Left Join pb_code_block pcb On pcb.pcb_id=xob.xob_block' +
        '  Left Join pb_basic_firm pbf On pbf.pbf_id=xcb.xcb_firm' +
        '  Left Join PB_USER_BASE pub on pub.pub_id=xcb.xcb_creator ' +
        '  Left Join v_Card_Base1 vcb on vcb.XCB_ID=xcb.XCB_ID ' +
        '  Left Join XS_Card_Freight xcf on xcf.Xcf_Card=xcb.xcb_ID ' +
     //   '  Left Join XS_Compy_Base xcg on xcg.xob_id=xcf.xcf_tran ' +
        //δɾ����������������0����Ƭ���ò��Ҵ��������״̬��δ����
        ' where  xcb.xcb_del=''0'''
              +' and xcb.XCB_Status=''1'''
              +' and vcb.XCB_FactRemain>0'
              +' and xcb.XCB_IsLock<>''1'''
              +' and ((xcb.XCB_AuditState=''201'') or (xcb.XCB_IsOnly=''1''))'
              +' and xcb.XCB_Client = ''%s'' ' +
        'Order By xcb.XCB_SetDate DESC) t Where XCB_CardId = ''%s'' ';
        //�����,ȡǰ100��
  nStr := Format(nStr,[nCID,nOID]);

  WriteLog(Format('GetOrderList = > [ ������Ϣ.%s ]', [nStr]));
  //��ѯ���

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_YT), FPacker.XMLBuilder do
    begin
      if RecordCount > 0 then
      begin
         nRemain := FieldByName('XCB_FactRemain').AsFloat
                       -  GetOrderYYValue(FieldByName('XCB_Cement').AsString,
                                       FieldByName('XCB_CardId').AsString);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  if nValue > nRemain then
  begin
    nCanCreate := False;
    ReData := '�µ���:' + FloatToStr(nValue) +
               ',�û�������:' + FloatToStr(nRemain) +
               '�޷��µ�';
    Exit;
  end;

  Result:= True;
end;

function TBusWorkerBusinessWebchat.synchronizedYYOrders(
  var nData: string): Boolean;
var nStr,nCusID,nClientName, nOType,nOrderNo,nReFlag: string;
    nStockNo,nStockName,nTruck,nZhiKa,nStatus,nCreateTime:string;
    nNum: Double;
    nRoot, nheader: TXmlNode;
    nReDs : TDataSet;
begin
  Result  := False;
  nReFlag := sFlag_No; 
  WriteLog('�̳Ƕ�����Ϣͬ����Σ�'+nData);

  with FPacker.XMLBuilder do
  begin
    try
      ReadFromString(nData);
      nData  := '�����������ʧ��';

      nheader := Root.FindNode('Head');
      //************************************************************
      try
        nCusID      := nheader.NodeByName('ClientNo').ValueAsString;
        nClientName := nheader.NodeByName('ClientName').ValueAsString;
        nOType      := nheader.NodeByName('Type').ValueAsString;
        nOrderNo    := nheader.NodeByName('OrderNo').ValueAsString;
        nStockNo    := nheader.NodeByName('StockNo').ValueAsString;
        nStockName  := nheader.NodeByName('StockName').ValueAsString;
        nTruck      := nheader.NodeByName('Truck').ValueAsString;
        nZhiKa      := nheader.NodeByName('ZhiKa').ValueAsString;
        nStatus     := nheader.NodeByName('Status').ValueAsString;
        nCreateTime := nheader.NodeByName('CreateTime').ValueAsString;
        nNum        := nheader.NodeByName('Num').ValueAsFloatDef(-1);

        if (nOType='')or(nNum<=0) then
        begin
          nData  := '�������ȱʧ';
          Exit;
        end;

        if (nOType = '1') then   //1����   2�ɹ�
        begin
          if nStatus = '1' then
          begin
            nStr := ' Select W_WebOrderID From %s Where W_WebOrderID=''%s'' ' ;
            nStr := Format(nStr,[sTable_YYWebBill,nOrderNo]);
            with gDBConnManager.WorkerQuery(FDBConn, nStr) do
            begin
              if RecordCount > 0 then
              begin
                nData := '�̳Ƕ���:'+nOrderNo+'�Ѵ���';
              end
              else
              begin
                nStr := ' insert into %s(W_WebOrderID,W_OrderNo,W_CusID,W_Customer,W_Truck,W_MakeTime,W_StockNo,W_StockName,W_State,W_Value) '+
                        ' values(''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',%.2f)';
                nStr := Format(nStr,[sTable_YYWebBill,nOrderNo,nZhiKa,nCusID,nClientName,nTruck,nCreateTime,nStockNo,nStockName,'0',nNum]);
                gDBConnManager.WorkerExec(FDBConn,nStr);

                nReFlag:= sFlag_Yes;
              end;
            end;
          end
          else if nStatus = '6' then
          begin
            {$IFDEF WebOrderAutoLoss}
            nStr := ' Select WOM_WebOrderID From %s Where WOM_WebOrderID=''%s'' ' ;
            nStr := Format(nStr,[sTable_WebOrderMatch,nOrderNo]);
            with gDBConnManager.WorkerQuery(FDBConn, nStr) do
            begin
              if RecordCount > 0 then
              begin
                nData := '�̳Ƕ���:'+nOrderNo+'���ƿ�,����ȡ����';
              end
              else
              begin
                nStr := ' Delete %s  where W_WebOrderID = ''%s'' ';
                nStr := Format(nStr,[sTable_YYWebBill,nOrderNo]);
                gDBConnManager.WorkerExec(FDBConn,nStr);

                nReFlag:= sFlag_Yes;
              end;
            end;
            {$ELSE}
            nStr := ' Select L_WebOrderID From %s Where L_WebOrderID=''%s'' ' ;
            nStr := Format(nStr,[sTable_Bill,nOrderNo]);
            with gDBConnManager.WorkerQuery(FDBConn, nStr) do
            begin
              if RecordCount > 0 then
              begin
                nData := '�̳Ƕ���:'+nOrderNo+'���ƿ�,����ȡ����';
              end
              else
              begin
                nStr := ' Delete %s  where W_WebOrderID = ''%s'' ';
                nStr := Format(nStr,[sTable_YYWebBill,nOrderNo]);
                gDBConnManager.WorkerExec(FDBConn,nStr);

                nReFlag:= sFlag_Yes;
              end;
            end;
            {$ENDIF}
          end;
        end
        else
        begin
          //
        end;
        nData := '�̳Ƕ�����Ϣͬ���ɹ�!';
      except
        on Ex : Exception do
        begin
          nData  := nData + '�̳Ƕ�����Ϣͬ��ʧ��!'+Ex.Message;
          WriteLog(nData);
        end;
      end;
    finally
      begin
        BuildDefaultXML;
        with Root.NodeNew('EXMG') do
        begin
          NodeNew('MsgTxt').ValueAsString     := nData;
          NodeNew('MsgResult').ValueAsString  := nReFlag;
          NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
        end;

        nData := FPacker.XMLBuilder.WriteToString;
        WriteLog('�̳Ƕ�����Ϣͬ�����Σ�' + nData);
      end;
    end;
  end;
end;

function TBusWorkerBusinessWebchat.GetOrderList_JY(
  var nData: string): Boolean;
var nWorker: PDBWorker;
    nTmp,nStr:string;
    nMoney, nValue: Double;
    nNode: TXmlNode;
begin
  Result := False;
  BuildDefaultXML;
  nMoney := 0;
  nTmp := Trim(FIn.FData);
  if nTmp='' then Exit;

  FListA.Clear;
  nStr := ' Select distinct * From ' +
        ' (select xcb.XCB_ID,' +                    //�ڲ����
        '  xcb.XCB_CardId,' +                       //���ۿ�Ƭ���
        '  xcb.XCB_Origin,' +                       //��Ƭ��Դ
        '  xcb.XCB_BillID,' +                       //��Դ���ݺ�
        '  xcb.XCB_SetDate,' +                      //��������
        '  xcb.XCB_CardType,' +                     //��Ƭ����
        '  xcb.XCB_SourceType,' +                   //��Դ����
        '  xcb.XCB_Option,' +                       //���Ʒ�ʽ:0,�ص���;1,������
        '  xcb.XCB_Client,' +                       //�ͻ����
        '  xob.XOB_Name as XCB_ClientName,' +       //�ͻ�����
        '  xgd.XOB_Name as XCB_WorkAddr,' +         //���̹���
        '  xcb.XCB_Alias,' +                        //�ͻ�����
        '  xcb.XCB_OperMan,' +                      //ҵ��Ա
        '  xcb.XCB_Area,' +                         //��������
        '  xcb.XCB_CementType as XCB_Cement,' +     //Ʒ�ֱ��
        '  PCM_Name as XCB_CementName,' +           //Ʒ������
        '  xcb.XCB_LadeType,' +                     //�����ʽ
        '  xcb.XCB_Number,' +                       //��ʼ����
        '  xcb.XCB_FactNum,' +                      //�ѿ�����
        '  xcb.XCB_PreNum,' +                       //ԭ������
        '  xcb.XCB_ReturnNum,' +                    //�˻�����
        '  xcb.XCB_OutNum,' +                       //ת������
        '  vcb.XCB_FactRemain,' +                   //ʣ������
        '  xcb.XCB_ValidS,XCB_ValidE,' +            //�����Ч��
        '  xcb.XCB_AuditState,' +                   //���״̬
        '  xcb.XCB_Status,' +                       //��Ƭ״̬:0,ͣ��;1,����;2,���;3,����
        '  xcb.XCB_IsImputed,' +                    //��Ƭ�Ƿ����
        '  xcb.XCB_IsOnly,' +                       //�Ƿ�һ��һƱ
        '  xcb.XCB_Del,' +                          //ɾ�����:0,����;1,ɾ��
        '  xcb.XCB_Creator,' +                      //������
        '  pub.pub_name as XCB_CreatorNM,' +        //��������
        '  xcb.XCB_CDate,' +                        //����ʱ��
        '  xcb.XCB_Firm,' +                         //��������
        '  pbf.pbf_name as XCB_FirmName,' +         //��������
        '  pcb.pcb_id, pcb.pcb_name, ' +            //����Ƭ��
        '  '''' as XCB_TransID, ' +                 //���䵥λ���
        '  '''' as XCB_TransName ' +                //���䵥λ
     //   '  xcg.xob_id as XCB_TransID, ' +             //���䵥λ���
     //   '  xcg.XOB_Name as XCB_TransName ' +          //���䵥λ
        'from XS_Card_Base xcb' +
        '  left join XS_Compy_Base xob on xob.XOB_ID = xcb.XCB_Client' +
        '  left join XS_Compy_Base xgd on xgd.XOB_ID = xcb.xcb_sublader' +
        '  left join PB_Code_Material pcm on pcm.PCM_ID = xcb.XCB_CementType' +
        '  Left Join pb_code_block pcb On pcb.pcb_id=xob.xob_block' +
        '  Left Join pb_basic_firm pbf On pbf.pbf_id=xcb.xcb_firm' +
        '  Left Join PB_USER_BASE pub on pub.pub_id=xcb.xcb_creator ' +
        '  Left Join v_Card_Base1 vcb on vcb.XCB_ID=xcb.XCB_ID ' +
        '  Left Join XS_Card_Freight xcf on xcf.Xcf_Card=xcb.xcb_ID ' +
     //   '  Left Join XS_Compy_Base xcg on xcg.xob_id=xcf.xcf_tran ' +
        //δɾ����������������0����Ƭ���ò��Ҵ��������״̬��δ����
        ' where  xcb.xcb_del=''0'''
              +' and xcb.XCB_Status=''1'''
              +' and vcb.XCB_FactRemain>0'
              +' and xcb.XCB_IsLock<>''1'''
              +' and ((xcb.XCB_AuditState=''201'') or (xcb.XCB_IsOnly=''1''))'
              +' and xcb.XCB_Client = ''%s'' ' +
        'Order By xcb.XCB_SetDate DESC) t Where Rownum <= 100';
        //�����,ȡǰ100��
  nStr := Format(nStr,[nTmp]);

  WriteLog(Format('GetOrderList = > [ ������Ϣ.%s ]', [nStr]));
  //��ѯ���

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_YT), FPacker.XMLBuilder do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('δ��ѯ���ͻ����[ %s ]��Ӧ�Ķ�����Ϣ1.', [nTmp]);
        with Root.NodeNew('EXMG') do
        begin
          NodeNew('MsgTxt').ValueAsString := nData;
          NodeNew('MsgResult').ValueAsString := sFlag_No;
          NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
        end;
        nData := FPacker.XMLBuilder.WriteToString;
        Exit;
      end;

      First;
      nNode := Root.NodeNew('head');
      with nNode do
      begin
        NodeNew('CusId').ValueAsString   := FieldByName('XCB_Client').AsString;
        NodeNew('CusName').ValueAsString := FieldByName('XCB_ClientName').AsString;
      end;

      nNode := Root.NodeNew('Items');
      while not Eof do
      try
        with nNode.NodeNew('Item') do
        begin
          NodeNew('SetDate').ValueAsString := FieldByName('XCB_SetDate').AsString;
          NodeNew('BillNumber').ValueAsString := FieldByName('XCB_CardId').AsString;
          NodeNew('StockNo').ValueAsString := FieldByName('XCB_Cement').AsString;
          if Trim(FieldByName('XCB_CementName').AsString) = '' then
            NodeNew('StockName').ValueAsString := FieldByName('XCB_Cement').AsString
          else
            NodeNew('StockName').ValueAsString := FieldByName('XCB_CementName').AsString;

          if Pos('��',FieldByName('XCB_CementName').AsString) > 0 then
            NodeNew('StockType').ValueAsString := 'D'
          else
            NodeNew('StockType').ValueAsString := 'S';

          //Ĭ������
          NodeNew('ContractType').ValueAsString := '1';

          NodeNew('BillName').ValueAsString     := FieldByName('XCB_CardId').AsString;
          {$IFDEF UseWebYYOrder}
            nValue := FieldByName('XCB_FactRemain').AsFloat
                     -  GetOrderYYValue(FieldByName('XCB_Cement').AsString,
                                     FieldByName('XCB_CardId').AsString);
                                     
            NodeNew('MaxNumber').ValueAsString    := FloatToStr(nValue);
          {$ELSE}
            nValue := FieldByName('XCB_FactRemain').AsFloat;
            NodeNew('MaxNumber').ValueAsString    := FloatToStr(nValue);
          {$ENDIF}
          NodeNew('SaleArea').ValueAsString     := FieldByName('XCB_WorkAddr').AsString;       
        end;
      finally
        Next;
      end;
      nNode := Root.NodeNew('EXMG');
      with nNode do
      begin
        NodeNew('MsgTxt').ValueAsString := 'ҵ��ִ�гɹ�';
        NodeNew('MsgResult').ValueAsString := sFlag_Yes;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('��ȡ�����б���:' + nData);
  Result := True;
end;

function TBusWorkerBusinessWebchat.get_LineInfobyTruck(
  var nData: string): Boolean;
var
  nRank : Integer;
  nStr, nTruckNumber, nStockNo, nStockName, nLine, nInTime : string;
  nNode,  nheader  : TXmlNode;
begin
  Result := False;

  with FPacker.XMLBuilder do
  begin
    try
      ReadFromString(nData);
      nData  := '�����������ʧ��';

      nheader := Root.FindNode('Head');
      //************************************************************
      try
        nTruckNumber := nheader.NodeByName('Data').ValueAsString;

        if nTruckNumber <> '' then
        begin
          nStr := ' Select * From %s Where L_Status <> ''O'' And L_Truck=''%s'' ';
          nStr := Format(nStr, [sTable_Bill, nTruckNumber]);
          //*****
          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
          begin
            if RecordCount < 1 then
            begin
              nData := '�Ҳ����˳��ƺŵ���Ч����.';
              with Root.NodeNew('EXMG') do
              begin
                NodeNew('MsgTxt').ValueAsString     := nData;
                NodeNew('MsgResult').ValueAsString  := sFlag_No;
                NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
              end;
              nData := FPacker.XMLBuilder.WriteToString;
              Exit;
            end;
            nStockNo   := FieldByName('L_StockNo').AsString;
            nStockName := FieldByName('L_StockName').AsString;
          end;
          
        end;
      except
        on Ex : Exception do
        begin
          nData  := nData + '��ѯ�����Ŷ�ͨ����Ϣʧ��!'+Ex.Message;
          WriteLog(nData);
        end;
      end;
    finally
      //
    end;
  end;

  BuildDefaultXML;
  nStr := ' Select T_Line, T_InTime From %s Where T_Valid = ''%s'' And T_Truck = ''%s''  ';
  nStr := Format(nStr, [sTable_ZTTrucks, sFlag_Yes, nTruckNumber]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr), FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nData := '����(%s)û�н�������Ϣ.';
      nData := Format(nData, [nStockNo]);
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;
      Exit;
    end;
    nLine   := FieldByName('T_Line').AsString;
    nInTime := FormatDateTime('YYYY-MM-DD HH:MM:SS',FieldByName('T_InTime').AsDateTime);
  end;

  nRank:= 0;
  nStr := ' Select * From %s Where T_Valid = ''%s'' And T_Line = ''%s'' and T_InTime < ''%s''  Order by T_InTime ';
  nStr := Format(nStr, [sTable_ZTTrucks, sFlag_Yes, nLine,nInTime]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr), FPacker.XMLBuilder do
  begin
    nNode := Root.NodeNew('Items');
    if RecordCount < 1 then
    begin
      nRank := nRank + 1;
      with nNode.NodeNew('Item') do
      begin
        NodeNew('LineName').ValueAsString  := nLine;
        NodeNew('StockNo').ValueAsString   := nStockNo;
        NodeNew('StockName').ValueAsString := nStockName;
        NodeNew('Rank').ValueAsString      := IntToStr(nRank);
        NodeNew('TruckNo').ValueAsString   := nTruckNumber;
      end;
    end
    else
    begin
      First;
      while not Eof do
      begin
        nRank := nRank + 1;
        with nNode.NodeNew('Item') do
        begin
          NodeNew('LineName').ValueAsString  := FieldByName('T_Line').AsString;
          NodeNew('StockNo').ValueAsString   := FieldByName('T_StockNo').AsString;
          NodeNew('StockName').ValueAsString := FieldByName('T_Stock').AsString;
          NodeNew('Rank').ValueAsString      := IntToStr(nRank);
          NodeNew('TruckNo').ValueAsString   := FieldByName('T_Truck').AsString;
        end;
        nExt;
      end;

      nRank := nRank + 1;
      with nNode.NodeNew('Item') do
      begin
        NodeNew('LineName').ValueAsString  := nLine;
        NodeNew('StockNo').ValueAsString   := nStockNo;
        NodeNew('StockName').ValueAsString := nStockName;
        NodeNew('Rank').ValueAsString      := IntToStr(nRank);
        NodeNew('TruckNo').ValueAsString   := nTruckNumber;
      end;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  
  nData  := FPacker.XMLBuilder.WriteToString;
  Result := True;
end;

function TBusWorkerBusinessWebchat.TruckQueuedInfo(
  var nData: string): boolean;
var
  nStr, nSql, ncontractNo: string;
  nDBConn: PDBWorker;
  nIdx: Integer;
  szUrl: string;
  ReJo, ParamJo, BodyJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream: TStringStream;
begin
  Result      := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');
  BodyJo   := SO();
  ParamJo  := SO();

  FListA.Text := PackerDecodeStr(FIn.FData);
  try
    if FListA.Values['queueNo'] = '1' then
    begin
      BodyJo.S['first']           := EncodeBase64('�Ŷӵ�һ������');
      BodyJo.S['queueNo']         := '1';
      BodyJo.S['queuingNumber']   := '0';
      BodyJo.S['time']            := EncodeBase64(DateTime2Str(Now));
      BodyJo.S['remark']          := EncodeBase64('���ĳ������Ŷ��ڵ�һλ���뾡����������');
      BodyJo.S['facSerialNo']     := gSysParam.FFactID;
      BodyJo.S['msgEventKey']     := '12';
      BodyJo.S['truckNumber']     := EncodeBase64(FListA.Values['Truck']);
      ParamJo.S['activeCode']     := Cus_TruckQueuedInfo;
      ParamJo.S['body']           := BodyJo.AsString;
      nStr                        := ParamJo.AsString;
    end
    else
    begin
      BodyJo.S['first']           := EncodeBase64('��'+FListA.Values['Truck']+'���Ŷӵ�����֪ͨ��');
      BodyJo.S['queueNo']         := '3';
      BodyJo.S['queuingNumber']   := '2';
      BodyJo.S['time']            := EncodeBase64(DateTime2Str(Now));
      BodyJo.S['remark']          := EncodeBase64('����ǰ�Ŷӵ������������ݳ����ڳ��������������ʱ�䡣');
      BodyJo.S['facSerialNo']     := gSysParam.FFactID;
      BodyJo.S['msgEventKey']     := '12';
      BodyJo.S['truckNumber']     := EncodeBase64(FListA.Values['Truck']);
      ParamJo.S['activeCode']     := Cus_TruckQueuedInfo;
      ParamJo.S['body']           := BodyJo.AsString;
      nStr                        := ParamJo.AsString;
    end;
    WriteLog(' �Ŷ�֪ͨ��Σ�' + nStr);

    //nStr := UTF8Encode(nStr);
    wParam.Clear;
    wParam.Add(nStr);
    
    //FidHttp������ʼ��
    ReQuestInit;

    szUrl := gSysParam.FSrvUrl + '/truck/pushVehicleQueueNotification';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog(' �Ŷ�֪ͨ���Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo := SO(nStr);

      if ReJo['code'].AsString = '1' then
      begin
        Result             := True;
        FOut.FData         := sFlag_Yes;
        FOut.FBase.FResult := True;
      end
      else WriteLog(' �Ŷ�֪ͨʧ�ܣ�' + ReJo['msg'].AsString);
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessWebchat.GetOrderList_JM(
  var nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
  nCardData,nCardItem:TStringList;
  nType: string;
  i:Integer;
  nRequest,nResponse:string;
  nDSType: string;
  nNode: TXmlNode;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
              @nOut, cBC_GetOrderList, Trim(FIn.FRemoteUL));
  WriteLog('TBusWorkerBusinessWebchat.GetOrderList: ' + Trim(FIn.FRemoteUL));
  nRequest := nData;

//  WriteLog(Format('Out => [%s]', [nOut.FData]));
  nCardData := TStringList.Create;
  nCardItem := TStringList.Create;
  try
    if Result then
    begin
      nCardData.Text := PackerDecodeStr(nOut.FData);
      WriteLog(Format('nCardData => [count.%d]', [nCardData.Count]));
      nCardItem.Text := PackerDecodeStr(nCardData.Strings[0]);
      with FPacker.XMLBuilder do
      begin
        nNode := Root.NodeNew('head');
        with nNode do
        begin
          NodeNew('CusId').ValueAsString   :=  nCardItem.Values['XCB_Client'];
          NodeNew('CusName').ValueAsString :=  nCardItem.Values['XCB_ClientName'];
        end;

        nNode := Root.NodeNew('Items');
        for i := 0 to nCardData.Count-1 do
        begin
          nCardItem.Text := PackerDecodeStr(nCardData.Strings[i]);
          WriteLog(Format('nCardData[%d] => [%s]', [i, nCardItem.Text]));
          with nNode.NodeNew('Item') do
          begin
            if Pos('��', nCardItem.Values['XCB_CementName']) > 0 then
            begin
              nType := '��װ';
              nDSType := 'D';
            end
            else begin
              nType := 'ɢװ';
              nDSType := 'S';
            end;
            NodeNew('SetDate').ValueAsString    := FormatDateTime('YYYY-MM-DD HH:MM:SS',StrToDate(nCardItem.Values['XCB_SetDate']));
            NodeNew('BillNumber').ValueAsString :=  nCardItem.Values['XCB_CardId'];
            NodeNew('StockNo').ValueAsString    := nCardItem.Values['XCB_Cement'];
            if nCardItem.Values['XCB_CementName'] = '' then
              NodeNew('StockName').ValueAsString := nCardItem.Values['XCB_Cement'] //+ nType
            else
              NodeNew('StockName').ValueAsString := nCardItem.Values['XCB_CementName'];//+ nType

            NodeNew('StockType').ValueAsString := nDSType;


            //Ĭ������
            NodeNew('ContractType').ValueAsString := '1';

            NodeNew('BillName').ValueAsString     := nCardItem.Values['XCB_CardId'];
            NodeNew('MaxNumber').ValueAsString    := nCardItem.Values['XCB_RemainNum'];
            NodeNew('SaleArea').ValueAsString     := nCardItem.Values['XCB_WorkAddr'];
            NodeNew('TransName').ValueAsString    := nCardItem.Values['XCB_TransName'];
          end;
        end;
        nNode := Root.NodeNew('EXMG');
        with nNode do
        begin
          NodeNew('MsgTxt').ValueAsString := 'ҵ��ִ�гɹ�';
          NodeNew('MsgResult').ValueAsString := sFlag_Yes;
          NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
        end;
      end;
    end;
  finally
    nCardItem.Free;
    nCardData.Free;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('��ȡ�����б���:' + nData);
  Result := True;
end;

function TBusWorkerBusinessWebchat.GetOrderList_ZX(
  var nData: string): Boolean;
var nWorker: PDBWorker;
    nTmp,nStr:string;
    nMoney, nValue: Double;

    nOut: TWorkerBusinessCommand;
    nCardData,nCardItem:TStringList;
    nType: string;
    i:Integer;
    nRequest,nResponse:string;
    nDSType: string;
    nNode: TXmlNode;
begin
  Result := False;
//  BuildDefaultXML;
  nMoney := 0;
  nTmp := Trim(FIn.FData);
  if nTmp='' then Exit;

  nCardData := TStringList.Create;
  nCardItem := TStringList.Create;
  nCardData.Clear;
  FListB.Clear;
  {$IFDEF GLlade}
//  nMoney := GetCustomerValidMoneyEx(FIn.FData);

  nStr := 'select D_ZID,' +                     //���ۿ�Ƭ���
        '  D_Type,' +                           //����(��,ɢ)
        '  D_StockNo,' +                        //ˮ����
        '  D_StockName,' +                      //ˮ������
        '  D_Price,' +                          //����
        '  D_Value,' +                          //������
        '  Z_Man,' +                            //������
        '  Z_Date,' +                           //��������
        '  Z_Customer,' +                       //�ͻ����
        '  Z_Name,' +                           //�ͻ�����
        '  Z_Lading,' +                         //�����ʽ
        '  Z_CID, ' +                            //��ͬ���
        '  Z_FixedMoney ' +                     //������
        'from %s a join %s b on a.Z_ID = b.D_ZID ' +
        'where Z_Verified=''%s'' and (Z_InValid<>''%s'' or Z_InValid is null) '+
        'and Z_Customer=''%s''';
        //��������� ��Ч
  nStr := Format(nStr,[sTable_ZhiKa,sTable_ZhiKaDtl,sFlag_Yes,sFlag_Yes,
                       nTmp]);
  WriteLog('��ȡ���ض����б�sql:'+nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        FListB.Values['XCB_CardId']     := FieldByName('D_ZID').AsString;
        FListB.Values['XCB_SetDate']    := FormatDateTime('YYYY-MM-DD HH:MM:SS',FieldByName('Z_Date').AsDateTime);
        FListB.Values['XCB_Client']     := FieldByName('Z_Customer').AsString;
        FListB.Values['XCB_ClientName'] := GetCusName(FieldByName('Z_Customer').AsString);
        FListB.Values['XCB_WorkAddr']   := '';
        FListB.Values['XCB_TransName']  := '';

        if FieldByName('Z_FixedMoney').AsFloat > 0 then
        begin
          nMoney := FieldByName('Z_FixedMoney').AsFloat;

          try
            nValue := nMoney / FieldByName('D_Price').AsFloat;
            nValue := Float2PInt(nValue, cPrecision, False) / cPrecision;
          except
            nValue := 0;
          end;

          FListB.Values['XCB_RemainNum']  := FloatToStr(nValue);
          FListB.Values['XCB_Cement']     := FieldByName('D_StockNo').AsString;
          FListB.Values['XCB_CementName'] := FieldByName('D_StockName').AsString;

          nCardData.Add(FListB.Text);
        end;

        Next;
      end;
    end;
  end;
  {$ENDIF}

  nStr := 'Select * From ' +
        '(select xcb.XCB_ID,' +                      //�ڲ����
        '  xcb.XCB_CardId,' +                       //���ۿ�Ƭ���
        '  xcb.XCB_Origin,' +                       //��Ƭ��Դ
        '  xcb.XCB_BillID,' +                       //��Դ���ݺ�
        '  xcb.XCB_SetDate,' +                      //��������
        '  xcb.XCB_CardType,' +                     //��Ƭ����
        '  xcb.XCB_SourceType,' +                   //��Դ����
        '  xcb.XCB_Option,' +                       //���Ʒ�ʽ:0,�ص���;1,������
        '  xcb.XCB_Client,' +                       //�ͻ����
        '  xob.XOB_Name as XCB_ClientName,' +       //�ͻ�����
        '  xgd.XOB_Name as XCB_WorkAddr,' +         //���̹���
        '  xcb.XCB_Alias,' +                        //�ͻ�����
        '  xcb.XCB_OperMan,' +                      //ҵ��Ա
        '  xcb.XCB_Area,' +                         //��������
        '  xcb.XCB_CementType as XCB_Cement,' +     //Ʒ�ֱ��
        '  PCM_Name as XCB_CementName,' +           //Ʒ������
        '  xcb.XCB_LadeType,' +                     //�����ʽ
        '  xcb.XCB_Number,' +                       //��ʼ����
        '  xcb.XCB_FactNum,' +                      //�ѿ�����
        '  xcb.XCB_PreNum,' +                       //ԭ������
        '  xcb.XCB_ReturnNum,' +                    //�˻�����
        '  xcb.XCB_OutNum,' +                       //ת������
        '  vcb.XCB_FactRemain,' +                   //ʣ������
        '  xcb.XCB_ValidS,XCB_ValidE,' +            //�����Ч��
        '  xcb.XCB_AuditState,' +                   //���״̬
        '  xcb.XCB_Status,' +                       //��Ƭ״̬:0,ͣ��;1,����;2,���;3,����
        '  xcb.XCB_IsImputed,' +                    //��Ƭ�Ƿ����
        '  xcb.XCB_IsOnly,' +                       //�Ƿ�һ��һƱ
        '  xcb.XCB_Del,' +                          //ɾ�����:0,����;1,ɾ��
        '  xcb.XCB_Creator,' +                      //������
        '  pub.pub_name as XCB_CreatorNM,' +        //��������
        '  xcb.XCB_CDate,' +                        //����ʱ��
        '  xcb.XCB_Firm,' +                         //��������
        '  pbf.pbf_name as XCB_FirmName,' +         //��������
        '  pcb.pcb_id, pcb.pcb_name, ' +            //����Ƭ��
        //'  '''' as XCB_TransID, ' +                 //���䵥λ���
        //'  '''' as XCB_TransName ' +                //���䵥λ
        '  xcg.xob_id as XCB_TransID, ' +             //���䵥λ���
        '  xcg.XOB_Name as XCB_TransName ' +          //���䵥λ
        'from XS_Card_Base xcb' +
        '  left join XS_Compy_Base xob on xob.XOB_ID = xcb.XCB_Client' +
        '  left join XS_Compy_Base xgd on xgd.XOB_ID = xcb.xcb_sublader' +
        '  left join PB_Code_Material pcm on pcm.PCM_ID = xcb.XCB_CementType' +
        '  Left Join pb_code_block pcb On pcb.pcb_id=xob.xob_block' +
        '  Left Join pb_basic_firm pbf On pbf.pbf_id=xcb.xcb_firm' +
        '  Left Join PB_USER_BASE pub on pub.pub_id=xcb.xcb_creator ' +
        '  Left Join v_Card_Base1 vcb on vcb.XCB_ID=xcb.XCB_ID ' +
        '  Left Join XS_Card_Freight xcf on xcf.Xcf_Card=xcb.xcb_ID ' +
        '  Left Join XS_Compy_Base xcg on xcg.xob_id=xcf.xcf_tran ' +
        //δɾ����������������0����Ƭ���ò��Ҵ��������״̬��δ����
        ' where  xcb.xcb_del=''0'''
              +' and xcb.XCB_Status=''1'''
              +' and vcb.XCB_FactRemain>0'
              +' and xcb.XCB_IsLock<>''1'''
              +' and ((xcb.XCB_AuditState=''201'') or (xcb.XCB_IsOnly=''1''))'
              +' and xcb.XCB_Client = ''%s'' ' +
        'Order By xcb.XCB_SetDate DESC) t Where Rownum <= 100';
        //�����,ȡǰ100��
  nStr := Format(nStr,[nTmp]);

  WriteLog(Format('GetOrderList = > [ ������Ϣ.%s ]', [nStr]));
  //��ѯ���

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_YT) do
    begin
      {$IFDEF GLlade}
      if (RecordCount < 1) and (FListA.Count < 1) then
      begin
        nData := Format('δ��ѯ���ͻ����[ %s ]��Ӧ�Ķ�����Ϣ1.', [nTmp]);
        Exit;
      end;
      {$ELSE}
      if RecordCount < 1 then
      begin
        nData := Format('δ��ѯ���ͻ����[ %s ]��Ӧ�Ķ�����Ϣ1.', [nTmp]);
        Exit;
      end;
      {$ENDIF}

      //FListA.Clear;
      FListB.Clear;
      First;

      while not Eof do
      try
        FListB.Values['XCB_ID']         := FieldByName('XCB_ID').AsString;
        FListB.Values['XCB_CardId']     := FieldByName('XCB_CardId').AsString;
        FListB.Values['XCB_Origin']     := FieldByName('XCB_Origin').AsString;
        FListB.Values['XCB_BillID']     := FieldByName('XCB_BillID').AsString;
        FListB.Values['XCB_SetDate']    := FormatDateTime('YYYY-MM-DD HH:MM:SS',FieldByName('XCB_SetDate').AsDateTime);
        FListB.Values['XCB_CardType']   := FieldByName('XCB_CardType').AsString;
        FListB.Values['XCB_SourceType'] := FieldByName('XCB_SourceType').AsString;
        FListB.Values['XCB_Option']     := FieldByName('XCB_Option').AsString;
        FListB.Values['XCB_Client']     := FieldByName('XCB_Client').AsString;
        FListB.Values['XCB_ClientName'] := FieldByName('XCB_ClientName').AsString;
        FListB.Values['XCB_WorkAddr']   := FieldByName('XCB_WorkAddr').AsString;
        FListB.Values['XCB_Alias']      := FieldByName('XCB_Alias').AsString;
        FListB.Values['XCB_OperMan']    := FieldByName('XCB_OperMan').AsString;
        FListB.Values['XCB_Area']       := FieldByName('XCB_Area').AsString;
        FListB.Values['XCB_Cement']     := FieldByName('XCB_Cement').AsString;
        FListB.Values['XCB_CementName'] := FieldByName('XCB_CementName').AsString;
        FListB.Values['XCB_LadeType']   := FieldByName('XCB_LadeType').AsString;
        FListB.Values['XCB_Number']     := FloatToStr(FieldByName('XCB_Number').AsFloat);
        FListB.Values['XCB_FactNum']    := FloatToStr(FieldByName('XCB_FactNum').AsFloat);
        FListB.Values['XCB_PreNum']     := FloatToStr(FieldByName('XCB_PreNum').AsFloat);
        FListB.Values['XCB_ReturnNum']  := FloatToStr(FieldByName('XCB_ReturnNum').AsFloat);
        FListB.Values['XCB_OutNum']     := FloatToStr(FieldByName('XCB_OutNum').AsFloat);
        FListB.Values['XCB_RemainNum']  := FloatToStr(FieldByName('XCB_FactRemain').AsFloat);
        FListB.Values['XCB_AuditState'] := FieldByName('XCB_AuditState').AsString;
        FListB.Values['XCB_Status']     := FieldByName('XCB_Status').AsString;
        FListB.Values['XCB_IsOnly']     := FieldByName('XCB_IsOnly').AsString;
        FListB.Values['XCB_Del']        := FieldByName('XCB_Del').AsString;
        FListB.Values['XCB_Creator']    := FieldByName('XCB_Creator').AsString;
        FListB.Values['XCB_CreatorNM']  := FieldByName('XCB_CreatorNM').AsString;
        FListB.Values['XCB_CDate']      := DateTime2Str(FieldByName('XCB_CDate').AsDateTime);
        FListB.Values['XCB_Firm']       := FieldByName('XCB_Firm').AsString;
        FListB.Values['XCB_FirmName']   := FieldByName('XCB_FirmName').AsString;
        FListB.Values['pcb_id']         := FieldByName('pcb_id').AsString;
        FListB.Values['pcb_name']       := FieldByName('pcb_name').AsString;
        FListB.Values['XCB_TransID']    := FieldByName('XCB_TransID').AsString;
        FListB.Values['XCB_TransName']  := FieldByName('XCB_TransName').AsString;

        nCardData.Add(FListB.Text);
      finally
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  if nCardData.Count < 1 then
  begin
    nData := Format('δ��ѯ���ͻ����[ %s ]��Ӧ�Ķ�����Ϣ2.', [FIn.FData]);
    Exit;
  end;

  try
    nCardItem.Text := nCardData.Strings[0];
    with FPacker.XMLBuilder do
    begin
      nNode := Root.NodeNew('head');
      with nNode do
      begin
        NodeNew('CusId').ValueAsString   :=  nCardItem.Values['XCB_Client'];
        NodeNew('CusName').ValueAsString :=  nCardItem.Values['XCB_ClientName'];
      end;

      nNode := Root.NodeNew('Items');
      for i := 0 to nCardData.Count-1 do
      begin
        nCardItem.Text := nCardData.Strings[i];
        WriteLog(Format('nCardData[%d] => [%s]', [i, nCardItem.Text]));
        with nNode.NodeNew('Item') do
        begin
          if Pos('��', nCardItem.Values['XCB_CementName']) > 0 then
          begin
            nType := '��װ';
            nDSType := 'D';
          end
          else begin
            nType := 'ɢװ';
            nDSType := 'S';
          end;
          NodeNew('SetDate').ValueAsString    :=  nCardItem.Values['XCB_SetDate'];
          NodeNew('BillNumber').ValueAsString :=  nCardItem.Values['XCB_CardId'];
          NodeNew('StockNo').ValueAsString    := nCardItem.Values['XCB_Cement'];
          if nCardItem.Values['XCB_CementName'] = '' then
            NodeNew('StockName').ValueAsString := nCardItem.Values['XCB_Cement'] //+ nType
          else
            NodeNew('StockName').ValueAsString := nCardItem.Values['XCB_CementName'];//+ nType

          NodeNew('StockType').ValueAsString := nDSType;


          //Ĭ������
          NodeNew('ContractType').ValueAsString := '1';

          NodeNew('BillName').ValueAsString     := nCardItem.Values['XCB_CardId'];
          NodeNew('MaxNumber').ValueAsString    := nCardItem.Values['XCB_RemainNum'];
          NodeNew('SaleArea').ValueAsString     := nCardItem.Values['XCB_WorkAddr'];
          NodeNew('TransName').ValueAsString    := nCardItem.Values['XCB_TransName'];
        end;
      end;
      nNode := Root.NodeNew('EXMG');
      with nNode do
      begin
        NodeNew('MsgTxt').ValueAsString := 'ҵ��ִ�гɹ�';
        NodeNew('MsgResult').ValueAsString := sFlag_Yes;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  finally
    nCardItem.Free;
    nCardData.Free;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('��ȡ�����б���:' + nData);
  Result := True;
end;

function TBusWorkerBusinessWebchat.GetCustomerValidMoneyEx(
  nCustomer: string): Double;
var nStr: string;
    nUseCredit: Boolean;
    nVal,nCredit: Double;
begin
  Result := 0 ;
  nUseCredit := False;

  nStr := 'Select MAX(C_End) From %s ' +
          'Where C_CusID=''%s'' and C_Money>=0 and C_Verify=''%s''';
  nStr := Format(nStr, [sTable_CusCredit, nCustomer, sFlag_Yes]);
  WriteLog('����SQL:'+nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    nUseCredit := (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
                  (Fields[0].AsDateTime > Now());
  //����δ����

  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, nCustomer]);
  WriteLog('�û��˻�SQL:'+nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      Exit;
    end;

    nVal := FieldByName('A_InitMoney').AsFloat + FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat;
    //xxxxx
    WriteLog('�û��˻����:'+FloatToStr(nVal));
    nCredit := FieldByName('A_CreditLimit').AsFloat;
    nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;
    WriteLog('�û��˻�����:'+FloatToStr(nCredit));
    if nUseCredit then
      nVal := nVal + nCredit;
    WriteLog('�û��˻����ý�:'+FloatToStr(nVal));
    Result := Float2PInt(nVal, cPrecision, False) / cPrecision;
  end;
end;

function TBusWorkerBusinessWebchat.getQuerySaleDtl(
  var nData: string): Boolean;
var
  nStr, nClientNo, nStockNo, nType, nSearch : string;
  nStart, nEnd, nSumStr : string;
  nNode,  nheader  : TXmlNode;

  function GetLeftStr(SubStr, Str: string): string;
  begin
    Result := Copy(Str, 1, Pos(SubStr, Str) - 1);
  end;
  function GetRightStr(SubStr, Str: string): string;
  var
     i: integer;
  begin
     i := pos(SubStr, Str);
     if i > 0 then
       Result := Copy(Str
         , i + Length(SubStr)
         , Length(Str) - i - Length(SubStr) + 1)
     else
       Result := '';
  end;
begin
  Result := False;

  with FPacker.XMLBuilder do
  begin
    try
      ReadFromString(nData);
      nData  := '�����������ʧ��';

      nheader := Root.FindNode('Head');
      //************************************************************
      try
        nClientNo := nheader.NodeByName('Data').ValueAsString;
        nType     := nheader.NodeByName('Type').ValueAsString;
        nSumStr   := nheader.NodeByName('ExtParam').ValueAsString;
        nSearch   := nheader.NodeByName('Search').ValueAsString;

        nStart    := GetLeftStr(';', nSumStr);
        nEnd      := GetRightStr(';',nSumStr);

        if (nClientNo = '') or (nType = '') then
        begin
          nData := '�����������ʧ��.';
          with Root.NodeNew('EXMG') do
          begin
            NodeNew('MsgTxt').ValueAsString     := nData;
            NodeNew('MsgResult').ValueAsString  := sFlag_No;
            NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
          end;
          nData := FPacker.XMLBuilder.WriteToString;
          Exit;
        end;
      except
        on Ex : Exception do
        begin
          nData  := nData + '��ѯ������Ϣʧ��!'+Ex.Message;
          WriteLog(nData);
        end;
      end;
   finally
   end;
  end;

  BuildDefaultXML;
  if nType = '1' then
  begin
    if Trim(nSearch) = '' then
    begin
      nStr := ' Select L_ID, L_ZhiKa, L_CusName, L_Truck, L_Value, L_MValue, L_PValue,'+
              ' L_Price, (L_Value * L_Price) as L_Money,L_OutFact,L_HYDan, L_StockNo,'+
              ' L_StockName, COUNT(*) as nCount from %s a, %s b '+
              ' where a.L_CusName = b.C_Name and b.C_ID = ''%s'' and L_OutFact >= ''%s'' and L_OutFact <= ''%s'' ' +
              ' Group by L_ID, L_ZhiKa, L_CusName, L_Truck, L_Value, L_MValue, L_PValue,'+
              ' L_Price, L_OutFact,L_HYDan, L_StockNo, L_StockName ' ;
      nStr := Format(nStr, [sTable_Bill,sTable_Customer, nClientNo,nStart,nEnd]);
    end
    else
    begin
      nStr := ' Select L_ID, L_ZhiKa, L_CusName, L_Truck, L_Value, L_MValue, L_PValue,'+
              ' L_Price, (L_Value * L_Price) as L_Money,L_OutFact,L_HYDan, L_StockNo,'+
              ' L_StockName, COUNT(*) as nCount from %s a, %s b '+
              ' where a.L_CusName = b.C_Name and b.C_ID = ''%s'' and ((L_Truck like ''%%%s%%'') or (L_StockName like ''%%%s%%'') ) '+
              ' and L_OutFact >= ''%s'' and L_OutFact <= ''%s'' ' +
              ' Group by L_ID, L_ZhiKa, L_CusName, L_Truck, L_Value, L_MValue, L_PValue,'+
              ' L_Price, L_OutFact,L_HYDan, L_StockNo, L_StockName ' ;
      nStr := Format(nStr, [sTable_Bill,sTable_Customer, nClientNo,nSearch,nSearch,nStart,nEnd]);
    end;
  end
  else
  begin
    nStr := ' Select b.D_ID as L_ID,a.O_BID as L_ZhiKa,O_ProName as L_CusName,O_Truck as L_Truck,'+
            ' D_Value as L_Value, D_MValue as L_MValue,D_PValue as L_PValue, 0 as L_Price, 0 as L_Money,'+
            ' D_OutFact as L_OutFact, '''' as L_HYDan, a.O_StockNo as L_StockNo,a.O_StockName as L_StockName, COUNT(*) as nCount  from %s a, %s b '+
            ' where a.O_ID = b.D_OID and a.O_ProID = ''%s'' and b.D_OutFact >= ''%s'' and b.D_OutFact <= ''%s'' ' +
            ' Group by D_ID, O_BID, O_ProName, O_Truck, D_Value, D_MValue, D_PValue,'+
            ' D_OutFact, O_StockNo,O_StockName ' ;
    nStr := Format(nStr, [sTable_Order, sTable_OrderDtl, nClientNo,nStart,nEnd]);
  end;

  with gDBConnManager.WorkerQuery(FDBConn, nStr), FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nData := '�˿ͻ��ڱ��ڼ����޵���.';
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;
      Exit;
    end;

    First;
    nNode := Root.NodeNew('Items');
    while not Eof do
    begin
      with nNode.NodeNew('Item') do
      begin
        NodeNew('LID').ValueAsString        := FieldByName('L_ID').AsString;
        NodeNew('Zhika').ValueAsString      := FieldByName('L_ZhiKa').AsString;
        NodeNew('CusName').ValueAsString    := FieldByName('L_CusName').AsString;
        NodeNew('Truck').ValueAsString      := FieldByName('L_Truck').AsString;
        NodeNew('Value').ValueAsString      := FieldByName('L_Value').AsString;
        NodeNew('MValue').ValueAsString     := FieldByName('L_MValue').AsString;
        NodeNew('PValue').ValueAsString     := FieldByName('L_PValue').AsString;
        NodeNew('Price').ValueAsString      := FieldByName('L_Price').AsString;
        NodeNew('Money').ValueAsString      := FieldByName('L_Money').AsString;
        NodeNew('OutFact').ValueAsString    := FieldByName('L_OutFact').AsString;
        NodeNew('HYDan').ValueAsString      := FieldByName('L_HYDan').AsString;
        NodeNew('StockNo').ValueAsString    := FieldByName('L_StockNo').AsString;
        NodeNew('StockName').ValueAsString  := FieldByName('L_StockName').AsString;
        NodeNew('Count').ValueAsString      := FieldByName('nCount').AsString;
      end;
      
      nExt;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString     := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;

  end;
  
  nData  := FPacker.XMLBuilder.WriteToString;
  Result := True;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerBusinessWebchat, sPlug_ModuleBus);

end.

