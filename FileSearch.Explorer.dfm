object FrmExplorer: TFrmExplorer
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 620
  ClientWidth = 905
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PnlTop: TPanel
    Left = 0
    Top = 0
    Width = 905
    Height = 41
    Align = alTop
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 900
    object LblSearchNameBefore: TLabel
      Left = 24
      Top = 9
      Width = 86
      Height = 19
      Caption = 'Suchbegriff:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LblSearchName: TLabel
      Left = 124
      Top = 9
      Width = 24
      Height = 19
      Caption = 'abc'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LblNumberFiles: TLabel
      Left = 818
      Top = 9
      Width = 9
      Height = 19
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LblNumberFilesBefore: TLabel
      Left = 753
      Top = 9
      Width = 59
      Height = 19
      Caption = 'Dateien:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LblSpecials: TLabel
      Left = 176
      Top = 14
      Width = 17
      Height = 13
      Caption = 'abc'
    end
  end
  object Status: TStatus
    Left = 0
    Top = 601
    Width = 905
    Height = 19
    Cursor = crArrow
    Hint = 'Abbruch? Hier klicken!'
    Panels = <
      item
        Width = 705
      end
      item
        Style = psOwnerDraw
        Width = 70
      end
      item
        Width = 70
      end
      item
        Style = psOwnerDraw
        Width = 60
      end>
    ExplicitWidth = 900
  end
  object PnlFilter: TPanel
    Left = 0
    Top = 41
    Width = 905
    Height = 24
    Align = alTop
    TabOrder = 2
    ExplicitWidth = 900
    object FilterShape: TShape
      Left = 1
      Top = 1
      Width = 31
      Height = 22
      Align = alLeft
      Brush.Color = clBtnFace
    end
    object EdtFilterFileText: TEdit
      Left = 284
      Top = 1
      Width = 621
      Height = 22
      Align = alLeft
      TabOrder = 0
      OnChange = EdtFilterFileTextChange
    end
    object EdtFilterFileName: TEdit
      Left = 32
      Top = 1
      Width = 201
      Height = 22
      Align = alLeft
      TabOrder = 1
      OnChange = EdtFilterFileNameChange
    end
    object EdtFilterFileExtension: TEdit
      Left = 233
      Top = 1
      Width = 51
      Height = 22
      Align = alLeft
      TabOrder = 2
      OnChange = EdtFilterFileExtensionChange
    end
  end
  object ActionList: TActionList
    Left = 264
    Top = 72
    object ActOpen: TAction
      Caption = #214'ffnen'
      OnExecute = ActOpenExecute
    end
    object ActOpenDir: TAction
      Caption = 'Ordner '#214'ffnen'
      OnExecute = ActOpenDirExecute
    end
    object ActCopy: TAction
      Caption = 'Pfad Kopieren'
      OnExecute = ActCopyExecute
    end
    object ActCopyDir: TAction
      Caption = 'Ordnerpfad Kopieren'
      OnExecute = ActCopyDirExecute
    end
    object ActCopyFilename: TAction
      Caption = 'Dateiname Kopieren'
      OnExecute = ActCopyFilenameExecute
    end
  end
  object PopupMenu: TPopupMenu
    Left = 200
    Top = 72
    object ffnen1: TMenuItem
      Action = ActOpen
    end
    object Ordnerffnen1: TMenuItem
      Action = ActOpenDir
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object PfadKopieren1: TMenuItem
      Action = ActCopy
    end
    object OrdnerpfadKopieren1: TMenuItem
      Action = ActCopyDir
    end
    object Ordnerffnen2: TMenuItem
      Action = ActCopyFilename
    end
  end
end
