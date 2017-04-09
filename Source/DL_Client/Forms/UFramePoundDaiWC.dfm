inherited fFramePoundDaiWC: TfFramePoundDaiWC
  inherited ToolBar1: TToolBar
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
    Top = 137
    Height = 230
  end
  inherited dxLayout1: TdxLayoutControl
    Height = 70
    object cxTextEdit1: TcxTextEdit [0]
      Left = 81
      Top = 41
      Hint = 'T.P_Start'
      ParentFont = False
      TabOrder = 0
      Width = 72
    end
    object cxTextEdit2: TcxTextEdit [1]
      Left = 216
      Top = 41
      Hint = 'T.P_End'
      ParentFont = False
      TabOrder = 1
      Width = 65
    end
    object cxTextEdit3: TcxTextEdit [2]
      Left = 332
      Top = 41
      Hint = 'T.P_DaiWuChaZ'
      ParentFont = False
      TabOrder = 2
      Width = 61
    end
    object cxTextEdit4: TcxTextEdit [3]
      Left = 444
      Top = 41
      Hint = 'T.P_DaiWuChaF'
      ParentFont = False
      TabOrder = 3
      Width = 85
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        ShowCaption = False
        Hidden = True
        ShowBorder = False
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #36215#22987#21544#25968':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #32467#26463#21544#25968':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #27491#33539#22260':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36127#33539#22260':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 129
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #21253#35013#35823#24046#33539#22260#35774#32622
      Style.IsFontAssigned = True
      AnchorX = 301
      AnchorY = 11
    end
  end
end
