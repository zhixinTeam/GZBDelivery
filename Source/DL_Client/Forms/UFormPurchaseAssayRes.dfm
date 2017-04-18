inherited fFormPurchaseAssayRes: TfFormPurchaseAssayRes
  Left = 401
  Top = 134
  Width = 713
  Height = 384
  BorderStyle = bsSizeable
  Constraints.MinHeight = 300
  Constraints.MinWidth = 445
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 697
    Height = 346
    inherited BtnOK: TButton
      Left = 534
      Top = 311
      Caption = #30830#23450
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 604
      Top = 311
      TabOrder = 7
    end
    object EditProvider: TcxButtonEdit [2]
      Left = 99
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object cxLabel1: TcxLabel [3]
      Left = 23
      Top = 86
      Caption = #32467#26524':'
      ParentFont = False
      Transparent = True
    end
    object EditMate: TcxButtonEdit [4]
      Left = 99
      Top = 61
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object SGRes: TStringGrid [5]
      Left = 24
      Top = 108
      Width = 649
      Height = 165
      BorderStyle = bsNone
      ColCount = 10
      DefaultColWidth = 80
      FixedCols = 0
      RowCount = 2
      TabOrder = 3
      OnSelectCell = SGResSelectCell
      ColWidths = (
        42
        63
        55
        54
        59
        61
        62
        54
        57
        66)
    end
    object EditpunishRes: TcxTextEdit [6]
      Left = 99
      Top = 279
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    object Btnpunish: TButton [7]
      Left = 11
      Top = 311
      Width = 75
      Height = 25
      Caption = #35745#31639#25187#37325
      TabOrder = 5
      OnClick = BtnpunishClick
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #21270#39564#32467#26524
        object dxLayout1Item5: TdxLayoutItem
          Caption = #20379' '#24212' '#21830':'
          Control = EditProvider
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #21407' '#26448' '#26009':'
          Control = EditMate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Control = SGRes
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #33258#21160#25187#37325'('#21544')'
          Control = EditpunishRes
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item8: TdxLayoutItem [0]
          Control = Btnpunish
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
