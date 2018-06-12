inherited fFormCusBatMap: TfFormCusBatMap
  Left = 496
  Top = 222
  Caption = 'fFormCusBatMap'
  ClientHeight = 242
  ClientWidth = 311
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 311
    Height = 242
    inherited BtnOK: TButton
      Left = 165
      Top = 209
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 235
      Top = 209
      TabOrder = 7
    end
    object EditAddrID: TcxComboBox [2]
      Left = 81
      Top = 86
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object EditLineType: TcxComboBox [3]
      Left = 81
      Top = 136
      ParentFont = False
      TabOrder = 4
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
      Top = 111
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#26632#21488
        'V=V'#12289'VIP'
        'S=S'#12289#33337#36816)
      Properties.ReadOnly = False
      TabOrder = 3
      Width = 121
    end
    object EditStock: TcxComboBox [6]
      Left = 81
      Top = 61
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object EditCk: TcxComboBox [7]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      TabOrder = 5
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCusID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #21697#31181#21517#31216':'
          Control = EditStock
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
        object dxLayout1Item7: TdxLayoutItem
          Caption = #20179#24211#32534#21495':'
          Control = EditCk
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
