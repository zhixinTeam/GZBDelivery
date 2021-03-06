{*******************************************************************************
  作者: dmzn@163.com 2012-02-03
  描述: 业务常量定义

  备注:
  *.所有In/Out数据,最好带有TBWDataBase基数据,且位于第一个元素.
*******************************************************************************}
unit UBusinessConst;

interface

uses
  Classes, SysUtils, UBusinessPacker, ULibFun, USysDB;

const
  {*channel type*}
  cBus_Channel_Connection     = $0002;
  cBus_Channel_Business       = $0005;

  {*query field define*}
  cQF_Bill                    = $0001;

  {*business command*}
  cBC_GetSerialNO             = $0001;   //获取串行编号
  cBC_ServerNow               = $0002;   //服务器当前时间
  cBC_IsSystemExpired         = $0003;   //系统是否已过期
  cBC_GetCardUsed             = $0004;   //获取卡片类型
  cBC_UserLogin               = $0005;   //用户登录
  cBC_UserLogOut              = $0006;   //用户注销
  cBC_UserYSWh                = $8006;   //用户验收权限
  cBC_GetOrderCType           = $0007;   //获取采购单卡类型
  cBC_GetDuanDaoCType         = $6017;   //获取短倒单卡类型

  cBC_GetCustomerMoney        = $0010;   //获取客户可用金
  cBC_GetZhiKaMoney           = $0011;   //获取纸卡可用金
  cBC_CustomerHasMoney        = $0012;   //客户是否有余额
  cBC_DaiPercentToZero        = $0014;   //将袋装发货量转为0的比率

  cBC_SaveTruckInfo           = $0013;   //保存车辆信息
  cBC_UpdateTruckInfo         = $0017;   //更新车辆信息
  cBC_GetTruckPoundData       = $0015;   //获取车辆称重数据
  cBC_SaveTruckPoundData      = $0016;   //保存车辆称重数据

  cBC_SaveBills               = $0020;   //保存交货单列表
  cBC_DeleteBill              = $0021;   //删除交货单
  cBC_ModifyBillTruck         = $0022;   //修改车牌号
  cBC_SaleAdjust              = $0023;   //销售调拨
  cBC_SaveBillCard            = $0024;   //绑定交货单磁卡
  cBC_LogoffCard              = $0025;   //注销磁卡

  cBC_ReadYTCard              = $0026;   //读取云天卡片信息
  cBC_VerifyYTCard            = $0027;   //校验云天卡片有效性

  cBC_SaveBillLSCard          = $0028;   //绑定厂内零售磁卡(单厂)

  cBC_SaveOrder               = $0040;
  cBC_DeleteOrder             = $0041;
  cBC_SaveOrderCard           = $0042;
  cBC_LogOffOrderCard         = $0043;
  cBC_GetPostOrders           = $0044;   //获取岗位采购单
  cBC_GetPostOrders_KS        = $8044;   //获取矿山采购单
  cBC_SavePostOrders          = $0045;   //保存岗位采购单
  cBC_SaveOrderBase           = $0046;   //保存采购申请单
  cBC_DeleteOrderBase         = $0047;   //删除采购申请单
  cBC_GetGYOrderValue         = $0048;   //获取已收货量
  cBC_ImportOrderPoundS       = $0049;   //批量插入过磅信息

  cBC_AlterPostOrders         = $0050;   //修改采购单品种信息
  cBC_AlterTruckSnap          = $0051;   //修改车辆签到信息

  cBC_GetPostBills            = $0030;   //获取岗位交货单
  cBC_SavePostBills           = $0031;   //保存岗位交货单
  cBC_MakeSanPreHK            = $0032;   //执行散装预合卡(单厂)

  cBC_ChangeDispatchMode      = $0053;   //切换调度模式
  cBC_GetPoundCard            = $0054;   //获取磅站卡号
  cBC_GetReaderCard           = $0052;   //读卡器有效卡
  cBC_GetQueueData            = $0055;   //获取队列数据
  cBC_PrintCode               = $0056;
  cBC_PrintFixCode            = $0057;   //喷码
  cBC_PrinterEnable           = $0058;   //喷码机启停
  cBC_GetQueueList            = $0059;   //获取队列数据

  cBC_JSStart                 = $0060;
  cBC_JSStop                  = $0061;
  cBC_JSPause                 = $0062;
  cBC_JSGetStatus             = $0063;
  cBC_SaveCountData           = $0064;   //保存计数结果
  cBC_RemoteExecSQL           = $0065;

  cBC_ShowLedTxt              = $0066;   //向led屏幕发送内容
  cBC_GetLimitValue           = $0067;   //获取车辆最大限载值
  cBC_LineClose               = $0068;   //关闭放灰

  cBC_ShowTxt                 = $0079;   //车检:发送小屏

  cBC_FYWLGetSaleInfo         = $8001;   //发运物流销售单
  cBC_FYWLSynSalePound        = $8002;   //同步发运物流销售磅单
  cBC_FYWLSynOrderPound       = $8003;   //同步发运物流采购磅单
  cBC_FYWLSynOrderInfo        = $8004;   //同步发运物流采购订单

  cBC_IsTunnelOK              = $0075;
  cBC_TunnelOC                = $0076;
  cBC_PlayVoice               = $0077;
  cBC_OpenDoorByReader        = $0078;

  cBC_IsTruckQueue            = $8028;

  cBC_SyncCustomer            = $0080;   //远程同步客户
  cBC_SyncModCustomer         = $8081;   //远程修改客户
  cBC_SyncSaleMan             = $0081;   //远程同步业务员
  cBC_SyncStockBill           = $0082;   //同步单据到远程
  cBC_CheckStockValid         = $0083;   //验证是否允许发货
  cBC_SyncStockOrder          = $0084;   //同步采购单据到远程
  cBC_SyncProvider            = $0085;   //远程同步供应商
  cBC_SyncMaterails           = $0086;   //远程同步原材料
  cBC_SyncBillEdit            = $0087;   //更新提货单状态

  cBC_GetYTBatchCode          = $0088;   //获取云天系统批次
  cBC_SaveLadingSealInfo      = $0089;   //更新批次信息
  cBC_SyncYTBatchCodeInfo     = $0090;   //获取化验单信息

  cBC_VerifPrintCode          = $0091;   //验证喷码信息
  cBC_WaitingForloading       = $0092;   //工厂待装查询
  cBC_BillSurplusTonnage      = $0093;   //网上订单可下单数量查询
  cBC_GetOrderInfo            = $0094;   //获取订单信息，用于网上商城下单
  cBC_GetOrderList            = $0103;   //获取订单列表，用于网上商城下单
  cBC_GetPurchaseContractList = $0107;   //获取采购合同列表，用于网上商城下单

  sBus_BusinessPurchase       = 'Bus_BusinessPurchase'; //采购单相关
  sBus_BusinessHHJY           = 'Bus_BusinessHHJY';     //恒河久远接口服务
  sCLI_BusinessHHJY           = 'CLI_BusinessHHJY';     //恒河久远接口服务

  cBC_WeChat_getCustomerInfo  = $0095;   //微信平台接口：获取客户注册信息
  cBC_WeChat_get_Bindfunc     = $0096;   //微信平台接口：客户与微信账号绑定
  cBC_WeChat_send_event_msg   = $0097;   //微信平台接口：发送消息
  cBC_WeChat_edit_shopclients = $0098;   //微信平台接口：新增商城用户
  cBC_WeChat_edit_shopgoods   = $0099;   //微信平台接口：添加商品
  cBC_WeChat_get_shoporders   = $0100;   //微信平台接口：获取订单信息

  cBC_WeChat_complete_shoporders   = $0101;   //微信平台接口：修改订单状态
  cBC_WeChat_get_shoporderbyNO     = $0102;   //微信平台接口：根据订单号获取订单信息
  cBC_WeChat_get_shopPurchasebyNO  = $0108;   //微信平台接口：根据订单号获取订单信息
  cBC_WeChat_InOutFactoryTotal     = $0200;   //微信平台接口：进出厂量查询（采购进厂量、销售出厂量）

  cBC_WeChat_SaveAutoSync     = $0120;        //微信业务: 增加自动更新

  cBC_WeChat_Get_ShopOrderByTruckNo = $600;   //微信平台接口：根据车号获取销售微信下单信息
  cBC_WeChat_Get_ShopPurchByTruckNo = $601;   //微信平台接口：根据车号获取采购微信下单信息
  cBC_WeChat_Get_DeclareTruck    = $602;      //微信平台接口：获取微信端提报车辆信息
  cBC_WeChat_Update_DeclareTruck = $603;      //微信平台接口：修改微信端提报车辆信息（审核信息）

  cBC_SavePurchaseContract         = $0104;   //保存采购合同
  cBC_DeletePurchaseContract       = $0105;   //删除采购合同
  cBC_ModifyPurchaseContract       = $0106;   //修改采购合同

  cBC_SyncProvidePound             = $0192;   //同步供应磅单到远程
  cBC_GetBatcodeAfterLine          = $0193;   //现场刷卡后获取批次号
  cBC_GetLineGroupByCustom         = $0194;   //获取客户指定分组编号

  cBC_GetWebOrderID              = $0195;   //获取网上下单申请单号
  cBC_GetStockBatcode            = $1100;   //获取批次编号(单厂)

  cSendWeChatMsgType_AddBill       = 1;       //开提货单
  cSendWeChatMsgType_OutFactory    = 2;       //车辆出厂
  cSendWeChatMsgType_Report        = 3;       //报表
  cSendWeChatMsgType_DelBill       = 4;       //删提货单

  c_WeChatStatusCreateCard         = 0;       //订单已办卡
  c_WeChatStatusFinished           = 1;       //订单已完成

  cBC_SaveBusinessCard             = $0136;   //保存当前刷卡信息
  cBC_SaveTruckLine                = $9090;   //保存装车道信息

  cBC_WX_VerifPrintCode       = $0501;   //微信：验证喷码信息
  cBC_WX_WaitingForloading    = $0502;   //微信：工厂待装查询
  cBC_WX_BillSurplusTonnage   = $0503;   //微信：网上订单可下单数量查询
  cBC_WX_GetOrderInfo         = $0504;   //微信：获取订单信息
  cBC_WX_GetOrderList         = $0505;   //微信：获取订单列表
  cBC_WX_GetPurchaseContract  = $0506;   //微信：获取采购合同列表

  cBC_WX_getCustomerInfo      = $0507;   //微信：获取客户注册信息
  cBC_WX_get_Bindfunc         = $0508;   //微信：客户与微信账号绑定
  cBC_WX_send_event_msg       = $0509;   //微信：发送消息
  cBC_WX_edit_shopclients     = $0510;   //微信：新增商城用户
  cBC_WX_edit_shopgoods       = $0511;   //微信：添加商品
  cBC_WX_get_shoporders       = $0512;   //微信：获取订单信息
  cBC_WX_complete_shoporders  = $0513;   //微信：修改订单状态
  cBC_WX_get_shoporderbyNO    = $0514;   //微信：根据订单号获取订单信息
  cBC_WX_get_shopPurchasebyNO = $0515;   //微信：根据订单号获取订单信息
  cBC_WX_ModifyWebOrderStatus = $0516;   //微信：修改网上订单状态
  cBC_WX_CreatLadingOrder     = $0517;   //微信：创建交货单
  cBC_WX_GetCusMoney          = $0518;   //微信：获取客户资金
  cBC_WX_GetInOutFactoryTotal = $0519;   //微信：获取进出厂统计
  cBC_WX_GetAuditTruck        = $0520;   //微信：获取审核车辆
  cBC_WX_UpLoadAuditTruck     = $0521;   //微信：审核车辆结果上传
  cBC_WX_DownLoadPic          = $0522;   //微信：下载图片
  cBC_WX_get_shoporderbyTruck = $0523;   //微信：根据车牌号获取订单信息
  cBC_WX_get_shoporderbyTruckClt = $0524;   //微信：根据车牌号获取订单信息  客户端用
  cBC_WX_get_shoporderStatus  = $0525;   //微信：根据订单号获取订单状态

  cBC_WX_get_ClientReportInfo    = $0535;   //微信：查询客户报表信息
  cBC_WX_get_QueueInfobyTruck    = $0536;   //微信：根据车牌号获取待上屏队列信息
  cBC_WX_get_TruckMaxBillNumInfo = $0537;   //微信：根据车牌号获取车牌荷载吨数信息
  cBC_WX_get_QuerySaleDtl        = $0538;   //微信：获取销售报表
  cBC_WX_get_LineInfobyTruck     = $0539;   //微信：车辆进厂后排队通道查询
  cBC_WX_get_TruckQueuedInfo     = $053A;   //微信：车辆排队通知

  cBC_WX_get_shopYYWebBill    = $0526;   //微信：根据时间段获取预约订单
  cBC_WX_SaveCustomerWxOrders = $0529;   //微信：新增客户预开单
  cBC_WX_IsCanCreateWXOrder   = $0531;   //微信：下单校验

type
  PWorkerQueryFieldData = ^TWorkerQueryFieldData;
  TWorkerQueryFieldData = record
    FBase     : TBWDataBase;
    FType     : Integer;           //类型
    FData     : string;            //数据
  end;

  PWorkerBusinessCommand = ^TWorkerBusinessCommand;
  TWorkerBusinessCommand = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //命令
    FData     : string;            //数据
    FExtParam : string;            //参数
    FRemoteUL : string;            //工厂服务器UL
  end;

  TPoundStationData = record
    FStation  : string;           //磅站标识
    FValue    : Double;           //皮重
    FDate     : TDateTime;        //称重日期
    FOperator : string;           //操作员
  end;

  PWorkerHHJYData = ^TWorkerHHJYData;
  TWorkerHHJYData = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //类型
    FData     : string;            //数据
    FExtParam : string;            //参数
    FRemoteUL : string;            //工厂服务器UL
  end;
  
  PLadingBillItem = ^TLadingBillItem;
  TLadingBillItem = record
    FID         : string;          //交货单号
    FZhiKa      : string;          //纸卡编号
    FProject    : string;          //项目编号
    FCusID      : string;          //客户编号
    FCusName    : string;          //客户名称
    FTruck      : string;          //车牌号码

    FType       : string;          //品种类型
    FStockNo    : string;          //品种编号
    FStockName  : string;          //品种名称
    FValue      : Double;          //提货量
    FPrice      : Double;          //提货单价

    FCard       : string;          //磁卡号
    FIsVIP      : string;          //通道类型
    FStatus     : string;          //当前状态
    FNextStatus : string;          //下一状态

    FPData      : TPoundStationData; //称皮
    FMData      : TPoundStationData; //称毛
    FFactory    : string;          //工厂编号
    FPModel     : string;          //称重模式
    FPType      : string;          //业务类型
    FPoundID    : string;          //称重记录
    FHKRecord   : string;          //合单记录
    FSelected   : Boolean;         //选中状态

    FSeal       : string;          //编号ID
    FHYDan      : string;          //水泥编号
    FPrintHY    : Boolean;         //打印化验单
    FLineGroup  : string;          //生产线

    FYSValid    : string;          //验收结果，Y验收成功；N拒收；
    FKZValue    : Double;          //供应扣除
    FYTID       : string;          //云天系统XLB_ID
    FMemo       : string;          //动作备注
    FArea       : string;          //销售片区
    Fworkaddr   : string;          //工地名称
    Ftransname  : string;          //运输单位
    Foutfact    : TDateTime;       //出厂日期
    FHdOrderId  : string;          //合单订单号
    FextDispatchNo:string;         //合单发运单号
    FYToutfact  : string;          //云天出厂日期
    FDispatchNo : string;          //物流发运单号
    FCtype      : string;          //卡类型；'L'：临时；'G'：固定
    FIsKS       : Integer          //0：不是矿山业务；1：是矿山业务(钟祥用),2:补单
  end;

  TLadingBillItems = array of TLadingBillItem;
  //交货单列表

  TQueueListItem = record
    FStockNO   : string;
    FStockName : string;

    FLineCount : Integer;
    FTruckCount: Integer;
  end;
  //待装车辆排队列表
  TQueueListItems = array of TQueueListItem;

  PWorkerWebChatData = ^TWorkerWebChatData;
  TWorkerWebChatData = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //类型
    FData     : string;            //数据
    FExtParam : string;            //参数
    FRemoteUL : string;            //工厂服务器UL
  end;

procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
//解析由业务对象返回的交货单数据
function CombineBillItmes(const nItems: TLadingBillItems): string;
//合并交货单数据为业务对象能处理的字符串

function Sbc2Dbc(const nStr: string):string;
//半角符号转全角符号
function Dbc2Sbc(const nStr: string):string;
//全角符号转半角符号

//解析由业务对象返回的待装排队数据
procedure AnalyseQueueListItems(const nData: string; var nItems: TQueueListItems);



resourcestring
  {*PBWDataBase.FParam*}
  sParam_NoHintOnError        = 'NHE';                  //不提示错误

  {*plug module id*}
  sPlug_ModuleBus             = '{DF261765-48DC-411D-B6F2-0B37B14E014E}';
                                                        //业务模块
  sPlug_ModuleHD              = '{B584DCD6-40E5-413C-B9F3-6DD75AEF1C62}';
                                                        //硬件守护
  sPlug_ModuleRemote          = '{B584DCD7-40E5-413C-B9F3-6DD75AEF1C63}';
                                                      //MIT互相访问                                                        
                                                                                                   
  {*common function*}  
  sSys_BasePacker             = 'Sys_BasePacker';       //基本封包器

  {*business mit function name*}
  sBus_ServiceStatus          = 'Bus_ServiceStatus';    //服务状态
  sBus_GetQueryField          = 'Bus_GetQueryField';    //查询的字段

  sBus_BusinessSaleBill       = 'Bus_BusinessSaleBill'; //交货单相关
  sBus_BusinessCommand        = 'Bus_BusinessCommand';  //业务指令
  sBus_HardwareCommand        = 'Bus_HardwareCommand';  //硬件指令
  sBus_BusinessDuanDao        = 'Bus_BusinessDuanDao';  //短倒业务相关
  sBus_BusinessPurchaseOrder  = 'Bus_BusinessPurchaseOrder'; //采购单相关
  sBus_BusinessPurchaseOrderSingle  = 'Bus_BusinessPurchaseOrderSingle'; //采购单相关(单厂)
  sBus_BusinessWebchat        = 'Bus_BusinessWebchat';  //Web平台服务
  sBus_BusinessSaleBillSingle = 'Bus_BusinessSaleBillSingle'; //交货单相关(单厂)

  {*client function name*}
  sCLI_ServiceStatus          = 'CLI_ServiceStatus';    //服务状态
  sCLI_GetQueryField          = 'CLI_GetQueryField';    //查询的字段
  sCLI_BusinessWebchat        = 'CLI_BusinessWebchat';  //Web平台服务

  sCLI_BusinessSaleBill       = 'CLI_BusinessSaleBill'; //交货单业务
  sCLI_BusinessCommand        = 'CLI_BusinessCommand';  //业务指令
  sCLI_HardwareCommand        = 'CLI_HardwareCommand';  //硬件指令
  sCLI_BusinessDuanDao        = 'CLI_BusinessDuanDao';  //短倒业务相关
  sCLI_BusinessPurchaseOrder  = 'CLI_BusinessPurchaseOrder'; //采购单相关
  sCLI_BusinessSaleBillSingle = 'CLI_BusinessSaleBillSingle'; //交货单业务(单厂)
  sCLI_BusinessPurchaseOrderSingle  = 'CLI_BusinessPurchaseOrderSingle'; //采购单相关(单厂)

implementation

//Date: 2014-09-17
//Parm: 交货单数据;解析结果
//Desc: 解析nData为结构化列表数据
procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
var nStr: string;
    nIdx,nInt: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := PackerDecodeStr(nData);
    //bill list
    nInt := 0;
    SetLength(nItems, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      //bill item

      with nListB,nItems[nInt] do
      begin
        FID         := Values['ID'];
        FZhiKa      := Values['ZhiKa'];
        FProject    := Values['Project'];
        FCusID      := Values['CusID'];
        FCusName    := Values['CusName'];
        FTruck      := Values['Truck'];

        FType       := Values['Type'];
        FStockNo    := Values['StockNo'];
        FStockName  := Values['StockName'];

        FCard       := Values['Card'];
        FIsVIP      := Values['IsVIP'];
        FStatus     := Values['Status'];
        FNextStatus := Values['NextStatus'];

        FFactory    := Values['Factory'];
        FPModel     := Values['PModel'];
        FPType      := Values['PType'];
        FPoundID    := Values['PoundID'];
        FSelected   := Values['Selected'] = sFlag_Yes;

        with FPData do
        begin
          FStation  := Values['PStation'];
          FDate     := Str2DateTime(Values['PDate']);
          FOperator := Values['PMan'];

          nStr := Trim(Values['PValue']);
          if (nStr <> '') and IsNumber(nStr, True) then
               FPData.FValue := StrToFloat(nStr)
          else FPData.FValue := 0;
        end;

        with FMData do
        begin
          FStation  := Values['MStation'];
          FDate     := Str2DateTime(Values['MDate']);
          FOperator := Values['MMan'];

          nStr := Trim(Values['MValue']);
          if (nStr <> '') and IsNumber(nStr, True) then
               FMData.FValue := StrToFloat(nStr)
          else FMData.FValue := 0;
        end;

        nStr := Trim(Values['Value']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FValue := StrToFloat(nStr)
        else FValue := 0;

        nStr := Trim(Values['Price']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FPrice := StrToFloat(nStr)
        else FPrice := 0;

        nStr := Trim(Values['KZValue']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FKZValue := StrToFloat(nStr)
        else FKZValue := 0;

        FSeal   := Values['Seal'];
        FHYDan  := Values['HYDan'];
        FPrintHY := Values['PrintHY'] = sFlag_Yes;
        FLineGroup := Values['LineGroup'];

        FMemo   := Values['Memo']; 
        FYSValid:= Values['YSValid'];
        FHKRecord:= Values['HKRecord'];

        FAREA := Values['AREA'];
        FWORKADDR := Values['WORKADDR'];
        FTRANSNAME := Values['TRANSNAME'];
        Foutfact := Str2DateTime(Values['OUTDATE']);
        FHdOrderId := Values['HdOrderId'];
        FextDispatchNo := Values['ExtDispatchNo'];
        FDispatchNo    := Values['DispatchNo'];
        FCtype         := Values['ctype'];
        FIsKS          := StrToIntDef(Values['IsKS'],0);
      end;

      Inc(nInt);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;   
end;

//Date: 2014-09-18
//Parm: 交货单列表
//Desc: 将nItems合并为业务对象能处理的
function CombineBillItmes(const nItems: TLadingBillItems): string;
var nIdx: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    Result := '';
    nListA.Clear;
    nListB.Clear;

    for nIdx:=Low(nItems) to High(nItems) do
    with nItems[nIdx] do
    begin
      if not FSelected then Continue;
      //ignored

      with nListB do
      begin
        Values['ID']         := FID;
        Values['ZhiKa']      := FZhiKa;
        Values['Project']    := FProject;
        Values['CusID']      := FCusID;
        Values['CusName']    := FCusName;
        Values['Truck']      := FTruck;

        Values['Type']       := FType;
        Values['StockNo']    := FStockNo;
        Values['StockName']  := FStockName;
        Values['Value']      := FloatToStr(FValue);
        Values['Price']      := FloatToStr(FPrice);

        Values['Card']       := FCard;
        Values['IsVIP']      := FIsVIP;
        Values['Status']     := FStatus;
        Values['NextStatus'] := FNextStatus;

        Values['Factory']    := FFactory;
        Values['PModel']     := FPModel;
        Values['PType']      := FPType;
        Values['PoundID']    := FPoundID;

        with FPData do
        begin
          Values['PStation'] := FStation;
          Values['PValue']   := FloatToStr(FPData.FValue);
          Values['PDate']    := DateTime2Str(FDate);
          Values['PMan']     := FOperator;
        end;

        with FMData do
        begin
          Values['MStation'] := FStation;
          Values['MValue']   := FloatToStr(FMData.FValue);
          Values['MDate']    := DateTime2Str(FDate);
          Values['MMan']     := FOperator;
        end;

        if FSelected then
             Values['Selected'] := sFlag_Yes
        else Values['Selected'] := sFlag_No;

        Values['Seal']       := FSeal;
        Values['HYDan']      := FHYDan;
        Values['LineGroup']  := FLineGroup;

        if FPrintHY then
             Values['PrintHY'] := sFlag_Yes
        else Values['PrintHY'] := sFlag_No;

        Values['KZValue']    := FloatToStr(FKZValue);
        Values['YSValid']    := FYSValid;
        Values['Memo']       := FMemo;
        Values['HKRecord']   := FHKRecord;
        
        Values['AREA']   := FAREA;
        Values['WORKADDR']   := FWORKADDR;
        Values['TRANSNAME']   := FTRANSNAME;
        Values['OUTDATE']   := DateTime2Str(Foutfact);
        Values['HdOrderId']    := FHdOrderId;
        Values['ExtDispatchNo']:= FextDispatchNo;
        Values['DispatchNo']   := FDispatchNo;
        Values['ctype']        := FCtype;
        Values['IsKS']         := IntToStr(FIsKS);
      end;

      nListA.Add(PackerEncodeStr(nListB.Text));
      //add bill
    end;

    Result := PackerEncodeStr(nListA.Text);
    //pack all
  finally
    nListB.Free;
    nListA.Free;
  end;
end;

{
在windows中，中文和全角字符都占两个字节，
并且使用了 ascii　chart  2  (codes  128 - 255 )。
全角字符的第一个字节总是被置为163，
而第二个字节则是 相同半角字符码加上128（不包括空格）。
如半角a为65，则全角a则是163（第一个字节）、 193 （第二个字节， 128 + 65 ）。
而对于中文来讲，它的第一个字节被置为大于163，（
如 ' 阿 ' 为: 176   162 ）,我们可以在检测到中文时不进行转换。
}

//------------------------------------------------------------------------------
//Date: 2015/11/25
//Parm: 
//Desc: 全角符号转半角符号
function Dbc2Sbc(const nStr: string):string;
var
  nLen,nIdx:integer;
  nStrTmp,nCStrTmp,nC1,nC2:string;
begin
  nLen:= length(nStr);
  if nLen = 0 then exit;

  nStrTmp  := '';
  nCStrTmp := nStr;
  SetLength(nCStrTmp, nLen + 1);

  nIdx := 1;
  while nIdx<=nLen do
  begin
    nC1 := nCStrTmp[nIdx];
    nC2 := nCStrTmp[nIdx + 1];

    if nC1 = #163 then //全角符号
    begin
      nStrTmp := nStrTmp + Chr(Ord(nC2[1]) - 128);
      Inc(nIdx, 2);
    end else

    if nC1 > #163 then //中文
    begin
      nStrTmp := nStrTmp + nC1 + nC2;
      Inc(nIdx, 2);
    end else

    if  (nC1 = #161 ) and (nC2 = #161 ) then   // 全角空格
    begin
      nStrTmp := nStrTmp + ' ';
      Inc(nIdx, 2 );
    end else

    begin
      nStrTmp := nStrTmp + nC1;
      Inc(nIdx, 1);
    end;
  end;

  Result:= nStrTmp;
end;

//------------------------------------------------------------------------------
//Date: 2015/11/25
//Parm: 
//Desc: 半角符号转全角符号
function Sbc2Dbc(const nStr: string):string;
var
  nLen,nIdx:integer;
  nStrTmp,nCStrTmp,nC1, nC2:string;
begin
  nLen:= length(nStr);
  if nLen = 0 then exit;

  nStrTmp  := '';
  nCStrTmp := nStr;
  SetLength(nCStrTmp, nLen + 1);

  nIdx := 1;
  while nIdx<=nLen do
  begin
    nC1 := nCStrTmp[nIdx];
    nC2 := nCStrTmp[nIdx + 1];

    if nC1 >= #163 then //中文 或 全角符号
    begin
      nStrTmp := nStrTmp + nC1 + nC2;
      Inc(nIdx, 2);
    end else

    if  (nC1 = #161) and (nC2 = #161) then   // 全角空格
    begin
      nStrTmp := nStrTmp +  nC1 + nC2;
      Inc(nIdx, 2);
    end else

    if  nC1 = ' ' then   // 空格
    begin
      nStrTmp := nStrTmp + #161 + #161;
      Inc(nIdx, 1);
    end else

    begin
      nStrTmp := nStrTmp + #163 + Chr(Ord(nC1[1]) + 128);
      Inc(nIdx, 1);
    end;
  end;

  Result:= nStrTmp;
end;

//Date: 2016-09-20
//Parm: 待装队列数据;解析结果
//Desc: 解析nData为结构化列表数据
procedure AnalyseQueueListItems(const nData: string; var nItems: TQueueListItems);
var nIdx,nInt: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := PackerDecodeStr(nData);
    //bill list
    nInt := 0;
    SetLength(nItems, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      //bill item

      with nListB,nItems[nInt] do
      begin
        FStockName := Values['StockName'];
        FLineCount := StrToIntDef(Values['LineCount'],0);
        FTruckCount := StrToIntDef(Values['TruckCount'],0);
      end;
      Inc(nInt);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;   
end;


end.


