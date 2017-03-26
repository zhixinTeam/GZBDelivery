inherited fFormPurchaseContract: TfFormPurchaseContract
  Left = 464
  Top = 136
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 497
  ClientWidth = 463
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayout1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 463
    Height = 497
    Align = alClient
    TabOrder = 0
    TabStop = False
    LayoutLookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 317
      Top = 464
      Width = 65
      Height = 22
      Caption = #20445#23384
      TabOrder = 17
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 387
      Top = 464
      Width = 65
      Height = 22
      Caption = #21462#28040
      TabOrder = 18
      OnClick = BtnExitClick
    end
    object editProvider: TcxButtonEdit
      Left = 93
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Caption = '...'
        end>
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      Text = 'editProvider'
      OnKeyPress = editProviderKeyPress
      Width = 121
    end
    object editMateriel: TcxButtonEdit
      Left = 93
      Top = 61
      ParentFont = False
      Properties.Buttons = <
        item
          Caption = '...'
        end>
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      Text = 'editMateriel'
      OnKeyPress = editMaterielKeyPress
      Width = 121
    end
    object editContractno: TcxTextEdit
      Left = 93
      Top = 86
      ParentFont = False
      TabOrder = 2
      Text = 'editContractno'
      Width = 121
    end
    object editPrice: TcxTextEdit
      Left = 198
      Top = 86
      ParentFont = False
      TabOrder = 3
      Text = 'editPrice'
      Width = 121
    end
    object editQuantity: TcxTextEdit
      Left = 305
      Top = 86
      ParentFont = False
      TabOrder = 4
      Text = 'editQuantity'
      Width = 121
    end
    object editRemark: TcxMemo
      Left = 93
      Top = 111
      ParentFont = False
      TabOrder = 5
      Height = 89
      Width = 185
    end
    object comQuotaName: TcxComboBox
      Left = 93
      Top = 203
      ParentFont = False
      Properties.OnChange = comQuotaNamePropertiesChange
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 6
      Text = 'comQuotaName'
      Width = 121
    end
    object comQuotaCondition: TcxComboBox
      Left = 271
      Top = 203
      ParentFont = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 7
      Text = 'comQuotaCondition'
      Width = 121
    end
    object comQuotaValue: TcxComboBox
      Left = 93
      Top = 233
      ParentFont = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 9
      Text = 'comQuotaValue'
      Width = 121
    end
    object comPunishCondition: TcxComboBox
      Left = 271
      Top = 233
      ParentFont = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 10
      Text = 'comPunishCondition'
      Width = 121
    end
    object editpunishBasis: TcxTextEdit
      Left = 93
      Top = 263
      ParentFont = False
      TabOrder = 12
      Text = 'editpunishBasis'
      Width = 121
    end
    object editpunishStandard: TcxTextEdit
      Left = 201
      Top = 263
      ParentFont = False
      TabOrder = 13
      Text = 'editpunishStandard'
      Width = 121
    end
    object comPunishMode: TcxComboBox
      Left = 323
      Top = 263
      ParentFont = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 14
      Text = 'comPunishMode'
      Width = 121
    end
    object cxMemo2: TcxMemo
      Left = 23
      Top = 288
      Lines.Strings = (
        #31034#20363':'#12304#25351#26631#21517':SiO,'#25187#37325#26465#20214':<,'#25187#37325#20381#25454':1,'#25187#37325#26631#20934':0.1,'#25187#37325#27169#24335':'#37325#37327#12305
        #34920#31034#20132#20184#30340#36135#29289#20013'SiO'#27599#20302#20110#36136#37327#35201#27714'1%,'#25187#37325'0.1'#21544';'
        #12304#25351#26631#21517':SiO,'#25187#37325#26465#20214':<,'#25187#37325#20381#25454':1,'#25187#37325#26631#20934':0.5,'#25187#37325#27169#24335':'
        #21333#20215#12305#34920#31034#20132#20184#30340#36135#29289#20013'SiO'#27599#20302#20110#36136#37327#35201#27714'1%,'#21333#20215#38477#20302'0.5'#20803)
      ParentFont = False
      TabOrder = 15
      Height = 57
      Width = 417
    end
    object InfoList: TcxMCListBox
      Left = 23
      Top = 350
      Width = 121
      Height = 97
      HeaderSections = <
        item
          Text = #25351#26631#20540
          Width = 80
        end
        item
          Text = #26465#20214
          Width = 40
        end
        item
          Text = #20869#23481
          Width = 40
        end
        item
          Text = #25187#37325#26465#20214
          Width = 60
        end
        item
          Text = #25187#37325#20381#25454'(%)'
          Width = 65
        end
        item
          Text = #25187#37325#26631#20934
          Width = 60
        end
        item
          Text = #25187#37325#27169#24335
          Width = 60
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 16
    end
    object btnAdd: TcxButton
      Left = 338
      Top = 203
      Width = 75
      Height = 25
      Caption = #28155#21152#25351#26631
      TabOrder = 8
      OnClick = btnAddClick
    end
    object btnDel: TcxButton
      Left = 335
      Top = 233
      Width = 75
      Height = 25
      Caption = #21024#38500#25351#26631
      TabOrder = 11
      OnClick = btnDelClick
    end
    object dxLayout1Group_Root: TdxLayoutGroup
      AlignHorz = ahParentManaged
      AlignVert = avParentManaged
      CaptionOptions.Visible = False
      ButtonOptions.Buttons = <>
      Hidden = True
      ShowBorder = False
      object dxGroup1: TdxLayoutGroup
        AlignVert = avTop
        CaptionOptions.Text = #21512#21516#22522#26412#20449#24687
        SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
        SizeOptions.SizableHorz = True
        SizeOptions.SizableVert = True
        ButtonOptions.Buttons = <>
        object dxLayout1Item3: TdxLayoutItem
          CaptionOptions.Text = #20379#24212#21830
          Control = editProvider
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          CaptionOptions.Text = #21407#26448#26009
          Control = editMateriel
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ButtonOptions.Buttons = <>
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            AlignHorz = ahLeft
            CaptionOptions.Text = #21512#21516#32534#21495
            SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
            SizeOptions.SizableHorz = True
            SizeOptions.SizableVert = True
            SizeOptions.Width = 142
            Control = editContractno
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item6: TdxLayoutItem
            AlignHorz = ahLeft
            CaptionOptions.Text = #21333#20215
            SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
            SizeOptions.SizableHorz = True
            SizeOptions.SizableVert = True
            SizeOptions.Width = 102
            Control = editPrice
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item7: TdxLayoutItem
            AlignHorz = ahLeft
            CaptionOptions.Text = #25968#37327
            SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
            SizeOptions.SizableHorz = True
            SizeOptions.SizableVert = True
            SizeOptions.Width = 134
            Control = editQuantity
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item8: TdxLayoutItem
          AlignVert = avTop
          CaptionOptions.Text = #22791#27880
          SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
          SizeOptions.SizableHorz = True
          SizeOptions.SizableVert = True
          SizeOptions.Height = 55
          Control = editRemark
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup
        AlignVert = avTop
        CaptionOptions.Text = #21512#21516#25351#26631#20449#24687
        ButtonOptions.Buttons = <>
        object dxLayout1Group3: TdxLayoutGroup
          ButtonOptions.Buttons = <>
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item9: TdxLayoutItem
            CaptionOptions.Text = #25351#26631#21517
            SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
            SizeOptions.SizableHorz = True
            SizeOptions.SizableVert = True
            Control = comQuotaName
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item10: TdxLayoutItem
            CaptionOptions.Text = #25351#26631#26465#20214
            SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
            SizeOptions.SizableHorz = True
            SizeOptions.SizableVert = True
            SizeOptions.Width = 114
            Control = comQuotaCondition
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item18: TdxLayoutItem
            CaptionOptions.Text = 'cxButton1'
            CaptionOptions.Visible = False
            Control = btnAdd
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ButtonOptions.Buttons = <>
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item11: TdxLayoutItem
            CaptionOptions.Text = #25351#26631#20540
            SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
            SizeOptions.SizableHorz = True
            SizeOptions.SizableVert = True
            Control = comQuotaValue
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item12: TdxLayoutItem
            CaptionOptions.Text = #25187#37325#26465#20214
            SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
            SizeOptions.SizableHorz = True
            SizeOptions.SizableVert = True
            SizeOptions.Width = 111
            Control = comPunishCondition
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item19: TdxLayoutItem
            CaptionOptions.Text = 'cxButton2'
            CaptionOptions.Visible = False
            Control = btnDel
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group5: TdxLayoutGroup
          ButtonOptions.Buttons = <>
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item13: TdxLayoutItem
            AlignHorz = ahLeft
            CaptionOptions.Text = #25187#37325#20381#25454'(%)'
            SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
            SizeOptions.SizableHorz = True
            SizeOptions.SizableVert = True
            SizeOptions.Width = 121
            Control = editpunishBasis
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item14: TdxLayoutItem
            AlignHorz = ahLeft
            CaptionOptions.Text = #25187#37325#26631#20934
            SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
            SizeOptions.SizableHorz = True
            SizeOptions.SizableVert = True
            SizeOptions.Width = 117
            Control = editpunishStandard
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item15: TdxLayoutItem
            AlignHorz = ahLeft
            CaptionOptions.Text = #25187#37325#27169#24335
            SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
            SizeOptions.SizableHorz = True
            SizeOptions.SizableVert = True
            SizeOptions.Width = 125
            Control = comPunishMode
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item16: TdxLayoutItem
          Control = cxMemo2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item17: TdxLayoutItem
          Control = InfoList
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayout1Group1: TdxLayoutGroup
        AlignVert = avBottom
        CaptionOptions.Visible = False
        ButtonOptions.Buttons = <>
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayout1Item1: TdxLayoutItem
          AlignHorz = ahRight
          CaptionOptions.Text = 'Button1'
          CaptionOptions.Visible = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          AlignHorz = ahRight
          CaptionOptions.Text = 'Button2'
          CaptionOptions.Visible = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
