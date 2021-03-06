{*******************************************************************************
  作者: dmzn@163.com 2012-4-22
  描述: 硬件动作业务
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
//处理网络自动发卡(新版驱动)
function DoTTCEDispenserIssCard(const nItem: PDispenserItem): Boolean;
//电子标签发卡(新版驱动)
function DoTruckSnapInfo(const nCard:string; nList:TStringList):Boolean;
//电子标签车辆签到并发送到小屏展示
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
procedure WhenBlueReaderCardArrived(nHost: TBlueReaderHost; nCard: TBlueReaderCard);
//有新卡号到达读头
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
//现场读头有新卡号
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
//现场读头卡号超时
procedure WhenBusinessMITSharedDataIn(const nData: string);
//业务中间件共享数据
function GetStockType(nBill: string):string;
//获取品种简称
function GetJSTruck(const nTruck,nBill: string): string;
//获取计数器显示车牌
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
//保存计数结果

//推送消息到微信平台
procedure SendMsgToWebMall(const nLid:string;const MsgType:Integer;
                           const nBillType:string;const nWOID:string='');

//发送消息
function Do_send_event_msg(const nXmlStr: string): string;

//修改网上订单状态
procedure ModifyWebOrderStatus(const nType,nLId,nSender,nDesc:string;
 nStatus:Integer=c_WeChatStatusFinished;const AWebOrderID:string='');
//修改网上订单状态
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
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
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
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
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
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象(单厂)
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
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
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

//Desc: 调用中间件上的采购单据对象
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
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的短倒单据对象
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
//Parm: 命令;数据;参数;输出
//Desc: 调用硬件守护上的业务对象
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
//Parm: 磁卡号;岗位;交货单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetLadingBills(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
end;

//Date: 2014-09-18
//Parm: 岗位;交货单列表
//Desc: 保存nPost岗位上的交货单数据
function SaveLadingBills(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2018-08-18
//Parm: 磁卡号;岗位;交货单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表(单厂)
function GetLadingBillsSingle(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBillSingle(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
end;

//Date: 2018-08-18
//Parm: 岗位;交货单列表
//Desc: 保存nPost岗位上的交货单数据(单厂)
function SaveLadingBillsSingle(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBillSingle(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: 磁卡号
//Desc: 获取磁卡使用类型
function GetCardUsed(const nCard: string; var nCardType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut);

  if Result then
       nCardType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2019-04-05
//Parm: 磁卡号
//Desc: 获取采购单卡类型
function GetOrderCType(const nCard: string; var nOrderCType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetOrderCType, nCard, '', @nOut);

  if Result then
       nOrderCType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2019-04-05
//Parm: 磁卡号
//Desc: 获取短倒单卡类型
function GetDuanDaoCType(const nCard: string; var nOrderCType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetDuanDaoCType, nCard, '', @nOut);

  if Result then
       nOrderCType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2019-04-05
//Parm: 单据号 类型
//Desc: 获取单据网上下单信息
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
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: 磁卡号;岗位;采购单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetLadingOrders(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
end;

//Date: 2015-08-06
//Parm: 岗位;采购单列表
//Desc: 保存nPost岗位上的采购单数据
function SaveLadingOrders(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_SavePostOrders, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: 岗位;采购单列表
//Desc: 保存nPost岗位上的采购单数据
function SaveLadingOrders_KS(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_AlterPostOrders, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: 磁卡号;岗位;短倒单列表
//Desc: 获取nPost岗位上磁卡为nCard的短倒单列表
function GetDuanDaoItems(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
end;

//Date: 2015-08-06
//Parm: 岗位;短倒单列表
//Desc: 保存nPost岗位上的短倒单数据
function SaveDuanDaoItems(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessDuanDao(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2013-07-21
//Parm: 事件描述;岗位标识
//Desc:
procedure WriteHardHelperLog(const nEvent: string; nPost: string = '');
begin
  gSysLoger.AddLog(THardwareHelper, '硬件守护辅助', nEvent);
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
//Parm: 读卡器编号
//Desc: 蓝卡读卡器抬杆
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
      WriteHardHelperLog('蓝卡读卡器抬杆:' + nReader);
    end
    else
    if nReaderType = sHyCard then
    begin
      gHYReaderManager.OpenDoor(nReader);
      WriteHardHelperLog('华益读卡器抬杆:' + nReader);
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
//Parm: 卡号
//Desc: 对nCard放行进厂
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
  WriteHardHelperLog('MakeTruckIn进入.' + ':::Reader [ ' + nReader + ' ] ');
  {$ENDIF}
  if gTruckQueueManager.IsTruckAutoIn and (GetTickCount -
     gHardwareHelper.GetCardLastDone(nCard, nReader) < 2 * 60 * 1000) then
  begin
    gHardwareHelper.SetReaderCard(nReader, nCard);
    Exit;
  end; //同读头同卡,在2分钟内不做二次进厂业务.

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
    nStr := '读取磁卡[ %s ]订单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    if nCardType = sFlag_DuanDao then
      gDisplayManager.Display(nReader, '磁卡无效');
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要进厂车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckNone) or (FStatus = sFlag_TruckIn) then Continue;
    //未进长,或已进厂

    nStr := '车辆[ %s ]下一状态为:[ %s ],进厂刷卡无效.';
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
        //抬杆

        nStr := '车辆[ %s ]再次抬杆操作.';
        nStr := Format(nStr, [nTrucks[0].FTruck]);
        WriteHardHelperLog(nStr, sPost_In);
      end;
    end;

    if nCardType = sFlag_DuanDao then
    begin
      nStr := '%s进厂';
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
      nStr := '车辆[ %s ]进厂放行失败.';
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
      //抬杆
    end;

    nStr := '%s磁卡[%s]进厂抬杆成功';
    nStr := Format(nStr, [BusinessToStr(nCardType), nCard]);
    WriteHardHelperLog(nStr, sPost_In);

    if nCardType = sFlag_DuanDao then
    begin
      nStr := '%s进厂';
      nStr := Format(nStr, [nTrucks[0].FTruck]);
      WriteHardHelperLog(nStr, sPost_In);
      gDisplayManager.Display(nReader, nStr);
    end;

    Exit;
  end;
  //非销售磁卡直接抬杆

  nPLine := nil;
  //nPTruck := nil;

  with gTruckQueueManager do
  if not IsDelayQueue then //非延时队列(厂内模式)
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
      nStr := '车辆[ %s ]没有在调度队列中.';
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
    nStr := '车辆[ %s ]进厂放行失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  with gTruckQueueManager do
  if not IsDelayQueue then //厂外模式,进厂时绑定道号(一车多单)
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
      //绑定通道
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
    //抬杆
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
    //加载提货单信息
    if not GetLadingBills(nLid, sFlag_BillDone, nBills) then
    begin
      Exit;
    end;
  end
  else if nBillType=sFlag_Provide then
  begin
    //加载采购订单信息
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
    nData := '微信消息延迟推送';
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

//发送消息
function Do_send_event_msg(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if TWorkerBusinessCommander.CallMe(cBC_WeChat_send_event_msg, nXmlStr, '', @nOut) then
       Result := nOut.FData
  else WriteHardHelperLog(nOut.FData);
end;

//修改网上订单状态
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
  if nWebOrderId='' then//开卡不执行 出厂执行
//  {$ENDIF}
  begin
    GetWebOrderID(nLId,nType,nWebOrderId,nWeight);
    FNetWeight := StrToFloatDef(nWeight, 0);
  end;

  if (nType = sFlag_Sale) or (nType = sFlag_SaleSingle) then
  begin
    WriteHardHelperLog('更新销售状态,微信单据号: ' + nWebOrderId);
  end else
  if nType = sFlag_Provide then
  begin
    WriteHardHelperLog('更新采购状态,微信单据号: ' + nWebOrderId);
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
    nData := '微信状态延迟推送';
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

//修改网上订单状态
function Do_ModifyWebOrderStatus(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if not TWorkerBusinessCommander.CallMe(cBC_WeChat_complete_shoporders, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//Date: 2012-4-22
//Parm: 卡号;读头;打印机;化验单打印机
//Desc: 对nCard放行出厂
procedure MakeTruckOut(const nCard,nReader,nPrinter: string;
  const nHYPrinter: string = '';const nReaderType: string = '');
var nStr,nCardType: string;
    nIdx: Integer;
    nRet: Boolean;
    nTrucks: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('MakeTruckOut进入.' + ':::Reader [ ' + nReader + ' ] ');
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
    nStr := '读取磁卡[ %s ]订单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    if nCardType = sFlag_DuanDao then
      gDisplayManager.Display(nReader, '磁卡无效');
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要出厂车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '车辆[ %s ]下一状态为:[ %s ],无法出厂.';
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
    nStr := '车辆[ %s ]出厂放行失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  BlueOpenDoor(nReader, nReaderType);
  //抬杆
  //发送微信商城
  if nCardType = sFlag_Provide then
    SendMsgToWebMall(nTrucks[0].FZhiKa,cSendWeChatMsgType_OutFactory,nCardType)
  else
  begin
    if Length(Trim(nTrucks[0].FDispatchNo)) < 1 then
    begin
      SendMsgToWebMall(nTrucks[0].FID,cSendWeChatMsgType_OutFactory,nCardType);
    end;
  end;
  //发起一次打印

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
    //磁卡类型

    {$IFDEF PrintHYEach}
    if Trim(FHYDan) <> '' then
    begin
      if CallBusinessCommand(cBC_SyncYTBatchCodeInfo, FHYDan,'',@nOut) then
      begin
        if nHYPrinter <> '' then
          nStr := nStr + #6 + nHYPrinter;
        //化验单打印机
      end
      else
      begin
        nStr := '车辆[ %s ]单据[ %s ]同步云天化验单[ %s ]信息失败.';
        nStr := Format(nStr, [FTruck, FID, FHYDan]);

        WriteHardHelperLog(nStr, sPost_Out);
      end;
    end;
    {$ELSE}
    if nHYPrinter <> '' then
      nStr := nStr + #6 + nHYPrinter;
    //化验单打印机
    {$ENDIF}

    if nPrinter = '' then
         gRemotePrinter.PrintBill(FID + nStr)
    else gRemotePrinter.PrintBill(FID + #9 + nPrinter + nStr); //打印报表

    if nCardType = sFlag_Provide then
         ModifyWebOrderStatus(nCardType, FZhiKa, 'MakeTruckOut', '刷卡出厂')
    else
    begin
      if Length(Trim(nTrucks[0].FDispatchNo)) < 1 then
        ModifyWebOrderStatus(nCardType, FID, 'MakeTruckOut', '刷卡出厂');
    end;
  end;

  if nCardType = sFlag_DuanDao then
  begin
    nStr := '%s出厂';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    gDisplayManager.Display(nReader, nStr);
  end;
end;

//Date: 2016-5-4
//Parm: 卡号;读头;打印机;化验单打印机
//Desc: 对nCard放行出
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
    nStr := '读取磁卡[ %s ]订单信息失败.';
    nStr := Format(nStr, [nCard]);
    Result := True;
    //磁卡已无效

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要出厂车辆.';
    nStr := Format(nStr, [nCard]);
    Result := True;
    //磁卡已无效

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '车辆[ %s ]下一状态为:[ %s ],无法出厂.';
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
    nStr := '车辆[ %s ]出厂放行失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  BlueOpenDoor(nReader, nReaderType);
  //抬杆
  //发送微信商城
  if nCardType = sFlag_Provide then
    SendMsgToWebMall(nTrucks[0].FZhiKa,cSendWeChatMsgType_OutFactory,nCardType)
  else
  begin
    if Length(Trim(nTrucks[0].FDispatchNo)) < 1 then
    begin
      SendMsgToWebMall(nTrucks[0].FID,cSendWeChatMsgType_OutFactory,nCardType);
    end;
  end;
  //发起一次打印

  {$IFDEF PrintHYEach}
  with nTrucks[0] do
  begin
    if Trim(FHYDan) <> '' then
    begin
      if not CallBusinessCommand(cBC_SyncYTBatchCodeInfo, FHYDan,'',@nOut) then
      begin
        nStr := '车辆[ %s ]单据[ %s ]同步云天化验单[ %s ]信息失败.';
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
    //磁卡类型

    if nHYPrinter <> '' then
      nStr := nStr + #6 + nHYPrinter;
    //化验单打印机

    if nPrinter = '' then
         gRemotePrinter.PrintBill(FID + nStr)
    else gRemotePrinter.PrintBill(FID + #9 + nPrinter + nStr);

    if nCardType = sFlag_Provide then
         ModifyWebOrderStatus(nCardType, FZhiKa, 'MakeTruckOutM100', '刷卡出厂')
    else
    begin
      if Length(Trim(nTrucks[0].FDispatchNo)) < 1 then
      begin
        ModifyWebOrderStatus(nCardType, FID, 'MakeTruckOutM100', '刷卡出厂');
      end;
    end;
  end;
  //打印报表

  Result := True;
end;

//Date: 2012-10-19
//Parm: 卡号;读头
//Desc: 检测车辆是否在队列中,决定是否抬杆
procedure MakeTruckPassGate(const nCard,nReader: string; const nDB: PDBWorker;
                            const nReaderType: string = '');
var nStr: string;
    nIdx: Integer;
    nTrucks: TLadingBillItems;
begin
  if not GetLadingBills(nCard, sFlag_TruckOut, nTrucks) then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要通过道闸的车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if gTruckQueueManager.TruckInQueue(nTrucks[0].FTruck) < 0 then
  begin
    nStr := '车辆[ %s ]不在队列,禁止通过道闸.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  BlueOpenDoor(nReader, nReaderType);
  //抬杆

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    nStr := 'Update %s Set T_InLade=%s Where T_Bill=''%s'' And T_InLade Is Null';
    nStr := Format(nStr, [sTable_ZTTrucks, sField_SQLServer_Now, nTrucks[nIdx].FID]);

    gDBConnManager.WorkerExec(nDB, nStr);
    //更新提货时间,语音程序将不再叫号.
  end;
end;

//Date: 2019-10-26
//Parm: 卡号;读头
//Desc: 抬杆同时生成过闸记录
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
    gDBConnManager.WorkerExec(nDB, nStr); //大于两天更新成已出厂
    
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
          nStr := '电子标签[ %s ]无对应的车辆绑定.';
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
        nStr := '厂内车辆已达最大允许进厂数:' + inttostr(nMaxNum);

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
      //抬杆
    end;
  finally
    FList.Free;
  end;
end;

//Date: 2019-10-26
//Parm: 卡号;读头
//Desc: 抬杆同时生成过闸记录
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
      //抬杆
    end;
  finally
    FList.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure WriteNearReaderLog(const nEvent: string);
begin
  gSysLoger.AddLog(T02NReader, '现场近距读卡器', nEvent);
end;

//Date: 2018-11-26
//Parm: 磁卡号;通道号
//Desc: 对nCard执行卸货操作
function MakeTruckYSStockTunnel(const nCard,nTunnel,nCardType: string) : Boolean;
var nStr, nStockNo, nStockName : string;
    nIdx,i: Integer;
    nTrucks: TLadingBillItems;
    nDBConn: PDBWorker;
begin
  WriteNearReaderLog('MakeTruckYSStockTunnel进入.'+' 磁卡:'+nCard+' 通道：'+nTunnel);

  Result := False;
  if nCardType = sFlag_Provide then
    Result := GetLadingOrders(nCard, 'X', nTrucks);

  if not Result then
  begin
    nStr := '读取磁卡[ %s ]业务单据信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    {$IFDEF StockTunnel}
     {$IFDEF LedNew}
     LEDDisplayNew(nTunnel, '', '磁卡无效');
     {$ELSE}
     gDisplayManager.Display(nTunnel, '磁卡无效');
     {$ENDIF}
    {$ENDIF}
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有对应车辆信息.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    {$IFDEF StockTunnel}
     {$IFDEF LedNew}
     LEDDisplayNew(nTunnel, '', '磁卡无效');
     {$ELSE}
     gDisplayManager.Display(nTunnel, '磁卡无效');
     {$ENDIF}
    {$ENDIF}
    Exit;
  end;

  for nIdx := Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FNextStatus='X') or (FNextStatus='M') then Continue;
    //未装或已装

    nStr := nTrucks[0].FTruck + '状态'+ FNextStatus +'不能验收';
    WriteNearReaderLog(nStr);
    Exit;
  end;

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
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

    nStr := '订单品种:'+ nTrucks[0].FStockNo + '与绑定品种'+ nStockNo +'不同';
    WriteNearReaderLog(nStr);
    Exit; 
  end;

  with nTrucks[0] do
  begin
    FYSValid  := 'Y';
    FKZValue  :=  0;
    FMemo     := '刷卡自动验收';
  end;
  
  if nCardType = sFlag_Provide then
    Result := SaveLadingOrders('X', nTrucks);
  if not Result then
  begin
    nStr := '车辆[ %s ]验收失败.';
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
//Parm: 读头数据
//Desc: 对nReader读到的卡号做具体动作
procedure WhenReaderCardArrived(const nReader: THHReaderItem);
var nStr,nSQL,nHYStr,nReaderType,nCard : string;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardArrived进入.');
  {$ENDIF}

  {$IFDEF UseELableOpenDoor}
  if nReader.FType = rtGate then
  begin
    if Assigned(nReader.FOptions) then
         nReaderType := nReader.FOptions.Values['ReaderType']
    else nReaderType := '';

    if Assigned(nReader.FOptions) then
    begin
      WriteHardHelperLog('电子标签号:'+nReader.FCard);
      with gParamManager.ActiveParam^ do
      try
        nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
        if not Assigned(nDBConn) then
        begin
          WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
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
    //抬杆
   // Exit;
  end;
  {$ENDIF}

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db
      nStr := Format('磁卡号[ %s ]通道号[ %s ].', [nReader.FCard,nReader.FID]);
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
            nStr := Format('磁卡号[ %s ]匹配失败.', [nReader.FCard]);
            WriteHardHelperLog(nStr);
            Exit;
          end;

          if (Copy(nReader.FID, 1, 1) = 'V') and
             (Fields[0].AsString = sFlag_OrderCardL) then
          begin
            nStr := '原材料临时卡禁止虚拟出厂.';
            WriteHardHelperLog(nStr);
            Exit;
          end;
        end;
      end else
      begin
        if Copy(nReader.FID, 1, 1) = 'V' then
        begin
          nStr := '非原材料固定卡禁止虚拟出厂.';
          WriteHardHelperLog(nStr);
          Exit;
        end;
      end;
      {$ENDIF}
    end else
    begin
      nStr := Format('磁卡号[ %s ]匹配失败.', [nReader.FCard]);
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
      WriteHardHelperLog('读卡器对应通道:'+Trim(nReader.FOptions.Values['Tunnel']));
      if MakeTruckYSStockTunnel(nCard,Trim(nReader.FOptions.Values['Tunnel']),nReaderType) then
      begin
        if nReader.FID <> '' then
          BlueOpenDoor(nReader.FID, nReaderType);
        //抬杆
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
        //抬杆
      end else

      if nReader.FType = rtQueueGate then
      begin
        if nReader.FID <> '' then
          MakeTruckPassGate(nStr, nReader.FID, nDBConn, nReaderType);
        //抬杆
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

//播放语音
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
    nStr := '%s采购电子标签无效';
    nStr := Format(nStr, [nECard]);
    WriteHardHelperLog(nStr);
    //PlayVoice(nStr);
    Exit;
  end;

  if Length(nTruck) < 3 then
  begin
    nStr := '车牌号%s长度非法';
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
    nStr := '%s获取网上下单信息失败';
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
      nStr := '%s校验采购合同有效性失败';
      nStr := Format(nStr, [nTruck]);
      WriteHardHelperLog(nStr);
      PlayVoice(nStr);
      Exit;
    end;
    //校验供应商进厂量限制
    {$IFDEF UseOrderDayNum}
      Amsg := '';
      if not GetDayNumInfo(nWebOrderItem.FGoodsID,nWebOrderItem.FProvID,Amsg) then
      begin
        nStr := '%s厂内仓库已满无法进厂卸货';
        nStr := Format(nStr, [nTruck]);
        WriteHardHelperLog(nStr);
        PlayVoice(nStr);
        Exit;
      end;
      if Amsg <> '' then
      begin
        nStr := '%s当日限制进厂时间已过,无法开单';
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
        nStr := '%s保存采购单失败';
        nStr := Format(nStr, [nTruck]);
        WriteHardHelperLog(nStr);
        Exit;
      end;

      SaveWebOrderMatch(nOrder, nWebOrderItem.FOrdernumber);
    finally
      nList.Free;
    end;
    WriteHardHelperLog('    ' + nOrder + '开始保存卡号：' + nCard);
    nRet := SaveOrderCard(nOrder, nCard);
    if nRet then
    begin
      WriteHardHelperLog('    ' + nCard + '准备发卡');
      {$IFDEF UseTTCEDispenser}
      if not gDispenserManager.SendCardOut(nID, nHint) then
      {$ELSE}
      if not gK720ReaderManager.SendCardOutF(nTunnel) then
      {$ENDIF}
      begin
        nStr := '车辆%s自动发卡失败';
        nStr := Format(nStr, [nTruck]);
        WriteHardHelperLog(nStr + ':' + nHint);
        PlayVoice(nStr);
        Exit;
      end;
      nStr := '品种%s车辆%s发卡成功，请您取卡';
      nStr := Format(nStr, [nStockName, nTruck]);
      WriteHardHelperLog(nStr);
      PlayVoice(nStr);
      Result := True;
    end;
  end;
end;

//Date: 2014-10-25
//Parm: 读头数据
//Desc: 华益读头磁卡动作
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
    WriteHardHelperLog(Format('华益标签 %s:%s', [nReader.FTunnel, nReader.FCard]));
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
        WriteHardHelperLog('电子标签：'+nReader.FCard);
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
              nStr := nStr + '签到成功';
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
        WriteHardHelperLog(Format('华益标签发卡机[ %s ]SendCard %s:%s',
                                 [nItem.FID, nReader.FCard, nReader.FTunnel]));
        DoTTCEDispenserIssCard(nItem);
      end
      else
      begin
        WriteHardHelperLog(Format('华益标签未找到发卡机[ %s ],无法执行发卡业务',
                                 [nItem.FID]));
      end;
      {$ELSE}
      gELabelFCard := nReader.FCard;
      gELabelFTunnel := nReader.FTunnel;
      WriteHardHelperLog(Format('华益标签SendCard %s:%s', [gELabelFCard, gELabelFTunnel]));
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
  //WriteHardHelperLog(Format('蓝卡读卡器 %s:%s', [nReader.FTunnel, nReader.FCard]));
  {$ENDIF}

  gHardwareHelper.SetReaderCard(nHost.FReaderID, nCard.FCard, False);
end;

//------------------------------------------------------------------------------
//Date: 2017/3/29
//Parm: 三合一读卡器
//Desc: 处理三合一读卡器信息
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
var nStr: string;
    nRetain: Boolean;
    nCType,nOrderCType,nReaderType: string;
begin
  nRetain := False;
  //init

  {$IFDEF DEBUG}
  nStr := '三合一读卡器卡号'  + nItem.FID + ' ::: ' + nItem.FCard;
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
        WriteHardHelperLog('采购单卡类型:' + nOrderCType);
        if nOrderCType = sFlag_OrderCardG then
          nRetain := False;
      end
      else if nCType = sFlag_DuanDao then
      begin
        GetDuanDaoCType(nItem.FCard, nOrderCType);
        WriteHardHelperLog('短倒单卡类型:' + nOrderCType);
        if nOrderCType = sFlag_OrderCardG then
          nRetain := False;
      end;
      if nRetain then
        WriteHardHelperLog('吞卡机执行状态:'+'卡类型:'+nCType+'动作:吞卡')
      else
        WriteHardHelperLog('吞卡机执行状态:'+'卡类型:'+nCType+'动作:吞卡后吐卡');
    end
    else
      gHardwareHelper.SetReaderCard(nItem.FVReader, nItem.FCard, False);
    end;
  finally
    gM100ReaderManager.DealtWithCard(nItem, nRetain)
  end;
end;

//lih 2018-02-03
//处理网络自动发卡
procedure WhenTTCE_K720_ReadCard(const nItem: PK720ReaderItem);
var
  nStr, nCard, nECard, nETunnel: string;
  nLast: Int64;
  nGetPurFailed: Boolean;
begin
  //{$IFDEF DEBUG}
  nStr := '网络发卡机'  + nItem.FID + ' ::: ' + nItem.FCard;
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
        WriteHardHelperLog(' ::: 磁卡' + nCard + '回收完毕');
      Exit;
    end;

    if gECard <> gELabelFCard then
    begin
      gECard := gELabelFCard;//gELabelItem.FCard;
      nETunnel := gELabelFTunnel;//gELabelItem.FTunnel;
      WriteHardHelperLog(' ::: 上次电子标签：' + gLastECard + '   当前电子标签：' + gECard);

      nLast := Trunc((GetTickCount - gLastTime) / 1000);
      WriteHardHelperLog(' ::: 间隔时长：' + IntToStr(nLast) + 's');
      if (gECard = gLastECard) and (gLastTime <> 0) and (nLast < 300) then
      begin
        WriteHardHelperLog(' ::: 电子标签'+gECard+'读取间隔时间小于300s');
        gLastECard := gECard;
        gELabelFCard := '';
        gECard := '';
        Exit;
      end;
      
      if not SavePurchBillAutoOutCard(nGetPurFailed, nCard, gECard, nETunnel) then
      begin
        WriteHardHelperLog(' ::: 通道[' + nETunnel + ']ELabel: [' + gECard + ']保存失败！');
        gLastTime := GetTickCount;
        gLastECard := gECard;
        gECard := '';
        Exit;
      end;
      WriteHardHelperLog(' ::: 电子标签'+gECard+'业务完毕');
      gLastTime := GetTickCount;
      gLastECard := gECard;
      gECard := '';
    end;
  end;
end;


// 2018-11-28
//处理网络自动发卡(新版驱动)
procedure WhenTTCE_K720_ReadCardByTTCEDispenser(const nItem: PDispenserItem);
var
  nStr: string;
begin
  //{$IFDEF DEBUG}
  nStr := '网络发卡机'  + nItem.FID + ' ::: ' + nItem.FNowCard;
  WriteHardHelperLog(nStr);
  //{$ENDIF}
end;

//电子标签车辆签到并发送到小屏展示
function DoTruckSnapInfo(const nCard:string; nList:TStringList):Boolean;
var
  nSql: string;
begin
  //
end;

// 2018-11-29
//电子标签自动发卡(新版驱动)
function DoTTCEDispenserIssCard(const nItem: PDispenserItem): Boolean;
var
  nStr, nCard, nECard, nETunnel, nHint: string;
  nLast, nLastTime: Int64;
  nGetPurFailed : Boolean;
begin
  Result := False;

  if not Assigned(nItem.FOptions) then
  begin
    nStr := '网络发卡机'  + nItem.FID + ' ::: Option节点未配置' ;
    Exit;
  end;

  with nItem.FOptions do
  begin
    //if Values['ECard'] <> Values['ELabelFCard'] then
    begin
      Values['ECard'] := Values['ELabelFCard'];//gELabelItem.FCard;
      nETunnel := Values['ELabelFTunnel'];//gELabelItem.FTunnel;
      WriteHardHelperLog(' ::: 上次电子标签：' + Values['LastECard']
                          + '   当前电子标签：' + Values['ECard']);

      nLastTime := StrToInt64Def(Values['LastTime'], 0);
      nLast := Trunc((GetTickCount - nLastTime) / 1000);
      WriteHardHelperLog(' ::: 间隔时长：' + IntToStr(nLast) + 's');

      if (Values['ECard'] = Values['LastECard']) and (nLastTime <> 0) and (nLast < 60) then
      begin
        WriteHardHelperLog(' ::: 电子标签'+Values['ECard']+'读取间隔时间小于60s');
        Values['LastECard'] := Values['ECard'];
        Values['ELabelFCard'] := '';
        Values['ECard'] := '';
        Exit;
      end;

      nCard := gDispenserManager.GetCardNo(nItem.FID, nHint, False);

      if nCard = '' then
      begin
        nStr := '网络发卡机'  + nItem.FID + ' ::: 读取卡号失败,' + nHint;
        WriteHardHelperLog(nStr);
        PlayVoice('读取卡号失败');
        Exit;
      end;

      if (nCard = Values['LastTCard']) and (Values['ECard'] <> Values['LastECard']) then
      begin
        WriteHardHelperLog(' ::: 电子标签'+Values['ECard']+'当前卡号'+
                           nCard + '与上次办卡成功卡号' + Values['LastTCard']+
                           '一致,业务终止');
        Exit;
      end;

      if not CheckCardOK(nCard, nStr) then
      begin
        WriteHardHelperLog(' ::: ' + nStr);
        PlayVoice(nStr);
        if gDispenserManager.RecoveryCard(nItem.FID, nHint) then
          WriteHardHelperLog(' ::: 磁卡' + nCard + '回收完毕');
        Exit;
      end;

      if not SavePurchBillAutoOutCard(nGetPurFailed, nCard, Values['ECard'], nETunnel, nItem.FID) then
      begin
        WriteHardHelperLog(' ::: 通道[' + nETunnel + ']ELabel: [' + Values['ECard'] + ']保存失败！');
        if nGetPurFailed then//读取订单失败调整间隔为10秒
          Values['LastTime'] := IntToStr(GetTickCount - 50000)
        else
          Values['LastTime'] := IntToStr(GetTickCount);
        Values['LastECard'] := Values['ECard'];
        Values['ECard'] := '';
        Exit;
      end;
      WriteHardHelperLog(' ::: 电子标签'+Values['ECard']+'业务完毕');
      Values['LastTime'] := IntToStr(GetTickCount);;
      Values['LastECard'] := Values['ECard'];
      Values['LastTCard'] := nCard;
      Values['ECard'] := '';
    end;
  end;
end;

//Date: 2012-4-24
//Parm: 车牌;通道;是否检查先后顺序;提示信息
//Desc: 检查nTuck是否可以在nTunnel装车
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
      nHint := Format('通道[ %s ]无效.', [nTunnel]);
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
        //不在当前队列
        if not StockMatch(nPLine.FStockNo, nLineItem) then Continue;
        //刷卡道与队列道品种不匹配

        nIdx := nPLine.FTrucks.Add(nLineItem.FTrucks[nInt]);
        nLineItem.FTrucks.Delete(nInt);
        //挪动车辆到新道

        nHint := 'Update %s Set T_Line=''%s'' ' +
                 'Where T_Truck=''%s'' And T_Line=''%s''';
        nHint := Format(nHint, [sTable_ZTTrucks, nPLine.FLineID, nTruck,
                nLineItem.FLineID]);
        gTruckQueueManager.AddExecuteSQL(nHint);

        nHint := '车辆[ %s ]自主换道[ %s->%s ]';
        nHint := Format(nHint, [nTruck, nLineItem.FName, nPLine.FName]);
        WriteNearReaderLog(nHint);
        Break;
      end;
    end;
    //袋装重调队列

    if nIdx < 0 then
    begin
      nHint := Format('车辆[ %s ]不在[ %s ]队列中.', [nTruck, nPLine.FName]);
      Exit;
    end;

    nPTruck := nPLine.FTrucks[nIdx];
//    nPTruck.FStockName := nPLine.FName;
//    //同步物料名
    Result := True;

    if (not nQueued) or (nIdx < 1) then Exit;
    //不检查队列,或头车

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
    //没有在装车车辆,无需排队

    if nIdx - nInt <> 1 then
    begin
      nHint := '车辆[ %s ]需要在[ %s ]排队等候.';
      nHint := Format(nHint, [nPTruck.FTruck, nPLine.FName]);

      Result := False;
      Exit;
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-1-21
//Parm: 通道号;交货单;
//Desc: 在nTunnel上打印nBill防伪码
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
    nStr := '向通道[ %s ]发送防违流码失败,描述: %s';
    nStr := Format(nStr, [nTunnel, nOut.FData]);  
    WriteNearReaderLog(nStr);
  end;

  gTaskMonitor.DelTask(nTask, True);
  //task done
end;

//Date: 2012-4-24
//Parm: 车牌;通道;交货单;启动计数
//Desc: 对在nTunnel的车辆开启计数器
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
      nHint := Format('通道[ %s ]无效.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if nIdx < 0 then
    begin
      nHint := Format('车辆[ %s ]已不再队列.', [nTruck]);
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
//Parm: 交货单号
//Desc: 查询nBill上的已装量
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
      WriteNearReaderLog('连接HM数据库失败(DBConn Is Null).');
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
      WriteNearReaderLog('连接HM数据库失败(DBConn Is Null).');
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
      WriteNearReaderLog('连接HM数据库失败(DBConn Is Null).');
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
//Parm: 车牌号;其他信息
//Desc: 小屏显示内容
function MakeShowTxt(const nTruck, nExt:string): string;
var nStr: string;
begin
  nStr := Copy(nTruck, Length(nTruck) - 5, 6);
  Result := Dbc2Sbc(nStr + StringOfChar(' ', 12 - Length(nStr)) + nExt);
end;

//Date: 2019-3-10
//Parm: 提货单号;装车线ID;装车线名称
//Desc: 更新装车道
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
//Parm: 磁卡号;通道号
//Desc: 对nCard执行卸货操作
procedure MakeTruckXieHuo(const nCard,nTunnel,nCardType: string);
var nStr, nStockNo, nStockName : string;
    nIdx,i: Integer;
    nTrucks: TLadingBillItems;
    nRet : Boolean;
    nDBConn: PDBWorker;
begin
  WriteNearReaderLog('MakeTruckXieHuo进入.'+' 磁卡:'+nCard+' 通道：'+nTunnel);

  nRet := False;
  if nCardType = sFlag_Provide then
    nRet := GetLadingOrders(nCard, sFlag_TruckBFM, nTrucks);

  if not nRet then
  begin
    nStr := '读取磁卡[ %s ]业务单据信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    {$IFDEF YanShouOnlyShow}
     {$IFDEF LedNew}
     LEDDisplayNew(nTunnel, '', '磁卡无效');
     {$ELSE}
     gDisplayManager.Display(nTunnel, '磁卡无效');
     {$ENDIF}
    {$ENDIF}
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有对应车辆信息.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    {$IFDEF YanShouOnlyShow}
     {$IFDEF LedNew}
     LEDDisplayNew(nTunnel, '', '磁卡无效');
     {$ELSE}
     gDisplayManager.Display(nTunnel, '磁卡无效');
     {$ENDIF}
    {$ENDIF}
    Exit;
  end;

  for nIdx := Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckBFM) or (FNextStatus = sFlag_TruckBFM) then Continue;
    //未装或已装
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
      WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
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
  //更改品种信息
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
    nStr := '车辆[ %s ]卸货处卸货失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if nCardType = sFlag_Provide then
    nRet := SaveLadingOrders(sFlag_TruckOut, nTrucks);
  if not nRet then
  begin
    nStr := '车辆[ %s ]卸货处自动出厂失败.';
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
//Parm: 车辆
//Desc: 查询nTruck所在道并与虚拟道匹配
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
      WriteNearReaderLog(Format('%s 为 非客户特定订单专用通道、检查通过', [nLine]));
      Result:= True;
      Exit;
    end;

    WriteNearReaderLog(Format('%s 为特定订单：%s 专用通道、进行通道匹配检查', [nLine, nLineCus]));
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
         WriteNearReaderLog(Format('%s %s 匹配检查通过', [nTruck,nLine]))
    else WriteNearReaderLog(Format('匹配检查未通过、%s 禁止在 %s 装车', [nTruck,nLine]));
  end;
end;

//Date: 2012-4-24
//Parm: 磁卡号;通道号
//Desc: 对nCard执行袋装装车操作
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
        nStr := '通道[ %s ]装车中,业务无效.';
        nStr := Format(nStr, [nTunnel]);
        WriteNearReaderLog(nStr);
      end;
    end;
begin
  WriteNearReaderLog('MakeTruckLadingDai进入.');

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
      nStr := '读取磁卡[ %s ]验收处采购单信息失败.';
      nStr := Format(nStr, [nCard]);

      WriteNearReaderLog(nStr);
      gDisplayManager.Display(nTunnel, '磁卡无效');
      Exit;
    end;

    if Length(nTrucks) < 1 then
    begin
      nStr := '磁卡[ %s ]没有需要验收车辆.';
      nStr := Format(nStr, [nCard]);

      WriteNearReaderLog(nStr);
      gDisplayManager.Display(nTunnel, '磁卡无效');
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
      nStr := '车辆[ %s ]下一状态为:[ %s ],无法卸货.';
      nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    end;

    if nInt < 1 then
    begin
      WriteHardHelperLog(nStr);

      nStr := MakeShowTxt(nTrucks[0].FTruck,
              '该 ' + TruckStatusToStr(nTrucks[0].FNextStatus));
      gDisplayManager.Display(nTunnel, nStr);
      Exit;
    end;

    if (nTunnel <> '') and (not
       IsTruckInTunnel(nTunnel, nTrucks[0].FStockNo)) then
    begin
      nStr := MakeShowTxt(nTrucks[0].FTruck, '请换库卸货');
      gDisplayManager.Display(nTunnel, nStr);
      Exit;
    end;

    for nIdx:=Low(nTrucks) to High(nTrucks) do
    with nTrucks[nIdx] do
    begin
      if not FSelected then Continue;
      if FStatus <> sFlag_TruckXH then Continue;

      nStr := '车辆[ %s ]再次刷卡卸货.';
      nStr := Format(nStr, [FTruck]);
      WriteNearReaderLog(nStr);

      nStr := MakeShowTxt(FTruck, FStockName);
      WriteNearReaderLog(nStr);
      gDisplayManager.Display(nTunnel, nStr);

      Exit;
    end;

    if not SaveLadingOrders(sFlag_TruckXH, nTrucks) then
    begin
      nStr := '车辆[ %s ]刷卡卸货失败.';
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
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要栈台提货车辆.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //重新定位车辆所在车道
    if IsJSRun then Exit;
  end;

  if gTruckQueueManager.IsDaiForceQueue then
  begin
    nBool := True;
    for nIdx:=Low(nTrucks) to High(nTrucks) do
    begin
      nBool := nTrucks[nIdx].FNextStatus = sFlag_TruckZT;
      //未装车,检查排队顺序
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
  end; //检查通道

  {$IFDEF UseDaiJYStockNo}
  if (nTunnel <> '') and (not
      IsTunnelStockNo(nTunnel, nTrucks[0].FStockNo)) then
  begin
    nStr := '交货单品种与通道品种不同';
    gDisplayManager.Display(nTunnel, nStr);
    WriteNearReaderLog('通道'+ nTunnel + nStr);
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
      //刷卡通道对应的交货单

      Continue;
    end;

    FSelected := False;
    nStr := '车辆[ %s ]下一状态为:[ %s ],无法栈台提货.';
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

    nStr := '袋装车辆[ %s ]再次刷卡装车.';
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
    nStr := '车辆[ %s ]栈台提货失败.';
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
//Parm: 车辆;通道
//Desc: 授权nTruck在nTunnel车道放灰
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
    //打开放灰

    nStr := nTruck.FTruck + StringOfChar(' ', 12 - Length(nTruck.FTruck));
    nTmp := nLine.FName + FloatToStr(nTruck.FValue);
    nStr := nStr + nLine.FName + StringOfChar(' ', 12 - Length(nTmp)) +
            FloatToStr(nTruck.FValue);
    //xxxxx

    gERelayManager.ShowTxt(nLine.FLineID, nStr);
  end;
  //显示内容
  {$IFDEF SanLed}
  nStr := nLine.FName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nTruck.FValue);
  LEDDisplayNew(nLine.FLineID, nStr, nTruck.FTruck);
  {$ENDIF}
end;

//Date: 2012-4-24
//Parm: 磁卡号;通道号
//Desc: 对nCard执行袋装装车操作
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
  WriteNearReaderLog('MakeTruckLadingSan进入.');
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
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要放灰车辆.';
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
    //过重后允许返回(状态回溯至成皮重,防止过快出厂)
    {$ENDIF}

    if (FStatus = sFlag_TruckFH) or (FNextStatus = sFlag_TruckFH) then Continue;
    //未装或已装

    nStr := '车辆[ %s ]下一状态为:[ %s ],无法放灰.';
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
      //未装车,检查排队顺序
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
    if nBool and (Pos('等候', nStr) > 0) then
      nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '请排队等候'
    else
      nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '请换库装车';
    gERelayManager.ShowTxt(nTunnel, nStr);
    {$IFDEF SanLed}
    if nBool and (Pos('等候', nStr) > 0) then
      LEDDisplayNew(nTunnel, '请排队等候', nTrucks[0].FTruck)
    else
      LEDDisplayNew(nTunnel, '请换库装车', nTrucks[0].FTruck);
    {$ENDIF}
    Exit;
  end; //检查通道

  nIsVIP:= False;
  if not CanLadingInLine(nTrucks[0].FTruck, nTunnel, nIsVIP) then
  begin
    WriteNearReaderLog(nStr);
    //loged

    nIdx := Length(nTrucks[0].FTruck);
    nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '当前为专用车道';
    nStr := '当前专用车道请换道装车';
    gERelayManager.ShowTxt(nTunnel, nStr);
    Exit;
  end; //检查通道

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    SaveTruckLine(FID, nTunnel, nPLine.FName);
  end;

  if nTrucks[0].FStatus = sFlag_TruckFH then
  begin
    nStr := '散装车辆[ %s ]再次刷卡装车.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    TruckStartFH(nPTruck, nPLine);

    {$IFDEF FixLoad}
    WriteNearReaderLog('启动定置装车::'+nTunnel+'@'+nCard);
    //发送卡号和通道号到定置装车服务器
    gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
    //二次调用
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
    nStr := '车辆[ %s ]放灰处提货失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  TruckStartFH(nPTruck, nPLine);
  //执行放灰
  {$IFDEF FixLoad}
  WriteNearReaderLog('启动定置装车::'+nTunnel+'@'+nCard);
  //发送卡号和通道号到定置装车服务器
  gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
  //二次调用
  gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
  {$ENDIF}
end;

//Date: 2012-4-24
//Parm: 主机;卡号
//Desc: 对nHost.nCard新到卡号作出动作
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
//Parm: 主机;卡号
//Desc: 对nHost.nCard超时卡作出动作
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardOut退出.');
  {$ENDIF}

  if Assigned(nHost.FOptions) then
  begin
    if nHost.FOptions.Values['YanShou'] = sFlag_Yes then
    begin
      Exit;
    end;
  end;

  {$IFDEF FixLoad}
  WriteHardHelperLog('停止定置装车::'+nHost.FTunnel+'@Close');
  //发送卡号和通道号到定置装车服务器
  gSendCardNo.SendCardNo(nHost.FTunnel+'@Close');
  {$ENDIF}

  {$IFDEF SanLed}
  LEDDisplayNew(nHost.FTunnel, '请刷卡', '欢迎光临');
  {$ENDIF}

  gERelayManager.LineClose(nHost.FTunnel);
  Sleep(100);

  if nHost.FETimeOut then
       gERelayManager.ShowTxt(nHost.FTunnel, '电子标签超出范围')
  else gERelayManager.ShowTxt(nHost.FTunnel, nHost.FLEDText);
  Sleep(100);
end;

//------------------------------------------------------------------------------
//Date: 2012-12-16
//Parm: 磁卡号
//Desc: 对nCardNo做自动出厂(模拟读头刷卡)
procedure MakeTruckAutoOut(const nCardNo: string);
var nReader: string;
begin
  if gTruckQueueManager.IsTruckAutoOut then
  begin
    nReader := gHardwareHelper.GetReaderLastOn(nCardNo);
    if nReader <> '' then
      gHardwareHelper.SetReaderCard(nReader, nCardNo);
    //模拟刷卡
  end;
end;

//Date: 2012-12-16
//Parm: 共享数据
//Desc: 处理业务中间件与硬件守护的交互数据
procedure WhenBusinessMITSharedDataIn(const nData: string);
begin
  WriteHardHelperLog('收到Bus_MIT业务请求:::' + nData);
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

  {$IFNDEF PreShowEx}//特殊显示不再截取
  Result := Copy(Result, 1, 4);
  {$ENDIF}
end;

//Date: 2015-01-14
//Parm: 车牌号;交货单
//Desc: 格式化nBill交货单需要显示的车牌号
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
  Result := Copy(nStr, 1, 2) +    //取前两位
            Copy(nTruck, Length(nTruck) - nLen + 1, nLen);
  Exit;
  {$ENDIF}
end;

//Date: 2013-07-17
//Parm: 计数器通道
//Desc: 保存nTunnel计数结果
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
