{*******************************************************************************
  作者: dmzn@163.com 2009-7-2
  描述: 销售信息
*******************************************************************************}
unit UFramePUserYSInfo;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxContainer, dxLayoutControl, cxMaskEdit, cxButtonEdit, cxTextEdit,
  ADODB, cxLabel, UBitmapPanel, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, Menus;

type
  TfFrameUserYSInfo = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    PopupMenu1: TPopupMenu;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure OnLoadPopedom; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase,
  UFormCtrl, USysBusiness;

class function TfFrameUserYSInfo.FrameID: integer;
begin
  Result := cFI_FrameUserYSInfo;
end;

function TfFrameUserYSInfo.InitFormDataSQL(const nWhere: string): string;
begin
  Result := ' Select * From ' + sTable_UserYSWh;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By R_ID ';
end;

//Desc: 查询
procedure TfFrameUserYSInfo.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;
    
    FWhere := Format(' P_StockNo Like ''%%%s%%'' or P_StockName Like ''%%%s%%''',
              [EditName.Text,EditName.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameUserYSInfo.N2Click(Sender: TObject);
var nStr, nUserName, nRID: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nRID      := SQLQuery.FieldByName('R_ID').AsString;
    nStr      := SQLQuery.FieldByName('P_StockName').AsString;
    nUserName := SQLQuery.FieldByName('P_UName').AsString;
    nStr := Format('确定要将品种[ %s ]设为允许[ %s ]验收吗?', [nStr,nUserName]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := ' Update %s Set P_State = ''%s'' Where R_ID = ''%s'' ';
    nStr := Format(nStr, [sTable_UserYSWh, sFlag_Yes,nRID]);
    FDM.ExecuteSQL(nStr);

    InitFormData(FWhere);
  end;
end;

procedure TfFrameUserYSInfo.N3Click(Sender: TObject);
var nStr, nUserName, nRID: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nRID      := SQLQuery.FieldByName('R_ID').AsString;
    nStr      := SQLQuery.FieldByName('P_StockName').AsString;
    nUserName := SQLQuery.FieldByName('P_UName').AsString;
    nStr := Format('确定要将品种[ %s ]设为禁止[ %s ]验收吗?', [nStr,nUserName]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := ' Update %s Set P_State = ''%s'' Where R_ID = ''%s'' ';
    nStr := Format(nStr, [sTable_UserYSWh, sFlag_No,nRID]);
    FDM.ExecuteSQL(nStr);

    InitFormData(FWhere);
  end;
end;

procedure TfFrameUserYSInfo.OnLoadPopedom;
begin
  inherited;
  BtnEdit.Visible := False;
end;

procedure TfFrameUserYSInfo.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormUserYSWh, '', @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFrameUserYSInfo.BtnDelClick(Sender: TObject);
var nStr,nRID,nEvent: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nRID  := SQLQuery.FieldByName('R_ID').AsString;
    nStr  := '确定要删除这条记录吗?';
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_UserYSWh, nRID]);

    FDM.ExecuteSQL(nStr);


    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameUserYSInfo, TfFrameUserYSInfo.FrameID);
end.
