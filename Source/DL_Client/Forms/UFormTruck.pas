{*******************************************************************************
  ����: dmzn@163.com 2014-11-25
  ����: ������������
*******************************************************************************}
unit UFormTruck;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxLabel;

type
  TfFormTruck = class(TfFormNormal)
    EditTruck: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditOwner: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditPhone: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    CheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    CheckVerify: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item6: TdxLayoutItem;
    CheckUserP: TcxCheckBox;
    CheckVip: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    CheckGPS: TcxCheckBox;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayout1Item11: TdxLayoutItem;
    EditMValue: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayout1Item13: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    EditPrePValue: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    EditMaxBillNum: TcxTextEdit;
    dxLayout1Item15: TdxLayoutItem;
    EditAxlesNum: TcxTextEdit;
    dxLayout1Item16: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FTruckID: string;
    procedure LoadFormData(const nID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst;

class function TfFormTruck.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormTruck.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '���� - ���';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '���� - �޸�';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormTruck.FormID: integer;
begin
  Result := cFI_FormTrucks;
end;

procedure TfFormTruck.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      CheckVerify.Checked := True;
      CheckValid.Checked := True;
      Exit;
    end;

    EditTruck.Text      := FieldByName('T_Truck').AsString;     
    EditOwner.Text      := FieldByName('T_Owner').AsString;
    EditPhone.Text      := FieldByName('T_Phone').AsString;
    EditMValue.Text     := FieldByName('T_MValueMax').AsString;
    EditMaxBillNum.Text := FieldByName('T_MaxBillNum').AsString;
    EditAxlesNum.Text   := FieldByName('T_AxlesNum').AsString;
    EditPrePValue.Text  := FloatToStr(FieldByName('T_PrePValue').AsFloat);

    CheckVerify.Checked := FieldByName('T_NoVerify').AsString = sFlag_No;
    CheckValid.Checked := FieldByName('T_Valid').AsString = sFlag_Yes;
    CheckUserP.Checked := FieldByName('T_PrePUse').AsString = sFlag_Yes;

    CheckVip.Checked   := FieldByName('T_VIPTruck').AsString = sFlag_TypeVIP;
    CheckGPS.Checked   := FieldByName('T_HasGPS').AsString = sFlag_Yes;
  end;
end;

//Desc: ����
procedure TfFormTruck.BtnOKClick(Sender: TObject);
var
  nPreNum: Double;
  nStr,nTruck,nU,nV,nP,nVip,nGps,nEvent: string;
begin
  nTruck := UpperCase(Trim(EditTruck.Text));
  if nTruck = '' then
  begin
    ActiveControl := EditTruck;
    ShowMsg('�����복�ƺ���', sHint);
    Exit;
  end;

  if FTruckID = '' then
  begin
    nStr := ' select T_Truck from %s where T_Truck=''%s''';
    nStr := Format(nStr,[sTable_Truck, nTruck]);
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount>0 then
      begin
        ActiveControl := EditTruck;
        ShowMsg('�Ѵ��ڴ˳��ƺ���', sHint);
        Exit;
      end;
    end;
  end;

  if CheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if CheckVerify.Checked then
       nU := sFlag_No
  else nU := sFlag_Yes;

  if CheckUserP.Checked then
       nP := sFlag_Yes
  else nP := sFlag_No;

  if nP = sFlag_Yes then
  begin
    nPreNum := StrToFloatDef(EditPrePValue.Text,0);
    if nPreNum <= 0  then
    begin
      ShowMsg('Ԥ��Ƥ��ֵ��Ҫ������', sHint);
      Exit;
    end;
  end;

  if CheckVip.Checked then
       nVip:=sFlag_TypeVIP
  else nVip:=sFlag_TypeCommon;

  if CheckGPS.Checked then
       nGps := sFlag_Yes
  else nGps := sFlag_No;

  if FTruckID = '' then
       nStr := ''
  else nStr := SF('R_ID', FTruckID, sfVal);

  nStr := MakeSQLByStr([SF('T_Truck', nTruck),
          SF('T_Owner', EditOwner.Text),
          SF('T_Phone', EditPhone.Text),
          SF('T_MValueMax', EditMValue.Text, sfVal),
          SF('T_MaxBillNum', EditMaxBillNum.Text, sfVal),
          SF('T_AxlesNum', EditAxlesNum.Text),
          SF('T_NoVerify', nU),
          SF('T_Valid', nV),
          SF('T_PrePUse', nP),
          SF('T_VIPTruck', nVip),
          SF('T_HasGPS', nGps),
          SF('T_PrePValue', FloatToStr(nPreNum),sfVal),
          SF('T_LastTime', sField_SQLServer_Now, sfVal)
          ], sTable_Truck, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  if FTruckID='' then
        nEvent := '���[ %s ]������Ϣ.'
  else  nEvent := '�޸�[ %s ]������Ϣ.';
  nEvent := Format(nEvent, [nTruck]);
  FDM.WriteSysLog(sFlag_CommonItem, nTruck, nEvent);


  ModalResult := mrOk;
  ShowMsg('������Ϣ����ɹ�', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormTruck, TfFormTruck.FormID);
end.
