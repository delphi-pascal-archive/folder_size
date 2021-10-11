program FolderSize;

uses
  Forms,
  main in 'main.pas' {MainForm},
  folderinfo in 'folderinfo.pas',
  searchthread in 'searchthread.pas',
  UAbout in 'UAbout.pas' {AboutBox};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Folder SIZE';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
