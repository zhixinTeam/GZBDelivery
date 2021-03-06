{*******************************************************************************
  ����: dmzn@163.com 2013-11-23
  ����: ģ�鹤������,������Ӧ����¼�
*******************************************************************************}
unit UEventHardware;

{$I Link.Inc}
interface

uses
  Windows, Classes, UMgrPlug, UBusinessConst, ULibFun, UMITConst,
  UPlugConst,UMgrSendCardNo;

type
  THardwareWorker = class(TPlugEventWorker)
  public
    class function ModuleInfo: TPlugModuleInfo; override;
    procedure RunSystemObject(const nParam: PPlugRunParameter); override;
    procedure InitSystemObject; override;
    //����������ʱ��ʼ��
    procedure BeforeStartServer; override;
    //��������֮ǰ����
    procedure AfterStopServer; override;
    //����ر�֮�����
    {$IFDEF DEBUG}
    procedure GetExtendMenu(const nList: TList); override;
    {$ENDIF}
  end;

var
  gPlugRunParam: TPlugRunParameter;
  //���в���

implementation

uses
  SysUtils, USysLoger, UHardBusiness, UMgrTruckProbe, UMgrParam,
  UMgrQueue, UMgrLEDCard, UMgrHardHelper, UMgrRemotePrint, U02NReader,
  UMgrERelay,   {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UMgrRemoteVoice, UMgrCodePrinter, UMgrLEDDisp, UMgrRFID102, UMgrVoiceNet,
  UMgrTTCEM100, UMgrTTCEK720, UMgrTTCEDispenser, UMgrBXFontCard;

class function THardwareWorker.ModuleInfo: TPlugModuleInfo;
begin
  Result := inherited ModuleInfo;
  with Result do
  begin
    FModuleID := sPlug_ModuleHD;
    FModuleName := 'Ӳ���ػ�';
    FModuleVersion := '2014-09-30';
    FModuleDesc := '�ṩˮ��һ��ͨ������Ӳ���������';
    FModuleBuildTime:= Str2DateTime('2014-09-30 15:01:01');
  end;
end;

procedure THardwareWorker.RunSystemObject(const nParam: PPlugRunParameter);
var nStr,nCfg: string;
begin
  gPlugRunParam := nParam^;
  nCfg := gPlugRunParam.FAppPath + 'Hardware\';

  try
    nStr := 'LED';
    gCardManager.TempDir := nCfg + 'Temp\';
    gCardManager.FileName := nCfg + 'LED.xml';

    nStr := 'Զ���ͷ';
    gHardwareHelper.LoadConfig(nCfg + '900MK.xml');

    //nStr := '����������';
    //gBlueReader.LoadConfig(nCfg + 'BlueCardReader.XML');

    nStr := '�����ͷ';
    g02NReader.LoadConfig(nCfg + 'Readers.xml');

    nStr := '������';
    gMultiJSManager.LoadFile(nCfg + 'JSQ.xml');

    nStr := '�̵���';
    gERelayManager.LoadConfig(nCfg + 'ERelay.xml');

    nStr := 'Զ�̴�ӡ';
    gRemotePrinter.LoadConfig(nCfg + 'Printer.xml');

    nStr := '��������';
    gVoiceHelper.LoadConfig(nCfg + 'Voice.xml');

    nStr := '������������';
    if FileExists(nCfg + 'NetVoice.xml') then
    begin
      if not Assigned(gNetVoiceHelper) then
        gNetVoiceHelper := TNetVoiceManager.Create;
      gNetVoiceHelper.LoadConfig(nCfg + 'NetVoice.xml');
    end;

    nStr := '�����';
    gCodePrinterManager.LoadConfig(nCfg + 'CodePrinter.xml');

    nStr := 'С����ʾ';
    gDisplayManager.LoadConfig(nCfg + 'LEDDisp.xml');

    {$IFDEF HYRFID201}
    nStr := '����RFID102';
    if not Assigned(gHYReaderManager) then
    begin
      gHYReaderManager := THYReaderManager.Create;
      gHYReaderManager.LoadConfig(nCfg + 'RFID102.xml');
    end;
    {$ENDIF}

    nStr := '����һ������';
    if not Assigned(gM100ReaderManager) then
    begin
      gM100ReaderManager := TM100ReaderManager.Create;
      gM100ReaderManager.LoadConfig(nCfg + cTTCE_M100_Config);
    end;

    nStr := '���������';
    if FileExists(nCfg + 'TruckProber.xml') then
    begin
      gProberManager := TProberManager.Create;
      gProberManager.LoadConfig(nCfg + 'TruckProber.xml');
    end;

    {$IFDEF PurELabelAutoCard}
      {$IFDEF UseTTCEDispenser}
      nStr := 'K720���緢����(�°�����)';
      if not Assigned(gDispenserManager) then
      begin
        gDispenserManager := TDispenserManager.Create;
        gDispenserManager.LoadConfig(nCfg + 'TTCE_K720.xml');
      end;
      {$ELSE}
      nStr := 'K720���緢����';
      if not Assigned(gK720ReaderManager) then
      begin
        gK720ReaderManager := TK720ReaderManager.Create;
        gK720ReaderManager.LoadConfig(nCfg + cTTCE_K720_Config);
      end;
      {$ENDIF}
    {$ENDIF}

    {$IFDEF SanLed}
    nStr := 'ɢװ����С��(������)';
    if not Assigned(gBXFontCardManager) then
    begin
      gBXFontCardManager := TBXFontCardManager.Create;
      gBXFontCardManager.LoadConfig(nCfg + 'BXFontLED.xml');
    end;
    {$ELSE}
      {$IFDEF LedNew}
      if not Assigned(gBXFontCardManager) then
      begin
        gBXFontCardManager := TBXFontCardManager.Create;
        gBXFontCardManager.LoadConfig(nCfg + 'BXFontLED.xml');
      end;
      {$ENDIF}
    {$ENDIF}

    {$IFDEF FixLoad}
    nStr := '����װ��';
    gSendCardNo.LoadConfig(nCfg + 'PLCController.xml');
    {$ENDIF}
  except
    on E:Exception do
    begin
      nStr := Format('����[ %s ]�����ļ�ʧ��: %s', [nStr, E.Message]);
      gSysLoger.AddLog(nStr);
    end;
  end;
end;

{$IFDEF DEBUG}
procedure THardwareWorker.GetExtendMenu(const nList: TList);
var nItem: PPlugMenuItem;
begin
  New(nItem);
  nList.Add(nItem);
  nItem.FName := 'Menu_Param_2';

  nItem.FModule := ModuleInfo.FModuleID;
  nItem.FCaption := 'Ӳ������';
  nItem.FFormID := cFI_FormTest2;
  nItem.FDefault := False;
end;
{$ENDIF}

procedure THardwareWorker.InitSystemObject;
begin
  g02NReader := T02NReader.Create;
  //�����ͷ

  gHardwareHelper := THardwareHelper.Create;
  //Զ���ͷ

  if not Assigned(gMultiJSManager) then
    gMultiJSManager := TMultiJSManager.Create;
  //������

  gHardShareData := WhenBusinessMITSharedDataIn;
  //hard monitor share
  {$IFDEF FixLoad}
  gSendCardNo := TReaderHelper.Create;
  {$ENDIF}
end;

procedure THardwareWorker.BeforeStartServer;
begin
  gTruckQueueManager.StartQueue(gParamManager.ActiveParam.FDB.FID);
  //truck queue

  gHardwareHelper.OnProce := WhenReaderCardArrived;
  gHardwareHelper.StartRead;
  //long reader

  //gBlueReader.OnCardArrived := WhenBlueReaderCardArrived;
  //if not gHardwareHelper.ConnHelper then gBlueReader.StartReader;
  //blue reader, �����ʹ��Ӳ���ػ�������������������Զ���

  {$IFDEF HYRFID201}
  if Assigned(gHYReaderManager) then
  begin
    gHYReaderManager.OnCardProc := WhenHYReaderCardArrived;
    gHYReaderManager.StartReader;
  end;
  {$ENDIF}

  if Assigned(gM100ReaderManager) then
  begin
    gM100ReaderManager.OnCardProc := WhenTTCE_M100_ReadCard;
    gM100ReaderManager.StartReader;
  end;
  //����һ������

  g02NReader.OnCardIn := WhenReaderCardIn;
  g02NReader.OnCardOut := WhenReaderCardOut;
  g02NReader.StartReader;
  //near reader

  gMultiJSManager.SaveDataProc := WhenSaveJS;
  {$IFNDEF JSTruckNone}
  gMultiJSManager.GetTruckProc := GetJSTruck;
  {$ENDIF}
  gMultiJSManager.StartJS;
  //counter
  gERelayManager.ControlStart;
  //erelay

  gRemotePrinter.StartPrinter;
  //printer
  gVoiceHelper.StartVoice;
  //voice

  if Assigned(gNetVoiceHelper) then
    gNetVoiceHelper.StartVoice;
  //NetVoice

  gCardManager.StartSender;
  //led display
  gDisplayManager.StartDisplay;
  //small led

  {$IFDEF MITTruckProber}
  gProberManager.StartProber;
  {$ENDIF}

  {$IFDEF PurELabelAutoCard}
    {$IFDEF UseTTCEDispenser}
    if Assigned(gDispenserManager) then
    begin
      gDispenserManager.OnCardProc := WhenTTCE_K720_ReadCardByTTCEDispenser;
      gDispenserManager.StartDispensers;
    end;
    {$ELSE}
    if Assigned(gK720ReaderManager) then
    begin
      gK720ReaderManager.OnCardProc := WhenTTCE_K720_ReadCard;
      gK720ReaderManager.StartReader;
    end;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF SanLed}
  if Assigned(gBXFontCardManager) then
    gBXFontCardManager.StartService;
   {$ELSE}
    {$IFDEF LedNew}
    if Assigned(gBXFontCardManager) then
      gBXFontCardManager.StartService;
    {$ENDIF}
 {$ENDIF}
  
  {$IFDEF FixLoad}
  if Assigned(gSendCardNo) then
  gSendCardNo.StartPrinter;
  //sendcard
  {$ENDIF}
end;

procedure THardwareWorker.AfterStopServer;
begin
  gVoiceHelper.StopVoice;
  //voice
  gRemotePrinter.StopPrinter;
  //printer
  if Assigned(gNetVoiceHelper) then
    gNetVoiceHelper.StopVoice;
  //NetVoice

  gERelayManager.ControlStop;
  //erelay
  gMultiJSManager.StopJS;
  //counter

  g02NReader.StopReader;
  g02NReader.OnCardIn := nil;
  g02NReader.OnCardOut := nil;

  gHardwareHelper.StopRead;
  gHardwareHelper.OnProce := nil;
  //reader

  //gBlueReader.StopReader;
  //gBlueReader.OnCardArrived := nil;
  //blue reader

  {$IFDEF HYRFID201}
  if Assigned(gHYReaderManager) then
  begin
    gHYReaderManager.StopReader;
    gHYReaderManager.OnCardProc := nil;
  end;
  {$ENDIF}
  //HY Reader

  if Assigned(gM100ReaderManager) then
  begin
    gM100ReaderManager.StopReader;
    gM100ReaderManager.OnCardProc := nil;
  end;
  //����һ������

  gDisplayManager.StopDisplay;
  //small led
  gCardManager.StopSender;
  //led

  gTruckQueueManager.StopQueue;
  //queue

  {$IFDEF MITTruckProber}
  gProberManager.StopProber;
  {$ENDIF}

  {$IFDEF PurELabelAutoCard}
    {$IFDEF UseTTCEDispenser}
    gDispenserManager.StopDispensers;
    {$ELSE}
    gK720ReaderManager.StopReader;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF SanLed}
  if Assigned(gBXFontCardManager) then
    gBXFontCardManager.StopService;
  {$ELSE}
    {$IFDEF LedNew}
    if Assigned(gBXFontCardManager) then
      gBXFontCardManager.StopService;
    {$ENDIF}
  {$ENDIF}

  
  {$IFDEF FixLoad}
  if Assigned(gSendCardNo) then
  gSendCardNo.StopPrinter;
  //sendcard
  {$ENDIF}
end;

end.
