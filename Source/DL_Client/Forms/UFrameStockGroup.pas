{*******************************************************************************
  ����:  2018-08-20
  ����: ��ѯˮ����Ʒ������  �ͻ�����
*******************************************************************************}
unit UFrameStockGroup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  IniFiles, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, cxTextEdit, Menus,
  dxLayoutControl, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, dxSkinsdxLCPainter;

type
  TfFrameStockGroup = class(TfFrameNormal)
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    cxLevel2: TcxGridLevel;
    cxView2: TcxGridDBTableView;
    DataSource2: TDataSource;
    SQLNo1: TADOQuery;
    N7: TMenuItem;
    Edt_GName: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    pm1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    N2: TMenuItem;
    procedure cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
      ALevel: TcxGridLevel);
    procedure BtnRefreshClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure Edt_GNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxView2CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuItem1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);

  private
    procedure EditStockGroup;
  protected
    FQueryAll: Boolean;
    //��ѯ����
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnLoadGridConfig(const nIni: TIniFile); override;
    procedure OnSaveGridConfig(const nIni: TIniFile); override;
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string = '';
     const nQuery: TADOQuery = nil); override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysBusiness, UBusinessConst, UFormBase, USysDataDict,
  UDataModule, UFormDateFilter, UForminputbox, USysConst, USysDB, USysGrid;

//------------------------------------------------------------------------------
class function TfFrameStockGroup.FrameID: integer;
begin
  Result := cFI_FrameStockGroup;
end;

procedure TfFrameStockGroup.OnCreateFrame;
begin
  inherited;
  FQueryAll := True;
  cxGrid1.ActiveLevel := cxLevel1;
end;

procedure TfFrameStockGroup.OnDestroyFrame;
begin
  inherited;
end;

procedure TfFrameStockGroup.OnLoadGridConfig(const nIni: TIniFile);
begin
  cxGrid1.ActiveLevel := cxLevel1;
  cxGrid1ActiveTabChanged(cxGrid1, cxGrid1.ActiveLevel);

  gSysEntityManager.BuildViewColumn(cxView2, 'MAIN_D13');
  InitTableView(Name, cxView2, nIni);
end;

procedure TfFrameStockGroup.OnSaveGridConfig(const nIni: TIniFile);
begin
  SaveUserDefineTableView(Name, cxView2, nIni);
end;

procedure TfFrameStockGroup.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
var nStr: string;
begin
  nDefault := False;

  if (cxGrid1.ActiveLevel=cxLevel1) then
  begin
    nStr := ' Select * From  $StockGroup  Where 1=1 ';
    if FWhere <> '' then
      nStr := nStr + ' And (' + FWhere + ')';
    //xxxxx

    nStr := MacroValue(nStr, [MI('$StockGroup', sTable_StockGroup)]);
    FDM.QueryData(SQLQuery, nStr);
  end;

  if (cxGrid1.ActiveLevel=cxLevel2) then
  begin
    nStr := ' Select D_ID,D_ParamB,D_Value,D_ParamA,G_Name From $Dict Left Join Sys_StockGroup g on D_ParamA=g.R_ID '+
            ' Where D_Name=''StockItem'' And D_Value Not Like ''%%����%%'' ';

    if FWhere <> '' then
        nStr := nStr + ' And (' + FWhere + ')';

    nStr := MacroValue(nStr, [MI('$Dict', sTable_SysDict)]);
    //xxxxx

    FDM.QueryData(SQLNo1, nStr);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameStockGroup.cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
  ALevel: TcxGridLevel);
begin
  BtnAdd.Enabled := cxGrid1.ActiveLevel = cxLevel1;
  BtnEdit.Enabled:= cxGrid1.ActiveLevel = cxLevel1;
  BtnDel.Enabled := cxGrid1.ActiveLevel = cxLevel1;

  if (cxGrid1.ActiveLevel = cxLevel1) then
    cxGrid1.PopupMenu:= PMenu1
  else cxGrid1.PopupMenu:= Pm1;
end;

//Desc: ˢ��
procedure TfFrameStockGroup.BtnRefreshClick(Sender: TObject);
begin
  FWhere := '';
  InitFormData(FWhere);
end;

procedure TfFrameStockGroup.N1Click(Sender: TObject);
var nGNo, nStName : string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nGNo := SQLQuery.FieldByName('R_ID').AsString;

    FWhere := ' D_ParamA='+nGNo+' ';
    cxGrid1.ActiveLevel := cxLevel2;
    InitFormData(FWhere);
  end;
end;

procedure TfFrameStockGroup.cxView1DblClick(Sender: TObject);
begin
  N1Click(Self);
end;

procedure TfFrameStockGroup.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormStockGroup, PopedomItem, @nParam);

  if (nParam.FCommand = mrOk) then
  begin
    BtnRefresh.Click;
  end;
end;

procedure TfFrameStockGroup.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
    nStr : string;
begin
  if not (cxGrid1.ActiveLevel = cxLevel1) then exit;

  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA  := SQLQuery.FieldByName('R_ID').AsString;
  nParam.FParamB  := SQLQuery.FieldByName('G_Name').AsString;

  CreateBaseFormItem(cFI_FormStockGroup, PopedomItem, @nParam);
  if (nParam.FCommand = mrOk) then
  begin
    BtnRefresh.Click;
  end;
end;

procedure TfFrameStockGroup.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if not (cxGrid1.ActiveLevel = cxLevel1) then exit;

  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�����ļ�¼', sHint); Exit;
  end;

  if not QueryDlg('ȷ��Ҫɾ���÷���ô', sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nStr := SQLQuery.FieldByName('R_ID').AsString;
    nSQL := 'Delete From %s Where R_ID=''%s''';
    nSQL := Format(nSQL, [sTable_StockGroup, nStr]);

    FDM.ExecuteSQL(nSQL);

    FDM.ADOConn.CommitTrans;
    BtnRefresh.Click;
    ShowMsg('�ѳɹ�ɾ������', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('ɾ��ʧ��', 'δ֪����');
  end;
end;

procedure TfFrameStockGroup.Edt_GNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  Edt_GName.Text := Trim(Edt_GName.Text);
  if Edt_GName.Text <> '' then
  begin
    FWhere := ' And G_Name like ''%' + Edt_GName.Text + '%'''
  end;

  InitFormData(FWhere);
end;

procedure TfFrameStockGroup.EditStockGroup;
var nParam: TFormCommandParam;
begin
  if (cxGrid1.ActiveLevel = cxLevel2) then
  begin
    if cxView2.DataController.GetSelectedCount < 1 then
    begin
      ShowMsg('��ѡ��Ҫ�����ļ�¼', sHint); Exit;
    end;

    nParam.FCommand := cCmd_EditData;
    nParam.FParamA := SQLNo1.FieldByName('D_Value').AsString;
    nParam.FParamB := SQLNo1.FieldByName('D_ParamB').AsString;
    nParam.FParamC := SQLNo1.FieldByName('D_ID').AsString;
    CreateBaseFormItem(cFI_FormEditStockGroup, '', @nParam);
    if (nParam.FCommand = mrOk) then
    begin
      BtnRefresh.Click;
    end;
  end;
end;

procedure TfFrameStockGroup.cxView2CellDblClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
var nParam: TFormCommandParam;
begin
  EditStockGroup;
end;

procedure TfFrameStockGroup.MenuItem1Click(Sender: TObject);
var nGNo, nStName : string;
begin
  EditStockGroup;
end;

procedure TfFrameStockGroup.N2Click(Sender: TObject);
begin
  BtnRefresh.Click;;
end;

initialization
  gControlManager.RegCtrl(TfFrameStockGroup, TfFrameStockGroup.FrameID);
end.
