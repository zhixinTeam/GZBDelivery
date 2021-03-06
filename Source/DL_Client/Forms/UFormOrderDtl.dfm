inherited fFormOrderDtl: TfFormOrderDtl
  Left = 610
  Top = 230
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 131
  ClientWidth = 480
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 480
    Height = 131
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 324
      Top = 98
      Width = 70
      Height = 22
      Caption = #20445#23384
      TabOrder = 4
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 399
      Top = 98
      Width = 70
      Height = 22
      Caption = #21462#28040
      TabOrder = 5
      OnClick = BtnExitClick
    end
    object EditTunnelID: TcxButtonEdit
      Left = 81
      Top = 61
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 121
    end
    object EditTunnelName: TcxTextEdit
      Left = 265
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      Width = 121
    end
    object EditStock: TcxButtonEdit
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 0
      OnKeyPress = EditStockKeyPress
      Width = 121
    end
    object EditStockName: TcxTextEdit
      Left = 265
      Top = 36
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        LayoutDirection = ldHorizontal
        object dxLayoutControl1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Item6: TdxLayoutItem
            Caption = #21407#26448#26009'ID:'
            Control = EditStock
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item3: TdxLayoutItem
            Caption = #36890#36947#32534#30721':'
            Control = EditTunnelID
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Item7: TdxLayoutItem
            Caption = #21407' '#26448' '#26009':'
            Control = EditStockName
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item5: TdxLayoutItem
            Caption = #36890#36947#21517#31216':'
            Control = EditTunnelName
            ControlOptions.ShowBorder = False
          end
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
