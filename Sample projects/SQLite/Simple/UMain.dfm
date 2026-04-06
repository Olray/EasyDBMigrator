object frmMain: TfrmMain
  Left = 0
  Top = 0
  Margins.Left = 6
  Margins.Top = 6
  Margins.Right = 6
  Margins.Bottom = 6
  BorderStyle = bsToolWindow
  Caption = 'Simple_SQLite'
  ClientHeight = 946
  ClientWidth = 964
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -24
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 192
  TextHeight = 32
  object Label1: TLabel
    Left = 302
    Top = 84
    Width = 118
    Height = 32
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Caption = 'to version: '
  end
  object btnDowngradeDatabase: TButton
    Left = 16
    Top = 78
    Width = 274
    Height = 50
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Caption = 'Downgrade Database'
    TabOrder = 0
    OnClick = btnDowngradeDatabaseClick
  end
  object btnUpgradeDatabase: TButton
    Left = 302
    Top = 16
    Width = 274
    Height = 50
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Caption = 'Upgrade Database'
    TabOrder = 1
    OnClick = btnUpgradeDatabaseClick
  end
  object btnAddMigrations: TButton
    Left = 16
    Top = 16
    Width = 274
    Height = 50
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Caption = 'Add Migrations'
    TabOrder = 2
    OnClick = btnAddMigrationsClick
  end
  object edtVersion: TEdit
    Left = 418
    Top = 78
    Width = 164
    Height = 40
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    NumbersOnly = True
    TabOrder = 3
    Text = '5'
  end
  object mmoLog: TMemo
    Left = 11
    Top = 149
    Width = 930
    Height = 786
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object pbTotal: TProgressBar
    Left = 624
    Top = 16
    Width = 329
    Height = 34
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    TabOrder = 5
  end
end
