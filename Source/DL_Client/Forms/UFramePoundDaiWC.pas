unit UFramePoundDaiWC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxTextEdit;

type
  TfFramePoundDaiWC = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
  protected
    { protected declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFramePoundDaiWC: TfFramePoundDaiWC;

implementation

{$R *.dfm}

uses
  USysConst, USysDB, UMgrControl, ULibFun, UDataModule,
  UFormBase, UFormPoundDaiWC;

class function TfFramePoundDaiWC.FrameID: integer;
begin
  Result := cFI_FramePoundDaiWC;
end;

function TfFramePoundDaiWC.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_PoundDaiWC;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By R_ID';
end;

procedure TfFramePoundDaiWC.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  inherited;
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormPoundDaiWC, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFramePoundDaiWC.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  inherited;
  nP.FCommand := cCmd_EditData;
  nP.FParamA  := SQLQuery.FieldByName('R_ID').AsString;
  CreateBaseFormItem(cFI_FormPoundDaiWC, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFramePoundDaiWC.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nStr := '确定要删除编号为[ %s ]的设置吗?';
  nStr := Format(nStr, [SQLQuery.FieldByName('R_ID').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  nStr := 'Delete From %s Where R_ID=%s';
  nStr := Format(nStr, [sTable_PoundDaiWC, SQLQuery.FieldByName('R_ID').AsString]);
  FDM.ExecuteSQL(nStr);
  InitFormData('');
end;

initialization
  gControlManager.RegCtrl(TfFramePoundDaiWC, TfFramePoundDaiWC.FrameID);
end.
