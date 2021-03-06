unit UFrameCusBatMap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxTextEdit, cxMaskEdit,
  cxButtonEdit;

type
  TfFrameCusBatMap = class(TfFrameNormal)
    EditCusName: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditCode: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditCusNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    { protected declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: Integer; override;
  end;

var
  fFrameCusBatMap: TfFrameCusBatMap;

implementation

{$R *.dfm}

uses
  USysConst, UMgrControl, USysDB, ULibFun, 
  UFormCusBatMap, UFormBase, UDataModule;

class function TfFrameCusBatMap.FrameID: Integer;
begin
  Result := cFI_FrameCusBatMap;
end;

function TfFrameCusBatMap.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_YT_CusBatMap;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By R_ID';
end;

procedure TfFrameCusBatMap.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  inherited;
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormCusBatMap, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFrameCusBatMap.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  inherited;
  nP.FCommand := cCmd_EditData;
  nP.FParamA  := SQLQuery.FieldByName('R_ID').AsString;
  CreateBaseFormItem(cFI_FormCusBatMap, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFrameCusBatMap.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := 'ȷ��Ҫɾ�����Ϊ[ %s ]��������?';
  nStr := Format(nStr, [SQLQuery.FieldByName('R_ID').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  nStr := 'Delete From %s Where R_ID=%s';
  nStr := Format(nStr, [sTable_YT_CusBatMap, SQLQuery.FieldByName('R_ID').AsString]);
  FDM.ExecuteSQL(nStr);
  InitFormData('');
end;

procedure TfFrameCusBatMap.EditCusNamePropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  inherited;
  if Sender = EditCode then
  begin
    EditCode.Text := Trim(EditCode.Text);
    if EditCode.Text = '' then Exit;

    FWhere := ' M_StockName like ''%' + EditCode.Text + '%'' ';
    InitFormData(FWhere);
  end else

  if Sender = EditCusName then
  begin
    EditCusName.Text := Trim(EditCusName.Text);
    if EditCusName.Text = '' then Exit;

    FWhere := 'M_CusID like ''%%%s%%'' Or M_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCusName.Text, EditCusName.Text]);
    InitFormData(FWhere);
  end
end;

initialization
  gControlManager.RegCtrl(TfFrameCusBatMap, TfFrameCusBatMap.FrameID);
end.
