{*******************************************************************************
  作者: fendou116688@163.com 2017/4/1
  描述: 待处理事件浏览
*******************************************************************************}
unit UFrameManualEvent;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, cxMaskEdit, cxButtonEdit,
  dxLayoutControl, cxTextEdit, ADODB, cxContainer, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxLookAndFeels, cxLookAndFeelPainters;

type
  TfFrameManualEvent = class(TfFrameNormal)
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit5: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditMan: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditItem: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    procedure EditManPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //时间间隔
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //查询语句
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UFormCtrl, UMgrControl, UFormDateFilter, UFrameBase,
  USysConst, USysDB;

class function TfFrameManualEvent.FrameID: integer;
begin
  Result := cFI_FrameManualEvent;
end;

procedure TfFrameManualEvent.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameManualEvent.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameManualEvent.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  
  Result := 'Select * From %s Where E_Date>=''%s'' And E_Date<''%s''';
  Result := Format(Result, [sTable_ManualEvent, DateToStr(FStart), DateToStr(FEnd+1)]);
  if nWhere <> '' then Result := Result + ' And (' + nWhere + ')';
end;

//Desc: 执行查询
procedure TfFrameManualEvent.EditManPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditMan then
  begin
    EditMan.Text := Trim(EditMan.Text);
    if EditMan.Text = '' then Exit;

    FWhere := 'E_ManDeal like ''%' + EditMan.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditItem then
  begin
    EditItem.Text := Trim(EditItem.Text);
    if EditItem.Text = '' then Exit;

    FWhere := '(E_Key like ''%' + EditItem.Text + '%'') or ' +
              '(E_Event like ''%' + EditItem.Text + '%'')';
    InitFormData(FWhere);
  end;
end;

//Desc: 日期筛选
procedure TfFrameManualEvent.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

initialization
  gControlManager.RegCtrl(TfFrameManualEvent, TfFrameManualEvent.FrameID);
end.
