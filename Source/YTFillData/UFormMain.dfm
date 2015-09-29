object fFormMain: TfFormMain
  Left = 572
  Top = 321
  Width = 926
  Height = 565
  Caption = #20113#22825#25968#25454#22635#20805
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Memo1: TMemo
    Left = 0
    Top = 41
    Width = 918
    Height = 497
    Align = alClient
    Lines.Strings = (
      #26412#31243#24207#29992#20110#22635#20805'XS_Lade_Base'#20013#23384#22312','#20294'DB_Turn_ProduOut'#27809#26377#30340#25968#25454'.')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 918
    Height = 41
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object BtnConn: TButton
      Left = 12
      Top = 8
      Width = 75
      Height = 25
      Caption = '1.conn'
      TabOrder = 0
      OnClick = BtnConnClick
    end
    object BtnFill: TButton
      Left = 95
      Top = 8
      Width = 75
      Height = 25
      Caption = '2.fill'
      TabOrder = 1
      OnClick = BtnFillClick
    end
  end
  object ADOConnection1: TADOConnection
    LoginPrompt = False
    Left = 200
    Top = 6
  end
  object Query1: TADOQuery
    Connection = ADOConnection1
    Parameters = <>
    Left = 228
    Top = 6
  end
  object ADOExec: TADOQuery
    Connection = ADOConnection1
    Parameters = <>
    Left = 256
    Top = 6
  end
end
