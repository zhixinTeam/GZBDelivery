inherited fFormBill: TfFormBill
  Left = 490
  Top = 85
  ClientHeight = 558
  ClientWidth = 445
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 445
    Height = 558
    AutoControlTabOrders = False
    inherited BtnOK: TButton
      Left = 299
      Top = 525
      Caption = #24320#21333
      TabOrder = 14
    end
    inherited BtnExit: TButton
      Left = 369
      Top = 525
      TabOrder = 16
    end
    object EditValue: TcxTextEdit [2]
      Left = 279
      Top = 424
      ParentFont = False
      TabOrder = 13
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object EditCard: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditID: TcxTextEdit [4]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = True
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditCus: TcxTextEdit [5]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditCName: TcxTextEdit [6]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditMan: TcxTextEdit [7]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 4
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditDate: TcxTextEdit [8]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 5
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditFirm: TcxTextEdit [9]
      Left = 81
      Top = 186
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 6
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditArea: TcxTextEdit [10]
      Left = 81
      Top = 211
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 7
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditStock: TcxTextEdit [11]
      Left = 81
      Top = 349
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 8
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditSName: TcxTextEdit [12]
      Left = 81
      Top = 374
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 9
      OnKeyPress = EditLadingKeyPress
      Width = 135
    end
    object EditMax: TcxTextEdit [13]
      Left = 279
      Top = 374
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 10
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditTruck: TcxButtonEdit [14]
      Left = 81
      Top = 424
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      Properties.OnChange = EditTruckPropertiesChange
      TabOrder = 12
      OnKeyPress = EditLadingKeyPress
      Width = 135
    end
    object EditType: TcxComboBox [15]
      Left = 81
      Top = 399
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#26632#21488
        'V=V'#12289'VIP'
        'S=S'#12289#33337#36816)
      TabOrder = 11
      OnKeyPress = EditLadingKeyPress
      Width = 135
    end
    object EditTrans: TcxTextEdit [16]
      Left = 81
      Top = 261
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 19
      Width = 121
    end
    object EditMemo: TcxTextEdit [17]
      Left = 279
      Top = 449
      ParentFont = False
      TabOrder = 20
      Width = 136
    end
    object EditWorkAddr: TcxTextEdit [18]
      Left = 81
      Top = 236
      ParentFont = False
      TabOrder = 21
      Width = 121
    end
    object EditFQ: TcxButtonEdit [19]
      Left = 279
      Top = 399
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditFQPropertiesButtonClick
      TabOrder = 22
      OnKeyPress = OnCtrlKeyPress
      Width = 138
    end
    object EditLineGroup: TcxComboBox [20]
      Left = 81
      Top = 449
      ParentFont = False
      TabOrder = 23
      Width = 121
    end
    object PrintHY: TcxCheckBox [21]
      Left = 11
      Top = 525
      Caption = #25171#21360#21270#39564#21333
      ParentFont = False
      TabOrder = 24
      Transparent = True
      Width = 95
    end
    object EditMValue: TcxTextEdit [22]
      Left = 279
      Top = 474
      ParentFont = False
      Properties.OnChange = EditMValuePropertiesChange
      TabOrder = 25
      Width = 135
    end
    object EditPValue: TcxTextEdit [23]
      Left = 81
      Top = 474
      ParentFont = False
      Properties.OnChange = EditPValuePropertiesChange
      TabOrder = 26
      Width = 135
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxGroupLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #35760#24405#32534#21495':'
            Control = EditID
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #21345#29255#32534#21495':'
            Control = EditCard
            ControlOptions.ShowBorder = False
          end
        end
        object dxlytmLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCName
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item5: TdxLayoutItem
          Caption = #24320' '#21333' '#20154':'
          Control = EditMan
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item6: TdxLayoutItem
          Caption = #24320#21333#26102#38388':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item7: TdxLayoutItem
          Caption = #21457#36135#24037#21378':'
          Control = EditFirm
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item8: TdxLayoutItem
          Caption = #38144#21806#29255#21306':'
          Control = EditArea
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #24037#31243#24037#22320':'
          Control = EditWorkAddr
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #36816#36755#21333#20301':'
          Control = EditTrans
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #25552#21333#20449#24687
        object dxlytmLayout1Item9: TdxLayoutItem
          Caption = #27700#27877#32534#21495':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxGroupLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxGroupLayout1Group7: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxlytmLayout1Item10: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #27700#27877#21517#31216':'
              Control = EditSName
              ControlOptions.ShowBorder = False
            end
            object dxlytmLayout1Item11: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21487#25552#36135#37327':'
              Control = EditMax
              ControlOptions.ShowBorder = False
            end
          end
          object dxGroupLayout1Group6: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Group3: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxlytmLayout1Item13: TdxLayoutItem
                Caption = #25552#36135#36890#36947':'
                Control = EditType
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item7: TdxLayoutItem
                Caption = #20986#21378#32534#21495':'
                Control = EditFQ
                ControlOptions.ShowBorder = False
              end
            end
            object dxGroupLayout1Group3: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayout1Group5: TdxLayoutGroup
                ShowCaption = False
                Hidden = True
                ShowBorder = False
                object dxlytmLayout1Item12: TdxLayoutItem
                  Caption = #25552#36135#36710#36742':'
                  Control = EditTruck
                  ControlOptions.ShowBorder = False
                end
                object dxLayout1Item10: TdxLayoutItem
                  Caption = #36890#36947#20998#32452':'
                  Control = EditLineGroup
                  ControlOptions.ShowBorder = False
                end
              end
              object dxLayout1Group4: TdxLayoutGroup
                ShowCaption = False
                Hidden = True
                ShowBorder = False
                object dxLayout1Item8: TdxLayoutItem
                  AutoAligns = [aaVertical]
                  AlignHorz = ahClient
                  Caption = #21150#29702#21544#25968':'
                  Control = EditValue
                  ControlOptions.ShowBorder = False
                end
                object dxLayout1Item4: TdxLayoutItem
                  Caption = #22791'    '#27880':'
                  Control = EditMemo
                  ControlOptions.ShowBorder = False
                end
              end
            end
          end
        end
        object dxLayout1Group6: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item12: TdxLayoutItem
            Caption = #30382#37325#21544#25968':'
            Visible = False
            Control = EditPValue
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item13: TdxLayoutItem
            Caption = #27611#37325#21544#25968':'
            Visible = False
            Control = EditMValue
            ControlOptions.ShowBorder = False
          end
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item11: TdxLayoutItem [0]
          ShowCaption = False
          Control = PrintHY
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
