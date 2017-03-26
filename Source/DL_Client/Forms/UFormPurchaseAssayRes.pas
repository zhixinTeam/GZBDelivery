{*******************************************************************************
  作者: 289525016@163.com 2017/3/16
  描述: 录入化验结果并自动扣重
*******************************************************************************}
unit UFormPurchaseAssayRes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, dxLayoutControl, StdCtrls, cxControls,
  ComCtrls, cxListView, cxButtonEdit, cxLabel, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinBlack, dxSkinBlue,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy,
  dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  dxSkinscxPCPainter, dxLayoutcxEditAdapters, Grids;

type
  TPurchaseContractDtlInfo = record
    Fquota_name:string;
    Fquota_condition:string;
    Fquota_value:Double;
    Fpunish_condition:string;
    Fpunish_Basis:Double;
    Fpunish_standard:Double;
    Fpunish_mode:Integer;
  end;

  TPurchaseContractDtlInfos = array of TPurchaseContractDtlInfo;
  
  TfFormPurchaseAssayRes = class(TfFormNormal)
    EditProvider: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    EditMate: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    SGRes: TStringGrid;
    dxLayout1Item4: TdxLayoutItem;
    EditpunishRes: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    Btnpunish: TButton;
    dxLayout1Item8: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure SGResSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure BtnpunishClick(Sender: TObject);
  private
    { Private declarations }
    FCommand:Integer;
    Fpcid:string;//合同编号
    Fprovider_name:string;
    Fmateriel_name:string;
    FD_ID:string;//采购明细号
    FNetWeight:Double;
    FContractPrice:Double;
    FContractDtlItems: TPurchaseContractDtlInfos;
    FAssayResults:TStrings;//化验结果数据
    procedure InitUI;
    function CalcAutoPunish:Boolean;
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

class function TfFormPurchaseAssayRes.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormPurchaseAssayRes.Create(Application) do
  begin
    Btnpunish.Visible := False;
    FAssayResults := TStringList.Create;
    Caption := '录入原材料化验结果';
    FCommand := nP.FCommand;
    EditProvider.Enabled := False;
    EditMate.Enabled := False;
    if FCommand=cCmd_ViewData then
    begin
      SGRes.Options := SGRes.Options+[goColSizing];
    end
    else begin
      SGRes.Options := SGRes.Options+[goColSizing,goEditing];
    end;

    with TStringList.Create do
    begin
      Text := nPopedom;
      Fpcid := Values['pcid'];
      Fprovider_name := Values['provider_name'];
      Fmateriel_name := Values['con_materiel_name'];
      FNetWeight := StrToFloat(Values['NetWeight']);
      FD_ID := Values['DID'];
    end;

    SetLength(FContractDtlItems, 0);
    InitUI;
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    FAssayResults.Free;
    Free;
  end;
end;

class function TfFormPurchaseAssayRes.FormID: integer;
begin
  Result := cFI_FormPurchaseAssayRes;
end;

procedure TfFormPurchaseAssayRes.BtnOKClick(Sender: TObject);
var
  nStr:string;
  nIdx:Integer;
  nquota_name:string;
  nAssayRes:Double;
  nSum:Double;
begin
  if FCommand=cCmd_ViewData then
  begin
    ModalResult := mrOk;
    Exit;
  end;
  if not CalcAutoPunish then Exit;
  nSum := StrToFloatDef(EditpunishRes.Text,0);
  if nSum>0.001 then
  begin
    nStr := '系统计算的自动扣重为：%f,是否继续保存？';
    nStr := Format(nStr,[nSum]);
    if not QueryDlg(nStr,sHint) then Exit;
  end;

  try
    //保存化验结果
    for nIdx := 1 to SGRes.RowCount-1 do
    begin
      nquota_name := SGRes.Cells[1,nIdx];
      nAssayRes := StrToFloat(SGRes.Cells[4,nIdx])/100;

      nStr := MakeSQLByStr([SF('D_ID', FD_ID),
              SF('quota_name', nquota_name),
              SF('AssayRes', nAssayRes,sfVal),
              SF('pas_Man', gSysParam.FUserName),
              SF('pas_Date', sField_SQLServer_Now, sfVal)
              ], sTable_PurchaseAssayResult, '', True);
      FDM.ExecuteSQL(nStr);
    end;

    //保存扣重结果
    nStr := MakeSQLByStr([SF('D_KZValue',nSum,sfVal)],
        sTable_OrderDtl,'D_ID='''+FD_ID+'''',False);
    FDM.ExecuteSQL(nStr);

    //计算合同已完成量
    nSum := 0;
    nStr := 'select isnull(sum((D_MValue-D_PValue-D_KZValue)),0) as D_NetWeight'
      +' from %s where D_OID in (select O_ID from %s'
      +' where pcid=''%s'')';
    nStr := Format(nStr,[sTable_OrderDtl,sTable_Order,Fpcid]);
    with fdm.QueryTemp(nStr) do
    begin
      if RecordCount>0 then
      begin
        nSum := FieldByName('D_NetWeight').AsFloat;
      end;
    end;

    nStr := 'update %s set con_finished_quantity=%f where pcid=''%s''';
    nStr := Format(nStr,[sTable_PurchaseContract,nSum,Fpcid]);
    FDM.ExecuteSQL(nStr);
    ModalResult := mrOk;
  except
    ShowMsg('数据库操作发送错误！',sHint);
  end;
end;

procedure TfFormPurchaseAssayRes.InitUI;
var
  nStr:string;
  nIdx:integer;
  nName,nvalue:string;
begin
  if FCommand=cCmd_ViewData then
  begin
    nStr := 'select * from %s where D_ID=''%s''';
    nStr := Format(nStr,[sTable_PurchaseAssayResult,FD_ID]);
    with fdm.QueryTemp(nStr) do
    begin
      while not Eof do
      begin
        nName := FieldByName('quota_name').AsString;
        nValue := FloatToStr(FieldByName('AssayRes').AsFloat*100);
        FAssayResults.Values[nName] := nValue;
        Next;
      end;
    end;
  end;
  SGRes.Cells[0,0] := '行号';
  SGRes.Cells[1,0] := '指标名';
  SGRes.Cells[2,0] := '条件';
  SGRes.Cells[3,0] := '标准值(%)';
  SGRes.Cells[4,0] := '化验值(%)';
  EditProvider.Text := Fprovider_name;
  EditMate.Text := Fmateriel_name;
  nStr := 'select * from %s where pcid=''%s''';
  nStr := Format(nStr,[sTable_PurchaseContract,Fpcid]);
  with fdm.QueryTemp(nStr) do
  begin
    FContractPrice := FieldByName('con_price').AsFloat;
  end;
  
  nStr := 'select * from %s where pcid=''%s''';
  nStr := Format(nStr,[sTable_PurchaseContractDetail,Fpcid]);
  with fdm.QueryTemp(nStr) do
  begin
    SetLength(FContractDtlItems, RecordCount);
    if RecordCount>=2 then
    begin
      SGRes.RowCount := RecordCount+1;
    end;
    nIdx := Low(FContractDtlItems);
    while not Eof do
    begin
      with FContractDtlItems[nIdx] do
      begin
        Fquota_name := FieldByName('quota_name').AsString;
        Fquota_condition := FieldByName('quota_condition').AsString;
        Fquota_value := FieldByName('quota_value').AsFloat*100;
        Fpunish_condition := FieldByName('punish_condition').AsString;
        Fpunish_Basis := FieldByName('punish_Basis').AsFloat*100;
        Fpunish_standard := FieldByName('punish_standard').AsFloat;
        Fpunish_mode := FieldByName('punish_mode').AsInteger;

        SGRes.Cells[0,nIdx+1] := IntToStr(nIdx+1);
        SGRes.Cells[1,nIdx+1] := Fquota_name;
        SGRes.Cells[2,nIdx+1] := Fquota_condition;
        SGRes.Cells[3,nIdx+1] := FloatToStr(Fquota_value);
        if FAssayResults.IndexOfName(Fquota_name)=-1 then
        begin
          SGRes.Cells[4,nIdx+1] := FloatToStr(Fquota_value);
        end
        else begin
          SGRes.Cells[4,nIdx+1] := FAssayResults.Values[Fquota_name];
        end;
      end;
      
      Inc(nIdx);
      Next;
    end;
  end;
end;

procedure TfFormPurchaseAssayRes.SGResSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if ACol<4 then CanSelect := False;
end;

procedure TfFormPurchaseAssayRes.BtnpunishClick(Sender: TObject);
begin
  CalcAutoPunish;
end;

function TfFormPurchaseAssayRes.CalcAutoPunish:Boolean;
var
  nIdx:integer;
  nStr:string;
  nquota_value:Double;
  nAssayRes:Double;
  npunishSum:Double;
  ndiff:Double;
  npunish_Condition:string;
  npunish_Basis:Double; //扣重依据,每小于标准1%或5%扣重X
  npunish_standard:Double; //扣重标准，0.1吨或0.5元
  npunish_mode:Integer; //扣重模式，0为重量，1为单价
begin
  Result := False;
  npunishSum := 0;
  for nIdx := 1 to SGRes.RowCount-1 do
  begin
    npunish_Condition := FContractDtlItems[nIdx-1].Fpunish_condition;
    npunish_Basis := FContractDtlItems[nIdx-1].Fpunish_Basis;
    npunish_standard := FContractDtlItems[nIdx-1].Fpunish_standard;
    npunish_mode := FContractDtlItems[nIdx-1].Fpunish_mode;
    nquota_value := StrToFloatDef(SGRes.Cells[3,nIdx],0);

    nStr := SGRes.Cells[4,nIdx];
    nAssayRes := StrToFloatDef(nStr,0);
    if nAssayRes=0 then
    begin
      nStr := '第 %d 行化验值录入有误,请检查';
      nStr := Format(nStr,[nIdx]);
      ShowMsg(nStr,sHint);
      Exit;
    end;

    //化验值与标准值一致
    if abs(nquota_value-nAssayRes)<0.00001 then
    begin
      Continue;
    end;

    if (npunish_Condition='<') and (nAssayRes-nquota_value>0.00001) then Continue;
    if (npunish_Condition='>') and (nquota_value-nAssayRes>0.00001) then Continue;


    ndiff := Abs(nquota_value-nAssayRes);
    //扣重量

    if npunish_mode=0 then
    begin
      //本次扣重=(差额/扣重依据)*扣重标准
      npunishSum := npunishSum+(npunish_standard*ndiff/npunish_Basis);
    end
    //扣单价
    else if npunish_mode=1 then
    begin
      //本次扣重=(差额/扣重依据)*净重/合同单价
      npunishSum := npunishSum+ npunish_standard*ndiff*FNetweight/FcontractPrice;
    end;
  end;
  EditpunishRes.Text := FloatToStr(npunishSum);
  Result := True;
end;

initialization
  gControlManager.RegCtrl(TfFormPurchaseAssayRes, TfFormPurchaseAssayRes.FormID);
end.
