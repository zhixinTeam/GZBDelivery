{*******************************************************************************
  作者: dmzn@163.com 2009-7-2
  描述: 销售信息
*******************************************************************************}
unit UFramePSaleInfo;

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
  TfFrameSaleInfo = class(TfFrameNormal)
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

class function TfFrameSaleInfo.FrameID: integer;
begin
  Result := cFI_FrameSaleInfo;
end;

function TfFrameSaleInfo.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_SysDict + ' where D_Name = ''StockItem'' ';
  if nWhere <> '' then
    Result := Result + ' And (' + nWhere + ')';
  Result := Result + ' Order By D_Index ';
end;

//Desc: 查询
procedure TfFrameSaleInfo.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;
    
    FWhere := Format('D_Value Like ''%%%s%%'' or D_ParamB Like ''%%%s%%''',
              [EditName.Text,EditName.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameSaleInfo.N2Click(Sender: TObject);
var nStr: string;
    nStockID: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('D_Value').AsString;
    nStr := Format('确定要将品种[ %s ]设为允许自助机取卡吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStockID := SQLQuery.FieldByName('D_ParamB').AsString;

    nStr := 'Update %s Set D_ParamC = ''%s'' Where D_Name=''%s'' And D_ParamB = ''%s'' ';
    nStr := Format(nStr, [sTable_SysDict, sFlag_Yes,sFlag_StockItem, nStockID]);
    FDM.ExecuteSQL(nStr);

    InitFormData(FWhere);
  end;
end;

procedure TfFrameSaleInfo.N3Click(Sender: TObject);
var nStr, nStockID: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('D_Value').AsString;
    nStr := Format('确定要将品种[ %s ]设为禁止自助机取卡吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStockID   := SQLQuery.FieldByName('D_ParamB').AsString;

    nStr := ' Update %s Set D_ParamC = ''%s'' Where D_Name = ''%s'' And D_ParamB = ''%s'' ';
    nStr := Format(nStr, [sTable_SysDict, sFlag_No,sFlag_StockItem, nStockID]);
    FDM.ExecuteSQL(nStr);

    InitFormData(FWhere);
  end;
end;

procedure TfFrameSaleInfo.OnLoadPopedom;
begin
  inherited;
  BtnAdd.Visible  := False;
  BtnEdit.Visible := False;
  BtnDel.Visible  := False;
end;

initialization
  gControlManager.RegCtrl(TfFrameSaleInfo, TfFrameSaleInfo.FrameID);
end.
