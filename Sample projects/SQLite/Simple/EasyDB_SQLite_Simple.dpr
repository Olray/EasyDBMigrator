program EasyDB_SQLite_Simple;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {frmMain},
  EasyDB.SQLiteRunner in '..\..\..\Lib\Runners\EasyDB.SQLiteRunner.pas',
  EasyDB.ConnectionManager.SQLite in '..\..\..\Lib\ConnectionManagers\EasyDB.ConnectionManager.SQLite.pas',
  EasyDB.Core in '..\..\..\Lib\Core\EasyDB.Core.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  ReportMemoryLeaksOnShutdown := True;
  Application.Run;
end.
