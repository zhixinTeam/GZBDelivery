{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusinessCommand;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, ADODB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst;

type
  TBusWorkerQueryField = class(TBusinessWorkerBase)
  private
    FIn: TWorkerQueryFieldData;
    FOut: TWorkerQueryFieldData;
  public
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //执行业务
  end;

  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //错误码
    FDBConn: PDBWorker;
    //数据通道
    FDataIn,FDataOut: PBWDataBase;
    //入参出参
    FDataOutNeedUnPack: Boolean;
    //需要解包
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //出入参数
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //验证入参
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //数据业务
  public
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
  end;

  TWorkerBusinessCommander = class(TMITDBWorker)
  private
    FListA,FListB,FListC, FListD: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetCardUsed(var nData: string): Boolean;
    //获取卡片类型
    function Login(var nData: string):Boolean;
    function LogOut(var nData: string): Boolean;
    //登录注销，用于移动终端
    function GetServerNow(var nData: string): Boolean;
    //获取服务器时间
    function GetSerailID(var nData: string): Boolean;
    //获取串号
    function IsSystemExpired(var nData: string): Boolean;
    //系统是否已过期
    function GetCustomerValidMoney(var nData: string): Boolean;
    //获取客户可用金
    function GetZhiKaValidMoney(var nData: string): Boolean;
    //获取纸卡可用金
    function CustomerHasMoney(var nData: string): Boolean;
    //验证客户是否有钱
    function GetDaiPercentToZero(var nData: string): Boolean;
    function SaveTruck(var nData: string): Boolean;
    function UpdateTruck(var nData: string): Boolean;
    //保存车辆到Truck表
    function GetTruckPoundData(var nData: string): Boolean;
    function SaveTruckPoundData(var nData: string): Boolean;
    //存取车辆称重数据
    function ReadYTCard(var nData: string): Boolean;
    //读取云天提货卡片
    function VerifyYTCard(var nData: string): Boolean;
    //验证云天提货卡有效性
    function SyncYT_Sale(var nData: string): Boolean;
    //发货单到榜单
    function SyncYT_Provide(var nData: string): Boolean;
    //供应订单到榜单
    function SyncYT_BillEdit(var nData: string): Boolean;
    //发货单状态同步
    function SyncYT_ProvidePound(var nData: string): Boolean;
    //同步供应磅单到磅单
    function SaveLadingSealInfo(var nData: string): Boolean;
    //修改发货单批次号
    function GetYTBatchCode(var nData: string): Boolean;
    //获取云天发货单批次号
    function SyncYT_BatchCodeInfo(var nData: string): Boolean;
    //获取云天系统化验单信息

    function SyncRemoteTransit(var nData: string): Boolean;
    function SyncRemoteSaleMan(var nData: string): Boolean;
    function SyncRemoteCustomer(var nData: string): Boolean;
    function SyncRemoteProviders(var nData: string): Boolean;
    function SyncRemoteMaterails(var nData: string): Boolean;

    //防伪码校验
    function CheckSecurityCodeValid(var nData: string): Boolean;

    //工厂待装查询
    function GetWaitingForloading(var nData: string):Boolean;

    //网上订单可下单数量查询
    function GetBillSurplusTonnage(var nData:string):boolean;

    //获取订单信息，用于网上下单
    function GetOrderInfo(var nData:string):Boolean;

    //获取订单信息，用于网上下单
    function GetOrderList(var nData:string):Boolean;

    //获取采购合同列表，用于网上下单
    function GetPurchaseContractList(var nData:string):Boolean;

    //获取客户注册信息
    function getCustomerInfo(var nData:string):Boolean;

    //客户与微信账号绑定
    function get_Bindfunc(var nData:string):Boolean;

    //发送消息
    function send_event_msg(var nData:string):Boolean;

    //新增商城用户
    function edit_shopclients(var nData:string):Boolean;

    //添加商品
    function edit_shopgoods(var nData:string):Boolean;

    //获取订单信息
    function get_shoporders(var nData:string):Boolean;

    //根据订单号获取订单信息
    function get_shoporderbyno(var nData:string):Boolean;

    //修改订单状态
    function complete_shoporders(var nData:string):Boolean;

  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
    class function VerifyDaiValue(nBill: TLadingBillItem;
      const nPercent: Double=0):Double;
    //袋装发货量
  end;

  TWorkerBusinessOrders = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton

    function SaveOrderBase(var nData: string):Boolean;
    function DeleteOrderBase(var nData: string):Boolean;
    function SavePurchaseContract(var nData: string):Boolean;
    function ModifyPurchaseContract(var nData: string):Boolean;
    function DeletePurchaseContract(var nData: string):Boolean;
    function SaveOrder(var nData: string):Boolean;
    function DeleteOrder(var nData: string): Boolean;
    function SaveOrderCard(var nData: string): Boolean;
    function LogoffOrderCard(var nData: string): Boolean;
    function ChangeOrderTruck(var nData: string): Boolean;
    //修改车牌号
    function GetGYOrderValue(var nData: string): Boolean;
    //获取供应可收货量

    function GetPostOrderItems(var nData: string): Boolean;
    //获取岗位采购单
    function SavePostOrderItems(var nData: string): Boolean;
    //保存岗位采购单

    function ImportOrderPoundS(var nData: string): Boolean;
    //插入磅单信息
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

  function DateTime2StrOracle(const nDT: TDateTime): string;
  function Date2StrOracle(const nDT: TDateTime): string;
  //Oracle Time Field

implementation
uses
  UMgrQueue,uFormCallWechatWebService;
class function TBusWorkerQueryField.FunctionName: string;
begin
  Result := sBus_GetQueryField;
end;

function TBusWorkerQueryField.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_GetQueryField;
  end;
end;

function TBusWorkerQueryField.DoWork(var nData: string): Boolean;
begin
  FOut.FData := '*';
  FPacker.UnPackIn(nData, @FIn);

  case FIn.FType of
   cQF_Bill:
    FOut.FData := '*';
  end;

  Result := True;
  FOut.FBase.FResult := True;
  nData := FPacker.PackOut(@FOut);
end;

//------------------------------------------------------------------------------
//Date: 2012-3-13
//Parm: 如参数护具
//Desc: 获取连接数据库所需的资源
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
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
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      nData := FPacker.PackOut(FDataOut);

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: 输出数据;结果
//Desc: 数据业务执行完毕后的收尾操作
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: 入参数据
//Desc: 验证入参数据是否有效
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: 记录nEvent日志
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function TWorkerBusinessCommander.FunctionName: string;
begin
  Result := sBus_BusinessCommand;
end;

constructor TWorkerBusinessCommander.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessCommander.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  inherited;
end;

function TWorkerBusinessCommander.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessCommander.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/22
//Parm: 订单记录
//Desc: 矫正袋装发货量,如果是散装，直接返回发货量；袋装则进行矫正
class function TWorkerBusinessCommander.VerifyDaiValue(nBill: TLadingBillItem;
    const nPercent: Double): Double;
var nNet, nTmpVal, nTmpNet: Double;
begin
  Result := nBill.FValue;

  with nBill do
  begin
    if (FType = sFlag_San) or (nPercent<=0) then Exit;

    nNet := FMData.FValue - FPData.FValue;

    nTmpVal := Float2Float(FValue * nPercent * 1000, cPrecision, False);
    nTmpNet := Float2Float(nNet * 1000, cPrecision, False);

    if nTmpVal>=nTmpNet then Result := 0;
    //净重\票重比率小于50%（可设置)时，认为该车出现问题，发货量记为0
  end;  
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessCommander.CallMe(const nCmd: Integer;
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
    nPacker.InitData(@nIn, True, False);
    //init
    
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
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

//Date: 2012-3-22
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_GetCardUsed         : Result := GetCardUsed(nData);
   cBC_ServerNow           : Result := GetServerNow(nData);
   cBC_GetSerialNO         : Result := GetSerailID(nData);
   cBC_IsSystemExpired     : Result := IsSystemExpired(nData);
   cBC_GetCustomerMoney    : Result := GetCustomerValidMoney(nData);
   cBC_GetZhiKaMoney       : Result := GetZhiKaValidMoney(nData);
   cBC_CustomerHasMoney    : Result := CustomerHasMoney(nData);
   cBC_DaiPercentToZero    : Result := GetDaiPercentToZero(nData);
   cBC_SaveTruckInfo       : Result := SaveTruck(nData);
   cBC_UpdateTruckInfo     : Result := UpdateTruck(nData);
   cBC_GetTruckPoundData   : Result := GetTruckPoundData(nData);
   cBC_SaveTruckPoundData  : Result := SaveTruckPoundData(nData);
   cBC_UserLogin           : Result := Login(nData);
   cBC_UserLogOut          : Result := LogOut(nData);

   cBC_ReadYTCard          : Result := ReadYTCard(nData);
   cBC_VerifyYTCard        : Result := VerifyYTCard(nData);
   cBC_SyncStockBill       : Result := SyncYT_Sale(nData);
   cBC_SyncStockOrder      : Result := SyncYT_Provide(nData);
   cBC_SyncBillEdit        : Result := SyncYT_BillEdit(nData);
   cBC_SyncProvidePound    : Result := SyncYT_ProvidePound(nData);

   cBC_GetYTBatchCode      : Result := GetYTBatchCode(nData);
   cBC_SaveLadingSealInfo  : Result := SaveLadingSealInfo(nData);
   cBC_SyncYTBatchCodeInfo : Result := SyncYT_BatchCodeInfo(nData);

   cBC_SyncCustomer        : Result := SyncRemoteCustomer(nData);
   cBC_SyncSaleMan         : Result := SyncRemoteSaleMan(nData);
   cBC_SyncProvider        : Result := SyncRemoteProviders(nData);
   cBC_SyncMaterails       : Result := SyncRemoteMaterails(nData);

   cBC_VerifPrintCode      : Result := CheckSecurityCodeValid(nData); //验证码查询
   cBC_WaitingForloading   : Result := GetWaitingForloading(nData); //待装车辆查询
   cBC_BillSurplusTonnage  : Result := GetBillSurplusTonnage(nData); //查询商城订单可用量
   cBC_GetOrderInfo        : Result := GetOrderInfo(nData); //查询云天系统订单信息
   cBC_GetOrderList        : Result := GetOrderList(nData); //查询云天系统订单列表
   cBC_GetPurchaseContractList : Result := GetPurchaseContractList(nData); //查询采购合同列表
   
   cBC_WeChat_getCustomerInfo : Result := getCustomerInfo(nData);   //微信平台接口：获取客户注册信息
   cBC_WeChat_get_Bindfunc    : Result := get_Bindfunc(nData);   //微信平台接口：客户与微信账号绑定
   cBC_WeChat_send_event_msg  : Result := send_event_msg(nData);   //微信平台接口：发送消息
   cBC_WeChat_edit_shopclients : Result := edit_shopclients(nData);   //微信平台接口：新增商城用户
   cBC_WeChat_edit_shopgoods  : Result := edit_shopgoods(nData);   //微信平台接口：添加商品
   cBC_WeChat_get_shoporders  : Result := get_shoporders(nData);   //微信平台接口：获取订单信息
   cBC_WeChat_complete_shoporders  : Result := complete_shoporders(nData);   //微信平台接口：修改订单状态
   cBC_WeChat_get_shoporderbyno : Result := get_shoporderbyno(nData);   //微信平台接口：根据订单号获取订单信息   
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//Date: 2014-09-05
//Desc: 获取卡片类型：销售S;采购P;其他O
function TWorkerBusinessCommander.GetCardUsed(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Select C_Used From %s Where C_Card=''%s'' ' +
          'or C_Card3=''%s'' or C_Card2=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FData, FIn.FData, FIn.FData]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    FOut.FData := Fields[0].AsString;
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: 用户名，密码；返回用户数据
//Desc: 用户登录
function TWorkerBusinessCommander.Login(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if FListA.Values['User']='' then Exit;
  //未传递用户名

  nStr := 'Select U_Password From %s Where U_Name=''%s''';
  nStr := Format(nStr, [sTable_User, FListA.Values['User']]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    nStr := Fields[0].AsString;
    if nStr<>FListA.Values['Password'] then Exit;
    {
    if CallMe(cBC_ServerNow, '', '', @nOut) then
         nStr := PackerEncodeStr(nOut.FData)
    else nStr := IntToStr(Random(999999));

    nInfo := FListA.Values['User'] + nStr;
    //xxxxx

    nStr := 'Insert into $EI(I_Group, I_ItemID, I_Item, I_Info) ' +
            'Values(''$Group'', ''$ItemID'', ''$Item'', ''$Info'')';
    nStr := MacroValue(nStr, [MI('$EI', sTable_ExtInfo),
            MI('$Group', sFlag_UserLogItem), MI('$ItemID', FListA.Values['User']),
            MI('$Item', PackerEncodeStr(FListA.Values['Password'])),
            MI('$Info', nInfo)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);  }

    Result := True;
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: 用户名；验证数据
//Desc: 用户注销
function TWorkerBusinessCommander.LogOut(var nData: string): Boolean;
//var nStr: string;
begin
  {nStr := 'delete From %s Where I_ItemID=''%s''';
  nStr := Format(nStr, [sTable_ExtInfo, PackerDecodeStr(FIn.FData)]);
  //card status

  
  if gDBConnManager.WorkerExec(FDBConn, nStr)<1 then
       Result := False
  else Result := True;     }

  Result := True;
end;

//Date: 2014-09-05
//Desc: 获取服务器当前时间
function TWorkerBusinessCommander.GetServerNow(var nData: string): Boolean;
var nStr: string;
begin
  nStr := 'Select ' + sField_SQLServer_Now;
  //sql

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    FOut.FData := DateTime2Str(Fields[0].AsDateTime);
    Result := True;
  end;
end;

//Date: 2012-3-25
//Desc: 按规则生成序列编号
function TWorkerBusinessCommander.GetSerailID(var nData: string): Boolean;
var nInt: Integer;
    nStr,nP,nB: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    Result := False;
    FListA.Text := FIn.FData;
    //param list

    nStr := 'Update %s Set B_Base=B_Base+1 ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, FListA.Values['Group'],
            FListA.Values['Object']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Select B_Prefix,B_IDLen,B_Base,B_Date,%s as B_Now From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_SerialBase,
            FListA.Values['Group'], FListA.Values['Object']]);
    //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '没有[ %s.%s ]的编码配置.';
        nData := Format(nData, [FListA.Values['Group'], FListA.Values['Object']]);

        FDBConn.FConn.RollbackTrans;
        Exit;
      end;

      nP := FieldByName('B_Prefix').AsString;
      nB := FieldByName('B_Base').AsString;
      nInt := FieldByName('B_IDLen').AsInteger;

      if FIn.FExtParam = sFlag_Yes then //按日期编码
      begin
        nStr := Date2Str(FieldByName('B_Date').AsDateTime, False);
        //old date

        if (nStr <> Date2Str(FieldByName('B_Now').AsDateTime, False)) and
           (FieldByName('B_Now').AsDateTime > FieldByName('B_Date').AsDateTime) then
        begin
          nStr := 'Update %s Set B_Base=1,B_Date=%s ' +
                  'Where B_Group=''%s'' And B_Object=''%s''';
          nStr := Format(nStr, [sTable_SerialBase, sField_SQLServer_Now,
                  FListA.Values['Group'], FListA.Values['Object']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);

          nB := '1';
          nStr := Date2Str(FieldByName('B_Now').AsDateTime, False);
          //now date
        end;

        System.Delete(nStr, 1, 2);
        //yymmdd
        nInt := nInt - Length(nP) - Length(nStr) - Length(nB);
        FOut.FData := nP + nStr + StringOfChar('0', nInt) + nB;
      end else
      begin
        nInt := nInt - Length(nP) - Length(nB);
        nStr := StringOfChar('0', nInt);
        FOut.FData := nP + nStr + nB;
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-05
//Desc: 验证系统是否已过期
function TWorkerBusinessCommander.IsSystemExpired(var nData: string): Boolean;
var nStr: string;
    nDate: TDate;
    nInt: Integer;
begin
  nDate := Date();
  //server now

  nStr := 'Select D_Value,D_ParamB From %s ' +
          'Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ValidDate]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := 'dmzn_stock_' + Fields[0].AsString;
    nStr := MD5Print(MD5String(nStr));

    if nStr = Fields[1].AsString then
      nDate := Str2Date(Fields[0].AsString);
    //xxxxx
  end;

  nInt := Trunc(nDate - Date());
  Result := nInt > 0;

  if nInt <= 0 then
  begin
    nStr := '系统已过期 %d 天,请联系管理员!!';
    nData := Format(nStr, [-nInt]);
    Exit;
  end;

  FOut.FData := IntToStr(nInt);
  //last days

  if nInt <= 7 then
  begin
    nStr := Format('系统在 %d 天后过期', [nInt]);
    FOut.FBase.FErrDesc := nStr;
    FOut.FBase.FErrCode := sFlag_ForceHint;
  end;
end;

//Date: 2014-09-05
//Desc: 获取指定客户的可用金额
function TWorkerBusinessCommander.GetCustomerValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nCredit: Double;
begin
  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的客户账户不存在.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;

    nVal := FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat;
    //xxxxx

    nCredit := FieldByName('A_CreditLimit').AsFloat;
    nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;

    if FIn.FExtParam = sFlag_Yes then
      nVal := nVal + nCredit;
    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;

    FOut.FData := FloatToStr(nVal);
    FOut.FExtParam := FloatToStr(nCredit);
    Result := True;
  end;
end;

//Date: 2014-09-05
//Desc: 获取指定纸卡的可用金额
function TWorkerBusinessCommander.GetZhiKaValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nMoney: Double;
begin
  nStr := 'Select ca.*,Z_OnlyMoney,Z_FixedMoney From $ZK,$CA ca ' +
          'Where Z_ID=''$ZID'' and A_CID=Z_Customer';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ZID', FIn.FData),
          MI('$CA', sTable_CusAccount)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的纸卡不存在,或客户账户无效.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;

    FOut.FExtParam := FieldByName('Z_OnlyMoney').AsString;
    nMoney := FieldByName('Z_FixedMoney').AsFloat;

    nVal := FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat +
            FieldByName('A_CreditLimit').AsFloat;
    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;

    if FOut.FExtParam = sFlag_Yes then
    begin
      if nMoney > nVal then
        nMoney := nVal;
      //enough money
    end else nMoney := nVal;

    FOut.FData := FloatToStr(nMoney);
    Result := True;
  end;
end;

//Date: 2014-09-05
//Desc: 验证客户是否有钱,以及信用是否过期
function TWorkerBusinessCommander.CustomerHasMoney(var nData: string): Boolean;
var nStr,nName: string;
    nM,nC: Double;
begin
  FIn.FExtParam := sFlag_No;
  Result := GetCustomerValidMoney(nData);
  if not Result then Exit;

  nM := StrToFloat(FOut.FData);
  FOut.FData := sFlag_Yes;
  if nM > 0 then Exit;

  nStr := 'Select C_Name From %s Where C_ID=''%s''';
  nStr := Format(nStr, [sTable_Customer, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
         nName := Fields[0].AsString
    else nName := '已删除';
  end;

  nC := StrToFloat(FOut.FExtParam);
  if (nC <= 0) or (nC + nM <= 0) then
  begin
    nData := Format('客户[ %s ]的资金余额不足.', [nName]);
    Result := False;
    Exit;
  end;

  nStr := 'Select MAX(C_End) From %s Where C_CusID=''%s'' and C_Money>=0';
  nStr := Format(nStr, [sTable_CusCredit, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
     (Fields[0].AsDateTime < Date()) then
  begin
    nData := Format('客户[ %s ]的信用已过期.', [nName]);
    Result := False;
  end;
end;

//Date: 2015-10-22
//Desc:
function TWorkerBusinessCommander.GetDaiPercentToZero(var nData: string): Boolean;
var nPercent: Double;
    nStr: string;
begin
  nStr := 'Select D_Value From %s Where D_Name=''%s'' ' +
          'And D_Memo=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundWuCha,
          sFlag_DaiPercentToZero]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
        nPercent := Fields[0].AsFloat
  else  nPercent := 0;

  FOut.FData := FloatToStr(nPercent);
  Result := True;
  //固定比率
end;

//Date: 2014-10-02
//Parm: 车牌号[FIn.FData];
//Desc: 保存车辆到sTable_Truck表
function TWorkerBusinessCommander.SaveTruck(var nData: string): Boolean;
var nStr: string;
begin
  Result := True;
  FIn.FData := UpperCase(FIn.FData);
  
  nStr := 'Select Count(*) From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, FIn.FData]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if Fields[0].AsInteger < 1 then
  begin
    nStr := 'Insert Into %s(T_Truck, T_PY) Values(''%s'', ''%s'')';
    nStr := Format(nStr, [sTable_Truck, FIn.FData, GetPinYinOfStr(FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2016-02-16
//Parm: 车牌号(Truck); 表字段名(Field);数据值(Value)
//Desc: 更新车辆信息到sTable_Truck表
function TWorkerBusinessCommander.UpdateTruck(var nData: string): Boolean;
var nStr: string;
    nValInt: Integer;
    nValFloat: Double;
begin
  Result := True;
  FListA.Text := FIn.FData;

  if FListA.Values['Field'] = 'T_PValue' then
  begin
    nStr := 'Select T_PValue, T_PTime From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, FListA.Values['Truck']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nValInt := Fields[1].AsInteger;
      nValFloat := Fields[0].AsFloat;
    end else Exit;

    nValFloat := nValFloat * nValInt + StrToFloatDef(FListA.Values['Value'], 0);
    nValFloat := nValFloat / (nValInt + 1);
    nValFloat := Float2Float(nValFloat, cPrecision);

    nStr := 'Update %s Set T_PValue=%.2f, T_PTime=T_PTime+1 Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nValFloat, FListA.Values['Truck']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2014-09-25
//Parm: 车牌号[FIn.FData]
//Desc: 获取指定车牌号的称皮数据(使用配对模式,未称重)
function TWorkerBusinessCommander.GetTruckPoundData(var nData: string): Boolean;
var nStr: string;
    nPound: TLadingBillItems;
begin
  SetLength(nPound, 1);
  FillChar(nPound[0], SizeOf(TLadingBillItem), #0);

  nStr := 'Select * From %s Where P_Truck=''%s'' And ' +
          'P_MValue Is Null And P_PModel=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, FIn.FData, sFlag_PoundPD]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),nPound[0] do
  begin
    if RecordCount > 0 then
    begin
      FCusID      := FieldByName('P_CusID').AsString;
      FCusName    := FieldByName('P_CusName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;

      FType       := FieldByName('P_MType').AsString;
      FStockNo    := FieldByName('P_MID').AsString;
      FStockName  := FieldByName('P_MName').AsString;

      with FPData do
      begin
        FStation  := FieldByName('P_PStation').AsString;
        FValue    := FieldByName('P_PValue').AsFloat;
        FDate     := FieldByName('P_PDate').AsDateTime;
        FOperator := FieldByName('P_PMan').AsString;
      end;  

      FFactory    := FieldByName('P_FactID').AsString;
      FPModel     := FieldByName('P_PModel').AsString;
      FPType      := FieldByName('P_Type').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;
      FSelected   := True;
    end else
    begin
      FTruck      := FIn.FData;
      FPModel     := sFlag_PoundPD;

      FStatus     := '';
      FNextStatus := sFlag_TruckBFP;
      FSelected   := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nPound);
  Result := True;
end;

//Date: 2014-09-25
//Parm: 称重数据[FIn.FData]
//Desc: 获取指定车牌号的称皮数据(使用配对模式,未称重)
function TWorkerBusinessCommander.SaveTruckPoundData(var nData: string): Boolean;
var nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  AnalyseBillItems(FIn.FData, nPound);
  //解析数据

  with nPound[0] do
  begin
    if FPoundID = '' then
    begin
      TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FTruck, '', @nOut);
      //保存车牌号

      FListC.Clear;
      FListC.Values['Group'] := sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_PoundID;

      if not CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FPoundID := nOut.FData;
      //new id

      if FPModel = sFlag_PoundLS then
           nStr := sFlag_Other
      else nStr := sFlag_Provide;

      nSQL := MakeSQLByStr([
              SF('P_ID', FPoundID),
              SF('P_Type', nStr),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', sFlag_San),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', FFactory),
              SF('P_PStation', FPData.FStation),
              SF('P_Direction', '进厂'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nStr := SF('P_ID', FPoundID);
      //where

      if FNextStatus = sFlag_TruckBFP then
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //称重时,由于皮重大,交换皮毛重数据
      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
      end;

      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    FOut.FData := FPoundID;
    Result := True;
  end;
end;

//Date: 2015-09-13
//Parm: 单据号[FData];查询条件[FExtParam]
//Desc: 依据查询条件,在云天.XS_Card_Base中查询卡片信息
function TWorkerBusinessCommander.ReadYTCard(var nData: string): Boolean;
var nStr: string;
    nWorker: PDBWorker;
begin
  nStr := 'select XCB_ID,' +                      //内部编号
          '  XCB_CardId,' +                       //销售卡片编号
          '  XCB_Origin,' +                       //卡片来源
          '  XCB_BillID,' +                       //来源单据号
          '  XCB_SetDate,' +                      //办理日期
          '  XCB_CardType,' +                     //卡片类型
          '  XCB_SourceType,' +                   //来源类型
          '  XCB_Option,' +                       //控制方式:0,控单价;1,控数量
          '  XCB_Client,' +                       //客户编号
          '  xob.XOB_Name as XCB_ClientName,' +   //客户名称
          '  xgd.XOB_Name as XCB_WorkAddr,' +     //工程工地
          '  XCB_Alias,' +                        //客户别名
          '  XCB_OperMan,' +                      //业务员
          '  XCB_Area,' +                         //销售区域
          '  XCB_CementType as XCB_Cement,' +     //品种编号
          '  PCM_Name as XCB_CementName,' +       //品种名称
          '  XCB_LadeType,' +                     //提货方式
          '  XCB_Number,' +                       //初始数量
          '  XCB_FactNum,' +                      //已开数量
          '  XCB_PreNum,' +                       //原已提量
          '  XCB_ReturnNum,' +                    //退货数量
          '  XCB_OutNum,' +                       //转出数量
          '  XCB_RemainNum,' +                    //剩余数量
          '  XCB_ValidS,XCB_ValidE,' +            //提货有效期
          '  XCB_AuditState,' +                   //审核状态
          '  XCB_Status,' +                       //卡片状态:0,停用;1,启用;2,冲红;3,作废
          '  XCB_IsImputed,' +                    //卡片是否估算
          '  XCB_IsOnly,' +                       //是否一车一票
          '  XCB_Del,' +                          //删除标记:0,正常;1,删除
          '  XCB_Creator,' +                      //创建人
          '  pub.pub_name as XCB_CreatorNM,' +    //创建人名
          '  XCB_CDate,' +                        //创建时间
          '  XCB_Firm,' +                         //所属厂区
          '  pbf.pbf_name as XCB_FirmName,' +     //工厂名称
          '  pcb.pcb_id, pcb.pcb_name, ' +        //销售片区
          '  xcg.xob_id as XCB_TransID, ' +       //运输单位编号
          '  xcg.XOB_Name as XCB_TransName ' +    //运输单位
          'from XS_Card_Base xcb' +
          '  left join XS_Compy_Base xob on xob.XOB_ID = xcb.XCB_Client' +
          '  left join XS_Compy_Base xgd on xgd.XOB_ID = xcb.xcb_sublader' +
          '  left join PB_Code_Material pcm on pcm.PCM_ID = xcb.XCB_CementType' +
          '  Left Join pb_code_block pcb On pcb.pcb_id=xob.xob_block' +
          '  Left Join pb_basic_firm pbf On pbf.pbf_id=xcb.xcb_firm' +
          '  Left Join PB_USER_BASE pub on pub.pub_id=xcb.xcb_creator ' +
          '  Left Join XS_Card_Freight xcf on xcf.Xcf_Card=xcb.xcb_ID ' +
          '  Left Join XS_Compy_Base xcg on xcg.xob_id=xcf.xcf_tran ' +
          'where rownum <= 10';
  //查询主题,返回记录不超过10条

  if FIn.FData <> '' then
    nStr := nStr + Format(' and XCB_CardID=''%s''', [FIn.FData]);
  //按单号查询

  if FIn.FExtParam <> '' then
    nStr := nStr + Format(' and (%s)', [FIn.FExtParam]);
  //附加查询条件

  Result := False;
  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_YT) do
    begin
      if RecordCount < 1 then
      begin
        if FIn.FData = '' then
             nData := '云天系统中未找到符合条件的数据.'
        else nData := Format('单据:[ %s ]无效,或者已经丢失.', [FIn.FData]);

        Exit;
      end;

      FListA.Clear;
      FListB.Clear;
      First;

      while not Eof do
      begin
        FListB.Values['XCB_ID']         := FieldByName('XCB_ID').AsString;
        FListB.Values['XCB_CardId']     := FieldByName('XCB_CardId').AsString;
        FListB.Values['XCB_Origin']     := FieldByName('XCB_Origin').AsString;
        FListB.Values['XCB_BillID']     := FieldByName('XCB_BillID').AsString;
        FListB.Values['XCB_SetDate']    := DateTime2Str(FieldByName('XCB_SetDate').AsDateTime);
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
        FListB.Values['XCB_RemainNum']  := FloatToStr(FieldByName('XCB_RemainNum').AsFloat);
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

        FListA.Add(PackerEncodeStr(FListB.Text));
        Next;
      end;

      FOut.FData := PackerEncodeStr(FListA.Text);
      Result := True;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2015-09-14
//Parm: 由ReadYTCard查询到的记录[FData];加载扩展信息[FIn.FExtParam]
//Desc: 验证记录是否有效,或者能否开单
function TWorkerBusinessCommander.VerifyYTCard(var nData: string): Boolean;
var nStr: string;
    nVal: Double;
    nWorker: PDBWorker;
begin
  with FListA do
  begin
    Result := False;
    nData := '';
    Text := PackerDecodeStr(FIn.FData);

    if Values['XCB_Del'] <> '0' then
    begin
      nStr := '※.单据:[ %s ]已删除,或被管理员关闭.' + #13#10;
      nData := Format(nStr, [Values['XCB_CardId']]);
    end;

    if (Values['XCB_IsOnly'] <> '1') and (Values['XCB_AuditState'] <> '201') then
    begin
      nStr := '※.单据:[ %s ]未通过管理员审核.' + #13#10;
      nData := nData + Format(nStr, [Values['XCB_CardId']]);
    end;
    //XCB_IsOnly为1时，一车一票先过磅，后审核

    if Values['XCB_Status'] <> '1' then
    begin
      nStr := '※.单据:[ %s ]未启用,已停用或作废.' + #13#10;
      nData := nData + Format(nStr, [Values['XCB_CardId']]);
    end;

    nStr := Values['XCB_RemainNum'];
    if not IsNumber(nStr, True) then
    begin
      nStr := '※.单据:[ %s ]剩余量读取失败.' + #13#10;
      nData := nData + Format(nStr, [Values['XCB_CardId']]);
      Exit;
    end;

    if nData <> ''  then Exit;
    //已有错误,不再校验冻结量

    //--------------------------------------------------------------------------
    nWorker := nil;
    try
      nStr := 'select XCB_FactRemain from V_CARD_BASE1 t where XCB_ID=''%s''';
      //nStr := 'select XCB_FactRemain from V_CARD_BASE t where XCB_ID=''%s''';
      //支持查询补货
      nStr := Format(nStr, [Values['XCB_ID']]);
      //查询剩余量
      
      with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_YT) do
      begin
        if RecordCount > 0 then
             nVal := Fields[0].AsFloat
        else nVal := 0;

        {$IFDEF DEBUG}
        nStr := '单据:[%s]=>云天系统剩余量[%f]';
        nStr := Format(nStr, [Values['XCB_ID'], Fields[0].AsFloat]);
        WriteLog(nStr);
        {$ENDIF}
      end;

      if nVal > 0 then
      begin
        nStr := 'Select * From %s Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CardInfo, Values['XCB_ID']]);

        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        if RecordCount > 0 then
        begin
          First;
          nVal := nVal - FieldByName('C_Freeze').AsFloat;
          //扣除已开未提
          nVal := Float2Float(nVal, cPrecision, False);

          {$IFDEF DEBUG}
          nStr := '单据:[%s]=>一卡通系统冻结量[%f]';
          nStr := Format(nStr, [Values['XCB_ID'], FieldByName('C_Freeze').AsFloat]);
          WriteLog(nStr);
          {$ENDIF}
        end;
      end;

      if (nVal <= 0) and (Pos(sFlag_AllowZeroNum, FIn.FExtParam) < 1) then
      begin
        nStr := '※.单据:[ %s ]可开票量为0,无法提货.' + #13#10;
        nData := nData + Format(nStr, [Values['XCB_CardId']]);
        Exit;
      end;

      Values['XCB_RemainNum'] := FloatToStr(nVal);
      //可用量

      //--------------------------------------------------------------------------
      if Pos(sFlag_LoadExtInfo, FIn.FExtParam) < 1 then
      begin
        FOut.FData := PackerEncodeStr(FListA.Text);
        Result := True;
        Exit;
      end; //是否加载订单附加信息

      nStr := 'Select D_Memo From %s Where D_ParamB=''%s''';
      nStr := Format(nStr, [sTable_SysDict, Values['XCB_Cement']]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then
        begin
          nStr := '品种[ %s.%s ]没有在字典中配置,请联系管理员.';
          nStr := Format(nStr, [Values['XCB_Cement'], Values['XCB_CementName']]);

          nData := nStr;
          Exit;
        end;

        Values['XCB_CementType'] := Fields[0].AsString;
        //包散类型
      end;

      FOut.FData := PackerEncodeStr(FListA.Text);
      Result := True;
    finally
      gDBConnManager.ReleaseConnection(nWorker);
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/13
//Parm: 
//Desc: 同步云天系统客户信息
function TWorkerBusinessCommander.SyncRemoteCustomer(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nStr := 'Select C_Param From %s Where C_XuNi<>''%s''';
  nStr := Format(nStr, [sTable_Customer, sFlag_Yes]);

  FListB.Clear;
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
  begin
    First;

    while not Eof do
    begin
      if Fields[0].AsString<>'' then FListB.Add(Fields[0].AsString);

      Next;
    end;  
  end;

  nDBWorker := nil;
  try
    nStr := 'Select XOB_ID,XOB_Code,XOB_Name,XOB_JianPin,XOB_Status ' +
            'From XS_Compy_Base ' +
            'Where XOB_IsClient=''1''';
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        if FieldByName('XOB_ID').AsString = '' then Continue;
        //invalid

        if FieldByName('XOB_Status').AsString = '1' then
        begin  //Add
          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          Continue;
          //Has Saved

          nStr := MakeSQLByStr([SF('C_ID', FieldByName('XOB_ID').AsString),
                  SF('C_Name', FieldByName('XOB_Name').AsString),
                  SF('C_PY', FieldByName('XOB_JianPin').AsString),
                  SF('C_Param', FieldByName('XOB_ID').AsString),
                  SF('C_XuNi', sFlag_No)
                  ], sTable_Customer, '', True);
          FListA.Add(nStr);

        end else
        begin  //valid
          nStr := 'Delete From %s Where C_Param=''%s''';
          nStr := Format(nStr, [sTable_Customer, FieldByName('XOB_ID').AsString]);
          //xxxxx

          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          FListA.Add(nStr);
          //Has Saved
        end;
      finally
        Next;
      end;
    end;

    if FListA.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;
      //开启事务
    
      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/13
//Parm: 
//Desc: 同步云天系统业务员信息
function TWorkerBusinessCommander.SyncRemoteSaleMan(var nData: string): Boolean;
begin
  Result := True;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/13
//Parm: 
//Desc: 同步云天系统供应商信息
function TWorkerBusinessCommander.SyncRemoteProviders(var nData: string): Boolean;
var nStr,nSaler: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  FListB.Clear;
  nStr := 'Select P_ID From P_Provider';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
  begin
    First;

    while not Eof do
    begin
      if Fields[0].AsString<>'' then FListB.Add(Fields[0].AsString);

      Next;
    end;  
  end;

  nDBWorker := nil;
  try
    nSaler := '待分配业务员';
    nStr := 'Select XOB_ID,XOB_Code,XOB_Name,XOB_JianPin,XOB_Status ' +
            'From XS_Compy_Base ' +
            'Where XOB_IsSupy=''1'' or XOB_IsMetals=''1''';
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        if FieldByName('XOB_ID').AsString = '' then Continue;
        //invalid

        if FieldByName('XOB_Status').AsString = '1' then
        begin  //Add
          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          Continue;
          //Has Saved

          nStr := MakeSQLByStr([SF('P_ID', FieldByName('XOB_ID').AsString),
                  SF('P_Name', FieldByName('XOB_Name').AsString),
                  SF('P_PY', GetPinYinOfStr(FieldByName('XOB_Name').AsString)),
                  SF('P_Memo', FieldByName('XOB_Code').AsString),
                  SF('P_Saler', nSaler)
                  ], sTable_Provider, '', True);
          //xxxxx

          FListA.Add(nStr);

        end else
        begin  //valid
          nStr := 'Delete From %s Where P_ID=''%s''';
          nStr := Format(nStr, [sTable_Provider, FieldByName('XOB_ID').AsString]);
          //xxxxx

          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          FListA.Add(nStr);
          //Has Saved
        end;
      finally
        Next;
      end;
    end;

    if FListA.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;
      //开启事务

      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/13
//Parm:
//Desc: 同步云天系统原材料信息
function TWorkerBusinessCommander.SyncRemoteMaterails(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  FListB.Clear;
  nStr := 'Select M_ID From P_Materails';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
  begin
    First;

    while not Eof do
    begin
      if Fields[0].AsString<>'' then FListB.Add(Fields[0].AsString);

      Next;
    end;  
  end;

  nDBWorker := nil;
  try
    nStr := 'Select PCM_ID,PCM_MaterId,PCM_Name,PCM_Kind,PCY_Name,PCM_Status ' +
            'From PB_Code_Material pcm ' +
            'Left join PB_Code_MaterType pcy on pcm.PCM_Kind=pcy.PCY_ID ';
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        if FieldByName('PCM_ID').AsString = '' then Continue;
        //invalid

        if FieldByName('PCM_Status').AsString = '1' then
        begin  //Add
          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('PCM_ID').AsString)>=0) then
          Continue;
          //Has Saved

          nStr := MakeSQLByStr([SF('M_ID', FieldByName('PCM_ID').AsString),
                SF('M_Name', FieldByName('PCM_Name').AsString),
                SF('M_PY', GetPinYinOfStr(FieldByName('PCM_Name').AsString)),
                SF('M_Memo', FieldByName('PCM_MaterId').AsString +
                  FieldByName('PCY_Name').AsString)
                ], sTable_Materails, '', True);
          //xxxxx

          FListA.Add(nStr);

        end else
        begin  //valid
          nStr := 'Delete From %s Where M_ID=''%s''';
          nStr := Format(nStr, [sTable_Materails, FieldByName('PCM_ID').AsString]);
          //xxxxx

          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('PCM_ID').AsString)>=0) then
          FListA.Add(nStr);
          //Has Saved
        end;
      finally
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2016-09-20
//Parm: 防伪码[FIn.FData]
//Desc: 防伪码校验
function TWorkerBusinessCommander.CheckSecurityCodeValid(var nData: string): Boolean;
var
  nStr,nCode,nBill_id: string;
  nSprefix:string;
  nIdx,nIdlen:Integer;
  nDs:TDataSet;
  nBills: TLadingBillItems;
begin
  nSprefix := '';
  nidlen := 0;
  Result := True;
  nCode := FIn.FData;
  if nCode='' then
  begin
    nData := '';
    FOut.FData := nData;
    Exit;
  end;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);
  nDs :=  gDBConnManager.WorkerQuery(FDBConn, nStr);

  if nDs.RecordCount>0 then
  begin
    nSprefix := nDs.FieldByName('B_Prefix').AsString;
    nIdlen := nDs.FieldByName('B_IDLen').AsInteger;
    nIdlen := nIdlen-length(nSprefix);
  end;

  //生成提货单号
  nBill_id := nSprefix+Copy(nCode,Length(nCode)-nIdlen+1,nIdlen);

  //查询数据库
  nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
      'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,' +
      'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue From $Bill b ';
  nStr := nStr + 'Where L_ID=''$CD''';
  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', nBill_id)]);

  nDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
  if nDs.RecordCount<1 then
  begin
    SetLength(nBills, 1);
    ZeroMemory(@nBills[0],0);
    FOut.FData := CombineBillItmes(nBills);
    Exit;
  end;

  SetLength(nBills, nDs.RecordCount);
  nIdx := 0;
  nDs.First;
  while not nDs.eof do
  begin
    with  nBills[nIdx] do
    begin
      FID         := nDs.FieldByName('L_ID').AsString;
      FZhiKa      := nDs.FieldByName('L_ZhiKa').AsString;
      FCusID      := nDs.FieldByName('L_CusID').AsString;
      FCusName    := nDs.FieldByName('L_CusName').AsString;
      FTruck      := nDs.FieldByName('L_Truck').AsString;

      FType       := nDs.FieldByName('L_Type').AsString;
      FStockNo    := nDs.FieldByName('L_StockNo').AsString;
      FStockName  := nDs.FieldByName('L_StockName').AsString;
      FValue      := nDs.FieldByName('L_Value').AsFloat;
      FPrice      := nDs.FieldByName('L_Price').AsFloat;

      FCard       := nDs.FieldByName('L_Card').AsString;
      FIsVIP      := nDs.FieldByName('L_IsVIP').AsString;
      FStatus     := nDs.FieldByName('L_Status').AsString;
      FNextStatus := nDs.FieldByName('L_NextStatus').AsString;
      FSelected := True;
      if FIsVIP = sFlag_TypeShip then
      begin
        FStatus    := sFlag_TruckZT;
        FNextStatus := sFlag_TruckOut;
      end;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      FPData.FValue := nDs.FieldByName('L_PValue').AsFloat;
      FMData.FValue := nDs.FieldByName('L_MValue').AsFloat;
    end;

    Inc(nIdx);
    nDs.Next;
  end;

  FOut.FData := CombineBillItmes(nBills);
end;

//Date: 2016-09-20
//Parm: 
//Desc: 工厂待装查询
function TWorkerBusinessCommander.GetWaitingForloading(var nData: string):Boolean;
var nFind: Boolean;
    nLine: PLineItem;
    nIdx,nInt, i: Integer;
    nQueues: TQueueListItems;
begin
  gTruckQueueManager.RefreshTrucks(True);
  Sleep(320);
  //刷新数据

  with gTruckQueueManager do
  try
    SyncLock.Enter;
    Result := True;

    FListB.Clear;
    FListC.Clear;

    i := 0;
    SetLength(nQueues, 0);
    //保存查询记录

    for nIdx:=0 to Lines.Count - 1 do
    begin
      nLine := Lines[nIdx];

      nFind := False;
      for nInt:=Low(nQueues) to High(nQueues) do
      begin
        with nQueues[nInt] do
          if FStockNo = nLine.FStockNo then
          begin
            Inc(FLineCount);
            FTruckCount := FTruckCount + nLine.FRealCount;

            nFind := True;
            Break;
          end;
      end;

      if not nFind then
      begin
        SetLength(nQueues, i+1);
        with nQueues[i] do
        begin
          FStockNO    := nLine.FStockNo;
          FStockName  := nLine.FStockName;

          FLineCount  := 1;
          FTruckCount := nLine.FRealCount;
        end;

        Inc(i);
      end;
    end;

    for nIdx:=Low(nQueues) to High(nQueues) do
    begin
      with FListB, nQueues[nIdx] do
      begin
        Clear;

        Values['StockName'] := FStockName;
        Values['LineCount'] := IntToStr(FLineCount);
        Values['TruckCount']:= IntToStr(FTruckCount);
      end;

      FListC.Add(PackerEncodeStr(FListB.Text));
    end;

    FOut.FData := PackerEncodeStr(FListC.Text);
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2016-09-23
//Parm:
//Desc: 网上订单可下单数量查询
function TWorkerBusinessCommander.GetBillSurplusTonnage(var nData:string):boolean;
var nStr,nCusID: string;
    nVal,nCredit,nPrice: Double;
    nStockNo:string;
begin
  nCusID := '';
  nStockNo := '';
  nPrice := 1;
  nCredit := 0;
  nVal := 0;
  Result := False;
  nCusID := Fin.FData;
  if nCusID='' then Exit;  
  //未传递客户号

  nStockNo := Fin.FExtParam;
  if nStockNo='' then Exit;
  //未传递产品编号

  //产品销售价格表擦查询单价
  nStr := 'select p_price from %s where P_StockNo=''%s'' order by P_Date desc';
  //nStr := Format(nStr, [sTable_SPrice, nStockNo]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '未设单价，查询失败!';
      Exit;
    end;
    nPrice := FieldByName('p_price').AsFloat;
    if Float2PInt(nPrice, 100000, False)<=0 then
    begin
      nData := '单价设置不正确，查询失败!';
      Exit;    
    end;
  end;

  //调用GetCustomerValidMoney查询可用金额
  Result := GetCustomerValidMoney(nData);
  if not Result then Exit;
  nVal := StrToFloat(FOut.FData);
  if Float2PInt(nVal, cPrecision, False)<=0 then
  begin
    nData := '编号为[ %s ]的客户账户可用金额不足.';
    nData := Format(nData, [nCusID]);
    Exit;
  end;
  FOut.FData := FormatFloat('0.0000',nVal/nPrice);
  Result := True;  
end;

//获取订单信息，用于网上下单
function TWorkerBusinessCommander.GetOrderInfo(var nData:string):Boolean;
var nList: TStrings;
    nOut: TWorkerBusinessCommand;
    nCard,nParam:string;
    nLoginAccount,nLoginCusId,nOrderCusId:string;
    nSql:string;
    nDataSet:TDataSet;
    nOrderValid:Boolean;
begin
  nCard := fin.FData;
  nLoginAccount := FIn.FExtParam;
  nParam := sFlag_LoadExtInfo;
  Result := CallMe(cBC_ReadYTCard, nCard, '', @nOut);
  if not Result then
  begin
    nCard := nOut.FBase.FErrDesc;
    Exit;
  end;
  nList := TStringList.Create;
  try
    nList.Text := PackerDecodeStr(nOut.FData);
    nCard := nList[0];
    //cBC_ReadYTCard读取指令允许读取多条,取第一条
  finally
    nList.Free;
  end;

  Result := CallMe(cBC_VerifyYTCard, nCard, nParam, @nOut);
  if not Result then
  begin
    nCard := nOut.FBase.FErrDesc;
  end;
  FOut.FData := nCard;

  //------防伪校验begin-------
  nList := TStringList.Create;
  try
    nList.Text := PackerDecodeStr(nCard);
    nOrderCusId := nList.Values['XCB_Client'];
  finally
    nList.Free;
  end;

  nSql := 'select i_itemid from %s where i_group=''%s'' and i_item=''%s'' and i_info=''%s''';
  nSql := Format(nSql,[sTable_ExtInfo,sFlag_CustomerItem,'手机',nLoginAccount]);

  nDataSet := gDBConnManager.WorkerQuery(FDBConn, nSql);
  //未找到注册的手机号
  if nDataSet.RecordCount<1 then
  begin
    nData := '未找到注册的手机号码';
    nout.FBase.FErrDesc := nData;  
    Result := False;
    Exit;
  end;

  nOrderValid := False;
    
  while not nDataSet.Eof do
  begin
    nLoginCusId := nDataSet.FieldByName('i_itemid').AsString;
    if nLoginCusId=nOrderCusId then
    begin
      nOrderValid := True;
      Break;
    end;
    nDataSet.Next;
  end;

  if not nOrderValid then
  begin
    nData := '请勿冒用其他客户的订单号.';
    nout.FBase.FErrDesc := nData;  
    Result := False;
    Exit;  
  end;
  //------防伪校验end-------
end;

//获取订单列表，用于网上下单
function TWorkerBusinessCommander.GetOrderList(var nData:string):Boolean;
var
  nCusId,nStr:string;
  nWorker: PDBWorker;
  nFactRemain:Double;
  i:Integer;
begin
  Result := False;
  nCusId := Trim(fin.FData);
  if nCusId='' then Exit;
  nStr := 'select XCB_ID,' +                      //内部编号
        '  XCB_CardId,' +                       //销售卡片编号
        '  XCB_Origin,' +                       //卡片来源
        '  XCB_BillID,' +                       //来源单据号
        '  XCB_SetDate,' +                      //办理日期
        '  XCB_CardType,' +                     //卡片类型
        '  XCB_SourceType,' +                   //来源类型
        '  XCB_Option,' +                       //控制方式:0,控单价;1,控数量
        '  XCB_Client,' +                       //客户编号
        '  xob.XOB_Name as XCB_ClientName,' +   //客户名称
        '  xgd.XOB_Name as XCB_WorkAddr,' +     //工程工地
        '  XCB_Alias,' +                        //客户别名
        '  XCB_OperMan,' +                      //业务员
        '  XCB_Area,' +                         //销售区域
        '  XCB_CementType as XCB_Cement,' +     //品种编号
        '  PCM_Name as XCB_CementName,' +       //品种名称
        '  XCB_LadeType,' +                     //提货方式
        '  XCB_Number,' +                       //初始数量
        '  XCB_FactNum,' +                      //已开数量
        '  XCB_PreNum,' +                       //原已提量
        '  XCB_ReturnNum,' +                    //退货数量
        '  XCB_OutNum,' +                       //转出数量
        '  XCB_RemainNum,' +                    //剩余数量
        '  XCB_ValidS,XCB_ValidE,' +            //提货有效期
        '  XCB_AuditState,' +                   //审核状态
        '  XCB_Status,' +                       //卡片状态:0,停用;1,启用;2,冲红;3,作废
        '  XCB_IsImputed,' +                    //卡片是否估算
        '  XCB_IsOnly,' +                       //是否一车一票
        '  XCB_Del,' +                          //删除标记:0,正常;1,删除
        '  XCB_Creator,' +                      //创建人
        '  pub.pub_name as XCB_CreatorNM,' +    //创建人名
        '  XCB_CDate,' +                        //创建时间
        '  XCB_Firm,' +                         //所属厂区
        '  pbf.pbf_name as XCB_FirmName,' +     //工厂名称
        '  pcb.pcb_id, pcb.pcb_name, ' +        //销售片区
        '  xcg.xob_id as XCB_TransID, ' +       //运输单位编号
        '  xcg.XOB_Name as XCB_TransName ' +    //运输单位
        'from XS_Card_Base xcb' +
        '  left join XS_Compy_Base xob on xob.XOB_ID = xcb.XCB_Client' +
        '  left join XS_Compy_Base xgd on xgd.XOB_ID = xcb.xcb_sublader' +
        '  left join PB_Code_Material pcm on pcm.PCM_ID = xcb.XCB_CementType' +
        '  Left Join pb_code_block pcb On pcb.pcb_id=xob.xob_block' +
        '  Left Join pb_basic_firm pbf On pbf.pbf_id=xcb.xcb_firm' +
        '  Left Join PB_USER_BASE pub on pub.pub_id=xcb.xcb_creator ' +
        '  Left Join XS_Card_Freight xcf on xcf.Xcf_Card=xcb.xcb_ID ' +
        '  Left Join XS_Compy_Base xcg on xcg.xob_id=xcf.xcf_tran ' +
        //未删除、可用数量大于0、卡片启用并且处于已审核状态
        ' where xcb.xcb_del=''0'''
              +' and xcb.XCB_Status=''1'''
              +' and xcb.XCB_RemainNum>0.001'
              +' and xcb.XCB_AuditState=''201'''
              +' and xcb.XCB_Client = ''%s''';
  nStr := Format(nStr,[nCusId]);

  nWorker := nil;

  try
    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_YT) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('未查询到客户编号[ %s ]对应的订单信息.', [nCusId]);
        Exit;
      end;

      FListA.Clear;
      FListB.Clear;
      First;

      while not Eof do
      begin
        FListB.Values['XCB_ID']         := FieldByName('XCB_ID').AsString;
        FListB.Values['XCB_CardId']     := FieldByName('XCB_CardId').AsString;
        FListB.Values['XCB_Origin']     := FieldByName('XCB_Origin').AsString;
        FListB.Values['XCB_BillID']     := FieldByName('XCB_BillID').AsString;
        FListB.Values['XCB_SetDate']    := Date2Str(FieldByName('XCB_SetDate').AsDateTime,True);
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
        FListB.Values['XCB_RemainNum']  := FloatToStr(FieldByName('XCB_RemainNum').AsFloat);
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

        FListA.Add(PackerEncodeStr(FListB.Text));
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  //begin查询补货//查询剩余量
  for i := FListA.Count-1 downto 0 do
  begin
    FListB.Text := PackerDecodeStr(FListA.Strings[i]);
    nStr := 'select XCB_FactRemain from V_CARD_BASE t where XCB_ID=''%s'' and XCB_FactRemain>0.001';
    nStr := Format(nStr,[FListB.Values['XCB_ID']]);
    nWorker := nil;
    try
      with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_YT) do
      begin
        if RecordCount < 1 then
        begin
          FListA.Delete(i);
          Continue;
        end;
        FListB.Values['XCB_RemainNum'] := FieldByName('XCB_FactRemain').AsString;
        FListA.Strings[i] := PackerEncodeStr(FListB.Text);
      end;
    finally
      gDBConnManager.ReleaseConnection(nWorker);
    end;
  end;
  //end查询补货//查询剩余量

  if FListA.Count < 1 then
  begin
    nData := Format('未查询到客户编号[ %s ]对应的订单信息.', [nCusId]);
    Exit;
  end;

  FOut.FData := PackerEncodeStr(FListA.Text);
  Result := True;
end;

//获取采购合同列表，用于网上下单
function TWorkerBusinessCommander.GetPurchaseContractList(var nData:string):Boolean;
var
  nProvId:string;
  nWorker:PDBWorker;
  nStr:string;
begin
  Result := False;
  nProvId := Trim(fin.FData);
  if nProvId='' then Exit;
  nStr := 'select * from %s where provider_code=''%s'' and con_status>0 and con_quantity-con_finished_quantity>0.00001';
  nStr := format(nStr,[sTable_PurchaseContract,nProvId]);

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('未查询到供应商[ %s ]对应的订单信息.', [nProvId]);
        Exit;
      end;

      FListA.Clear;
      FListB.Clear;
      First;
      while not Eof do
      begin
        FListB.Values['pcId'] := FieldByName('pcId').AsString;
        FListB.Values['provider_code'] := FieldByName('provider_code').AsString;
        FListB.Values['provider_name'] := FieldByName('provider_name').AsString;
        FListB.Values['con_code'] := FieldByName('con_code').AsString;
        FListB.Values['con_materiel_Code'] := FieldByName('con_materiel_Code').AsString;
        FListB.Values['con_materiel_name'] := FieldByName('con_materiel_name').AsString;
        FListB.Values['con_price'] := FieldByName('con_price').AsString;
        FListB.Values['con_quantity'] := FieldByName('con_quantity').AsString;
        FListB.Values['con_finished_quantity'] := FieldByName('con_finished_quantity').AsString;
        FListB.Values['con_date'] := FieldByName('con_date').AsString;
        FListB.Values['con_remark'] := FieldByName('con_remark').AsString;
        FListA.Add(PackerEncodeStr(FListB.Text));
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
  FOut.FData := PackerEncodeStr(FListA.Text);
  Result := True;
end;

//获取客户注册信息
function TWorkerBusinessCommander.getCustomerInfo(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_getCustomerInfo,fin.FData);
    nData := fin.FData;
    FOut.FData := fin.FData;
  finally
    frmCall.Free;
  end;
end;

//客户与微信账号绑定
function TWorkerBusinessCommander.get_Bindfunc(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_get_Bindfunc,fin.FData);
    FOut.FData := 'Y';
  finally
    frmCall.Free;
  end;
end;

//发送消息
function TWorkerBusinessCommander.send_event_msg(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_send_event_msg,fin.FData);
    FOut.FData := 'Y';
  finally
    frmCall.Free;
  end;
end;

//新增商城用户
function TWorkerBusinessCommander.edit_shopclients(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_edit_shopclients,fin.FData);
    FOut.FData := 'Y';
  finally
    frmCall.Free;
  end;
end;

//添加商品
function TWorkerBusinessCommander.edit_shopgoods(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_edit_shopgoods,fin.FData);
  finally
    frmCall.Free;
  end;
end;

//获取订单信息
function TWorkerBusinessCommander.get_shoporders(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_get_shoporders,fin.FData);
    nData := fin.FData;
    FOut.FData := fin.FData;
  finally
    frmCall.Free;
  end;
end;

//根据订单号获取订单信息
function TWorkerBusinessCommander.get_shoporderbyno(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_get_shoporderbyNO,fin.FData);
    nData := fin.FData;
    FOut.FData := fin.FData;
  finally
    frmCall.Free;
  end;
end;

//修改订单状态
function TWorkerBusinessCommander.complete_shoporders(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_complete_shoporders,fin.FData);
    FOut.FData := 'Y';
  finally
    frmCall.Free;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/13
//Parm:
//Desc: 同步云天系统运输单位信息
function TWorkerBusinessCommander.SyncRemoteTransit(var nData: string): Boolean;
var nStr,nSaler: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  FListB.Clear;
  nStr := 'Select T_ID From S_Translator';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
  begin
    First;

    while not Eof do
    begin
      if Fields[0].AsString<>'' then FListB.Add(Fields[0].AsString);

      Next;
    end;  
  end;

  nDBWorker := nil;
  try
    nSaler := '待分配业务员';
    nStr := 'Select XOB_ID,XOB_Code,XOB_Name,XOB_JianPin,XOB_Status ' +
            'From XS_Compy_Base ' +
            'Where XOB_IsTransit=''1''';
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        if FieldByName('XOB_ID').AsString = '' then Continue;
        //invalid

        if FieldByName('XOB_Status').AsString = '1' then
        begin  //Add
          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          Continue;
          //Has Saved

          nStr := MakeSQLByStr([SF('T_ID', FieldByName('XOB_ID').AsString),
                  SF('T_Name', FieldByName('XOB_Name').AsString),
                  SF('T_PY', GetPinYinOfStr(FieldByName('XOB_Name').AsString)),
                  SF('T_Memo', FieldByName('XOB_Code').AsString),
                  SF('T_Saler', nSaler)
                  ], sTable_Translator, '', True);
          //xxxxx

          FListA.Add(nStr);

        end else
        begin  //valid
          nStr := 'Delete From %s Where T_ID=''%s''';
          nStr := Format(nStr, [sTable_Translator, FieldByName('XOB_ID').AsString]);
          //xxxxx

          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          FListA.Add(nStr);
          //Has Saved
        end;
      finally
        Next;
      end;
    end;

    if FListA.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;
      //开启事务

      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2015-09-16
//Parm: 表名;数据链路
//Desc: 生成nTable的唯一记录号
function YT_NewID(const nTable: string; const nWorker: PDBWorker): string;
begin
  with nWorker.FExec do
  begin
    Close;
    SQL.Text := '{call GetID(?,?)}';

    Parameters.Clear;
    Parameters.CreateParameter('P1', ftString , pdInput, Length(nTable), nTable);
    Parameters.CreateParameter('P2', ftString, pdOutput, 20, '') ;
    ExecSQL;

    Result := Parameters.ParamByName('P2').Value;
  end;
end;

//Date: 2015/11/3
//Parm: 数据链路
//Desc: 获取云天系统班次区分
function YT_GetSpell(const nWorker: PDBWorker): string;
var nBegin, nEnd, nNow: TDateTime;
begin
  Result := '';
  //init

  nNow := Time;
  with nWorker.FExec do
  begin
    Close;
    SQL.Text := 'select * from PB_Code_Spell';
    Open;

    if RecordCount<=0 then  Exit;

    First;
    while not Eof do
    try
      nBegin := FieldByName('PCP_BEGINTIME').AsDateTime;
      nEnd   := FieldByName('PCP_ENDTIME').AsDateTime;

      if nBegin>nEnd then nEnd := nEnd + 1;

      if nBegin>nNow then Continue;
      //当前时间小于开始时间

      if nEnd < nNow then Continue;
      //结束时间大于开始时间

      Result := FieldByName('PCP_ID').AsString;
      Exit;
    finally
      Next;
    end;
  end;
end;

//Date: 2015-11-03
//Parm: 数据库语句；数据链路
//Desc: 生成插入事物表语句
function YT_NewInsertLog(const nSQL: string; const nWorker: PDBWorker): string;
var nStr, nSQLTmp, nPltID: string;
begin
  Result := '';
  //init

  nPltID := YT_NewID('PB_LOG_TRANSACTION', nWorker);
  nStr := MakeSQLByStr([SF('PLT_ID', nPltID),
          SF('PLT_Status', '0')
          ], 'PB_Log_Transaction', '', True);
  Result := Result + nStr + ';';
  //同步事务表

  nSQLTmp := StringReplace(nSQL, '''', '''''', [rfReplaceAll, rfIgnoreCase]);
  nStr := MakeSQLByStr([SF('PLS_TRANSACTION', nPltID),
          SF('PLS_ORDER', 0),
          SF('PLS_SQL', nSQLTmp)
          ], 'PB_Log_Sql', '', True);
  Result := Result + nStr + ';';
  //同步事务执行语句表
end;

//Date: 2017/2/21
//Parm: 单据类型[nKind];表主键[nTableID];操作类型[nHandleType]
//Desc: 插入异步同步信息
function YT_NewInsertSyncLog(const nKind, nTableID, nHandleType: string;
  const nWorker: PDBWorker): string;
var nSQL, nPdlID: string;
begin
  Result := '';
  //init

  nPdlID := YT_NewID('PB_DATA_SYNCLOG', nWorker);
  nSQL := MakeSQLByStr([SF('PDL_ID', nPdlID),
          SF('PDL_Type', '101'),               //工厂数据
          SF('PDL_Kind', nKind),
          SF('PDL_Bill', nTableID),
          SF('PDL_IsSync', '0', sfVal),
          SF('PDL_HandleType', nHandleType),
          SF('PDL_HandleTime', DateTime2StrOracle(Now), sfVal)
          ], 'PB_Data_SyncLog', '', True);
  Result := Result + nSQL + ';';
end;

//------------------------------------------------------------------------------
//Date: 2015/9/26
//Parm:
//Desc: 转OracleDateTime
function DateTime2StrOracle(const nDT: TDateTime): string;
var nStr :string;
begin
  nStr := 'to_date(''%s'', ''yyyy-mm-dd hh24-mi-ss'')';
  Result := Format(nStr, [DateTime2Str(nDT)]);
end;

function Date2StrOracle(const nDT: TDateTime): string;
var nStr :string;
begin
  nStr := 'to_date(''%s'', ''yyyy-mm-dd'')';
  Result := Format(nStr, [Date2Str(nDT)]);
end;

//Date: 2015-09-16
//Parm: 交货单(多个)[FIn.FData]
//Desc: 同步交货单发货数据到云天发货表中
function TWorkerBusinessCommander.SyncYT_Sale(var nData: string): Boolean;
var nIdx: Integer;
    nDS: TDataSet;
    nWorker: PDBWorker;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    nDateMin, nSetDate: TDateTime;
    nStr,nSQL,nPID,nSpell, nFreID, nFreType: string;
    nVal,nFreVal, nFrePrice: Double;
begin
  Result := False;
  FListA.Text := FIn.FData;
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);

  nSQL := 'Select bill.*, plog.P_ID, ' +         //提货单信息
          'bcreater.U_Memo As bCreaterID, ' +    //云天开票员编号
          'pcreater.U_Memo As pCreaterID, ' +    //云天过皮司磅员
          'mcreater.U_Memo As mCreaterID  ' +    //云天过毛司磅员
          ' From $BILL bill ' +
          ' Left Join $USER bcreater On bcreater.U_Name=bill.L_Man ' +
          ' Left Join $USER pcreater On pcreater.U_Name=bill.L_PMan ' +
          ' Left Join $USER mcreater On mcreater.U_Name=bill.L_MMan ' +
          ' Left Join $PLOG plog On plog.P_Bill=bill.L_ID ' +
          'Where L_ID In ($IN)';
  nSQL := MacroValue(nSQL, [MI('$BILL', sTable_Bill), MI('$USER', sTable_User),
          MI('$PLOG', sTable_PoundLog), MI('$IN', nStr)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '发货单[ %s ]信息已丢失.';
      nData := Format(nData, [CombinStr(FListA, ',', False)]);
      Exit;
    end;

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    SetLength(nBills, RecordCount);
    nIdx := 0;

    FListA.Clear;
    First;

    while not Eof do
    begin
      with nBills[nIdx] do
      begin
        FID         := FieldByName('L_ID').AsString;
        FZhiKa      := FieldByName('L_ZhiKa').AsString;
        FCusID      := FieldByName('L_CusID').AsString;
        FCard       := '0';
        //默认非一车一票

        FSeal       := FieldByName('L_Seal').AsString;
        FHYDan      := FieldByName('L_HYDan').AsString;

        FTruck      := FieldByName('L_Truck').AsString;
        FStockNo    := FieldByName('L_StockNo').AsString;
        FValue      := FieldByName('L_Value').AsFloat;
        FYSValid    := FieldByName('L_IsEmpty').AsString;

        if FListA.IndexOf(FZhiKa) < 0 then
          FListA.Add(FZhiKa);
        //订单项

        FPoundID := FieldByName('P_ID').AsString;
        //榜单编号
        if FPoundID = '' then
        begin
          if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
            raise Exception.Create(nOut.FData);
          FPoundID := nOut.FData;
        end;

        nDateMin := Str2Date('2000-01-01');
        //最小日期参考

        with FPData do
        begin
          FValue    := FieldByName('L_PValue').AsFloat;
          FDate     := FieldByName('L_PDate').AsDateTime;
          FOperator := FieldByName('pCreaterID').AsString;

          if FOperator = '' then
            FOperator := FieldByName('L_PMan').AsString;
          //xxxx

          if FDate < nDateMin then
            FDate := FieldByName('L_Date').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;

        with FMData do
        begin
          FValue    := FieldByName('L_MValue').AsFloat;
          FDate     := FieldByName('L_MDate').AsDateTime;
          FOperator := FieldByName('mCreaterID').AsString;

          if FOperator = '' then
            FOperator := FieldByName('L_MMan').AsString;
          //xxxx

          if FDate < nDateMin then
            FDate := FieldByName('L_OutFact').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;

        FYTID := FieldByName('L_YTID').AsString;
        FMemo := FieldByName('L_Memo').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);
  //订单列表

  nSQL := 'select * From %s Where XCB_ID in (%s)';
  nSQL := Format(nSQL, ['XS_Card_Base', nStr]);
  //查询订单表

  nWorker := nil;
  try
    nDS := gDBConnManager.SQLQuery(nSQL, nWorker, sFlag_DB_YT);
    with nDS do
    begin
      if RecordCount < 1 then
      begin
        nData := '云天系统: 发货单[ %s ]信息已丢失.';
        nData := Format(nData, [CombinStr(FListA, ',', False)]);
        Exit;
      end;

      FListA.Clear;
      FListA.Add('begin');
      //init sql list

      for nIdx:=Low(nBills) to High(nBills) do
      begin
        First;
        //init cursor

        if nBills[nIdx].FValue<=0 then Continue;
        //发货量为0

        if nBills[nIdx].FYSValid = sFlag_Yes then Continue;
        //空车出厂

        while not Eof do
        begin
          nStr := FieldByName('XCB_ID').AsString;
          if nStr = nBills[nIdx].FZhiKa then Break;
          Next;
        end;

        if Eof then Continue;
        //订单丢失则不予处理

        nSetDate := nBills[nIdx].FMData.FDate;
        //nSetDate

        if nBills[nIdx].FYTID = '' then
        begin
          nBills[nIdx].FYTID := YT_NewID('XS_LADE_BASE', nWorker);
          //记录编号

          nSQL := MakeSQLByStr([SF('XLB_ID', nBills[nIdx].FYTID),
                  SF('XLB_LadeId', nBills[nIdx].FID),
                  SF('XLB_SetDate', Date2StrOracle(nSetDate), sfVal),
                  SF('XLB_LadeType', '103'),
                  SF('XLB_Origin', '101'),
                  SF('XLB_Client', nBills[nIdx].FCusID),
                  SF('XLB_Cement', nBills[nIdx].FStockNo),
                  SF('XLB_CementSwap', nBills[nIdx].FStockNo),
                  SF('XLB_Number', nBills[nIdx].FValue, sfVal),

                  SF('XLB_Price', '0.00', sfVal),
                  SF('XLB_CardPrice', '0.00', sfVal),
                  SF('XLB_Total', '0.00', sfVal),
                  SF('XLB_FactTotal', '0.00', sfVal),
                  SF('XLB_ScaleDifNum', '0.00', sfVal),
                  SF('XLB_InvoNum', '0.00', sfVal),

                  SF('XLB_SendArea', FieldByName('XCB_SubLader').AsString),
                  SF('XLB_CarCode', nBills[nIdx].FTruck),
                  SF('XLB_Quantity', '0', sfVal),
                  SF('XLB_PrintNum', '0', sfVal),
                  SF('XLB_IsCarry', '0'),
                  SF('XLB_IsOut', '0'),
                  SF('XLB_IsCheck', '1'),
                  SF('XLB_IsDoor', '0'),
                  SF('XLB_IsBack', '0'),
                  SF('XLB_IsInvo', '0'),
                  SF('XLB_Approve', '0'),
                  SF('XLB_TCollate', '0'),
                  SF('XLB_Collate', '0'),
                  SF('XLB_OutStore', '0'),
                  SF('XLB_ISTUNE', '0'),

                  SF('XLB_Firm', FieldByName('XCB_Firm').AsString),
                  SF('XLB_Status', '1'),
                  SF('XLB_Del', '0'),
                  SF('XLB_Creator', nBills[nIdx].FMData.FOperator),
                  SF('XLB_CDate', DateTime2StrOracle(nSetDate), sfVal),
                  SF('XLB_PROID', FieldByName('XCB_SubLader').AsString),
                  SF('XLB_KDATE', DateTime2StrOracle(nSetDate), sfVal),
                  SF('XLB_ISONLY', FieldByName('XCB_ISONLY').AsString),
                  SF('XLB_ISSUPPLY', '0')
                  ], 'XS_Lade_Base', '', True);
          FListA.Add(nSQL + ';'); //销售提货单表

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //插入同步事物表

          nSQL := YT_NewInsertSyncLog('A004', nBills[nIdx].FYTID, '101', nWorker);
          FListA.Add(nSQL);
          //插入集团同步业务表

          nSQL := MakeSQLByStr([SF('XLD_ID', YT_NewID('XS_LADE_DETAIL', nWorker)),
                  SF('XLD_Lade', nBills[nIdx].FYTID),
                  SF('XLD_Client', nBills[nIdx].FCusID),
                  SF('XLD_Card',  nBills[nIdx].FZhiKa),
                  SF('XLD_Number', nBills[nIdx].FValue, sfVal),
                  SF('XLD_Gap', '0', sfVal),
                  SF('XLD_PROID', FieldByName('XCB_SubLader').AsString),
                  SF('XLD_Order', '0', sfVal)
                  ], 'XS_Lade_Detail', '', True);
          FListA.Add(nSQL + ';'); //销售提货单明细表

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //插入同步事物表

          nSQL := SF('L_ID', nBills[nIdx].FID);
          nSQL := MakeSQLByStr([
                  SF('L_YTID', nBills[nIdx].FYTID)
                  ],sTable_Bill, nSQL, False);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;

        //nRID := YT_NewID('XS_LADE_BASE', nWorker);
        //记录编号

        nSQL := MakeSQLByStr([
                SF('XLB_CementCode', nBills[nIdx].FHYDan),
                SF('XLB_FactNum', nBills[nIdx].FValue, sfVal),
                SF('XLB_Remark', nBills[nIdx].FMemo),

                SF('XLB_Area', FieldByName('XCB_Area').AsString),
                {$IFDEF ADDRETURN}
                SF('XLB_Return', FieldByName('XCB_Return').AsString),
                {$ENDIF}

                SF('XLB_OutTime', DateTime2StrOracle(nSetDate), sfVal),
                SF('XLB_DoorTime', DateTime2StrOracle(nSetDate), sfVal),
                SF('XLB_IsCarry', '1'),
                SF('XLB_IsOut', '1'),
                SF('XLB_IsCheck', '0'),
                SF('XLB_IsDoor', '1'),
                SF('XLB_Gather', '1')
                ], 'XS_Lade_Base', SF('XLB_ID', nBills[nIdx].FYTID), False);
        FListA.Add(nSQL + ';'); //销售提货单表

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //插入同步事物表

        nSQL := YT_NewInsertSyncLog('A004', nBills[nIdx].FYTID, '102', nWorker);
        FListA.Add(nSQL);
        //插入集团同步业务表

        nBills[nIdx].FPrice := FieldByName('XCB_Price').AsFloat;
        nVal := nBills[nIdx].FPrice * nBills[nIdx].FValue;
        nVal := Float2Float(nVal, cPrecision, True);
        //价格

        nSQL := MakeSQLByStr([
                SF('XLD_Client', nBills[nIdx].FCusID),
                SF('XLD_Card',  nBills[nIdx].FZhiKa),
                SF('XLD_Number', nBills[nIdx].FValue, sfVal),
                SF('XLD_Price', nBills[nIdx].FPrice, sfVal),
                SF('XLD_CardPrice', nBills[nIdx].FPrice, sfVal),
                SF('XLD_Gap', '0', sfVal),
                SF('XLD_Total', nVal, sfVal),
                SF('XLD_PROID', FieldByName('XCB_SubLader').AsString),
                SF('XLD_Order', '0', sfVal),
                SF('XLD_FactNum', '0', sfVal),
                SF('XLD_GWeight', nBills[nIdx].FMData.FValue, sfVal),
                SF('XLD_TWeight', nBills[nIdx].FPData.FValue, sfVal),
                SF('XLD_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                   nBills[nIdx].FPData.FValue, cPrecision, True), sfVal)
                ], 'XS_Lade_Detail', SF('XLD_Lade', nBills[nIdx].FYTID), False);
        FListA.Add(nSQL + ';'); //销售提货单明细表

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //插入同步事物表

        nPID := YT_NewID('DB_TURN_PRODUOUT', nWorker);
        nSQL := MakeSQLByStr([SF('DTP_ID', nPID),
                SF('DTP_Card', nBills[nIdx].FZhiKa),
                SF('DTP_ScaleBill', nBills[nIdx].FID),
                SF('DTP_Origin',  '101'),

                SF('DTP_Vehicle', nBills[nIdx].FTruck),
                SF('DTP_OutDate', Date2StrOracle(nSetDate), sfVal),
                SF('DTP_Material', nBills[nIdx].FStockNo),
                SF('DTP_CementCode', nBills[nIdx].FHYDan),
                SF('DTP_Lade', nBills[nIdx].FYTID),

                SF('DTP_Scale',  nBills[nIdx].FPData.FStation),
                SF('DTP_Creator', nBills[nIdx].FPData.FOperator),
                SF('DTP_CDate', DateTime2StrOracle(nBills[nIdx].FPData.FDate),sfVal),
                SF('DTP_SecondScale',  nBills[nIdx].FMData.FStation),
                SF('DTP_GMan', nBills[nIdx].FMData.FOperator),
                SF('DTP_GDate', DateTime2StrOracle(nBills[nIdx].FMData.FDate),sfVal),

                SF('DTP_Firm', FieldByName('XCB_Firm').AsString),
                SF('DTP_GWeight', nBills[nIdx].FMData.FValue, sfVal),
                SF('DTP_TWeight', nBills[nIdx].FPData.FValue, sfVal),
                SF('DTP_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                   nBills[nIdx].FPData.FValue, cPrecision, True), sfVal),

                SF('DTP_ISBalance', '0'),
                SF('DTP_IsSupply', '0'),
                SF('DTP_Status', '1'),
                SF('DTP_Del', '0')
                ], 'DB_Turn_ProduOut', '', True);
        FListA.Add(nSQL + ';'); //水泥熟料出厂表

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //插入同步事物表

        nSQL := YT_NewInsertSyncLog('A010', nPID, '101', nWorker);
        FListA.Add(nSQL);
        //插入集团同步业务表

        nSQL := MakeSQLByStr([SF('DTU_ID', YT_NewID('DB_TURN_PRODUDTL', nWorker)),
                SF('DTU_Del', '0'),
                SF('DTU_PID', nPID),
                SF('DTU_LadeID', nBills[nIdx].FYTID),
                SF('DTU_Firm', FieldByName('XCB_Firm').AsString),
                SF('DTU_GWeight', nBills[nIdx].FMData.FValue, sfVal),
                SF('DTU_TWeight', nBills[nIdx].FPData.FValue, sfVal),
                SF('DTU_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                   nBills[nIdx].FPData.FValue, cPrecision, True), sfVal)
                ], 'DB_Turn_ProduDtl', '', True);
        FListA.Add(nSQL + ';'); //水泥熟料出厂明细表

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //插入同步事物表

        nSpell := YT_GetSpell(nWorker);
        nSQL := MakeSQLByStr([SF('XLO_Lade', nBills[nIdx].FYTID),
                SF('XLO_SetDate', DateTime2StrOracle(nSetDate), sfVal),
                SF('XLO_Creator', 'zx-delivery'),
                SF('XLO_CDate', DateTime2StrOracle(nSetDate), sfVal),
                SF('XLO_FIRM', FieldByName('XCB_Firm').AsString),
                SF('XLO_SPELL', nSpell),
                SF('XLO_ISCANDEL', '0')
                ], 'XS_Lade_OutDoor', '', True);
        FListA.Add(nSQL + ';'); //提货单出门登记表

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //插入同步事物表

        nSQL := 'Update %s Set XCB_FactNum=XCB_FactNum+(%.2f),' +
                'XCB_RemainNum=XCB_RemainNum-(%.2f) Where XCB_ID=''%s''';
        nSQL := Format(nSQL, ['XS_Card_Base', nBills[nIdx].FValue,
                nBills[nIdx].FValue, nBills[nIdx].FZhiKa]);
        FListA.Add(nSQL + ';'); //更新订单

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //插入同步事物表

        nSQL := YT_NewInsertSyncLog('A001', nBills[nIdx].FZhiKa, '102', nWorker);
        FListA.Add(nSQL);
        //插入集团同步业务表

        nBills[nIdx].FCard := FieldByName('XCB_IsOnly').AsString;
        //是否一车一票

        if nBills[nIdx].FSeal <> '' then
        begin
          nStr := YT_NewID('XS_LADE_CEMENTCODE', nWorker);
          //id

          nSQL := MakeSQLByStr([SF('XLM_ID', nStr),
                  SF('XLM_LADE', nBills[nIdx].FYTID),
                  SF('XLM_CEMENTCODE', nBills[nIdx].FSeal),
                  SF('XLM_NUMBER', nBills[nIdx].FValue, sfVal)
                  ], 'XS_Lade_CementCode', '', True);
          FListA.Add(nSQL + ';'); //更新批次号使用量

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //插入同步事物表
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FCard = '1' then //如果是一车一票
    begin
      nVal := nBills[nIdx].FPrice * nBills[nIdx].FValue;
      nVal := Float2Float(nVal, cPrecision, True);
      //水泥金额

      nSQL := MakeSQLByStr([
              SF('XCB_Number', nBills[nIdx].FValue, sfVal),
              SF('XCB_TotalSum', nVal, sfVal),
              SF('XCB_ToTal', nVal, sfVal),
              SF('XCB_IsCanAudit', '1')
              ], 'XS_Card_Base', SF('XCB_ID', nBills[nIdx].FZhiKa), False);
      FListA.Add(nSQL + ';'); //销售提货单表:开单量,总金额,水泥金额,状态

      nSQL := YT_NewInsertLog(nSQL+';', nWorker);
      FListA.Add(nSQL);
      //插入同步事物表

      nSQL := YT_NewInsertSyncLog('A001', nBills[nIdx].FZhiKa, '102', nWorker);
      FListA.Add(nSQL);
      //插入集团同步业务表

      nSQL := 'Update %s Set XRC_Total=%.2f Where XRC_BillID=''%s'' ' +
              'And XRC_Origin=''101'' And XRC_FreType=''999''';
      nSQL := Format(nSQL, ['XS_Rece_Receivable', nVal,
              nBills[nIdx].FZhiKa]);
      FListA.Add(nSQL + ';'); //销售应收款表:水泥金额

      nSQL := YT_NewInsertLog(nSQL+';', nWorker);
      FListA.Add(nSQL);
      //插入同步事物表

      nSQL  := 'Select * From %s Where XCF_Card=''%s''';
      nSQL  := Format(nSQL, ['XS_Card_Freight', nBills[nIdx].FZhiKa]);

      with gDBConnManager.WorkerQuery(nWorker, nSQL) do
      begin
        First;

        while not Eof do
        try
          nFreID := FieldByName('XCF_ID').AsString;
          nFreType := FieldByName('XCF_Type').AsString;
          nFrePrice := FieldByName('XCF_Price').AsFloat;

          nFreVal := nFrePrice * nBills[nIdx].FValue;
          nFreVal := Float2Float(nFreVal, cPrecision, True);
          //运费金额

          nSQL := 'Update %s Set XRC_Total=%.2f Where XRC_BillID=''%s'' ' +
                  'And XRC_Origin=''101'' And XRC_FreType=''%s''';
          nSQL := Format(nSQL, ['XS_Rece_Receivable', nFreVal,
                  nBills[nIdx].FZhiKa, nFreType]);
          FListA.Add(nSQL + ';'); //销售应收款表:运费金额

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //插入同步事物表

          nSQL := 'Update %s Set XCB_TotalSum=XCB_TotalSum+(%.2f) ' +
                  'Where XCB_ID=''%s''';
          nSQL := Format(nSQL, ['XS_Card_Base', nFreVal, nBills[nIdx].FZhiKa]);
          FListA.Add(nSQL + ';'); //销售提货单表:总金额

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //插入同步事物表

          nSQL := YT_NewInsertSyncLog('A001', nBills[nIdx].FZhiKa, '102', nWorker);
          FListA.Add(nSQL);
          //插入集团同步业务表

          nSQL := 'Update %s Set XCF_Total=%.2f Where XCF_ID=''%s''';
          nSQL := Format(nSQL, ['XS_Card_Freight', nFreVal,
                  nFreID]);
          FListA.Add(nSQL + ';'); //销售运费表

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //插入同步事物表
        finally
          Next;
        end;
      end;
    end;

    //nWorker.FConn.BeginTrans;
    try
      nStr := 'commit;' + #13#10 +
              'exception' + #13#10 +
              ' when others then rollback; raise;' + #13#10 +
              'end;';
      FListA.Add(nStr);
      //oracle需明确提交

      gDBConnManager.WorkerExec(nWorker, FListA.Text);
      //执行脚本

      //nWorker.FConn.CommitTrans;
      Result := True;
    except
      on E:Exception do
      begin
        //nWorker.FConn.RollbackTrans;
        nData := '同步云天数据时发生错误,描述: ' + E.Message;
        Exit;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2015-09-16
//Parm: 榜单号(单个)[FIn.FData]
//Desc: 同步原料过磅数据到云天采购表中
function TWorkerBusinessCommander.SyncYT_Provide(var nData: string): Boolean;
var nStr,nSQL,nRID: string;
    nIdx,nErrNum: Integer;
    nDateMin: TDateTime;
    nWorker: PDBWorker;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := FIn.FData;
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);

  nSQL := 'Select D_ID,D_OID,O_ProID,O_StockNo,O_Truck,' +
          'D_Value,D_KZValue,D_AKValue,D_YSResult,' +
          'D_PValue,D_PDate,D_PMan,' +
          'D_MValue,D_MDate,D_MMan,' +
          'D_InTime,D_OutFact,D_PID ' +
          'From %s ' +
          '  Left Join %s On D_OID=O_ID ' +
          'Where D_ID In (%s) ';
  nSQL := Format(nSQL, [sTable_OrderDtl, sTable_Order, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '采购入库单[ %s ]信息已丢失.';
      nData := Format(nData, [CombinStr(FListA, ',', False)]);
      Exit;
    end;

    if FieldByName('D_YSResult').AsString=sFlag_No then
    begin   //材料拒收，不回传信息
      Result := True;
      Exit;
    end;  

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    SetLength(nBills, RecordCount);
    nIdx := 0;

    FListA.Clear;
    First;

    while not Eof do
    begin
      with nBills[nIdx] do
      begin
        FID         := FieldByName('D_ID').AsString;
        FZhiKa      := FieldByName('D_OID').AsString;

        FCusID      := FieldByName('O_ProID').AsString;
        FTruck      := FieldByName('O_Truck').AsString;
        FStockNo    := FieldByName('O_StockNo').AsString;
        FValue      := FieldByName('D_Value').AsFloat;
        FKZValue    := FieldByName('D_KZValue').AsFloat;

        if FListA.IndexOf(FZhiKa) < 0 then
          FListA.Add(FZhiKa);
        //订单项

        FPoundID := FieldByName('D_PID').AsString;
        //榜单编号
        if FPoundID = '' then
        begin
          if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
            raise Exception.Create(nOut.FData);
          FPoundID := nOut.FData;
        end;

        nDateMin := Str2Date('2000-01-01');
        //最小日期参考

        with FPData do
        begin
          FValue    := FieldByName('D_PValue').AsFloat;
          FDate     := FieldByName('D_PDate').AsDateTime;
          FOperator := FieldByName('D_PMan').AsString;

          if FDate < nDateMin then
            FDate := FieldByName('D_InTime').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;

        with FMData do
        begin
          FValue    := FieldByName('D_MValue').AsFloat;
          FDate     := FieldByName('D_MDate').AsDateTime;
          FOperator := FieldByName('D_MMan').AsString;

          if FDate < nDateMin then
            FDate := FieldByName('D_OutFact').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  nWorker := nil;
  try
    nWorker := gDBConnManager.GetConnection(sFlag_DB_YT, nErrNum);

    if not Assigned(nWorker) then
    begin
      nStr := Format('连接[ %s ]数据库失败(ErrCode: %d).', [sFlag_DB_YT, nErrNum]);
      WriteLog(nStr);
      raise Exception.Create(nStr);
    end;

    if not nWorker.FConn.Connected then
      nWorker.FConn.Connected := True;
    //conn db

    FListA.Clear;
    FListA.Add('begin');
    //init sql list

    for nIdx:=Low(nBills) to High(nBills) do
    begin
      nRID := YT_NewID('DB_TURN_MATERIN', nWorker);
      //记录编号

      nSQL := MakeSQLByStr([SF('DTM_ID', nRID),
              SF('DTM_Card', nBills[nIdx].FZhiKa),
              SF('DTM_ScaleBill', nBills[nIdx].FID),

              SF('DTM_IsTBalance', '0'),
              SF('DTM_IsBalance', '0'),
              SF('DTM_IsStore', '0'),
              SF('DTM_Status', '1'),
              SF('DTM_Del', '0'),

              SF('DTM_Impur', '0'),
              SF('DTM_Corner', '0'),
              SF('DTM_Freight', '0'),
              SF('DTM_CGWeight', '0'),
              SF('DTM_CTWeight', '0'),
              SF('DTM_CNWeight', '0'),
              SF('DTM_PrintNum', '0'),
              {$IFDEF GZBZX}
              SF('DTM_COLTYPE', '102'),
              {$ENDIF}
              {$IFDEF GZBSZ}
              SF('DTM_COLTYPE', '103'),
              {$ENDIF}

              SF('DTM_IsPlan', '0'),
              SF('DTM_KeepNum', '0'),
              SF('DTM_OtherNum', '0'),
              SF('DTM_ColPrice', '0'),
              SF('DTM_ColTotal', '0'),
              SF('DTM_FundWeight', '0'),

              SF('DTM_Vehicle', nBills[nIdx].FTruck),

              SF('DTM_InDate', Date2StrOracle(nBills[nIdx].FMData.FDate), sfVal),
              SF('DTM_CDate', DateTime2StrOracle(nBills[nIdx].FPData.FDate),sfVal),
              SF('DTM_TDate', DateTime2StrOracle(nBills[nIdx].FMData.FDate),sfVal),
              SF('DTM_Material', nBills[nIdx].FStockNo),
              SF('DTM_Company', nBills[nIdx].FCusID),
              SF('DTM_FIRM', gSysParam.FProvFirm),
              SF('DTM_TYPE', '101'),

              SF('DTM_RWeight', nBills[nIdx].FKZValue, sfVal),
              SF('DTM_GWeight', nBills[nIdx].FMData.FValue, sfVal),
              SF('DTM_TWeight', nBills[nIdx].FPData.FValue, sfVal),
              SF('DTM_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                   nBills[nIdx].FPData.FValue-nBills[nIdx].FKZValue, cPrecision,
                   True), sfVal)
              ], 'DB_Turn_MaterIn', '', True);
      FListA.Add(nSQL + ';'); //材料进厂表

      nSQL := YT_NewInsertLog(nSQL + ';', nWorker);
      FListA.Add(nSQL);
    end;

    //nWorker.FConn.BeginTrans;
    try
      nStr := 'commit;' + #13#10 +
              'exception' + #13#10 +
              ' when others then rollback; raise;' + #13#10 +
              'end;';
      FListA.Add(nStr);
      //oracle需明确提交

     gDBConnManager.WorkerExec(nWorker, FListA.Text);
     //执行脚本

      //nWorker.FConn.CommitTrans;
      Result := True;
    except
      on E:Exception do
      begin
        //nWorker.FConn.RollbackTrans;
        nData := '同步云天数据时发生错误,描述: ' + E.Message;
        Exit;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/3/21
//Parm: 磅单号列表(FIn.FData)
//Desc: 同步供应订单到云天
function TWorkerBusinessCommander.SyncYT_ProvidePound(var nData: string): Boolean;
var nBills: TLadingBillItems;
    nStr,nSQL,nRID: string;
    nIdx,nErrNum: Integer;
    nWorker: PDBWorker;
begin
  Result := False;
  FListA.Text := FIn.FData;
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);

  nSQL := 'Select * From %s ' +
          'Where (P_ID In (%s) or P_Order In (%s)) And P_Type=''P''';
  nSQL := Format(nSQL, [sTable_PoundLog, nStr, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '采购磅单[ %s ]信息已丢失.';
      nData := Format(nData, [CombinStr(FListA, ',', False)]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    FListA.Clear;
    nIdx := 0;
    First;

    while not Eof do
    begin
      with nBills[nIdx] do
      begin
        FID         := FieldByName('P_ID').AsString;
        FZhiKa      := FieldByName('P_Order').AsString;

        FCusID      := FieldByName('P_CusID').AsString;
        FTruck      := FieldByName('P_Truck').AsString;
        FStockNo    := FieldByName('P_MID').AsString;
        FKZValue    := FieldByName('P_KZValue').AsFloat;

        with FPData do
        begin
          FValue    := FieldByName('P_PValue').AsFloat;
          FDate     := FieldByName('P_PDate').AsDateTime;
          FOperator := FieldByName('P_PMan').AsString;
        end;

        with FMData do
        begin
          FValue    := FieldByName('P_MValue').AsFloat;
          FDate     := FieldByName('P_MDate').AsDateTime;
          FOperator := FieldByName('P_MMan').AsString;
        end;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  nWorker := nil;
  try
    nWorker := gDBConnManager.GetConnection(sFlag_DB_YT, nErrNum);

    if not Assigned(nWorker) then
    begin
      nStr := Format('连接[ %s ]数据库失败(ErrCode: %d).', [sFlag_DB_YT, nErrNum]);
      WriteLog(nStr);
      raise Exception.Create(nStr);
    end;

    if not nWorker.FConn.Connected then
      nWorker.FConn.Connected := True;
    //conn db

    FListA.Clear;
    FListA.Add('begin');
    //init sql list

    for nIdx:=Low(nBills) to High(nBills) do
    begin
      nRID := YT_NewID('DB_TURN_MATERIN', nWorker);
      //记录编号

      nSQL := MakeSQLByStr([SF('DTM_ID', nRID),
              SF('DTM_Card', nBills[nIdx].FZhiKa),
              SF('DTM_ScaleBill', nBills[nIdx].FID),

              SF('DTM_IsTBalance', '0'),
              SF('DTM_IsBalance', '0'),
              SF('DTM_IsStore', '0'),
              SF('DTM_Status', '1'),
              SF('DTM_Del', '0'),

              SF('DTM_Impur', '0'),
              SF('DTM_Corner', '0'),
              SF('DTM_Freight', '0'),
              SF('DTM_CGWeight', '0'),
              SF('DTM_CTWeight', '0'),
              SF('DTM_CNWeight', '0'),
              SF('DTM_PrintNum', '0'),
              {$IFDEF GZBZX}
              SF('DTM_COLTYPE', '102'),
              {$ENDIF}
              {$IFDEF GZBSZ}
              SF('DTM_COLTYPE', '103'),
              {$ENDIF}

              SF('DTM_IsPlan', '0'),
              SF('DTM_KeepNum', '0'),
              SF('DTM_OtherNum', '0'),
              SF('DTM_ColPrice', '0'),
              SF('DTM_ColTotal', '0'),
              SF('DTM_FundWeight', '0'),

              SF('DTM_Vehicle', nBills[nIdx].FTruck),

              SF('DTM_InDate', Date2StrOracle(nBills[nIdx].FMData.FDate), sfVal),
              SF('DTM_CDate', DateTime2StrOracle(nBills[nIdx].FPData.FDate),sfVal),
              SF('DTM_TDate', DateTime2StrOracle(nBills[nIdx].FMData.FDate),sfVal),
              SF('DTM_Material', nBills[nIdx].FStockNo),
              SF('DTM_Company', nBills[nIdx].FCusID),
              SF('DTM_FIRM', gSysParam.FProvFirm),
              SF('DTM_TYPE', '101'),

              SF('DTM_RWeight', nBills[nIdx].FKZValue, sfVal),
              SF('DTM_GWeight', nBills[nIdx].FMData.FValue, sfVal),
              SF('DTM_TWeight', nBills[nIdx].FPData.FValue, sfVal),
              SF('DTM_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                   nBills[nIdx].FPData.FValue-nBills[nIdx].FKZValue, cPrecision,
                   True), sfVal)
              ], 'DB_Turn_MaterIn', '', True);
      FListA.Add(nSQL + ';'); //材料进厂表

      nSQL := YT_NewInsertLog(nSQL + ';', nWorker);
      FListA.Add(nSQL);
    end;

    //nWorker.FConn.BeginTrans;
    try
      nStr := 'commit;' + #13#10 +
              'exception' + #13#10 +
              ' when others then rollback; raise;' + #13#10 +
              'end;';
      FListA.Add(nStr);
      //oracle需明确提交

     gDBConnManager.WorkerExec(nWorker, FListA.Text);
     //执行脚本

      //nWorker.FConn.CommitTrans;
      Result := True;
    except
      on E:Exception do
      begin
        //nWorker.FConn.RollbackTrans;
        nData := '同步云天数据时发生错误,描述: ' + E.Message;
        Exit;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/3/21
//Parm:
//Desc: 同步销售订单状态
function TWorkerBusinessCommander.SyncYT_BillEdit(var nData: string): Boolean;
var nIdx: Integer;
    nWorker: PDBWorker;
    nStr, nSQL: string;
    nPrice, nVal: Double;
    nBills: TLadingBillItems;
    nDateMin, nSetDate: TDateTime;
begin
  Result := False;
  nStr := FIn.FData;

  nSQL := 'Select bill.*, plog.P_ID, ' +         //提货单信息
          'bcreater.U_Memo As bCreaterID, ' +    //云天开票员编号
          'pcreater.U_Memo As pCreaterID, ' +    //云天过皮司磅员
          'mcreater.U_Memo As mCreaterID  ' +    //云天过毛司磅员
          ' From $BILL bill ' +
          ' Left Join $USER bcreater On bcreater.U_Name=bill.L_Man ' +
          ' Left Join $USER pcreater On pcreater.U_Name=bill.L_PMan ' +
          ' Left Join $USER mcreater On mcreater.U_Name=bill.L_MMan ' +
          ' Left Join $PLOG plog On plog.P_Bill=bill.L_ID ' +
          'Where L_ID In ($IN)';
  nSQL := MacroValue(nSQL, [MI('$BILL', sTable_Bill), MI('$USER', sTable_User),
          MI('$PLOG', sTable_PoundLog), MI('$IN', nStr)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '发货单[ %s ]信息已丢失.';
      nData := Format(nData, [CombinStr(FListA, ',', False)]);
      Exit;
    end;

    First;
    nIdx := 0;
    FListA.Clear;
    SetLength(nBills, RecordCount);

    while not Eof do
    begin
      with nBills[nIdx] do
      begin
        FID         := FieldByName('L_ID').AsString;
        FZhiKa      := FieldByName('L_ZhiKa').AsString;
        FCusID      := FieldByName('L_CusID').AsString;

        FTruck      := FieldByName('L_Truck').AsString;
        FStockNo    := FieldByName('L_StockNo').AsString;
        FValue      := FieldByName('L_Value').AsFloat;

        if FListA.IndexOf(FZhiKa) < 0 then
          FListA.Add(FZhiKa);
        //订单项

        nDateMin := Str2Date('2000-01-01');
        //最小日期参考

        with FMData do
        begin
          FDate     := FieldByName('L_Date').AsDateTime;
          FOperator := FieldByName('bCreaterID').AsString;

          if FOperator = '' then
            FOperator := FieldByName('L_Man').AsString;
          //xxxx

          if FDate < nDateMin then
            FDate := FieldByName('L_OutFact').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;
        //临时记录开票信息

        FYTID := FieldByName('L_YTID').AsString;
        FMemo := FieldByName('L_Memo').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);
  //订单列表

  nSQL := 'select * From %s Where XCB_ID in (%s)';
  nSQL := Format(nSQL, ['XS_Card_Base', nStr]);
  //查询订单表

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nSQL, nWorker, sFlag_DB_YT) do
    begin
      if RecordCount < 1 then
      begin
        nData := '云天系统: 发货单[ %s ]信息已丢失.';
        nData := Format(nData, [CombinStr(FListA, ',', False)]);
        Exit;
      end;

      FListA.Clear;
      FListA.Add('begin');
      //init sql list

      FListB.Clear;
      //init Local sql List

      for nIdx:=Low(nBills) to High(nBills) do
      begin
        First;
        //init cursor

        //if nBills[nIdx].FValue<=0 then Continue;
        //发货量为0,管理员已经确认，无需保留

        while not Eof do
        begin
          nStr := FieldByName('XCB_ID').AsString;
          if nStr = nBills[nIdx].FZhiKa then Break;
          Next;
        end;

        if Eof then Continue;
        //订单丢失则不予处理

        nSetDate := nBills[nIdx].FMData.FDate;
        //nSetDate

        if FIn.FExtParam = sFlag_BillNew then
        begin
          nBills[nIdx].FYTID := YT_NewID('XS_LADE_BASE', nWorker);
          //记录编号

          nSQL := MakeSQLByStr([SF('XLB_ID', nBills[nIdx].FYTID),
                  SF('XLB_LadeId', nBills[nIdx].FID),
                  SF('XLB_SetDate', Date2StrOracle(nSetDate), sfVal),
                  SF('XLB_LadeType', '103'),
                  SF('XLB_Origin', '101'),
                  SF('XLB_Client', nBills[nIdx].FCusID),
                  SF('XLB_Cement', nBills[nIdx].FStockNo),
                  SF('XLB_CementSwap', nBills[nIdx].FStockNo),
                  //SF('XLB_CementCode', nBills[nIdx].FHYDan),
                  SF('XLB_Number', nBills[nIdx].FValue, sfVal),
                  //SF('XLB_FactNum', nBills[nIdx].FValue, sfVal),

                  SF('XLB_Price', '0.00', sfVal),
                  SF('XLB_CardPrice', '0.00', sfVal),
                  SF('XLB_Total', '0.00', sfVal),
                  SF('XLB_FactTotal', '0.00', sfVal),
                  SF('XLB_ScaleDifNum', '0.00', sfVal),
                  SF('XLB_InvoNum', '0.00', sfVal),
                  SF('XLB_Area', gSysParam.FSaleArea),

                  SF('XLB_SendArea', FieldByName('XCB_SubLader').AsString),
                  SF('XLB_CarCode', nBills[nIdx].FTruck),
                  SF('XLB_Quantity', '0', sfVal),
                  SF('XLB_PrintNum', '0', sfVal),
                  //SF('XLB_OutTime', DateTime2StrOracle(nSetDate), sfVal),
                  //SF('XLB_DoorTime', DateTime2StrOracle(nSetDate), sfVal),
                  SF('XLB_IsCarry', '0'),
                  SF('XLB_IsOut', '0'),
                  SF('XLB_IsCheck', '1'),
                  SF('XLB_IsDoor', '0'),
                  SF('XLB_IsBack', '0'),
                  //SF('XLB_Gather', '1'),
                  SF('XLB_IsInvo', '0'),
                  SF('XLB_Approve', '0'),
                  SF('XLB_TCollate', '0'),
                  SF('XLB_Collate', '0'),
                  SF('XLB_OutStore', '0'),
                  SF('XLB_ISTUNE', '0'),

                  SF('XLB_Firm', FieldByName('XCB_Firm').AsString),
                  SF('XLB_Status', '1'),
                  SF('XLB_Del', '0'),
                  SF('XLB_Creator', nBills[nIdx].FMData.FOperator),
                  SF('XLB_CDate', DateTime2StrOracle(nSetDate), sfVal),
                  SF('XLB_PROID', FieldByName('XCB_SubLader').AsString),
                  SF('XLB_KDATE', DateTime2StrOracle(nSetDate), sfVal),
                  SF('XLB_ISONLY', FieldByName('XCB_ISONLY').AsString),
                  SF('XLB_ISSUPPLY', '0')
                  ], 'XS_Lade_Base', '', True);
          FListA.Add(nSQL + ';'); //销售提货单表

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //插入同步事物表

          nSQL := YT_NewInsertSyncLog('A004', nBills[nIdx].FYTID, '101', nWorker);
          FListA.Add(nSQL);
          //插入集团同步业务表

          nPrice := FieldByName('XCB_Price').AsFloat;
          nVal := nPrice * nBills[nIdx].FValue;
          nVal := Float2Float(nVal, cPrecision, True);
          //金额

          nSQL := MakeSQLByStr([SF('XLD_ID', YT_NewID('XS_LADE_DETAIL', nWorker)),
                  SF('XLD_Lade', nBills[nIdx].FYTID),
                  SF('XLD_Client', nBills[nIdx].FCusID),
                  SF('XLD_Card',  nBills[nIdx].FZhiKa),
                  SF('XLD_Number', nBills[nIdx].FValue, sfVal),
                  SF('XLD_Price', nPrice, sfVal),
                  SF('XLD_CardPrice', nPrice, sfVal),
                  SF('XLD_Gap', '0', sfVal),
                  SF('XLD_Total', nVal, sfVal),
                  SF('XLD_PROID', FieldByName('XCB_SubLader').AsString),
                  SF('XLD_Order', '0', sfVal)
                  //SF('XLD_FactNum', '0', sfVal),
                  //SF('XLD_GWeight', nBills[nIdx].FMData.FValue, sfVal),
                  //SF('XLD_TWeight', nBills[nIdx].FPData.FValue, sfVal),
                  //SF('XLD_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                  //   nBills[nIdx].FPData.FValue, cPrecision, True), sfVal)
                  ], 'XS_Lade_Detail', '', True);
          FListA.Add(nSQL + ';'); //销售提货单明细表

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //插入同步事物表

          nSQL := SF('L_ID', nBills[nIdx].FID);
          nSQL := MakeSQLByStr([
                  SF('L_YTID', nBills[nIdx].FYTID)
                  ],sTable_Bill, nSQL, False);
          FListB.Add(nSQL);
        end else

        if FIn.FExtParam = sFlag_BillDel then
        begin
          nSQL := SF('XLB_ID', nBills[nIdx].FYTID);
          nSQL := MakeSQLByStr([
                  SF('XLB_Del', '1')
                  ], 'XS_Lade_Base', nSQL, False);
          FListA.Add(nSQL + ';'); //销售提货单表

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //插入同步事物表

          nSQL := YT_NewInsertSyncLog('A004', nBills[nIdx].FYTID, '102', nWorker);
          FListA.Add(nSQL);
          //插入集团同步业务表
        end else

        if FIn.FExtParam = sFlag_BillPick then
        begin
          nPrice := FieldByName('XCB_Price').AsFloat;
          nVal := nPrice * nBills[nIdx].FValue;
          nVal := Float2Float(nVal, cPrecision, True);
          //金额

          nSQL := SF('XLD_Lade', nBills[nIdx].FYTID);

          nSQL := MakeSQLByStr([SF('XLD_Client', nBills[nIdx].FCusID),
                  SF('XLD_Card',  nBills[nIdx].FZhiKa),
                  SF('XLD_Number', nBills[nIdx].FValue, sfVal),
                  SF('XLD_Price', nPrice, sfVal),
                  SF('XLD_CardPrice', nPrice, sfVal),
                  SF('XLD_Gap', '0', sfVal),
                  SF('XLD_Total', nVal, sfVal),
                  SF('XLD_PROID', FieldByName('XCB_SubLader').AsString),
                  SF('XLD_Order', '0', sfVal)
                  //SF('XLD_FactNum', '0', sfVal),
                  //SF('XLD_GWeight', nBills[nIdx].FMData.FValue, sfVal),
                  //SF('XLD_TWeight', nBills[nIdx].FPData.FValue, sfVal),
                  //SF('XLD_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                  //   nBills[nIdx].FPData.FValue, cPrecision, True), sfVal)
                  ], 'XS_Lade_Detail', nSQL, False);
          FListA.Add(nSQL + ';'); //销售提货单明细表

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //插入同步事物表
        end
      end;

      FDBConn.FConn.BeginTrans;
      try
        nStr := 'commit;' + #13#10 +
                'exception' + #13#10 +
                ' when others then rollback; raise;' + #13#10 +
                'end;';
        FListA.Add(nStr);
        //oracle需明确提交

        gDBConnManager.WorkerExec(nWorker, FListA.Text);
        //执行脚本

        for nIdx := 0 to FListB.Count - 1 do
          gDBConnManager.WorkerExec(FDBConn, FListB[nIdx]);
        //xxxxx

        FDBConn.FConn.CommitTrans;
        Result := True;
      except
        on E:Exception do
        begin
          FDBConn.FConn.RollbackTrans;
          nData := '同步云天提货单数据时发生错误,描述: ' + E.Message;
          Exit;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2016/8/13
//Parm: 提货单号(FIn.FData);新的批次号(FIn.FExtParam)
//Desc: 更新提货单的批次号
function TWorkerBusinessCommander.SaveLadingSealInfo(var nData: string): Boolean;
var nVal: Double;
    nIdx: Integer;
    nHasOut: Boolean;
    nWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
    nStr, nSQL, nCNO, nSNO, nComentCode, nYTID, nHYDan, nSeal: string;
begin
  Result := False;
  FListA.Clear;
  //init

  nSQL := 'Select * From %s Where L_ID=''%s''';
  nSQL := Format(nSQL, [sTable_Bill, FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '发货单[ %s ]信息已丢失.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nHasOut := FieldByName('L_OutFact').AsString <> '';
    nComentCode := FieldByName('L_HYDan').AsString;
    nCNO := FieldByName('L_Seal').AsString;
    nVal := FieldByName('L_Value').AsFloat;
    nYTID:= FieldByName('L_YTID').AsString;
    nSNO := FieldByName('L_StockNO').AsString;

    FListA.Values['HYDan'] := FIn.FExtParam;
    FListA.Values['Value'] := FloatToStr(nVal);
    FListA.Values['XCB_CementName'] := FieldByName('L_StockName').AsString;
  end;

  if not TWorkerBusinessCommander.CallMe(cBC_GetYTBatchCode,
     PackerEncodeStr(FListA.Text), '', @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end; //验证批次号有效性和可提量

  FListA.Text := PackerDecodeStr(nOut.FData);
  nHYDan := FListA.Values['XCB_CementCode'];
  nSeal  := FListA.Values['XCB_CementCodeID'];

  nWorker := nil;
  try
    nSQL := 'Select * From XS_Lade_Base Where  XLB_LadeId=''%s''';
    nSQL := Format(nSQL, [FIn.FData]);
    
    with gDBConnManager.SQLQuery(nSQL, nWorker, sFlag_DB_YT) do
    begin
      if RecordCount < 1 then
      begin
        nData := '云天系统: 发货单[ %s ]信息已丢失.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      FListA.Clear;
      FListB.Clear;

      if nHasOut then    //已出厂，需更新云天系统批次号
      begin
        FListA.Add('begin');
        //init sql list

        nSQL := SF('XLB_ID', nYTID);
        nSQL := MakeSQLByStr([
                SF('XLB_CementCode', nHYDan)
                ], 'XS_Lade_Base', nSQL, False);
        FListA.Add(nSQL + ';'); //销售提货单表

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //插入同步事物表

        nSQL := YT_NewInsertSyncLog('A004', nYTID, '102', nWorker);
        FListA.Add(nSQL);
        //插入集团同步业务表

        nSQL := SF('DTP_Lade', nYTID);
        nSQL := MakeSQLByStr([
                SF('DTP_CementCode', nHYDan)
                ], 'DB_Turn_ProduOut', nSQL, False);
        FListA.Add(nSQL + ';'); //销售出厂列表

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //插入同步事物表

        nSQL := SF('XLM_LADE', nYTID);
        nSQL := MakeSQLByStr([
                SF('XLM_CEMENTCODE', nSeal)
                ], 'XS_Lade_CementCode', nSQL, False);
        FListA.Add(nSQL + ';'); //销售批次使用列表

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //插入同步事物表

        nStr := 'commit;' + #13#10 +
                'exception' + #13#10 +
                ' when others then rollback; raise;' + #13#10 +
                'end;';
        FListA.Add(nStr);
        //oracle需明确提交

        nStr := 'Update %s Set C_HasDone=C_HasDone+%.2f Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nSeal]);
        nIdx := gDBConnManager.WorkerExec(FDBConn, nStr);

        if nIdx < 1 then
        begin
          nSQL := MakeSQLByStr([
            SF('C_ID', nSeal),
            SF('C_Code', nHYDan),
            SF('C_Stock', nSNO),
            SF('C_Freeze', '0', sfVal),
            SF('C_HasDone', nVal, sfVal)
            ], sTable_YT_CodeInfo, '', True);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;
        //更新新批次;

        nStr := 'Update %s Set C_HasDone=C_HasDone-%.2f Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nCNO]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
        //更新旧批次

        nSQL := SF('L_ID', FIn.FData);
        nSQL := MakeSQLByStr([
                SF('L_HYDan', nHYDan),
                SF('L_Seal', nSeal)
                ],sTable_Bill, nSQL, False);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
      end else

      begin            //未出厂，需更新一卡通系统批次号冻结量
        nStr := 'Update %s Set C_Freeze=C_Freeze+%.2f Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nSeal]);
        nIdx := gDBConnManager.WorkerExec(FDBConn, nStr);

        if nIdx < 1 then
        begin
          nSQL := MakeSQLByStr([
            SF('C_ID', nSeal),
            SF('C_Code', nHYDan),
            SF('C_Stock', nSNO),
            SF('C_Freeze', nVal, sfVal),
            SF('C_HasDone', '0', sfVal)
            ], sTable_YT_CodeInfo, '', True);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;
        //更新新批次;

        nStr := 'Update %s Set C_Freeze=C_Freeze-%.2f Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nCNO]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
        //更新旧批次

        nSQL := SF('L_ID', FIn.FData);
        nSQL := MakeSQLByStr([
                SF('L_HYDan', nHYDan),
                SF('L_Seal', nSeal)
                ],sTable_Bill, nSQL, False);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
      end;

      if FListA.Count > 0 then
        gDBConnManager.WorkerExec(nWorker, FListA.Text);
      //执行脚本
    end;

    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;   
end;

function TWorkerBusinessCommander.GetYTBatchCode(var nData: string): Boolean;
var nStr: string;
    nVal: Double;
    nSelect: Boolean;
    nIdx,nInt: Integer;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  //Init

  with FListA do
  begin
    FListB.Clear;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NOBatchCode]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;

      try
        nStr := FieldByName('D_Value').AsString;
        if FListB.IndexOf(nStr) < 0 then
          FListB.Add(nStr);
      finally
        Next;
      end;
    end;

    if (FListB.Count > 0) and (FListB.IndexOf(Values['XCB_Cement']) >= 0) then
    begin
      FOut.FData := PackerEncodeStr(FListA.Text);
      Result := True;
      Exit;
    end;
    //无需批次号的物料

    if Values['XCB_OutASH'] = '' then
    begin
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_HYPackers]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
         Values['XCB_OutASH'] := Fields[0].AsString;
    end;   

    nInt := 0;
    nDBWorker := nil;
    try
      if Trim(Values['HYDan']) <> '' then  //存在批次号
      begin
        nStr := 'Select cno_count, cno_id, cno_cementcode ' +
                'From CF_Notify_OutWork ' +
                'Where (CNO_Cementcode=''%s'') AND ' +
                '      (CNO_Status = 1) AND ' +
                '      (CNO_Del = 0) AND ' +
                '      (CNO_SetDate<=Sysdate) ' +
                'order by cno_setdate ';
        nStr := Format(nStr, [Values['HYDan']]);
        with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
        if RecordCount > 0 then
        begin
          nVal := FieldByName('cno_count').AsFloat;
          Values['XCB_CementCodeID'] := FieldByName('cno_id').AsString;
          Values['XCB_CementCode'] := FieldByName('cno_cementcode').AsString;
        end
        else
        begin
          nData := '※.水泥编号: %s' + #13#10 +
                   '※.水泥名称: %s' + #13#10 +
                   '※.错误描述: 水泥编号不存在,无法开票.';
          nData := Format(nData, [Values['HYDan'],
                   Values['XCB_CementName']]);
          Exit;
        end;

        nStr := 'select C_Freeze from %s where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, Values['XCB_CementCodeID']]);

        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        begin
          if RecordCount > 0 then
            nVal := nVal - Fields[0].AsFloat;
          //扣减已冻结
        end;

        nStr := 'select nvl(SUM(xlc.XLM_Number), 0) AS XCV_UserCount ' +
                'from XS_Lade_CementCode xlc' +
                ' LEFT OUTER JOIN XS_Lade_Base xlb on xlb.XLB_ID = xlc.XLM_Lade ' +
                'WHERE (xlc.xlm_cementcode = ''%s'') and ' +
                ' (xlb.XLB_Del = 0) AND (xlb.XLB_Status = 1) ' +
                'GROUP BY xlc.XLM_CementCode';
        //xxxxx

        nStr := Format(nStr, [Values['XCB_CementCodeID']]);
        //查询已发量

        with gDBConnManager.WorkerQuery(nDBWorker, nStr) do
        begin
          if RecordCount > 0 then
            nVal := nVal - FieldByName('XCV_UserCount').AsFloat;
          //扣减已发货
        end;

        nVal := nVal - StrToFloatDef(Values['Value'], 0);
        //减去本次发货量

        if nVal <= 0 then
        begin
          nData := '※.水泥编号: %s' + #13#10 +
                   '※.水泥名称: %s' + #13#10 +
                   '※.错误描述: 该编号余量不足,无法开票.';
          nData := Format(nData, [Values['HYDan'],
                   Values['XCB_CementName']]);
          Exit;
        end;

        FOut.FData := PackerEncodeStr(FListA.Text);
        Result := True;
      end else                            //重选批次号

      begin
        //----------------------------------------------------------------------
        nStr := 'select cno.cno_id,cno.cno_cementcode,cno.cno_count,cnd.cnd_OutASH from ' +
                'CF_Notify_OutWorkDtl cnd' +
                ' Left Join CF_Notify_OutWork cno On cno.cno_id=cnd.cnd_notifyid ' +
                'where (cnd.Cnd_Cement = ''%s'') and' +
                '      (cno.cno_cementcode <> '' '') and' +
                '      (cno.cno_status = 1) AND' +
                '      (cno.CNO_Del = 0) AND' +
                '      (cno.CNO_SetDate<=Sysdate)' +
                'order by cno.cno_setdate ';
        //xxxxx

        nStr := Format(nStr, [Values['XCB_Cement']]);
        //查询批次号记录

        with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
        if RecordCount > 0 then
        begin
          First;
          FListD.Clear;

          while not Eof do
          try
            nStr := FieldByName('cnd_OutASH').AsString;
            if Values['XCB_OutASH'] <> '' then
            begin
              FListB.Clear;
              SplitStr(nStr, FListB, 0, ',', False);

              FListC.Clear;
              SplitStr(Values['XCB_OutASH'], FListC, 0, ',', False);

              nSelect := False;
              for nIdx := 0 to FListB.Count-1 do
              begin
                if Length(FListB[nIdx]) < 1 then Continue;

                nSelect := FListC.IndexOf(FListB[nIdx]) >= 0;
                if nSelect then Break;
              end;

              if not nSelect then Continue;
              //不满足条件
            end;

            FListC.Clear;
            nVal := FieldByName('cno_count').AsFloat;

            FListC.Values['XCB_CementCodeID'] := FieldByName('cno_id').AsString;
            FListC.Values['XCB_CementCode'] := FieldByName('cno_cementcode').AsString;
            FListC.Values['XCB_OutASH'] := FieldByName('cnd_OutASH').AsString;
            //批次与编号

            nStr := 'select C_Freeze from %s where C_ID=''%s''';
            nStr := Format(nStr, [sTable_YT_CodeInfo, FListC.Values['XCB_CementCodeID']]);

            with gDBConnManager.WorkerQuery(FDBConn, nStr) do
            begin
              if RecordCount > 0 then
                nVal := nVal - Fields[0].AsFloat;
              //扣减已冻结
            end;

            FListC.Values['XCB_CementValue']  := FloatToStr(nVal);
            //订单量

            if nVal > 0 then
              FListD.Add(PackerEncodeStr(FListC.Text));
            //可用量大于0  
          finally
            Next;
          end;

          FListB.Clear;
          //保存剩余量大于0的记录
        
          for nIdx := 0 to FListD.Count - 1 do
          begin
            FListC.Text := PackerDecodeStr(FListD[nIdx]);
            nVal := StrToFloatDef(FListC.Values['XCB_CementValue'], 0);

            nStr := 'select nvl(SUM(xlc.XLM_Number), 0) AS XCV_UserCount ' +
                    'from XS_Lade_CementCode xlc' +
                    ' LEFT OUTER JOIN XS_Lade_Base xlb on xlb.XLB_ID = xlc.XLM_Lade ' +
                    'WHERE (xlc.xlm_cementcode = ''%s'') and ' +
                    ' (xlb.XLB_Del = 0) AND (xlb.XLB_Status = 1) ' +
                    'GROUP BY xlc.XLM_CementCode';
            //xxxxx

            nStr := Format(nStr, [FListC.Values['XCB_CementCodeID']]);
            //查询已发量

            with gDBConnManager.WorkerQuery(nDBWorker, nStr) do
            begin
              if RecordCount > 0 then
                nVal := nVal - FieldByName('XCV_UserCount').AsFloat;
              //扣减已发货
            end;

            if nVal > 0 then
            begin
              if nInt = 0 then
              begin
                Values['XCB_CementCodeID'] := FListC.Values['XCB_CementCodeID'];
                Values['XCB_CementCode'] := FListC.Values['XCB_CementCode'];
              end;

              nVal := Float2Float(nVal, cPrecision, False);
              FListC.Values['XCB_CementValue'] := FloatToStr(nVal);
              FListB.Add(PackerEncodeStr(FListC.Text));
              Inc(nInt);
            end;
          end;

          if (nInt <= 0) or (FListB.Count < 1) then
          begin
            nData := '※.水泥编号: %s' + #13#10 +
                     '※.水泥名称: %s' + #13#10 +
                     '※.错误描述: 无可用水泥编号,无法开票.';
            nData := Format(nData, [Values['XCB_Cement'],
                     Values['XCB_CementName']]);
            Exit;
          end;

          Values['XCB_CementRecords'] := PackerEncodeStr(FListB.Text);
        end;

        FOut.FData := PackerEncodeStr(FListA.Text);
        Result := True;
      end;
    finally
      gDBConnManager.ReleaseConnection(nDBWorker);
    end;
  end;
end;

function TWorkerBusinessCommander.SyncYT_BatchCodeInfo(var nData: string): Boolean;
begin
  Result := True;
end;


//------------------------------------------------------------------------------
class function TWorkerBusinessOrders.FunctionName: string;
begin
  Result := sBus_BusinessPurchaseOrder;
end;

constructor TWorkerBusinessOrders.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessOrders.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessOrders.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessOrders.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessOrders.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveOrder            : Result := SaveOrder(nData);
   cBC_DeleteOrder          : Result := DeleteOrder(nData);
   cBC_SaveOrderBase        : Result := SaveOrderBase(nData);
   cBC_DeleteOrderBase      : Result := DeleteOrderBase(nData);
   cBC_SavePurchaseContract : Result := SavePurchaseContract(nData);
   cBC_ModifyPurchaseContract : Result := ModifyPurchaseContract(nData);
   cBC_DeletePurchaseContract : Result := DeletePurchaseContract(nData);
   cBC_SaveOrderCard        : Result := SaveOrderCard(nData);
   cBC_LogoffOrderCard      : Result := LogoffOrderCard(nData);
   cBC_ModifyBillTruck      : Result := ChangeOrderTruck(nData);
   cBC_GetPostOrders        : Result := GetPostOrderItems(nData);
   cBC_SavePostOrders       : Result := SavePostOrderItems(nData);
   cBC_GetGYOrderValue      : Result := GetGYOrderValue(nData);
   cBC_ImportOrderPoundS    : Result := ImportOrderPoundS(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

function TWorkerBusinessOrders.SaveOrderBase(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nOut: TWorkerBusinessCommand;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  //unpack Order

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_OrderBase;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := FOut.FData + nOut.FData + ',';
    //combine Order

    nStr := MakeSQLByStr([SF('B_ID', nOut.FData),
            SF('B_BStatus', FListA.Values['IsValid']),

            SF('B_Project', FListA.Values['Project']),
            SF('B_Area', FListA.Values['Area']),

            SF('B_Value', StrToFloat(FListA.Values['Value']),sfVal),
            SF('B_RestValue', StrToFloat(FListA.Values['Value']),sfVal),
            SF('B_LimValue', StrToFloat(FListA.Values['LimValue']),sfVal),
            SF('B_WarnValue', StrToFloat(FListA.Values['WarnValue']),sfVal),

            SF('B_SentValue', 0,sfVal),
            SF('B_FreezeValue', 0,sfVal),

            SF('B_ProID', FListA.Values['ProviderID']),
            SF('B_ProName', FListA.Values['ProviderName']),
            SF('B_ProPY', GetPinYinOfStr(FListA.Values['ProviderName'])),

            SF('B_SaleID', FListA.Values['SaleID']),
            SF('B_SaleMan', FListA.Values['SaleMan']),
            SF('B_SalePY', GetPinYinOfStr(FListA.Values['SaleMan'])),

            SF('B_StockType', sFlag_San),
            SF('B_StockNo', FListA.Values['StockNO']),
            SF('B_StockName', FListA.Values['StockName']),

            SF('B_Man', FIn.FBase.FFrom.FUser),
            SF('B_Date', sField_SQLServer_Now, sfVal)
            ], sTable_OrderBase, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx
    
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/9/19
//Parm: 
//Desc: 删除采购申请单
function TWorkerBusinessOrders.DeleteOrderBase(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  //init

  nStr := 'Select Count(*) From %s Where O_BID=''%s''';
  nStr := Format(nStr, [sTable_Order, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '采购申请单[ %s ]已使用.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_OrderBase]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('B_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,B_DelMan,B_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where B_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_OrderBaseBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_OrderBase), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where B_ID=''%s''';
    nStr := Format(nStr, [sTable_OrderBase, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/3/16
//Parm: 
//Desc: 保存采购合同
function TWorkerBusinessOrders.SavePurchaseContract(var nData: string):Boolean;
var nStr: string;
    nIdx: Integer;
    nOut: TWorkerBusinessCommand;
    nPcid:string;
    nQuotaList,nTempList:TStrings;
    nName,nCondition,nValue:string;
    npunishcondition:string;
    npunishBasis,punish_standard:double;
    npunishmode:integer;
    ndValue:Double;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nQuotaList := TStringList.Create;
  nTempList := TStringList.Create;
  try
    //unpack Order
    FDBConn.FConn.BeginTrans;
    try
      FOut.FData := '';
      //bill list

      FListC.Values['Group'] :=sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_PurchaseContract;
      //to get serial no

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      nPcid := nOut.FData;
      FOut.FData := nOut.FData;
      //combine Order
      //bill list

      nStr := MakeSQLByStr([SF('pcid', nPcid),
              SF('provider_code', FListA.Values['ProviderCode']),
              SF('provider_name', FListA.Values['ProviderName']),
              SF('con_code', FListA.Values['ContractNo']),
              SF('con_materiel_Code', FListA.Values['MeterailCode']),
              SF('con_materiel_name',FListA.Values['MeterailName']),
              SF('con_price',  StrToFloatDef(FListA.Values['Price'],0),sfVal),
              SF('con_quantity', StrToFloatDef(FListA.Values['quantity'],0),sfVal),
              SF('con_finished_quantity', 0,sfVal),
              SF('con_status', StrToint(sFlag_PurchaseContract_input),sfVal),
              SF('con_Man', FIn.FBase.FFrom.FUser),
              SF('con_remark', FListA.Values['Remark'])
          ], sTable_PurchaseContract, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      nStr :=  PackerDecodeStr(FListA.Values['QuotaList']);
      nQuotaList.Text := nStr;
      for nIdx := 0 to nQuotaList.Count-1 do
      begin
        nStr := nQuotaList.Strings[nIdx];
        nTempList.CommaText := nStr;
        npunishcondition :='';
        npunishBasis := 0;
        punish_standard := 0;
        npunishmode := 0;
        nName := nTempList.Strings[0];
        nValue := nTempList.Strings[1];
        nValue :=  StringReplace(nValue, '%', '', [rfReplaceAll, rfIgnoreCase]);
        ndValue := StrToFloatDef(nValue,0)/100;
        nCondition := nTempList.Strings[2];
        if nTempList.Count>4 then
        begin
          npunishcondition := nTempList.Strings[3];
          npunishBasis := StrToFloatDef(nTempList.Strings[4],0)/100;
          punish_standard := StrToFloatDef(nTempList.Strings[5],0);
          if nTempList.Strings[6]='单价' then
          begin
            npunishmode := 1;
          end;
        end;
        nStr := MakeSQLByStr([SF('pcid', nPcid),
                SF('quota_name', nName),
                SF('quota_condition', nCondition),
                SF('quota_value', ndValue,sfval),
                SF('punish_condition', npunishcondition),
                SF('punish_Basis', npunishBasis,sfVal),
                SF('punish_standard', punish_standard,sfVal),
                SF('punish_mode', npunishmode,sfVal),
                SF('remark', '')
          ], sTable_PurchaseContractDetail, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
  
      FDBConn.FConn.CommitTrans;
      Result := True;
    except
      FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    nTempList.Free;
    nQuotaList.Free;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/3/16
//Parm: 
//Desc: 修改采购合同
function TWorkerBusinessOrders.ModifyPurchaseContract(var nData: string):Boolean;
var nStr: string;
    nIdx: Integer;
    nOut: TWorkerBusinessCommand;
    nPcid:string;
    nQuotaList,nTempList:TStrings;
    nName,nCondition,nValue:string;
    npunishcondition:string;
    npunishBasis,punish_standard:double;
    npunishmode:integer;
    ndValue:Double;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nQuotaList := TStringList.Create;
  nTempList := TStringList.Create;
  try
    FDBConn.FConn.BeginTrans;
    try
      nPcid := FListA.Values['fid'];
      FOut.FData := nPcid;

      nStr := MakeSQLByStr([SF('provider_code', FListA.Values['ProviderCode']),
              SF('provider_name', FListA.Values['ProviderName']),
              SF('con_code', FListA.Values['ContractNo']),
              SF('con_materiel_Code', FListA.Values['MeterailCode']),
              SF('con_materiel_name',FListA.Values['MeterailName']),
              SF('con_price',  StrToFloatDef(FListA.Values['Price'],0),sfVal),
              SF('con_quantity', StrToFloatDef(FListA.Values['quantity'],0),sfVal),
              SF('con_status', StrToint(sFlag_PurchaseContract_input),sfVal),
              SF('con_MdyMan', FIn.FBase.FFrom.FUser),
              SF('con_MdyDate', sField_SQLServer_Now,sfVal),
              SF('con_remark', FListA.Values['Remark'])
          ], sTable_PurchaseContract, 'pcId=''%s''', False);
      nStr := Format(nStr,[nPcid]);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      //保存历史合同明细到备份表
      nStr := 'insert into %s(pcId,quota_name,quota_condition,quota_value,'
        +'punish_condition,punish_Basis,punish_standard,punish_mode,Del_man,Del_Date,remark) '
        +'select pcId,quota_name,quota_condition,quota_value,punish_condition,'
        +'punish_Basis,punish_standard,punish_mode,''%s'',%s,remark from %s where pcid=''%s''';
      nStr := Format(nStr,[sTable_PurchaseContractDetail_bak,
        FIn.FBase.FFrom.FUser,
        sField_SQLServer_Now,
        sTable_PurchaseContractDetail,
        nPcid]);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      //更新合同明细
      nStr := 'delete from %s where pcid=''%s''';
      nStr := Format(nStr,[sTable_PurchaseContractDetail,nPcid]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      
      nStr :=  PackerDecodeStr(FListA.Values['QuotaList']);
      nQuotaList.Text := nStr;
      for nIdx := 0 to nQuotaList.Count-1 do
      begin
        nStr := nQuotaList.Strings[nIdx];
        nTempList.CommaText := nStr;
        npunishcondition :='';
        npunishBasis := 0;
        punish_standard := 0;
        npunishmode := 0;
        nName := nTempList.Strings[0];
        nValue := nTempList.Strings[1];
        nValue :=  StringReplace(nValue, '%', '', [rfReplaceAll, rfIgnoreCase]);
        ndValue := StrToFloatDef(nValue,0)/100;
        nCondition := nTempList.Strings[2];
        if nTempList.Count>4 then
        begin
          npunishcondition := nTempList.Strings[3];
          npunishBasis := StrToFloatDef(nTempList.Strings[4],0)/100;
          punish_standard := StrToFloatDef(nTempList.Strings[5],0);
          if nTempList.Strings[6]='单价' then
          begin
            npunishmode := 1;
          end;
        end;
        nStr := MakeSQLByStr([SF('pcid', nPcid),
                SF('quota_name', nName),
                SF('quota_condition', nCondition),
                SF('quota_value', ndValue,sfval),
                SF('punish_condition', npunishcondition),
                SF('punish_Basis', npunishBasis,sfVal),
                SF('punish_standard', punish_standard,sfVal),
                SF('punish_mode', npunishmode,sfVal),
                SF('remark', '')
          ], sTable_PurchaseContractDetail, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
  
      FDBConn.FConn.CommitTrans;
      Result := True;
    except
      FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    nTempList.Free;
    nQuotaList.Free;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/3/16
//Parm: 
//Desc: 删除采购合同
function TWorkerBusinessOrders.DeletePurchaseContract(var nData: string):Boolean;
var
  nStr:string;
  nPcid:string;
begin
  Result := False;
  nPcid := FIn.FData;
  nStr := 'Select Count(*) From %s Where PCID=''%s''';
  nStr := Format(nStr, [sTable_Order, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '采购合同[ %s ]已被使用.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    nStr := 'update %s set con_DelMan=''%s'',con_DelDate=%s,con_status=%d where pcid=''%s''';
    nStr := Format(nStr,[sTable_PurchaseContract,
      FIn.FBase.FFrom.FUser,
      sField_SQLServer_Now,
      StrToInt(sFlag_PurchaseContract_deleted),
      nPcid]);

    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/20
//Parm: 
//Desc: 获取供应可收货量
function TWorkerBusinessOrders.GetGYOrderValue(var nData: string): Boolean;
var nSQL: string;
    nVal, nSent, nLim, nWarn, nFreeze,nMax: Double;
begin
  Result := False;
  //init

  nSQL := 'Select B_Value,B_SentValue,B_RestValue, ' +
          'B_LimValue,B_WarnValue,B_FreezeValue ' +
          'From $OrderBase b1 inner join $Order o1 on b1.B_ID=o1.O_BID ' +
          'Where O_ID=''$ID''';
  nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
          MI('$Order', sTable_Order), MI('$ID', FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount<1 then
    begin
      nData := '采购申请单[%s]信息已丢失';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nVal    := FieldByName('B_Value').AsFloat;
    nSent   := FieldByName('B_SentValue').AsFloat;
    nLim    := FieldByName('B_LimValue').AsFloat;
    nWarn   := FieldByName('B_WarnValue').AsFloat;
    nFreeze := FieldByName('B_FreezeValue').AsFloat;

    nMax := nVal - nSent - nFreeze;
  end;  

  with FListB do
  begin
    Clear;

    if nVal>0 then
         Values['NOLimite'] := sFlag_No
    else Values['NOLimite'] := sFlag_Yes;

    Values['MaxValue']    := FloatToStr(nMax);
    Values['LimValue']    := FloatToStr(nLim);
    Values['WarnValue']   := FloatToStr(nWarn);
    Values['FreezeValue'] := FloatToStr(nFreeze);
  end;

  FOut.FData := PackerEncodeStr(FListB.Text);
  Result := True;
end;  


//Date: 2015-8-5
//Desc: 保存采购单
function TWorkerBusinessOrders.SaveOrder(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nVal: Double;
    nOut: TWorkerBusinessCommand;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nVal := StrToFloat(FListA.Values['Value']);
  //unpack Order

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_Order;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := FOut.FData + nOut.FData + ',';
    //combine Order

    nStr := MakeSQLByStr([SF('O_ID', nOut.FData),

            SF('O_CType', FListA.Values['CardType']),
            SF('O_Project', FListA.Values['Project']),
            SF('O_Area', FListA.Values['Area']),

            SF('O_BID', FListA.Values['SQID']),
            SF('pcid', FListA.Values['SQID']),
            SF('O_Value', nVal,sfVal),

            SF('O_ProID', FListA.Values['ProviderID']),
            SF('O_ProName', FListA.Values['ProviderName']),
            SF('O_ProPY', GetPinYinOfStr(FListA.Values['ProviderName'])),

            SF('O_SaleID', FListA.Values['SaleID']),
            SF('O_SaleMan', FListA.Values['SaleMan']),
            SF('O_SalePY', GetPinYinOfStr(FListA.Values['SaleMan'])),

            SF('O_Type', sFlag_San),
            SF('O_StockNo', FListA.Values['StockNO']),
            SF('O_StockName', FListA.Values['StockName']),

            SF('O_Truck', FListA.Values['Truck']),
            SF('O_Man', FIn.FBase.FFrom.FUser),
            SF('O_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Order, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    if FListA.Values['CardType'] = sFlag_OrderCardL then
    begin
      nStr := 'Update %s Set B_FreezeValue=B_FreezeValue+%.2f ' +
              'Where B_ID = ''%s'' and B_Value>0';
      nStr := Format(nStr, [sTable_OrderBase, nVal,FListA.Values['SQID']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx
    
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015-8-5
//Desc: 保存采购单
function TWorkerBusinessOrders.DeleteOrder(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  //init

  nStr := 'Select Count(*) From %s Where D_OID=''%s''';
  nStr := Format(nStr, [sTable_OrderDtl, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '采购单[ %s ]已使用.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Order]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('O_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,O_DelMan,O_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where O_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_OrderBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_Order), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where O_ID=''%s''';
    nStr := Format(nStr, [sTable_Order, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 采购订单[FIn.FData];磁卡号[FIn.FExtParam]
//Desc: 为采购单绑定磁卡
function TWorkerBusinessOrders.SaveOrderCard(var nData: string): Boolean;
var nStr,nSQL,nTruck: string;
begin
  Result := False;
  nTruck := '';

  FListB.Text := FIn.FExtParam;
  //磁卡列表
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //采购单列表

  nSQL := 'Select O_ID,O_Card,O_Truck From %s Where O_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Order, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('采购订单[ %s ]已丢失.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      nStr := FieldByName('O_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '采购单[ %s ]的车牌号不一致,不能并单.' + #13#10#13#10 +
                 '*.本单车牌: %s' + #13#10 +
                 '*.其它车牌: %s' + #13#10#13#10 +
                 '相同牌号才能并单,请修改车牌号,或者单独办卡.';
        nData := Format(nData, [FieldByName('O_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('O_Card').AsString;
      //正在使用的磁卡
        
      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nSQL := 'Select O_ID,O_Truck From %s Where O_Card=''%s''';
  nSQL := Format(nSQL, [sTable_Order, FIn.FExtParam]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    nData := '车辆[ %s ]正在使用该卡,无法并单.';
    nData := Format(nData, [FieldByName('O_Truck').AsString]);
    Exit;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
      //重新计算列表

      nSQL := 'Update %s Set O_Card=''%s'' Where O_ID In(%s)';
      nSQL := Format(nSQL, [sTable_Order, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);

      nSQL := 'Update %s Set D_Card=''%s'' Where D_OID In(%s) and D_OutFact Is NULL';
      nSQL := Format(nSQL, [sTable_OrderDtl, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Provide),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Provide),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015-8-5
//Desc: 保存采购单
function TWorkerBusinessOrders.LogoffOrderCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set O_Card=Null Where O_Card=''%s''';
    nStr := Format(nStr, [sTable_Order, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set D_Card=Null Where D_Card=''%s''';
    nStr := Format(nStr, [sTable_OrderDtl, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessOrders.ChangeOrderTruck(var nData: string): Boolean;
var nStr: string;
begin
  //Result := False;
  //Init

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set O_Truck=''%s'' Where O_ID=''%s''';
    nStr := Format(nStr, [sTable_Order, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //更新修改信息

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 磁卡号[FIn.FData];岗位[FIn.FExtParam]
//Desc: 获取特定岗位所需要的交货单列表
function TWorkerBusinessOrders.GetPostOrderItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsOrder: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  nIsOrder := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_Order]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsOrder := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //前缀和长度都满足采购单编码规则,则视为采购单号
  end;

  if not nIsOrder then
  begin
    nStr := 'Select C_Status,C_Freeze From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FData]);
    //card status

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('磁卡[ %s ]信息已丢失.', [FIn.FData]);
        Exit;
      end;

      if Fields[0].AsString <> sFlag_CardUsed then
      begin
        nData := '磁卡[ %s ]当前状态为[ %s ],无法提货.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '磁卡[ %s ]已被冻结,无法提货.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;

  nStr := 'Select O_ID,O_Card,O_ProID,O_ProName,O_Type,O_StockNo,' +
          'O_StockName,O_Truck,O_Value ' +
          'From $OO oo ';
  //xxxxx

  if nIsOrder then
       nStr := nStr + 'Where O_ID=''$CD'''
  else nStr := nStr + 'Where O_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$OO', sTable_Order),MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsOrder then
           nData := '采购单[ %s ]已无效.'
      else nData := '磁卡号[ %s ]无订单';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end else
    with FListA do
    begin
      Clear;

      Values['O_ID']         := FieldByName('O_ID').AsString;
      Values['O_ProID']      := FieldByName('O_ProID').AsString;
      Values['O_ProName']    := FieldByName('O_ProName').AsString;
      Values['O_Truck']      := FieldByName('O_Truck').AsString;

      Values['O_Type']       := FieldByName('O_Type').AsString;
      Values['O_StockNo']    := FieldByName('O_StockNo').AsString;
      Values['O_StockName']  := FieldByName('O_StockName').AsString;

      Values['O_Card']       := FieldByName('O_Card').AsString;
      Values['O_Value']      := FloatToStr(FieldByName('O_Value').AsFloat);
    end;
  end;

  nStr := 'Select D_ID,D_OID,D_PID,D_YLine,D_Status,D_NextStatus,' +
          'D_KZValue,D_Memo,D_YSResult,' +
          'P_PStation,P_PValue,P_PDate,P_PMan,' +
          'P_MStation,P_MValue,P_MDate,P_MMan ' +
          'From $OD od Left join $PD pd on pd.P_Order=od.D_ID ' +
          'Where D_OutFact Is Null And D_OID=''$OID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$OD', sTable_OrderDtl),
                            MI('$PD', sTable_PoundLog),
                            MI('$OID', FListA.Values['O_ID'])]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then
    begin
      SetLength(nBills, 1);

      with nBills[0], FListA do
      begin
        FZhiKa      := Values['O_ID'];
        FCusID      := Values['O_ProID'];
        FCusName    := Values['O_ProName'];
        FTruck      := Values['O_Truck'];

        FType       := Values['O_Type'];
        FStockNo    := Values['O_StockNo'];
        FStockName  := Values['O_StockName'];
        FValue      := StrToFloat(Values['O_Value']);

        FCard       := Values['O_Card'];
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;

        FSelected := True;
      end;  
    end else
    begin
      SetLength(nBills, RecordCount);

      nIdx := 0;

      First; 
      while not Eof do
      with nBills[nIdx], FListA do
      begin
        FID         := FieldByName('D_ID').AsString;
        FZhiKa      := FieldByName('D_OID').AsString;
        FPoundID    := FieldByName('D_PID').AsString;

        FCusID      := Values['O_ProID'];
        FCusName    := Values['O_ProName'];
        FTruck      := Values['O_Truck'];

        FType       := Values['O_Type'];
        FStockNo    := Values['O_StockNo'];
        FStockName  := Values['O_StockName'];
        FValue      := StrToFloat(Values['O_Value']);

        FCard       := Values['O_Card'];
        FStatus     := FieldByName('D_Status').AsString;
        FNextStatus := FieldByName('D_NextStatus').AsString;

        if (FStatus = '') or (FStatus = sFlag_BillNew) then
        begin
          FStatus     := sFlag_TruckNone;
          FNextStatus := sFlag_TruckNone;
        end;

        with FPData do
        begin
          FStation  := FieldByName('P_PStation').AsString;
          FValue    := FieldByName('P_PValue').AsFloat;
          FDate     := FieldByName('P_PDate').AsDateTime;
          FOperator := FieldByName('P_PMan').AsString;
        end;

        with FMData do
        begin
          FStation  := FieldByName('P_MStation').AsString;
          FValue    := FieldByName('P_MValue').AsFloat;
          FDate     := FieldByName('P_MDate').AsDateTime;
          FOperator := FieldByName('P_MMan').AsString;
        end;

        FKZValue  := FieldByName('D_KZValue').AsFloat;
        FMemo     := FieldByName('D_Memo').AsString;
        FYSValid  := FieldByName('D_YSResult').AsString;
        FSelected := True;

        Inc(nIdx);
        Next;
      end;
    end;    
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: 交货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessOrders.SavePostOrderItems(var nData: string): Boolean;
var nVal: Double;
    nIdx, nInt: Integer;
    nStr,nSQL, nYS: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    npcid:string;//采购合同号
    nSum:Double;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nPound);
  nInt := Length(nPound);
  //解析数据

  if nInt < 1 then
  begin
    nData := '岗位[ %s ]提交的单据为空.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '岗位[ %s ]提交了原材料合单,该业务系统暂时不支持.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;
  //无合单业务

  FListA.Clear;
  //用于存储SQL列表

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  begin
    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_OrderDtl;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
        FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([
            SF('D_ID', nOut.FData),
            SF('D_Card', FCard),
            SF('D_OID', FZhiKa),
            SF('D_Status', sFlag_TruckIn),
            SF('D_NextStatus', sFlag_TruckBFP),
            SF('D_InMan', FIn.FBase.FFrom.FUser),
            SF('D_InTime', sField_SQLServer_Now, sfVal)
            ], sTable_OrderDtl, '', True);
      FListA.Add(nSQL);
    end;  
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    FListB.Clear;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        FListB.Add(Fields[0].AsString);
        Next;
      end;
    end;

    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockIfYS]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
         nYS := Fields[0].AsString
    else nYS := sFlag_No;

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //返回榜单号,用于拍照绑定
    with nPound[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckXH;

      if (FListB.IndexOf(FStockNo) >= 0) or (nYS <> sFlag_Yes) then
        FNextStatus := sFlag_TruckBFM;
      //现场不发货直接过重

      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Provide),
            SF('P_Order', FID),
            SF('P_Truck', FTruck),
            SF('P_CusID', FCusID),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_LimValue', 0),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_PDate', sField_SQLServer_Now, sfVal),
            SF('P_PMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '进厂'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_PValue', FPData.FValue, sfVal),
              SF('D_PDate', sField_SQLServer_Now, sfVal),
              SF('D_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL);
    end;  

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckXH then //验收现场
  begin
    with nPound[0] do
    begin
      FStatus := sFlag_TruckXH;
      FNextStatus := sFlag_TruckBFM;

      nStr := SF('P_Order', FID);
      //where
      nSQL := MakeSQLByStr([
                SF('P_KZValue', FKZValue, sfVal)
                ], sTable_PoundLog, nStr, False);
        //验收扣杂
       FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_YTime', sField_SQLServer_Now, sfVal),
              SF('D_YMan', FIn.FBase.FFrom.FUser),
              SF('D_KZValue', FKZValue, sfVal),
              SF('D_YSResult', FYSValid),
              SF('D_YLine', FPoundID),      //一线或二线
              SF('D_YLineName', FHKRecord), //卸货地点
              SF('D_Memo', FMemo)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    with nPound[0] do
    begin
      nStr := SF('P_Order', FID);
      //where

      nVal := FMData.FValue - FPData.FValue -FKZValue;
      if FNextStatus = sFlag_TruckBFP then
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //称重时,由于皮重大,交换皮毛重数据
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('D_Status', sFlag_TruckBFM),
                SF('D_NextStatus', sFlag_TruckOut),
                SF('D_PValue', FPData.FValue, sfVal),
                SF('D_PDate', sField_SQLServer_Now, sfVal),
                SF('D_PMan', FIn.FBase.FFrom.FUser),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', DateTime2Str(FMData.FDate)),
                SF('D_MMan', FMData.FOperator),
                SF('D_Value', nVal, sfVal)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);

      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('D_Status', sFlag_TruckBFM),
                SF('D_NextStatus', sFlag_TruckOut),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', sField_SQLServer_Now, sfVal),
                SF('D_MMan', FMData.FOperator),
                SF('D_Value', nVal, sfVal)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);
      end;

      //--------------------------------------------------------------------------
      FListC.Clear;
      FListC.Values['Field'] := 'T_PValue';
      FListC.Values['Truck'] := FTruck;
      FListC.Values['Value'] := FloatToStr(FPData.FValue);

      if not TWorkerBusinessCommander.CallMe(cBC_UpdateTruckInfo,
            FListC.Text, '', @nOut) then
        raise Exception.Create(nOut.FData);
      //保存车辆有效皮重

      if FYSValid <> sFlag_NO then  //验收成功，调整已收货量
      begin
        nSQL := 'Update $OrderBase Set B_SentValue=B_SentValue+$Val ' +
                'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'')';
        nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
                MI('$Order', sTable_Order),MI('$ID', FZhiKa),
                MI('$Val', FloatToStr(nVal))]);
        FListA.Add(nSQL);
        //调整已收货；
      end;

      nSQL := 'Update $OrderBase Set B_FreezeValue=B_FreezeValue-$KDVal ' +
              'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'''+
              ' And O_CType= ''L'') and B_Value>0';
      nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
              MI('$Order', sTable_Order),MI('$ID', FZhiKa),
              MI('$KDVal', FloatToStr(FValue))]);
      FListA.Add(nSQL);
      //调整冻结量
    end;

    nSQL := 'Select P_ID From %s Where P_Order=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nPound[0].FID]);
    //未称毛重记录

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;

    //计算合同已完成量
    nSum:=0;
    nSQL := 'select * from %s where P_Order where O_ID=%s';
    nSQL := Format(nSQL,[sTable_Order,nPound[0].FZhiKa]);
    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      npcid := FieldByName('pcid').AsString;
    end;
    if npcid<>'' then
    begin
      nSQL := 'select isnull(sum((D_MValue-D_PValue-D_KZValue)),0) as D_NetWeight'
        +' from %s where D_OID in (select O_ID from %s'
        +' where pcid=''%s'')';
      nStr := Format(nStr,[sTable_OrderDtl,sTable_Order,npcid]);
      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        nSum := FieldByName('D_NetWeight').AsFloat;
      end;
      nSQL := 'update %s set con_finished_quantity=%f where pcid=''%s''';
      nSQL := Format(nStr,[sTable_PurchaseContract,nSum,npcid]);
      gDBConnManager.WorkerQuery(FDBConn, nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([SF('D_Status', sFlag_TruckOut),
              SF('D_NextStatus', ''),
              SF('D_Card', ''),
              SF('D_OutFact', sField_SQLServer_Now, sfVal),
              SF('D_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL); //更新采购单
    end;

    nStr := nPound[0].FID;
    if not TWorkerBusinessCommander.CallMe(cBC_SyncStockOrder, nStr, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    nSQL := 'Select O_CType,O_Card From %s Where O_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Order, nPound[0].FZhiKa]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      nStr := FieldByName('O_Card').AsString;
      if FieldByName('O_CType').AsString = sFlag_OrderCardL then
      if not CallMe(cBC_LogOffOrderCard, nStr, '', @nOut) then
      begin
        nData := nOut.FData;
        Exit;
      end;
    end;
    //如果是临时卡片，则注销卡片
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    if Assigned(gHardShareData) then
      gHardShareData('TruckOut:' + nPound[0].FCard);
    //磅房处理自动出厂
  end;
end;

function TWorkerBusinessOrders.ImportOrderPoundS(var nData: string): Boolean;
var nIdx: Integer;
    nSQL, nIDS: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  //批量插入信息

  if FListA.Count < 1 then
  begin
    nData := '无导入信息记录';
    Exit;
  end;

  FListC.Clear;
  //磅单编号
  for nIdx := 0 to FListA.Count - 1 do
  begin
    FListB.Text := PackerDecodeStr(FListA[nIdx]);
    FListC.Add('''' + FListB.Values['P_ID'] + '''');
  end;

  nIDS := AdjustListStrFormat2(FListC, '''', True, ',', False, False);
  nIDS := Format('Select P_ID From %s Where P_ID In (%s)', [sTable_PoundLog, nIDS]);
  
  with gDBConnManager.WorkerQuery(FDBConn, nIDS) do
  if RecordCount > 0 then
  begin
    First;

    nIDS := '';
    while not Eof do
    begin
      nIDS := nIDS + Fields[0].AsString + ',';
      Next;
    end;

    nData := '磅单号[%s]已存在';
    nData := Format(nData, [nIDS]);
    Exit;
  end;
  //重复磅单号禁止使用
  
  FListC.Clear;
  //数据库语句
  
  for nIdx := 0 to FListA.Count - 1 do
  begin
    FListB.Text := PackerDecodeStr(FListA[nIdx]);
    //单条记录信息

    nSQL := MakeSQLByStr([
            SF('P_ID', FListB.Values['P_ID']),
            SF('P_Type', sFlag_Provide),
            SF('P_Order', FListB.Values['P_Order']),
            SF('P_Truck', FListB.Values['P_Truck']),
            SF('P_CusID', FListB.Values['P_CusID']),
            SF('P_CusName', FListB.Values['P_CusName']),
            SF('P_MID', FListB.Values['P_MID']),
            SF('P_MName', FListB.Values['P_MName']),
            SF('P_MType', sFlag_San),
            SF('P_LimValue', 0),

            SF('P_PValue', StrToFloat(FListB.Values['P_PValue']), sfVal),
            SF('P_PDate', FListB.Values['P_PDate']),
            SF('P_PMan', FIn.FBase.FFrom.FUser),

            SF('P_MValue', StrToFloat(FListB.Values['P_MValue']), sfVal),
            SF('P_MDate', FListB.Values['P_MDate']),
            SF('P_MMan', FIn.FBase.FFrom.FUser),

            SF('P_KZValue', StrToFloat(FListB.Values['P_KZValue']), sfStr),
            SF('P_Import', sFlag_Yes),

            SF('P_Direction', '进厂'),
            SF('P_PModel', sFlag_PoundPD),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_PrintNum', 1, sfVal)], sTable_PoundLog, '', True);
    FListC.Add(nSQL);
  end;

  FDBConn.FConn.BeginTrans;
  try
    for nIdx := 0 to FListC.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);

    FDBConn.FConn.CommitTrans;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
  //保存磅单数据

  FListC.Clear;
  //磅单编号
  
  for nIdx := 0 to FListA.Count - 1 do
  begin
    FListB.Text := PackerDecodeStr(FListA[nIdx]);
    FListC.Add('''' + FListB.Values['P_ID'] + '''');
  end;

  if FListC.Count < 1 then
  begin
    nData := '无同步信息记录';
    Exit;
  end;

  if not TWorkerBusinessCommander.CallMe(cBC_SyncProvidePound, FListC.Text,
     '', @nOut) then
  begin
    nSQL := AdjustListStrFormat2(FListC, '''', True, ',', False, False);
    nSQL := Format('Delete From %s Where P_ID In (%s)', [sTable_PoundLog, nSQL]);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
    raise Exception.Create(nOut.FData);
  end;

  Result := True;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessOrders.CallMe(const nCmd: Integer;
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
    nPacker.InitData(@nIn, True, False);
    //init
    
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
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

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessOrders, sPlug_ModuleBus);
end.
