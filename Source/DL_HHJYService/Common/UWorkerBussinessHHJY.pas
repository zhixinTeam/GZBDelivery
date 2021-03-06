{*******************************************************************************
  作者: juner11212436@163.com 2018-10-25
  描述: 恒河久远相关业务和数据处理
*******************************************************************************}
unit UWorkerBussinessHHJY;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, DB, ADODB, NativeXml, UBusinessWorker,
  UBusinessPacker, UBusinessConst, UMgrDBConn, UMgrParam, UFormCtrl, USysLoger,
  ZnMD5, ULibFun, USysDB, UMITConst, UMgrChannel, UWorkerBusiness,IdHTTP,Graphics,
  Variants, uLkJSON,DateUtils, V_Sys_Materiel_Intf, T_Sys_SaleCustomer_Intf,
  T_SupplyProvider_Intf, V_SaleConsignPlanBill_Intf, V_SaleValidConsignPlanBill_Intf,
  T_SaleConsignBill_Intf, V_QControlWareNumberNoticeBill_Intf,
  T_SaleTransportForCustomer_Intf, V_SupplyMaterialEntryPlan_Intf,
  T_SupplyMaterialReceiveBill_Intf, V_SupplyMaterialTransferPlan_Intf,
  T_SupplyMaterialTransferBill_Intf, T_SupplyWeighBill_Intf, T_SaleScheduleVan_Intf,
  V_QChemistryTestBill_Intf, V_QPhysicsRecord_Intf, V_QPhysicsWRONCRecord_Intf,
  V_QPhysicsSettingTimeRecord_Intf,V_QPhysicsFinenessRecord_Intf,
  V_QPhysicsSpecificSurfaceAreaRecord_Intf,V_QPhysicsIntensityRecord_Intf,
  QAdmixtureDataBrief_WS_Intf,QAdmixtureDataDetail_WS_Intf, xxykt_Intf,
  uSuperObject, UObjectList;

const
  cHttpTimeOut          = 10;
  
var
  gSapURLInited: Integer = 0;      //是否初始化

type
  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //错误码
    FDBConn: PDBWorker;
    //数据通道
    FXXChannel: PChannelItem;
    FDataIn,FDataOut: PBWDataBase;
    //入参出参
    FDataOutNeedUnPack: Boolean;
    //需要解包
    FPackOut: Boolean;
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

  TBusWorkerBusinessHHJY = class(TMITDBWorker)
  private
    FListA,FListB,FListC,FListD,FListE: TStrings;
    //list
    FIn: TWorkerHHJYData;
    FOut: TWorkerHHJYData;
    //in out
    FChannel: TIdHTTP;
    FUrl: string;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function SyncHhSaleMateriel(var nData:string):boolean;
    //同步销售物料
    function SyncHhCustomer(var nData:string):boolean;
    //同步销售客户
    function SyncHhProvider(var nData:string):boolean;
    //同步供应商
    function BillVerifyHhSalePlan(var nData:string):boolean;
    //销售计划开单校验
    function IsHhSaleDetailExits(var nData: string): Boolean;
    //查询销售发货明细
    function GetHhSaleDetailID(var nData: string): Boolean;
    //获取新增销售发货明细ID
    function GetHhSaleWareNumber(var nData: string): Boolean;
    //获取批次号
    function GetHhSaleWTTruck(var nData: string): Boolean;
    //获取派车单
    function SyncHhSaleWareNumber(var nData: string): Boolean;
    //同步批次号
    function GetHhSaleRealPrice(var nData: string): Boolean;
    //获取最新价格
    function SyncHhOrderPlan(var nData: string): Boolean;
    //获取普通原材料进厂计划
    function SyncHhOrderDetail(var nData: string): Boolean;
    //同步普通原材料收货明细
    function IsHhOrderDetailExits(var nData: string): Boolean;
    //查询普通原材料收货明细
    function GetHhOrderDetailID(var nData: string): Boolean;
    //获取新增普通原材料收货明细ID
    function SyncHhNdOrderPlan(var nData: string): Boolean;
    //获取内倒原材料进厂计划
    function IsHhNdOrderDetailExits(var nData: string): Boolean;
    //查询内倒原材料收货明细
    function GetHhNdOrderDetailID(var nData: string): Boolean;
    //获取新增内倒原材料收货明细ID
    function IsHhOtherOrderDetailExits(var nData: string): Boolean;
    //查询内倒原材料收货明细
    function GetHhOtherOrderDetailID(var nData: string): Boolean;
    //获取新增内倒原材料收货明细ID
    function GetHhHYWlNjTime(var nData: string): Boolean;
    //获取化验单物理分析数据凝结时间
    function GetHhHYWlXD(var nData: string): Boolean;
    //获取化验单物理分析数据细度
    function GetHhHYWlBiBiao(var nData: string): Boolean;
    //获取化验单物理分析数据比表面积
    function GetHhHYWlQD(var nData: string): Boolean;
    //获取化验单物理分析数据强度
    function GetHhHYHhcDetail(var nData: string): Boolean;
    //获取化验单混合材

    procedure ReQuestInit;
    function GetWLFYSaleInfo(var nData: string): Boolean;
    //获取物流发运销售单
    function SyncWLFYSalePound(var nData: string): Boolean;
    //同步销售反馈磅单
    function SyncWLFYOrderPound(var nData: string): Boolean;
    //同步采购反馈磅单
    function SyncWLFYOrderInfo(var nData: string): Boolean;
    //同步采购订单信息
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

implementation

//Date: 2012-3-13
//Parm: 如参数护具
//Desc: 获取连接数据库所需的资源
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;
  FXXChannel := nil;

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

    FXXChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(FXXChannel) then
    begin
      nData := '连接ERP服务失败(Wechat Web Service No Channel).';
      Exit;
    end;

    with FXXChannel^ do
    begin
      if not Assigned(FChannel) then
        FChannel := Coxxykt.Create(FMsg, FHttp);
      FHttp.TargetUrl := gSysParam.FERPSrv;
    end; //config web service channel

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
      if FPackOut then
      begin
        WriteLog('打包');
        nData := FPacker.PackOut(FDataOut);
      end;

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
    gChannelManager.ReleaseChannel(FXXChannel);
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
class function TBusWorkerBusinessHHJY.FunctionName: string;
begin
  Result := sBus_BusinessHHJY;
end;

constructor TBusWorkerBusinessHHJY.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
  FListE := TStringList.Create;
  
  inherited;
end;

destructor TBusWorkerBusinessHHJY.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  FreeAndNil(FListE);
  inherited;
end;

function TBusWorkerBusinessHHJY.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessHHJY;
  end;
end;

procedure TBusWorkerBusinessHHJY.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TBusWorkerBusinessHHJY.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerHHJYData;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessHHJY);
    nPacker.InitData(@nIn, True, False);
    //init

    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessHHJY);
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

//Date: 2017-09-24
//Desc: 创建对象
function NewHttp(const nClass: TClass): TObject;
begin
  Result := TIdHTTP.Create(nil);
end;

//Date: 2017-09-24
//Desc: 释放对象
procedure FreeHttp(const nObject: TObject);
begin
  TIdHTTP(nObject).Free;
end;

//Date: 2012-3-22
//Parm: 输入数据
//Desc: 执行nData业务指令
function TBusWorkerBusinessHHJY.DoDBWork(var nData: string): Boolean;
var
  nInt: Integer;
  nItem: PObjectPoolItem;
begin
  nInt := InterlockedExchange(gSapURLInited, 10);
  try
    if nInt < 1 then
    begin
      if not Assigned(gObjectPoolManager) then
        gObjectPoolManager := TObjectPoolManager.Create;
      gObjectPoolManager.RegClass(TIdHTTP, NewHttp, FreeHttp);
    end;
  except
    InterlockedExchange(gSapURLInited, nInt);
  end;

  nItem := nil;
  try
    Result := False;
    nItem := gObjectPoolManager.LockObject(TIdHTTP);

    if not Assigned(nItem) then
    begin
      nData := '连接Sap失败(IdHTTP Is Null).';
      Exit;
    end;

    FChannel := nItem.FObject as TIdHTTP;


    with FOut.FBase do
    begin
      FResult := True;
      FErrCode := 'S.00';
      FErrDesc := '业务执行成功.';
    end;
    FPackOut := True;

  //  case FIn.FCommand of
  //   cBC_SyncHhSaleDetail        : FPackOut := False;
  //  end;

    case FIn.FCommand of
      cBC_FYWLGetSaleInfo:   Result := GetWLFYSaleInfo(nData);
      cBC_FYWLSynSalePound:  Result := SyncWLFYSalePound(nData);
      cBC_FYWLSynOrderPound: Result := SyncWLFYOrderPound(nData);
      cBC_FYWLSynOrderInfo:  Result := SyncWLFYOrderInfo(nData);
    else
      begin
        Result := False;
        nData := '无效的业务代码(Code: %d Invalid Command).';
        nData := Format(nData, [FIn.FCommand]);
      end;
    end;

  finally
    gObjectPoolManager.ReleaseObject(nItem);
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhSaleMateriel(
  var nData: string): boolean;
var nStr,nType: string;
    nInt, nIdx: Integer;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
begin
  Result := False;

  WriteLog('同步物料入参'+nStr);

  nStr := Ixxykt(FXXChannel^.FChannel).Load_Inv('03');

  nStr := UTF8Encode(nStr);
  try
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    if not Assigned(nJS) then
    begin
      nData := '同步物料接口调用异常.格式无法解析:' + nStr;
      WriteLog(nData);
      Exit;
    end;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '同步物料接口调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    FListB.Clear;
    FListC.Clear;

    if nJS.Field['DATA'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['DATA'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '同步物料接口调用异常.' + FIn.FData + 'Data节点为空';
        WriteLog(nData);
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        FListA.Clear;
        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;

        if Pos('袋',FListA.Values['cInvName']) > 0 then
          nType := sFlag_Dai
        else
          nType := sFlag_San;

        nStr := SF('D_ParamB', FListA.Values['cInvCode']);
        nStr := MakeSQLByStr([SF('D_Value',
                FListA.Values['cInvName']),
                SF('D_Memo', nType)
                ], sTable_SysDict, nStr, False);
        //xxxxx
        FListB.Add(nStr);

        nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
                SF('D_ParamB', FListA.Values['cInvCode']),
                SF('D_Value', FListA.Values['cInvName']),
                SF('D_Memo', nType)
                ], sTable_SysDict, '', True);
        //xxxxx
        FListC.Add(nStr);
      end;
    end
    else
    begin
      nData := '接口调用异常.Data节点异常';
      WriteLog(nData);
      Exit;
    end;

    if FListB.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;

      for nIdx:=0 to FListB.Count - 1 do
      begin
        if gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]) <= 0 then
        begin
          gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    if Assigned(nJS) then
      nJS.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhCustomer(
  var nData: string): boolean;
var nStr: string;
    nInt, nIdx: Integer;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
begin
  Result := False;
  nStr := PackerDecodeStr(FIn.FData);


  try
    WriteLog('同步销售客户入参'+nStr);

    nStr := Ixxykt(FXXChannel^.FChannel).Load_Cus(nStr);


    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    if not Assigned(nJS) then
    begin
      nData := '同步客户档案接口调用异常.格式无法解析:' + nStr;
      WriteLog(nData);
      Exit;
    end;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '同步销售客户接口调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    FListB.Clear;
    FListC.Clear;

    if nJS.Field['DATA'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['DATA'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '同步销售客户接口调用异常.' + FIn.FData + 'Data节点为空';
        WriteLog(nData);
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        FListA.Clear;
        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;

        nStr := SF('C_ID', FListA.Values['cCusCode']);
        nStr := MakeSQLByStr([
                SF('C_Name', FListA.Values['cCusName']),
                SF('C_PY', GetPinYinOfStr(FListA.Values['cCusName'])),
                SF('C_Addr', FListA.Values['FAddress']),
                SF('C_Phone', FListA.Values['FOfficeTelCode']),
                SF('C_Tax', FListA.Values['FFaxCode']),
                SF('C_Bank', FListA.Values['FBankNames']),
                SF('C_Memo', FListA.Values['FCustomerCode']),
                SF('C_Account', FListA.Values['FIDcardnumber'])
                ], sTable_Customer, nStr, False);
        FListB.Add(nStr);

        nStr := MakeSQLByStr([SF('C_ID', FListA.Values['cCusCode']),
                SF('C_Name', FListA.Values['cCusName']),
                SF('C_PY', GetPinYinOfStr(FListA.Values['cCusName'])),
                SF('C_Addr', FListA.Values['FAddress']),
                SF('C_Phone', FListA.Values['FOfficeTelCode']),
                SF('C_Tax', FListA.Values['FFaxCode']),
                SF('C_Bank', FListA.Values['FBankNames']),
                SF('C_Account', FListA.Values['FIDcardnumber']),
                SF('C_Memo', FListA.Values['FCustomerCode']),
                SF('C_XuNi', sFlag_No)
                ], sTable_Customer, '', True);
        FListC.Add(nStr);
      end;
    end
    else
    begin
      nData := '接口调用异常.Data节点异常';
      WriteLog(nData);
      Exit;
    end;

    if FListB.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;

      for nIdx:=0 to FListB.Count - 1 do
      begin
        if gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]) <= 0 then
        begin
          gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    if Assigned(nJS) then
      nJS.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhProvider(
  var nData: string): boolean;
var nStr: string;
    nInt, nIdx: Integer;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
begin
  Result := False;

  nStr := PackerDecodeStr(FIn.FData);

  WriteLog('同步供应商入参'+nStr);

  nStr := Ixxykt(FXXChannel^.FChannel).Load_Ven(nStr);
  WriteLog('同步供应商出参'+nStr);

  nStr := UTF8Encode(nStr);
  try
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    if not Assigned(nJS) then
    begin
      nData := '同步供应商接口调用异常.格式无法解析:' + nStr;
      WriteLog(nData);
      Exit;
    end;

    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '同步供应商接口调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    FListB.Clear;
    FListC.Clear;

    if nJS.Field['DATA'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['DATA'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '同步供应商接口调用异常.' + FIn.FData + 'Data节点为空';
        WriteLog(nData);
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        FListA.Clear;
        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;

        nStr := SF('P_ID', FListA.Values['cVenCode']);
        nStr := MakeSQLByStr([
                SF('P_Name', FListA.Values['cVenName']),
                SF('P_Memo', FListA.Values['FProviderNumber']),
                SF('P_PY', GetPinYinOfStr(FListA.Values['cVenName']))
                ], sTable_Provider, nStr, False);
        FListB.Add(nStr);

        nStr := MakeSQLByStr([SF('P_ID', FListA.Values['cVenCode']),
                SF('P_Name', FListA.Values['cVenName']),
                SF('P_Memo', FListA.Values['FProviderNumber']),
                SF('P_PY', GetPinYinOfStr(FListA.Values['cVenName']))
                ], sTable_Provider, '', True);
        FListC.Add(nStr);
      end;
    end
    else
    begin
      nData := '供应商接口调用异常.Data节点异常';
      WriteLog(nData);
      Exit;
    end;

    if FListB.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;

      for nIdx:=0 to FListB.Count - 1 do
      begin
        if gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]) <= 0 then
        begin
          gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    if Assigned(nJS) then
      nJS.Free;
  end;
end;

function TBusWorkerBusinessHHJY.BillVerifyHhSalePlan(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Text := PackerDecodeStr(FIn.FData);
                           //1003415304
  FListA.Values['Order'] := '1015578701';
  FListA.Values['Value'] := '10';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('开单校验销售订单入参'+FListA.Text);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_SaleValidConsignPlanBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_SaleValidConsignPlanBill(nHHJYChannel^.FChannel).ValidConsignPlanBill(nSoapHeader,
                                   1003415304,
                                   1);

    WriteLog('开单校验销售订单出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '开单校验销售订单调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['Data'].Value))) <= 0 then
    begin
      nData := '开单校验销售订单失败.' + VarToStr(nJS.Field['Data'].Value);
      WriteLog(nData);
      Exit;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.IsHhSaleDetailExits(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Clear;
  nStr := 'FBillNumber = ''%s''';
  nStr := Format(nStr,[PackerDecodeStr(FIn.FData)]);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('查询已上传提货单入参'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SaleConsignBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SaleConsignBill(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                   nStr, '');

    WriteLog('查询已上传提货单出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '查询已上传提货单调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '查询已上传提货单调用异常.Data节点为空';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;
    nData := PackerEncodeStr(FListA.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhSaleDetailID(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListE.Clear;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('获取新增提货单ID入参'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SaleConsignBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SaleConsignBill(nHHJYChannel^.FChannel).InitializationModel(nSoapHeader);

    WriteLog('获取新增提货单ID出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取新增提货单ID调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nJsCol := nJS.Field['Data'] as TlkJSONobject;

    nStr := VarToStr(nJSCol.Field['FBillID'].Value);

    if nStr = '' then
    begin
      nData := '获取新增提货单ID接口调用异常.Data节点FBillID为空';
      Exit;
    end;

    nData := PackerEncodeStr(nStr);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;


function TBusWorkerBusinessHHJY.GetHhSaleWareNumber(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Text := PackerDecodeStr(FIn.FData);
//  FlistA.Values['FactoryID'] := '100000104';
//  FlistA.Values['PackingID'] := '1';
//  FlistA.Values['StockID'] := '11';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('获取批次号入参'+FListA.Text);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QControlWareNumberNoticeBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QControlWareNumberNoticeBill(nHHJYChannel^.FChannel).GetWareNumberNoticeBill(nSoapHeader,
                                   FlistA.Values['FactoryID'],
                                   FlistA.Values['StockID'],
                                   FlistA.Values['PackingID']);

    WriteLog('获取批次号出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取批次号调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '获取批次号调用异常.Data节点为空';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;
    nData := PackerEncodeStr(FListA.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhSaleWTTruck(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Text := PackerDecodeStr(FIn.FData);
//  FlistA.Values['FactoryID'] := '100000104';
//  FlistA.Values['PackingID'] := '1';
//  FlistA.Values['StockID'] := '11';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('获取委托单入参'+FListA.Text);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SaleTransportForCustomer.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SaleTransportForCustomer(nHHJYChannel^.FChannel).GetTransportListForCustomer(nSoapHeader,
                                   FlistA.Values['CusID'],
                                   FlistA.Values['SaleManID'],
                                   FlistA.Values['StockID'],
                                   FlistA.Values['PackingID']);

    WriteLog('获取委托单出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取委托单调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '获取委托单调用异常.Data节点为空';
        Exit;
      end;
      FListB.Clear;
      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        FListB.Add(PackerEncodeStr(FListA.Text));
      end;
    end;
    nData := PackerEncodeStr(FListB.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhSaleWareNumber(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Text := PackerDecodeStr(FIn.FData);

  WriteLog('同步提货单批次号入参:' + FListA.Text);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QControlWareNumberNoticeBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel

    nStr := IV_QControlWareNumberNoticeBill(nHHJYChannel^.FChannel).P_SaleUpdateQControlWareNumber(nSoapHeader,
                                   FlistA.Values['FFactoryID'],
                                   FlistA.Values['FMaterielID'],
                                   FlistA.Values['FPackingID'],
                                   FlistA.Values['FWareNumber'],
                                   FlistA.Values['FConsignBillID']);


    WriteLog('同步提货单批次号出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '同步提货单批次号调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '同步提货单批次号调用异常.Data节点为空';
        Exit;
      end;
      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;

      nStr := FlistA.Values['FResult'];

      if Length(nStr) > 0 then
      begin
        nData := '同步提货单批次号失败,返回结果:[' + nStr + ']' + ',水泥编号未找到或已注销';
        Exit;
      end;

      Result := True;
      FOut.FData := '';
      FOut.FBase.FResult := True;
    end;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhSaleRealPrice(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  FListE.Clear;
  FListE.Text := PackerDecodeStr(FIn.FData);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := '获取销售最新价格入参:FContractDetailID[ %s ],' +
            'FTContractDetailID[ %s ],FLoadingSiteID[ %s ]dateTime[ %s ]';
    nStr := Format(nStr,[FListE.Values['FContractDetailID'],
                         FListE.Values['FTContractDetailID'],
                         FListE.Values['FLoadingSiteID'],
                         FListE.Values['FPriceDate']]);
    WriteLog(nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_SaleConsignPlanBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_SaleConsignPlanBill(nHHJYChannel^.FChannel).F_Sale_GetPriceForConsignBill(nSoapHeader,
                                   FlistE.Values['FContractDetailID'],
                                   FlistE.Values['FTContractDetailID'],
                                   FlistE.Values['FLoadingSiteID'],
                                   FListE.Values['FPriceDate']);

    WriteLog('获取销售最新价格出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取销售最新价格调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '获取销售最新价格调用异常.Data节点为空';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListE.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListE.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;

    nData := PackerEncodeStr(FListE.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhOrderPlan(
  var nData: string): boolean;
var nStr: string;
    nInt, nIdx: Integer;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nValue: Double;
begin
  Result := False;
  nStr := PackerDecodeStr(FIn.FData);

  FListD.Clear;

  FListD.Text := nStr;

  try
    WriteLog('获取普通原材料订单入参'+nStr);

    nStr := Ixxykt(FXXChannel^.FChannel).VenInv(FListD.Values['ProviderNo']);

    WriteLog('获取普通原材料订单出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    if not Assigned(nJS) then
    begin
      nData := '同步销售订单接口调用异常.格式无法解析:' + nStr;
      WriteLog(nData);
      Exit;
    end;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取普通原材料订单接口调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['DATA'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['DATA'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '获取普通原材料订单接口调用异常.' + FIn.FData + 'Data节点为空';
        WriteLog(nData);
        Exit;
      end;

      FListA.Clear;
      FListC.Clear;
      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        FListB.Clear;
        FListC.Clear;
        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListC.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;

        with FListB do
        begin
          Values['Order']         := FListC.Values['Order'];
          Values['ProName']       := FListD.Values['ProviderName'];
          Values['ProID']         := FListD.Values['ProviderNo'];
          Values['StockName']     := FListC.Values['cInvName'];
          Values['StockID']       := FListC.Values['cInvCode'];
          Values['StockNo']       := FListC.Values['cInvCode'];

          Values['Value']         := '10000';//剩余量

          FListA.Add(PackerEncodeStr(FListB.Text));
        end;
      end;
      nData := PackerEncodeStr(FListA.Text);
    end
    else
    begin
      nData := '获取普通原材料订单接口调用异常.Data节点异常';
      WriteLog(nData);
      Exit;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    if Assigned(nJS) then
      nJS.Free;
  end;
end;

function TBusWorkerBusinessHHJY.IsHhOrderDetailExits(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Clear;
  nStr := 'FBillNumber = ''%s''';
  nStr := Format(nStr,[PackerDecodeStr(FIn.FData)]);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('查询已上传普通原材料采购单入参'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyMaterialReceiveBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyMaterialReceiveBill(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                   nStr, '');

    WriteLog('查询已上传普通原材料采购单出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '查询已上传普通原材料采购单调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '查询已上传普通原材料采购单调用异常.Data节点为空';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;
    nData := PackerEncodeStr(FListA.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhOrderDetailID(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListE.Clear;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('获取新增普通原材料采购单ID入参'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyMaterialReceiveBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyMaterialReceiveBill(nHHJYChannel^.FChannel).InitializationModel(nSoapHeader);

    WriteLog('获取新增普通原材料采购单ID出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取新增普通原材料采购单ID调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nJsCol := nJS.Field['Data'] as TlkJSONobject;

    nStr := VarToStr(nJSCol.Field['FBillID'].Value);

    if nStr = '' then
    begin
      nData := '获取新增普通原材料采购单ID接口调用异常.Data节点FBillID为空';
      Exit;
    end;

    nData := PackerEncodeStr(nStr);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhOrderDetail(
  var nData: string): boolean;
var nStr,nDateStr,nDelete: string;
    nInt, nIdx: Integer;
    nJS: TlkJSONobject;
begin
  Result := False;

  FListD.Text := PackerDecodeStr(FIn.FData);

  nDelete := '1';

  try
    WriteLog('同步原材料磅单入参'+FListD.Text);

    nStr := 'Select P_ID,P_Truck,P_CusID,P_MID,P_UnLoad,P_YSResult,' +
            ' (P_MValue-P_PValue- isnull(P_KzValue,0)) As P_NetWeight,' +
            ' case when (pl.P_PDate IS not null) and (pl.P_MDate IS not null)'+
            ' then (case when pl.P_PDate > pl.P_MDate then pl.P_PDate else'+
            ' pl.P_MDate end) else pl.P_MDate end as P_Date '+
            ' From $Pound pl ';
    //xxxxx

    nStr := nStr + 'Where P_ID=''$CD''';

    nStr := MacroValue(nStr, [MI('$Pound', sTable_PoundLog), MI('$CD', FListD.Values['ID'])]);

    WriteLog('原材料查询SQL:' + nStr);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if (FieldByName('P_YSResult').AsString = sFlag_No) or
         (FListD.Values['Delete'] = sFlag_Yes) then
        nDelete := '0';
      nDateStr := FieldByName('P_Date').AsString;

      nStr := Ixxykt(FXXChannel^.FChannel).Insert_Rd01(nDelete, nDateStr,
              FieldByName('P_ID').AsString,FieldByName('P_CusID').AsString,
              FieldByName('P_Truck').AsString,FieldByName('P_MID').AsString,
              FieldByName('P_NetWeight').AsString,'0',
              '0',FieldByName('P_UnLoad').AsString);

      WriteLog('同步原材料磅单出参'+nStr);

      nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

      if not Assigned(nJS) then
      begin
        nData := '上传原材料磅单接口调用异常.格式无法解析:' + nStr;
        WriteLog(nData);
        Exit;
      end;

      nStr := VarToStr(nJS.Field['IsSuccess'].Value);

      if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
      begin
        nData := '同步原材料磅单调用异常.' + VarToStr(nJS.Field['Message'].Value);
        WriteLog(nData);
        Exit;
      end;

      nStr :='update %s set P_BDAX=''1'',P_BDNUM=P_BDNUM+1 where P_ID = ''%s'' ';
      nStr := Format(nStr,[sTable_PoundLog,FListD.Values['ID']]);

      gDBConnManager.WorkerExec(FDBConn,nStr);

      FOut.FData := '';
      FOut.FBase.FResult := True;
      Result := True;
    end;
  finally
    if Assigned(nJS) then
      nJS.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncHhNdOrderPlan(
  var nData: string): boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
    nValue: Double;
begin
  Result := False;
  nUrl := '';
  nStr := PackerDecodeStr(FIn.FData);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        if nStr = '' then
          nStr := FDefWhere
        else
        if FDefWhere <> '' then
          nStr := nStr + ' And ' + FDefWhere;
        Break;
      end;
    end;

    WriteLog('获取内倒原材料订单入参'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

        FChannel := CoV_SupplyMaterialTransferPlan.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_SupplyMaterialTransferPlan(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                            nStr, '');

    if Pos('FBillNumber', PackerDecodeStr(FIn.FData)) > 0 then
      WriteLog('获取内倒原材料订单出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取内倒原材料订单接口调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '获取内倒原材料订单接口调用异常.' + FIn.FData + 'Data节点为空';
        WriteLog(nData);
        Exit;
      end;

      if Pos('FBillNumber', PackerDecodeStr(FIn.FData)) > 0 then
      begin
        for nIdx := 0 to nJSRow.Count - 1 do
        begin
          nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

          FListE.Clear;
          for nInt := 0 to nJSCol.Count - 1 do
          begin
            FListE.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
          end;
          nData := PackerEncodeStr(FListE.Text);
        end;
      end
      else
      begin
        FListA.Clear;
        FListC.Clear;
        for nIdx := 0 to nJSRow.Count - 1 do
        begin
          nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

          FListB.Clear;
          FListC.Clear;
          for nInt := 0 to nJSCol.Count - 1 do
          begin
            FListC.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
          end;

          with FListB do
          begin
            Values['Order']         := FListC.Values['FBillNumber'];
            Values['StockName']     := FListC.Values['FMaterielName'];
            Values['StockID']       := FListC.Values['FMaterielID'];
            Values['StockNo']       := FListC.Values['FMaterielNumber'];
            try
              nValue := StrToFloat(FListC.Values['FApproveAmount'])
                        - StrToFloat(FListC.Values['FExecuteAmount']);
              nValue := Float2PInt(nValue, cPrecision, False) / cPrecision;
            except
              nValue := 0;
            end;
            Values['PlanValue']     := FListC.Values['FApproveAmount'];//审批量
            Values['EntryValue']    := FListC.Values['FExecuteAmount'];//已进厂量
            Values['Value']         := FloatToStr(nValue);//剩余量
            Values['Model']         := FListC.Values['FModel'];//型号

            FListA.Add(PackerEncodeStr(FListB.Text));
          end;
        end;
        nData := PackerEncodeStr(FListA.Text);
      end;
    end
    else
    begin
      nData := '获取内倒原材料订单接口调用异常.Data节点异常';
      WriteLog(nData);
      Exit;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.IsHhNdOrderDetailExits(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Clear;
  nStr := 'FBillNumber = ''%s''';
  nStr := Format(nStr,[PackerDecodeStr(FIn.FData)]);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('查询已上传内倒原材料采购单入参'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyMaterialTransferBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyMaterialTransferBill(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                   nStr, '');

    WriteLog('查询已上传内倒原材料采购单出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '查询已上传内倒原材料采购单调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '查询已上传内倒原材料采购单调用异常.Data节点为空';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;
    nData := PackerEncodeStr(FListA.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhNdOrderDetailID(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListE.Clear;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('获取新增内倒原材料采购单ID入参'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyMaterialTransferBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyMaterialTransferBill(nHHJYChannel^.FChannel).InitializationModel(nSoapHeader);

    WriteLog('获取新增内倒原材料采购单ID出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取新增内倒原材料采购单ID调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nJsCol := nJS.Field['Data'] as TlkJSONobject;

    nStr := VarToStr(nJSCol.Field['FBillID'].Value);

    if nStr = '' then
    begin
      nData := '获取新增内倒原材料采购单ID接口调用异常.Data节点FBillID为空';
      Exit;
    end;

    nData := PackerEncodeStr(nStr);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.IsHhOtherOrderDetailExits(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListA.Clear;
  nStr := 'FBillNumber = ''%s''';
  nStr := Format(nStr,[PackerDecodeStr(FIn.FData)]);

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('查询已上传临时称重采购单入参'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyWeighBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyWeighBill(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                   nStr, '');

    WriteLog('查询已上传临时称重采购单出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '查询已上传临时称重采购单调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '查询已上传临时称重采购单调用异常.Data节点为空';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListA.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListA.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
      end;
    end;
    nData := PackerEncodeStr(FListA.Text);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhOtherOrderDetailID(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';
  FListE.Clear;

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    WriteLog('获取新增临时称重采购单ID入参'+nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoT_SupplyWeighBill.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IT_SupplyWeighBill(nHHJYChannel^.FChannel).InitializationModel(nSoapHeader);

    WriteLog('获取新增临时称重采购单ID出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取新增临时称重采购单ID调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    nJsCol := nJS.Field['Data'] as TlkJSONobject;

    nStr := VarToStr(nJSCol.Field['FBillID'].Value);

    if nStr = '' then
    begin
      nData := '获取新增临时称重采购单ID接口调用异常.Data节点FBillID为空';
      Exit;
    end;

    nData := PackerEncodeStr(nStr);

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYWlNjTime(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FRecordID = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('获取化验单物理分析凝结时间入参:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QPhysicsSettingTimeRecord.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QPhysicsSettingTimeRecord(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('获取化验单物理分析凝结时间出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取化验单物理分析凝结时间调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '获取化验单物理分析凝结时间调用异常.Data节点为空';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYWlXD(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FRecordID = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('获取化验单物理分析细度入参:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QPhysicsFinenessRecord.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QPhysicsFinenessRecord(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('获取化验单物理分析细度出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取化验单物理分析细度调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '获取化验单物理分析细度调用异常.Data节点为空';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYWlBiBiao(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FRecordID = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('获取化验单物理分析比表面积入参:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QPhysicsSpecificSurfaceAreaRecord.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QPhysicsSpecificSurfaceAreaRecord(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('获取化验单物理分析比表面积出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取化验单物理分析比表面积调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '获取化验单物理分析比表面积调用异常.Data节点为空';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYWlQD(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FRecordID = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('获取化验单物理分析强度入参:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoV_QPhysicsSpecificSurfaceAreaRecord.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IV_QPhysicsSpecificSurfaceAreaRecord(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('获取化验单物理分析强度出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取化验单物理分析强度调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '获取化验单物理分析强度调用异常.Data节点为空';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetHhHYHhcDetail(
  var nData: string): Boolean;
var nStr, nUrl: string;
    nNode, nRoot: TXmlNode;
    nInt, nIdx: Integer;
    nSoapHeader: MySoapHeader;
    nJS: TlkJSONobject;
    nJSRow: TlkJSONlist;
    nJSCol: TlkJSONobject;
    nHHJYChannel: PChannelItem;
begin
  Result := False;
  nUrl := '';

  nSoapHeader := MySoapHeader.Create;

  try
    for nInt := Low(gSysParam.FHHJYUrl) to High(gSysParam.FHHJYUrl) do
    with gSysParam.FHHJYUrl[nInt] do
    begin
      if FIn.FCommand = FCID then
      begin
        nSoapHeader.Password := FPassword;
        nUrl := FURL;
        Break;
      end;
    end;

    nStr := 'FTestSampleCode = ''%s'' ';
    nStr := Format(nStr, [FIn.FData]);

    WriteLog('获取化验单混合材入参:' + nStr);

    nHHJYChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(nHHJYChannel) then
    begin
      nData := '连接恒河久远服务失败(HHJY Web Service No Channel).';
      Exit;
    end;

    with nHHJYChannel^ do
    begin
      if Assigned(FChannel) then
        FChannel := nil;

      FChannel := CoQAdmixtureDataBrief_WS.Create(FMsg, FHttp);
      FHttp.TargetUrl := nUrl;
    end; //config web service channel


    nStr := IQAdmixtureDataBrief_WS(nHHJYChannel^.FChannel).RetrieveList(nSoapHeader,
                                  nStr, '');

    WriteLog('获取化验单混合材出参'+nStr);

    nStr := UTF8Encode(nStr);
    nJS := TlkJSON.ParseText(nStr) as TlkJSONobject;

    nStr := VarToStr(nJS.Field['IsSuccess'].Value);

    if Pos('TRUE', UpperCase(VarToStr(nJS.Field['IsSuccess'].Value))) <= 0 then
    begin
      nData := '获取化验单混合材调用异常.' + VarToStr(nJS.Field['Message'].Value);
      WriteLog(nData);
      Exit;
    end;

    if nJS.Field['Data'] is TlkJSONlist then
    begin
      nJSRow := nJS.Field['Data'] as TlkJSONlist;

      if nJSRow.Count <= 0 then
      begin
        nData := '获取化验单混合材调用异常.Data节点为空';
        Exit;
      end;

      for nIdx := 0 to nJSRow.Count - 1 do
      begin
        FListB.Clear;
        nJSCol:= nJSRow.Child[nIdx] as TlkJSONobject;

        for nInt := 0 to nJSCol.Count - 1 do
        begin
          FListB.Values[nJSCol.NameOf[nInt]] := VarToStr(nJSCol.Field[nJSCol.NameOf[nInt]].Value);
        end;
        nData := PackerEncodeStr(FListB.Text);
      end;
    end;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  finally
    gChannelManager.ReleaseChannel(nHHJYChannel);
    if Assigned(nJS) then
      nJS.Free;
    nSoapHeader.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetWLFYSaleInfo(
  var nData: string): Boolean;
var
  nStr, nWebOrder, szUrl: string;
  ReJo, ParamJo, OneJo : ISuperObject;
  ReStream,PostStream: TStringStream;
  ReBodyJo: TSuperArray;
  nIdx: Integer;
begin
  Result := False;
  nWebOrder := PackerDecodeStr(FIn.FData);
  ReStream := TStringstream.Create('');
  ParamJo := SO();
  try
//    ParamJo.S['shipperName']  := gSysParam.FshipperNameEx;
//    ParamJo.S['shipperCode']  := nWebOrder;
    ParamJo.S['dispatchNo']  := nWebOrder;
    WriteLog('获取订单信息入参:' +'['+ParamJo.AsString+']');
    nStr                      := Ansitoutf8('['+ParamJo.AsString+']');
    PostStream:= TStringStream.Create(nStr);



    szUrl := gSysParam.FERPSrv + '/ipp-api/custom/dispatch/dispatchFeedbackNotice.shtml';
    WriteLog('获取订单服务地址:' + szUrl);
    FChannel.Request.Clear;
    FChannel.Request.ContentType        := 'application/json;Charset=UTF-8';
    FChannel.Request.CustomHeaders.Text := 'token:'+gSysParam.FToken;
    FChannel.Post(szUrl, PostStream, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog('获取订单信息出参:' + nStr);

    if nStr <> '' then
    begin
      FListA.Clear;
      FListB.Clear;
      ReJo := SO(nStr);
      if ReJo = nil then Exit;

      if ReJo.S['msgCode'] = 'M1000' then
      begin
        ReBodyJo := ReJo['data'].AsArray;
        if ReBodyJo = nil then Exit;

        for nIdx := 0 to ReBodyJo.Length - 1 do
        begin
          FListB.Values['Code']         := Copy(ReBodyJo[nIdx].S['ladingNo'],Pos('-',ReBodyJo[nIdx].S['ladingNo'])+1,MaxInt);   //云天大票
          FListB.Values['driverId']     := ReBodyJo[nIdx].S['mainDriverName'];       //司机编号
          FListB.Values['drvName']      := ReBodyJo[nIdx].S['mainDriverName'];       //司机名称
          FListB.Values['drvPhone']     := ReBodyJo[nIdx].S['mainDriverTel'];        //司机号码
          FListB.Values['project']      := ReBodyJo[nIdx].S['consigneeLocationName'];//工程工地
          FListB.Values['vehicleNo']    := ReBodyJo[nIdx].S['vehicleNo'];            //车牌号码
          FListB.Values['dispatchNo']   := ReBodyJo[nIdx].S['dispatchNo'];           //发运单号
          FListB.Values['ladingNo']     := ReBodyJo[nIdx].S['ladingNo'];             //提货单号
          FListB.Values['status']       := ReBodyJo[nIdx].S['status'];               //状态
          FListB.Values['reqShipTime']  := ReBodyJo[nIdx].S['reqShipTime'];          //提货日期
          FListB.Values['shipperCode']  := ReBodyJo[nIdx].S['shipperCode'];          //发货客户编码
          FListB.Values['shipperName']  := ReBodyJo[nIdx].S['shipperName'];          //发货客户名称
          FListB.Values['consigneeCode']:= ReBodyJo[nIdx].S['consigneeCode'];        //收货客户编码
          FListB.Values['consigneeName']:= ReBodyJo[nIdx].S['consigneeName'];        //收货客户名称
          FListB.Values['skuName']      := ReBodyJo[nIdx].S['skuName'];              //商品名称
          FListB.Values['skuCode']      := ReBodyJo[nIdx].S['skuCode'];              //商品编码
          FListB.Values['carrierName']  := ReBodyJo[nIdx].S['carrierName'];          //承运商
          FListB.Values['qtyEa']        := FloatToStr(ReBodyJo[nIdx].D['qtyEa']);   //数量
          FListB.Values['extDispatchNo']:= ReBodyJo[nIdx].S['extDispatchNo'];        //合单号
          FListB.Values['mergeSysDispatchNo']:= ReBodyJo[nIdx].S['mergeSysDispatchNo']; //合单发运单号
          FListB.Values['unitWeight']        := FloatToStr(ReBodyJo[nIdx].D['unitWeight']);   //

          nStr := StringReplace(FListB.Text, '\n', #13#10, [rfReplaceAll]);
          FListA.Add(PackerEncodeStr(nStr));
        end;
        Result             := True;
        FOut.FData         := FListA.Text;
        FOut.FBase.FResult := True;
      end
      else WriteLog('订单信息失败：' + ReJo.S['msg']);
    end;
  finally
    FChannel.Disconnect;
    ReStream.Free;
    PostStream.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncWLFYSalePound(
  var nData: string): Boolean;
var
  nStr, szUrl, nSql: string;
  ReJo, ParamJo, OneJo, ReBodyJo : ISuperObject;
  ReStream,PostStream: TStringStream;
  nIdx: Integer;
  nNetWeight: Double;
  ndispatchNo,nshipmentNo,nextDispatchNo: string;
  nIsHD:Boolean;
begin
  Result      := False;
  nIsHD       := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  //销售信息 L_HKRecord
  nSql := ' select a.L_Value, a.L_DispatchNo, a.L_extDispatchNo, b.P_ID, a.L_ID from %s a, %s b '+
          ' where a.L_ID = b.P_Bill and a.l_id = ''%s'' and a.l_status = ''%s'' and IsNull(a.L_DispatchNo, '''') <> '''' ';
  nSql := Format(nSql, [sTable_Bill, sTable_PoundLog, FListA.Values['ID'],sFlag_TruckOut]);

  with gDBConnManager.WorkerQuery(FDBConn, nSql) do
  begin
    if recordcount > 0 then
    begin
      nNetWeight    := FieldByName('L_Value').asFloat;
      ndispatchNo   := FieldByName('L_DispatchNo').AsString;
      nshipmentNo   := FieldByName('L_ID').AsString;
      nextDispatchNo:= FieldByName('L_DispatchNo').AsString;
    end
    else
    begin
      nIsHD         := True;
    end;
  end;

  if nIsHD then
  begin
    //销售信息 L_HKRecord
    nSql := ' select a.L_Value, a.L_DispatchNo, a.L_extDispatchNo, b.P_ID, a.L_ID,'+
            ' (select Top 1 IsNull(L_extDispatchNo,'''') from  S_Bill where L_HKRecord=a.L_HKRecord and L_ID <>a.L_ID) as L_HdDispatchNo '+
            ' from %s a, %s b '+
            ' where a.L_ID = b.P_Bill and a.l_id = ''%s'' and a.l_status = ''%s'' and IsNull(a.L_DispatchNo, '''') = '''' ';
    nSql := Format(nSql, [sTable_Bill, sTable_PoundLog, FListA.Values['ID'],sFlag_TruckOut]);

    with gDBConnManager.WorkerQuery(FDBConn, nSql) do
    begin
      if (recordcount > 0) and (Trim(FieldByName('L_HdDispatchNo').AsString) <> '') then
      begin
        nNetWeight    := FieldByName('L_Value').asFloat;
        ndispatchNo   := FieldByName('L_HdDispatchNo').AsString;
        nshipmentNo   := FieldByName('L_ID').AsString;
        nextDispatchNo:= FieldByName('L_HdDispatchNo').AsString;
      end
      else
      begin
        Result             := True;
        FOut.FData         := nData;
        FOut.FBase.FResult := True;
        Exit;
      end;
    end;
  end;

  ReStream    := TStringstream.Create('');
  ParamJo     := SO();
  try
    ParamJo.S['dispatchNo']     := ndispatchNo;
    ParamJo.S['shipmentNo']     := nshipmentNo;
    ParamJo.S['extDispatchNo']  := nextDispatchNo;
    ParamJo.S['weighedQty']     := FloatToStr(nNetWeight);
    WriteLog('销售通知单反馈入参:' +'['+ParamJo.AsString+']');
    nStr                        := Ansitoutf8('['+ParamJo.AsString+']');
    PostStream:= TStringStream.Create(nStr);

    szUrl := gSysParam.FERPSrv + '/ipp-api/api/dispatchOrder/dispatchOrderFeedback.shtml';

    WriteLog('销售通知单反馈服务地址:' + szUrl);
    FChannel.Request.Clear;
    FChannel.Request.ContentType        := 'application/json;Charset=UTF-8';
    FChannel.Request.CustomHeaders.Text := 'token:'+gSysParam.FToken;
    FChannel.Post(szUrl, PostStream, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog('获取销售通知单反馈信息出参:' + nStr);

    if nStr <> '' then
    begin
      ReJo := SO(nStr);
      if ReJo = nil then Exit;

      if ReJo.S['msgCode'] = 'M1000' then
      begin
        Result             := True;
        FOut.FData         := nData;
        FOut.FBase.FResult := True;
      end
      else WriteLog('订单信息失败：' + ReJo.S['message']);
    end;
  finally
    FChannel.Disconnect;
    ReStream.Free;
    PostStream.Free;
  end;
end;

procedure TBusWorkerBusinessHHJY.ReQuestInit;
begin
  FChannel.Request.Clear;
  FChannel.Request.Accept         := 'application/json, text/javascript, */*; q=0.01';
  FChannel.Request.AcceptLanguage := 'zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3';
  FChannel.Request.ContentType    := 'application/json;Charset=UTF-8';
  FChannel.Request.Connection     := 'keep-alive';
end;

function TBusWorkerBusinessHHJY.SyncWLFYOrderPound(
  var nData: string): Boolean;
var
  nStr, szUrl, nSql: string;
  ReJo, ParamJo, OneJo, ReBodyJo : ISuperObject;
  ReStream,PostStream: TStringStream;
  nIdx: Integer;
  nNetWeight: Double;
  ndispatchNo,nshipmentNo,nextDispatchNo: string;
begin
  Result      := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  //采购磅单信息
  nSql := ' select a.P_ID, (a.P_MValue - a.P_PValue - isnull(a.P_KZValue,0)) as NetWeight, b.O_WebOrderID ' +
          ' from %s a, %s b, %s c  where a.P_Order = c.D_ID and c.D_OID = b.O_ID and a.P_ID = ''%s'' and IsNull(b.O_WebOrderID,'''') <> '''' ';
  nSql := Format(nSql, [sTable_PoundLog, sTable_Order, sTable_OrderDtl,FListA.Values['ID']]);

  with gDBConnManager.WorkerQuery(FDBConn, nSql) do
  begin
    if recordcount > 0 then
    begin
      nNetWeight     := FieldByName('NetWeight').asFloat;
      ndispatchNo    := FieldByName('O_WebOrderID').AsString;
      nshipmentNo    := FieldByName('P_ID').AsString;
      nextDispatchNo := FieldByName('O_WebOrderID').AsString;
    end
    else
    begin
      Result             := True;
      FOut.FData         := nData;
      FOut.FBase.FResult := True;
      Exit;
    end;
  end;

  ReStream    := TStringstream.Create('');
  ParamJo     := SO();
  try
    ParamJo.S['dispatchNo']     := ndispatchNo;
    ParamJo.S['shipmentNo']     := nshipmentNo;
    ParamJo.S['extDispatchNo']  := nextDispatchNo;
    ParamJo.S['weighedQty']     := FloatToStr(nNetWeight);
    WriteLog('采购通知单反馈入参:' +'['+ParamJo.AsString+']');
    nStr                        := Ansitoutf8('['+ParamJo.AsString+']');
    PostStream                  := TStringStream.Create(nStr);

    szUrl := gSysParam.FERPSrv + '/ipp-api/api/dispatchOrder/dispatchOrderFeedback.shtml';

    WriteLog('采购通知单反馈服务地址:' + szUrl);
    FChannel.Request.Clear;
    FChannel.Request.ContentType        := 'application/json;Charset=UTF-8';
    FChannel.Request.CustomHeaders.Text := 'token:'+gSysParam.FToken;
    FChannel.Post(szUrl, PostStream, ReStream);
    nStr := UTF8Decode(ReStream.DataString);
    WriteLog('获取采购通知单反馈信息出参:' + nStr);

    if nStr <> '' then
    begin
      ReJo := SO(nStr);
      if ReJo = nil then Exit;

      if ReJo.S['msgCode'] = 'M1000' then
      begin
        Result             := True;
        FOut.FData         := nData;
        FOut.FBase.FResult := True;
      end
      else WriteLog('订单信息失败：' + ReJo.S['message']);
    end;
  finally
    FChannel.Disconnect;
    ReStream.Free;
    PostStream.Free;
  end;
end;

function TBusWorkerBusinessHHJY.SyncWLFYOrderInfo(
  var nData: string): Boolean;
var
  nStr, szUrl: string;
  ReJo, ParamJo, OneJo, ReBodyJo, JoA : ISuperObject;
  ReStream, PostStream: TStringStream;
  nIdx: Integer;
  dSet: TDataSet;
  nBegin, nEnd : TDateTime;
begin
  Result      := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  ReStream    := TStringstream.Create('');
  ParamJo     := SO();
  OneJo       := SO();
  JoA         := SO('[]');
  
  nStr := ' Select * from %s where con_Synstatus = 0 and pcId = ''%s'' and con_code = ''%s'' ';
  nStr := Format(nStr,[sTable_PurchaseContract,FListA.Values['ID'],FListA.Values['Order']]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nStr := 'Select B_ID as pcId, ' +
              'B_ProID as provider_code, ' +
              'B_ProName as provider_name, ' +
              'B_ID as con_code, ' +
              'B_StockNo as con_materiel_Code, ' +
              'B_StockName as con_materiel_name, ' +
              '0 as con_price, ' +
              'B_Value as con_quantity, ' +
              'B_SentValue as con_finished_quantity, ' +
              'B_Date as con_date, ' +
              'B_Memo as con_remark' + ' from %s where B_SynStatus = 0 and B_ID = ''%s'' ';
      nStr := format(nStr,[sTable_OrderBase,FListA.Values['ID']]);
      dSet := gDBConnManager.WorkerQuery(FDBConn, nStr);
      //荆门无合同表 执行申请表查询
      if dSet.RecordCount < 1 then
        Exit;
    end;

    nBegin := StrToDateDef(FieldByName('con_date').AsString,Now);
    nEnd   := IncYear(nBegin,5);
    try
      //系统订单号
      ParamJo.S['orderNo']               := FieldByName('con_code').AsString;
      //订单分类
      ParamJo.S['orderCategory']         := 'TRANS';
      //订单类型代码
      ParamJo.S['orderTypeCode']         := 'TRANS';
      //订单类型名称
      ParamJo.S['orderTypeName']         := '采购';
      //是否紧急订单
      ParamJo.S['isEmergent']            := 'N';
      //状态编码
      ParamJo.S['status']                := 'NEW';
      //订单计划开始时间
      ParamJo.S['fmPlanOrderTime']       := FieldByName('con_date').AsString;
      //订单计划结束时间
      ParamJo.S['toPlanOrderTime']       := DateTime2Str(nEnd);
      //发货客户编码
      ParamJo.S['shipperCode']           := gSysParam.FshipperCode;
      //发货客户名称
      ParamJo.S['shipperName']           := gSysParam.FshipperName;
      //发货联系人编码
      ParamJo.S['shipperContactCode']    := gSysParam.FshipperContactCode;
      //发货联系人名称
      ParamJo.S['shipperContactName']    := gSysParam.FshipperContactName;
      //发货联系电话
      ParamJo.S['shipperContactTel']     := gSysParam.FshipperContactTel;
      //发货地点编码
      ParamJo.S['shipperLocationCode']   := gSysParam.FshipperLocationCode;
      //发货地点名称
      ParamJo.S['shipperLocationName']   := gSysParam.FshipperLocationName;
      //供应商编码
      ParamJo.S['supplierCode']          := FieldByName('provider_code').AsString;
      //供应商名称
      ParamJo.S['supplierName']          := FieldByName('provider_name').AsString;
      //收货客户编码
      ParamJo.S['consigneeCode']         := gSysParam.FconsigneeCode;
      //收货客户名称
      ParamJo.S['consigneeName']         := gSysParam.FconsigneeName;
      //收货联系人编码
      ParamJo.S['consigneeContactCode']  := gSysParam.FconsigneeContactCode;
      //收货联系人名称
      ParamJo.S['consigneeContactName']  := gSysParam.FconsigneeContactName;
      //收货联系电话
      ParamJo.S['consigneeContactTel']   := gSysParam.FconsigneeContactTel;
      //收货地点编码
      ParamJo.S['consigneeLocationCode'] := gSysParam.FconsigneeLocationCode;
      //收货地点名称
      ParamJo.S['consigneeLocationName'] := gSysParam.FconsigneeLocationName;
      //提货单号
      ParamJo.S['ladingNo']              := FieldByName('con_code').AsString;
      //所在公司
      ParamJo.S['orgId']                 := gSysParam.ForgId;
      //明细唯一行号
      OneJo.S['lineNo']                  := FieldByName('con_code').AsString;
      //商品编码
      OneJo.S['skuCode']                 := FieldByName('con_materiel_Code').AsString;
      //商品名称
      OneJo.S['skuName']                 := FieldByName('con_materiel_name').AsString;
      //订单商品数量
      OneJo.S['qtyEa']                   := FieldByName('con_quantity').AsString;
      //包装规格代码
      OneJo.S['packCode']                := gSysParam.FpackCode;
      //包装单位代码
      OneJo.S['uom']                     := '吨';
      JoA.AsArray.add(OneJo);
      ParamJo.O['orderGargoList']        := JoA;
      WriteLog('物流订单接收入参:' + '['+ParamJo.AsString+']');
      nStr                               := Ansitoutf8('['+ParamJo.AsString+']');
      PostStream                         := TStringStream.Create(nStr);

      szUrl := gSysParam.FERPSrvOms + '/oms-open-api-web/open/order/receivingOrder.shtml';

      WriteLog('采购订单同步服务地址:' + szUrl);
      FChannel.Request.Clear;
      FChannel.Request.ContentType        := 'application/json;Charset=UTF-8';
      FChannel.Request.CustomHeaders.Text := 'token:'+gSysParam.FTokenOms;
      FChannel.Post(szUrl, PostStream, ReStream);
      nStr := UTF8Decode(ReStream.DataString);
      WriteLog('获取采购订单同步信息出参:' + nStr);

      if nStr <> '' then
      begin
        ReJo := SO(nStr);
        if ReJo = nil then Exit;

        if ReJo.S['msgCode'] = 'M1000' then
        begin
          nStr :=' update %s set con_Synstatus = ''1'' where pcId = ''%s'' ';
          nStr := Format(nStr,[sTable_PurchaseContract,FListA.Values['ID']]);
          gDBConnManager.WorkerExec(FDBConn,nStr);

          nStr :='update %s set B_SynStatus = ''1'' where B_ID = ''%s'' ';
          nStr := Format(nStr,[sTable_OrderBase,FListA.Values['ID']]);
          gDBConnManager.WorkerExec(FDBConn,nStr);

          Result             := True;
          FOut.FData         := nData;
          FOut.FBase.FResult := True;
        end
        else WriteLog('订单信息失败：' + ReJo.S['message']);
      end;
    finally
      FChannel.Disconnect;
      ReStream.Free;
      PostStream.Free;
    end;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerBusinessHHJY, sPlug_ModuleBus);
end.
