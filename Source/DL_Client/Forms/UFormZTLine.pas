{*******************************************************************************
  作者: dmzn@163.com 2010-3-14
  描述: 装车线管理
*******************************************************************************}
unit UFormZTLine;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxLabel, cxCheckBox, cxTextEdit, dxLayoutControl, StdCtrls;

type
  TfFormZTLine = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditID: TcxTextEdit;
    LayItem1: TdxLayoutItem;
    EditMax: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    CheckValid: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Group3: TdxLayoutGroup;
    cxLabel2: TcxLabel;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    EditPeer: TcxTextEdit;
    dxLayout1Item19: TdxLayoutItem;
    dxLayout1Item20: TdxLayoutItem;
    cxLabel4: TcxLabel;
    dxLayout1Group9: TdxLayoutGroup;
    EditStockID: TcxComboBox;
    dxLayout1Item21: TdxLayoutItem;
    EditType: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Item22: TdxLayoutItem;
    cxLabel5: TcxLabel;
    dxLayout1Group10: TdxLayoutGroup;
    dxLayout1Group12: TdxLayoutGroup;
    EditLineGroup: TcxComboBox;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item9: TdxLayoutItem;
    dxLayout1Group6: TdxLayoutGroup;
    dxLayout1Group7: TdxLayoutGroup;
    ChkCusLine: TcxCheckBox;
    procedure BtnOKClick(Sender: TObject);
    procedure EditStockIDPropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FID: string;
    //标识
    procedure WriteSysLog(const nID:string);
    //记录操作日志
    procedure InitFormData(const nID: string);
    procedure GetData(Sender: TObject; var nData: string);
    function SetData(Sender: TObject; const nData: string): Boolean;
    //数据处理
  public
    { Public declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

function ShowAddZTLineForm: Boolean;
function ShowEditZTLineForm(const nID: string): Boolean;
//入口函数

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UDataModule, UFormInputbox, USysGrid,
  UFormCtrl, USysDB, USysConst ,USysLoger, USysBusiness, UAdjustForm;

type
  TLineStockItem = record
    FID   : string;
    FName : string;
  end;

  TFormInfoItem = record
    FID       : string;
    FName     : string;
    FGroup    : string;
    FStockID  : string;
    FStockName: string;

    FType     : string;
    FMax      : string;
    FPeer     : string;
  end;

var
  gStockItems: array of TLineStockItem;
  //品种列表
   gCheckValid,gChkCusLine: boolean;
  //通道钩选属性
  gOldInfo: TFormInfoItem;

function ShowAddZTLineForm: Boolean;
begin
  with TfFormZTLine.Create(Application) do
  try
    FID := '';
    Caption := '装车线 - 添加';

    InitFormData('');
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

function ShowEditZTLineForm(const nID: string): Boolean;
begin
  with TfFormZTLine.Create(Application) do
  try
    FID := nID;
    Caption := '装车线 - 修改';

    InitFormData(nID);
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

class function TfFormZTLine.FormID: integer;
begin
  Result := cFI_FormZTLine;
end;

class function TfFormZTLine.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
end;

//------------------------------------------------------------------------------
procedure TfFormZTLine.InitFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  {$IFDEF ZDTD}
  ChkCusLine.Visible := True;
  {$ELSE}
  ChkCusLine.Visible := False;
  {$ENDIF}
  
  ResetHintAllForm(Self, 'T', sTable_ZTLines);
  //重置表名称

  LoadZTLineGroup(EditLineGroup.Properties.Items);
  //载入栈台分组列表
  if EditLineGroup.Properties.Items.Count > 0 then
    EditLineGroup.ItemIndex := 0;

  if nID <> '' then
  begin
    EditID.Properties.ReadOnly := True;
    {$IFDEF GZBZX}
    EditName.Properties.ReadOnly := not gSysParam.FIsAdmin;
    EditStockID.Properties.ReadOnly := not gSysParam.FIsAdmin;
    EditStockName.Properties.ReadOnly := not gSysParam.FIsAdmin;
    EditType.Properties.ReadOnly := not gSysParam.FIsAdmin;
    EditLineGroup.Properties.ReadOnly := not gSysParam.FIsAdmin;
    EditMax.Properties.ReadOnly := not gSysParam.FIsAdmin;
    EditPeer.Properties.ReadOnly := not gSysParam.FIsAdmin;
    {$ENDIF}

    nStr := 'Select * From %s Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZTLines, nID]);

    if FDM.QueryTemp(nStr).RecordCount > 0 then
    begin
      EditStockID.Text := FDM.SqlTemp.FieldByName('Z_StockNo').AsString;
      LoadDataToCtrl(FDM.SqlTemp, Self, '', SetData);

      with gOldInfo do
      begin
        FID     := EditID.Text;
        FName   := EditName.Text;
        FGroup  := GetCtrlData(EditLineGroup);

        FStockID:= EditStockID.Text;
        FStockName:=EditStockName.Text;
        
        FType   := EditType.Text;
        FPeer   := EditPeer.Text;
        FMax    := EditMax.Text;
      end;  
    end;
  end;

  nStr := 'Select D_Value,D_ParamB From %s Where D_Name=''%s'' ' +
          'And D_Index>=0 Order By D_Index DESC';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  EditStockID.Properties.Items.Clear;
  SetLength(gStockItems, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gStockItems, RecordCount);

    nIdx := 0;
    First;

    while not Eof do
    begin
      with gStockItems[nIdx] do
      begin
        FID := Fields[1].AsString;
        FName := Fields[0].AsString;
        EditStockID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
      end;

      Inc(nIdx);
      Next;
    end;
  end;
end;

procedure TfFormZTLine.EditStockIDPropertiesChange(Sender: TObject);
var nIdx: Integer;
begin
  if (not EditStockID.Focused) or (EditStockID.ItemIndex < 0) then Exit;
  nIdx := Integer(EditStockID.Properties.Items.Objects[EditStockID.ItemIndex]);
  EditStockName.Text := gStockItems[nIdx].FName;
end;

function TfFormZTLine.SetData(Sender: TObject; const nData: string): Boolean;
begin
  Result := False;

  if Sender = EditType then
  begin
    Result := True;
    if nData = sFlag_TypeVIP then
      EditType.ItemIndex := 1 else
    if nData = sFlag_TypeZT then
      EditType.ItemIndex := 2 else
    if nData = sFlag_TypeShip then
      EditType.ItemIndex := 3
    else EditType.ItemIndex := 0;
  end else
  
  if Sender = CheckValid then
  begin
    Result := True;
    CheckValid.Checked := nData <> sFlag_No;
  end else

  if Sender = EditLineGroup then
  begin
    Result := True;
    SetCtrlData(EditLineGroup, Trim(nData));
  end;

  if Sender = ChkCusLine then
  begin
    Result := True;
    ChkCusLine.Checked := nData = sFlag_Yes;
  end;
end;

procedure TfFormZTLine.GetData(Sender: TObject; var nData: string);
begin
  if Sender = EditType then
  begin
    case EditType.ItemIndex of
     0: nData := sFlag_TypeCommon;
     1: nData := sFlag_TypeVIP;
     2: nData := sFlag_TypeZT;
     3: nData := sFlag_TypeShip else nData := sFlag_TypeCommon;
    end;
  end else

  if Sender = CheckValid then
  begin
    if CheckValid.Checked   then
    begin
      nData := sFlag_Yes;
      gCheckValid := true;
    end else
    begin
      nData := sFlag_No;
      gCheckValid := false;
    end;
  end;

  if Sender = ChkCusLine then
  begin
    if ChkCusLine.Checked   then
    begin
      nData := sFlag_Yes;
      gChkCusLine := true;
    end else
    begin
      nData := sFlag_No;
      gChkCusLine := false;
    end;
  end;
end;

function TfFormZTLine.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Integer;
begin
  Result := True;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    Result := EditID.Text <> '';
    nHint := '请填写有效编号';
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    Result := EditName.Text <> '';
    nHint := '请填写有效名称';
  end else

  if Sender = EditStockID then
  begin
    Result := EditStockID.ItemIndex >= 0;
    nHint := '请选择品种';
  end else

  if Sender = EditMax then
  begin
    Result := IsNumber(EditMax.Text, False);
    nHint := '队列数为大于零的整数';
    if not Result then Exit;

    nVal := StrToInt(EditMax.Text);
    Result := (nVal > 0) and (nVal <= 50);
    nHint := '队列数在1-50之间'
  end else

  if Sender = EditPeer then
  begin
    Result := IsNumber(EditPeer.Text, False) and (StrToInt(EditPeer.Text) > 0);
    nHint := '袋重为大于0的整数';
    if not Result then Exit;
  end;
end;

procedure TfFormZTLine.WriteSysLog(const nID: string);
var nEvent: string;
begin
  if nID='' then Exit;
  with gOldInfo do
  begin
    if FID<>EditID.Text then
    begin
      nEvent := '通道 [ %s ] 信息由  [ %s ] 变为 [ %s ] ';
      nEvent := Format(nEvent, [EditID.Text, FID, EditID.Text]);
      FDM.WriteSysLog(sFlag_TruckQueue, 'UFromZTline',nEvent);
    end;

    if FName<>EditName.Text then
    begin
      nEvent := '通道 [ %s ] 信息由  [ %s ] 变为 [ %s ] ';
      nEvent := Format(nEvent, [EditID.Text, FName, EditName.Text]);
      FDM.WriteSysLog(sFlag_TruckQueue, 'UFromZTline',nEvent);
    end;

    if FStockName<>EditStockName.Text then
    begin
      nEvent := '通道 [ %s ] 信息由  [ %s ] 变为 [ %s ] ';
      nEvent := Format(nEvent, [EditID.Text, FStockName, EditStockName.Text]);
      FDM.WriteSysLog(sFlag_TruckQueue, 'UFromZTline',nEvent);
    end;

    if FPeer<>EditPeer.Text then
    begin
      nEvent := '通道 [ %s ] 信息由  [ %s ] 变为 [ %s ] ';
      nEvent := Format(nEvent, [EditID.Text, FPeer, EditPeer.Text]);
      FDM.WriteSysLog(sFlag_TruckQueue, 'UFromZTline',nEvent);
    end;

    if FType<>EditType.Text then
    begin
      nEvent := '通道 [ %s ] 信息由  [ %s ] 变为 [ %s ] ';
      nEvent := Format(nEvent, [EditID.Text, FType, EditType.Text]);
      FDM.WriteSysLog(sFlag_TruckQueue, 'UFromZTline',nEvent);
    end;

    if FMax<>EditMax.Text then
    begin
      nEvent := '通道 [ %s ] 信息由  [ %s ] 变为 [ %s ] ';
      nEvent := Format(nEvent, [EditID.Text, FMax, EditMax.Text]);
      FDM.WriteSysLog(sFlag_TruckQueue, 'UFromZTline',nEvent);
    end;

    if FGroup<>GetCtrlData(EditLineGroup) then
    begin
      nEvent := '通道 [ %s ] 信息由  [ %s ] 变为 [ %s ] ';
      nEvent := Format(nEvent, [EditID.Text, FGroup, GetCtrlData(EditLineGroup)]);
      FDM.WriteSysLog(sFlag_TruckQueue, 'UFromZTline',nEvent);
    end;
  end;  
end;

procedure TfFormZTLine.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nList: TStrings;
    nStr,nEvent: string;
begin
  if not IsDataValid then Exit;

  nList := TStringList.Create;
  try
    nIdx := Integer(EditStockID.Properties.Items.Objects[EditStockID.ItemIndex]);
    nList.Add(Format('Z_StockNo=''%s''', [gStockItems[nIdx].FID]));
    //ext fields

    if FID = '' then
    begin
      nStr := MakeSQLByForm(Self, sTable_ZTLines, '', True, GetData, nList);
    end else
    begin
      nStr := Format('Z_ID=''%s''', [FID]);
      nStr := MakeSQLByForm(Self, sTable_ZTLines, nStr, False, GetData, nList);
    end;
  finally
    nList.Free;
  end;

  FDM.ExecuteSQL(nStr);
  ModalResult := mrOk;

  //--------------
  if   gCheckValid = false then
  begin
       nEvent := '通道 [ %s ] 关闭';
       nEvent := Format(nEvent, [EditID.Text]);
       FDM.WriteSysLog(sFlag_TruckQueue, 'UFromZTline', nEvent);
  end;
  if   gCheckValid = true  then
  begin
       nEvent := '通道 [ %s ] 开启';
       nEvent := Format(nEvent, [EditID.Text]);
       FDM.WriteSysLog(sFlag_TruckQueue, 'UFromZTline',nEvent);
  end;
  WriteSysLog(FID);
  //--写入操作通道日志
  ShowMsg('通道已保存,请等待刷新', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormZTLine, TfFormZTLine.FormID);
end.
