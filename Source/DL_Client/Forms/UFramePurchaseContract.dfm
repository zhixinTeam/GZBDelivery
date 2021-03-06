inherited fFramePurchaseContract: TfFramePurchaseContract
  Width = 945
  inherited ToolBar1: TToolBar
    Width = 945
    inherited BtnAdd: TToolButton
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
    inherited BtnRefresh: TToolButton
      Caption = '   '#21047#26032'   '
    end
    inherited BtnExit: TToolButton
      Caption = #20851#38381
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 202
    Width = 945
    Height = 165
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 945
    Height = 135
    object cxTextEdit1: TcxTextEdit [0]
      Left = 81
      Top = 119
      Hint = 'T.con_code'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Width = 125
    end
    object editcontactNo: TcxButtonEdit [1]
      Left = 75
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditNamePropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object cxTextEdit2: TcxTextEdit [2]
      Left = 492
      Top = 119
      Hint = 'T.con_materiel_name'
      ParentFont = False
      TabOrder = 8
      Width = 149
    end
    object cxTextEdit3: TcxTextEdit [3]
      Left = 275
      Top = 119
      Hint = 'T.provider_name'
      ParentFont = False
      TabOrder = 7
      Width = 160
    end
    object cxTextEdit4: TcxTextEdit [4]
      Left = 674
      Top = 119
      Hint = 'T.con_quantity'
      ParentFont = False
      TabOrder = 9
      Width = 121
    end
    object editProviderCode: TcxButtonEdit [5]
      Left = 269
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditNamePropertiesButtonClick
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object editMaterielCode: TcxButtonEdit [6]
      Left = 75
      Top = 61
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditNamePropertiesButtonClick
      TabOrder = 3
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object EditDate: TcxButtonEdit [7]
      Left = 253
      Top = 61
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 4
      Width = 176
    end
    object CheckDelete: TcxCheckBox [8]
      Left = 434
      Top = 61
      Caption = #26597#35810#24050#21024#38500
      ParentFont = False
      TabOrder = 5
      Transparent = True
      OnClick = CheckDeleteClick
      Width = 91
    end
    object editProviderName: TcxButtonEdit [9]
      Left = 459
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditNamePropertiesButtonClick
      Style.ButtonStyle = btsHotFlat
      TabOrder = 2
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        LayoutDirection = ldVertical
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item2: TdxLayoutItem
            Caption = #21512#21516#32534#21495
            Control = editcontactNo
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item6: TdxLayoutItem
            Caption = #20379#24212#21830#32534#30721
            Control = editProviderCode
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item10: TdxLayoutItem
            Caption = #20379#24212#21830#21517#31216
            Control = editProviderName
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item7: TdxLayoutItem
            Caption = #29289#26009#21517#31216
            Control = editMaterielCode
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            Caption = #26085#26399#31579#36873
            Control = EditDate
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            Control = CheckDelete
            ControlOptions.ShowBorder = False
          end
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #21512#21516#32534#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #20379#24212#21830#21517#31216
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #29289#26009#21517#31216
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #25968#37327
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 945
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 945
    inherited TitleBar: TcxLabel
      Caption = #37319#36141#21512#21516#31649#29702
      Style.IsFontAssigned = True
      Width = 945
      AnchorX = 473
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Top = 234
  end
  inherited DataSource1: TDataSource
    Top = 234
  end
end
