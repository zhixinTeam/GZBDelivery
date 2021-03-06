inherited fFormHYMBWH: TfFormHYMBWH
  Left = 323
  Top = 208
  ClientHeight = 214
  ClientWidth = 473
  Constraints.MinHeight = 245
  Constraints.MinWidth = 460
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 473
    Height = 214
    inherited BtnOK: TButton
      Left = 327
      Top = 181
      Caption = #30830#23450
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 397
      Top = 181
      TabOrder = 4
    end
    object EditCustom: TcxComboBox [2]
      Left = 105
      Top = 36
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ItemHeight = 18
      Properties.OnChange = EditCustomPropertiesChange
      TabOrder = 0
      OnKeyPress = EditCustomKeyPress
      Width = 121
    end
    object EditStockName: TcxComboBox [3]
      Left = 105
      Top = 61
      TabOrder = 1
      Width = 121
    end
    object EditStockNameEx: TcxComboBox [4]
      Left = 105
      Top = 86
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCustom
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #21697#31181#21517#31216':'
          Control = EditStockName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #27169#26495#21697#31181#21517#31216':'
          Control = EditStockNameEx
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
