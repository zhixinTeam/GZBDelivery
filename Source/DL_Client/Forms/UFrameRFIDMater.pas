{*******************************************************************************
  作者: dmzn@163.com 2009-7-2
  描述: 销售信息
*******************************************************************************}
unit UFrameRFIDMater;

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
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, Menus,
  cxGridCustomPopupMenu, cxGridPopupMenu;

type
  TfFrameRFIDMater = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    PopupMenu1: TPopupMenu;
    N4: TMenuItem;
    N1: TMenuItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N4Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
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
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase,UFormInputbox,
  UFormCtrl, USysBusiness;

class function TfFrameRFIDMater.FrameID: integer;
begin
  Result := cFI_FrameRFIDMater;
end;

function TfFrameRFIDMater.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_SysDict + ' where D_Name = ''StockTunnel'' ';
  if nWhere <> '' then
    Result := Result + ' And (' + nWhere + ')';
  Result := Result + ' Order By D_Index Desc ';
end;

//Desc: 查询
procedure TfFrameRFIDMater.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('D_Desc Like ''%%%s%%'' ',[EditName.Text]);
    InitFormData(FWhere);
  end;
end;


procedure TfFrameRFIDMater.OnLoadPopedom;
begin
  inherited;
  BtnAdd.Visible  := False;
  BtnDel.Visible  := False;
end;

procedure TfFrameRFIDMater.N4Click(Sender: TObject);
var nStr,nDesc,nValue,nParamB : string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nDesc   := SQLQuery.FieldByName('D_Desc').AsString;
    nValue  := SQLQuery.FieldByName('D_Value').AsString;
    nParamB := SQLQuery.FieldByName('D_ParamB').AsString;

    nStr := ' update %s set D_ParamF = ''%s'' where D_Name = ''%s'' and D_Desc = ''%s'' and D_Value = ''%s''  and D_ParamB = ''%s'' ';
    nStr := Format(nStr, [sTable_SysDict, sFlag_Yes, 'StockTunnel',nDesc,nValue,nParamB]);
    FDM.ExecuteSQL(nStr);

    nStr := '[ %s %s %s]设置开启.';
    nStr := Format(nStr, [nDesc,nValue,nParamB]);
    FDM.WriteSysLog(sFlag_BillItem, nDesc+'-'+nParamB, nStr, False);

    InitFormData(FWhere);
    ShowMsg('设置开启通道成功', sHint);
  end;
end;

procedure TfFrameRFIDMater.N1Click(Sender: TObject);
var nStr,nDesc,nValue,nParamB : string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nDesc   := SQLQuery.FieldByName('D_Desc').AsString;
    nValue  := SQLQuery.FieldByName('D_Value').AsString;
    nParamB := SQLQuery.FieldByName('D_ParamB').AsString;

    nStr := ' update %s set D_ParamF = ''%s'' where D_Name = ''%s'' and D_Desc = ''%s'' and D_Value = ''%s''  and D_ParamB = ''%s'' ';
    nStr := Format(nStr, [sTable_SysDict, sFlag_No, 'StockTunnel',nDesc,nValue,nParamB]);
    FDM.ExecuteSQL(nStr);

    nStr := '[ %s %s %s]设置关闭.';
    nStr := Format(nStr, [nDesc,nValue,nParamB]);
    FDM.WriteSysLog(sFlag_BillItem, nDesc+'-'+nParamB, nStr, False);

    InitFormData(FWhere);
    ShowMsg('设置关闭通道成功', sHint);
  end;
end;

procedure TfFrameRFIDMater.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA  := SQLQuery.FieldByName('D_Value').AsString;
    nP.FParamB  := SQLQuery.FieldByName('D_Memo').AsString;
    nP.FParamC  := SQLQuery.FieldByName('D_ParamB').AsString;
    nP.FParamD  := SQLQuery.FieldByName('D_Desc').AsString;
    
    CreateBaseFormItem(cFI_FormOrderDtl, '', @nP);
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameRFIDMater, TfFrameRFIDMater.FrameID);
end.
