{*******************************************************************************
  作者: fendou116688@163.com 2016-02-27
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusinessOrders;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusinessCommand, UHardBusiness;

type
  TWorkerBusinessOrders = class(TMITDBWorker)
  private
    FListA,FListB,FListC,FListD: TStrings;
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

implementation

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
  FListD := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessOrders.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
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
    nName,nCondition,nValue, nUnit, nPunishcondition:string;
    nPunishBasis,nPunishStandard:double;
    nPunishMode:integer;
    ndValue:Double;
    j:Integer;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  //init

  FListC.Clear;
  FListC.Values['Group'] :=sFlag_BusGroup;
  FListC.Values['Object'] := sFlag_PurchaseContract;
  //to get serial no

  if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
        FListC.Text, sFlag_Yes, @nOut) then
    raise Exception.Create(nOut.FData);
  //xxxxx

  FOut.FData := nOut.FData;
  //PurchaseContract ID

  FListB.Clear;
  //SQL List

  with FListA do
  nStr := MakeSQLByStr([SF('pcid', FOut.FData),
          SF('provider_code', Values['ProviderCode']),
          SF('provider_name', Values['ProviderName']),
          SF('con_materiel_Code', Values['MeterailCode']),
          SF('con_materiel_name',Values['MeterailName']),
          SF('con_code', Values['ContractNo']),
          SF('con_finished_quantity', 0,sfVal),

          SF('con_price',  StrToFloatDef(Values['Price'],0),sfVal),
          SF('con_quantity', StrToFloatDef(Values['quantity'],0),sfVal),
          SF('con_status', StrToint(sFlag_PurchaseContract_input),sfVal),
          SF('con_Man', FIn.FBase.FFrom.FUser),
          SF('con_remark', Values['Remark'])
          ], sTable_PurchaseContract, '', True);
  FListB.Add(nStr);

  FListC.Text :=  PackerDecodeStr(FListA.Values['QuotaList']);
  for nIdx := 0 to FListC.Count - 1 do
  begin
    FListD.Clear;
    FListD.CommaText := FListC[nIdx];
    for j := FListD.Count-1 downto 0 do
    begin
      if FListD.Strings[j]='' then
      begin
        FListD.Delete(j);
      end;
    end;
    nName := FListD[0];
    nUnit := FListD[1];
    nCondition := FListD[2];
    nValue:= FListD[3];
    ndValue := StrToFloatDef(nValue,0);

    nPunishcondition :='';
    nPunishStandard := 0;
    nPunishBasis := 0;
    nPunishMode := 0;

    if FListD.Count > 4 then
    begin
      nPunishcondition := FListD[4];
      nPunishBasis := StrToFloatDef(FListD[5],0);
      nPunishStandard := StrToFloatDef(FListD[6],0);
      if FListD[7]='单价' then
      begin
        nPunishMode := 1;
      end
      else if FListD[6]='净重' then
      begin
        nPunishMode := 2;
      end;
    end;

    nStr := MakeSQLByStr([SF('pcid', FOut.FData),
            SF('quota_name', nName),
            SF('quota_condition', nCondition),
            SF('quota_value', ndValue,sfVal),
            SF('quota_unit', nUnit),
            SF('punish_condition', nPunishcondition),
            SF('punish_Basis', nPunishBasis,sfVal),
            SF('punish_standard', nPunishStandard,sfVal),
            SF('punish_mode', nPunishMode,sfVal),
            SF('remark', '')
            ], sTable_PurchaseContractDetail, '', True);
    FListB.Add(nStr);
  end;

  FDBConn.FConn.BeginTrans;
  try
    for nIdx := 0 to FListB.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListB[nIdx]);
    //执行

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
//Desc: 修改采购合同
function TWorkerBusinessOrders.ModifyPurchaseContract(var nData: string):Boolean;
var nStr: string;
    nIdx: Integer;
    nName,nCondition,nValue:string;
    nPunishcondition:string;
    nPunishBasis,nPunishStandard:double;
    nPunishMode:integer;
    ndValue:Double;
    nUnit:string;
    j:integer;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);

  FOut.FData := FListA.Values['FID'];

  FListD.Clear;
  //SQL List

  with FListA do
  begin
    nStr := MakeSQLByStr([SF('provider_code', Values['ProviderCode']),
            SF('provider_name', Values['ProviderName']),
            SF('con_code', Values['ContractNo']),
            SF('con_materiel_Code', Values['MeterailCode']),
            SF('con_materiel_name',Values['MeterailName']),
            SF('con_price',  StrToFloatDef(Values['Price'],0),sfVal),
            SF('con_quantity', StrToFloatDef(Values['quantity'],0),sfVal),
            SF('con_status', StrToint(sFlag_PurchaseContract_input),sfVal),
            SF('con_MdyMan', FIn.FBase.FFrom.FUser),
            SF('con_MdyDate', sField_SQLServer_Now,sfVal),
            SF('con_remark', Values['Remark'])
            ], sTable_PurchaseContract, SF('PCID', Values['FID']), False);
    FListD.Add(nStr);

    nStr := 'insert into %s(pcId,quota_name,quota_condition,quota_value,'  +
            'punish_condition,punish_Basis,punish_standard,punish_mode,Del_man,Del_Date,remark) '  +
            'select pcId,quota_name,quota_condition,quota_value,punish_condition,' +
            'punish_Basis,punish_standard,punish_mode,''%s'',%s,remark From %s ' +
            'where pcid=''%s''';
    nStr := Format(nStr,[sTable_PurchaseContractDetail_bak,
            FIn.FBase.FFrom.FUser, sField_SQLServer_Now,
            sTable_PurchaseContractDetail,
            Values['FID']]);
    FListD.Add(nStr);
    //保存历史合同明细到备份表

    nStr := 'delete from %s where pcid=''%s''';
    nStr := Format(nStr,[sTable_PurchaseContractDetail,Values['FID']]);
    FListD.Add(nStr);
    //删除明细

    FListB.Text := PackerDecodeStr(Values['QuotaList']);
    for nIdx := 0 to FListB.Count - 1 do
    begin
      FListC.CommaText := FListB[nIdx];
      for j := FListC.Count-1 downto 0 do
      begin
        if FListC.Strings[j]='' then
        begin
          FListC.Delete(j);
        end;
      end;

      nPunishcondition :='';
      nPunishStandard := 0;
      nPunishBasis := 0;
      nPunishMode := 0;

      nName := FListC[0];
      nUnit := FListC[1];
      nCondition := FListC[2];
      nValue :=  FListC[3];
      ndValue := StrToFloatDef(nValue,0);

      if FListC.Count > 4 then
      begin
        nPunishcondition := FListC[4];
        nPunishBasis := StrToFloatDef(FListC[5],0)/100;
        nPunishStandard := StrToFloatDef(FListC[6],0);
        if FListC[7]='单价' then
        begin
          nPunishMode := 1;
        end
        else if FListC[7]='净重' then
        begin
          nPunishMode := 2;
        end;
      end;

      nStr := MakeSQLByStr([SF('pcid', Values['FID']),
              SF('quota_name', nName),
              SF('quota_unit', nUnit),
              SF('quota_condition', nCondition),
              SF('quota_value', ndValue,sfval),
              SF('punish_condition', nPunishcondition),
              SF('punish_Basis', nPunishBasis,sfVal),
              SF('punish_standard', nPunishStandard,sfVal),
              SF('punish_mode', nPunishMode,sfVal),
              SF('remark', '')
              ], sTable_PurchaseContractDetail, '', True);
      FListD.Add(nStr);
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    for nIdx := 0 to FListD.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListD[nIdx]);

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
//Desc: 删除采购合同
function TWorkerBusinessOrders.DeletePurchaseContract(var nData: string):Boolean;
var nStr:string;
begin
  Result := False;
  {
  nStr := 'Select Count(*) From %s Where PCID=''%s''';
  nStr := Format(nStr, [sTable_Order, Trim(FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '采购合同[ %s ]已被使用.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;
  }
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set con_DelMan=''%s'',con_DelDate=%s,con_Status=%d ' +
            'Where PCID=''%s''';
    nStr := Format(nStr,[sTable_PurchaseContract, FIn.FBase.FFrom.FUser,
            sField_SQLServer_Now, StrToInt(sFlag_PurchaseContract_deleted),
            FIn.FData]);

    gDBConnManager.WorkerExec(FDBConn, nStr);
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    on E:Exception do
    begin
      nData := '删除采购合同[ %s ]发生错误，错误信息[ %s ].';
      nData := Format(nData, [FIn.FData,e.Message]);
      FDBConn.FConn.RollbackTrans;
    end;
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
var nStr, nTmp: string;
    nIdx: Integer;
    nVal: Double;
    nOut: TWorkerBusinessCommand;
    nWeborder:string;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nVal := StrToFloat(FListA.Values['Value']);
  nWeborder := FListA.Values['WebOrderID'];
  //unpack Order

  
  //begin判断该车牌号是否有未完成业务
  {$IFDEF MultiOrderOfTruck}
  nStr := 'select O_ID from %s where O_Truck=''%s'' and O_CType = ''%s'' and O_Card<>'''' ';  //先查临时卡未完成业务
  nStr := Format(nStr,[sTable_Order, FListA.Values['Truck'], sFlag_OrderCardL]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := False;
      FOut.FBase.FResult := False;
      nStr := '车辆[ %s ]在未完成[ %s ]采购单之前禁止开单.';
      nData := Format(nStr, [FListA.Values['Truck'], FieldByName('O_ID').AsString]);
      Fout.FBase.FErrDesc := nData;
      Exit;
    end;
  end;

  nStr := 'select O_ID,O_Card from %s where O_Truck=''%s'' and O_CType = ''%s'' and O_Card<>'''' ';   //再查固定卡未完成业务
  nStr := Format(nStr,[sTable_Order, FListA.Values['Truck'], sFlag_OrderCardG]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount>0 then
    begin
      nStr := 'select D_OID from %s where D_Card = ''%s'' ';
      nStr := Format(nStr, [sTable_OrderDtl, FieldByName('O_Card').AsString]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount>0 then
      begin
        Result := False;
        FOut.FBase.FResult := False;
        nStr := '车辆[ %s ]在未完成[ %s ]采购单之前禁止开单.';
        nData := Format(nStr, [FListA.Values['Truck'], FieldByName('D_OID').AsString]);
        Fout.FBase.FErrDesc := nData;
        Exit;
      end;
    end;
  end;
  {$ELSE}
  nStr := 'select O_ID from %s where O_Truck=''%s'' and O_Card<>'''' ';
  nStr := Format(nStr,[sTable_Order, FListA.Values['Truck']]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := False;
      FOut.FBase.FResult := False;
      nStr := '车辆[ %s ]在未完成[ %s ]采购单之前禁止开单.';
      nData := Format(nStr, [FListA.Values['Truck'], FieldByName('O_ID').AsString]);
      Fout.FBase.FErrDesc := nData;
      Exit;
    end;
  end;
  {$ENDIF}
  //end判断该车牌号是否有未完成业务
  
  
  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FListA.Values['Truck'],
    '', @nOut);
  //保存车牌号

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

    nTmp := nOut.FData;
    FOut.FData := FOut.FData + nTmp + ',';
    //combine Order

    nStr := MakeSQLByStr([SF('O_ID', nTmp),

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
    end else

    begin
      {$IFDEF TruckInLoop}
      FListC.Clear;
      FListC.Values['Group'] := sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_OrderDtl;

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      nStr := MakeSQLByStr([
            SF('D_ID', nOut.FData),
            SF('D_OID', nTmp),
            SF('D_Status', sFlag_TruckIn),
            SF('D_NextStatus', sFlag_TruckBFP),
            SF('D_InTime', sField_SQLServer_Now, sfVal)
            ], sTable_OrderDtl, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      {$ENDIF}
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

  //修改商城订单状态
  ModifyWebOrderStatus(nOut.FData,c_WeChatStatusCreateCard,nWeborder);
  //发送微信消息
  SendMsgToWebMall(nOut.FData,cSendWeChatMsgType_AddBill,sFlag_Provide);
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

  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //磁卡列表
  nSQL := 'Select O_ID,O_Card,O_Truck From %s Where O_Card In (%s)';
  nSQL := Format(nSQL, [sTable_Order, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('O_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '车辆[ %s ]正在使用该卡.';
        nData := Format(nData, [nStr]);
        Exit;
      end;

      Next;
    end;
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
    nSQL := 'select * from %s where O_ID=''%s''';
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
      nSQL := Format(nSQL,[sTable_OrderDtl,sTable_Order,npcid]);
      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        nSum := FieldByName('D_NetWeight').AsFloat + nVal;
        //历史总量 + 本次净重
      end;
      nSQL := 'update %s set con_finished_quantity=%f where pcid=''%s''';
      nSQL := Format(nSQL,[sTable_PurchaseContract,nSum,npcid]);
      FListA.Add(nSQL);
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

      nSQL := 'Select O_CType,O_Card From %s Where O_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Order, FZhiKa]);

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        nStr := FieldByName('O_CType').AsString;
        if nStr = sFlag_OrderCardL then
        begin
          nSQL := 'Update %s Set O_Card=Null Where O_Card=''%s''';
          nSQL := Format(nSQL, [sTable_Order, FCard]);
          FListA.Add(nSQL);

          nSQL := 'Update %s Set C_Status=''%s'', C_Used=Null Where C_Card=''%s''';
          nSQL := Format(nSQL, [sTable_Card, sFlag_CardInvalid, FCard]);
          FListA.Add(nSQL);
        end else

        begin
          {$IFDEF TruckInLoop}
          FListC.Clear;
          FListC.Values['Group'] := sFlag_BusGroup;
          FListC.Values['Object'] := sFlag_OrderDtl;

          if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
              FListC.Text, sFlag_Yes, @nOut) then
            raise Exception.Create(nOut.FData);
          //xxxxx

          nSQL := MakeSQLByStr([
                SF('D_ID', nOut.FData),
                SF('D_OID', FZhiKa),
                SF('D_Card', FCard),
                SF('D_Status', sFlag_TruckIn),
                SF('D_NextStatus', sFlag_TruckBFP),
                SF('D_InTime', sField_SQLServer_Now, sfVal)
                ], sTable_OrderDtl, '', True);
          FListA.Add(nSQL);
          {$ENDIF}
        end;
      end;
      //如果是临时卡片，则注销卡片
    end;

    nStr := nPound[0].FID;
    if not TWorkerBusinessCommander.CallMe(cBC_SyncStockOrder, nStr, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;
    //同步原材料
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
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessOrders, sPlug_ModuleBus);
end.
