{***************************************************}
{                                                   }
{   Author: Ali Dehbansiahkarbon(adehban@gmail.com) }
{   SQLite: Olray Dragon (prog@allanime.org)        }
{   GitHub: https://github.com/Olray/EasyDBMigrator }
{                                                   }
{***************************************************}
unit EasyDB.SQLiteRunner;

interface

uses
  System.SysUtils, System.StrUtils,
  EasyDB.Core,
  EasyDB.Consts,
  EasyDB.Migration,
  EasyDB.MigrationX,
  EasyDB.Runner,
  EasyDB.Logger,
  EasyDB.ConnectionManager.SQLite;

type
  TSQLiteRunner = class(TRunner)
  private
    FSchema: string;
    FSQLiteConnection: TSQLiteConnection;
  protected
    procedure UpdateVersionInfo(AMigration: TMigrationBase; AInsertMode: Boolean = True); override;
    procedure DownGradeVersionInfo(AVersionToDownGrade: Int64); override;
    function GetDatabaseVersion: Int64; override;
  public
    constructor Create(AConnectionParams: TSQLiteConnectionParams; ALoggerEventHandler: TLoggerEventHandler = nil); overload;
    constructor Create(AConnectionParams: TSQLiteConnectionParams; ALocalLogFile: string); overload;
    destructor Destroy; override;

    property SQLite: TSQLiteConnection read FSQLiteConnection write FSQLiteConnection;
    property Schema: string read FSchema write FSchema;
  end;

implementation

{ TMySQLRunner }

constructor TSQLiteRunner.Create(AConnectionParams: TSQLiteConnectionParams; ALoggerEventHandler: TLoggerEventHandler);
begin
  inherited Create;
  if Assigned(ALoggerEventHandler) then
    GetLogger.OnLog := ALoggerEventHandler;

   FSQLiteConnection:= TSQLiteConnection.Instance.SetConnectionParam(AConnectionParams).ConnectEx;
  if not Assigned(FSQLiteConnection) then
  begin
    if (not Assigned(ALoggerEventHandler)) and (not Assigned(TLogger.Instance.OnLog)) then
      raise Exception.Create(NoConnectionMsg);
  end;

  FSchema := AConnectionParams.Schema;
end;

constructor TSQLiteRunner.Create(AConnectionParams: TSQLiteConnectionParams; ALocalLogFile: string);
begin
  inherited Create;
  GetLogger.ConfigLocal(True, ALocalLogFile);

  FSQLiteConnection:= TSQLiteConnection.Instance.SetConnectionParam(AConnectionParams).ConnectEx;
  if not Assigned(FSQLiteConnection) then
    raise Exception.Create(NoConnectionMsg);

  FSchema := AConnectionParams.Schema;
end;

destructor TSQLiteRunner.Destroy;
begin
  if Assigned(FSQLiteConnection) then
    FSQLiteConnection.Free;
  inherited;
end;

procedure TSQLiteRunner.DownGradeVersionInfo(AVersionToDownGrade: Int64);
var
  LvScript: string;
begin
  LvScript := 'DELETE FROM ' + TB + ' WHERE Version > ' + AVersionToDownGrade.ToString;
  FSQLiteConnection.ExecuteAdHocQuery(LvScript);
end;

function TSQLiteRunner.GetDatabaseVersion: Int64;
begin
  if FSQLiteConnection.IsConnected then
    Result := FSQLiteConnection.OpenAsInteger('SELECT IFNULL(MAX(Version), 1) FROM ' + TB)
  else
    Result := -1;
end;

procedure TSQLiteRunner.UpdateVersionInfo(AMigration: TMigrationBase; AInsertMode: Boolean);
var
  LvScript: string;
  LvLatestVersion: Int64;
  LvAuthor:string;
  LvDescription: string;
begin
  if AMigration is TMigration then
  begin
    LvLatestVersion := TMigration(AMigration).Version;
    LvAuthor := TMigration(AMigration).Author;
    LvDescription := TMigration(AMigration).Description;
  end
  else if AMigration is TMigrationX then
  begin
    LvLatestVersion := TMigrationX(AMigration).AttribVersion;
    LvAuthor := TMigrationX(AMigration).AttribAuthor;
    LvDescription := TMigrationX(AMigration).AttribDescription;
  end;

  if AInsertMode then
  begin
    LvScript := 'INSERT INTO `' + TB + '`' + #10
    + '(`Version`,' + #10
    + '`AppliedOn`,' + #10
    + '`Author`,' + #10
    + '`Description`)' + #10
    + 'VALUES' + #10
    + '(' + LvLatestVersion.ToString + ',' + #10
    + 'CURRENT_TIMESTAMP,' + #10
    + '	' +  LvAuthor.QuotedString + ',' + #10
    + '	' + LvDescription.QuotedString + ' ' + #10
    + ');';
  end
  else
  begin
    LvScript :=
    'UPDATE `' + TB + '`' + #10
    + 'SET' + #10
    + '`Version` = ' + LvLatestVersion.ToString + #10
    + ',`AppliedOn` = CURRENT_TIMESTAMP' + #10
    + ',`Author` = CONCAT(`Author`,' + QuotedStr(' -- ') + ', ' + LvAuthor.QuotedString + ')' + #10
    + ',`Description` = CONCAT(`Description`,' + QuotedStr(' -- ') + ', ' + LvDescription.QuotedString + ')' + #10
    + 'WHERE `Version` = ' + LvLatestVersion.ToString + ';';
  end;

  FSQLiteConnection.ExecuteAdHocQuery(LvScript);
end;

end.
