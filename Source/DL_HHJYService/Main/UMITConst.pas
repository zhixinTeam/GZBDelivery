{*******************************************************************************
  ����: dmzn@163.com 2011-10-22
  ����: ��������
*******************************************************************************}
unit UMITConst;

{$I Link.Inc}
interface

uses
  Windows, SysUtils, Classes, ComCtrls, Forms, IniFiles, USysMAC;

const
  cSBar_Date          = 0;                           //�����������
  cSBar_Time          = 1;                           //ʱ���������
  cSBar_User          = 2;                           //�û��������

const
  {*Frame ID*}
  cFI_FrameRunlog     = $0002;                       //������־
  cFI_FrameSummary    = $0005;                       //��ϢժҪ
  cFI_FrameConfig     = $0006;                       //��������
  cFI_FrameParam      = $0007;                       //��������
  cFI_FramePlugs      = $0008;                       //�������
  cFI_FrameStatus     = $0009;                       //����״̬

  {*Form ID*}
  cFI_FormPack        = $0050;                       //������
  cFI_FormDB          = $0051;                       //���ݿ�
  cFI_FormSAP         = $0052;                       //sap
  cFI_FormPerform     = $0053;                       //��������
  cFI_FormServiceURL  = $0055;                       //�����ַ

  {*Command*}
  cCmd_AdminChanged   = $0001;                       //�����л�
  cCmd_RefreshData    = $0002;                       //ˢ������
  cCmd_ViewSysLog     = $0003;                       //ϵͳ��־

  cCmd_ModalResult    = $1001;                       //Modal����
  cCmd_FormClose      = $1002;                       //�رմ���
  cCmd_AddData        = $1003;                       //�������
  cCmd_EditData       = $1005;                       //�޸�����
  cCmd_ViewData       = $1006;                       //�鿴����

  cSendWeChatMsgType_AddBill     = 1; //�������
  cSendWeChatMsgType_OutFactory  = 2; //��������
  cSendWeChatMsgType_Report      = 3; //����
  cSendWeChatMsgType_DelBill     = 4; //ɾ�����

  c_WeChatStatusCreateCard       = 0; //�����Ѱ쿨
  c_WeChatStatusFinished         = 1; //���������
  c_WeChatStatusDeleted          = 2;  //������ɾ��

type
  THHJYUrl = record
    FCID        : Integer;                            //������
    FURL        : string;                            //��ַ
    FPassword   : string;                            //����
    FDefWhere   : string;                            //����
  end;

type
  TSysParam = record
    FProgID     : string;                            //�����ʶ
    FAppTitle   : string;                            //�����������ʾ
    FMainTitle  : string;                            //���������
    FHintText   : string;                            //��ʾ�ı�
    FCopyRight  : string;                            //��Ȩ����

    FAppFlag    : string;                            //�����ʶ
    FParam      : string;                            //��������
    FIconFile   : string;                            //ͼ���ļ�

    FAdminPwd   : string;                            //����Ա����
    FIsAdmin    : Boolean;                           //����Ա״̬
    FAdminKeep  : Integer;                           //״̬����

    FLocalIP    : string;                            //����IP
    FLocalMAC   : string;                            //����MAC
    FLocalName  : string;                            //��������

    FDisplayDPI : Integer;                           //��Ļ�ֱ���
    FAutoMin    : Boolean;                           //�Զ���С��

    FFactID     : string;                            //΢��:������ʶ
    FSrvRemote  : string;                            //΢��:Զ�̷���
    FSrvMIT     : string;                            //΢��:���ط���
    FHHJYUrl    : array of THHJYUrl;                 //��Ӿ�Զ�ӿڷ���

    FERPSrv                : string;                    //ERP�ӿڵ�ַ
    FERPSrvOms             : string;                    //ERPOms�ӿڵ�ַ
    FToken                 : string;                    //ERP��ӦToken
    FTokenOms              : string;                    //ERPOms��ӦToken
    FshipperCode           : string;                    //�����ͻ�����
    FshipperName           : string;                    //�����ͻ�����
    FshipperContactCode    : string;                    //������ϵ�˱���
    FshipperContactName    : string;                    //������ϵ������
    FshipperContactTel     : string;                    //������ϵ�绰
    FshipperLocationCode   : string;                    //�����ص����
    FshipperLocationName   : string;                    //�����ص�����
    FconsigneeCode         : string;                    //�ջ��ͻ�����
    FconsigneeName         : string;                    //�ջ��ͻ�����
    FconsigneeContactCode  : string;                    //�ջ���ϵ�˱���
    FconsigneeContactName  : string;                    //�ջ���ϵ������
    FconsigneeContactTel   : string;                    //�ջ���ϵ�绰
    FconsigneeLocationCode : string;                    //�ջ��ص����
    FconsigneeLocationName : string;                    //�ջ��ص�����
    ForgId                 : string;                    //���ڹ�˾
    FpackCode              : string;                    //��װ������
    FshipperNameEx         : string;                    //�����ͻ�����
    FClearPicture          : string;                    //������ʱ�������������ץ��ͼƬ
  end;
  //ϵͳ����

var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gStatusBar: TStatusBar;                            //ȫ��ʹ��״̬��

procedure InitSystemEnvironment;
//��ʼ��ϵͳ���л����ı���
procedure ActionSysParameter(const nIsRead: Boolean);
//��дϵͳ���ò���

procedure ShowMsgOnLastPanelOfStatusBar(const nMsg: string);
procedure StatusBarMsg(const nMsg: string; const nIdx: integer);
//��״̬����ʾ��Ϣ

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'Bus_MIT';                   //Ĭ�ϱ�ʶ
  sAppTitle           = 'Bus_MIT';                   //�������
  sMainCaption        = 'ͨ���м��';                //�����ڱ���
  sHintText           = 'ͨ���м������';            //��ʾ����

  sHint               = '��ʾ';                      //�Ի������
  sWarn               = '����';                      //==
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sError              = '����';                      //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��
  sUser               = '�û�:��%s��';               //�������û�

  sConfigFile         = 'Config.Ini';                //�������ļ�
  sConfigSec          = 'Config';                    //������С��
  
  sFormConfig         = 'FormInfo.ini';              //��������
  sLogDir             = 'Logs\';                     //��־Ŀ¼
  sLogSyncLock        = 'SyncLock_WebChat_CommonMIT';    //��־ͬ����

  sPlugDir            = 'Plugs\';                    //���Ŀ¼
  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�
  
implementation

procedure InitSystemEnvironment;
begin
  Randomize;
  ShortDateFormat := 'YYYY-MM-DD';
  gPath := ExtractFilePath(Application.ExeName);
end;

//Desc: ��дϵͳ���ò���
procedure ActionSysParameter(const nIsRead: Boolean);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    nIni := TIniFile.Create(gPath + sConfigFile);
    //config file

    with nIni,gSysParam do
    begin
      if nIsRead then
      begin
        FProgID    := ReadString(sConfigSec, 'ProgID', sProgID);
        //�����ʶ�����������в���          
        FAppTitle  := ReadString(FProgID, 'AppTitle', sAppTitle);
        FMainTitle := ReadString(FProgID, 'MainTitle', sMainCaption);
        FHintText  := ReadString(FProgID, 'HintText', '');

        FCopyRight := ReadString(FProgID, 'CopyRight', '');
        FCopyRight := StringReplace(FCopyRight, '\n', #13#10, [rfReplaceAll]);
        FAppFlag   := ReadString(FProgID, 'AppFlag', 'COMMIT');

        FToken     := ReadString(FProgID, 'Token', 'J1xjBge64C8mfz+He1KQxf+Gy5Gj8BG/C5Ml69vsGEDUXhddyIzI9LJuFntc/8yv8QypfRKrB0+q\r\nSaszGoDi9yRlOa12+vikLJGbm1T2KCo=');
        FTokenOms  := ReadString(FProgID, 'TokenOms', 'J1xjBge64C8mfz+He1KQxf+Gy5Gj8BG/C5Ml69vsGEDUXhddyIzI9LJuFntc/8yv8QypfRKrB0+q\r\nSaszGoDi9yRlOa12+vikLJGbm1T2KCo=');

        FClearPicture:= ReadString(FProgID, 'ClearPicture', 'N');

        FParam     := ParamStr(1);
        FIconFile  := ReadString(FProgID, 'IconFile', gPath + 'Icons\Icon.ini');
        FIconFile  := StringReplace(FIconFile, '$Path\', gPath, [rfIgnoreCase]);

        FLocalMAC   := MakeActionID_MAC;
        GetLocalIPConfig(FLocalName, FLocalIP);
        FDisplayDPI := GetDeviceCaps(GetDC(0), LOGPIXELSY);
      end;
    end;
  finally
    nIni.Free;
  end; 
end;

//------------------------------------------------------------------------------
//Desc: ��ȫ��״̬�����һ��Panel����ʾnMsg��Ϣ
procedure ShowMsgOnLastPanelOfStatusBar(const nMsg: string);
begin
  if Assigned(gStatusBar) and (gStatusBar.Panels.Count > 0) then
  begin
    gStatusBar.Panels[gStatusBar.Panels.Count - 1].Text := nMsg;
    Application.ProcessMessages;
  end;
end;

//Desc: ������nIdx��Panel����ʾnMsg��Ϣ
procedure StatusBarMsg(const nMsg: string; const nIdx: integer);
begin
  if Assigned(gStatusBar) and (gStatusBar.Panels.Count > nIdx) and
     (nIdx > -1) then
  begin
    gStatusBar.Panels[nIdx].Text := nMsg;
    gStatusBar.Panels[nIdx].Width := gStatusBar.Canvas.TextWidth(nMsg) +
                                     Trunc(gSysParam.FDisplayDPI * Length(nMsg) / 50);
    //Application.ProcessMessages;
  end;
end;

end.
