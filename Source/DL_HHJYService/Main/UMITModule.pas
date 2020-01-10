{*******************************************************************************
  作者: dmzn@163.com 2009-6-25
  描述: 单元模块

  备注: 由于模块有自注册能力,只要Uses一下即可.
*******************************************************************************}
unit UMITModule;

{$I Link.Inc}
interface

uses
  Forms, Classes, SysUtils, ULibFun, UMITConst, USysDB,
  //常规定义
  UMITPacker, UWorkerBussinessWebchat, UMessageScan, UWorkerBusiness,
  UWorkerBussinessHHJY,
  //业务对象
  UBusinessWorker, UBusinessPacker, UMgrDBConn, UMgrParam, UMgrPlug,
  UMgrChannel, UTaskMonitor, UChannelChooser, USysShareMem,
  USysLoger, UBaseObject, UMemDataPool;
  //系统对象

procedure InitSystemObject(const nMainForm: THandle);
procedure RunSystemObject;
procedure FreeSystemObject;
//入口函数

implementation

{$IFDEF DEBUG}
uses
  UPlugConst, UFormTest;
{$ENDIF}

type
  TMainEventWorker = class(TPlugEventWorker)
  protected
    {$IFDEF DEBUG}
    procedure GetExtendMenu(const nList: TList); override;
    {$ENDIF}
    procedure BeforeStartServer; override;
    procedure AfterStopServer; override;
  public
    class function ModuleInfo: TPlugModuleInfo; override;
  end;

class function TMainEventWorker.ModuleInfo: TPlugModuleInfo;
begin
  Result := inherited ModuleInfo;
  with Result do
  begin
    FModuleID       := '{2497C39C-E1B2-406D-B7AC-9C8DB49C44DF}';
    FModuleName     := '框架事件';
    FModuleAuthor   := 'dmzn@163.com';
    FModuleVersion  := '2013-12-12';
    FModuleDesc     := '主框架对象,处理基本业务.';
    FModuleBuildTime:= Str2DateTime('2013-12-12 13:05:00');
  end;
end;

{$IFDEF DEBUG}
procedure TMainEventWorker.GetExtendMenu(const nList: TList);
var nMenu: PPlugMenuItem;
begin
  New(nMenu);
  nList.Add(nMenu);

  nMenu.FModule := ModuleInfo.FModuleID;
  nMenu.FName := 'menu_test2';
  nMenu.FCaption := '业务测试';
  nMenu.FFormID := cFI_FormTest2;
  nMenu.FDefault := True;
end;
{$ENDIF}

//Date: 2017-09-26
//Desc: 读取数据库参数
procedure LoadDBConfig;
var nStr: string;
    nWorker: PDBWorker;
    nIdx: Integer;
begin
  nWorker := nil;
  try
    nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := Fields[1].AsString;
        
        if nStr = sFlag_ERPSrv then
          gSysParam.FERPSrv := Fields[0].AsString;
        if nStr = sFlag_ERPSrvOms then
          gSysParam.FERPSrvOms := Fields[0].AsString;
        if nStr = sFlag_shipperCode then                                        //发货客户编码
          gSysParam.FshipperCode := Fields[0].AsString;
        if nStr = sFlag_shipperName then                                        //发货客户名称
          gSysParam.FshipperName := Fields[0].AsString;
        if nStr = sFlag_shipperContactCode then                                 //发货联系人编码
          gSysParam.FshipperContactCode := Fields[0].AsString;
        if nStr = sFlag_shipperContactName then                                 //发货联系人名称
          gSysParam.FshipperContactName := Fields[0].AsString;
        if nStr = sFlag_shipperContactTel then                                  //发货联系电话
          gSysParam.FshipperContactTel := Fields[0].AsString;
        if nStr = sFlag_shipperLocationCode then                                //发货地点编码
          gSysParam.FshipperLocationCode:= Fields[0].AsString;
        if nStr = sFlag_shipperLocationName then                                //发货地点名称
          gSysParam.FshipperLocationName:= Fields[0].AsString;
        if nStr = sFlag_consigneeCode then                                      //收货客户编码
          gSysParam.FconsigneeCode:= Fields[0].AsString;
        if nStr = sFlag_consigneeName then                                      //收货客户名称
          gSysParam.FconsigneeName:= Fields[0].AsString;
        if nStr = sFlag_consigneeContactCode then                               //收货联系人编码
          gSysParam.FconsigneeContactCode:= Fields[0].AsString;
        if nStr = sFlag_consigneeContactName then                               //收货联系人名称
          gSysParam.FconsigneeContactName:= Fields[0].AsString;
        if nStr = sFlag_consigneeContactTel then                                //收货联系电话
          gSysParam.FconsigneeContactTel:= Fields[0].AsString;
        if nStr = sFlag_consigneeLocationCode then                              //收货地点编码
          gSysParam.FconsigneeLocationCode:= Fields[0].AsString;
        if nStr = sFlag_consigneeLocationName then                              //收货地点名称
          gSysParam.FconsigneeLocationName:= Fields[0].AsString;
        if nStr = sFlag_packCode  then                                          //包装规格代码
          gSysParam.FpackCode := Fields[0].AsString;
        if nStr = sFlag_orgId then                                              //所在公司
          gSysParam.ForgId := Fields[0].AsString;
        if nStr = sFlag_shipperNameEx then                                      //发货客户名称(物流下单)
          gSysParam.FshipperNameEx := Fields[0].AsString;

        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker); 
  end;

  if gSysParam.FERPSrv = '' then
  begin
//    nStr := '未配置[ %s.%s ]字典项.';
//    nStr := Format(nStr, [sTable_SysDict, sFlag_ERPSrv]);
    raise Exception.Create(nStr);
  end;
end;

procedure TMainEventWorker.BeforeStartServer;
begin
  {$IFDEF DBPool}
  with gParamManager do
  begin
    gDBConnManager.AddParam(ActiveParam.FDB^);
    gDBConnManager.MaxConn := ActiveParam.FDB.FNumWorker;
  end;
  {$ENDIF} //db

  {$IFDEF SAP}
  with gParamManager do
  begin
    gSAPConnectionManager.AddParam(ActiveParam.FSAP^);
    gSAPConnectionManager.PoolSize := ActiveParam.FPerform.FPoolSizeSAP;
  end;
  {$ENDIF}//sap

  {$IFDEF ChannelPool}
  gChannelManager.ChannelMax := 50;
  {$ENDIF} //channel

  {$IFDEF AutoChannel}
  gChannelChoolser.AddChanels(gParamManager.URLRemote.Text);
  gChannelChoolser.StartRefresh;
  {$ENDIF} //channel auto select

  LoadDBConfig;
  //load param in db

  gTaskMonitor.StartMon;
  //mon task start
  gMessageScan.Start;
  //消息扫描启动
end;

procedure TMainEventWorker.AfterStopServer;
begin
  inherited;
  gTaskMonitor.StopMon;
  //stop mon task
  gMessageScan.Stop;
  //停止消息扫描
  {$IFDEF AutoChannel}
  gChannelChoolser.StopRefresh;
  {$ENDIF} //channel

  {$IFDEf SAP}
  gSAPConnectionManager.ClearAllConnection;
  {$ENDIF}//stop sap

  {$IFDEF DBPool}
  gDBConnManager.Disconnection();
  {$ENDIF} //db
end;

//------------------------------------------------------------------------------
//Desc: 填充数据库参数
procedure FillAllDBParam;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    gParamManager.LoadParam(nList, ptDB);
    for nIdx:=0 to nList.Count - 1 do
      gDBConnManager.AddParam(gParamManager.GetDB(nList[nIdx])^);
    //xxxxx
  finally
    nList.Free;
  end;
end;

//Desc: 初始化系统对象
procedure InitSystemObject(const nMainForm: THandle);
var nParam: TPlugRunParameter;
begin
  gSysLoger := TSysLoger.Create(gPath + sLogDir, sLogSyncLock);
  //日志管理器
  gCommonObjectManager := TCommonObjectManager.Create;
  //通用对象状态管理

  gTaskMonitor := TTaskMonitor.Create;
  //任务监控器
  gMemDataManager := TMemDataManager.Create;
  //内存管理器

  gParamManager := TParamManager.Create(gPath + 'Parameters.xml');
  if gSysParam.FParam <> '' then
    gParamManager.GetParamPack(gSysParam.FParam, True);
  //参数管理器

  {$IFDEF DBPool}
  gDBConnManager := TDBConnManager.Create;
  FillAllDBParam;
  {$ENDIF}

  {$IFDEF SAP}
  gSAPConnectionManager := TSAPConnectionManager.Create;
  //sap conn pool
  {$ENDIF}

  {$IFDEF ChannelPool}
  gChannelManager := TChannelManager.Create;
  {$ENDIF}

  {$IFDEF AutoChannel}
  gChannelChoolser := TChannelChoolser.Create('');
  gChannelChoolser.AutoUpdateLocal := False;
  gChannelChoolser.AddChanels(gParamManager.URLRemote.Text);
  {$ENDIF}

  gMessageScan:=TMessageScan.Create;
  //消息表扫描线程
  gMessageScan.LoadConfig(gPath+'MessageScan.xml');

  with nParam do
  begin
    FAppHandle := Application.Handle;
    FMainForm  := nMainForm;
    FAppFlag   := gSysParam.FAppFlag;
    FAppPath   := gPath;

    FLocalIP   := gSysParam.FLocalIP;
    FLocalMAC  := gSysParam.FLocalMAC;
    FLocalName := gSysParam.FLocalName;
    FExtParam  := TStringList.Create;
  end;

  gPlugManager := TPlugManager.Create(nParam);
  with gPlugManager do
  begin
    AddEventWorker(TMainEventWorker.Create);
    {$IFDEF Remote2MIT}
    AddEventWorker(TEventRemoteWorker.Create);
    {$ENDIF}
    LoadPlugsInDirectory(gPath + sPlugDir);

    RefreshUIMenu;
    InitSystemObject;
  end; //插件管理器(需最后一个初始化)
end;

//Desc: 运行系统对象
procedure RunSystemObject;

begin
  {$IFDEF ClientMon}
  if Assigned(gParamManager.ActiveParam) and
     Assigned(gParamManager.ActiveParam.FPerform) then
  with gParamManager.ActiveParam.FPerform^ do
  begin
    if Assigned(gProcessMonitorSapMITClient) then
    begin
      gProcessMonitorSapMITClient.UpdateHandle(nFormHandle, GetCurrentProcessId, nStr);
      gProcessMonitorSapMITClient.StartMonitor(nStr, FMonInterval);
    end;
  end;
  {$ENDIF}

  gPlugManager.RunSystemObject;
  //插件对象开始运行
end;

//Desc: 释放系统对象
procedure FreeSystemObject;
begin
  FreeAndNil(gPlugManager);
  //插件管理器(需第一个释放)

  if Assigned(gProcessMonitorSapMITClient) then
  begin
    gProcessMonitorSapMITClient.StopMonitor(Application.Active);
    FreeAndNil(gProcessMonitorSapMITClient);
  end; //stop monitor
end;

end.
