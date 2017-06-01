inherited fFormCusBatMap: TfFormCusBatMap
  Left = 496
  Top = 222
  Caption = 'fFormCusBatMap'
  ClientHeight = 182
  ClientWidth = 311
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 311
    Height = 182
    inherited BtnOK: TButton
      Left = 165
      Top = 149
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 235
      Top = 149
      TabOrder = 5
    end
    object EditAddrID: TcxComboBox [2]
      Left = 81
      Top = 61
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object EditLineType: TcxComboBox [3]
      Left = 81
      Top = 111
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object EditCusID: TcxComboBox [4]
      Left = 81
      Top = 36
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    object EditIsVip: TcxComboBox [5]
      Left = 81
      Top = 86
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#26632#21488
        'V=V'#12289'VIP'
        'S=S'#12289#33337#36816)
      Properties.ReadOnly = False
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCusID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #24037#22320#21517#31216':'
          Control = EditAddrID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #19987#24211#31867#22411':'
          Control = EditIsVip
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #36890#36947#20998#32452':'
          Control = EditLineType
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
