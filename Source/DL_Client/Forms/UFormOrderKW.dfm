inherited fFormOrderKW: TfFormOrderKW
  Left = 418
  Top = 228
  Width = 410
  Height = 392
  BorderStyle = bsSizeable
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 402
    Height = 361
    inherited BtnOK: TButton
      Left = 256
      Top = 328
      Caption = #30830#23450
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 326
      Top = 328
      TabOrder = 7
    end
    object EditStockNo: TcxComboBox [2]
      Left = 93
      Top = 192
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditStockNoPropertiesEditValueChanged
      TabOrder = 1
      OnKeyPress = EditStockNoKeyPress
      Width = 200
    end
    object EditStockName: TcxTextEdit [3]
      Left = 93
      Top = 217
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 200
    end
    object ListQuery: TcxListView [4]
      Left = 11
      Top = 11
      Width = 776
      Height = 151
      Align = alClient
      Columns = <
        item
          Caption = #37319#36141#35746#21333
          Width = 90
        end
        item
          Caption = #29289#26009#32534#21495
          Width = 90
        end
        item
          Caption = #29289#26009#21517#31216
          Width = 90
        end
        item
          Caption = #36710#29260#21495
          Width = 90
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
      ViewStyle = vsReport
    end
    object EditProName: TcxTextEdit [5]
      Left = 93
      Top = 267
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 4
      Width = 121
    end
    object EditOID: TcxTextEdit [6]
      Left = 93
      Top = 292
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 5
      Width = 121
    end
    object EditProID: TcxComboBox [7]
      Left = 93
      Top = 242
      Properties.OnEditValueChanged = EditProIDPropertiesEditValueChanged
      TabOrder = 3
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      object dxLayout1Item5: TdxLayoutItem [0]
        Control = ListQuery
        ControlOptions.ShowBorder = False
      end
      inherited dxGroup1: TdxLayoutGroup
        AutoAligns = []
        Caption = #20462#25913#21518#20449#24687
        object dxLayout1Item10: TdxLayoutItem
          AutoAligns = []
          Caption = #29289#26009#32534#30721':'
          Control = EditStockNo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = #29289#26009#21517#31216':'
          Control = EditStockName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #20379#24212#21830#32534#21495':'
          Control = EditProID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #20379#24212#21830#21517#31216':'
          Control = EditProName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #37319#36141#35746#21333':'
          Control = EditOID
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
