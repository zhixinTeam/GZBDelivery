{*******************************************************************************
  作者: dmzn@163.com 2012-03-26
  描述: 发货明细
*******************************************************************************}
unit UFrameQuerySaletunnel;

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
  ComCtrls, ToolWin, cxSpinEdit, cxTimeEdit, StdCtrls, Buttons,
  cxDropDownEdit, cxCalendar;

type
  TfFrameSaletunnelQuery = class(TfFrameNormal)
    cxtxtdt1: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxtxtdt2: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    pmPMenu1: TPopupMenu;
    mniN1: TMenuItem;
    cxtxtdt3: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxtxtdt4: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    EditEnd1: TcxTimeEdit;
    dxLayout1Item9: TdxLayoutItem;
    dxLayout1Item4: TdxLayoutItem;
    EditStart1: TcxTimeEdit;
    btnOK1: TBitBtn;
    dxLayout1Item6: TdxLayoutItem;
    EditStart2: TcxTimeEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditEnd2: TcxTimeEdit;
    dxLayout1Item8: TdxLayoutItem;
    btnOK2: TBitBtn;
    dxLayout1Item10: TdxLayoutItem;
    EditDate: TcxDateEdit;
    dxLayout1Item11: TdxLayoutItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure mniN1Click(Sender: TObject);
    procedure btnOK1Click(Sender: TObject);
    procedure btnOK2Click(Sender: TObject);
  private
    procedure SaveGroupTmp;
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FJBWhere: string;
    //交班条件
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

class function TfFrameSaletunnelQuery.FrameID: integer;
begin
  Result := cFI_FrameSaletunnelQuery;
end;

procedure TfFrameSaletunnelQuery.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  EditDate.Date := Now;

  SaveGroupTmp;
end;

procedure TfFrameSaletunnelQuery.OnDestroyFrame;
begin
  inherited;
end;

function TfFrameSaletunnelQuery.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  FEnableBackDB := True;
  Result := '';

  nStr :=
  ' select L_Value,L_Group, (select G_StockName from S_GroupTmp where G_ID = c.L_Group) G_StockName from ' +
  ' (select SUM(L_Value) L_Value,L_Group from ' +
  ' (select *, (SELECT D_Value  FROM Sys_Dict where D_Memo = a.L_Ladeline) L_Group from ' +
  ' (select SUM(L_Value) L_Value, L_LadeLine from S_Bill where  L_LadeTime >= ''%s'' and L_LadeTime < ''%s''  Group by L_LadeLine) a) b '+
  ' Group by L_Group) c ' ;

  nStr := Format(nStr, [DateTime2Str(FTimeS),DateTime2Str(FTimeE)]);

  Result := nStr;

end;

//Desc: 过滤字段
function TfFrameSaletunnelQuery.FilterColumnField: string;
begin
  //
end;

//Desc: 日期筛选
procedure TfFrameSaletunnelQuery.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
   //
end;

//Desc: 执行查询
procedure TfFrameSaletunnelQuery.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  //
end;

//Desc: 交接班查询
procedure TfFrameSaletunnelQuery.mniN1Click(Sender: TObject);
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

procedure TfFrameSaletunnelQuery.btnOK1Click(Sender: TObject);
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(EditDate.Date,True)+' '+EditStart1.Text);
  FTimeE := Str2DateTime(Date2Str(EditDate.Date,True)+' '+EditEnd1.Text);
  InitFormDataSQL('');
  InitFormData('');
end;

procedure TfFrameSaletunnelQuery.btnOK2Click(Sender: TObject);
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(EditDate.Date,True)+' '+EditStart2.Text);
  FTimeE := Str2DateTime(Date2Str(EditDate.Date+1,True)+' '+EditEnd2.Text);
  InitFormDataSQL('');
  InitFormData('');
end;

procedure TfFrameSaletunnelQuery.SaveGroupTmp;
var
  nIdx, i : Integer;
  nStr, nSQL  : string;
  aList, bList : TStrings;
begin
  aList := TStringList.Create;
  bList := TStringList.Create;
  try
    nSQL := ' SELECT DISTINCT D_Value FROM  Sys_Dict  WHERE D_Name = ''GroupTunnel'' ';
    with FDM.QueryTemp(nSQL) do
    begin
      if RecordCount > 0 then
      begin
        nIdx := 0;
        First;

        while not Eof do
        begin
          aList.Values[IntToStr(nIdx)] := FieldByName('D_Value').AsString;
          Next;
          Inc(nIdx);
        end;
      end;
    end;

    for i := 0 to aList.Count - 1 do
    begin
      bList.Values[aList.values[IntToStr(i)]] := '';
      nSQL := ' Select distinct D_Value, (Select Z_Stock from S_ZTLines where Z_ID = a.D_Memo) D_Name '+
              ' from sys_dict a where D_Name = ''GroupTunnel'' and D_Value = ''%s'' ';
      nSQL := Format(nSQL, [aList.values[IntToStr(i)]]);

      with FDM.QueryTemp(nSQL) do
      begin
        if RecordCount > 0 then
        begin
          First;

          while not Eof do
          begin
            bList.Values[aList.values[IntToStr(i)]] := bList.Values[aList.values[IntToStr(i)]] +','+ FieldByName('D_Name').AsString;
            Next;
          end;
        end;
      end;
    end;

    nSQL := ' Delete From S_GroupTmp ';
    FDM.ExecuteSQL(nSQL);
    for i := 0 to aList.Count - 1 do
    begin
      nSQL := ' insert into S_GroupTmp (G_ID,G_StockName) values (''%s'',''%s'') ';
      nSQL := Format(nSQL, [aList.Values[IntToStr(i)], Copy(bList.Values[aList.Values[IntToStr(i)]],2,MaxInt)]);
      FDM.ExecuteSQL(nSQL);
    end;
  finally
    aList.Free;
    bList.Free;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameSaletunnelQuery, TfFrameSaletunnelQuery.FrameID);
end.
