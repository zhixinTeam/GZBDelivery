inherited fFormCusBatMap: TfFormCusBatMap
  Left = 496
  Top = 222
  Caption = 'fFormCusBatMap'
  ClientHeight = 170
  ClientWidth = 311
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 311
    Height = 170
    inherited BtnOK: TButton
      Left = 165
      Top = 137
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 235
      Top = 137
      TabOrder = 4
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
      Top = 86
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object EditCusID: TcxComboBox [4]
      Left = 81
      Top = 36
      ParentFont = False
      TabOrder = 0
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
        object dxLayout1Item9: TdxLayoutItem
          Caption = #36890#36947#20998#32452':'
          Control = EditLineType
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
