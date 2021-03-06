{*******************************************************************************
  ����: fendou116688@163.com 2016-02-27
  ����: ģ��ҵ�����
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
    //�޸ĳ��ƺ�
    function GetGYOrderValue(var nData: string): Boolean;
    //��ȡ��Ӧ���ջ���

    function GetPostOrderItems(var nData: string): Boolean;
    //��ȡ��λ�ɹ���
    function GetPostOrderItemsKS(var nData: string): Boolean;
    //��ȡ��ɽ�ɹ���
    function SavePostOrderItems(var nData: string): Boolean;
    //�����λ�ɹ���
    function SavePostOrderItems_KS(var nData: string): Boolean;
    //�����ɽ�ɹ���(������)

    function ImportOrderPoundS(var nData: string): Boolean;
    //���������Ϣ
    function GetCardUsed(const nCard: string;var nCardType: string): Boolean;
    //��ȡ��Ƭ����
    function GetOrderInfo(const nOID: string;var nBID: string): Boolean;

    function getPrePInfo(const nTruck:string;var nPrePValue:Double;
                          var nPrePMan:string;var nPrePTime:TDateTime):Boolean;
    function GetInBillInterval: Integer;
    function VerifyPTruckCount(const nPID, nStockNo: string; var nHint: string): Boolean;
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
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessOrders.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
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
   cBC_GetPostOrders_KS     : Result := GetPostOrderItemsKS(nData);
   cBC_SavePostOrders       : Result := SavePostOrderItems(nData);
   cBC_GetGYOrderValue      : Result := GetGYOrderValue(nData);
   cBC_ImportOrderPoundS    : Result := ImportOrderPoundS(nData);
   
   cBC_AlterPostOrders      : Result := SavePostOrderItems_KS(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
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
            {$IFDEF UseWLFYInfo}
            SF('B_SynStatus', 0, sfVal),
            {$ENDIF}
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
//Desc: ɾ���ɹ����뵥
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
      nData := '�ɹ����뵥[ %s ]��ʹ��.';
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
      //�����ֶ�,������ɾ��

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
//Desc: ����ɹ���ͬ
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
          {$IFDEF UseWLFYInfo}
          SF('con_Synstatus', 0, sfVal),
          {$ENDIF}
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
      if FListD[7]='����' then
      begin
        nPunishMode := 1;
      end
      else if FListD[6]='����' then
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
    //ִ��

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
//Desc: �޸Ĳɹ���ͬ
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
            {$IFDEF UseWLFYInfo}
            SF('con_Synstatus', 0, sfVal),
            {$ENDIF}
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
    //������ʷ��ͬ��ϸ�����ݱ�

    nStr := 'delete from %s where pcid=''%s''';
    nStr := Format(nStr,[sTable_PurchaseContractDetail,Values['FID']]);
    FListD.Add(nStr);
    //ɾ����ϸ

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
        if FListC[7]='����' then
        begin
          nPunishMode := 1;
        end
        else if FListC[7]='����' then
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
//Desc: ɾ���ɹ���ͬ
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
      nData := '�ɹ���ͬ[ %s ]�ѱ�ʹ��.';
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
      nData := 'ɾ���ɹ���ͬ[ %s ]�������󣬴�����Ϣ[ %s ].';
      nData := Format(nData, [FIn.FData,e.Message]);
      FDBConn.FConn.RollbackTrans;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/20
//Parm:
//Desc: ��ȡ��Ӧ���ջ���
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
      nData := '�ɹ����뵥[%s]��Ϣ�Ѷ�ʧ';
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
//Desc: ����ɹ���
function TWorkerBusinessOrders.SaveOrder(var nData: string): Boolean;
var nStr, nTmp: string;
    nIdx,nInt: Integer;
    nVal: Double;
    nOut: TWorkerBusinessCommand;
    nWeborder:string;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nVal := StrToFloat(FListA.Values['Value']);
  nWeborder := FListA.Values['WebOrderID'];
  //unpack Order

  {$IFDEF PTruckCount}
  if not VerifyPTruckCount(FListA.Values['ProviderID'],FListA.Values['StockNO'], nHint) then
    raise Exception.Create(nHint);
  {$ENDIF}

  
  //begin�жϸó��ƺ��Ƿ���δ���ҵ��
  {$IFDEF MultiOrderOfTruck}
  nStr := 'select O_ID from %s where O_Truck=''%s'' and O_CType = ''%s'' and O_Card<>'''' ';  //�Ȳ���ʱ��δ���ҵ��
  nStr := Format(nStr,[sTable_Order, FListA.Values['Truck'], sFlag_OrderCardL]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := False;
      FOut.FBase.FResult := False;
      nStr := '����[ %s ]��δ���[ %s ]�ɹ���֮ǰ��ֹ����.';
      nData := Format(nStr, [FListA.Values['Truck'], FieldByName('O_ID').AsString]);
      Fout.FBase.FErrDesc := nData;
      Exit;
    end;
  end;

  nStr := 'select O_ID,O_Card from %s where O_Truck=''%s'' and O_CType = ''%s'' and O_Card<>'''' ';   //�ٲ�̶���δ���ҵ��
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
        nStr := '����[ %s ]��δ���[ %s ]�ɹ���֮ǰ��ֹ����.';
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
      nStr := '����[ %s ]��δ���[ %s ]�ɹ���֮ǰ��ֹ����.';
      nData := Format(nStr, [FListA.Values['Truck'], FieldByName('O_ID').AsString]);
      Fout.FBase.FErrDesc := nData;
      Exit;
    end;
  end;
  {$ENDIF}
  //end�жϸó��ƺ��Ƿ���δ���ҵ��

  {$IFDEF TruckParkReadyEx}
  nInt := GetInBillInterval;
  
  nStr := ' Select %s as T_Now,T_LastTime,T_NoVerify,T_Valid,T_MaxBillNum From %s ' +
          ' Where T_Truck=''%s''';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, FListA.Values['Truck']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      Result := False;
      FOut.FBase.FResult := False;
      nData := 'û�г���[ %s ]�ĵ���,�޷�����.';
      nData := Format(nData, [FListA.Values['Truck']]);
      Fout.FBase.FErrDesc := nData;
      Exit;
    end;

    if FieldByName('T_Valid').AsString = sFlag_No then
    begin
      Result := False;
      FOut.FBase.FResult := False;
      nData := '����[ %s ]������Ա��ֹ����.';
      nData := Format(nData, [FListA.Values['Truck']]);
      Fout.FBase.FErrDesc := nData;
      Exit;
    end;

    if FieldByName('T_NoVerify').AsString <> sFlag_Yes then
    begin
      nIdx := Trunc((FieldByName('T_Now').AsDateTime -
                     FieldByName('T_LastTime').AsDateTime) * 24 * 60);
      //�ϴλ������

      if nIdx >= nInt then
      begin
        Result := False;
        nData  := '����[ %s ]���ܲ���ͣ����,��ֹ����.';
        nData  := Format(nData, [FListA.Values['Truck']]);
        Exit;
      end;
    end;
  end;
  {$ENDIF}

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FListA.Values['Truck'],
    '', @nOut);
  //���泵�ƺ�

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
            SF('O_WebOrderID',nWeborder),
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

  //�޸��̳Ƕ���״̬
  ModifyWebOrderStatus(sFlag_Provide,nOut.FData,'SaveOrder', '��������',
                       c_WeChatStatusCreateCard,nWeborder);
  //����΢����Ϣ
  SendMsgToWebMall(nOut.FData,cSendWeChatMsgType_AddBill,sFlag_Provide, nWeborder);
end;

//Date: 2015-8-5
//Desc: ����ɹ���
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
      nData := '�ɹ���[ %s ]��ʹ��.';
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
      //�����ֶ�,������ɾ��

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
//Parm: �ɹ�����[FIn.FData];�ſ���[FIn.FExtParam]
//Desc: Ϊ�ɹ����󶨴ſ�
function TWorkerBusinessOrders.SaveOrderCard(var nData: string): Boolean;
var nStr,nSQL,nTruck: string;
begin
  Result := False;
  nTruck := '';

  FListB.Text := FIn.FExtParam;
  //�ſ��б�
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //�ɹ����б�

  nSQL := 'Select O_ID,O_Card,O_Truck From %s Where O_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Order, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('�ɹ�����[ %s ]�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      nStr := FieldByName('O_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '�ɹ���[ %s ]�ĳ��ƺŲ�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.��������: %s' + #13#10 +
                 '*.��������: %s' + #13#10#13#10 +
                 '��ͬ�ƺŲ��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
        nData := Format(nData, [FieldByName('O_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('O_Card').AsString;
      //����ʹ�õĴſ�
        
      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //�ſ��б�
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
        nData := '����[ %s ]����ʹ�øÿ�.';
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
      //���¼����б�

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
    WriteLog('�쿨�ɹ�');
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015-8-5
//Desc: ����ɹ���
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
    //�����޸���Ϣ

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: �ſ���[FIn.FData];��λ[FIn.FExtParam]
//Desc: ��ȡ�ض���λ����Ҫ�Ľ������б�
function TWorkerBusinessOrders.GetPostOrderItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsOrder: Boolean;
    nBills: TLadingBillItems;
    nCType:string;
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
    //ǰ׺�ͳ��ȶ�����ɹ����������,����Ϊ�ɹ�����
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
        nData := Format('�ſ�[ %s ]��Ϣ�Ѷ�ʧ.', [FIn.FData]);
        Exit;
      end;

      if Fields[0].AsString <> sFlag_CardUsed then
      begin
        nData := '�ſ�[ %s ]��ǰ״̬Ϊ[ %s ],�޷����.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '�ſ�[ %s ]�ѱ�����,�޷����.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;

  nStr := ' Select O_ID,O_Card,O_ProID,O_ProName,O_Type,O_StockNo, ' +
          ' O_StockName,O_Truck,O_Value,O_CType ' +
          ' From $OO oo ';
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
           nData := '�ɹ���[ %s ]����Ч.'
      else nData := '�ſ���[ %s ]�޶���';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end else
    with FListA do
    begin
      Clear;
      nCType                 := FieldByName('O_CType').AsString;
      Values['O_ID']         := FieldByName('O_ID').AsString;
      Values['O_ProID']      := FieldByName('O_ProID').AsString;
      Values['O_ProName']    := FieldByName('O_ProName').AsString;
      Values['O_Truck']      := FieldByName('O_Truck').AsString;

      Values['O_Type']       := FieldByName('O_Type').AsString;
      Values['O_StockNo']    := FieldByName('O_StockNo').AsString;
      Values['O_StockName']  := FieldByName('O_StockName').AsString;

      Values['O_Card']       := FieldByName('O_Card').AsString;
      Values['O_Value']      := FloatToStr(FieldByName('O_Value').AsFloat);
      Values['ctype']        := nCType;
    end;
  end;
  {$IFDEF AddKSYW}
  nStr := 'Select D_ID,D_OID,D_PID,D_YLine,D_Status,D_NextStatus,' +
          'D_KZValue,D_Memo,D_YSResult,' +
          'P_PStation,P_PValue,P_PDate,P_PMan, ' +
          'P_MStation,P_MValue,P_MDate,P_MMan, D_IsMT ' +
          'From $OD od Left join $PD pd on pd.P_Order=od.D_ID ' +
          'Where D_OutFact Is Null And D_OID=''$OID''';
  //xxxxx
  {$ELSE}
  nStr := 'Select D_ID,D_OID,D_PID,D_YLine,D_Status,D_NextStatus,' +
          'D_KZValue,D_Memo,D_YSResult,' +
          'P_PStation,P_PValue,P_PDate,P_PMan, ' +
          'P_MStation,P_MValue,P_MDate,P_MMan  ' +
          'From $OD od Left join $PD pd on pd.P_Order=od.D_ID ' +
          'Where D_OutFact Is Null And D_OID=''$OID''';
  //xxxxx
  {$ENDIF}

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
        FID         := '';
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
        FCtype      := nCType;

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
        FCtype    := nCType;
        {$IFDEF AddKSYW}
        FIsKS     := StrToIntDef(FieldByName('D_IsMT').AsString,0) ;
        {$ENDIF}
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
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
function TWorkerBusinessOrders.SavePostOrderItems(var nData: string): Boolean;
var nVal: Double;
    nIdx, nInt: Integer;
    nStr,nSQL, nYS, nPID: string;
    nCardType: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    npcid:string;//�ɹ���ͬ��
    nSum:Double;
    nBID:string;
    nYTOuttime:string;
    nIsPreTruck, nUpdate: Boolean;
    nPrePValue:Double;
    nPrePMan:string;
    nPrePTime:TDateTime;
    nStatus,nNextStatus :string;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nPound);
  nInt := Length(nPound);
  //��������

  if nInt < 1 then
  begin
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '��λ[ %s ]�ύ��ԭ���Ϻϵ�,��ҵ��ϵͳ��ʱ��֧��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;
  //�޺ϵ�ҵ��

  nIsPreTruck := getPrepinfo(nPound[0].Ftruck,nPrePValue,nPrePMan,nPrePTime);
  
  FListA.Clear;
  //���ڴ洢SQL�б�

  nCardType := '';
  if not GetCardUsed(nPound[0].Fcard, nCardType) then Exit;

  nBID :='';
  if nCardType = sFlag_Provide then
  begin
    GetOrderInfo(nPound[0].FZhiKa,nBID);
  end;
  
  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
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
            {$IFDEF AddKSYW}
            SF('D_IsMT', FIsKS),
            {$ELSE}
            SF('D_IsMT', sFlag_No),
            {$ENDIF}
            SF('D_InMan', FIn.FBase.FFrom.FUser),
            SF('D_InTime', sField_SQLServer_Now, sfVal)
            ], sTable_OrderDtl, '', True);
      FListA.Add(nSQL);
    end;  
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //����Ƥ��
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
    //���ذ񵥺�,�������հ�
    with nPound[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckXH;

      if (FListB.IndexOf(FStockNo) >= 0) or (nYS <> sFlag_Yes) then
        FNextStatus := sFlag_TruckBFM;
      //�ֳ�������ֱ�ӹ���

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
            SF('P_Direction', '����'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_BID', nBID),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_PValue', FPData.FValue, sfVal),
              SF('D_PDate', sField_SQLServer_Now, sfVal),
              {$IFDEF AddKSYW}
              SF('D_IsMT', FIsKS),
              {$ELSE}
              SF('D_IsMT', sFlag_No),
              {$ENDIF}
              SF('D_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL);
      {$IFNDEF NoUpdatePrePValue}
      if nIsPreTruck then
      begin
        nSQL := ' update %s set T_PrePValue=%f,T_PrePMan=''%s'',T_PrePTime=%s where t_truck=''%s'' and T_PrePUse = ''%s'' ';
        nSQL := format(nSQL,[sTable_Truck,FPData.FValue,FIn.FBase.FFrom.FUser,sField_SQLServer_Now,FTruck,sflag_yes]);
        FListA.Add(nSQL);
      end;
      {$ENDIF}
    end;

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckXH then //�����ֳ�
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
        //���տ���
       FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_YTime', sField_SQLServer_Now, sfVal),
              SF('D_YMan', FIn.FBase.FFrom.FUser),
              SF('D_KZValue', FKZValue, sfVal),
              SF('D_YSResult', FYSValid),
              SF('D_YLine', FPoundID),      //һ�߻����
              SF('D_YLineName', FHKRecord), //ж���ص�
              SF('D_Memo', FMemo)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    with nPound[0] do
    begin
      nStr := SF('P_Order', FID);
      //where
      nStatus     := sFlag_TruckBFM;
      nNextStatus := sFlag_TruckOut;
      //���ڿ�+Ԥ��Ƥ�أ���һ״̬Ϊë��
      if (FCtype=sFlag_CardGuDing) and nIsPreTruck then
      begin
        nNextStatus := sFlag_TruckBFM;
      end;

      nVal := FMData.FValue - FPData.FValue -FKZValue;

      if (nStatus=sFlag_TruckBFM) and (nNextStatus=sFlag_TruckBFM) then
      begin
//        nStr := ' Select P_Order From %s Where P_Order=''%s''';
//        nStr := Format(nStr, [sTable_PoundLog, FID]);
//        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
//        if RecordCount > 0 then
//             nUpdate := True
//        else nUpdate := False;

        FListC.Clear;
        FListC.Values['Group']  := sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_PoundID;

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
                FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        FOut.FData := nOut.FData;

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
            SF('P_PDate', FPData.FDate, sfDateTime),
            SF('P_PMan', FPData.FOperator),
            SF('P_MValue', FMData.FValue, sfVal),
            SF('P_MDate', sField_SQLServer_Now, sfVal),
            SF('P_MMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '����'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_BID', nBID),
            SF('P_Model', FPModel),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
              SF('D_Status', nStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_PValue', FPData.FValue, sfVal),
              SF('D_PDate', FPData.FDate, sfDateTime),
              SF('D_PMan', FPData.FOperator),

              SF('D_MValue', FMData.FValue, sfVal),
              SF('D_MDate', sField_SQLServer_Now, sfVal),
              SF('D_MMan', FIn.FBase.FFrom.FUser)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);
      end
      else
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
        //����ʱ,����Ƥ�ش�,����Ƥë������
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
      //���泵����ЧƤ��

      if FYSValid <> sFlag_NO then  //���ճɹ����������ջ���
      begin
        nSQL := 'Update $OrderBase Set B_SentValue=B_SentValue+$Val ' +
                'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'')';
        nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
                MI('$Order', sTable_Order),MI('$ID', FZhiKa),
                MI('$Val', FloatToStr(nVal))]);
        FListA.Add(nSQL);
        //�������ջ���
      end;

      nSQL := 'Update $OrderBase Set B_FreezeValue=B_FreezeValue-$KDVal ' +
              'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'''+
              ' And O_CType= ''L'') and B_Value>0';
      nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
              MI('$Order', sTable_Order),MI('$ID', FZhiKa),
              MI('$KDVal', FloatToStr(FValue))]);
      FListA.Add(nSQL);
      //����������
    end;

    nSQL := 'Select P_ID From %s Where P_Order=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nPound[0].FID]);
    //δ��ë�ؼ�¼

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;

    //�����ͬ�������
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
        //��ʷ���� + ���ξ���
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
      nYTOuttime := '';
      nSQL := ' Select D_YTOutFact From %s Where D_ID = ''%s'' And D_YTOutFact Is not Null And D_YTOutFact <> '''' ';
      nSQL := Format(nSQL, [sTable_OrderDtl, FID]);

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        nYTOuttime := Fields[0].AsString;
        if Length(Trim(nYTOuttime)) <= 10 then
          nYTOuttime := nYTOuttime + ' 00:00:01';
      end;
      
      if nYTOuttime = '' then
      begin
        nSQL := MakeSQLByStr([SF('D_Status', sFlag_TruckOut),
                SF('D_NextStatus', ''),
                SF('D_Card', ''),
                SF('D_OutFact', sField_SQLServer_Now, sfVal),
                SF('D_OutMan', FIn.FBase.FFrom.FUser)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL); //���²ɹ���
      end
      else
      begin
        nSQL := MakeSQLByStr([SF('D_Status', sFlag_TruckOut),
                SF('D_NextStatus', ''),
                SF('D_Card', ''),
                SF('D_OutFact', nYTOuttime),
                SF('D_OutMan', FIn.FBase.FFrom.FUser)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL); //���²ɹ���
      end;

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
          if FIsKS <> 2 then
          begin
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
          end;
          {$ENDIF}
        end;
      end;
      //�������ʱ��Ƭ����ע����Ƭ
    end;

    nStr := nPound[0].FID;
    if not TWorkerBusinessCommander.CallMe(cBC_SyncStockOrder, nStr, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;
    //ͬ��ԭ����
    
    {$IFDEF UseWLFYInfo}
    with nPound[0] do
    begin
      nSQL := 'Select Top 1 P_ID,P_BID From %s Where P_Order=''%s'' order by R_ID desc ';
      nSQL := Format(nSQL, [sTable_PoundLog, FID]);

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        nPID := Fields[0].AsString;
        nSQL := MakeSQLByStr([
              SF('H_ID'   , nPID),
              SF('H_Order' , Fields[1].AsString),
              SF('H_Status' , '1'),
              SF('H_BillType'   , sFlag_Provide)
              ], sTable_HHJYSync, '', True);
        WriteLog('�ɹ�������ͬ����Ϣ:' + nSQL);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
      end;
    end;
    {$ENDIF}
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

  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    //���ڿ�+Ԥ��Ƥ�أ����Զ�����
    if (nPound[0].FCtype=sFlag_CardGuDing) and nIsPreTruck then
    begin
      //null;
    end
    else
    begin
      {$IFDEF PurAutoOutByStokNo}
      nSQL := 'Select D_Value From %s Where D_Name=''AutoOutStock'' and D_Value=''%s''';
      nSQL := Format(nSQL, [sTable_SysDict, nPound[0].FStockNo]);

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        gHardShareData('TruckOut:' + nPound[0].FCard);
        //���������Զ�����
        WriteLog('���������Զ�����:' +nPound[0].FCard);
      end;
      {$ELSE}
      if Assigned(gHardShareData) then
        gHardShareData('TruckOut:' + nPound[0].FCard);
      //���������Զ�����
      {$ENDIF}
    end;
  end;
end;

function TWorkerBusinessOrders.ImportOrderPoundS(var nData: string): Boolean;
var nIdx: Integer;
    nSQL, nIDS: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  //����������Ϣ

  if FListA.Count < 1 then
  begin
    nData := '�޵�����Ϣ��¼';
    Exit;
  end;

  FListC.Clear;
  //�������
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

    nData := '������[%s]�Ѵ���';
    nData := Format(nData, [nIDS]);
    Exit;
  end;
  //�ظ������Ž�ֹʹ��
  
  FListC.Clear;
  //���ݿ����
  
  for nIdx := 0 to FListA.Count - 1 do
  begin
    FListB.Text := PackerDecodeStr(FListA[nIdx]);
    //������¼��Ϣ

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

            SF('P_Direction', '����'),
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
  //�����������

  FListC.Clear;
  //�������
  
  for nIdx := 0 to FListA.Count - 1 do
  begin
    FListB.Text := PackerDecodeStr(FListA[nIdx]);
    FListC.Add('''' + FListB.Values['P_ID'] + '''');
  end;

  if FListC.Count < 1 then
  begin
    nData := '��ͬ����Ϣ��¼';
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
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
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

function TWorkerBusinessOrders.GetOrderInfo(const nOID: string; var nBID: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nBID :='';
  nStr := 'select O_BID from %s where O_ID =''%s''';
  nStr := format(nStr,[sTable_Order,nOID]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount>0 then
    begin
      nBID   := FieldByName('O_BID').asString;
      Result := True;
    end;
  end;
end;

function TWorkerBusinessOrders.GetCardUsed(const nCard: string;
  var nCardType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := TWorkerBusinessCommander.Callme(cBC_GetCardUsed, nCard, '', @nOut);

  if Result then
       nCardType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

function TWorkerBusinessOrders.getPrePInfo(const nTruck: string;
  var nPrePValue: Double; var nPrePMan: string;
  var nPrePTime: TDateTime): Boolean;
var
  nStr:string;
begin
  Result     := False;
  nPrePValue := 0;
  nPrePMan   := '';
  nPrePTime  := now;
  nStr       := ' Select T_PrePValue,T_PrePMan,T_PrePTime from %s where t_truck = ''%s'' and T_PrePUse = ''%s'' ';
  nStr       := format(nStr,[sTable_Truck,nTruck,sflag_yes]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount>0 then
    begin
      nPrePValue := FieldByName('T_PrePValue').asFloat;;
      nPrePMan   := FieldByName('T_PrePMan').asString;
      nPrePTime  := FieldByName('T_PrePTime').asDateTime;
      Result     := True;
    end;
  end;
end;

//�޸�Ʒ�����ƺ�ֱ�ӳ���
function TWorkerBusinessOrders.SavePostOrderItems_KS(
  var nData: string): Boolean;
var nVal: Double;
    nIdx, nInt: Integer;
    nStr,nSQL, nYS, nPID: string;
    nCardType: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    npcid:string;//�ɹ���ͬ��
    nSum:Double;
    nBID:string;
    nYTOuttime:string;
    nIsPreTruck:Boolean;
    nPrePValue:Double;
    nPrePMan:string;
    nPrePTime:TDateTime;
    nStatus,nNextStatus :string;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nPound);
  nInt := Length(nPound);
  //��������

  if nInt < 1 then
  begin
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '��λ[ %s ]�ύ��ԭ���Ϻϵ�,��ҵ��ϵͳ��ʱ��֧��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;
  //�޺ϵ�ҵ��

  FListA.Clear;
  //���ڴ洢SQL�б�
  with nPound[0] do
  begin
    nSQL := MakeSQLByStr([SF('D_StockNo', FStockNo),
            SF('D_StockName', FStockName)
            ], sTable_OrderDtl, SF('D_ID', FID), False);
    FListA.Add(nSQL); //���²ɹ���

    nSQL := MakeSQLByStr([SF('O_StockNo', FStockNo),
            SF('O_StockName', FStockName)
            ], sTable_Order, SF('O_Card', FCard), False);
    FListA.Add(nSQL);

    nSQL := MakeSQLByStr([
            SF('P_MID',   FStockNo),
            SF('P_MName', FStockName)
            ], sTable_PoundLog, SF('P_Order', FID), False);
    //xxxxx
    FListA.Add(nSQL);
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
end;

function TWorkerBusinessOrders.GetPostOrderItemsKS(
  var nData: string): Boolean;
var nStr, nDID : string;
    nIdx: Integer;
    nBills: TLadingBillItems;
    nCType:string;
begin
  Result := False;

  nDID   := FIn.FData;

  nStr := ' Select O_ID,O_Card,O_ProID,O_ProName,O_Type,O_StockNo, ' +
          ' O_StockName,O_Truck,O_Value,O_CType ' +
          ' From $OO oo ';
  //xxxxx
  nStr := nStr + ' Where O_ID = (Select distinct D_OID From P_OrderDtl Where D_ID = ''$CD'')';


  nStr := MacroValue(nStr, [MI('$OO', sTable_Order),MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '�ɹ���[ %s ]����Ч.';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end else
    with FListA do
    begin
      Clear;
      nCType                 := FieldByName('O_CType').AsString;
      Values['O_ID']         := FieldByName('O_ID').AsString;
      Values['O_ProID']      := FieldByName('O_ProID').AsString;
      Values['O_ProName']    := FieldByName('O_ProName').AsString;
      Values['O_Truck']      := FieldByName('O_Truck').AsString;

      Values['O_Type']       := FieldByName('O_Type').AsString;
      Values['O_StockNo']    := FieldByName('O_StockNo').AsString;
      Values['O_StockName']  := FieldByName('O_StockName').AsString;

      Values['O_Card']       := FieldByName('O_Card').AsString;
      Values['O_Value']      := FloatToStr(FieldByName('O_Value').AsFloat);
      Values['ctype']        := nCType;
    end;
  end;

  nStr := 'Select D_ID,D_OID,D_PID,D_YLine,D_Status,D_NextStatus,' +
          'D_KZValue,D_Memo,D_YSResult,' +
          'P_PStation,P_PValue,P_PDate,P_PMan, ' +
          'P_MStation,P_MValue,P_MDate,P_MMan, D_IsMT ' +
          'From $OD od Left join $PD pd on pd.P_Order=od.D_ID ' +
          'Where D_OutFact Is Null And D_ID=''$OID''';

  nStr := MacroValue(nStr, [MI('$OD', sTable_OrderDtl),
                            MI('$PD', sTable_PoundLog),
                            MI('$OID', nDID)]);
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
        FCtype      := nCType;

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
        FCtype    := nCType;
        FIsKS     := StrToIntDef(FieldByName('D_IsMT').AsString,0);
        FSelected := True;

        Inc(nIdx);
        Next;
      end;
    end;    
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

function TWorkerBusinessOrders.GetInBillInterval: Integer;
var nStr: string;
begin
  Result := 0;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_InAndBill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsInteger;
  end;
end;

function TWorkerBusinessOrders.VerifyPTruckCount(const nPID,
  nStockNo: string; var nHint: string): Boolean;
var nStr: string;
    nCount, nCountSet : Integer;
    nBDate, nEDate: string;
begin
  Result := True;
  nHint := '';
  nStr := 'Select * From %s Where C_CusName=''%s''';
  nStr := Format(nStr, [sTable_PTruckControl, sFlag_PTruckControl]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
      Exit;
    WriteLog('ԭ���Ͻ������������ܿ���:' + FieldByName('C_Valid').AsString);
    if FieldByName('C_Valid').AsString <> sFlag_Yes then
      Exit;
  end;

  nCount := 0;
  nCountSet := 0;

  nStr := 'Select * From %s Where C_CusID=''%s'' and C_StockNo=''%s'' and C_Valid=''%s''';
  nStr := Format(nStr, [sTable_PTruckControl, nPID, nStockNo, sFlag_Yes]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      WriteLog('��Ӧ��' + nPID + 'ԭ����'+ nStockNo + 'δ�����޶���������δ����');
      Exit;
    end;
    nCountSet := FieldByName('C_Count').AsInteger;
    WriteLog('ԭ���Ͻ���������������:' + FieldByName('C_Count').AsString);
  end;

  nBDate := FormatDateTime('YYYY-MM-DD', Now) + ' 00:00:00';
  nEDate := FormatDateTime('YYYY-MM-DD', Now) + ' 23:59:59';

  nStr := ' Select Count(*) as P_Count From %s a, '+
          ' P_Order b where a.D_OID = b.O_ID and O_ProID=''%s'' and O_StockNo=''%s'' '
         +' And (D_InTime>=''%s'' and D_InTime <=''%s'')';
  nStr := Format(nStr, [sTable_OrderDtl, nPID, nStockNo, nBDate, nEDate]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      Exit;
    end;
    nCount := FieldByName('P_Count').AsInteger;

    if (nCount > 0) and (nCount >= nCountSet) then
    begin
      nHint := '��Ӧ��' + nPID + 'ԭ����'+ nStockNo
               + '��ǰ�ѿ�������' + IntToStr(nCount)
               + '�����ս����趨����' + IntToStr(nCountSet) + '�޷�����';
      WriteLog(nHint);
      Result := False;
    end;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessOrders, sPlug_ModuleBus);
end.
