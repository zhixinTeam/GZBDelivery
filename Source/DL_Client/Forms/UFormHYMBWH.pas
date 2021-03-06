{*******************************************************************************
  作者: dmzn@163.com 2010-3-16
  描述: 开化验单
*******************************************************************************}
unit UFormHYMBWH;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxDropDownEdit,
  cxCalendar, cxButtonEdit, cxMaskEdit, cxTextEdit, dxLayoutControl,
  StdCtrls;

type
  TfFormHYMBWH = class(TfFormNormal)
    EditCustom: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    EditStockName: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditStockNameEx: TcxComboBox;
    dxLayout1Item5: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCustomKeyPress(Sender: TObject; var Key: Char);
    procedure EditSManPropertiesEditValueChanged(Sender: TObject);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure EditCustomPropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FSelectVal: Double;
    //选中量
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    procedure GetSaveSQLList(const nList: TStrings); override;
    procedure AfterSaveData(var nDefault: Boolean); override;
    //验证数据
    procedure InitFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UAdjustForm, UFormBase, UMgrControl,
  UDataModule, USysBusiness, USysDB, USysConst;

class function TfFormHYMBWH.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  nP := nParam;

  with TfFormHYMBWH.Create(Application) do
  try
    Caption := '新增模板';
    InitFormData('');

    if Assigned(nP) then
    begin
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormHYMBWH.FormID: integer;
begin
  Result := cFI_FormHYMBWH;
end;

procedure TfFormHYMBWH.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormHYMBWH.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  Action := caFree;
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
//Desc: 初始化解面
procedure TfFormHYMBWH.InitFormData(const nID: string);
var nStr : string;
begin

  if EditCustom.Properties.Items.Count < 1 then
  begin
    nStr := ' Select C_ID+'';''+C_Name as S_Name  From %s ';
    nStr := Format(nStr, [sTable_Customer]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        EditCustom.Properties.Items.Add(FieldByName('S_Name').AsString);
        Next;
      end;
    end;
  end;

  if EditStockName.Properties.Items.Count < 1 then
  begin
    nStr := ' Select D_ParamB+'';''+D_Value as S_Name  From %s where D_Name = ''StockItem'' ';
    nStr := Format(nStr, [sTable_SysDict]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        EditStockName.Properties.Items.Add(FieldByName('S_Name').AsString);
        Next;
      end;
    end;
  end;

  if EditStockNameEx.Properties.Items.Count < 1 then
  begin
    nStr := ' Select D_ParamB+'';''+D_Value as S_Name  From %s where D_Name = ''StockItem'' ';
    nStr := Format(nStr, [sTable_SysDict]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        EditStockNameEx.Properties.Items.Add(FieldByName('S_Name').AsString);
        Next;
      end;
    end;
  end;
end;

//Desc: 选择客户
procedure TfFormHYMBWH.EditCustomKeyPress(Sender: TObject; var Key: Char);
var nStr: string;
    nP: TFormCommandParam;
begin
//  if Key = Char(VK_SPACE) then
//  begin
//    Key := #0;
//    nP.FParamA := GetCtrlData(EditCustom);
//    
//    if nP.FParamA = '' then
//      nP.FParamA := EditCustom.Text;
//    //xxxxx
//
//    CreateBaseFormItem(cFI_FormGetCustom, '', @nP);
//    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
//
//    SetCtrlData(EditCustom, nP.FParamB);
//    
//    if EditCustom.ItemIndex < 0 then
//    begin
//      nStr := Format('%s=%s.%s', [nP.FParamB, nP.FParamB, nP.FParamC]);
//      EditCustom.ItemIndex := InsertStringsItem(EditCustom.Properties.Items, nStr);
//    end;
//  end;
end;

//Desc: 选择车辆
procedure TfFormHYMBWH.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  //
end;

//Desc: 业务员变更,选择客户
procedure TfFormHYMBWH.EditSManPropertiesEditValueChanged(Sender: TObject);
begin
end;

//Desc: 选择水泥编号
function TfFormHYMBWH.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal,nMax: Double;
begin
  Result := True;

  if Sender = EditCustom then
  begin
    Result := Pos(';',EditCustom.Text)>0;
    nHint := '请选择有效的客户';
  end else
  
  if Sender = EditStockName then
  begin
    Result := EditStockName.ItemIndex > -1;
    nHint := '请选择有效的品种名称';
  end else

  if Sender = EditStockNameEx then
  begin
    Result :=  EditStockNameEx.ItemIndex > -1;
    nHint := '请选择有效的模板品种名称';
  end else

  if EditStockName.Text = EditStockNameEx.Text then
  begin
    Result :=  False;
    nHint := '品种名称与模板品种名称相同,请重新选择';
  end;
end;

//Desc: 保存SQL
procedure TfFormHYMBWH.GetSaveSQLList(const nList: TStrings);
var
  nStr: string;
  nCusID,nCusName,nStockNo,nStockName,nStockNoEx,nStockNameEx:string;

  function GetLeftStr(SubStr, Str: string): string;
  begin
    Result := Copy(Str, 1, Pos(SubStr, Str) - 1);
  end;
  function GetRightStr(SubStr, Str: string): string;
  var
     i: integer;
  begin
     i := pos(SubStr, Str);
     if i > 0 then
       Result := Copy(Str
         , i + Length(SubStr)
         , Length(Str) - i - Length(SubStr) + 1)
     else
       Result := '';
  end;
begin
  nCusID       := GetLeftStr(';', EditCustom.Text);
  nCusName     := GetRightStr(';', EditCustom.Text);
  nStockNo     := GetLeftStr(';', EditStockName.Text);
  nStockName   := GetRightStr(';', EditStockName.Text);
  nStockNoEx   := GetLeftStr(';', EditStockNameEx.Text);
  nStockNameEx := GetRightStr(';', EditStockNameEx.Text);

  nStr := ' insert into S_HYMBWH(S_CusID,S_CusName,S_StockNo,S_StockName,S_StockNoEx,S_StockNameEx) ' +
          ' Values(''%s'',''%s'',''%s'',''%s'',''%s'',''%s'') ';

  nStr := Format(nStr,[nCusID,nCusName,nStockNo,nStockName,nStockNoEx,nStockNameEx]);

  nList.Add(nStr);
end;

//Desc: 打印化验单
procedure TfFormHYMBWH.AfterSaveData(var nDefault: Boolean);
begin
  //
end;

procedure TfFormHYMBWH.EditCustomPropertiesChange(Sender: TObject);
var nStr : string;
begin
  inherited;
  EditCustom.DoubleBuffered := True;
  
  if Length(Trim(EditCustom.Text)) >= 6 then
  begin
    EditCustom.Properties.Items.Clear;
    if EditCustom.Properties.Items.Count < 1 then
    begin
      nStr := ' Select C_ID+'';''+C_Name as S_Name From %s where (C_ID like ''%%%s%%'') or (C_Name like ''%%%s%%'') ';
      nStr := Format(nStr, [sTable_Customer,Trim(EditCustom.Text),Trim(EditCustom.Text)]);

      with FDM.QueryTemp(nStr) do
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          EditCustom.Properties.Items.Add(FieldByName('S_Name').AsString);
          Next;
        end;
      end;
    end;
  end
  else
  begin
    if EditCustom.Properties.Items.Count < 1 then
    begin
      nStr := ' Select C_ID+'';''+C_Name as S_Name From %s ';
      nStr := Format(nStr, [sTable_Customer]);

      with FDM.QueryTemp(nStr) do
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          EditCustom.Properties.Items.Add(FieldByName('S_Name').AsString);
          Next;
        end;
      end;
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormHYMBWH, TfFormHYMBWH.FormID);
end.
