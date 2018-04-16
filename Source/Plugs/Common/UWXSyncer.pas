{*******************************************************************************
  作者: dmzn@163.com 2018-04-13
  描述: 微信数据自动双向同步
*******************************************************************************}
unit UWXSyncer;

interface

uses
  Windows, Classes, SysUtils, UBusinessWorker, UBusinessPacker, UBusinessConst,
  UWorkerBusinessCommand, UMgrDBConn, UWaitItem, ULibFun, USysDB, UMITConst,
  USysLoger;

type
  TWXSyncer = class;
  TWXSyncThread = class(TThread)
  private
    FOwner: TWXSyncer;
    //拥有者
    FDB: string;
    FDBConn: PDBWorker;
    //数据对象
    FWorker: TBusinessWorkerBase;
    FPacker: TBusinessPackerBase;
    //业务对象
    FListA,FListB: TStrings;
    //列表对象
    FNumUploadSync: Integer;
    //计时计数
    FWaiter: TWaitObject;
    //等待对象
    FSyncLock: TCrossProcWaitObject;
    //同步锁定
  protected
    procedure DoUploadSync;
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TWXSyncer);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启止线程
  end;

  TWXSyncer = class(TObject)
  private
    FDB: string;
    //数据标识
    FThread: TWXSyncThread;
    //扫描线程
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure Start(const nDB: string = '');
    procedure Stop;
    //起停上传
  end;

var
  gWXSyncer: TWXSyncer = nil;
  //全局使用

implementation

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TWXSyncer, '微信双向同步', nMsg);
end;

constructor TWXSyncThread.Create(AOwner: TWXSyncer);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FDB := FOwner.FDB;
  
  FListA := TStringList.Create;
  FListB := TStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 60 * 1000;
  //1 minute

  FSyncLock := TCrossProcWaitObject.Create('BusMIT_WeChat_Sync');
  //process sync
end;

destructor TWXSyncThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TWXSyncThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TWXSyncThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TWXSyncThread.Execute;
var nErr: Integer;
    nInit: Int64;
begin
  FNumUploadSync := 0;
  //init counter

  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Inc(FNumUploadSync);
    //inc counter

    if FNumUploadSync >= 10 then
       FNumUploadSync :=0 ;
    //上传至微信： 6次/小时

    if (FNumUploadSync <> 0) then Continue;
    //无业务可做

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //其它进程正在执行

    FDBConn := nil;
    try
      FDBConn := gDBConnManager.GetConnection(FDB, nErr);
      if not Assigned(FDBConn) then Continue;

      FWorker := nil;
      FPacker := nil;

      if FNumUploadSync = 0 then
      try
        FWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
        FPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);

        WriteLog('自动同步数据到微信平台...');
        nInit := GetTickCount;
        DoUploadSync;
        WriteLog('同步完毕,耗时: ' + IntToStr(GetTickCount - nInit));
      finally
        gBusinessPackerManager.RelasePacker(FPacker);
        FPacker := nil;
        gBusinessWorkerManager.RelaseWorker(FWorker);
        FWorker := nil;
      end;
    finally
      FSyncLock.SyncLockLeave();
      gDBConnManager.ReleaseConnection(FDBConn);
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;


procedure TWXSyncThread.DoUploadSync;
var nStr: string;
    nInt: Integer;
    nOut: TWorkerBusinessCommand;
begin
  nStr := 'Delete From %s Where (S_SyncFlag=''%s'') or (%s-S_Date>=2)';
  nStr := Format(nStr, [sTable_WeixinSync, sFlag_Yes, sField_SQLServer_Now]);
  gDBConnManager.WorkerExec(FDBConn, nStr); //清理已完成

  nStr := 'Select * From ' + sTable_WeixinSync;
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
      Exit;
    //xxxxx

    First;
    while not Eof do
    try
      nStr := FieldByName('S_Business').AsString;
      if IsNumber(nStr, False) then
           nInt := StrToInt(nStr)
      else nInt := 0;

      case nInt of
       cBC_WeChat_complete_shoporders: //业务完成,更新状态
        begin
          nStr := FieldByName('S_Data').AsString;
          if TWorkerBusinessCommander.CallMe(nInt, nStr, '', @nOut) then
          begin
            nStr := 'Update %s Set S_SyncFlag=''%s'' Where R_ID=%s';
            nStr := Format(nStr, [sTable_WeixinSync, sFlag_Yes,
                    FieldByName('R_ID').AsString]);
            gDBConnManager.WorkerExec(FDBConn, nStr);
          end else
          begin
            nStr := 'Update %s Set S_SyncTime=S_SyncTime+1,S_SyncMemo=''%s'' ' +
                    'Where R_ID=%s';
            nStr := Format(nStr, [sTable_WeixinSync, nOut.FData,
                    FieldByName('R_ID').AsString]);
            gDBConnManager.WorkerExec(FDBConn, nStr);
          end;
        end;
      end;

      Next;
    except
      on nErr: Exception do
      begin
        Next; //ignor any error
        WriteLog(nErr.Message);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TWXSyncer.Create;
begin
  FThread := nil;
end;

destructor TWXSyncer.Destroy;
begin
  Stop;
  inherited;
end;

procedure TWXSyncer.Start(const nDB: string);
begin
  if nDB = '' then
  begin
    if Assigned(FThread) then
      FThread.Wakeup;
    //start upload
  end else
  if not Assigned(FThread) then
  begin
    FDB := nDB;
    FThread := TWXSyncThread.Create(Self);
  end;
end;

procedure TWXSyncer.Stop;
begin
  if Assigned(FThread) then
  begin
    FThread.StopMe;
    FThread := nil;
  end;
end;

initialization
  gWXSyncer := TWXSyncer.Create;
finalization
  FreeAndNil(gWXSyncer);
end.
