{*******************************************************************************
  作者: fendou116688@163.com 2017/6/6
  描述: 倒运明细
*******************************************************************************}
unit UFormTransDetail;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, UFormBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutControl, cxCheckBox,
  cxLabel, StdCtrls, cxMaskEdit, cxDropDownEdit, cxMCListBox, cxMemo,
  cxTextEdit;

type
  TfFormTransDetail = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    EditMemo: TcxMemo;
    dxLayoutControl1Item4: TdxLayoutItem;
    BtnOK: TButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group5: TdxLayoutGroup;
    EditTruck: TcxTextEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditSrc: TcxTextEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    EditDest: TcxTextEdit;
    dxLayoutControl1Item5: TdxLayoutItem;
    EditMName: TcxTextEdit;
    dxLayoutControl1Item6: TdxLayoutItem;
    EditPValue: TcxTextEdit;
    dxLayoutControl1Item7: TdxLayoutItem;
    EditMValue: TcxTextEdit;
    dxLayoutControl1Item8: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayoutControl1Item9: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditMValuePropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
    FTID: string;
    //客户标识
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
  IniFiles, ULibFun, UMgrControl, UFormCtrl, UAdjustForm, USysBusiness,
  USysGrid, USysDB, USysConst;

var
  gForm: TfFormTransDetail = nil;
  //全局使用

class function TfFormTransDetail.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
   cCmd_AddData:
    with TfFormTransDetail.Create(Application) do
    begin
      FTID := '';
      Caption := '倒运明细 - 添加';

      InitFormData('');
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_EditData:
    with TfFormTransDetail.Create(Application) do
    begin
      FTID := nP.FParamA;
      Caption := '倒运明细 - 修改';

      InitFormData(FTID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_ViewData:
    begin
      if not Assigned(gForm) then
      begin
        gForm := TfFormTransDetail.Create(Application);
        with gForm do
        begin
          Caption := '倒运明细 - 查看';
          FormStyle := fsStayOnTop;

          BtnOK.Visible := False;
        end;
      end;

      with gForm  do
      begin
        FTID := nP.FParamA;
        InitFormData(FTID);
        if not Showing then Show;
      end;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end; 
end;

class function TfFormTransDetail.FormID: integer;
begin
  Result := cFI_FormTransDetail;
end;

//------------------------------------------------------------------------------
procedure TfFormTransDetail.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
  ResetHintAllForm(Self, 'T', sTable_Transfer);
  //重置表名称
end;

procedure TfFormTransDetail.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);

  gForm := nil;
  Action := caFree;
end;

procedure TfFormTransDetail.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormTransDetail.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
  begin
    Key := 0; Close;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2009-6-2
//Parm: 供应商编号
//Desc: 载入nID供应商的信息到界面
procedure TfFormTransDetail.InitFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where T_ID=''%s''';
    nStr := Format(nStr, [sTable_Transfer, nID]);
    LoadDataToCtrl(FDM.QueryTemp(nStr), Self, '');
  end;
end;

//Desc: 保存数据
procedure TfFormTransDetail.BtnOKClick(Sender: TObject);
var nList: TStrings;
    nSQL,nStr,nID: string;
begin
  if FTID = '' then
  begin
    nList := TStringList.Create;
    try
      nID := GetSerialNo(sFlag_BusGroup, sFlag_Transfer, False);
      if nID = '' then Exit;
    
      nList.Add(SF('T_ID', nID));
      nList.Add(SF('T_PDate', sField_SQLServer_Now, sfVal));
      nList.Add(SF('T_PMan', gSysParam.FUserID));
      nList.Add(SF('T_MDate', sField_SQLServer_Now, sfVal));
      nList.Add(SF('T_MMan', gSysParam.FUserID));
      nList.Add(SF('T_InTime', sField_SQLServer_Now, sfVal));
      nList.Add(SF('T_InMan', gSysParam.FUserID));
      nList.Add(SF('T_OutFact', sField_SQLServer_Now, sfVal));
      nList.Add(SF('T_OutMan', gSysParam.FUserID));
      nList.Add(SF('T_Status', sFlag_TruckOut));
      nSQL := MakeSQLByForm(Self, sTable_Transfer, '', True, nil, nList);
    finally
      nList.Free;
    end;
  end else
  begin
    nID := FTID;
    nStr := 'T_ID=''' + FTID + '''';
    nSQL := MakeSQLByForm(Self, sTable_Transfer, nStr, False);
  end;

  FDM.ExecuteSQL(nSQL);
  ModalResult := mrOK;
  ShowMsg('数据已保存', sHint);
end;

procedure TfFormTransDetail.EditMValuePropertiesEditValueChanged(
  Sender: TObject);
var nMVal, nPVal, nVal: Double;
begin
  inherited;
  //if (not EditPValue.Focused) and (not EditMValue.Focused) then Exit;

  if not IsNumber(EditPValue.Text, True) then Exit;
  if not IsNumber(EditMValue.Text, True) then Exit;

  nMVal := StrToFloat(EditMValue.Text);
  nPVal := StrToFloat(EditPValue.Text);
  if FloatRelation(nMVal, nPVal, rtLess) then Exit;

  nVal := nMVal - nPVal;
  EditValue.Text := Format('%.2f', [nVal]);
end;

initialization
  gControlManager.RegCtrl(TfFormTransDetail, TfFormTransDetail.FormID);
end.
