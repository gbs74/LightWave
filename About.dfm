object AboutBox: TAboutBox
  Left = 547
  Top = 246
  BorderStyle = bsDialog
  Caption = 'About LightWave'
  ClientHeight = 213
  ClientWidth = 298
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 281
    Height = 161
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentColor = True
    TabOrder = 0
    object ProgramIcon: TImage
      Left = 8
      Top = 8
      Width = 57
      Height = 57
      Picture.Data = {
        055449636F6E0000010001002020100000000000E80200001600000028000000
        2000000040000000010004000000000080020000000000000000000000000000
        0000000000000000000080000080000000808000800000008000800080800000
        C0C0C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
        FFFFFF00000000000000000000000000000000000000000000000C0000000000
        000000000C0C0DDDDC00C00C0C0CC0CCCCCCC00000C0D99BBB0000000000C000
        9990CC000000CCC99900C00CC000000BBBBB0000000CC99990000000000000C0
        9990C000CC9BBBBBB00000CCCCCCC0CCCCCC0C0000CCC999900000099B99000D
        BBBD00000000000000C000CCCCCCC00C999C0C00000000000000000000000000
        CCC00C000C0C0CCCC0C00C000C0CCCCC0C00CC0000000BBBB00000000C000000
        000000000C0C09999C0C00C0000C00C00C00C00000000C0C000000000C000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000001111111111111111111111111111110055555555555555555555555
        5555555005555555555555555555555555555550055555555555555555555555
        5CCC5550055555555555555555555555CCCCC5500555CCCCCC5555555555555C
        CCCCC550055CCCCCCC5555555555555CCCCCCC5005CCCCCCCC55555CCCCC55CC
        CCCCCC500CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC00CCCCCCCCC55555CCCCC55CC
        CCCCCC5005CCCCCCCC5555555555555CCCCCC550055CCCCCC55555555555555C
        CCCCC550055555555555555555555555CCCC5550055555555555555555555555
        5555555005555555555555555555555555555550000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000}
      Proportional = True
      Stretch = True
      IsControl = True
    end
    object ProductName: TLabel
      Left = 88
      Top = 16
      Width = 86
      Height = 13
      Caption = 'About: LightWave'
      IsControl = True
    end
    object Version: TLabel
      Left = 88
      Top = 40
      Width = 62
      Height = 13
      Caption = 'Version: 1.00'
      IsControl = True
    end
    object Copyright: TLabel
      Left = 8
      Top = 80
      Width = 187
      Height = 13
      Caption = 'Copyright (c) Bogdan Sabac 1995-2019'
      IsControl = True
    end
    object Comments: TLabel
      Left = 8
      Top = 104
      Width = 192
      Height = 26
      Caption = 
        'PCM, Mono, 8 and 16 bit wav file editor. Built with Delphi 7.0 (' +
        '4.453 )'
      WordWrap = True
      IsControl = True
    end
  end
  object OKButton: TButton
    Left = 111
    Top = 180
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
