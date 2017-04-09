inherited fFormPoundDaiWC: TfFormPoundDaiWC
  Left = 581
  Top = 212
  Caption = 'fFormPoundDaiWC'
  ClientHeight = 241
  ClientWidth = 377
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 377
    Height = 241
    inherited BtnOK: TButton
      Left = 231
      Top = 208
      TabOrder = 7
    end
    inherited BtnExit: TButton
      Left = 301
      Top = 208
      TabOrder = 8
    end
    object EditStart: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    object EditEnd: TcxTextEdit [3]
      Left = 81
      Top = 61
      TabOrder = 1
      Width = 121
    end
    object EditWCZ: TcxTextEdit [4]
      Left = 81
      Top = 86
      TabOrder = 2
      Width = 121
    end
    object EditWCF: TcxTextEdit [5]
      Left = 81
      Top = 111
      TabOrder = 3
      Width = 121
    end
    object EditStation: TcxTextEdit [6]
      Left = 81
      Top = 136
      TabOrder = 4
      Width = 121
    end
    object EditPert: TcxCheckBox [7]
      Left = 23
      Top = 161
      Caption = #25353#30334#20998#27604#35745#31639
      ParentFont = False
      TabOrder = 5
      Transparent = True
      Width = 121
    end
    object cxLabel1: TcxLabel [8]
      Left = 149
      Top = 161
      Caption = #25353#27604#20363#35745#31639#26102','#21333#20301#21315#20998#20043#19968
      ParentFont = False
      Transparent = True
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #35823#24046#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          Caption = #36215#22987#21544#20301':'
          Control = EditStart
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #32456#27490#21544#20301':'
          Control = EditEnd
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #27491' '#35823' '#24046':'
          Control = EditWCZ
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #36127' '#35823' '#24046':'
          Control = EditWCF
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #22320#30917#32534#21495':'
          Control = EditStation
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item8: TdxLayoutItem
            Caption = 'cxCheckBox1'
            ShowCaption = False
            Control = EditPert
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            Caption = 'cxLabel1'
            ShowCaption = False
            Control = cxLabel1
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
end
