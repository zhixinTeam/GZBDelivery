{*******************************************************************************
  作者: dmzn@163.com 2014-10-20
  描述: 自动称重通道项
*******************************************************************************}
unit UFramePoundAutoItem;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMgrPoundTunnels, UBusinessConst, UFrameBase, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, StdCtrls,
  UTransEdit, ExtCtrls, cxRadioGroup, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLabel, ULEDFont;

type
  TfFrameAutoPoundItem = class(TBaseFrame)
    GroupBox1: TGroupBox;
    EditValue: TLEDFontNum;
    GroupBox3: TGroupBox;
    ImageGS: TImage;
    Label16: TLabel;
    Label17: TLabel;
    ImageBT: TImage;
    Label18: TLabel;
    ImageBQ: TImage;
    ImageOff: TImage;
    ImageOn: TImage;
    HintLabel: TcxLabel;
    EditTruck: TcxComboBox;
    EditMID: TcxComboBox;
    EditPID: TcxComboBox;
    EditMValue: TcxTextEdit;
    EditPValue: TcxTextEdit;
    EditJValue: TcxTextEdit;
    Timer1: TTimer;
    EditBill: TcxComboBox;
    EditZValue: TcxTextEdit;
    GroupBox2: TGroupBox;
    RadioPD: TcxRadioButton;
    RadioCC: TcxRadioButton;
    EditMemo: TcxTextEdit;
    EditWValue: TcxTextEdit;
    RadioLS: TcxRadioButton;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    cxLabel10: TcxLabel;
    Timer2: TTimer;
    Timer_ReadCard: TTimer;
    TimerDelay: TTimer;
    MemoLog: TZnTransMemo;
    Timer_SaveFail: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer_ReadCardTimer(Sender: TObject);
    procedure TimerDelayTimer(Sender: TObject);
    procedure Timer_SaveFailTimer(Sender: TObject);
  private
    { Private declarations }
    FCardUsed: string;
    //卡片类型
    FIsWeighting, FIsSaving: Boolean;
    //称重标识,保存标识
    FPoundTunnel: PPTTunnelItem;
    //磅站通道
    FLastGS,FLastBT,FLastBQ: Int64;
    //上次活动
    FBillItems: TLadingBillItems;
    FUIData,FInnerData: TLadingBillItem;
    //称重数据
    FLastCardDone: Int64;
    FLastCard, FCardTmp, FLastReader: string;
    //上次卡号, 临时卡号, 读卡器编号
    FListA: TStrings;
    FSampleIndex: Integer;
    FValueSamples: array of Double;
    //数据采样
    FVirPoundID: string;
    //虚拟地磅编号
    FBarrierGate: Boolean;
    //是否采用道闸
    FPoundMinNetWeight: Double;
    //净重最小值(除销售以外业务使用)
    FEmptyPoundInit, FDoneEmptyPoundInit: Int64;
    //空磅计时,过磅保存后空磅
    FEmptyPoundIdleLong, FEmptyPoundIdleShort: Int64;
    //空磅时间间隔
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //界面数据
    procedure SetImageStatus(const nImage: TImage; const nOff: Boolean);
    //设置状态
    procedure SetTunnel(const nTunnel: PPTTunnelItem);
    //关联通道
    procedure OnPoundDataEvent(const nValue: Double);
    procedure OnPoundData(const nValue: Double);
    //读取磅重
    procedure LoadBillItems(const nCard: string);
    //读取交货单
    function VerifySanValue(var nValue: Double): Boolean;
    //矫正散装净重
    procedure InitSamples;
    procedure AddSample(const nValue: Double);
    function IsValidSamaple: Boolean;
    //处理采样
    function SavePoundSale: Boolean;
    function SavePoundData: Boolean;
    //保存称重
    procedure WriteLog(nEvent: string);
    //记录日志
    procedure PlayVoice(const nStrtext: string);
    //播放语音
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //子类继承
    property PoundTunnel: PPTTunnelItem read FPoundTunnel write SetTunnel;
    //属性相关
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UFormBase, {$IFDEF HR1847}UKRTruckProber,{$ELSE}UMgrTruckProbe,{$ENDIF}
  UMgrRemoteVoice, UMgrVoiceNet, UDataModule, USysBusiness,UBusinessPacker,
  USysLoger, USysConst, USysDB, UFormInputbox;

const
  cFlag_ON    = 10;
  cFlag_OFF   = 20;

class function TfFrameAutoPoundItem.FrameID: integer;
begin
  Result := 0;
end;

procedure TfFrameAutoPoundItem.OnCreateFrame;
begin
  inherited;
  FPoundTunnel := nil;
  FIsWeighting := False;
  
  FEmptyPoundInit := 0;
  FListA := TStringList.Create;
end;

procedure TfFrameAutoPoundItem.OnDestroyFrame;
begin
  gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
  //关闭表头端口
  FListA.Free;
  inherited;
end;

//Desc: 设置运行状态图标
procedure TfFrameAutoPoundItem.SetImageStatus(const nImage: TImage;
  const nOff: Boolean);
begin
  if nOff then
  begin
    if nImage.Tag <> cFlag_OFF then
    begin
      nImage.Tag := cFlag_OFF;
      nImage.Picture.Bitmap := ImageOff.Picture.Bitmap;
    end;
  end else
  begin
    if nImage.Tag <> cFlag_ON then
    begin
      nImage.Tag := cFlag_ON;
      nImage.Picture.Bitmap := ImageOn.Picture.Bitmap;
    end;
  end;
end;

procedure TfFrameAutoPoundItem.WriteLog(nEvent: string);
var nInt: Integer;
begin
  with MemoLog do
  try
    Lines.BeginUpdate;
    if Lines.Count > 20 then
     for nInt:=1 to 10 do
      Lines.Delete(0);
    //清理多余

    Lines.Add(DateTime2Str(Now) + #9 + nEvent);
  finally
    Lines.EndUpdate;
    Perform(EM_SCROLLCARET,0,0);
    Application.ProcessMessages;
  end;
end;

procedure WriteSysLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameAutoPoundItem, '自动称重业务', nEvent);
end;

//------------------------------------------------------------------------------
//Desc: 更新运行状态
procedure TfFrameAutoPoundItem.Timer1Timer(Sender: TObject);
begin
  SetImageStatus(ImageGS, GetTickCount - FLastGS > 5 * 1000);
  SetImageStatus(ImageBT, GetTickCount - FLastBT > 5 * 1000);
  SetImageStatus(ImageBQ, GetTickCount - FLastBQ > 5 * 1000);
end;

//Desc: 关闭红绿灯
procedure TfFrameAutoPoundItem.Timer2Timer(Sender: TObject);
begin
  Timer2.Tag := Timer2.Tag + 1;
  if Timer2.Tag < 10 then Exit;

  Timer2.Tag := 0;
  Timer2.Enabled := False;

  {$IFNDEF MITTruckProber}
    {$IFDEF HR1847}
    gKRMgrProber.TunnelOC(FPoundTunnel.FID,False);
    {$ELSE}
    gProberManager.TunnelOC(FPoundTunnel.FID,False);
    {$ENDIF}
  {$ENDIF}
end;

//Desc: 设置通道
procedure TfFrameAutoPoundItem.SetTunnel(const nTunnel: PPTTunnelItem);
begin
  FPoundTunnel := nTunnel;
  FEmptyPoundIdleLong := -1;
  FEmptyPoundIdleShort:= -1;

  FPoundTunnel := nTunnel;
  SetUIData(True);

  if Assigned(FPoundTunnel.FOptions) then
  with FPoundTunnel.FOptions do
  begin
    FVirPoundID  := Values['VirPoundID'];
    FBarrierGate := Values['BarrierGate'] = sFlag_Yes;
    
    FEmptyPoundIdleLong   := StrToInt64Def(Values['EmptyIdleLong'], 60);
    FEmptyPoundIdleShort  := StrToInt64Def(Values['EmptyIdleShort'], 5);
    FPoundMinNetWeight    := StrToFloatDef(Values['MinNetWeight'], 0);
  end;
end;

//Desc: 重置界面数据
procedure TfFrameAutoPoundItem.SetUIData(const nReset,nOnlyData: Boolean);
var nStr: string;
    nInt: Integer;
    nVal: Double;
    nItem: TLadingBillItem;
begin
  if nReset then
  begin
    FillChar(nItem, SizeOf(nItem), #0);
    //init

    with nItem do
    begin
      FPModel := sFlag_PoundPD;
      FFactory := gSysParam.FFactNum;
    end;

    FUIData := nItem;
    FInnerData := nItem;
    if nOnlyData then Exit;

    SetLength(FBillItems, 0);
    EditValue.Text := '0.00';
    EditBill.Properties.Items.Clear;

    FIsSaving    := False;
    FEmptyPoundInit := 0;

    if not FIsWeighting then
    begin
      gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
      //关闭表头端口

      Timer_ReadCard.Enabled := True;
      //启动读卡
    end;
  end;

  with FUIData do
  begin
    EditBill.Text := FID;
    EditTruck.Text := FTruck;
    EditMID.Text := FStockName;
    EditPID.Text := FCusName;

    EditMValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);

    if (FValue > 0) and (FMData.FValue > 0) and (FPData.FValue > 0) then
    begin
      nVal := FMData.FValue - FPData.FValue;
      EditJValue.Text := Format('%.2f', [nVal]);
      EditWValue.Text := Format('%.2f', [FValue - nVal]);
    end else
    begin
      EditJValue.Text := '0.00';
      EditWValue.Text := '0.00';
    end;

    RadioPD.Checked := FPModel = sFlag_PoundPD;
    RadioCC.Checked := FPModel = sFlag_PoundCC;
    RadioLS.Checked := FPModel = sFlag_PoundLS;

    RadioLS.Enabled := (FPoundID = '') and (FID = '');
    //已称过重量或销售,禁用临时模式
    RadioCC.Enabled := FID <> '';
    //只有销售有出厂模式

    EditBill.Properties.ReadOnly := (FID = '') and (FTruck <> '');
    EditTruck.Properties.ReadOnly := FTruck <> '';
    EditMID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    EditPID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    //可输入项调整

    EditMemo.Properties.ReadOnly := True;
    EditMValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditPValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditJValue.Properties.ReadOnly := True;
    EditZValue.Properties.ReadOnly := True;
    EditWValue.Properties.ReadOnly := True;
    //可输入量调整

    if FTruck = '' then
    begin
      EditMemo.Text := '';
      Exit;
    end;
  end;

  nInt := Length(FBillItems);
  if nInt > 0 then
  begin
    if nInt > 1 then
         nStr := '销售并单'
    else nStr := '销售';

    if FCardUsed = sFlag_Provide then nStr := '供应';
    if FCardUsed = sFlag_DuanDao then nStr := '临时';

    if FUIData.FNextStatus = sFlag_TruckBFP then
    begin
      RadioCC.Enabled := False;
      EditMemo.Text := nStr + '称皮重';
    end else
    begin
      RadioCC.Enabled := True;
      EditMemo.Text := nStr + '称毛重';
    end;
  end;
end;

//Date: 2014-09-19
//Parm: 磁卡或交货单号
//Desc: 读取nCard对应的交货单
procedure TfFrameAutoPoundItem.LoadBillItems(const nCard: string);
var nRet: Boolean;
    nIdx,nInt: Integer;
    nBills: TLadingBillItems;
    nStr,nHint,nVoice, nLabel: string;
begin
  nStr := Format('读取到卡号[ %s ],开始执行业务.', [nCard]);
  WriteLog(nStr);

  FCardUsed := GetCardUsed(nCard);
  if FCardUsed = sFlag_Provide then
     nRet := GetPurchaseOrders(nCard, sFlag_TruckBFP, nBills) else
  if FCardUsed=sFlag_DuanDao then
     nRet := GetDuanDaoItems(nCard, sFlag_TruckBFP, nBills) else
  if FCardUsed=sFlag_Sale then
     nRet := GetLadingBills(nCard, sFlag_TruckBFP, nBills) else nRet := False;

  if (not nRet) or (Length(nBills) < 1)
  then
  begin
    nVoice := '读取磁卡信息失败,请联系管理员';
    PlayVoice(nVoice);
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;
  
  nHint := '';
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if (FStatus <> sFlag_TruckBFP) and (FNextStatus = sFlag_TruckZT) then
      FNextStatus := sFlag_TruckBFP;
    //状态校正

    FSelected := (FNextStatus = sFlag_TruckBFP) or
                 (FNextStatus = sFlag_TruckBFM);
    //可称重状态判定

    if FSelected then
    begin
      Inc(nInt);
      Continue;
    end;

    nStr := '※.单号:[ %s ] 状态:[ %-6s -> %-6s ]   ';
    if nIdx < High(nBills) then nStr := nStr + #13#10;

    nStr := Format(nStr, [FID,
            TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
    nHint := nHint + nStr;

    nVoice := '车辆 %s 不能过磅,应该去 %s ';
    nVoice := Format(nVoice, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt = 0 then
  begin
    PlayVoice(nVoice);
    //车辆状态异常

    nHint := '该车辆当前不能过磅,详情如下: ' + #13#10#13#10 + nHint;
    WriteSysLog(nStr);
    SetUIData(True);
    Exit;
  end;

  EditBill.Properties.Items.Clear;
  SetLength(FBillItems, nInt);
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if FSelected then
    begin
      FPoundID := '';
      //该标记有特殊用途
      
      if nInt = 0 then
           FInnerData := nBills[nIdx]
      else FInnerData.FValue := FInnerData.FValue + FValue;
      //累计量

      EditBill.Properties.Items.Add(FID);
      FBillItems[nInt] := nBills[nIdx];
      Inc(nInt);
    end;
  end;

  FInnerData.FPModel := sFlag_PoundPD;
  FUIData := FInnerData;
  SetUIData(False);

  nInt := GetTruckLastTime(FUIData.FTruck);
  if (nInt > 0) and (nInt < FPoundTunnel.FCardInterval) then
  begin
    nStr := '磅站[ %s.%s ]: 车辆[ %s ]需等待 %d 秒后才能过磅';
    nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
            FUIData.FTruck, FPoundTunnel.FCardInterval - nInt]);
    WriteSysLog(nStr);
    SetUIData(True);
    Exit;
  end;
  //指定时间内车辆禁止过磅

  if FVirPoundID <> '' then
  begin
    nLabel := GetTruckRealLabel(FUIData.FTruck);
    if nLabel <> '' then
    begin
      nHint := ReadPoundCard(nStr, FVirPoundID);
      if (nHint = '') or (Pos(nLabel, nHint) < 1) then
      begin
        nStr := '未识别电子签,请移动车辆.';
        PlayVoice(nStr);

        nStr := '磅站[ %s.%s ]: 车辆[ %s.%s ]电子标签不匹配[ %s ],禁止上磅';
        nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
                FUIData.FTruck, nLabel, nHint]);
        WriteSysLog(nStr);
        SetUIData(True);
        Exit;
      end;  
    end;
  end;
  //判断车辆是否就位

  InitSamples;
  //初始化样本

  if not FPoundTunnel.FUserInput then
  if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
         OnPoundDataEvent, True) then
  begin
    nHint := '连接地磅表头失败，请联系管理员检查硬件连接';
    WriteSysLog(nHint);

    nVoice := nHint;
    PlayVoice(nVoice);
    
    SetUIData(True);
    Exit;
  end;

  Timer_ReadCard.Enabled := False;
  FDoneEmptyPoundInit := 0;
  FIsWeighting := True;
  //停止读卡,开始称重

  if FBarrierGate then
  begin
    nStr := '[n1]%s刷卡成功请上磅,并熄火停车';
    nStr := Format(nStr, [FUIData.FTruck]);
    PlayVoice(nStr);
    //读卡成功，语音提示

    {$IFNDEF DEBUG}
    OpenDoorByReader(FLastReader);
    //打开主道闸
    {$ENDIF}
  end;  
  //车辆上磅
end;

//------------------------------------------------------------------------------
//Desc: 由定时读取交货单
procedure TfFrameAutoPoundItem.Timer_ReadCardTimer(Sender: TObject);
var nStr,nCard: string;
    nLast, nDoneTmp: Int64;
begin
  if gSysParam.FIsManual then Exit;
  Timer_ReadCard.Tag := Timer_ReadCard.Tag + 1;
  if Timer_ReadCard.Tag < 5 then Exit;

  Timer_ReadCard.Tag := 0;
  if FIsWeighting then Exit;

  try
    WriteLog('正在读取磁卡号.');
    {$IFNDEF DEBUG}
    nCard := Trim(ReadPoundCard(FLastReader, FPoundTunnel.FID));
    {$ENDIF}
    if nCard = '' then Exit;

    if nCard <> FLastCard then
         nDoneTmp := 0
    else nDoneTmp := FLastCardDone;
    //新卡时重置

    {$IFDEF DEBUG}
    nStr := '磅站[ %s.%s ]: 读取到新卡号::: %s =>旧卡号::: %s';
    nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
            nCard, FLastCard]);
    WriteSysLog(nStr);
    {$ENDIF}

    nLast := Trunc((GetTickCount - nDoneTmp) / 1000);
    if (nDoneTmp <> 0) and (nLast < FPoundTunnel.FCardInterval)  then
    begin
      nStr := '磅站[ %s.%s ]: 磁卡[ %s ]需等待 %d 秒后才能过磅';
      nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
              nCard, FPoundTunnel.FCardInterval - nLast]);
      WriteSysLog(nStr);
      Exit;
    end;

    FCardTmp := nCard;
    EditBill.Text := nCard;
    LoadBillItems(EditBill.Text);
  except
    on E: Exception do
    begin
      nStr := Format('磅站[ %s.%s ]: ',[FPoundTunnel.FID,
              FPoundTunnel.FName]) + E.Message;
      WriteSysLog(nStr);

      SetUIData(True);
      //错误则重置
    end;
  end;
end;

//Date: 2015-09-22
//Parm: 净重[in];超发量[out]
//Desc: 计算净重比订单超发了多少,没超发为0.
function TfFrameAutoPoundItem.VerifySanValue(var nValue: Double): Boolean;
var nStr, nHint: string;
    f,m: Double;
begin
  Result := False;
  nStr := FInnerData.FProject;

  if not (YT_ReadCardInfo(nStr) and
     YT_VerifyCardInfo(nStr, sFlag_AllowZeroNum)) then
  begin
    PlayVoice('读取订单失败,请联系管理员处理');
    WriteSysLog(nStr);
    Exit;
  end;

  FListA.Text := PackerDecodeStr(nStr);
  //读取订单
  m := StrToFloat(FListA.Values['XCB_RemainNum']);
  //订单剩余量

  f := nValue - FInnerData.FValue;
  //开单量和净重差额

  nStr := '提货单号[%s]详情如下:' + #13#10 +
          '※.提货净重: %.2f吨' + #13#10 +
          '※.开 票 量: %.2f吨' + #13#10 +
          '※.订单剩余: %.2f吨' + #13#10 +
          '※.超发数量: %.2f吨' + #13#10 +
          '请核对信息';
  nStr := Format(nStr, [FInnerData.FID, nValue, FInnerData.FValue, m, f]);
  WriteSysLog(nStr);

  m := f - m;
  //可用量是否够用

  if m > 0 then
  begin
    {$IFDEF GZBJM}
    nStr := '散装订单超发%.2f吨,请联系开票员处理';
    nStr := Format(nStr, [m]);
    PlayVoice(nStr);
    {$ENDIF}

    nHint := '客户[ %s.%s ]订单上没有足够的量,详情如下:' + #13#10#13#10 +
             '※.订单编号: %s' + #13#10 +
             '※.提货净重: %.2f吨' + #13#10 +
             '※.需 补 交: %.2f吨' + #13#10+#13#10 +
             '请到开票室办理补单手续,然后再次称重.';
    //xxxxx

    nHint := Format(nHint, [FInnerData.FCusID, FInnerData.FCusName,
            FInnerData.FProject, nValue, m]);
    //xxxxx

    {$IFDEF GZBJM}
    WriteSysLog(nHint);
    nHint := nHint + '若有可用提货单,请点击"是"按钮继续.';
    if not QueryDlg(nHint, sHint) then Exit;

    nStr := '';
    while true do
    begin
      if not ShowInputBox('请输入新的提货单号:', '并单业务', nStr) then Exit;
      nStr := Trim(nStr);

      if (nStr = '') or  (CompareText(nStr, FInnerData.FProject) = 0) then
      begin
        ShowMsg('请输入有效单据', sHint);
        Continue;
      end;

      FUIData.FMemo := nStr;
      FUIData.FKZValue := m;

      nValue := m;
      Result := True; Break;
    end;
    {$ELSE}
    if not VerifyManualEventRecord(FInnerData.FID + sFlag_ManualD, nHint, 'I') then
    begin //开票员忽略后，认为司机卸货后再次过磅。
      nStr := 'MStation=%s;m=%.2f;Pound_PValue=%.2f;Pound_MValue=%.2f;Pound_Card=%s';
      nStr := Format(nStr, [FPoundTunnel.FID,m,
              FUIData.FPData.FValue, FUIData.FMData.FValue,FUIData.FCard]);

      AddManualEventRecord(FInnerData.FID + sFlag_ManualD, FInnerData.FTruck, nHint,
        sFlag_DepBangFang, sFlag_Solution_YNI, sFlag_DepDaTing, True, nStr);

      nStr := '散装订单超发%.2f吨,请联系开票员处理';
      nStr := Format(nStr, [m]);
      PlayVoice(nStr);
      Exit;
    end;

    FUIData.FMemo := nStr;
    FUIData.FKZValue := m;

    nValue := m;
    Result := True;
    {$ENDIF}
  end else
  begin
    nValue := 0;
    Result := True;
  end;
end;

//Desc: 保存销售
function TfFrameAutoPoundItem.SavePoundSale: Boolean;
var nHint: string;
    nVal,nNet, nWarn: Double;
begin
  Result := False;
  //init

  with FUIData do
  if FNextStatus = sFlag_TruckBFP then
  begin
    if not VerifyPoundWarning(nHint, nWarn) then
    begin
      if not VerifyManualEventRecord(FID + sFlag_ManualA, nHint) then
      begin
        AddManualEventRecord(FID + sFlag_ManualA, FTruck, nHint);

        WriteSysLog(nHint);
        PlayVoice(nHint);
        Exit;
      end;
    end;
    //设置皮重预警范围

    nNet := GetTruckEmptyValue(FTruck);
    nVal := nNet * 1000 - FPData.FValue * 1000;

    if (nNet > 0) and (nWarn > 0) and (Abs(nVal) > nWarn) then
    begin
      nHint := '车辆[ %s ]实时皮重误差较大,详情如下:' + #13#10 +
              '※.实时皮重: %.2f吨' + #13#10 +
              '※.历史皮重: %.2f吨' + #13#10 +
              '※.误差量: %.2f公斤' + #13#10 +
              '是否继续保存?';
      nHint := Format(nHint, [FTruck, FPData.FValue,
              nNet, nVal]);

      if not VerifyManualEventRecord(FID + sFlag_ManualB, nHint) then
      begin
        AddManualEventRecord(FID + sFlag_ManualB, FTruck, nHint);
        WriteSysLog(nHint);

        nHint := '[n1]%s皮重超出预警,请等待管理员处理';
        nHint := Format(nHint, [FTruck]);
        PlayVoice(nHint);
        Exit;
      end;
      //判断皮重是否超差
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) and
     (FUIData.FYSValid <> sFlag_Yes) then //非空车出厂
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      PlayVoice('皮重应小于毛重,请联系管理员处理');
      Exit;
    end;

    nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;
    //净重
    nVal := nNet * 1000 - FInnerData.FValue * 1000;
    //与开票量误差(公斤)

    with gSysParam,FBillItems[0] do
    begin
      {$IFDEF DaiStepWuCha}
      if (FType = sFlag_Dai) then
        GetPoundAutoWuCha(FPoundDaiZ, FPoundDaiF, FInnerData.FValue);
      //xxxxx
      {$ELSE}
      if FDaiPercent and (FType = sFlag_Dai) then
      begin
        if nVal > 0 then
             FPoundDaiZ := Float2Float(FInnerData.FValue * FPoundDaiZ_1 * 1000,
                                       cPrecision, False)
        else FPoundDaiF := Float2Float(FInnerData.FValue * FPoundDaiF_1 * 1000,
                                       cPrecision, False);
      end;
      {$ENDIF}

      if ((FType = sFlag_Dai) and (
          ((nVal > 0) and (FPoundDaiZ > 0) and (nVal > FPoundDaiZ)) or
          ((nVal < 0) and (FPoundDaiF > 0) and (-nVal > FPoundDaiF))))then
      begin
        {$IFDEF GZBJM}
        nHint := '车辆[n1]%s净重与开票量误差较大,请联系管理员处理';
        nHint := Format(nHint, [FTruck]);
        PlayVoice(nHint);
        {$ENDIF}

        nHint := '车辆[ %s ]实际装车量误差较大,详情如下:' + #13#10 +
                '※.开单量: %.2f吨' + #13#10 +
                '※.装车量: %.2f吨' + #13#10 +
                '※.误差量: %.2f公斤' + #13#10 +
                '请确认是否可以过磅';
        nHint := Format(nHint, [FTruck, FInnerData.FValue, nNet, nVal]);

        {$IFDEF GZBJM}
        WriteSysLog(nHint);
        if not QueryDlg(nHint, sHint) then Exit;
        {$ELSE}
        if not VerifyManualEventRecord(FID + sFlag_ManualC, nHint) then
        begin
          AddManualEventRecord(FID + sFlag_ManualC, FTruck, nHint,
            sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepJianZhuang);
          WriteSysLog(nHint);

          nHint := '车辆[n1]%s净重[n2]%.2f吨,开票量[n2]%.2f吨,'+
                   '误差量[n2]%.2f公斤,请去包装点包';
          nHint := Format(nHint, [FTruck,nNet,FInnerData.FValue,nVal]);
          PlayVoice(nHint);
          Exit;
        end;
        {$ENDIF}
      end;

      FUIData.FMemo := '';
      FUIData.FKZValue := 0;
      //初始化补单数据

      if (nVal > 0) and (FType = sFlag_San) and (not VerifySanValue(nNet)) then
        Exit;
      //散装净重超过开单量时,验证是否发超
    end;
  end;

  with FBillItems[0] do
  begin
    FPModel := FUIData.FPModel;
    FFactory := gSysParam.FFactNum;

    with FPData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := FUIData.FPData.FValue;
      FOperator := gSysParam.FUserID;
    end;

    with FMData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := FUIData.FMData.FValue;
      FOperator := gSysParam.FUserID;
    end;

    FMemo := FUIData.FMemo;
    FKZValue := FUIData.FKZValue;
    //散装并单信息

    FPoundID := sFlag_Yes;
    //标记该项有称重数据
    Result := SaveLadingBills(FNextStatus, FBillItems, FPoundTunnel);
    //保存称重
  end;

  if not Result then
    PlayVoice('过磅保存失败，请联系管理员处理');
end;

//------------------------------------------------------------------------------
//Desc: 原材料或临时
function TfFrameAutoPoundItem.SavePoundData: Boolean;
var nStr: string;
    nVal: Double;
begin
  Result := False;
  //init

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      WriteLog('皮重应小于毛重');
      Exit;
    end;

    if FPoundMinNetWeight > 0 then
    begin
      nVal := FUIData.FMData.FValue - FUIData.FPData.FValue;
      //净重

      if nVal < FPoundMinNetWeight then
      begin
        nStr := '净重[%.2f<%.2f(下限)]不满足业务.';
        nStr := Format(nStr, [nVal, FPoundMinNetWeight]);
        WriteLog(nStr);

        nStr := '车辆[ %s ]净重[%.2f<%.2f(下限)]无效,不保存本次称重.';
        nStr := Format(nStr, [FUIData.FTruck, nVal, FPoundMinNetWeight]);
        WriteSysLog(nStr);

        nStr := '车辆[ %s ]本次称重无效,请下磅.';
        nStr := Format(nStr, [FUIData.FTruck]);
        PlayVoice(nStr);
        Exit;
      end;
    end;
  end;

  nStr := FBillItems[0].FNextStatus;
  //暂存下一状态

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //复制用户界面数据
  
  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx
    
    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;
  end;

  if FCardUsed = sFlag_Provide then
       Result := SavePurchaseOrders(nStr, FBillItems,FPoundTunnel)
  else Result := SaveDuanDaoItems(nStr, FBillItems, FPoundTunnel);
  //保存称重

  if not Result then
    PlayVoice('过磅保存失败，请联系管理员处理');
end;

//Desc: 读取表头数据
procedure TfFrameAutoPoundItem.OnPoundDataEvent(const nValue: Double);
begin
  try
    if FIsSaving then Exit;
    //正在保存。。。

    OnPoundData(nValue);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('磅站[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      SetUIData(True);
    end;
  end;
end;

//Desc: 处理表头数据
procedure TfFrameAutoPoundItem.OnPoundData(const nValue: Double);
var nRet: Boolean;
    nInt: Int64;
begin
  FLastBT := GetTickCount;
  EditValue.Text := Format('%.2f', [nValue]);

  if not FIsWeighting then Exit;
  //不在称重中
  if gSysParam.FIsManual then Exit;
  //手动时无效

  if nValue < FPoundTunnel.FPort.FMinValue then //空磅
  begin
    if FEmptyPoundInit = 0 then
      FEmptyPoundInit := GetTickCount;
    nInt := GetTickCount - FEmptyPoundInit;

    if (nInt > FEmptyPoundIdleLong * 1000) then
    begin
      FIsWeighting :=False;
      Timer_SaveFail.Enabled := True;

      WriteSysLog('刷卡后司机无响应,退出称重.');
      Exit;
    end;
    //上磅时间,延迟重置

    if (nInt > FEmptyPoundIdleShort * 1000) and   //保证空磅
       (FDoneEmptyPoundInit>0) and (GetTickCount-FDoneEmptyPoundInit>nInt) then
    begin
      FIsWeighting :=False;
      Timer_SaveFail.Enabled := True;

      WriteSysLog('司机已下磅,退出称重.');
      Exit;
    end;
    //上次保存成功后,空磅超时,认为车辆下磅

    Exit;
  end else
  begin
    FEmptyPoundInit := 0;
    if FDoneEmptyPoundInit > 0 then
      FDoneEmptyPoundInit := GetTickCount;
    //车辆称重完毕后，未下磅
  end;

  AddSample(nValue);
  if not IsValidSamaple then Exit;
  //样本验证不通过

  if Length(FBillItems) < 1 then Exit;
  //无称重数据

  if (FCardUsed = sFlag_Provide) or (FCardUsed = sFlag_DuanDao) then
  begin
    if FInnerData.FPData.FValue > 0 then
    begin
      if nValue <= FInnerData.FPData.FValue then
      begin
        FUIData.FPData := FInnerData.FMData;
        FUIData.FMData := FInnerData.FPData;

        FUIData.FPData.FValue := nValue;
        FUIData.FNextStatus := sFlag_TruckBFP;
        //切换为称皮重
      end else
      begin
        FUIData.FPData := FInnerData.FPData;
        FUIData.FMData := FInnerData.FMData;

        FUIData.FMData.FValue := nValue;
        FUIData.FNextStatus := sFlag_TruckBFM;
        //切换为称毛重
      end;
    end else FUIData.FPData.FValue := nValue;
  end else
  if FBillItems[0].FNextStatus = sFlag_TruckBFP then
       FUIData.FPData.FValue := nValue
  else FUIData.FMData.FValue := nValue;

  SetUIData(False);
  //更新界面

  {$IFDEF MITTruckProber}
    if not IsTunnelOK(FPoundTunnel.FID) then
  {$ELSE}
    {$IFDEF HR1847}
    if not gKRMgrProber.IsTunnelOK(FPoundTunnel.FID) then
    {$ELSE}
    if not gProberManager.IsTunnelOK(FPoundTunnel.FID) then
    {$ENDIF}
  {$ENDIF}
  begin
    PlayVoice('车辆未停到位,请移动车辆.');
    InitSamples;
    Exit;
  end;

  FIsSaving := True;
  if FCardUsed = sFlag_Sale then
       nRet := SavePoundSale
  else nRet := SavePoundData;

  if nRet then
       TimerDelay.Enabled := True
  else Timer_SaveFail.Enabled := True;

  if FBarrierGate then
  begin
    {$IFDEF ERROPENONEDOOR}
    if not nRet then
    begin
      OpenDoorByReader(FLastReader, sFlag_Yes);
      Exit;
    end;  
    {$ENDIF}
    OpenDoorByReader(FLastReader, sFlag_No);
    //打开副道闸
  end;
end;

procedure TfFrameAutoPoundItem.TimerDelayTimer(Sender: TObject);
begin
  try
    TimerDelay.Enabled := False;
    WriteSysLog(Format('对车辆[ %s ]称重完毕.', [FUIData.FTruck]));
    PlayVoice(#9 + FUIData.FTruck);
    //播放语音

    FLastCard     := FCardTmp;
    FLastCardDone := GetTickCount;
    FDoneEmptyPoundInit := GetTickCount;
    //保存状态

    if not FBarrierGate then
      FIsWeighting := False;
    //磅上无道闸时，即时过磅完毕

    {$IFDEF MITTruckProber}
        TunnelOC(FPoundTunnel.FID, True);
    {$ELSE}
      {$IFDEF HR1847}
      gKRMgrProber.TunnelOC(FPoundTunnel.FID, True);
      {$ELSE}
      gProberManager.TunnelOC(FPoundTunnel.FID, True);
      {$ENDIF}
    {$ENDIF} //开红绿灯
      
    Timer2.Enabled := True;
    SetUIData(True);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('磅站[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 初始化样本
procedure TfFrameAutoPoundItem.InitSamples;
var nIdx: Integer;
begin
  SetLength(FValueSamples, FPoundTunnel.FSampleNum);
  FSampleIndex := Low(FValueSamples);

  for nIdx:=High(FValueSamples) downto FSampleIndex do
    FValueSamples[nIdx] := 0;
  //xxxxx
end;

//Desc: 添加采样
procedure TfFrameAutoPoundItem.AddSample(const nValue: Double);
begin
  FValueSamples[FSampleIndex] := nValue;
  Inc(FSampleIndex);

  if FSampleIndex >= FPoundTunnel.FSampleNum then
    FSampleIndex := Low(FValueSamples);
  //循环索引
end;

//Desc: 验证采样是否稳定
function TfFrameAutoPoundItem.IsValidSamaple: Boolean;
var nIdx: Integer;
    nVal: Integer;
begin
  Result := False;

  for nIdx:=FPoundTunnel.FSampleNum-1 downto 1 do
  begin
    if FValueSamples[nIdx] < FPoundTunnel.FPort.FMinValue then Exit;
    //样本不完整

    nVal := Trunc(FValueSamples[nIdx] * 1000 - FValueSamples[nIdx-1] * 1000);
    if Abs(nVal) >= FPoundTunnel.FSampleFloat then Exit;
    //浮动值过大
  end;

  Result := True;
end;

procedure TfFrameAutoPoundItem.PlayVoice(const nStrtext: string);
begin
  {$IFNDEF DEBUG}
  if (Assigned(FPoundTunnel.FOptions)) and
     (CompareText('NET', FPoundTunnel.FOptions.Values['Voice']) = 0) then
       gNetVoiceHelper.PlayVoice(nStrtext, FPoundTunnel.FID, 'pound')
  else gVoiceHelper.PlayVoice(nStrtext);
  {$ENDIF}
end;

procedure TfFrameAutoPoundItem.Timer_SaveFailTimer(Sender: TObject);
begin
  inherited;
  try
    FDoneEmptyPoundInit := GetTickCount;
    Timer_SaveFail.Enabled := False;
    SetUIData(True);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('磅站[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

end.
