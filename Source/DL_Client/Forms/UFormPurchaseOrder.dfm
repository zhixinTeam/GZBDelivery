inherited fFormPurchaseOrder: TfFormPurchaseOrder
  Left = 495
  Top = 210
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 288
  ClientWidth = 509
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 509
    Height = 288
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    AutoControlAlignment = False
    object EditMemo: TcxMemo
      Left = 84
      Top = 185
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      Style.Edges = [bBottom]
      TabOrder = 8
      Height = 40
      Width = 437
    end
    object BtnOK: TButton
      Left = 353
      Top = 254
      Width = 70
      Height = 23
      Caption = #20445#23384
      TabOrder = 9
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 429
      Top = 254
      Width = 69
      Height = 23
      Caption = #21462#28040
      TabOrder = 10
      OnClick = BtnExitClick
    end
    object EditSalesMan: TcxComboBox
      Left = 84
      Top = 81
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.ItemHeight = 20
      TabOrder = 2
      OnKeyDown = EditSalesManKeyDown
      Width = 145
    end
    object EditProject: TcxTextEdit
      Left = 295
      Top = 133
      ParentFont = False
      Properties.MaxLength = 0
      TabOrder = 5
      Width = 183
    end
    object EditArea: TcxButtonEdit
      Left = 84
      Top = 133
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
      TabOrder = 4
      Width = 145
    end
    object cxLabel1: TcxLabel
      Left = 231
      Top = 159
      AutoSize = False
      Caption = #27880':'#20020#26102#21345#20986#21378#26102#22238#25910';'#22266#23450#21345#20986#21378#26102#19981#22238#25910
      ParentFont = False
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 20
      Width = 268
      AnchorY = 169
    end
    object EditTruck: TcxButtonEdit
      Left = 84
      Top = 107
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 3
      OnKeyPress = EditTruckKeyPress
      Width = 183
    end
    object EditMate: TcxComboBox
      Left = 84
      Top = 55
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      OnKeyPress = EditMateKeyPress
      Width = 145
    end
    object EditCardType: TcxComboBox
      Left = 84
      Top = 159
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.Items.Strings = (
        'L=L'#12289#20020#26102#21345
        'G=G'#12289#38271#26399#21345)
      TabOrder = 6
      Width = 141
    end
    object EditProvider: TcxButtonEdit
      Left = 84
      Top = 29
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      TabOrder = 0
      OnKeyPress = EditProviderKeyPress
      Width = 121
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Group9: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Item6: TdxLayoutItem
            Caption = #20379' '#24212' '#21830':'
            Control = EditProvider
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item3: TdxLayoutItem
            Caption = #21407#26448#26009#21517':'
            Control = EditMate
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item5: TdxLayoutItem
            Caption = #19994#21153#20154#21592':'
            Control = EditSalesMan
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item1: TdxLayoutItem
            Caption = #36710#29260#21495#30721':'
            Control = EditTruck
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item8: TdxLayoutItem
            Caption = #25152#23646#21306#22495':'
            Control = EditArea
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item2: TdxLayoutItem
            Caption = #39033#30446#21517#31216':'
            Control = EditProject
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Group11: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item7: TdxLayoutItem
            Caption = #21345#29255#31867#22411':'
            Control = EditCardType
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item21: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = 'cxLabel1'
            ShowCaption = False
            Control = cxLabel1
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avBottom
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item10: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button3'
          ShowCaption = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item11: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button4'
          ShowCaption = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
