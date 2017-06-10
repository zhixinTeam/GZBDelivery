inherited fFormTransDetail: TfFormTransDetail
  Left = 420
  Top = 165
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 308
  ClientWidth = 366
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 366
    Height = 308
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object EditMemo: TcxMemo
      Left = 81
      Top = 211
      Hint = 'T.T_Memo'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      Style.Edges = [bBottom]
      TabOrder = 7
      Height = 45
      Width = 385
    end
    object BtnOK: TButton
      Left = 210
      Top = 275
      Width = 70
      Height = 22
      Caption = #20445#23384
      TabOrder = 8
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 285
      Top = 275
      Width = 70
      Height = 22
      Caption = #21462#28040
      TabOrder = 9
      OnClick = BtnExitClick
    end
    object EditTruck: TcxTextEdit
      Left = 81
      Top = 36
      Hint = 'T.T_Truck'
      TabOrder = 0
      Width = 121
    end
    object EditSrc: TcxTextEdit
      Left = 81
      Top = 61
      Hint = 'T.T_SrcAddr'
      TabOrder = 1
      Width = 121
    end
    object EditDest: TcxTextEdit
      Left = 81
      Top = 86
      Hint = 'T.T_DestAddr'
      TabOrder = 2
      Width = 121
    end
    object EditMName: TcxTextEdit
      Left = 81
      Top = 111
      Hint = 'T.T_StockName'
      TabOrder = 3
      Width = 121
    end
    object EditPValue: TcxTextEdit
      Left = 81
      Top = 136
      Hint = 'T.T_PValue'
      Properties.OnEditValueChanged = EditMValuePropertiesEditValueChanged
      TabOrder = 4
      Text = '0.00'
      Width = 121
    end
    object EditMValue: TcxTextEdit
      Left = 81
      Top = 161
      Hint = 'T.T_MValue'
      Properties.OnEditValueChanged = EditMValuePropertiesEditValueChanged
      TabOrder = 5
      Text = '0.00'
      Width = 121
    end
    object EditValue: TcxTextEdit
      Left = 81
      Top = 186
      Hint = 'T.T_Value'
      TabOrder = 6
      Text = '0.00'
      Width = 121
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item2: TdxLayoutItem
          Caption = #20498#20986#22320#22336':'
          Control = EditSrc
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item5: TdxLayoutItem
          Caption = #20498#20837#22320#22336':'
          Control = EditDest
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item6: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditMName
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item7: TdxLayoutItem
          Caption = #30382#37325'('#21544'):'
          Control = EditPValue
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item8: TdxLayoutItem
          Caption = #27611#37325'('#21544'):'
          Control = EditMValue
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item9: TdxLayoutItem
          Caption = #20928#37325'('#21544'):'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group5: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avBottom
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item10: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button3'
          ShowCaption = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item11: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button4'
          ShowCaption = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
