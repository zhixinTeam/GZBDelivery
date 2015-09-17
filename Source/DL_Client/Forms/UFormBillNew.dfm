inherited fFormNewBill: TfFormNewBill
  Left = 567
  Top = 378
  Caption = #21019#24314#20132#36135#21333
  ClientHeight = 225
  ClientWidth = 411
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 411
    Height = 225
    AutoControlAlignment = False
    inherited BtnOK: TButton
      Left = 265
      Top = 192
      Caption = #30830#23450
      TabOrder = 2
    end
    inherited BtnExit: TButton
      Left = 335
      Top = 192
      TabOrder = 3
    end
    object EditID: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      TabOrder = 0
      OnKeyPress = EditIDKeyPress
      Width = 121
    end
    object EditMemo: TcxMemo [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      Properties.ScrollBars = ssVertical
      Style.Edges = [bBottom]
      TabOrder = 1
      Height = 89
      Width = 185
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxlytmLayout1Item4: TdxLayoutItem
          Caption = #25552#36135#21333#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item5: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #24320#21333#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
