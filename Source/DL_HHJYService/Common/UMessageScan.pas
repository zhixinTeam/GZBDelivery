{*******************************************************************************
作者: juner11212436@163.com 2017/11/20
描述: 微信业务发送表扫描线程
*******************************************************************************}
unit UMessageScan;

{$I Link.inc}
interface

uses
  Windows, Classes, SysUtils, DateUtils, UBusinessConst, UMgrDBConn,
  UBusinessWorker, UWaitItem, ULibFun, USysDB, UMITConst, USysLoger,
  UBusinessPacker, NativeXml, UMgrParam, UWorkerBussinessWebchat,
  UWorkerBussinessHHJY, DB ;

type
  TMessageScan = class;
  TMessageScanThread = class(TThread)
  private
    FOwner: TMessageScan;
    //拥有者
    FDBConn: PDBWorker;
    //数据对象
    FListA,FListB,FListC: TStrings;
    //列表对象
    FXMLBuilder: TNativeXml;
    //XML构建器
    FWaiter: TWaitObject;
    //等待对象
    FSyncLock: TCrossProcWaitObject;
    //同步锁定
    FNumOutFactMsg: Integer;
    //提货单出厂消息推送计时计数
  protected
    function SendSaleMsgToWebMall(nList: TStrings):Boolean;
    //销售发送消息
    function SendOrderMsgToWebMall(nList: TStrings):Boolean;
    //采购发送消息
    procedure UpdateMsgNum(const nSuccess: Boolean; nLID: string);
    //更新消息状态
    procedure DoSaveOutFactMsg;
    //执行出厂消息插入
    procedure DoSendWLFYOrderInfo;
    //向物流发运发送采购订单
    function SaveSaleOutFactMsg(nList: TStrings):Boolean;
    //销售出厂消息
    function SaveOrderOutFactMsg(nList: TStrings):Boolean;
    //销售出厂消息
    function SaveMakeOrderMsg(nList: TStrings):Boolean;
    //采购订单推送
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TMessageScan);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启止线程
  end;

  TMessageScan = class(TObject)
  private
    FThread: TMessageScanThread;
    //扫描线程
  public
    FSyncTime:Integer;
    //设定同步次数阀值
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure Start;
    procedure Stop;
    //起停上传
    procedure LoadConfig(const nFile:string);//载入配置文件
  end;

var
  gMessageScan: TMessageScan = nil;
  //全局使用


implementation

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TMessageScan, '接口消息扫描', nMsg);
end;

constructor TMessageScan.Create;
begin
  FThread := nil;
end;

destructor TMessageScan.Destroy;
begin
  Stop;
  inherited;
end;

procedure TMessageScan.Start;
begin
  if not Assigned(FThread) then
    FThread := TMessageScanThread.Create(Self);
  FThread.Wakeup;
end;

procedure TMessageScan.Stop;
begin
  if Assigned(FThread) then
    FThread.StopMe;
  FThread := nil;
end;

//载入nFile配置文件
procedure TMessageScan.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByName('Item');
    try
      FSyncTime:= StrToInt(nNode.NodeByName('SyncTime').ValueAsString);
    except
      FSyncTime:= 5;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TMessageScanThread.Create(AOwner: TMessageScan);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FXMLBuilder :=TNativeXml.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 30*1000;

  FSyncLock := TCrossProcWaitObject.Create('HHJYService_MessageScan');
  //process sync
end;

destructor TMessageScanThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;
  FListC.Free;
  FXMLBuilder.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TMessageScanThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TMessageScanThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TMessageScanThread.Execute;
var nErr, nSuccessCount, nFailCount: Integer;
    nStr: string;
    nResult : Boolean;
    nInit: Int64;
    nOut: TWorkerBusinessCommand;
begin
  FNumOutFactMsg := 0;

  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Inc(FNumOutFactMsg);

    if FNumOutFactMsg >= 3 then
      FNumOutFactMsg := 0;

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //其它进程正在执行

    FDBConn := nil;
    with gParamManager.ActiveParam^ do
    try
      FDBConn := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, nErr);
      if not Assigned(FDBConn) then Continue;

      if FNumOutFactMsg = 0 then
      begin
        DoSendWLFYOrderInfo;
      end;

      nStr:= 'select top 100 * from %s where H_SyncNum <= %d And H_Deleted <> ''%s''';
      nStr:= Format(nStr,[sTable_HHJYSync, gMessageScan.FSyncTime, sFlag_Yes]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then
          Continue;
        //无新消息
        nSuccessCount := 0;
        nFailCount := 0;
        WriteLog('共查询到'+ IntToStr(RecordCount) + '条数据,开始推送...');
        nInit := GetTickCount;

        First;

        while not Eof do
        begin
          FListA.Clear;
          FListA.Values['ID']       := FieldByName('H_ID').AsString;
          FListA.Values['Order']    := FieldByName('H_Order').AsString;
          FListA.Values['BillType'] := FieldByName('H_BillType').AsString;
          FListA.Values['PurType']  := FieldByName('H_PurType').AsString;
          FListA.Values['Status']   := FieldByName('H_Status').AsString;

          UpdateMsgNum(False,FListA.Values['ID']);

          nStr := PackerEncodeStr(FListA.Text);

        {$IFDEF UseWLFYInfo}
          if FListA.Values['BillType'] = sFlag_Sale then
            nResult := TBusWorkerBusinessHHJY.CallMe(cBC_FYWLSynSalePound
                       ,nStr,'',@nOut)
          else if (FListA.Values['BillType'] = sFlag_Provide)
            and (FListA.Values['PurType'] = sFlag_Provide) then
          begin
            nResult := TBusWorkerBusinessHHJY.CallMe(cBC_FYWLSynOrderInfo
                     ,nStr,'',@nOut);
          end
          else if (FListA.Values['BillType'] = sFlag_Provide)
            and (FListA.Values['PurType'] <> sFlag_Provide) then
          begin
            nResult := TBusWorkerBusinessHHJY.CallMe(cBC_FYWLSynOrderPound
                     ,nStr,'',@nOut);
          end;
          {$ENDIF}

          if nResult then
          begin
            //更新为已处理
            Inc(nSuccessCount);
          end
          else
          begin
            Inc(nFailCount);
          end;

          UpdateMsgNum(nResult,FListA.Values['ID']);
          WriteLog('第'+IntToStr(RecNo)+'条数据处理完成！提货单号:'+FListA.Values['ID']);
          Next;
        end;
      end;
      WriteLog(IntToStr(nSuccessCount) + '条消息同步成功，'
                + IntToStr(nFailCount) + '条消息同步失败，'
                + '耗时: ' + IntToStr(GetTickCount - nInit) + 'ms');
    finally
      gDBConnManager.ReleaseConnection(FDBConn);
      FSyncLock.SyncLockLeave();
      WriteLog('Release FDBConn');
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

function TMessageScanThread.SendSaleMsgToWebMall(nList: TStrings):Boolean;
var nStr, nLID, nTableName: string;
    nDBWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;

  nLID := nList.Values['WOM_LID'];

  nDBWorker := nil;
  try
    nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
            'L_StockName,L_Truck,L_Value,L_Card,L_Price ' +
            'From $Bill b ';
    //xxxxx

    nStr := nStr + 'Where L_ID=''$CD''';

    if StrToIntDef(nList.Values['WOM_StatusType'],0) = c_WeChatStatusDeleted then
      nTableName := sTable_BillBak
    else
      nTableName := sTable_Bill;
    nStr := MacroValue(nStr, [MI('$Bill', nTableName), MI('$CD', nLID)]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '交货单[ %s ]已无效.';

        nStr := Format(nStr, [nLID]);
        WriteLog(nStr);
        Exit;
      end;

      First;

      while not Eof do
      begin
        FListB.Clear;

        FListB.Values['CusID']      := FieldByName('L_CusID').AsString;
        FListB.Values['MsgType']    := nList.Values['WOM_MsgType'];
        FListB.Values['BillID']     := FieldByName('L_ID').AsString;
        FListB.Values['Card']       := FieldByName('L_Card').AsString;
        FListB.Values['Truck']      := FieldByName('L_Truck').AsString;
        FListB.Values['StockNo']    := FieldByName('L_StockNo').AsString;
        FListB.Values['StockName']  := FieldByName('L_StockName').AsString;
        FListB.Values['CusName']    := FieldByName('L_CusName').AsString;
        FListB.Values['Value']      := FieldByName('L_Value').AsString;

        nStr := PackerEncodeStr(FListB.Text);

//        Result := TBusWorkerBusinessWebchat.CallMe(cBC_WX_send_event_msg
//           ,nStr,'',@nOut);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

function TMessageScanThread.SendOrderMsgToWebMall(nList: TStrings):Boolean;
var nStr, nLID, nTableName: string;
    nDBWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;

  nLID := nList.Values['WOM_LID'];

  nDBWorker := nil;
  try
    if StrToIntDef(nList.Values['WOM_StatusType'],0) = c_WeChatStatusFinished then
    begin
      nStr := 'Select D_ID,D_OID,D_ProID,D_ProName,D_Type,D_StockNo,' +
              'D_StockName,D_Truck,D_Value,D_Card ' +
              'From $Bill b ';
      //xxxxx

      nStr := nStr + 'Where D_OID=''$CD''';

      nTableName := sTable_OrderDtl;
      nStr := MacroValue(nStr, [MI('$Bill', nTableName), MI('$CD', nLID)]);
      //xxxxx
    end
    else
    begin
      nStr := 'Select O_ID as D_OID,O_ProID as D_ProID,O_ProName as D_ProName,'+
              'O_Type as D_Type,O_StockNo as D_StockNo,O_StockName as D_StockName,' +
              'O_Truck as D_Truck,O_Value as D_Value,O_Card as D_Card ' +
              'From $Bill b ';
      //xxxxx

      nStr := nStr + 'Where O_ID=''$CD''';

      if StrToIntDef(nList.Values['WOM_StatusType'],0) = c_WeChatStatusDeleted then
        nTableName := sTable_OrderBak
      else
        nTableName := sTable_Order;
      nStr := MacroValue(nStr, [MI('$Bill', nTableName), MI('$CD', nLID)]);
      //xxxxx
    end;

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '采购单[ %s ]已无效.';

        nStr := Format(nStr, [nLID]);
        WriteLog(nStr);
        Exit;
      end;

      First;

      while not Eof do
      begin
        FListB.Clear;

        FListB.Values['CusID']      := FieldByName('D_ProID').AsString;
        FListB.Values['MsgType']    := nList.Values['WOM_MsgType'];
        FListB.Values['BillID']     := FieldByName('D_OID').AsString;
        FListB.Values['Card']       := FieldByName('D_Card').AsString;
        FListB.Values['Truck']      := FieldByName('D_Truck').AsString;
        FListB.Values['StockNo']    := FieldByName('D_StockNo').AsString;
        FListB.Values['StockName']  := FieldByName('D_StockName').AsString;
        FListB.Values['CusName']    := FieldByName('D_ProName').AsString;
        FListB.Values['Value']      := FieldByName('D_Value').AsString;

        nStr := PackerEncodeStr(FListB.Text);

//        Result := TBusWorkerBusinessWebchat.CallMe(cBC_WX_send_event_msg
//           ,nStr,'',@nOut);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

procedure TMessageScanThread.UpdateMsgNum(const nSuccess: Boolean; nLID: string);
var nStr: string;
    nUpdateDBWorker: PDBWorker;
begin
  if nSuccess then
  begin
    nUpdateDBWorker := nil;

    try
        nStr := 'Update %s set H_Deleted = ''%s'' where H_ID = ''%s''';
        nStr:= Format(nStr,[sTable_HHJYSync, sFlag_Yes,nLID]);
        gDBConnManager.ExecSQL(nStr);
        //更新为已处理
    finally
      gDBConnManager.ReleaseConnection(nUpdateDBWorker);
    end;
  end
  else
  begin
    nUpdateDBWorker := nil;

    try
      nStr := 'Update %s Set H_SyncNum = H_SyncNum + 1 '+
                ' where H_ID = ''%s''';
      nStr:= Format(nStr,[sTable_HHJYSync, nLID]);
      gDBConnManager.ExecSQL(nStr);
    finally
      gDBConnManager.ReleaseConnection(nUpdateDBWorker);
    end;
  end;
end;

procedure TMessageScanThread.DoSaveOutFactMsg;
var nStr: string;
    nInit: Int64;
    nErr,nIdx: Integer;
    nOut: TWorkerWebChatData;
begin
  nStr:= 'select top 100 * from %s where WOM_StatusType =%d Order by R_ID desc';
  nStr:= Format(nStr,[sTable_WebOrderMatch, c_WeChatStatusCreateCard]);
  //查询最近100条网上开单记录
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
      Exit;
    //无新消息
    WriteLog('共查询到'+ IntToStr(RecordCount) + '条数据,开始筛选...');
    nInit := GetTickCount;
    FListB.Clear;

    First;

    while not Eof do
    begin
      FListA.Clear;
      FListA.Values['WOM_WebOrderID'] := FieldByName('WOM_WebOrderID').AsString;
      FListA.Values['WOM_LID']:= FieldByName('WOM_LID').AsString;
      FListA.Values['WOM_StatusType']:= FieldByName('WOM_StatusType').AsString;
      FListA.Values['WOM_MsgType']:= FieldByName('WOM_MsgType').AsString;
      FListA.Values['WOM_BillType']:= FieldByName('WOM_BillType').AsString;
      nStr := StringReplace(FListA.Text, #$D#$A, '\S', [rfReplaceAll]);
      FListB.Add(nStr);
      Next;
    end;
  end;
  for nIdx := 0 to FListB.Count - 1 do
  begin
    nStr := FListB.Strings[nIdx];
    FListA.Text := StringReplace(nStr, '\S', #$D#$A, [rfReplaceAll]);
    if FListA.Values['WOM_BillType'] = sFlag_Sale then
      SaveSaleOutFactMsg(FListA)
    else
      SaveOrderOutFactMsg(FListA);
  end;
  WriteLog('插入出厂推送消息耗时: ' + IntToStr(GetTickCount - nInit) + 'ms');
end;

function TMessageScanThread.SaveSaleOutFactMsg(nList: TStrings): Boolean;
var nStr, nLID, nTableName: string;
begin
  Result := False;
  nLID := nList.Values['WOM_LID'];

  nStr := 'select L_ID from %s where L_ID=''%s'' and L_OutFact is not null ';
  nStr := Format(nStr,[sTable_Bill,nLID]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      Exit;
    end;
  end;

  nStr := 'select WOM_LID from %s where WOM_LID=''%s'' and WOM_StatusType=%d ';
  nStr := Format(nStr,[sTable_WebOrderMatch,nLID,c_WeChatStatusFinished]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount >= 1 then
    begin
      Exit;
    end;
  end;

  WriteLog('查询到提货单'+ nLID +'已出厂,插入推送消息...');

  nStr := 'insert into %s(WOM_WebOrderID,WOM_LID,WOM_StatusType,WOM_MsgType,WOM_BillType)'
          + ' values(''%s'',''%s'',%d,%d,''%s'')';
  nStr := Format(nStr,[sTable_WebOrderMatch,nList.Values['WOM_WebOrderID'],
                       nLID,c_WeChatStatusFinished,cSendWeChatMsgType_OutFactory,
                       nList.Values['WOM_BillType']]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
  Result := True;
end;

function TMessageScanThread.SaveOrderOutFactMsg(nList: TStrings): Boolean;
var nStr, nLID, nTableName: string;
begin
  Result := False;
  nLID := nList.Values['WOM_LID'];

  nStr := 'select D_ID from %s where D_OID=''%s'' and D_OutFact is not null ';
  nStr := Format(nStr,[sTable_OrderDtl,nLID]);
  //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      Exit;
    end;
  end;

  nStr := 'select WOM_LID from %s where WOM_LID=''%s'' and WOM_StatusType=%d ';
  nStr := Format(nStr,[sTable_WebOrderMatch,nLID,c_WeChatStatusFinished]);
  //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount >= 1 then
    begin
      Exit;
    end;
  end;

  WriteLog('查询到采购单'+ nLID +'已出厂,插入推送消息...');

  nStr := 'insert into %s(WOM_WebOrderID,WOM_LID,WOM_StatusType,WOM_MsgType,WOM_BillType)'
          + ' values(''%s'',''%s'',%d,%d,''%s'')';
  nStr := Format(nStr,[sTable_WebOrderMatch,nList.Values['WOM_WebOrderID'],
                       nLID,c_WeChatStatusFinished,cSendWeChatMsgType_OutFactory,
                       nList.Values['WOM_BillType']]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
  Result := True;
end;

procedure TMessageScanThread.DoSendWLFYOrderInfo;
var
  nStr:string;
  nInit: Int64;
  nIdx: Integer;
  dSet:TDataSet;
begin
  nStr := ' Select Top 1000 * from %s where con_Synstatus = 0 Order by R_ID DESC ';
  nStr := format(nStr,[sTable_PurchaseContract]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nStr := 'select Top 1000 B_ID as pcId, ' +
              'B_ProID as provider_code, ' +
              'B_ProName as provider_name, ' +
              'B_ID as con_code, ' +
              'B_StockNo as con_materiel_Code, ' +
              'B_StockName as con_materiel_name, ' +
              '0 as con_price, ' +
              'B_Value as con_quantity, ' +
              'B_SentValue as con_finished_quantity, ' +
              'B_Date as con_date, ' +
              'B_Memo as con_remark' + ' from %s where B_SynStatus = 0 Order by R_ID DESC';
      nStr := format(nStr,[sTable_OrderBase]);
      dSet := gDBConnManager.WorkerQuery(FDBConn, nStr);
      //荆门无合同表 执行申请表查询
      if dSet.RecordCount < 1 then
        Exit;
    end;

    //无新消息
    WriteLog('共查询到'+ IntToStr(RecordCount) + '条数据,开始筛选...');
    nInit := GetTickCount;
    FListB.Clear;

    First;

    while not Eof do
    begin
      FListA.Clear;
      FListA.Values['H_ID']         := FieldByName('pcId').AsString;
      FListA.Values['H_Order']      := FieldByName('con_code').AsString;
      FListA.Values['H_Status']     := '1';
      FListA.Values['H_BillType']   := sFlag_Provide;
      FListA.Values['H_PurType']    := sFlag_Provide;
      nStr := StringReplace(FListA.Text, #$D#$A, '\S', [rfReplaceAll]);
      FListB.Add(nStr);
      Next;
    end;
  end;

  for nIdx := 0 to FListB.Count - 1 do
  begin
    nStr := FListB.Strings[nIdx];
    FListA.Text := StringReplace(nStr, '\S', #$D#$A, [rfReplaceAll]);
    SaveMakeOrderMsg(FListA);
  end;
  WriteLog('插入采购订单推送消息耗时: ' + IntToStr(GetTickCount - nInit) + 'ms');
end;

function TMessageScanThread.SaveMakeOrderMsg(nList: TStrings): Boolean;
var nStr, nLID, nTableName: string;
begin
  Result := False;
  
  WriteLog('查询到采购订单'+ nList.Values['H_ID'] +',插入推送消息...');

  nStr := 'select H_ID from %s where H_ID=''%s'' and H_Order=''%s'' and H_Deleted <> ''%s'' ';
  nStr := Format(nStr,[sTable_HHJYSync,nList.Values['H_ID'],nList.Values['H_Order'],'Y']);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount >= 1 then
    begin
      Exit;
    end;
  end;

  nStr := 'insert into %s(H_ID,H_Order,H_Status,H_BillType,H_PurType)'
          + ' values(''%s'',''%s'',''%s'',''%s'',''%s'')';
  nStr := Format(nStr,[sTable_HHJYSync,nList.Values['H_ID'],
                       nList.Values['H_Order'],nList.Values['H_Status'],nList.Values['H_BillType'],
                       nList.Values['H_PurType']]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
  Result := True;
end;

initialization
  gMessageScan := nil;
finalization
  FreeAndNil(gMessageScan);
end.

