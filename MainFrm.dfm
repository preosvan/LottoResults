object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Check Lotto Results'
  ClientHeight = 554
  ClientWidth = 416
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnBottom: TPanel
    Left = 0
    Top = 513
    Width = 416
    Height = 41
    Align = alBottom
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 456
    DesignSize = (
      416
      41)
    object btnStop: TButton
      Left = 103
      Top = 6
      Width = 83
      Height = 25
      Action = actStop
      TabOrder = 0
    end
    object btnStart: TButton
      Left = 13
      Top = 6
      Width = 84
      Height = 25
      Action = actStart
      TabOrder = 1
    end
    object btnClose: TButton
      Left = 303
      Top = 6
      Width = 98
      Height = 25
      Action = actClearResults
      Anchors = [akTop, akRight]
      TabOrder = 2
      ExplicitLeft = 344
    end
    object edPeriod: TLabeledEdit
      Left = 248
      Top = 8
      Width = 41
      Height = 22
      EditLabel.Width = 47
      EditLabel.Height = 13
      EditLabel.Caption = 'Period, h:'
      LabelPosition = lpLeft
      MaxLength = 100
      NumbersOnly = True
      TabOrder = 3
      Text = '1'
      OnChange = edPeriodChange
      OnExit = edPeriodExit
    end
  end
  object pnClient: TPanel
    Left = 0
    Top = 0
    Width = 416
    Height = 513
    Align = alClient
    ParentBackground = False
    TabOrder = 1
    ExplicitWidth = 456
    object meProgress: TMemo
      Left = 1
      Top = 1
      Width = 414
      Height = 511
      Align = alClient
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object ActionList: TActionList
    Left = 16
    Top = 16
    object actStart: TAction
      Caption = 'Start'
      OnExecute = actStartExecute
    end
    object actStop: TAction
      Caption = 'Stop'
      OnExecute = actStopExecute
    end
    object actClearResults: TAction
      Caption = 'Clear Results'
      OnExecute = actClearResultsExecute
    end
  end
  object Timer: TTimer
    Enabled = False
    Interval = 3600000
    OnTimer = TimerTimer
    Left = 72
    Top = 17
  end
end
