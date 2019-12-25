inherited fFrameSaletunnelQuery: TfFrameSaletunnelQuery
  Width = 1115
  Height = 480
  inherited ToolBar1: TToolBar
    Width = 1115
    ButtonWidth = 79
    inherited BtnAdd: TToolButton
      Visible = False
    end
    inherited BtnEdit: TToolButton
      Left = 79
      Visible = False
    end
    inherited BtnDel: TToolButton
      Left = 158
      Visible = False
    end
    inherited S1: TToolButton
      Left = 237
      Visible = False
    end
    inherited BtnRefresh: TToolButton
      Left = 245
      Caption = '    '#21047#26032'    '
    end
    inherited S2: TToolButton
      Left = 324
    end
    inherited BtnPrint: TToolButton
      Left = 332
    end
    inherited BtnPreview: TToolButton
      Left = 411
    end
    inherited BtnExport: TToolButton
      Left = 490
    end
    inherited S3: TToolButton
      Left = 569
    end
    inherited BtnExit: TToolButton
      Left = 577
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 205
    Width = 1115
    Height = 275
    inherited cxView1: TcxGridDBTableView
      PopupMenu = pmPMenu1
      DataController.Summary.Options = [soNullIgnore]
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 1115
    Height = 138
    object cxtxtdt1: TcxTextEdit [0]
      Left = 627
      Top = 98
      Hint = 'T.L_CusName'
      ParentFont = False
      TabOrder = 10
      Width = 105
    end
    object cxtxtdt2: TcxTextEdit [1]
      Left = 449
      Top = 98
      Hint = 'T.L_Value'
      ParentFont = False
      TabOrder = 9
      Width = 115
    end
    object cxtxtdt3: TcxTextEdit [2]
      Left = 81
      Top = 98
      Hint = 'T.L_ID'
      ParentFont = False
      TabOrder = 7
      Width = 115
    end
    object cxtxtdt4: TcxTextEdit [3]
      Left = 259
      Top = 98
      Hint = 'T.L_StockName'
      ParentFont = False
      TabOrder = 8
      Width = 115
    end
    object EditEnd1: TcxTimeEdit [4]
      Left = 235
      Top = 36
      EditValue = 0.729166666666667d
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object EditStart1: TcxTimeEdit [5]
      Left = 93
      Top = 36
      EditValue = 0.354166666666667d
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    object btnOK1: TBitBtn [6]
      Left = 361
      Top = 36
      Width = 80
      Height = 25
      Caption = #26597#35810
      TabOrder = 2
      OnClick = btnOK1Click
    end
    object EditStart2: TcxTimeEdit [7]
      Left = 516
      Top = 36
      EditValue = 0.729166666666667d
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object EditEnd2: TcxTimeEdit [8]
      Left = 694
      Top = 36
      EditValue = 0.354166666666667d
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    object btnOK2: TBitBtn [9]
      Left = 820
      Top = 36
      Width = 80
      Height = 25
      Caption = #26597#35810
      TabOrder = 6
      OnClick = btnOK2Click
    end
    object EditDate: TcxDateEdit [10]
      Left = 971
      Top = 36
      Properties.SaveTime = False
      Properties.ShowTime = False
      TabOrder = 5
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = #31532#19968#26102#38388#27573':'
          Control = EditStart1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = #21040
          Control = EditEnd1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = 'BitBtn1'
          ShowCaption = False
          Control = btnOK1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #31532#20108#26102#38388#27573':'
          Control = EditStart2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #21040#31532#20108#22825
          Control = EditEnd2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = #26597#35810#26085#26399':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Caption = 'BitBtn2'
          ShowCaption = False
          Control = btnOK2
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #20132#36135#21333#21495':'
          Control = cxtxtdt3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #21697#31181#21517#31216':'
          Control = cxtxtdt4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #20132#36135#37327'('#21544'):'
          Control = cxtxtdt2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #23458#25143#21517#31216':'
          Control = cxtxtdt1
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 197
    Width = 1115
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 1115
    inherited TitleBar: TcxLabel
      Caption = #21457#36135#26126#32454#32479#35745#26597#35810
      Style.IsFontAssigned = True
      Width = 1115
      AnchorX = 558
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 10
    Top = 252
  end
  inherited DataSource1: TDataSource
    Left = 38
    Top = 252
  end
  object pmPMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 10
    Top = 280
    object mniN1: TMenuItem
      Tag = 10
      Caption = #25353#20986#21378#26102#38388#26597#35810
      Visible = False
      OnClick = mniN1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Tag = 20
      Caption = #25353#21457#36135#26102#38388#26597#35810
      Visible = False
      OnClick = mniN1Click
    end
    object N3: TMenuItem
      Caption = #25353#36807#37325#26102#38388#26597#35810
      Visible = False
      OnClick = mniN1Click
    end
    object N4: TMenuItem
      Caption = #25353#36807#31354#26102#38388#26597#35810
      Visible = False
      OnClick = mniN1Click
    end
  end
end
