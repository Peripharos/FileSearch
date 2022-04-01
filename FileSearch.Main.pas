unit FileSearch.Main;

interface

uses
  SysUtils, Controls, Forms, Dialogs, StdCtrls, ExtCtrls, ImgList, Classes, ComCtrls, PageControls, Menus, ActnList;

type
  TFrmMain = class(TForm)
    ActClose: TAction;
    ActionList: TActionList;
    ActRename: TAction;
    ActShow: TAction;
    Anzeigen1: TMenuItem;
    BtnGo: TButton;
    ChbAllowFolder: TCheckBox;
    ChbAllowShortcut: TCheckBox;
    ChbOnlyFilename: TCheckBox;
    ChbRemoteDrive: TCheckBox;
    ChooseDirectory: TFileOpenDialog;
    DynPageControl: TDynPageControl;
    EdtDirectory: TEdit;
    EdtSearch: TEdit;
    ImageListChooseDirectory: TImageList;
    ImgChooseDirectory: TImage;
    LblSearch: TLabel;
    LblSearchDirectory: TLabel;
    N1: TMenuItem;
    PnlTop: TPanel;
    PopupMenu: TPopupMenu;
    Schlieen1: TMenuItem;
    Umbennen1: TMenuItem;
    procedure ActCloseExecute(Sender: TObject);
    procedure ActRenameExecute(Sender: TObject);
    procedure ActShowExecute(Sender: TObject);
    procedure BtnGoClick(Sender: TObject);
    procedure DynPageControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure EdtDirectoryChange(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ImgChooseDirectoryClick(Sender: TObject);
    procedure ImgChooseDirectoryMouseEnter(Sender: TObject);
    procedure ImgChooseDirectoryMouseLeave(Sender: TObject);
  private
    PopupTabIndex: Integer;
  public
    { Public-Deklarationen }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  Windows, FileSearch.Explorer, Registry;

{$R *.dfm}

{ TFrmMain }

procedure TFrmMain.FormCreate(Sender: TObject);
var
  Registry: TRegistry;
begin
  Caption:=Copy(ExtractFileName(Application.ExeName),0,length(ExtractFileName(Application.ExeName))-4);
  ImageListChooseDirectory.GetIcon(0,ImgChooseDirectory.Picture.Icon);
  Left:=(Screen.Width-Width)div 2;
  Top:=(Screen.Height-Height)div 2;
  Registry:=TRegistry.Create;
  try
    Registry.RootKey:=HKEY_CURRENT_USER;
    if Registry.KeyExists('Software\Peripharos\FileSearch') then begin
      Registry.OpenKey('Software\Peripharos\FileSearch',False);
      try
        ChbRemoteDrive.Checked:=Registry.ReadBool('RemoteDrive');
        ChbOnlyFilename.Checked:=Registry.ReadBool('OnlyFileName');
        ChbAllowFolder.Checked:=Registry.ReadBool('AllowFolder');
        ChbAllowShortcut.Checked:=Registry.ReadBool('AllowShortCut');
      except
        ChbRemoteDrive.Checked:=False;
        ChbOnlyFilename.Checked:=True;
        ChbAllowFolder.Checked:=True;
        ChbAllowShortcut.Checked:=False;
      end;
    end;
  finally
    Registry.Free;
  end;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
var
  Registry: TRegistry;
begin
  Registry:=TRegistry.Create;
  try
    Registry.RootKey:=HKEY_CURRENT_USER;
    Registry.OpenKey('Software\Peripharos\FileSearch',True);
    Registry.WriteBool('RemoteDrive',ChbRemoteDrive.Checked);
    Registry.WriteBool('OnlyFileName',ChbOnlyFilename.Checked);
    Registry.WriteBool('AllowFolder',ChbAllowFolder.Checked);
    Registry.WriteBool('AllowShortCut',ChbAllowShortcut.Checked);
  finally
    Registry.Free;
  end;
end;

procedure TFrmMain.FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
begin
  if (NewWidth<900) then
    NewWidth:=900;
end;

procedure TFrmMain.ImgChooseDirectoryClick(Sender: TObject);
begin
  if DirectoryExists(EdtDirectory.Text) then
    ChooseDirectory.DefaultFolder:=EdtDirectory.Text
  else
    ChooseDirectory.DefaultFolder:='C:\';
  if ChooseDirectory.Execute then
    EdtDirectory.Text:=ChooseDirectory.FileName;
end;

procedure TFrmMain.ImgChooseDirectoryMouseEnter(Sender: TObject);
begin
  ImageListChooseDirectory.GetIcon(1,ImgChooseDirectory.Picture.Icon);
end;

procedure TFrmMain.ImgChooseDirectoryMouseLeave(Sender: TObject);
begin
  ImageListChooseDirectory.GetIcon(0,ImgChooseDirectory.Picture.Icon);
end;

procedure TFrmMain.DynPageControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PopupTabIndex:=DynPageControl.IndexOfTabAt(X,Y);
end;

procedure TFrmMain.EdtDirectoryChange(Sender: TObject);
begin
  ChbRemoteDrive.Visible:=EdtDirectory.Text='Dieser PC';
end;

procedure TFrmMain.BtnGoClick(Sender: TObject);
var
  Explorer: TFrmExplorer;
begin
  if DirectoryExists(EdtDirectory.Text) or (EdtDirectory.Text='Dieser PC') then begin
    Explorer:=TFrmExplorer.Create(Self);
    Explorer.StartSearch(EdtDirectory.Text,EdtSearch.Text,ChbOnlyFilename.Checked,ChbAllowFolder.Checked,ChbAllowShortcut.Checked,ChbRemoteDrive.Checked);
    DynPageControl.ActivePage:=DynPageControl.AddPage(Explorer);
  end else
    raise Exception.Create('Pfad "'+EdtDirectory.Text+'" existiert nicht');
end;

procedure TFrmMain.ActShowExecute(Sender: TObject);
begin
  DynPageControl.ActivePage:=DynPageControl.Pages[PopupTabIndex];
end;

procedure TFrmMain.ActRenameExecute(Sender: TObject);
begin
  DynPageControl.RenamePage(DynPageControl.Pages[PopupTabIndex]);
end;

procedure TFrmMain.ActCloseExecute(Sender: TObject);
begin
  DynPageControl.DeletePage(DynPageControl.Pages[PopupTabIndex]);
end;

end.
