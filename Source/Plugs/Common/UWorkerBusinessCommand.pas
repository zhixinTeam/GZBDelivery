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
    class procedure InitLadingBillItem(var nItem: TLadingBillItem);
    //初始化数据
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
    function GetBatcodeAfterLine(var nData: string): Boolean;
    //现场刷卡后获取批次号
    function GetLineGroupByCustom(var nData: string): Boolean;
    //根据客户信息获取通道分组

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

    //根据货单号获取货单信息-原材料
    function get_shopPurchasebyNO(var nData:string):Boolean;

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

  function DateTime2StrOracle(const nDT: TDateTime): string;
  function Date2StrOracle(const nDT: TDateTime): string;
  //Oracle Time Field

implementation
uses
  UMgrQueue, UWorkerClientWebChat;


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

//Desc: 初始化提货结构数据
class procedure TMITDBWorker.InitLadingBillItem(var nItem: TLadingBillItem);
var nDef: TLadingBillItem;
begin
  FillChar(nDef, SizeOf(nDef), #0);
  nItem := nDef;
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
   cBC_GetBatcodeAfterLine : Result := GetBatcodeAfterLine(nData);
   cBC_GetLineGroupByCustom: Result := GetLineGroupByCustom(nData);

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
   cBC_WeChat_get_shopPurchasebyNO : Result := get_shopPurchasebyNO(nData);
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
    if RecordCount<1 then
    begin
      nData := '无匹配的磁卡信息';
      Exit;
    end;

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
          '  XCB_Sublader,' +                     //工地编号
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
          '  XCB_IsLock,' +                       //锁定标记:0,正常;1,锁定
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
        FListB.Values['XCB_Sublader']   := FieldByName('XCB_Sublader').AsString;
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
        FListB.Values['XCB_IsLock']     := FieldByName('XCB_IsLock').AsString;
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
    end;

    if Values['XCB_IsLock'] = '1' then
    begin
      nStr := '※.单据:[ %s ]已锁定.' + #13#10;
      nData := Format(nStr, [Values['XCB_CardId']]);
    end;
    //单据锁定,无法提货

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
var nIdx: Integer;
    nStr, nType: string;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nStr := 'Select C_Param From ' + sTable_Customer;
  //init

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
    nStr := 'Select XOB_ID,XOB_Code,XOB_Name,XOB_JianPin,XOB_Status,XOB_ISAREA ' +
            'From XS_Compy_Base ' +
            'Where XOB_IsClient=1 or XOB_ISAREA=1';
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

          if FieldByName('XOB_ISAREA').AsString = '1' then
               nType := sFlag_Yes                     //工地,虚拟客户
          else nType := sFlag_No;                     //非工地,销售客户

          nStr := MakeSQLByStr([SF('C_ID', FieldByName('XOB_ID').AsString),
                  SF('C_Name', FieldByName('XOB_Name').AsString),
                  SF('C_PY', FieldByName('XOB_JianPin').AsString),
                  SF('C_Param', FieldByName('XOB_ID').AsString),
                  SF('C_XuNi', nType)
                  ], sTable_Customer, '', True);
          FListA.Add(nStr);

          FListB.Add(FieldByName('XOB_ID').AsString);
          //防止重复查到
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

  {$IFDEF NoSecurityCodeQuery}
  FOut.FData := '';
  Exit;
  {$ENDIF}

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

  {$IFDEF CODECOMMON}
  //生成提货单号
  nBill_id := nSprefix+Copy(nCode, 1, 6) + //YYMMDD
              Copy(nCode, 12, Length(nCode) - 11); //XXXX
  {$ENDIF}

  {$IFDEF CODEAREA}
  //生成提货单号
  nBill_id := nSprefix+Copy(nCode, 1, nIdlen); //YYMMDDXXXX
  {$ENDIF}

  {$IFDEF CODEBATCODE}
  //生成提货单号
  nBill_id := nSprefix+Copy(nCode, 1, nIdlen); //YYMMDDXXXX
  {$ENDIF}


  //查询数据库
  nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
      'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,' +
      'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue,l_project,l_area,'+
      'l_workaddr,l_transname,l_hydan,l_outfact From $Bill b ';
  nStr := nStr + 'Where L_ID=''$CD''';
  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', nBill_id)]);

  nDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
  if nDs.RecordCount<1 then
  begin
    SetLength(nBills, 1);
    InitLadingBillItem(nBills[0]);
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

      FProject := nDs.FieldByName('l_project').AsString;
      FArea := nDs.FieldByName('l_area').AsString;
      Fworkaddr := nDs.FieldByName('l_workaddr').AsString;
      Ftransname := nDs.FieldByName('l_transname').AsString;
      Fhydan := nDs.FieldByName('l_hydan').AsString;
      Foutfact := nDs.FieldByName('l_outfact').AsDateTime;
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
      if not nLine.FIsValid then Continue;
      //通道无效

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
    nVal,nPrice: Double;
    nStockNo:string;
begin
  Result := False;
  nCusID := FIn.FData;
  if nCusID = '' then Exit;
  //未传递客户号

  nStockNo := Fin.FExtParam;
  if nStockNo = '' then Exit;
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
var nWorker: PDBWorker;
    nTmp,nStr:string;
begin
  Result := False;
  nTmp := Trim(FIn.FData);
  if nTmp='' then Exit;

  nStr := 'Select * From ' +
        '(select xcb.XCB_ID,' +                      //内部编号
        '  xcb.XCB_CardId,' +                       //销售卡片编号
        '  xcb.XCB_Origin,' +                       //卡片来源
        '  xcb.XCB_BillID,' +                       //来源单据号
        '  xcb.XCB_SetDate,' +                      //办理日期
        '  xcb.XCB_CardType,' +                     //卡片类型
        '  xcb.XCB_SourceType,' +                   //来源类型
        '  xcb.XCB_Option,' +                       //控制方式:0,控单价;1,控数量
        '  xcb.XCB_Client,' +                       //客户编号
        '  xob.XOB_Name as XCB_ClientName,' +       //客户名称
        '  xgd.XOB_Name as XCB_WorkAddr,' +         //工程工地
        '  xcb.XCB_Alias,' +                        //客户别名
        '  xcb.XCB_OperMan,' +                      //业务员
        '  xcb.XCB_Area,' +                         //销售区域
        '  xcb.XCB_CementType as XCB_Cement,' +     //品种编号
        '  PCM_Name as XCB_CementName,' +           //品种名称
        '  xcb.XCB_LadeType,' +                     //提货方式
        '  xcb.XCB_Number,' +                       //初始数量
        '  xcb.XCB_FactNum,' +                      //已开数量
        '  xcb.XCB_PreNum,' +                       //原已提量
        '  xcb.XCB_ReturnNum,' +                    //退货数量
        '  xcb.XCB_OutNum,' +                       //转出数量
        '  vcb.XCB_FactRemain,' +                   //剩余数量
        '  xcb.XCB_ValidS,XCB_ValidE,' +            //提货有效期
        '  xcb.XCB_AuditState,' +                   //审核状态
        '  xcb.XCB_Status,' +                       //卡片状态:0,停用;1,启用;2,冲红;3,作废
        '  xcb.XCB_IsImputed,' +                    //卡片是否估算
        '  xcb.XCB_IsOnly,' +                       //是否一车一票
        '  xcb.XCB_Del,' +                          //删除标记:0,正常;1,删除
        '  xcb.XCB_Creator,' +                      //创建人
        '  pub.pub_name as XCB_CreatorNM,' +        //创建人名
        '  xcb.XCB_CDate,' +                        //创建时间
        '  xcb.XCB_Firm,' +                         //所属厂区
        '  pbf.pbf_name as XCB_FirmName,' +         //工厂名称
        '  pcb.pcb_id, pcb.pcb_name, ' +            //销售片区
        '  '''' as XCB_TransID, ' +                 //运输单位编号
        '  '''' as XCB_TransName ' +                //运输单位
        'from XS_Card_Base xcb' +
        '  left join XS_Compy_Base xob on xob.XOB_ID = xcb.XCB_Client' +
        '  left join XS_Compy_Base xgd on xgd.XOB_ID = xcb.xcb_sublader' +
        '  left join PB_Code_Material pcm on pcm.PCM_ID = xcb.XCB_CementType' +
        '  Left Join pb_code_block pcb On pcb.pcb_id=xob.xob_block' +
        '  Left Join pb_basic_firm pbf On pbf.pbf_id=xcb.xcb_firm' +
        '  Left Join PB_USER_BASE pub on pub.pub_id=xcb.xcb_creator ' +
        '  Left Join v_Card_Base1 vcb on vcb.XCB_ID=xcb.XCB_ID ' +
        //未删除、可用数量大于0、卡片启用并且处于已审核状态、未锁定
        ' where  xcb.xcb_del=''0'''
              +' and xcb.XCB_Status=''1'''
              +' and vcb.XCB_FactRemain>0'
              +' and xcb.XCB_IsLock<>''1'''
              +' and ((xcb.XCB_AuditState=''201'') or (xcb.XCB_IsOnly=''1''))'
              +' and xcb.XCB_Client = ''%s'' ' +
        'Order By xcb.XCB_SetDate DESC) t Where Rownum <= 100';
        //排序后,取前100条
  nStr := Format(nStr,[nTmp]);

  WriteLog(Format('GetOrderList = > [ 订单信息.%s ]', [nStr]));
  //查询语句

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_YT) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('未查询到客户编号[ %s ]对应的订单信息1.', [nTmp]);
        Exit;
      end;

      FListA.Clear;
      FListB.Clear;
      First;

      while not Eof do
      try
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

        FListA.Add(PackerEncodeStr(FListB.Text));
      finally
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  if FListA.Count < 1 then
  begin
    nData := Format('未查询到客户编号[ %s ]对应的订单信息2.', [FIn.FData]);
    Exit;
  end;

  FOut.FData := PackerEncodeStr(FListA.Text);
  Result := True;
end;

//获取采购合同列表，用于网上下单
function TWorkerBusinessCommander.GetPurchaseContractList(var nData:string):Boolean;
var nStr:string; dSet:TDataSet;
begin
  Result := False;
  //nStr := 'select * from %s where provider_code=''%s'' and con_status>0 and con_quantity-con_finished_quantity>0.00001';
  nStr := 'select * from %s where provider_code=''%s'' and con_status>0';
  nStr := format(nStr,[sTable_PurchaseContract,Trim(FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
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
      //荆门无合同表 执行申请表查询
      if dSet.RecordCount < 1 then
      begin
        nStr := format(nStr,[sTable_OrderBase,Trim(FIn.FData)]);
        nData := Format('未查询到供应商[ %s ]对应的订单信息.', [FIn.FData]);
        Exit;
      end;
    end;

    FListA.Clear;
    FListB.Clear;
    First;
    while not Eof do
    try

      FListB.Values['pcId'] := FieldByName('pcId').AsString;
      FListB.Values['provider_code'] := FieldByName('provider_code').AsString;
      FListB.Values['provider_name'] := FieldByName('provider_name').AsString;
      FListB.Values['con_code'] := FieldByName('con_code').AsString;
      FListB.Values['con_materiel_Code'] := FieldByName('con_materiel_Code').AsString;
      FListB.Values['con_materiel_name'] := FieldByName('con_materiel_name').AsString;
      FListB.Values['con_price'] := FieldByName('con_price').AsString;
      FListB.Values['con_quantity'] := FieldByName('con_quantity').AsString;
      FListB.Values['con_finished_quantity'] := FieldByName('con_finished_quantity').AsString;
      if FieldByName('con_finished_quantity').AsFloat<0.000001 then
      begin
        FListB.Values['con_finished_quantity'] := '0';
      end;
      FListB.Values['con_date'] := FieldByName('con_date').AsString;
      FListB.Values['con_remark'] := FieldByName('con_remark').AsString;
      FListA.Add(PackerEncodeStr(FListB.Text));

    finally
      Next;
    end;
  end;  

  FOut.FData := PackerEncodeStr(FListA.Text);
  Result := True;
end;

//获取客户注册信息
function TWorkerBusinessCommander.getCustomerInfo(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_getCustomerInfo);
  if Result then
       FOut.FData := nOut.FData
  else nData := nOut.FData;
end;

//客户与微信账号绑定
function TWorkerBusinessCommander.get_Bindfunc(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_get_Bindfunc);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
end;

//发送消息
function TWorkerBusinessCommander.send_event_msg(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_send_event_msg);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
end;

//新增商城用户
function TWorkerBusinessCommander.edit_shopclients(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_edit_shopclients);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
end;

//添加商品
function TWorkerBusinessCommander.edit_shopgoods(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_edit_shopgoods);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
end;

//获取订单信息
function TWorkerBusinessCommander.get_shoporders(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_get_shoporders);
  if Result then
       FOut.FData := nOut.FData
  else nData := nOut.FData;
end;

//根据订单号获取订单信息
function TWorkerBusinessCommander.get_shoporderbyno(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_get_shoporderbyNO);
  if Result then
       FOut.FData := nOut.FData
  else nData := nOut.FData;
end;

//根据货单号获取货单信息-原材料
function TWorkerBusinessCommander.get_shopPurchasebyNO(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_get_shopPurchasebyNO);
  if Result then
       FOut.FData := nOut.FData
  else nData := nOut.FData;
end;

//修改订单状态
function TWorkerBusinessCommander.complete_shoporders(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_complete_shoporders);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
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
          'mcreater.U_Memo As mCreaterID, ' +    //云天过毛司磅员
          'dict.D_ParamC As ytLineID '      +    //云天生产线编号
          ' From $BILL bill ' +
          ' Left Join $USER bcreater On bcreater.U_Name=bill.L_Man ' +
          ' Left Join $USER pcreater On pcreater.U_Name=bill.L_PMan ' +
          ' Left Join $USER mcreater On mcreater.U_Name=bill.L_MMan ' +
          ' Left Join $PLOG plog On plog.P_Bill=bill.L_ID ' +
          ' Left Join $Dict dict On dict.D_Value=bill.L_LineGroup ' +
          '     And dict.D_Name=''$GROUP'' ' +
          'Where L_ID In ($IN)';
  nSQL := MacroValue(nSQL, [MI('$BILL', sTable_Bill), MI('$USER', sTable_User),
          MI('$PLOG', sTable_PoundLog), MI('$IN', nStr),
          MI('$Dict', sTable_SysDict),MI('$GROUP', sFlag_ZTLineGroup)]);

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
        FLineGroup := FieldByName('ytLineID').AsString;
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

        nSetDate := Now;
        //获取当前服务器时间

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

                  SF('XLB_SELLS', FieldByName('XCB_OperMan').AsString),         //业务员
                  SF('XLB_SendArea', FieldByName('XCB_SubLader').AsString),
                  SF('XLB_CarCode', nBills[nIdx].FTruck),
                  SF('XLB_Quantity', '0', sfVal),
                  SF('XLB_PrintNum', '0', sfVal),
                  SF('XLB_IsCarry', '0'),
                  SF('XLB_IsOut', '0'),
                  SF('XLB_IsCheck', '0'),
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

        if nBills[nIdx].FLineGroup <> '' then
        begin
          nStr := YT_NewID('XS_LADE_LOAD', nWorker);
          //id

          nSQL := MakeSQLByStr([SF('XLL_ID', nStr),
                  SF('XLL_LADE', nBills[nIdx].FYTID),
                  SF('XLL_CEMENTCODE', nBills[nIdx].FSeal),
                  SF('XLL_LINE', nBills[nIdx].FLineGroup),
                  SF('XLL_Creator', nBills[nIdx].FMData.FOperator),
                  SF('XLL_CDate', Date2StrOracle(nSetDate), sfVal),
                  SF('XLL_SETDate', Date2StrOracle(nSetDate), sfVal),

                  SF('XLL_STACK', '101')
                  ], 'Xs_Lade_Load', '', True);
          FListA.Add(nSQL + ';'); //插入云天生产线

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
    nWorker: PDBWorker;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    nDateIn, nDateOut, nDateMin: TDateTime;
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
      if nBills[nIdx].FPData.FDate < nBills[nIdx].FMData.FDate then
      begin
        nDateIn := nBills[nIdx].FPData.FDate;
        nDateOut := nBills[nIdx].FMData.FDate;
      end else

      begin
        nDateIn := nBills[nIdx].FMData.FDate;
        nDateOut := nBills[nIdx].FPData.FDate;
      end;    

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

              SF('DTM_InDate', Date2StrOracle(Now), sfVal),                     //获取当前系统时间
              SF('DTM_CDate', DateTime2StrOracle(nDateIn),sfVal),
              SF('DTM_TDate', DateTime2StrOracle(nDateOut),sfVal),
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

                  SF('XLB_SELLS', FieldByName('XCB_OperMan').AsString),         //业务员
                  SF('XLB_SendArea', FieldByName('XCB_SubLader').AsString),
                  SF('XLB_CarCode', nBills[nIdx].FTruck),
                  SF('XLB_Quantity', '0', sfVal),
                  SF('XLB_PrintNum', '0', sfVal),
                  //SF('XLB_OutTime', DateTime2StrOracle(nSetDate), sfVal),
                  //SF('XLB_DoorTime', DateTime2StrOracle(nSetDate), sfVal),
                  SF('XLB_IsCarry', '0'),
                  SF('XLB_IsOut', '0'),
                  SF('XLB_IsCheck', '0'),
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

//------------------------------------------------------------------------------
//Date: 2017/4/5
//Parm: 物料编号等
//Desc: 获取云天批次号信息
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
      FOut.FExtParam := sFlag_Yes;
      Result := True;
      Exit;
    end;
    //无需批次号的物料,业务执行完毕

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
        FOut.FExtParam := sFlag_Yes;
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
                     '※.错误描述: 无可用水泥编号,无法开票(1).';
            nData := Format(nData, [Values['XCB_Cement'],
                     Values['XCB_CementName']]);
            Exit;
          end;

          Values['XCB_CementRecords'] := PackerEncodeStr(FListB.Text);
        end;

        FOut.FData := PackerEncodeStr(FListA.Text);
        FOut.FExtParam := sFlag_No;
        Result := True;
      end;
    finally
      gDBConnManager.ReleaseConnection(nDBWorker);
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/4/5
//Parm: 物料编号;车间编号
//Desc: 现场刷卡后获取物料批次号
function TWorkerBusinessCommander.GetBatcodeAfterLine(var nData: string): Boolean;
var nSQL, nStr: string;
    nUpdate: Boolean;
    nIdx: Integer;
    nVal: Double;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  //解析数据

  nSQL := 'Select D_ParamB From %s Where D_Name=''%s'' And D_Value=''%s''';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_ZTLineGroup,
          FListA.Values['LineGroup']]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
    FListA.Values['XCB_OutASH'] := Fields[0].AsString;
  //获取生产线对应的仓库编号

  if not CallMe(cBC_GetYTBatchCode, PackerEncodeStr(FListA.Text), '', @nOut) then
  begin
    nData := nOut.FData;
    nSQL := 'Select * From %s Where E_ID=''%s''';
    nSQL := Format(nSQL, [sTable_ManualEvent, FListA.Values['ID']]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      nStr := '事件记录:[ %s ]已存在';
      nStr := Format(nStr, [FListA.Values['ID']]);

      WriteLog(nStr);
      nUpdate := True;
    end else nUpdate := False;

    nStr := SF('E_ID', FListA.Values['ID']);
    nSQL := MakeSQLByStr([
            SF('E_ID', FListA.Values['ID']),
            SF('E_Key', ''),
            SF('E_Result', ''),
            SF('E_From', sFlag_DepJianZhuang),

            SF('E_Event', nData),
            SF('E_Solution', sFlag_Solution_YN),
            SF('E_Departmen', sFlag_DepJianZhuang),
            SF('E_Date', sField_SQLServer_Now, sfVal)
            ], sTable_ManualEvent, nStr, (not nUpdate));
    gDBConnManager.WorkerExec(FDBConn, nSQL);
    Exit;
  end;

  Result := nOut.FExtParam = sFlag_Yes;

  if not Result then
  begin
    FListB.Text := PackerDecodeStr(nOut.FData);
    FListC.Text := PackerDecodeStr(FListB.Values['XCB_CementRecords']);
    //获取批次号剩余量明细

    for nIdx := 0 to FListC.Count - 1 do
    begin
      FListD.Text := PackerDecodeStr(FListC[nIdx]);
      nVal := StrToFloat(FListD.Values['XCB_CementValue']);

      if FloatRelation(nVal, StrToFloat(FListA.Values['Value']), rtGreater) then
      begin
        FListA.Values['XCB_CementCodeID'] := FListD.Values['XCB_CementCodeID'];
        FListA.Values['XCB_CementCode']   := FListD.Values['XCB_CementCode'];

        FOut.FData := PackerEncodeStr(FListA.Text);
        Result := True;
        Exit;
      end;
    end;

    nData := '※.水泥编号: %s ' +
             '※.水泥名称: %s ' +
             '※.错误描述: 无可用水泥编号,无法开票(2).';
    nData := Format(nData, [FListA.Values['XCB_Cement'],
             FListA.Values['XCB_CementName']]);
    //xxxxx

    nSQL := 'Select * From %s Where E_ID=''%s''';
    nSQL := Format(nSQL, [sTable_ManualEvent, FListA.Values['ID']]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      nStr := '事件记录:[ %s ]已存在';
      nStr := Format(nStr, [FListA.Values['ID']]);

      WriteLog(nStr);
      nUpdate := True;
    end else nUpdate := False;

    nStr := SF('E_ID', FListA.Values['ID']);
    nSQL := MakeSQLByStr([
            SF('E_ID', FListA.Values['ID']),
            SF('E_Key', ''),
            SF('E_Result', ''),
            SF('E_From', sFlag_DepJianZhuang),
          
            SF('E_Event', nData),
            SF('E_Solution', sFlag_Solution_YN),
            SF('E_Departmen', sFlag_DepJianZhuang),
            SF('E_Date', sField_SQLServer_Now, sfVal)
            ], sTable_ManualEvent, nStr, (not nUpdate));
    gDBConnManager.WorkerExec(FDBConn, nSQL);
  end;  
end;

//Date: 2017/03/30
//Parm: 云天批次号(FIn.FData)
//Desc: 同步云天批次号信息
function TWorkerBusinessCommander.SyncYT_BatchCodeInfo(var nData: string): Boolean;
var nStr: string;
    nIdx,nInt: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  FListB.Clear;
  Result := False;

  nDBWorker := nil;
  try
    //nStr := 'Select * From v_notify_print Where CNO_Del=''0'' ';
    nStr := 'select cno.CNO_ID,cno.CNO_NOTIFYID,cno.CNO_CEMENTCODE,'+
            'cno.CNO_CEMENTYEAR,cno.CNO_PACKCODE,cno.CNO_CEMENT,cno.CNO_DEPOSITARY,'+
            'cno.CNO_COUNT,cno.CNO_REMAINCOUNT,cno.CNO_PACKDATE,cno.CNO_SETDATE,cno.CNO_OPERMAN,'+
            'cno.CNO_CLIENTID,cno.CNO_STATUS,cno.CNO_DEL,cno.CNO_CREATOR,'+
            'cno.CNO_CDATE,cno.CNO_MENDER,cno.CNO_MDATE,cno.CNO_FIRM,'
            +'to_char(substr(cno.CNO_REMARK,1,500)) as CNO_REMARK,'+
            'pf_analy_outwork.*, ' +
            'hf_analy_outwork.*,pcd_name,pf_analy_native.*,' +
            'PCM_ID,pcm_molding ' +
            'from cf_notify_outwork cno ' +
            'left join  pf_analy_outwork on trim(cno_cementcode) = trim(paw_analy) ' +
            'left join hf_analy_outwork on cno_cementcode=haw_analy ' +
            'left join pb_code_material mater1 on mater1.pcm_id=paw_cement ' +
            'left join pb_code_detail a on a.pcd_code=CNO_Cement ' +
            '          and a.pcd_type=''701'' and a.pcd_del=''0'' ' +
            'left join pf_analy_native on PAW_Cement=PAN_Intensity ' +
            'where paw_del=''0'' ';
    //已删除的批次号不同步

    if FIn.FData <> '' then
    begin
      nStr := nStr + ' And Paw_analy=''%s''';
      nStr := Format(nStr, [FIn.FData]);
    end;  
    //指定同步的批次号

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        nStr := SF('Paw_analy', FieldByName('Paw_analy').AsString);
        nStr := MakeSQLByStr([
                SF('CNO_ID', FieldByName('CNO_ID').AsString),
                SF('CNO_NotifyID', FieldByName('CNO_NotifyID').AsString),
                SF('CNO_CementCode', FieldByName('CNO_CementCode').AsString),
                SF('CNO_CementYear', FieldByName('CNO_CementYear').AsString),
                SF('CNO_PackCode', FieldByName('CNO_PackCode').AsString),
                SF('CNO_Cement', FieldByName('CNO_Cement').AsString),
                SF('CNO_Depositary', FieldByName('CNO_Depositary').AsString),
                SF('CNO_Count', FieldByName('CNO_Count').AsString),
                SF('CNO_RemainCount', FieldByName('CNO_RemainCount').AsString),
                SF('CNO_PackDate', FieldByName('CNO_PackDate').AsString),
                SF('CNO_SetDate', FieldByName('CNO_SetDate').AsString),
                SF('CNO_OperMan', FieldByName('CNO_OperMan').AsString),
                SF('CNO_ClientID', FieldByName('CNO_ClientID').AsString),
                SF('CNO_Status', FieldByName('CNO_Status').AsString),
                SF('CNO_Del', FieldByName('CNO_Del').AsString),
                SF('CNO_Creator', FieldByName('CNO_Creator').AsString),
                SF('CNO_CDate', FieldByName('CNO_CDate').AsString),
                SF('CNO_Mender', FieldByName('CNO_Mender').AsString),
                SF('CNO_MDate', FieldByName('CNO_MDate').AsString),
                SF('CNO_Firm', FieldByName('CNO_Firm').AsString),
                SF('CNO_Remark', FieldByName('CNO_Remark').AsString),

                SF('PAW_ID', FieldByName('PAW_ID').AsString),
                SF('PAW_Analy', FieldByName('PAW_Analy').AsString),
                SF('PAW_Cement', FieldByName('PAW_Cement').AsString),
                SF('PAW_Intensity', FieldByName('PAW_Intensity').AsString),
                SF('PAW_Store', FieldByName('PAW_Store').AsString),
                SF('PAW_OutDate', FieldByName('PAW_OutDate').AsString),
                SF('PAW_Outnumber', FieldByName('PAW_Outnumber').AsString),
                SF('PAW_Stability', FieldByName('PAW_Stability').AsString),
                SF('PAW_ProduDate', FieldByName('PAW_ProduDate').AsString),
                SF('PAW_MoldDate', FieldByName('PAW_MoldDate').AsString),
                SF('PAW_Cohereend', FieldByName('PAW_Cohereend').AsString),
                SF('PAW_Facttab', FieldByName('PAW_Facttab').AsString),
                SF('PAW_Thick', FieldByName('PAW_Thick').AsString),
                SF('PAW_Fine', FieldByName('PAW_Fine').AsString),
                SF('PAW_Waterash', FieldByName('PAW_Waterash').AsString),
                SF('PAW_SurfaceArea', FieldByName('PAW_SurfaceArea').AsString),
                SF('PAW_Mixture', FieldByName('PAW_Mixture').AsString),
                SF('PAW_MoldMan', FieldByName('PAW_MoldMan').AsString),
                SF('PAW_WhipMan', FieldByName('PAW_WhipMan').AsString),
                SF('PAW_CohereMan', FieldByName('PAW_CohereMan').AsString),
                SF('PAW_BreakMan', FieldByName('PAW_BreakMan').AsString),
                SF('PAW_Remark', FieldByName('PAW_Remark').AsString),
                SF('PAW_3Dcensor', FieldByName('PAW_3Dcensor').AsString),
                SF('PAW_3Dconceit', FieldByName('PAW_3Dconceit').AsString),
                SF('PAW_3DcenMan', FieldByName('PAW_3DcenMan').AsString),
                SF('PAW_3DcenDate', FieldByName('PAW_3DcenDate').AsString),
                SF('PAW_28Dcensor', FieldByName('PAW_28Dcensor').AsString),
                SF('PAW_28Dconceit', FieldByName('PAW_28Dconceit').AsString),
                SF('PAW_28DcenMan', FieldByName('PAW_28DcenMan').AsString),
                SF('PAW_28DcenDate', FieldByName('PAW_28DcenDate').AsString),
                SF('PAW_IsAudit', FieldByName('PAW_IsAudit').AsString),
                SF('PAW_AuditMan', FieldByName('PAW_AuditMan').AsString),
                SF('PAW_AuditDate', FieldByName('PAW_AuditDate').AsString),
                SF('PAW_Del', FieldByName('PAW_Del').AsString),
                SF('PAW_Creator', FieldByName('PAW_Creator').AsString),
                SF('PAW_CDate', FieldByName('PAW_CDate').AsString),
                SF('PAW_Mender', FieldByName('PAW_Mender').AsString),
                SF('PAW_MDate', FieldByName('PAW_MDate').AsString),

                SF('PAW_Temp0', FieldByName('PAW_Temp0').AsString),
                SF('PAW_Temp1', FieldByName('PAW_Temp1').AsString),
                SF('PAW_Temp2', FieldByName('PAW_Temp2').AsString),
                SF('PAW_Temp3', FieldByName('PAW_Temp3').AsString),
                SF('PAW_Temp4', FieldByName('PAW_Temp4').AsString),
                SF('PAW_Temp5', FieldByName('PAW_Temp5').AsString),
                SF('PAW_Temp6', FieldByName('PAW_Temp6').AsString),
                SF('PAW_Temp7', FieldByName('PAW_Temp7').AsString),
                SF('PAW_Temp8', FieldByName('PAW_Temp8').AsString),
                SF('PAW_Temp9', FieldByName('PAW_Temp9').AsString),

                SF('PAW_Temp10', FieldByName('PAW_Temp10').AsString),
                SF('PAW_Temp11', FieldByName('PAW_Temp11').AsString),
                SF('PAW_Temp12', FieldByName('PAW_Temp12').AsString),
                SF('PAW_Temp13', FieldByName('PAW_Temp13').AsString),
                SF('PAW_Temp14', FieldByName('PAW_Temp14').AsString),
                SF('PAW_Temp15', FieldByName('PAW_Temp15').AsString),
                SF('PAW_Temp16', FieldByName('PAW_Temp16').AsString),
                SF('PAW_Temp17', FieldByName('PAW_Temp17').AsString),
                SF('PAW_Temp18', FieldByName('PAW_Temp18').AsString),
                SF('PAW_Temp19', FieldByName('PAW_Temp19').AsString),

                SF('PAW_Temp20', FieldByName('PAW_Temp20').AsString),
                SF('PAW_Temp21', FieldByName('PAW_Temp21').AsString),
                SF('PAW_Temp22', FieldByName('PAW_Temp22').AsString),
                SF('PAW_Temp23', FieldByName('PAW_Temp23').AsString),
                SF('PAW_Temp24', FieldByName('PAW_Temp24').AsString),
                SF('PAW_Temp25', FieldByName('PAW_Temp25').AsString),
                SF('PAW_Temp26', FieldByName('PAW_Temp26').AsString),
                SF('PAW_Temp27', FieldByName('PAW_Temp27').AsString),
                SF('PAW_Temp28', FieldByName('PAW_Temp28').AsString),
                SF('PAW_Temp29', FieldByName('PAW_Temp29').AsString),

                SF('PAW_Temp30', FieldByName('PAW_Temp30').AsString),
                SF('PAW_Temp31', FieldByName('PAW_Temp31').AsString),
                SF('PAW_Temp32', FieldByName('PAW_Temp32').AsString),
                SF('PAW_Temp33', FieldByName('PAW_Temp33').AsString),
                SF('PAW_Temp34', FieldByName('PAW_Temp34').AsString),
                SF('PAW_Temp35', FieldByName('PAW_Temp35').AsString),
                SF('PAW_Temp36', FieldByName('PAW_Temp36').AsString),
                SF('PAW_Temp37', FieldByName('PAW_Temp37').AsString),
                SF('PAW_Temp38', FieldByName('PAW_Temp38').AsString),
                SF('PAW_Temp39', FieldByName('PAW_Temp39').AsString),

                SF('PAW_Temp40', FieldByName('PAW_Temp40').AsString),
                SF('PAW_Temp41', FieldByName('PAW_Temp41').AsString),
                SF('PAW_Temp42', FieldByName('PAW_Temp42').AsString),
                SF('PAW_Temp43', FieldByName('PAW_Temp43').AsString),
                SF('PAW_Temp44', FieldByName('PAW_Temp44').AsString),
                SF('PAW_Temp45', FieldByName('PAW_Temp45').AsString),
                SF('PAW_Temp46', FieldByName('PAW_Temp46').AsString),
                SF('PAW_Temp47', FieldByName('PAW_Temp47').AsString),
                SF('PAW_Temp48', FieldByName('PAW_Temp48').AsString),
                SF('PAW_Temp49', FieldByName('PAW_Temp49').AsString),

                SF('PAW_Temp50', FieldByName('PAW_Temp50').AsString),
                SF('PAW_Temp51', FieldByName('PAW_Temp51').AsString),
                SF('PAW_Temp52', FieldByName('PAW_Temp52').AsString),
                SF('PAW_Temp53', FieldByName('PAW_Temp53').AsString),
                SF('PAW_Temp54', FieldByName('PAW_Temp54').AsString),
                SF('PAW_Temp55', FieldByName('PAW_Temp55').AsString),
                SF('PAW_Temp56', FieldByName('PAW_Temp56').AsString),
                SF('PAW_Temp57', FieldByName('PAW_Temp57').AsString),
                SF('PAW_Temp58', FieldByName('PAW_Temp58').AsString),
                SF('PAW_Temp59', FieldByName('PAW_Temp59').AsString),

                SF('PAW_Temp60', FieldByName('PAW_Temp60').AsString),
                SF('PAW_Temp61', FieldByName('PAW_Temp61').AsString),
                SF('PAW_Temp62', FieldByName('PAW_Temp62').AsString),
                SF('PAW_Temp63', FieldByName('PAW_Temp63').AsString),
                SF('PAW_Temp64', FieldByName('PAW_Temp64').AsString),
                SF('PAW_Temp65', FieldByName('PAW_Temp65').AsString),
                SF('PAW_Temp66', FieldByName('PAW_Temp66').AsString),
                SF('PAW_Temp67', FieldByName('PAW_Temp67').AsString),
                SF('PAW_Temp68', FieldByName('PAW_Temp68').AsString),
                SF('PAW_Temp69', FieldByName('PAW_Temp69').AsString),

                SF('PAW_Temp70', FieldByName('PAW_Temp70').AsString),
                SF('PAW_Temp71', FieldByName('PAW_Temp71').AsString),
                SF('PAW_Temp72', FieldByName('PAW_Temp72').AsString),
                SF('PAW_Temp73', FieldByName('PAW_Temp73').AsString),
                SF('PAW_Temp74', FieldByName('PAW_Temp74').AsString),
                SF('PAW_Temp75', FieldByName('PAW_Temp75').AsString),
                SF('PAW_Temp76', FieldByName('PAW_Temp76').AsString),
                SF('PAW_Temp77', FieldByName('PAW_Temp77').AsString),
                SF('PAW_Temp78', FieldByName('PAW_Temp78').AsString),
                SF('PAW_Temp79', FieldByName('PAW_Temp79').AsString),

                SF('PAW_Temp80', FieldByName('PAW_Temp80').AsString),
                SF('PAW_Temp81', FieldByName('PAW_Temp81').AsString),
                SF('PAW_Temp82', FieldByName('PAW_Temp82').AsString),
                SF('PAW_Temp83', FieldByName('PAW_Temp83').AsString),
                SF('PAW_Temp84', FieldByName('PAW_Temp84').AsString),
                SF('PAW_Temp85', FieldByName('PAW_Temp85').AsString),
                SF('PAW_Temp86', FieldByName('PAW_Temp86').AsString),
                SF('PAW_Temp87', FieldByName('PAW_Temp87').AsString),
                SF('PAW_Temp88', FieldByName('PAW_Temp88').AsString),
                SF('PAW_Temp89', FieldByName('PAW_Temp89').AsString),

                SF('PAW_Temp90', FieldByName('PAW_Temp90').AsString),
                SF('PAW_Temp91', FieldByName('PAW_Temp91').AsString),
                SF('PAW_Temp92', FieldByName('PAW_Temp92').AsString),
                SF('PAW_Temp93', FieldByName('PAW_Temp93').AsString),
                SF('PAW_Temp94', FieldByName('PAW_Temp94').AsString),
                SF('PAW_Temp95', FieldByName('PAW_Temp95').AsString),
                SF('PAW_Temp96', FieldByName('PAW_Temp96').AsString),
                SF('PAW_Temp97', FieldByName('PAW_Temp97').AsString),
                SF('PAW_Temp98', FieldByName('PAW_Temp98').AsString),
                SF('PAW_Temp99', FieldByName('PAW_Temp99').AsString),

                SF('PAW_Temp100', FieldByName('PAW_Temp100').AsString),
                SF('PAW_Temp101', FieldByName('PAW_Temp101').AsString),
                SF('PAW_Temp102', FieldByName('PAW_Temp102').AsString),
                SF('PAW_Temp103', FieldByName('PAW_Temp103').AsString),
                SF('PAW_Temp104', FieldByName('PAW_Temp104').AsString),
                SF('PAW_Temp105', FieldByName('PAW_Temp105').AsString),
                SF('PAW_Temp106', FieldByName('PAW_Temp106').AsString),
                SF('PAW_Temp107', FieldByName('PAW_Temp107').AsString),
                SF('PAW_Temp108', FieldByName('PAW_Temp108').AsString),
                SF('PAW_Temp109', FieldByName('PAW_Temp109').AsString),

                SF('PAW_Temp110', FieldByName('PAW_Temp110').AsString),
                SF('PAW_Temp111', FieldByName('PAW_Temp111').AsString),
                SF('PAW_Temp112', FieldByName('PAW_Temp112').AsString),
                SF('PAW_Temp113', FieldByName('PAW_Temp113').AsString),
                SF('PAW_Temp114', FieldByName('PAW_Temp114').AsString),
                SF('PAW_Temp115', FieldByName('PAW_Temp115').AsString),
                SF('PAW_Temp116', FieldByName('PAW_Temp116').AsString),
                SF('PAW_Temp117', FieldByName('PAW_Temp117').AsString),
                SF('PAW_Temp118', FieldByName('PAW_Temp118').AsString),
                SF('PAW_Temp119', FieldByName('PAW_Temp119').AsString),

                SF('PAW_Temp120', FieldByName('PAW_Temp20').AsString),
                SF('PAW_Temp121', FieldByName('PAW_Temp21').AsString),
                SF('PAW_Temp122', FieldByName('PAW_Temp22').AsString),
                SF('PAW_Temp123', FieldByName('PAW_Temp23').AsString),
                SF('PAW_Temp124', FieldByName('PAW_Temp24').AsString),
                SF('PAW_Temp125', FieldByName('PAW_Temp25').AsString),
                SF('PAW_Temp126', FieldByName('PAW_Temp26').AsString),
                SF('PAW_Temp127', FieldByName('PAW_Temp27').AsString),
                SF('PAW_Temp128', FieldByName('PAW_Temp28').AsString),
                SF('PAW_Temp129', FieldByName('PAW_Temp29').AsString),

                SF('PAW_Temp130', FieldByName('PAW_Temp130').AsString),
                SF('PAW_Temp131', FieldByName('PAW_Temp131').AsString),
                SF('PAW_Temp132', FieldByName('PAW_Temp132').AsString),
                SF('PAW_Temp133', FieldByName('PAW_Temp133').AsString),
                SF('PAW_Temp134', FieldByName('PAW_Temp134').AsString),
                SF('PAW_Temp135', FieldByName('PAW_Temp135').AsString),
                SF('PAW_Temp136', FieldByName('PAW_Temp136').AsString),
                SF('PAW_Temp137', FieldByName('PAW_Temp137').AsString),
                SF('PAW_Temp138', FieldByName('PAW_Temp138').AsString),
                SF('PAW_Temp139', FieldByName('PAW_Temp139').AsString),
                SF('PAW_Temp141', FieldByName('PAW_Temp141').AsString),
                SF('PAW_Temp143', FieldByName('PAW_Temp143').AsString),
                SF('PAW_Temp145', FieldByName('PAW_Temp145').AsString)
                ],sTable_YT_Batchcode, nStr, False);
        //更新信息
        FListA.Add(nStr);
        //先更新，更新失败则插入

        nStr := MakeSQLByStr([
                SF('CNO_ID', FieldByName('CNO_ID').AsString),
                SF('CNO_NotifyID', FieldByName('CNO_NotifyID').AsString),
                SF('CNO_CementCode', FieldByName('CNO_CementCode').AsString),
                SF('CNO_CementYear', FieldByName('CNO_CementYear').AsString),
                SF('CNO_PackCode', FieldByName('CNO_PackCode').AsString),
                SF('CNO_Cement', FieldByName('CNO_Cement').AsString),
                SF('CNO_Depositary', FieldByName('CNO_Depositary').AsString),
                SF('CNO_Count', FieldByName('CNO_Count').AsString),
                SF('CNO_RemainCount', FieldByName('CNO_RemainCount').AsString),
                SF('CNO_PackDate', FieldByName('CNO_PackDate').AsString),
                SF('CNO_SetDate', FieldByName('CNO_SetDate').AsString),
                SF('CNO_OperMan', FieldByName('CNO_OperMan').AsString),
                SF('CNO_ClientID', FieldByName('CNO_ClientID').AsString),
                SF('CNO_Status', FieldByName('CNO_Status').AsString),
                SF('CNO_Del', FieldByName('CNO_Del').AsString),
                SF('CNO_Creator', FieldByName('CNO_Creator').AsString),
                SF('CNO_CDate', FieldByName('CNO_CDate').AsString),
                SF('CNO_Mender', FieldByName('CNO_Mender').AsString),
                SF('CNO_MDate', FieldByName('CNO_MDate').AsString),
                SF('CNO_Firm', FieldByName('CNO_Firm').AsString),
                SF('CNO_Remark', FieldByName('CNO_Remark').AsString),

                SF('PAW_ID', FieldByName('PAW_ID').AsString),
                SF('PAW_Analy', FieldByName('PAW_Analy').AsString),
                SF('PAW_Cement', FieldByName('PAW_Cement').AsString),
                SF('PAW_Intensity', FieldByName('PAW_Intensity').AsString),
                SF('PAW_Store', FieldByName('PAW_Store').AsString),
                SF('PAW_OutDate', FieldByName('PAW_OutDate').AsString),
                SF('PAW_Outnumber', FieldByName('PAW_Outnumber').AsString),
                SF('PAW_Stability', FieldByName('PAW_Stability').AsString),
                SF('PAW_ProduDate', FieldByName('PAW_ProduDate').AsString),
                SF('PAW_MoldDate', FieldByName('PAW_MoldDate').AsString),
                SF('PAW_Cohereend', FieldByName('PAW_Cohereend').AsString),
                SF('PAW_Facttab', FieldByName('PAW_Facttab').AsString),
                SF('PAW_Thick', FieldByName('PAW_Thick').AsString),
                SF('PAW_Fine', FieldByName('PAW_Fine').AsString),
                SF('PAW_Waterash', FieldByName('PAW_Waterash').AsString),
                SF('PAW_SurfaceArea', FieldByName('PAW_SurfaceArea').AsString),
                SF('PAW_Mixture', FieldByName('PAW_Mixture').AsString),
                SF('PAW_MoldMan', FieldByName('PAW_MoldMan').AsString),
                SF('PAW_WhipMan', FieldByName('PAW_WhipMan').AsString),
                SF('PAW_CohereMan', FieldByName('PAW_CohereMan').AsString),
                SF('PAW_BreakMan', FieldByName('PAW_BreakMan').AsString),
                SF('PAW_Remark', FieldByName('PAW_Remark').AsString),
                SF('PAW_3Dcensor', FieldByName('PAW_3Dcensor').AsString),
                SF('PAW_3Dconceit', FieldByName('PAW_3Dconceit').AsString),
                SF('PAW_3DcenMan', FieldByName('PAW_3DcenMan').AsString),
                SF('PAW_3DcenDate', FieldByName('PAW_3DcenDate').AsString),
                SF('PAW_28Dcensor', FieldByName('PAW_28Dcensor').AsString),
                SF('PAW_28Dconceit', FieldByName('PAW_28Dconceit').AsString),
                SF('PAW_28DcenMan', FieldByName('PAW_28DcenMan').AsString),
                SF('PAW_28DcenDate', FieldByName('PAW_28DcenDate').AsString),
                SF('PAW_IsAudit', FieldByName('PAW_IsAudit').AsString),
                SF('PAW_AuditMan', FieldByName('PAW_AuditMan').AsString),
                SF('PAW_AuditDate', FieldByName('PAW_AuditDate').AsString),
                SF('PAW_Del', FieldByName('PAW_Del').AsString),
                SF('PAW_Creator', FieldByName('PAW_Creator').AsString),
                SF('PAW_CDate', FieldByName('PAW_CDate').AsString),
                SF('PAW_Mender', FieldByName('PAW_Mender').AsString),
                SF('PAW_MDate', FieldByName('PAW_MDate').AsString),

                SF('PAW_Temp0', FieldByName('PAW_Temp0').AsString),
                SF('PAW_Temp1', FieldByName('PAW_Temp1').AsString),
                SF('PAW_Temp2', FieldByName('PAW_Temp2').AsString),
                SF('PAW_Temp3', FieldByName('PAW_Temp3').AsString),
                SF('PAW_Temp4', FieldByName('PAW_Temp4').AsString),
                SF('PAW_Temp5', FieldByName('PAW_Temp5').AsString),
                SF('PAW_Temp6', FieldByName('PAW_Temp6').AsString),
                SF('PAW_Temp7', FieldByName('PAW_Temp7').AsString),
                SF('PAW_Temp8', FieldByName('PAW_Temp8').AsString),
                SF('PAW_Temp9', FieldByName('PAW_Temp9').AsString),

                SF('PAW_Temp10', FieldByName('PAW_Temp10').AsString),
                SF('PAW_Temp11', FieldByName('PAW_Temp11').AsString),
                SF('PAW_Temp12', FieldByName('PAW_Temp12').AsString),
                SF('PAW_Temp13', FieldByName('PAW_Temp13').AsString),
                SF('PAW_Temp14', FieldByName('PAW_Temp14').AsString),
                SF('PAW_Temp15', FieldByName('PAW_Temp15').AsString),
                SF('PAW_Temp16', FieldByName('PAW_Temp16').AsString),
                SF('PAW_Temp17', FieldByName('PAW_Temp17').AsString),
                SF('PAW_Temp18', FieldByName('PAW_Temp18').AsString),
                SF('PAW_Temp19', FieldByName('PAW_Temp19').AsString),

                SF('PAW_Temp20', FieldByName('PAW_Temp20').AsString),
                SF('PAW_Temp21', FieldByName('PAW_Temp21').AsString),
                SF('PAW_Temp22', FieldByName('PAW_Temp22').AsString),
                SF('PAW_Temp23', FieldByName('PAW_Temp23').AsString),
                SF('PAW_Temp24', FieldByName('PAW_Temp24').AsString),
                SF('PAW_Temp25', FieldByName('PAW_Temp25').AsString),
                SF('PAW_Temp26', FieldByName('PAW_Temp26').AsString),
                SF('PAW_Temp27', FieldByName('PAW_Temp27').AsString),
                SF('PAW_Temp28', FieldByName('PAW_Temp28').AsString),
                SF('PAW_Temp29', FieldByName('PAW_Temp29').AsString),

                SF('PAW_Temp30', FieldByName('PAW_Temp30').AsString),
                SF('PAW_Temp31', FieldByName('PAW_Temp31').AsString),
                SF('PAW_Temp32', FieldByName('PAW_Temp32').AsString),
                SF('PAW_Temp33', FieldByName('PAW_Temp33').AsString),
                SF('PAW_Temp34', FieldByName('PAW_Temp34').AsString),
                SF('PAW_Temp35', FieldByName('PAW_Temp35').AsString),
                SF('PAW_Temp36', FieldByName('PAW_Temp36').AsString),
                SF('PAW_Temp37', FieldByName('PAW_Temp37').AsString),
                SF('PAW_Temp38', FieldByName('PAW_Temp38').AsString),
                SF('PAW_Temp39', FieldByName('PAW_Temp39').AsString),

                SF('PAW_Temp40', FieldByName('PAW_Temp40').AsString),
                SF('PAW_Temp41', FieldByName('PAW_Temp41').AsString),
                SF('PAW_Temp42', FieldByName('PAW_Temp42').AsString),
                SF('PAW_Temp43', FieldByName('PAW_Temp43').AsString),
                SF('PAW_Temp44', FieldByName('PAW_Temp44').AsString),
                SF('PAW_Temp45', FieldByName('PAW_Temp45').AsString),
                SF('PAW_Temp46', FieldByName('PAW_Temp46').AsString),
                SF('PAW_Temp47', FieldByName('PAW_Temp47').AsString),
                SF('PAW_Temp48', FieldByName('PAW_Temp48').AsString),
                SF('PAW_Temp49', FieldByName('PAW_Temp49').AsString),

                SF('PAW_Temp50', FieldByName('PAW_Temp50').AsString),
                SF('PAW_Temp51', FieldByName('PAW_Temp51').AsString),
                SF('PAW_Temp52', FieldByName('PAW_Temp52').AsString),
                SF('PAW_Temp53', FieldByName('PAW_Temp53').AsString),
                SF('PAW_Temp54', FieldByName('PAW_Temp54').AsString),
                SF('PAW_Temp55', FieldByName('PAW_Temp55').AsString),
                SF('PAW_Temp56', FieldByName('PAW_Temp56').AsString),
                SF('PAW_Temp57', FieldByName('PAW_Temp57').AsString),
                SF('PAW_Temp58', FieldByName('PAW_Temp58').AsString),
                SF('PAW_Temp59', FieldByName('PAW_Temp59').AsString),

                SF('PAW_Temp60', FieldByName('PAW_Temp60').AsString),
                SF('PAW_Temp61', FieldByName('PAW_Temp61').AsString),
                SF('PAW_Temp62', FieldByName('PAW_Temp62').AsString),
                SF('PAW_Temp63', FieldByName('PAW_Temp63').AsString),
                SF('PAW_Temp64', FieldByName('PAW_Temp64').AsString),
                SF('PAW_Temp65', FieldByName('PAW_Temp65').AsString),
                SF('PAW_Temp66', FieldByName('PAW_Temp66').AsString),
                SF('PAW_Temp67', FieldByName('PAW_Temp67').AsString),
                SF('PAW_Temp68', FieldByName('PAW_Temp68').AsString),
                SF('PAW_Temp69', FieldByName('PAW_Temp69').AsString),

                SF('PAW_Temp70', FieldByName('PAW_Temp70').AsString),
                SF('PAW_Temp71', FieldByName('PAW_Temp71').AsString),
                SF('PAW_Temp72', FieldByName('PAW_Temp72').AsString),
                SF('PAW_Temp73', FieldByName('PAW_Temp73').AsString),
                SF('PAW_Temp74', FieldByName('PAW_Temp74').AsString),
                SF('PAW_Temp75', FieldByName('PAW_Temp75').AsString),
                SF('PAW_Temp76', FieldByName('PAW_Temp76').AsString),
                SF('PAW_Temp77', FieldByName('PAW_Temp77').AsString),
                SF('PAW_Temp78', FieldByName('PAW_Temp78').AsString),
                SF('PAW_Temp79', FieldByName('PAW_Temp79').AsString),

                SF('PAW_Temp80', FieldByName('PAW_Temp80').AsString),
                SF('PAW_Temp81', FieldByName('PAW_Temp81').AsString),
                SF('PAW_Temp82', FieldByName('PAW_Temp82').AsString),
                SF('PAW_Temp83', FieldByName('PAW_Temp83').AsString),
                SF('PAW_Temp84', FieldByName('PAW_Temp84').AsString),
                SF('PAW_Temp85', FieldByName('PAW_Temp85').AsString),
                SF('PAW_Temp86', FieldByName('PAW_Temp86').AsString),
                SF('PAW_Temp87', FieldByName('PAW_Temp87').AsString),
                SF('PAW_Temp88', FieldByName('PAW_Temp88').AsString),
                SF('PAW_Temp89', FieldByName('PAW_Temp89').AsString),

                SF('PAW_Temp90', FieldByName('PAW_Temp90').AsString),
                SF('PAW_Temp91', FieldByName('PAW_Temp91').AsString),
                SF('PAW_Temp92', FieldByName('PAW_Temp92').AsString),
                SF('PAW_Temp93', FieldByName('PAW_Temp93').AsString),
                SF('PAW_Temp94', FieldByName('PAW_Temp94').AsString),
                SF('PAW_Temp95', FieldByName('PAW_Temp95').AsString),
                SF('PAW_Temp96', FieldByName('PAW_Temp96').AsString),
                SF('PAW_Temp97', FieldByName('PAW_Temp97').AsString),
                SF('PAW_Temp98', FieldByName('PAW_Temp98').AsString),
                SF('PAW_Temp99', FieldByName('PAW_Temp99').AsString),

                SF('PAW_Temp100', FieldByName('PAW_Temp100').AsString),
                SF('PAW_Temp101', FieldByName('PAW_Temp101').AsString),
                SF('PAW_Temp102', FieldByName('PAW_Temp102').AsString),
                SF('PAW_Temp103', FieldByName('PAW_Temp103').AsString),
                SF('PAW_Temp104', FieldByName('PAW_Temp104').AsString),
                SF('PAW_Temp105', FieldByName('PAW_Temp105').AsString),
                SF('PAW_Temp106', FieldByName('PAW_Temp106').AsString),
                SF('PAW_Temp107', FieldByName('PAW_Temp107').AsString),
                SF('PAW_Temp108', FieldByName('PAW_Temp108').AsString),
                SF('PAW_Temp109', FieldByName('PAW_Temp109').AsString),

                SF('PAW_Temp110', FieldByName('PAW_Temp110').AsString),
                SF('PAW_Temp111', FieldByName('PAW_Temp111').AsString),
                SF('PAW_Temp112', FieldByName('PAW_Temp112').AsString),
                SF('PAW_Temp113', FieldByName('PAW_Temp113').AsString),
                SF('PAW_Temp114', FieldByName('PAW_Temp114').AsString),
                SF('PAW_Temp115', FieldByName('PAW_Temp115').AsString),
                SF('PAW_Temp116', FieldByName('PAW_Temp116').AsString),
                SF('PAW_Temp117', FieldByName('PAW_Temp117').AsString),
                SF('PAW_Temp118', FieldByName('PAW_Temp118').AsString),
                SF('PAW_Temp119', FieldByName('PAW_Temp119').AsString),

                SF('PAW_Temp120', FieldByName('PAW_Temp20').AsString),
                SF('PAW_Temp121', FieldByName('PAW_Temp21').AsString),
                SF('PAW_Temp122', FieldByName('PAW_Temp22').AsString),
                SF('PAW_Temp123', FieldByName('PAW_Temp23').AsString),
                SF('PAW_Temp124', FieldByName('PAW_Temp24').AsString),
                SF('PAW_Temp125', FieldByName('PAW_Temp25').AsString),
                SF('PAW_Temp126', FieldByName('PAW_Temp26').AsString),
                SF('PAW_Temp127', FieldByName('PAW_Temp27').AsString),
                SF('PAW_Temp128', FieldByName('PAW_Temp28').AsString),
                SF('PAW_Temp129', FieldByName('PAW_Temp29').AsString),

                SF('PAW_Temp130', FieldByName('PAW_Temp130').AsString),
                SF('PAW_Temp131', FieldByName('PAW_Temp131').AsString),
                SF('PAW_Temp132', FieldByName('PAW_Temp132').AsString),
                SF('PAW_Temp133', FieldByName('PAW_Temp133').AsString),
                SF('PAW_Temp134', FieldByName('PAW_Temp134').AsString),
                SF('PAW_Temp135', FieldByName('PAW_Temp135').AsString),
                SF('PAW_Temp136', FieldByName('PAW_Temp136').AsString),
                SF('PAW_Temp137', FieldByName('PAW_Temp137').AsString),
                SF('PAW_Temp138', FieldByName('PAW_Temp138').AsString),
                SF('PAW_Temp139', FieldByName('PAW_Temp139').AsString),
                SF('PAW_Temp141', FieldByName('PAW_Temp141').AsString),
                SF('PAW_Temp143', FieldByName('PAW_Temp143').AsString),
                SF('PAW_Temp145', FieldByName('PAW_Temp145').AsString)
                ],sTable_YT_Batchcode, '', True);
        //插入信息

        nIdx := FListA.Count - 1;
        FListB.Values['Index_' + IntToStr(nIdx)] := PackerEncodeStr(nStr);
        //更新失败则插入信息
      finally
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nInt := -1;
  //init

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;

    for nIdx:=0 to FListA.Count - 1 do
    begin
      nInt := nIdx;
      if gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]) < 1 then
       gDBConnManager.WorkerExec(FDBConn,
        PackerDecodeStr(FListB.Values['Index_' + IntToStr(nIdx)]));
      //xxxxx
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
  	on E:Exception do
  	begin
      if nInt > -1 then
      begin
	  	  writelog('SyncYT_BatchCodeInfo exception:' + e.Message +
                 ',sql1=[' + FListA[nInt] + ']');
	  	  writelog('SyncYT_BatchCodeInfo exception:' + e.Message +
                 ',sql2=[' + FListB.Values['Index_' + IntToStr(nInt)] + ']');
      end;

	    if FDBConn.FConn.InTransaction then
	      FDBConn.FConn.RollbackTrans;
	    raise;  	
  	end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/4/25
//Parm: 客户编号(FIn.FData);工地编号(FIn.FExtParam)
//Desc: 根据客户信息获取指定分组
function TWorkerBusinessCommander.GetLineGroupByCustom(var nData: string): Boolean;
var nSQL, nAddID, nStock: string;
    nIdx: Integer;
begin
  Result := True;
  FOut.FData := '';

  nIdx := Pos(';', FIn.FExtParam);
  nStock := Copy(FIn.FExtParam, 1, nIdx-1);
  nAddID := Copy(FIn.FExtParam, nIdx+1, Length(FIn.FExtParam)-nIdx);

  nSQL := 'Select * From %s Where M_CusID=''%s''';
  nSQL := Format(nSQL, [sTable_YT_CusBatMap, FIn.FData]);
  //只搜索对应客户的批次

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then Exit;

    First;
    FListA.Clear;

    while not Eof do
    try
      with FListC do
      begin
        Clear;
        Values['IsVip'] := FieldByName('M_IsVip').AsString;
        Values['CusID'] := FieldByName('M_CusID').AsString;
        Values['AddrID'] := FieldByName('M_AddrID').AsString;
        Values['StockNo']:= FieldByName('M_StockNo').AsString;
        Values['LineGroup'] := FieldByName('M_LineGroup').AsString;
      end;

      FListA.Add(PackerEncodeStr(FListC.Text));
    finally
      Next;
    end;
  end;

  for nIdx := 0 to FListA.Count - 1 do
  begin
    FListB.Clear;
    FListB.Text := PackerDecodeStr(FListA[nIdx]);

    if (FListB.Values['StockNo'] <> '') and             //规则中含有品种编号
       (FListB.Values['StockNo'] = nStock) then
    begin
      FOut.FData := FListB.Values['LineGroup'];
      FOut.FExtParam := FListB.Values['IsVIP'];
      Exit;
    end;
  end;
  //带有品种编号的规则优先

  for nIdx := 0 to FListA.Count - 1 do
  begin
    FListB.Clear;
    FListB.Text := PackerDecodeStr(FListA[nIdx]);

    if FListB.Values['StockNo'] <> '' then Continue;
    if (FListB.Values['AddrID'] <> '') and             //规则中含有工厂工地
       (FListB.Values['AddrID'] = nAddID) then
    begin
      FOut.FData := FListB.Values['LineGroup'];
      FOut.FExtParam := FListB.Values['IsVIP'];
      Exit;
    end;
  end;
  //带有工程工地的规则优先

  for nIdx := 0 to FListA.Count - 1 do
  begin
    FListB.Clear;
    FListB.Text := PackerDecodeStr(FListA[nIdx]);

    if FListB.Values['StockNo'] <> '' then Continue;
    if FListB.Values['AddrID'] <> '' then Continue;

    FOut.FData := FListB.Values['LineGroup'];
    FOut.FExtParam := FListB.Values['IsVIP'];
    Exit;
  end;
  //检测不带工程工地的规则
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
end.
