inherited fFormMaterailTunnel: TfFormMaterailTunnel
  Caption = 'fFormMaterailTunnel'
  ClientHeight = 161
  ClientWidth = 363
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 363
    Height = 161
    inherited BtnOK: TButton
      Left = 217
      Top = 128
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 287
      Top = 128
      TabOrder = 4
    end
    object EditStockNO: TcxButtonEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditStockNOPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object EditStockName: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object EditTunnel: TcxTextEdit [4]
      Left = 81
      Top = 86
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #29289#26009#32534#21495':'
          Control = EditStockNO
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditStockName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #36890#36947#32534#21495':'
          Control = EditTunnel
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
