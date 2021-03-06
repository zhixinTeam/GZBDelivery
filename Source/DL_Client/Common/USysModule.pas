{*******************************************************************************
  ����: dmzn@163.com 2009-6-25
  ����: ��Ԫģ��

  ��ע: ����ģ������ע������,ֻҪUsesһ�¼���.
*******************************************************************************}
unit USysModule;

{$I Link.Inc}
interface

uses
  UClientWorker, UMITPacker,
  UFrameLog, UFrameSysLog, UFormIncInfo, UFormBackupSQL, UFormRestoreSQL,
  UFormPassword, UFormBaseInfo, UFrameAuthorize, UFormAuthorize,
  {$IFNDEF GZBJM}
  {UFrameSalesMan, UFormSalesMan,
  UFrameSaleContract, UFormSaleContract, UFrameZhiKa, UFormZhiKa,
  UFormGetContract, UFormZhiKaAdjust, UFormZhiKaFixMoney, UFrameZhiKaVerify,
  UFormZhiKaVerify, UFrameShouJu, UFormShouJu, UFramePayment, UFormPayment,
  UFrameCustomerCredit, UFormCustomerCredit, UFrameCusAccount,
  UFrameCusInOutMoney, UFrameInvoiceWeek, UFormInvoiceWeek, UFormInvoiceGetWeek,
  UFrameInvoice, UFormInvoice, UFormInvoiceAdjust,UFrameInvoiceK, UFormInvoiceK,
  UFrameInvoiceDtl, UFrameInvoiceZZ, UFormInvoiceZZAll, UFormInvoiceZZCus,
  UFormGetZhiKa, UFrameZhiKaDetail, UFormZhiKaFreeze,
  UFormZhiKaPrice,}
  {$ENDIF}
  UFrameBill, UFormBill, UFormGetTruck, UFrameQueryDiapatch, UFrameTruckQuery,
  UFrameBillCard, UFormCard, UFormTruckIn, UFormTruckOut, UFormLadingDai,
  UFormLadingSan, UFramePoundManual, UFramePoundAuto, UFramePMaterails,
  UFramePSaleInfo, UFramePUserYSInfo, UFrameRFIDMater,UFormOrderDtl,
  UFormPMaterails, UFramePProvider, UFormPProvider, UFramePoundQuery,
  UFrameQuerySaleDetail, UFrameQuerySaletunnel, UFrameZTDispatch, UFrameTrucks, UFormTruck,
  UFormRFIDCard, UFormBillNew,UFrameCustomer, UFormCustomer, UFormGetCustom,
  UFormTruckEmpty, UFormReadCard, UFormTransfer, UFrameTransfer,
  UFrameQueryTransferDetail, UFormGetYTBatch,UFrameSalePlan,UFromSalePlan,UFormSalePlanDtl,

  UFramePurchaseOrder, UFormPurchaseOrder, UFormPurchasing, UFormPro_Order,
  UFrameQueryOrderDetail, UFrameOrderCard,  UFrameOrderDetail,UFramePro_Order,
  UFormGetProvider, UFormGetMeterails, UFramePOrderBase, UFormPOrderBase,
  UFormGetPOrderBase, UFrameMaterailTunnels, UFormMaterailTunnel, UFormPUserYSWh,
  UFrameImportOrderDetail, UFormTodo, UFormTodoSend, UFrameManualEvent,
  UFramePoundDaiWC, UFrameCusBatMap,
  {$IFDEF MicroMsg}
  UFrameWeiXinAccount, UFormWeiXinAccount, UFrameWeiXinSendlog,
  UFormWeiXinSendlog,
  {$ENDIF}
  {$IFDEF GlLade}
  UFrameSalesMan, UFormSalesMan,
  UFrameSaleContract, UFormSaleContract, UFrameZhiKa, UFormZhiKa,
  UFormGetContract, UFormZhiKaAdjust, UFormZhiKaFixMoney, UFrameZhiKaVerify,
  UFormZhiKaVerify, UFrameShouJu, UFormShouJu, UFramePayment, UFormPayment,
  UFrameCustomerCredit, UFormCustomerCredit, UFrameCusAccount,
  UFrameCusInOutMoney, UFrameInvoiceWeek, UFormInvoiceWeek, UFormInvoiceGetWeek,
  UFrameInvoice, UFormInvoice, UFormInvoiceAdjust,UFrameInvoiceK, UFormInvoiceK,
  UFrameInvoiceDtl, UFrameInvoiceZZ, UFormInvoiceZZAll, UFormInvoiceZZCus,
  UFormGetZhiKa, UFrameZhiKaDetail, UFormZhiKaFreeze,
  UFormZhiKaPrice, UFormBillSingle,
  {$ENDIF}
  //----------------------------------------------------------------------------
  UFramePurchaseContract,UFormPurchaseContract,UFormGetPurchaseContract,
  UFormPurchaseAssayRes, UFormCardSearch,UFormOrderKW,UFrameHYMBWH,UFormHYMBWH,
  UFormPTruckControl, UFramePTruckControl,
  UFormHYStock, UFormHYData, UFormHYRecord, UFormGetStockNo,
  UFrameHYStock, UFrameHYData, UFrameHYRecord;

procedure InitSystemObject;
procedure RunSystemObject;
procedure FreeSystemObject;

implementation

uses
  ULibFun, UMgrChannel, UChannelChooser, UDataModule, USysDB, USysMAC, SysUtils,
  USysLoger, USysConst,UMemDataPool, UFormBase, UMgrLEDDisp;

//Desc: ��ʼ��ϵͳ����
procedure InitSystemObject;
begin
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create(gPath + sLogDir);
  //system loger

  if not Assigned(gMemDataManager) then
    gMemDataManager := TMemDataManager.Create;
  //Memory Manager

  gChannelManager := TChannelManager.Create;
  gChannelManager.ChannelMax := 20;
  gChannelChoolser := TChannelChoolser.Create('');
  gChannelChoolser.AutoUpdateLocal := False;
  //channel
end;

//Desc: ����ϵͳ����
procedure RunSystemObject;
var nStr: string;
    nInt: Integer;
begin
  with gSysParam do
  begin
    FLocalMAC   := MakeActionID_MAC;
    GetLocalIPConfig(FLocalName, FLocalIP);
  end;

  nStr := 'Select W_Factory,W_Serial,W_Departmen,W_HardUrl,W_MITUrl From %s ' +
          'Where W_MAC=''%s'' And W_Valid=''%s''';
  nStr := Format(nStr, [sTable_WorkePC, gSysParam.FLocalMAC, sFlag_Yes]);

  with FDM.QueryTemp(nStr),gSysParam do
  if RecordCount > 0 then
  begin
    FFactNum := Fields[0].AsString;
    FSerialID := Fields[1].AsString;

    FDepartment := Fields[2].AsString;
    FHardMonURL := Trim(Fields[3].AsString);
    FMITServURL := Trim(Fields[4].AsString);
  end;

  //----------------------------------------------------------------------------
  with gSysParam do
  begin
    FPoundDaiZ := 0;
    FPoundDaiF := 0;
    FPoundSanF := 0;

    FPoundMMax := False;
    FDaiWCStop := False;
    FDaiPercent:= False;
    FPoundJMax := False;
  end;

  nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := Fields[1].AsString;
      if nStr = sFlag_PoundMMax then
        gSysParam.FPoundMMax := Fields[0].AsString = sFlag_Yes;
      //xxxxx
      if nStr = sFlag_PoundJMax then
        gSysParam.FPoundJMax := Fields[0].AsString = sFlag_Yes;

      if nStr = sFlag_PoundMultiM then
      with USysConst.gSysParam do
      begin
        nInt := Length(FPoundMultiM);
        SetLength(FPoundMultiM, nInt+1);
        FPoundMultiM[nInt] := Fields[0].AsString;
      end; //�����ι��س�Ʒ��
            
      Next;
    end;
  end;

  nStr := 'select d_value from %s where d_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict,sFlag_WXServiceMIT]);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    gSysParam.FWechatURL := Fields[0].AsString;
  end;

  nStr := 'select d_value from %s where d_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict,sFlag_HHJYServiceMIT]);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    gSysParam.FHHJYURL := Fields[0].AsString;
  end;

  nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundWuCha]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := Fields[1].AsString;
      if nStr = sFlag_PDaiWuChaZ then
        gSysParam.FPoundDaiZ := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PDaiWuChaF then
        gSysParam.FPoundDaiF := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PDaiPercent then
        gSysParam.FDaiPercent := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if nStr = sFlag_PDaiWuChaStop then
        gSysParam.FDaiWCStop := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if nStr = sFlag_PSanWuChaF then
        gSysParam.FPoundSanF := Fields[0].AsFloat;

      if nStr = sFlag_PEmpTWuCha then
        gSysParam.FEmpTruckWc := Fields[0].AsFloat;
      Next;
    end;

    with gSysParam do
    begin
      FPoundDaiZ_1 := FPoundDaiZ;
      FPoundDaiF_1 := FPoundDaiF;
      //backup wucha value
    end;
  end;

  //----------------------------------------------------------------------------
  if gSysParam.FMITServURL = '' then  //ʹ��Ĭ��URL
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_MITSrvURL]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        gChannelChoolser.AddChannelURL(Fields[0].AsString);
        Next;
      end;

      {$IFNDEF DEBUG}
      //gChannelChoolser.StartRefresh;
      {$ENDIF}//update channel
    end;
  end else
  begin
    gChannelChoolser.AddChannelURL(gSysParam.FMITServURL);
    //����ר��URL
  end;

  if gSysParam.FHardMonURL = '' then //����ϵͳĬ��Ӳ���ػ�
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_HardSrvURL]);

    with FDM.QueryTemp(nStr) do
     if RecordCount > 0 then
      gSysParam.FHardMonURL := Fields[0].AsString;
    //xxxxx
  end;

  //----------------------------------------------------------------------------
  gSysParam.FFactory := '';
  nStr := 'Select D_Value From %s where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_FactoryID]);

  with FDM.QueryTemp(nStr) do
   if RecordCount > 0 then
    gSysParam.FFactory := Trim(Fields[0].AsString);
  //xxxxx

//  if gSysParam.FFactory = '' then
//    ShowMsg('�����ù���ID', sHint);
  //xxxxx
           
  CreateBaseFormItem(cFI_FormTodo);
  //����������

  {$IFDEF BFLED}
  if FileExists(gPath + cDisp_Config) then
  begin
    gDisplayManager.LoadConfig(gPath + cDisp_Config);
    gDisplayManager.StartDisplay;
  end;
  {$ENDIF}
end;

//Desc: �ͷ�ϵͳ����
procedure FreeSystemObject;
begin
  FreeAndNil(gSysLoger);
end;

end.
