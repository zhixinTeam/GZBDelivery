{*******************************************************************************
  ����: dmzn@163.com 2009-6-12
  ����: �����鵥
*******************************************************************************}
unit UFrameHYMBWH;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, UBitmapPanel,
  cxSplitter, Menus, cxLookAndFeels, cxLookAndFeelPainters;

type
  TfFrameHYMBWH = class(TfFrameNormal)
    EditNO: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    PMenu1: TPopupMenu;
    EditID: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //ʱ������
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UFormBase, USysConst, USysDB, UDataModule,
  UFormDateFilter, USysBusiness;

class function TfFrameHYMBWH.FrameID: integer;
begin
  Result := cFI_FrameHYMBWH;
end;

procedure TfFrameHYMBWH.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameHYMBWH.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;                        
end;

//------------------------------------------------------------------------------
//Desc: ���ݲ�ѯSQL
function TfFrameHYMBWH.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  Result := ' Select * From $HY hy ';
  //xxxxx
  if nWhere = '' then
       Result := Result
  else Result := Result + ' Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$HY', sTable_HYMBWH)]);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: ���
procedure TfFrameHYMBWH.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormHYMBWH, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: ɾ��
procedure TfFrameHYMBWH.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('R_ID').AsString;
  if QueryDlg('ȷ��Ҫɾ��ѡ�еļ�¼��', sAsk) then
  begin
    nSQL := 'Delete From %s Where R_ID=%s';
    nSQL := Format(nSQL, [sTable_HYMBWH, nStr]);
    FDM.ExecuteSQL(nSQL);

    InitFormData(FWhere);
    ShowMsg('�ѳɹ�ɾ����¼', sHint);
  end;
end;

//Desc: �鿴����
procedure TfFrameHYMBWH.cxView1DblClick(Sender: TObject);
begin
end;

//Desc: ����ɸѡ
procedure TfFrameHYMBWH.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: ִ�в�ѯ
procedure TfFrameHYMBWH.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := Format('H_ID=%s', [EditID.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditNO then
  begin
    EditNO.Text := Trim(EditNO.Text);
    if EditNO.Text = '' then Exit;

    FWhere := Format('H_SerialNo Like ''%%%s%%''', [EditNO.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: ���鵥
procedure TfFrameHYMBWH.N1Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('H_ID').AsString;
    //PrintHuaYanReport(nStr, False);
  end;
end;

//Desc: �ϸ�֤
procedure TfFrameHYMBWH.N2Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('H_ID').AsString;
    PrintHeGeReport(nStr, False);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameHYMBWH, TfFrameHYMBWH.FrameID);
end.
