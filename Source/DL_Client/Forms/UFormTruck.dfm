inherited fFormTruck: TfFormTruck
  Left = 430
  Top = 124
  ClientHeight = 395
  ClientWidth = 404
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 404
    Height = 395
    inherited BtnOK: TButton
      Left = 258
      Top = 362
      TabOrder = 14
    end
    inherited BtnExit: TButton
      Left = 328
      Top = 362
      TabOrder = 15
    end
    object EditTruck: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 0
      Width = 116
    end
    object EditOwner: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 1
      Width = 125
    end
    object EditPhone: TcxTextEdit [4]
      Left = 81
      Top = 86
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object CheckValid: TcxCheckBox [5]
      Left = 23
      Top = 277
      Caption = #36710#36742#20801#35768#24320#21333'.'
      ParentFont = False
      TabOrder = 9
      Transparent = True
      Width = 80
    end
    object CheckVerify: TcxCheckBox [6]
      Left = 23
      Top = 329
      Caption = #39564#35777#36710#36742#24050#21040#20572#36710#22330'.'
      ParentFont = False
      TabOrder = 12
      Transparent = True
      Width = 165
    end
    object CheckUserP: TcxCheckBox [7]
      Left = 23
      Top = 303
      Caption = #36710#36742#20351#29992#39044#32622#30382#37325'.'
      ParentFont = False
      TabOrder = 10
      Transparent = True
      Width = 165
    end
    object CheckVip: TcxCheckBox [8]
      Left = 193
      Top = 303
      Caption = 'VIP'#36710#36742
      ParentFont = False
      TabOrder = 11
      Transparent = True
      Width = 100
    end
    object CheckGPS: TcxCheckBox [9]
      Left = 193
      Top = 329
      Caption = #24050#23433#35013'GPS'
      ParentFont = False
      TabOrder = 13
      Transparent = True
      Width = 100
    end
    object cxLabel1: TcxLabel [10]
      Left = 23
      Top = 111
      AutoSize = False
      ParentFont = False
      Style.Edges = []
      Transparent = True
      Height = 5
      Width = 12
    end
    object EditMValue: TcxTextEdit [11]
      Left = 81
      Top = 146
      ParentFont = False
      TabOrder = 5
      Text = '0'
      Width = 100
    end
    object cxLabel2: TcxLabel [12]
      Left = 23
      Top = 221
      Caption = #27880': '#36710#36742#36807#37325#26102#36229#36807#19978#38480','#23558#26080#27861#20445#23384','#38656#21368#36135#21518#20877#27425#36807#30917'.'
      ParentFont = False
      Style.Edges = []
      Transparent = True
    end
    object EditPrePValue: TcxTextEdit [13]
      Left = 81
      Top = 121
      ParentFont = False
      TabOrder = 4
      Text = '0'
      Width = 121
    end
    object EditMaxBillNum: TcxTextEdit [14]
      Left = 81
      Top = 196
      ParentFont = False
      TabOrder = 7
      Text = '0'
      Width = 121
    end
    object EditAxlesNum: TcxTextEdit [15]
      Left = 81
      Top = 171
      TabOrder = 6
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #36710#20027#22995#21517':'
            Control = EditOwner
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item3: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #32852#31995#26041#24335':'
            Control = EditPhone
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item14: TdxLayoutItem
          Caption = #39044#32622#30382#37325':'
          Control = EditPrePValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item12: TdxLayoutItem
            Caption = #27611#37325#19978#38480':'
            Control = EditMValue
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item16: TdxLayoutItem
            Caption = #36710#36724#25968#37327':'
            Control = EditAxlesNum
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item15: TdxLayoutItem
            Caption = #33655#36733#21544#25968':'
            Control = EditMaxBillNum
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item13: TdxLayoutItem
            Caption = 'cxLabel2'
            ShowCaption = False
            Control = cxLabel2
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #36710#36742#21442#25968
        object dxLayout1Item4: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = CheckValid
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item6: TdxLayoutItem
            ShowCaption = False
            Control = CheckUserP
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            Caption = 'cxCheckBox1'
            ShowCaption = False
            Control = CheckVip
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item7: TdxLayoutItem
            Caption = 'cxCheckBox2'
            ShowCaption = False
            Control = CheckVerify
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item10: TdxLayoutItem
            Caption = 'cxCheckBox1'
            ShowCaption = False
            Control = CheckGPS
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
end
