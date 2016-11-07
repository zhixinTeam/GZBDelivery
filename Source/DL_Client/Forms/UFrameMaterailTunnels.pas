{*******************************************************************************
  作者: fendou116688@163.com 2016/10/14
  描述: 原材料验收通道设置
*******************************************************************************}
unit UFrameMaterailTunnels;

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
  TfFrameMaterailTunnels = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase,
  UFormCtrl, USysBusiness;

class function TfFrameMaterailTunnels.FrameID: integer;
begin
  Result := cFI_FrameMaterailTunnels;
end;

function TfFrameMaterailTunnels.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From $Dict Where D_Name=''$MT''';
  if nWhere <> '' then
    Result := Result + ' And (' + nWhere + ')';
  Result := Result + ' Order By D_ParamB';

  Result := MacroValue(Result, [MI('$Dict', sTable_SysDict),
            MI('$MT', sFlag_MaterailTunnel)]);
end;

//Desc: 添加
procedure TfFrameMaterailTunnels.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormMaterailTunnel, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameMaterailTunnels.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('D_ID').AsString;
    CreateBaseFormItem(cFI_FormMaterailTunnel, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: 删除
procedure TfFrameMaterailTunnels.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('D_Value').AsString;
    nStr := Format('确定要删除原材料[ %s ]通道吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where D_ID=%s';
    nStr := Format(nStr, [sTable_SysDict, SQLQuery.FieldByName('D_ID').AsString]);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
  end;
end;

//Desc: 查询
procedure TfFrameMaterailTunnels.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit; 

    FWhere := Format('D_Name Like ''%%%s%%'' ' +
              ' or D_Memo Like ''%%%s%%''', [EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameMaterailTunnels, TfFrameMaterailTunnels.FrameID);
end.
