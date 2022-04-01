unit FileSearch.Explorer;   // sort nach ranks sortieren

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls, StdCtrls, Menus, ActnList,
  Contnrs, Grids, ComCtrls, Status, ImgList;

type
  TColumn = (clIcon,clName,clExtension,clDir);
  TSortType = (stNone,stAsc,stDesc);

  TMyDrawGrid = class;
  TSearchDirectoryThread = class;
  TFile = class;
  TFileList = class;
  TExtension = class;
  TExtensionList = class;
  TFilter = class;
  TSort = class;

  TCreateFileObject = procedure(const aPath: string) of object;
  TCreateExtensionObject = function(const aExtension: string; const aPicture: TPicture): Integer of object;
  TGetExtensionObject = function(const aIndex: Integer): TExtension of object;
  TEndFileSearch = procedure of object;

  TFrmExplorer = class(TForm)
    ActionList: TActionList;
    ActOpen: TAction;
    ActOpenDir: TAction;
    ffnen1: TMenuItem;
    LblNumberFiles: TLabel;
    LblNumberFilesBefore: TLabel;
    LblSearchName: TLabel;
    LblSearchNameBefore: TLabel;
    LblSpecials: TLabel;
    Ordnerffnen1: TMenuItem;
    PnlTop: TPanel;
    PopupMenu: TPopupMenu;
    Status: TStatus;
    ActCopyDir: TAction;
    ActCopy: TAction;
    ActCopyFilename: TAction;
    N1: TMenuItem;
    PfadKopieren1: TMenuItem;
    OrdnerpfadKopieren1: TMenuItem;
    Ordnerffnen2: TMenuItem;
    PnlFilter: TPanel;
    EdtFilterFileText: TEdit;
    FilterShape: TShape;
    EdtFilterFileName: TEdit;
    EdtFilterFileExtension: TEdit;
    procedure ActOpenDirExecute(Sender: TObject);
    procedure ActOpenExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ActCopyExecute(Sender: TObject);
    procedure ActCopyFilenameExecute(Sender: TObject);
    procedure ActCopyDirExecute(Sender: TObject);
    procedure EdtFilterFileNameChange(Sender: TObject);
    procedure EdtFilterFileExtensionChange(Sender: TObject);
    procedure EdtFilterFileTextChange(Sender: TObject);
  private
    Grid: TMyDrawGrid;
    FileList: TFileList;
    ExtensionList: TExtensionList;
    Filter: TFilter;
    Sort: TSort;
    SearchDirectoryThread: TSearchDirectoryThread;
    PopupFile: TFile;
    procedure SetLblSpecialFont;
    procedure CreateFileObject(const aPath: string);
    function CreateExtensionObject(const aExtension: string; const aPicture: TPicture): Integer;
    function GetExtensionObject(const aIndex: Integer): TExtension;
    procedure EndFileSearch;
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure GridDblClick(Sender: TObject);
    procedure GridContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure GridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GridColWidthsChanged(Sender: TObject);
  public
    procedure StartSearch(const aDirectory,aSearchName: string; const OnlyFileName,AllowFolder,AllowShortCut,RemoteDrive: Boolean);
  end;

  TMyDrawGrid = class(TDrawGrid)
  private
    FOnColWidthsChanged: TNotifyEvent;
  protected
    procedure ColWidthsChanged; override;
  public
    property OnColWidthsChanged: TNotifyEvent read FOnColWidthsChanged write FOnColWidthsChanged;
  end;
  
  TSearchDirectoryThread = class(TThread)
  protected
    procedure Execute; override;
  private
    FileObjectPath: string;
    FCreateFileObject: TCreateFileObject;
    FEndFileSearch: TEndFileSearch;
    procedure SyncCreateFileObject;
    procedure SyncEndFileSearch;
  public
    Directory: string;
    SearchName: string;
    OnlyFileName: Boolean;
    AllowFolder: Boolean;
    AllowShortCut: Boolean;
    RemoteDrive: Boolean;
    property CreateFileObject: TCreateFileObject read FCreateFileObject write FCreateFileObject;
    property EndFileSearch: TEndFileSearch read FEndFileSearch write FEndFileSearch;
  end;

  TFile = class(TObject)
  private
    FPath: string;
    FFileExtension: Integer;
    FFileName: string;
    FFileDir: string;
    FCreateExtensionObject: TCreateExtensionObject;
    FGetExtensionObject: TGetExtensionObject;
    function GetFileExtension: TExtension;
  public
    procedure Init(const aPath: string);
    property Path: string read FPath;
    property FileExtension: TExtension read GetFileExtension;
    property FileName: string read FFileName;
    property FileDir: string read FFileDir;
    property CreateExtensionObject: TCreateExtensionObject read FCreateExtensionObject write FCreateExtensionObject;
    property GetExtensionObject: TGetExtensionObject read FGetExtensionObject write FGetExtensionObject;
  end;

  TFileList = class(TObjectList)
  private
    function Get(Index: Integer): TFile;
  public
    function Add(aFile: TFile): Integer;
    property Items[Index: Integer]: TFile read Get; default;
  end;

  TExtension = class(TObject)
  private
    ImageID: Integer;
    FExtension: string;
    FIcon: TGraphic;
  public
    constructor Create(const aExtension: string; const aPicture: TPicture);
    property Extension: string read FExtension;
    property Icon: TGraphic read FIcon;
  end;

  TExtensionList = class(TObjectList)
  private
    function Get(Index: Integer): TExtension;
  public
    function Find(const aExtension: string; out Index: Integer): Boolean;
    function Add(aExtension: TExtension): Integer;
    property Items[Index: Integer]: TExtension read Get; default;
  end;

  TFilter = class(TObject)
  private
    type
      TArgument = class(TObject)
      private
        FColumn: TColumn;
        FValue: string;
      public
        constructor Create(const aColumn: TColumn; const aValue: string);
        property Column: TColumn read FColumn;
        property Value: string read FValue write FValue;
      end;

      TArgumentList = class(TObjectList)
      private
        function Get(Index: Integer): TArgument;
      public
        function Find(const aColumn: TColumn; out Index: Integer): Boolean;
        function Add(aArgument: TArgument): Integer;
        property Items[Index: Integer]: TArgument read Get; default;
      end;
    var
      ArgumentList: TArgumentList;
  public
    constructor Create;
    destructor Destroy;
    procedure SetFilter(const aColumn: TColumn; const aValue: string);
    function GetFilteredFileList(const aFileList: TFileList): TFileList;
  end;

  TSort = class(Tobject)
  private
    type
      TArgument = class(Tobject)
      private
        FColumn: TColumn;
        FSortType: TSortType;
      public
        constructor Create(const aColumn: TColumn; const aOrderType: TSortType);
        property Column: TColumn read FColumn;
        property SortType: TSortType read FSortType write FSortType;
      end;

      TArgumentList = class(TObjectList)
      private
        function Get(Index: Integer): TArgument;
      public
        function Find(const aColumn: TColumn; out Index: Integer): Boolean;
        function Add(aArgument: TArgument): Integer;
        property Items[Index: Integer]: TArgument read Get; default;
      end;
    var
      ArgumentList: TArgumentList;
  public
    constructor Create;
    destructor Destroy;
    procedure SetSorting(const aColumn: TColumn);
    function GetSortType(const aColumn: TColumn): TSortType;
    function GetSotedFileList(const aFileList: TFileList): TFileList;
  end;

var
  FrmExplorer: TFrmExplorer;

implementation

uses
  StrUtils, ShellAPI, FileUtils, Clipbrd, Dialogs;

{$R *.dfm}

{ TFrmExplorer }

procedure TFrmExplorer.FormCreate(Sender: TObject);
begin
  FileList:=TFileList.Create;
  ExtensionList:=TExtensionList.Create;
  Filter:=TFilter.Create;
  Sort:=TSort.Create;
  Grid:=TMyDrawGrid.Create(Self);
  Grid.Align:=alClient;
  Grid.Parent:=Self;
  Grid.ColCount:=4;
  Grid.DefaultColWidth:=30;
  Grid.FixedCols:=0;
  Grid.Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goColSizing,goRowSelect];
  Grid.RowCount:=2;
  Grid.ScrollBars:=ssVertical;
  Grid.OnDrawCell:=GridDrawCell;
  Grid.OnDblClick:=GridDblClick;
  Grid.OnContextPopup:=GridContextPopup;
  Grid.OnMouseUp:=GridMouseUp;
  Grid.OnColWidthsChanged:=GridColWidthsChanged;
  Grid.ColWidths[1]:=200;
  Grid.ColWidths[2]:=50;
  Grid.ColWidths[3]:=Width-280;
end;

procedure TFrmExplorer.FormDestroy(Sender: TObject);
begin
  Sort.Free;
  Filter.Free;
  ExtensionList.Free;
  FileList.Free;
end;

procedure TFrmExplorer.StartSearch(const aDirectory, aSearchName: string; const OnlyFileName,AllowFolder,AllowShortCut,RemoteDrive: Boolean);

  function GetCaption: string;
  begin
    if aDirectory = 'Dieser PC' then
      Result:='"'+aSearchName+'" '+IntToStr(ord(RemoteDrive))+','+IntToStr(ord(OnlyFileName))+','+IntToStr(ord(AllowFolder))+','+IntToStr(ord(AllowShortCut))
    else
      Result:='"'+aSearchName+'" '+IntToStr(ord(OnlyFileName))+','+IntToStr(ord(AllowFolder))+','+IntToStr(ord(AllowShortCut));
  end;

  function GetSpecials: string;
  var
    s: string;
  begin
    s:='';
    if not RemoteDrive and (aDirectory = 'Dieser PC') then
      s:=s+' keine Netzlaufwerke,';
    if OnlyFileName then
      s:=s+' nur Dateinamen,';
    if not AllowFolder then
      s:=s+' keine Ordner,';
    if not AllowShortCut then
      s:=s+' keine Verknüpfungen,';
    Result:=Copy(s,1,Length(s)-1);
  end;

begin
  Caption:=GetCaption;
  LblSearchName.Caption:='"'+aSearchName+'"';
  LblSpecials.Caption:=GetSpecials;
  LblSpecials.Left:=LblSearchName.Left+LblSearchName.Width+20;
  SetLblSpecialFont;
  SearchDirectoryThread:=TSearchDirectoryThread.Create(true);
  SearchDirectoryThread.FreeOnTerminate:=True;
  SearchDirectoryThread.Directory:=aDirectory;
  SearchDirectoryThread.SearchName:=aSearchName;
  SearchDirectoryThread.OnlyFileName:=OnlyFileName;
  SearchDirectoryThread.AllowFolder:=AllowFolder;
  SearchDirectoryThread.AllowShortCut:=AllowShortCut;
  SearchDirectoryThread.RemoteDrive:=RemoteDrive;
  SearchDirectoryThread.CreateFileObject:=CreateFileObject;
  SearchDirectoryThread.EndFileSearch:=EndFileSearch;
  Status.BeginWork;
  SearchDirectoryThread.Resume;
end;

procedure TFrmExplorer.FormResize(Sender: TObject);
begin
  LblNumberFiles.Left:=Width-100;
  LblNumberFilesBefore.Left:=Width-165;
  Grid.ColWidths[3]:=Width-(Grid.ColWidths[0]+Grid.ColWidths[1]+Grid.ColWidths[2]);
  EdtFilterFileText.Width:=Width-(Grid.ColWidths[0]+Grid.ColWidths[1]+Grid.ColWidths[2]+5);
  SetLblSpecialFont;
end;

procedure TFrmExplorer.SetLblSpecialFont;
begin
  LblSpecials.Font.Size:=10;
  while LblSpecials.Left+LblSpecials.Width > LblNumberFilesBefore.Left-20 do
    LblSpecials.Font.Size:=LblSpecials.Font.Size-1;
  LblSpecials.Top:=(LblSearchName.Top+LblSearchName.Height)-LblSpecials.Height;  
end;

procedure TFrmExplorer.CreateFileObject(const aPath: string);
var
  aFile: Tfile;
begin
  aFile:=TFile.Create;
  aFile.CreateExtensionObject:=CreateExtensionObject;
  aFile.GetExtensionObject:=GetExtensionObject;
  aFile.Init(aPath);
  FileList.Add(aFile);
  Grid.RowCount:=Filter.GetFilteredFileList(FileList).Count+1;
  LblNumberFiles.Caption:=IntToStr(Filter.GetFilteredFileList(FileList).Count)+'/'+IntToStr(FileList.Count);
end;

function TFrmExplorer.CreateExtensionObject(const aExtension: string; const aPicture: TPicture): Integer;
begin
  if not ExtensionList.Find(aExtension,Result) then
    Result:=ExtensionList.Add(TExtension.Create(aExtension,aPicture));
end;

function TFrmExplorer.GetExtensionObject(const aIndex: Integer): TExtension;
begin
  Result:=ExtensionList[aIndex];
end;

procedure TFrmExplorer.EndFileSearch;
begin
  Status.EndWork;
end;

procedure TFrmExplorer.GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);

  procedure DrawAscPolygon;
  var
    PointPolygon1: TPoint;
    PointPolygon2: TPoint;
    PointPolygon3: TPoint;
    OldPenColor: TColor;
    OldBrushColor: TColor;
  begin
    PointPolygon1.X:=Rect.Left + ((Rect.Right-Rect.Left-4)div 2);
    PointPolygon1.Y:=Rect.Top+4;
    PointPolygon2.X:=Rect.Left + ((Rect.Right-Rect.Left+4)div 2);
    PointPolygon2.Y:=Rect.Top+4;
    PointPolygon3.X:=Rect.Left + ((Rect.Right-Rect.Left)div 2);
    PointPolygon3.Y:=Rect.Top+2;
    OldPenColor:=Grid.Canvas.Pen.Color;
    OldBrushColor:=Grid.Canvas.Brush.Color;
    Grid.Canvas.Pen.Color:=clBlack;
    Grid.Canvas.Brush.Color:=clBlack;
    Grid.Canvas.Polygon([PointPolygon1,PointPolygon2,PointPolygon3]);
    Grid.Canvas.Pen.Color:=OldPenColor;
    Grid.Canvas.Brush.Color:=OldBrushColor;
  end;

  procedure DrawDescPolygon;
  var
    PointPolygon1: TPoint;
    PointPolygon2: TPoint;
    PointPolygon3: TPoint;
    OldPenColor: TColor;
    OldBrushColor: TColor;
  begin
    PointPolygon1.X:=Rect.Left + ((Rect.Right-Rect.Left-4)div 2);
    PointPolygon1.Y:=Rect.Top+2;
    PointPolygon2.X:=Rect.Left + ((Rect.Right-Rect.Left+4) div 2);
    PointPolygon2.Y:=Rect.Top+2;
    PointPolygon3.X:=Rect.Left + ((Rect.Right-Rect.Left) div 2);
    PointPolygon3.Y:=Rect.Top+4;
    OldPenColor:=Grid.Canvas.Pen.Color;
    OldBrushColor:=Grid.Canvas.Brush.Color;
    Grid.Canvas.Pen.Color:=clBlack;
    Grid.Canvas.Brush.Color:=clBlack;
    Grid.Canvas.Polygon([PointPolygon1,PointPolygon2,PointPolygon3]);
    Grid.Canvas.Pen.Color:=OldPenColor;
    Grid.Canvas.Brush.Color:=OldBrushColor;
  end;

var
  s: string;
  FilteredFileList: TFileList;
begin
  FilteredFileList:=Sort.GetSotedFileList(Filter.GetFilteredFileList(FileList));
  if FilteredFileList.Count<ARow then
    Exit;
  case ACol of
    0:begin
      if ARow=0 then begin
        s:='Icon';
        Grid.Canvas.TextRect(Rect,s,[tfSingleLine,tfCenter,tfVerticalCenter]);
        case Sort.GetSortType(clIcon) of
          stAsc: DrawAscPolygon;
          stDesc: DrawDescPolygon; 
        end;
      end else begin
        Grid.Canvas.Draw(Rect.Left+5,Rect.Top+5,FilteredFileList[ARow-1].GetFileExtension.Icon);
      end;
    end;
    1:begin
      if ARow=0 then begin
        s:='Name';
        Grid.Canvas.TextRect(Rect,s,[tfSingleLine,tfCenter,tfVerticalCenter]);
        case Sort.GetSortType(clName) of
          stAsc: DrawAscPolygon;
          stDesc: DrawDescPolygon; 
        end;
      end else begin
        s:=' '+FilteredFileList[ARow-1].FileName;
        Grid.Canvas.TextRect(Rect,s,[tfSingleLine,tfLeft,tfVerticalCenter]);
      end;
    end;
    2:begin
      if ARow=0 then begin
        s:='Dateityp';
        Grid.Canvas.TextRect(Rect,s,[tfSingleLine,tfCenter,tfVerticalCenter]);
        case Sort.GetSortType(clExtension) of
          stAsc: DrawAscPolygon;
          stDesc: DrawDescPolygon; 
        end;      
      end else begin
        s:=' '+FilteredFileList[ARow-1].GetFileExtension.Extension;
        Grid.Canvas.TextRect(Rect,s,[tfSingleLine,tfLeft,tfVerticalCenter]);
      end;
    end;
    3:begin
       if ARow=0 then begin
        s:='Ordnerpfad';
        Grid.Canvas.TextRect(Rect,s,[tfSingleLine,tfCenter,tfVerticalCenter]);
        case Sort.GetSortType(clDir) of
          stAsc: DrawAscPolygon;
          stDesc: DrawDescPolygon; 
        end;
      end else begin
        s:=' '+FilteredFileList[ARow-1].FileDir;
        Grid.Canvas.TextRect(Rect,s,[tfSingleLine,tfLeft,tfVerticalCenter]);
      end;
    end;
  end;
end;

procedure TFrmExplorer.GridContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:=True;
end;

procedure TFrmExplorer.GridDblClick(Sender: TObject);
begin
  ShellExecute(Handle,'open',PChar(FileList[Grid.Row-1].Path),nil,nil,SW_NORMAL)
end;

procedure TFrmExplorer.GridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button=mbRight)and(Grid.MouseCoord(X,Y).Y>0) then begin
    Grid.Row:=Grid.MouseCoord(X,Y).Y;
    Grid.Repaint;
    PopupFile:=FileList[Grid.MouseCoord(X,Y).Y-1];
    PopupMenu.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
  end;
  if (Button=mbLeft)and(Grid.MouseCoord(X,Y).Y=0) then begin
    case Grid.MouseCoord(X,Y).X of
      1: Sort.SetSorting(clName);
      2: Sort.SetSorting(clExtension);
      3: Sort.SetSorting(clDir);     
    end;
    Grid.Repaint;
  end;
end;

procedure TFrmExplorer.GridColWidthsChanged(Sender: TObject);
begin
  FilterShape.Width:=Grid.ColWidths[0]+1;
  EdtFilterFileName.Width:=Grid.ColWidths[1]+1;
  EdtFilterFileExtension.Width:=Grid.ColWidths[2]+1;
  Grid.ColWidths[3]:=Width-(Grid.ColWidths[0]+Grid.ColWidths[1]+Grid.ColWidths[2]);
  EdtFilterFileText.Width:=Width-(Grid.ColWidths[0]+Grid.ColWidths[1]+Grid.ColWidths[2]+5);
end;

procedure TFrmExplorer.ActOpenDirExecute(Sender: TObject);
begin
  ShellExecute(Handle,'open',PChar(PopupFile.FileDir),nil,nil,SW_NORMAL)
end;

procedure TFrmExplorer.ActOpenExecute(Sender: TObject);
begin
  ShellExecute(Handle,'open',PChar(PopupFile.Path),nil,nil,SW_NORMAL)
end;

procedure TFrmExplorer.ActCopyExecute(Sender: TObject);
begin
  ClipBoard.AsText:=PopupFile.Path;
end;

procedure TFrmExplorer.ActCopyDirExecute(Sender: TObject);
begin
  ClipBoard.AsText:=PopupFile.FileDir;
end;

procedure TFrmExplorer.ActCopyFilenameExecute(Sender: TObject);
begin
  ClipBoard.AsText:=PopupFile.FileName;
end;

procedure TFrmExplorer.EdtFilterFileNameChange(Sender: TObject);
begin
  Filter.SetFilter(clName,EdtFilterFileName.Text);
  Grid.RowCount:=Filter.GetFilteredFileList(FileList).Count+1;
  Grid.Repaint;
  LblNumberFiles.Caption:=IntToStr(Filter.GetFilteredFileList(FileList).Count)+'/'+IntToStr(FileList.Count);
end;

procedure TFrmExplorer.EdtFilterFileExtensionChange(Sender: TObject);
begin
  Filter.SetFilter(clExtension,EdtFilterFileExtension.Text);
  Grid.RowCount:=Filter.GetFilteredFileList(FileList).Count+1;
  Grid.Repaint;
  LblNumberFiles.Caption:=IntToStr(Filter.GetFilteredFileList(FileList).Count)+'/'+IntToStr(FileList.Count);
end;

procedure TFrmExplorer.EdtFilterFileTextChange(Sender: TObject);
begin
  Filter.SetFilter(clDir,EdtFilterFileText.Text);
  Grid.RowCount:=Filter.GetFilteredFileList(FileList).Count+1;
  Grid.Repaint;
  LblNumberFiles.Caption:=IntToStr(Filter.GetFilteredFileList(FileList).Count)+'/'+IntToStr(FileList.Count);
end;

{ TMyDrawGrid }

procedure TMyDrawGrid.ColWidthsChanged;
begin
  inherited;
  if Assigned(FOnColWidthsChanged) then
    FOnColWidthsChanged(Self);
end;

{ TSearchDirectoryThread }

procedure TSearchDirectoryThread.Execute;

  function GetFiles(const aDirectory: string): TStringList;
  var
    I: Integer;
  begin
    Result:=TStringList.Create;
    if AllowFolder then
       DirectoryScan(aDirectory,Result,DirScanParams([dsoNoSubFolders,dsoVerifyFolders]))
     else
      DirectoryScan(aDirectory,Result,DirScanParams([dsoNoSubFolders]));
    I:=0;
    while Result.Count>I do begin
      if (SearchName='') or
         (((AnsiContainsText(Result[I],SearchName) and not OnlyFileName) or
           (AnsiContainsText(ExtractFileName(Result[I]),SearchName) and OnlyFileName)) and
          (AllowShortCut or (AnsiRightStr(Result[I],4)<>'.lnk'))) then
        Inc(I)
      else
        Result.Delete(I);
    end;
  end;

  procedure SearchDirectory(const aDirectory: string);
  var
    Files: TStringList;
    Subdirectorys: TStringList;
    I: Integer;
  begin
    Files:=GetFiles(aDirectory);
    try
      for I:=0 to Files.Count-1 do begin
        FileObjectPath:=Files[I];
        Synchronize(SyncCreateFileObject);
      end;
    finally
      Files.Free;
    end;
     Subdirectorys:=TStringList.Create;
     try
       DirectoryScan(aDirectory,Subdirectorys,DirScanParams([dsoNoSubFolders,dsoVerifyFolders]));
       for I:=0 to Subdirectorys.Count-1 do
         if not AnsiContainsStr(Subdirectorys[I],'.') then
           SearchDirectory(Subdirectorys[I]);
    finally
      Subdirectorys.Free;
    end;
  end;

var
  Drive:Char;
begin
  if Directory='Dieser PC' then begin
    for Drive:='A'to'Z' do
      if (GetDriveType(PChar(Drive+':/'))=DRIVE_FIXED) or ((RemoteDrive)and(GetDriveType(PChar(Drive+':/'))=DRIVE_REMOTE)) then
        SearchDirectory(Drive+':\');
  end else
    SearchDirectory(Directory);
  Synchronize(SyncEndFileSearch);
end;

procedure TSearchDirectoryThread.SyncCreateFileObject;
begin
  if Assigned(FCreateFileObject) then
    FCreateFileObject(FileObjectPath);
end;

procedure TSearchDirectoryThread.SyncEndFileSearch;
begin
  if Assigned(FEndFileSearch) then
    FEndFileSearch;
end;

{ TFile }

procedure TFile.Init(const aPath: string);
var
  FileInfo: SHFILEINFO;
  Picture: TPicture;
begin
  FPath:=aPath;
  Picture:=TPicture.Create;
  SHGetFileInfo(PChar(Path), 0, FileInfo,
      SizeOf(FileInfo), SHGFI_ICON or SHGFI_SMALLICON);
  Picture.Icon.Handle:=FileInfo.hIcon;
  if Assigned(FCreateExtensionObject) then
    FFileExtension:=FCreateExtensionObject(ExtractFileExt(Path),Picture);
  FFileName:=ExtractFilePart(Path);
  FFileDir:=ExtractFilePath(Path);
end;

function TFile.GetFileExtension: TExtension;
begin
  if Assigned(FGetExtensionObject) then
    Result:=FGetExtensionObject(FFileExtension);
end;

{ TFileList }

function TFileList.Add(aFile: TFile): Integer;
begin
  Result:=inherited Add(aFile);
end;

function TFileList.Get(Index: Integer): TFile;
begin
  Result:=TFile(inherited Get(Index));
end;

{ TExtension }

constructor TExtension.Create(const aExtension: string; const aPicture: TPicture);
begin
  FExtension:=aExtension;
  if FExtension='' then
    FExtension:='Folder';
  FIcon:= aPicture.Graphic;
end;

{ TExtensionList }

function TExtensionList.Add(aExtension: TExtension): Integer;
begin
  Result:=inherited Add(aExtension);
end;

function TExtensionList.Find(const aExtension: string; out Index: Integer): Boolean;
var
  I: Integer;
begin
  Result:=False;
  Index:=-1;
  for I:=0 to Count-1 do begin
    if Items[I].FExtension=aExtension then begin
      Index:=I;
      Result:=True;
      Exit;
    end;
  end;
end;

function TExtensionList.Get(Index: Integer): TExtension;
begin
  Result:=TExtension(inherited Get(Index));
end;

{ TFilter }

constructor TFilter.Create;
begin
  ArgumentList:=TArgumentList.Create;
end;

destructor TFilter.Destroy;
begin
  ArgumentList.Free;
end;

procedure TFilter.SetFilter(const aColumn: TColumn; const aValue: string);
var
  Index: Integer;
begin
  if ArgumentList.Find(aColumn,Index) then begin
    ArgumentList[Index].Value:=aValue;
  end else begin
    ArgumentList.Add(TArgument.Create(aColumn,aValue));
  end;
end;

function TFilter.GetFilteredFileList(const aFileList: TFileList): TFileList;
var
  I: Integer;
  K: Integer;
  Add: Boolean;
begin
  Result:=TFileList.Create;
  for I:=0 to aFileList.Count-1 do begin
    Add:=True;
    for K:=0 to ArgumentList.Count-1 do begin
      case ArgumentList[K].Column of
        clName: begin
          if (ArgumentList[K].Value<>'') and
             (not AnsiContainsText(aFileList[I].FileName,ArgumentList[K].Value)) then
            Add:=False;
        end;
        clExtension: begin
          if (ArgumentList[K].Value<>'') and
             (not AnsiContainsText(aFileList[I].FileExtension.Extension,ArgumentList[K].Value)) then
            Add:=False;
        end;
        clDir: begin
          if (ArgumentList[K].Value<>'') and
             (not AnsiStartsText(ArgumentList[K].Value,aFileList[I].FileDir)) then
            Add:=False;
        end;
      end;
    end;
    if Add then
      Result.Add(aFileList[I]);
  end;
end;

{ TFilter.TArgument }

constructor TFilter.TArgument.Create(const aColumn: TColumn; const aValue: string);
begin
  FColumn:=aColumn;
  FValue:=aValue;
end;

{ TFilter.TArgumentList }

function TFilter.TArgumentList.Add(aArgument: TArgument): Integer;
begin
  Result:=inherited Add(aArgument);
end;

function TFilter.TArgumentList.Find(const aColumn: TColumn; out Index: Integer): Boolean;
var
  I: Integer;
begin
  Result:=False;
  Index:=-1;
  for I:=0 to Count-1 do begin
    if Items[I].FColumn=aColumn then begin
      Index:=I;
      Result:=True;
      Exit;
    end;
  end;
end;

function TFilter.TArgumentList.Get(Index: Integer): TArgument;
begin
  Result:=TArgument(inherited Get(Index));
end;

{ TSort }

constructor TSort.Create;
begin
  ArgumentList:=TArgumentList.Create;
end;

destructor TSort.Destroy;
begin
  ArgumentList.Free;
end;

procedure TSort.SetSorting(const aColumn: TColumn);
var
  Index: Integer;
begin
  if ArgumentList.Find(aColumn,Index) then begin
    case ArgumentList[Index].SortType of
      stNone: ArgumentList[Index].SortType:=stAsc;  
      stAsc: ArgumentList[Index].SortType:=stDesc;  
      stDesc: ArgumentList[Index].SortType:=stNone;  
    end;
  end else begin
    ArgumentList.Add(TArgument.Create(aColumn,stAsc));
  end;
end;

function TSort.GetSortType(const aColumn: TColumn): TSortType;
var
  Index: Integer;
begin
  if ArgumentList.Find(aColumn,Index) then begin
    Result:=ArgumentList[Index].SortType;  
  end else begin
    Result:=stNone;
  end;
end;

function TSort.GetSotedFileList(const aFileList: TFileList): TFileList;
var
  SortedFileList: TFileList;
  
  procedure QuickSort(const SectionStart,SectionEnd: Integer; const SortValue: TColumn; Desc: Boolean);
  type
    TCompareType = (ctLower,ctLowerEqual,ctBigger,ctBiggerEqual,ctEqual);

    function Compare(const File1,File2: TFile; const CompareType: TCompareType; const Desc: Boolean): Boolean;
    begin
      case CompareType of
        ctLower: begin
          case SortValue of
            clName: Result:=(AnsiUpperCase(File1.FileName)<AnsiUpperCase(File2.FileName));
            clExtension: Result:=(AnsiUpperCase(File1.GetFileExtension.Extension)<AnsiUpperCase(File2.GetFileExtension.Extension));
            clDir: Result:=(AnsiUpperCase(File1.FileDir)<AnsiUpperCase(File2.FileDir));
          end;
        end;
        ctLowerEqual: begin
          case SortValue of
            clName: Result:=(AnsiUpperCase(File1.FileName)<=AnsiUpperCase(File2.FileName));
            clExtension: Result:=(AnsiUpperCase(File1.GetFileExtension.Extension)<=AnsiUpperCase(File2.GetFileExtension.Extension));
            clDir: Result:=(AnsiUpperCase(File1.FileDir)<=AnsiUpperCase(File2.FileDir));
          end;
        end;
        ctBigger: begin
          case SortValue of
            clName: Result:=(AnsiUpperCase(File1.FileName)>AnsiUpperCase(File2.FileName));
            clExtension: Result:=(AnsiUpperCase(File1.GetFileExtension.Extension)>AnsiUpperCase(File2.GetFileExtension.Extension));
            clDir: Result:=(AnsiUpperCase(File1.FileDir)>AnsiUpperCase(File2.FileDir));
          end;
        end;
        ctBiggerEqual: begin
          case SortValue of
            clName: Result:=(AnsiUpperCase(File1.FileName)>=AnsiUpperCase(File2.FileName));
            clExtension: Result:=(AnsiUpperCase(File1.GetFileExtension.Extension)>=AnsiUpperCase(File2.GetFileExtension.Extension));
            clDir: Result:=(AnsiUpperCase(File1.FileDir)>=AnsiUpperCase(File2.FileDir));
          end;
        end;
        ctEqual: begin
          case SortValue of
            clName: Result:=(AnsiUpperCase(File1.FileName)=AnsiUpperCase(File2.FileName));
            clExtension: Result:=(AnsiUpperCase(File1.GetFileExtension.Extension)=AnsiUpperCase(File2.GetFileExtension.Extension));
            clDir: Result:=(AnsiUpperCase(File1.FileDir)=AnsiUpperCase(File2.FileDir));
          end;
        end;
      end;
      if Desc then
        Result:=not Result;
    end;

    function Divide(const SectionStart,SectionEnd: Integer; const Desc: Boolean): Integer;
    var
      I,K: Integer;
      DividerValue: TFile;
    begin
      I:=SectionStart;
      K:=SectionEnd-1;
      DividerValue:=SortedFileList[SectionEnd];

      while I<K do begin
        while (I<SectionEnd) and Compare(SortedFileList[I],DividerValue,ctLower,Desc) do
          Inc(I);
        while (K>SectionStart) and Compare(SortedFileList[K],DividerValue,ctBiggerEqual,Desc) do
          Dec(K);
        if I<K then
          SortedFileList.Exchange(I,K);
      end;
      if Compare(SortedFileList[I],DividerValue,ctBigger,Desc) then
        SortedFileList.Exchange(I,SectionEnd);
      Result:=I;  
    end;

  var
    Divider: Integer;
  begin
    if SectionStart<SectionEnd then begin
      Divider:=Divide(SectionStart,SectionEnd,Desc);
      QuickSort(SectionStart,Divider-1,SortValue,Desc);
      QuickSort(Divider+1,SectionEnd,SortValue,Desc);       
    end;
  end;

var
  I: Integer;
  Desc: Boolean;
begin
  SortedFileList:=TFileList.Create;
  for I:=0 to aFileList.Count-1 do
    SortedFileList.Add(aFileList[I]);
  for I:=0 to ArgumentList.Count-1 do begin
    case ArgumentList[I].SortType of
      stAsc: QuickSort(0,SortedFileList.Count-1,ArgumentList[I].Column,false);
      stDesc: QuickSort(0,SortedFileList.Count-1,ArgumentList[I].Column,true);
    end;
  end;
  Result:=SortedFileList;
end;

{ TSort.TArgument }

constructor TSort.TArgument.Create(const aColumn: TColumn; const aOrderType: TSortType);
begin
  FColumn:=aColumn;
  FSortType:=aOrderType;
end;

{ TSort.TArgumentList }

function TSort.TArgumentList.Add(aArgument: TArgument): Integer;
begin
  Result:=inherited Add(aArgument);
end;

function TSort.TArgumentList.Find(const aColumn: TColumn; out Index: Integer): Boolean;
var
  I: Integer;
begin
  Result:=False;
  Index:=-1;
  for I:=0 to Count-1 do begin
    if Items[I].FColumn=aColumn then begin
      Index:=I;
      Result:=True;
      Exit;
    end;
  end;
end;

function TSort.TArgumentList.Get(Index: Integer): TArgument;
begin
  Result:=TArgument(inherited Get(Index));
end;

end.
