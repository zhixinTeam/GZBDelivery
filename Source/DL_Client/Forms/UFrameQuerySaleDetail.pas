{*******************************************************************************
  作者: dmzn@163.com 2012-03-26
  描述: 发货明细
*******************************************************************************}
unit UFrameQuerySaleDetail;

{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameSaleDetailQuery = class(TfFrameNormal)
    cxtxtdt1: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxtxtdt2: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    pmPMenu1: TPopupMenu;
    mniN1: TMenuItem;
    cxtxtdt3: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxtxtdt4: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditBill: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure mniN1Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FJBWhere: string;
    //交班条件
    FShadowWeight: Double;
    //影子重量
    FGL: Boolean;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //查询SQL
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness,
  UBusinessConst, USysConst, USysDB, UDataModule;

class function TfFrameSaleDetailQuery.FrameID: integer;
begin
  Result := cFI_FrameSaleDetailQuery;
end;

procedure TfFrameSaleDetailQuery.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  FJBWhere := '';
  InitDateRange(Name, FStart, FEnd);
  FShadowWeight := -1;
end;

procedure TfFrameSaleDetailQuery.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameSaleDetailQuery.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  FEnableBackDB := True;
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := ' Select b.*, c.C_NAME From $Bill b '+
            ' Left Join S_Customer c On L_CusID=c.C_ID ';

  if FJBWhere = '' then
  begin
    Result := Result + 'Where (L_OutFact>=''$S'' and L_OutFact <''$End'')';

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;

  Result := Result + ' And L_OutFact is not NULL';

  {$IFDEF GLlade}
  FGL := PopedomItem = 'MAIN_N04';
  if FGL then
    Result := Result + ' And L_CardUsed = ''$CU'''
  else
    Result := Result + ' And (L_CardUsed <> ''$CU'' or L_CardUsed is null)';

  if not gPopedomManager.HasPopedom(PopedomItem, sPopedom_FullReport) then
  begin
    if FShadowWeight < 0 then
    begin
      FShadowWeight := 0;
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ShadowWeight]);

      with FDM.QueryTemp(nStr) do
      if RecordCount > 0 then
      begin
        FShadowWeight := Fields[0].AsFloat;
      end;
    end;

    if FShadowWeight > 0 then
    begin
      nStr := ' And L_MValue<%f';
      Result := Result +  Format(nStr, [FShadowWeight]);
    end;
  end;

  Result := MacroValue(Result, [MI('$Bill', sTable_Bill),
        MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1)),
        MI('$CU', sFlag_SaleSingle)]);
  {$ELSE}
  Result := MacroValue(Result, [MI('$Bill', sTable_Bill),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
  {$ENDIF}
end;

//Desc: 过滤字段
function TfFrameSaleDetailQuery.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'L_Price;L_Money';
end;

//Desc: 日期筛选
procedure TfFrameSaleDetailQuery.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: 执行查询
procedure TfFrameSaleDetailQuery.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text,EditBill.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'b.L_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text]);
    InitFormData(FWhere);
  end;

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FWhere := 'b.L_ID like ''%%%s%%''';
    FWhere := Format(FWhere, [EditBill.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: 交接班查询
procedure TfFrameSaleDetailQuery.mniN1Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    if Sender = mniN1 then
      FJBWhere := '(L_OutFact>=''%s'' and L_OutFact <''%s'')' else
    if Sender = N2 then
      FJBWhere := '(L_LadeTime>=''%s'' and L_LadeTime <''%s'')' else
    if Sender = N3 then
      FJBWhere := '(L_MDate>=''%s'' and L_MDate <''%s'')' else
    if Sender = N4 then
      FJBWhere := '(L_PDate>=''%s'' and L_PDate <''%s'')';

    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

procedure TfFrameSaleDetailQuery.N5Click(Sender: TObject);
var
  nStr : string;
  nRet : Boolean;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    if (SQLQuery.FieldByName('L_IsEmpty').AsString = 'Y')
      or (SQLQuery.FieldByName('L_YTOutFact').AsString='')
      or (SQLQuery.FieldByName('L_YTOutFact').IsNull) then
    begin
      nRet := SynEmptyBillYT(nStr);
      if nRet then
        ShowMsg('补传到云天数据成功', sHint);
    end
    else
    begin
      ShowMsg('此记录已经同步成功,不能再次同步！', sHint);
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameSaleDetailQuery, TfFrameSaleDetailQuery.FrameID);
end.
