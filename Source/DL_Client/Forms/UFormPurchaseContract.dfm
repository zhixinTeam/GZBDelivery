inherited fFormPurchaseContract: TfFormPurchaseContract
  Left = 221
  Top = 107
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 550
  ClientWidth = 546
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayout1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 546
    Height = 550
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 400
      Top = 517
      Width = 65
      Height = 22
      Caption = #20445#23384
      TabOrder = 18
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 470
      Top = 517
      Width = 65
      Height = 22
      Caption = #21462#28040
      TabOrder = 19
      OnClick = BtnExitClick
    end
    object editProvider: TcxButtonEdit
      Left = 75
      Top = 62
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 1
      Text = 'editProvider'
      OnKeyPress = editProviderKeyPress
      Width = 358
    end
    object editMateriel: TcxButtonEdit
      Left = 75
      Top = 87
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 2
      Text = 'editMateriel'
      OnKeyPress = editMaterielKeyPress
      Width = 358
    end
    object editContractno: TcxTextEdit
      Left = 75
      Top = 112
      ParentFont = False
      TabOrder = 3
      Text = 'editContractno'
      Width = 174
    end
    object editPrice: TcxTextEdit
      Left = 282
      Top = 112
      ParentFont = False
      TabOrder = 4
      Text = 'editPrice'
      Width = 151
    end
    object editQuantity: TcxTextEdit
      Left = 75
      Top = 137
      ParentFont = False
      TabOrder = 5
      Text = 'editQuantity'
      Width = 358
    end
    object editRemark: TcxMemo
      Left = 75
      Top = 162
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 6
      Height = 37
      Width = 446
    end
    object comQuotaName: TcxComboBox
      Left = 75
      Top = 236
      ParentFont = False
      Properties.OnChange = comQuotaNamePropertiesChange
      TabOrder = 7
      Text = 'comQuotaName'
      Width = 121
    end
    object comQuotaCondition: TcxComboBox
      Left = 253
      Top = 236
      ParentFont = False
      TabOrder = 8
      Text = 'comQuotaCondition'
      Width = 121
    end
    object comQuotaValue: TcxComboBox
      Left = 75
      Top = 266
      ParentFont = False
      TabOrder = 10
      Text = 'comQuotaValue'
      Width = 121
    end
    object comPunishCondition: TcxComboBox
      Left = 253
      Top = 266
      ParentFont = False
      TabOrder = 11
      Text = 'comPunishCondition'
      Width = 121
    end
    object editpunishBasis: TcxTextEdit
      Left = 75
      Top = 296
      ParentFont = False
      TabOrder = 13
      Text = 'editpunishBasis'
      Width = 121
    end
    object editpunishStandard: TcxTextEdit
      Left = 253
      Top = 296
      ParentFont = False
      TabOrder = 15
      Text = 'editpunishStandard'
      Width = 121
    end
    object comPunishMode: TcxComboBox
      Left = 75
      Top = 321
      ParentFont = False
      Properties.OnChange = comPunishModePropertiesChange
      TabOrder = 14
      Text = 'comPunishMode'
      Width = 121
    end
    object btnAdd: TcxButton
      Left = 379
      Top = 236
      Width = 75
      Height = 25
      Caption = #28155#21152#25351#26631
      TabOrder = 9
      OnClick = btnAddClick
      Align = alLeft
    end
    object btnDel: TcxButton
      Left = 379
      Top = 266
      Width = 75
      Height = 25
      Caption = #21024#38500#25351#26631
      TabOrder = 12
      OnClick = btnDelClick
      Align = alLeft
    end
    object cxMemo2: TcxMemo
      Left = 23
      Top = 346
      Align = alLeft
      Lines.Strings = (
        #31034#20363':'#12304'1'#12289#25351#26631#21517':SiO,'#25187#37325#26465#20214':<,'#25187#37325#20381#25454':1,'#25187#37325#26631#20934':0.1,'#25187#37325#27169#24335':'#37325#37327#12305
        #34920#31034#20132#20184#30340#36135#29289#20013'SiO'#27599#20302#20110#36136#37327#35201#27714'1%,'#25187#37325'0.1'#21544';'
        #12304'2'#12289#25351#26631#21517':SiO,'#25187#37325#26465#20214':<,'#25187#37325#20381#25454':1,'#25187#37325#26631#20934':0.5,'#25187#37325#27169#24335':'#21333#20215#12305
        #34920#31034#20132#20184#30340#36135#29289#20013'SiO'#27599#20302#20110#36136#37327#35201#27714'1%,'#21333#20215#38477#20302'0.5'#20803
        #12304'3'#12289#25351#26631#21517':SiO,'#25187#37325#26465#20214':<,'#25187#37325#27169#24335':'#20928#37325#12305#34920#31034#20132#20184#30340#36135#29289#20013'SiO'#20302#20110#36136#37327#35201#27714','#25187#37325'='#20928
        #37325'*'#25351#26631
        #24046#24322)
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 16
      Height = 81
      Width = 498
    end
    object InfoList: TcxListView
      Left = 23
      Top = 432
      Width = 498
      Height = 73
      Align = alLeft
      Columns = <
        item
          Caption = #25351#26631#21517
          Width = 80
        end
        item
          Caption = #21333#20301
        end
        item
          Caption = #26465#20214
          Width = 40
        end
        item
          Caption = #20540
          Width = 40
        end
        item
          Caption = #25187#37325#26465#20214
          Width = 60
        end
        item
          Caption = #25187#37325#20381#25454
          Width = 65
        end
        item
          Caption = #25187#37325#26631#20934
          Width = 60
        end
        item
          Caption = #25187#37325#27169#24335
          Width = 60
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 17
      ViewStyle = vsReport
    end
    object chbType: TcxCheckBox
      Left = 23
      Top = 36
      Caption = #20020#26102#21512#21516
      ParentFont = False
      TabOrder = 0
      Transparent = True
      Width = 121
    end
    object dxLayout1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxGroup1: TdxLayoutGroup
        AutoAligns = []
        Caption = #21512#21516#22522#26412#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = chbType
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = #20379#24212#21830
          Control = editProvider
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = #21407#26448#26009
          Control = editMateriel
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group8: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item6: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #21512#21516#32534#21495
              Control = editContractno
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item7: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #21333#20215
              Control = editPrice
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Item8: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #25968#37327
            Control = editQuantity
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = #22791#27880
          Control = editRemark
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup
        AutoAligns = []
        Caption = #21512#21516#25351#26631#20449#24687
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item10: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #25351#26631#21517
            Control = comQuotaName
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item11: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #25351#26631#26465#20214
            Control = comQuotaCondition
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item17: TdxLayoutItem
            Caption = 'cxButton1'
            ShowCaption = False
            Control = btnAdd
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group3: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item12: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #25351#26631#20540
              Control = comQuotaValue
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item13: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #25187#37325#26465#20214
              Control = comPunishCondition
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item18: TdxLayoutItem
              Caption = 'cxButton2'
              ShowCaption = False
              Control = btnDel
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group6: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Group7: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              ShowBorder = False
              object dxLayout1Item14: TdxLayoutItem
                AutoAligns = [aaVertical]
                Caption = #25187#37325#20381#25454
                Control = editpunishBasis
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item16: TdxLayoutItem
                AutoAligns = [aaVertical]
                Caption = #25187#37325#27169#24335
                Control = comPunishMode
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Item15: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #25187#37325#26631#20934
              Control = editpunishStandard
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayout1Item19: TdxLayoutItem
          Control = cxMemo2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item20: TdxLayoutItem
          Control = InfoList
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayout1Group1: TdxLayoutGroup
        AutoAligns = []
        AlignHorz = ahRight
        AlignVert = avBottom
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayout1Item1: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button1'
          ShowCaption = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button2'
          ShowCaption = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
