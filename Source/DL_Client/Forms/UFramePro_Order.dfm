inherited fFramePro_Order: TfFramePro_Order
  Width = 957
  Height = 436
  inherited ToolBar1: TToolBar
    Width = 957
    inherited BtnAdd: TToolButton
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 202
    Width = 957
    Height = 234
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
      OnDblClick = cxView1DblClick
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 957
    Height = 135
    object EditStockName: TcxButtonEdit [0]
      Left = 245
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object cxTextEdit2: TcxTextEdit [1]
      Left = 69
      Top = 93
      Hint = 'T.O_ProName'
      ParentFont = False
      TabOrder = 2
      Width = 125
    end
    object cxTextEdit4: TcxTextEdit [2]
      Left = 245
      Top = 93
      Hint = 'T.O_SaleMan'
      ParentFont = False
      TabOrder = 3
      Width = 125
    end
    object EditCustomer: TcxButtonEdit [3]
      Left = 69
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item7: TdxLayoutItem
          Caption = #20379#24212#21830':'
          Control = EditCustomer
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #21407#26448#26009':'
          Control = EditStockName
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          Caption = #20379#24212#21830':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #21407#26448#26009':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 957
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 957
    inherited TitleBar: TcxLabel
      Caption = #20379#24212#21830#36827#21378#37327#38480#21046
      Style.IsFontAssigned = True
      Width = 957
      AnchorX = 479
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 4
    Top = 236
  end
  inherited DataSource1: TDataSource
    Left = 32
    Top = 236
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 4
    Top = 264
    object N1: TMenuItem
      Caption = #21150#29702#30913#21345
      Visible = False
    end
    object N2: TMenuItem
      Caption = #27880#38144#30913#21345
      Visible = False
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Caption = #20462#25913#36710#29260#21495
      Visible = False
    end
  end
end
