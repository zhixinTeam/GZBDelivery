inherited fFormPUserYSWh: TfFormPUserYSWh
  Left = 495
  Top = 210
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 138
  ClientWidth = 335
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 335
    Height = 138
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    AutoControlAlignment = False
    object BtnOK: TButton
      Left = 179
      Top = 104
      Width = 70
      Height = 23
      Caption = #20445#23384
      TabOrder = 3
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 255
      Top = 104
      Width = 69
      Height = 23
      Caption = #21462#28040
      TabOrder = 4
      OnClick = BtnExitClick
    end
    object EditMate: TcxComboBox
      Left = 84
      Top = 55
      ParentFont = False
      Properties.ReadOnly = False
      TabOrder = 1
      OnKeyPress = EditMateKeyPress
      Width = 145
    end
    object cxCheckBox1: TcxCheckBox
      Left = 11
      Top = 104
      Caption = #20801#35768#39564#25910
      ParentFont = False
      State = cbsChecked
      TabOrder = 2
      Width = 121
    end
    object EditPUser: TcxComboBox
      Left = 90
      Top = 29
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    object dxLayoutGroup1: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutGroup2: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #39564' '#25910' '#21592#65306
          Control = EditPUser
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item3: TdxLayoutItem
          Caption = #21407#26448#26009#21517':'
          Control = EditMate
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
        object dxLayoutItem1: TdxLayoutItem
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
