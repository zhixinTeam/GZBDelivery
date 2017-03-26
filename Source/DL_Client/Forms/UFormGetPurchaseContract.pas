{*******************************************************************************
  作者: 289525016@163.com 2017/3/16
  描述: 选择采购合同
*******************************************************************************}
unit UFormGetPurchaseContract;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, dxLayoutControl, StdCtrls, cxControls,
  ComCtrls, cxListView, cxButtonEdit, cxLabel, cxLookAndFeels,
  cxLookAndFeelPainters;

type
  TPurchaseContractInfo = record
    FID :string;

    Fprovider_code: string;
    Fprovider_name: string;

    Fmateriel_Code: string;
    Fmateriel_name: string;

    Fprice:Double;
    FRemainQuantity:Double;
    FRemark:string;
  end;
  TPurchaseContractInfos = array of TPurchaseContractInfo;

  TfFormGetPurchaseContract = class(TfFormNormal)
    EditProvider: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    ListQuery: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    EditMate: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListQueryKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListQueryDblClick(Sender: TObject);
  private
    { Private declarations }
    FResults: TStrings;
    //查询类型
    FContractData: string;
    //申请单信息
    FContractItems: TPurchaseContractInfos;
    function QueryData(const nQueryType: string=''): Boolean;
    //查询数据
    procedure GetResult;
    //获取结果
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UFormCtrl, UFormBase, USysGrid, USysDB, 
  USysConst, UDataModule, UBusinessPacker;

class function TfFormGetPurchaseContract.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetPurchaseContract.Create(Application) do
  begin
    Caption := '选择合同单';
    FResults.Clear;
    SetLength(FContractItems, 0);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
    begin
      nP.FParamB := PackerEncodeStr(FContractData);
    end;
    Free;
  end;
end;

class function TfFormGetPurchaseContract.FormID: integer;
begin
  Result := cFI_FormGetPurchaseContract;
end;

procedure TfFormGetPurchaseContract.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListQuery, nIni);
  finally
    nIni.Free;
  end;

  FResults := TStringList.Create;
end;

procedure TfFormGetPurchaseContract.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListQuery, nIni);
  finally
    nIni.Free;
  end;

  FResults.Free;
end;

//------------------------------------------------------------------------------
//Date: 2015-01-22
//Desc: 按指定类型查询
function TfFormGetPurchaseContract.QueryData(const nQueryType: string=''): Boolean;
var nStr, nQuery: string;
    nIdx: Integer;
begin
  Result := False;
  ListQuery.Items.Clear;

  nStr := 'Select *,con_quantity-con_finished_quantity as con_remain_quantity From %s where con_status>0';
  if nQueryType = '1' then //供应商
  begin
    nQuery := Trim(EditProvider.Text);
    nStr := nStr+' and (provider_code like ''%s'' or provider_name like ''%s'')';
  end
  else if nQueryType = '2' then //原材料
  begin
    nQuery := Trim(EditMate.Text);
    nStr := nStr+' and (con_materiel_Code like ''%s'' or con_materiel_name like ''%s'')';
  end
  else exit;

  nStr := Format(nStr,[sTable_PurchaseContract,'%'+nQuery+'%','%'+nQuery+'%']);

  with FDM.QueryTemp(nStr) do
  begin
    SetLength(FContractItems, RecordCount);
     nIdx := Low(FContractItems);
     
    while not Eof do
    begin
      with FContractItems[nIdx] do
      begin
        Fid := FieldByName('pcId').AsString;
        Fprovider_code := FieldByName('provider_code').AsString;
        Fprovider_name := FieldByName('provider_name').AsString;

        Fmateriel_Code := FieldByName('con_materiel_Code').AsString;
        Fmateriel_name := FieldByName('con_materiel_name').AsString;

        Fprice := FieldByName('con_price').AsFloat;
        FRemainQuantity := FieldByName('con_remain_quantity').AsFloat;
        FRemark := FieldByName('con_remark').AsString;

        with ListQuery.Items.Add do
        begin
          Caption := FID;
          SubItems.Add(Fmateriel_name);
          SubItems.Add(Fprovider_name);
          SubItems.Add(FloatToStr(Fprice));
          SubItems.Add(FloatToStr(FRemainQuantity));
          SubItems.Add(FRemark);
          ImageIndex := cItemIconIndex;
        end;
      end;

      Inc(nIdx);
      Next;
    end;

    ListQuery.ItemIndex := 0;
    Result := True;
  end;
end;

procedure TfFormGetPurchaseContract.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nQueryType: string;
begin
  if Sender = EditProvider then
       nQueryType := '1'
  else nQueryType := '2';

  if QueryData(nQueryType) then ListQuery.SetFocus;
end;

//Desc: 获取结果
procedure TfFormGetPurchaseContract.GetResult;
var nIdx: Integer;
begin
  with ListQuery.Selected do
  begin
    for nIdx:=Low(FcontractItems) to High(FcontractItems) do
    with FcontractItems[nIdx], FResults do
    begin
      if CompareText(FID, Caption)=0 then
      begin
        Values['SQ_ID']       := FID;
        Values['SQ_ProID']    := Fprovider_code;
        Values['SQ_ProName']  := Fprovider_name;
        Values['SQ_SaleID']   := '';
        Values['SQ_SaleName'] := '';
        Values['SQ_StockNO']  := Fmateriel_Code;
        Values['SQ_StockName']:= Fmateriel_name;
        Values['SQ_Area']     := '';
        Values['SQ_Project']  := '';
        Values['SQ_RestValue']:= FloatToStr(FRemainQuantity);
        Break;
      end;
    end;  
  end;

  FContractData := FResults.Text;
end;

procedure TfFormGetPurchaseContract.ListQueryKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if ListQuery.ItemIndex > -1 then
    begin
      GetResult;
      ModalResult := mrOk;
    end;
  end;
end;

procedure TfFormGetPurchaseContract.ListQueryDblClick(Sender: TObject);
begin
  if ListQuery.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end;
end;

procedure TfFormGetPurchaseContract.BtnOKClick(Sender: TObject);
begin
  if ListQuery.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end else ShowMsg('请在查询结果中选择', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormGetPurchaseContract, TfFormGetPurchaseContract.FormID);
end.
