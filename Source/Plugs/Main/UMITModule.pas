{*******************************************************************************
  作者: dmzn@163.com 2009-6-25
  描述: 单元模块

  备注: 由于模块有自注册能力,只要Uses一下即可.
*******************************************************************************}
unit UMITModule;

{$I Link.Inc}
interface

uses
  Windows, Forms, Classes, SysUtils, ULibFun, UBusinessWorker, UBusinessPacker,
  UTaskMonitor, USysShareMem, USysLoger, UMITConst, UMITPacker, UMemDataPool,
  {$IFDEF HardMon}UEventHardware, UWorkerHardware,{$ENDIF}
  UWorkerClientWebChat,
  UWorkerBusinessCommand, UWorkerBusinessBill,
  UWorkerBusinessDuanDao, UWorkerBusinessOrders,
  {$IFDEF GLlade}UWorkerBusinessBillSingle,{$ENDIF}
  {$IFDEF PurchaseOrderSingle}UWorkerBusinessOrdersSingle,{$ENDIF}
  {$IFDEF MicroMsg}UMgrRemoteWXMsg, UWXSyncer,{$ENDIF}
  UMgrDBConn, UMgrParam, UMgrPlug, UMgrChannel, UChannelChooser, USAPConnection,
  UBaseObject;

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
  nMenu.FName := 'Form_Test';
  nMenu.FCaption := '测试窗体';
  nMenu.FFormID := cFI_FormTest1;
  nMenu.FDefault := True;
end;
{$ENDIF}

procedure TMainEventWorker.BeforeStartServer;
begin
  {$IFDEF DBPool}
  with gParamManager do
  begin
    gDBConnManager.DefaultConnection := ActiveParam.FDB.FID;
    gDBConnManager.MaxConn := ActiveParam.FDB.FNumWorker;

    {$IFDEF ASyncWriteData}
    gDBConnManager.ASyncInitDB;
    gDBConnManager.ASyncStart;
    {$ENDIF}
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

  {$IFDEF MicroMsg}
  gWXPlatFormHelper.StartPlatConnector;
  gWXSyncer.Start(gParamManager.ActiveParam.FDB.FID);
  {$ENDIF} //micro message

  gTaskMonitor.StartMon;
  //mon task start
end;

procedure TMainEventWorker.AfterStopServer;
begin
  inherited;
  gTaskMonitor.StopMon;
  //stop mon task

  {$IFDEF AutoChannel}
  gChannelChoolser.StopRefresh;
  {$ENDIF} //channel

  {$IFDEf SAP}
  gSAPConnectionManager.ClearAllConnection;
  {$ENDIF}//stop sap

  {$IFDEF DBPool}
    {$IFDEF ASyncWriteData}
    gDBConnManager.ASyncStop;
    {$ENDIF}

    gDBConnManager.Disconnection();
  {$ENDIF} //db

  {$IFDEF MicroMsg}
  gWXSyncer.Stop;
  gWXPlatFormHelper.StopPlatConnector;
  {$ENDIF} //micro message
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
  gTaskMonitor := TTaskMonitor.Create;
  //任务监控器

  gParamManager := TParamManager.Create(gPath + 'Parameters.xml');
  if gSysParam.FParam <> '' then
    gParamManager.GetParamPack(gSysParam.FParam, True);
  //参数管理器

  gCommonObjectManager := TCommonObjectManager.Create;
  //通用对象状态管理

  TBusinessWorkerSweetHeart.RegWorker(gParamManager.URLLocal.Text);
  //for channel manager

  gMemDataManager := TMemDataManager.Create;
  //内存管理器

  {$IFDEF ClientMon}
  gProcessMonitorClient := TProcessMonitorClient.Create(gSysParam.FParam);
  //process monitor
  {$ENDIF}
  
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

  {$IFDEF MicroMsg}
  gWXPlatFormHelper.LoadConfig(gPath + 'Hardware\MicroMsg.XML');
  {$ENDIF} //micro message

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
    {$IFDEF HardMon}
    AddEventWorker(THardwareWorker.Create);
    {$ENDIF}
    LoadPlugsInDirectory(gPath + sPlugDir);

    RefreshUIMenu;
    InitSystemObject;
  end; //插件管理器(需最后一个初始化)
end;

//Desc: 运行系统对象
procedure RunSystemObject;
var nStr: string;
begin
  {$IFDEF ClientMon}
  if Assigned(gParamManager.ActiveParam) and
     Assigned(gParamManager.ActiveParam.FPerform) then
  with gParamManager.ActiveParam.FPerform^ do
  begin
    if Assigned(gProcessMonitorSapMITClient) then
    begin
      gProcessMonitorSapMITClient.UpdateHandle(gPlugManager.RunParam.FMainForm,
                                               GetCurrentProcessId, nStr);
      gProcessMonitorSapMITClient.StartMonitor(nStr, FMonInterval);
    end;

    if Assigned(gProcessMonitorClient) then
    begin
      gProcessMonitorClient.UpdateHandle(gPlugManager.RunParam.FMainForm,
                                               GetCurrentProcessId, nStr);
      gProcessMonitorClient.StartMonitor(nStr, FMonInterval);
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
