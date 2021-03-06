unit UShowOrderInfo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UAndroidFormBase, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts,
  UMITPacker,UClientWorker,UBusinessConst,USysBusiness,UMainFrom, FMX.ListBox,
  FMX.ComboEdit, Androidapi.JNI.Toast;

type
  TFrmShowOrderInfo = class(TfrmFormBase)
    Label6: TLabel;
    tmrGetOrder: TTimer;
    BtnCancel: TSpeedButton;
    BtnOK: TSpeedButton;
    EditKZValue: TEdit;
    Label10: TLabel;
    Label8: TLabel;
    lblTruck: TLabel;
    lblMate: TLabel;
    Label4: TLabel;
    lblProvider: TLabel;
    lblID: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    EditKZMemo: TComboEdit;
    CheckBox1: TCheckBox;
    Label3: TLabel;
    EditWorkAddr: TComboEdit;
    Label5: TLabel;
    lblMValue: TLabel;
    procedure tmrGetOrderTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gCardNO: string;
  FrmShowOrderInfo: TFrmShowOrderInfo;

implementation
var
  gOrders: TLadingBillItems;

{$R *.fmx}

procedure TFrmShowOrderInfo.BtnCancelClick(Sender: TObject);
begin
  inherited;
  MainForm.Show;
  Self.Hide;
end;

procedure TFrmShowOrderInfo.BtnOKClick(Sender: TObject);
var nYSVaid, nStr: string;
begin
  inherited;
  nStr := Trim(EditKZMemo.Text);
  if CheckBox1.IsChecked then
  begin
    if nStr = '' then
    begin
      ShowMessage('���������ԭ��');
      Exit;
    end;
  end;

  if Length(gOrders)>0 then
  with gOrders[0] do
  begin
    if not UserYSControl(FStockNo) then
    begin
      ShowMessage('�����մ�Ʒ��Ȩ��');
      Exit;
    end;

    if CheckBox1.IsChecked then
    begin
      nYSVaid := 'N';
    end
    else
    begin
      nYSVaid := 'Y';
      nStr := '';
    end;

    FYSValid := nYSVaid;
    FKZValue := StrToFloatDef(EditKZValue.Text, 0);
    FMemo    := EditKZMemo.Text;
    FHKRecord:= Trim(EditWorkAddr.Text);

    if SavePurchaseOrders('X', gOrders) then
    begin
      //Toast('���ձ���ɹ�');
      ShowMessage('���ձ���ɹ�');
      MainForm.Show;
    end;

  end;
end;

procedure TFrmShowOrderInfo.CheckBox1Change(Sender: TObject);
begin
  inherited;
  if CheckBox1.IsChecked then
       Label2.Text := '����ԭ��'
  else Label2.Text := '�ۼ�ԭ��';
end;

procedure TFrmShowOrderInfo.FormActivate(Sender: TObject);
begin
  inherited;
  lblID.Text       := '';
  lblProvider.Text := '';
  lblMate.Text     := '';
  lblTruck.Text    := '';
  EditKZMemo.Text  := '';
  EditKZValue.Text := '0.00';

  tmrGetOrder.Enabled := True;
  SetLength(gOrders, 0);
end;

procedure TFrmShowOrderInfo.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  {if Key = vkHardwareBack then//������������ؼ�
  begin
    MessageDlg('ȷ���˳���', System.UITypes.TMsgDlgType.mtConfirmation,
      [System.UITypes.TMsgDlgBtn.mbOK, System.UITypes.TMsgDlgBtn.mbCancel], -1,

      procedure(const AResult: TModalResult)
      begin
        if AResult = mrOK then BtnCancelClick(Self);
      end
      );
      //�˳�����

    Key := 0;//����ģ���Ȼ����Ҳ���˳�
    Exit;
  end;    }
end;

procedure TFrmShowOrderInfo.FormShow(Sender: TObject);
begin
  inherited;
  lblID.Text       := '';
  lblProvider.Text := '';
  lblMate.Text     := '';
  lblTruck.Text    := '';
  lblMValue.Text   := '';
  EditKZValue.Text := '0.00';

  BtnOK.Enabled := False;
  tmrGetOrder.Enabled := True;
  SetLength(gOrders, 0);
end;

procedure TFrmShowOrderInfo.tmrGetOrderTimer(Sender: TObject);
var nIdx, nInt: Integer;
    nStr : string;
begin
  tmrGetOrder.Enabled := False;

  if not GetPurchaseOrders(gCardNO, 'X', gOrders) then
  begin
    BtnCancelClick(Self);
    Exit;
  end;

  nInt := 0;
  for nIdx := Low(gOrders) to High(gOrders) do
  with gOrders[nIdx] do
  begin
    FSelected := (FNextStatus='X') or (FNextStatus='M');
    if FSelected then Inc(nInt);
  end;

  if nInt<1 then
  begin
    nStr := '�ſ�[%s]����Ҫ���ճ���';
    nStr := Format(nStr, [gCardNo]);

    ShowMessage(nStr);
    Exit;
  end;

  with gOrders[0] do
  begin
    lblID.Text       := FID;
    lblProvider.Text := FCusName;
    lblMate.Text     := FStockName;
    lblTruck.Text    := FTruck;
    lblMValue.Text   := Floattostr(FPData.FValue);

    EditKZValue.Text := FloatToStr(FKZValue);
    EditKZMemo.Text := FMemo;

    if FYSValid = 'N' then
      CheckBox1.IsChecked := True
    else
      CheckBox1.IsChecked := False;
  end;

  BtnOK.Enabled := True;
end;

end.
