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
  private
    { Private declarations }
  protected
    { protected declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
    {*≤È—ØSQL*}
  public
    { Public declarations }
    class function FrameID: Integer; override;
  end;

var
  fFrameCusBatMap: TfFrameCusBatMap;

implementation

{$R *.dfm}

uses USysConst, UMgrControl, USysDB;

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

initialization
  gControlManager.RegCtrl(TfFrameCusBatMap, TfFrameCusBatMap.FrameID);
end.
