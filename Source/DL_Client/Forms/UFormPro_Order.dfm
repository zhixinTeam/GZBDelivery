inherited fFormPro_Order: TfFormPro_Order
  Left = 495
  Top = 210
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 214
  ClientWidth = 506
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 506
    Height = 214
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    AutoControlAlignment = False
    object EditMemo: TcxMemo
      Left = 84
      Top = 133
      Hint = 'T.P_Memo'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      Style.Edges = [bBottom]
      TabOrder = 4
      Height = 40
      Width = 437
    end
    object BtnOK: TButton
      Left = 333
      Top = 192
      Width = 70
      Height = 23
      Caption = #20445#23384
      TabOrder = 6
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 409
      Top = 192
      Width = 69
      Height = 23
      Caption = #21462#28040
      TabOrder = 7
      OnClick = BtnExitClick
    end
    object EditMate: TcxComboBox
      Left = 84
      Top = 55
      Hint = 'T.P_StockName'
      ParentFont = False
      Properties.ReadOnly = False
      TabOrder = 1
      OnKeyPress = EditMateKeyPress
      Width = 145
    end
    object EditProvider: TcxButtonEdit
      Left = 84
      Top = 29
      Hint = 'T.P_Name'
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = False
      TabOrder = 0
      OnKeyPress = EditProviderKeyPress
      Width = 397
    end
    object EditValue: TcxTextEdit
      Left = 120
      Top = 81
      Hint = 'T.P_Value'
      ParentFont = False
      TabOrder = 2
      Text = '0.00'
      Width = 161
    end
    object cxCheckBox1: TcxCheckBox
      Left = 11
      Top = 192
      Caption = #21551#29992#38480#21046
      ParentFont = False
      Properties.OnChange = cxCheckBox1PropertiesChange
      State = cbsChecked
      TabOrder = 5
      Width = 121
    end
    object EditDate: TcxDateEdit
      Left = 84
      Top = 107
      Properties.Kind = ckDateTime
      TabOrder = 3
      Width = 121
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Group9: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Item6: TdxLayoutItem
            Caption = #20379' '#24212' '#21830':'
            Control = EditProvider
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item3: TdxLayoutItem
            Caption = #21407#26448#26009#21517':'
            Control = EditMate
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Item9: TdxLayoutItem
          Caption = #27599#26085#36827#22330#37327'('#21544'):'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item2: TdxLayoutItem
          Caption = #26377#25928#26085#26399':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avBottom
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = cxCheckBox1
          ControlOptions.ShowBorder = False
        end
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
