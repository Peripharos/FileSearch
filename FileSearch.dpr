program FileSearch;

uses
  Forms,
  FileSearch.Main in 'FileSearch.Main.pas' {FrmMain},
  FileSearch.Explorer in 'FileSearch.Explorer.pas' {FrmExplorer};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
