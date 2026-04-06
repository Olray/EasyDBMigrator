{***************************************************}
{                                                   }
{   Author: Ali Dehbansiahkarbon(adehban@gmail.com) }
{   SQLite: Olray Dragon (prog@allanime.org)        }
{   GitHub: https://github.com/Olray/EasyDBMigrator }
{                                                   }
{***************************************************}

unit EasyDB.ConnectionManager.SQLite;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, {=MySQL=}FireDAC.Phys.SQLite, {$IF CompilerVersion >= 30}FireDAC.Phys.SQLiteDef,{$IFEND} FireDAC.Comp.UI, {=MySQL=}

  EasyDB.ConnectionManager.Base,
  EasyDB.Core,
  EasyDB.Logger,
  EasyDB.Consts;

 type

  TSQLiteConnection = class(TConnection) // Singletone
  private
    FConnection: TFDConnection;
    FSQLiteDriver: TFDPhysSQLiteDriverLink;
    FQuery: TFDQuery;
    FConnectionParams: TSQLiteConnectionParams;
    Constructor Create;
    class var FInstance: TSQLiteConnection;
  public
    class function Instance: TSQLiteConnection;
    Destructor Destroy; override;

    function GetConnectionString: string; override;
    function SetConnectionParam(AConnectionParams: TSQLiteConnectionParams): TSQLiteConnection;
    function Connect: Boolean; override;
    function ConnectEx: TSQLiteConnection;
    function IsConnected: Boolean;
    function InitializeDatabase: Boolean;
    function Logger: TLogger; override;

    procedure ExecuteAdHocQuery(AScript: string); override;
    procedure ExecuteAdHocQueryWithTransaction(AScript: string);
    procedure ExecuteScriptFile(AScriptPath: string; ADelimiter: string); override;
    function OpenAsInteger(AScript: string): Largeint;

    procedure BeginTrans;
    procedure CommitTrans;
    procedure RollBackTrans;

    property ConnectionParams: TSQLiteConnectionParams read FConnectionParams;
  end;

implementation

{ TMySQLConnection }

procedure TSQLiteConnection.BeginTrans;
begin
  FConnection.Transaction.StartTransaction;
end;

procedure TSQLiteConnection.CommitTrans;
begin
  FConnection.Transaction.Commit;
end;

function TSQLiteConnection.Connect: Boolean;
begin
  try
    FConnection.Connected := True;
    InitializeDatabase;
    Result := True;
  except on E: Exception do
    begin
      Logger.Log(atDbConnection, E.Message);
      Result := False;
    end;
  end;
end;

function TSQLiteConnection.ConnectEx: TSQLiteConnection;
begin
  if Connect then
    Result := FInstance
  else
  begin
    Self.Free;
    Result := nil;
  end;
end;

constructor TSQLiteConnection.Create;
begin
  FConnection := TFDConnection.Create(nil);
  FSQLiteDriver := TFDPhysSQLiteDriverLink.Create(nil);
  FSQLiteDriver.VendorLib := 'sqlite3.dll';

  FConnection.DriverName := 'SQLite';
  FConnection.LoginPrompt := False;


  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection;
end;

destructor TSQLiteConnection.Destroy;
begin
  FQuery.Close;
  FQuery.Free;
  FSQLiteDriver.Free;

  FConnection.Close;
  FConnection.Free;
  FInstance := nil;
  inherited;
end;

procedure TSQLiteConnection.ExecuteAdHocQuery(AScript: string);
begin
  try
    FConnection.ExecSQL(AScript);
  except on E: Exception do
    begin
      E.Message := ' Script: ' + AScript + #13#10 + ' Error: ' + E.Message;
      raise;
    end;
  end;
end;

procedure TSQLiteConnection.ExecuteAdHocQueryWithTransaction(AScript: string);
begin
  try
    BeginTrans;
    FConnection.ExecSQL(AScript);
    CommitTrans;
  except on E: Exception do
    begin
      RollBackTrans;
      E.Message := ' Script: ' + AScript + #13#10 + ' Error: ' + E.Message;
      raise;
    end;
  end;
end;

procedure TSQLiteConnection.ExecuteScriptFile(AScriptPath: string; ADelimiter: string);
var
  LvStreamReader: TStreamReader;
  LvLine: string;
  LvStatement: string;
begin
  if FileExists(AScriptPath) then
  begin
    LvStreamReader := TStreamReader.Create(AScriptPath, TEncoding.UTF8);
    LvLine := EmptyStr;
    LvStatement := EmptyStr;

    try
      while not LvStreamReader.EndOfStream do
      begin
        LvLine := LvStreamReader.ReadLine;

        if not RightStr(LvLine.Trim.ToLower, Length(ADelimiter)).Equals(ADelimiter) then
          LvStatement := LvStatement + ' ' + LvLine
        else
        begin
          if not LvStatement.Trim.IsEmpty then
          try
            ExecuteAdHocQuery(LvStatement);
          finally
            LvStatement := EmptyStr;
          end;
        end;
      end;
    finally
      LvStreamReader.Free;
    end;
  end
  else
    Logger.Log(atFileExecution, 'Script file doesn''t exists.');
end;

function TSQLiteConnection.GetConnectionString: string;
begin
  Result := FConnection.ConnectionString;
end;

function TSQLiteConnection.InitializeDatabase: Boolean;
var
  LvTbScript: string;
begin
  LvTbScript := 'CREATE TABLE IF NOT EXISTS VersionInfo ( ' + #10
       + '  Version BIGINT NOT NULL PRIMARY KEY, ' + #10
       + '  AppliedOn DATETIME DEFAULT CURRENT_TIMESTAMP, ' + #10
       + '  Author NVARCHAR(100), ' + #10
       + '  Description NVARCHAR(4000) ' + #10
       + ');';

  try
    ExecuteAdHocQuery(LvTbScript);
    Result := True;
  except on E: Exception do
    begin
      Logger.Log(atInitialize, E.Message);
      Result := False;
    end;
  end;
end;

class function TSQLiteConnection.Instance: TSQLiteConnection;
begin
  if not Assigned(FInstance) then
    FInstance := TSQLiteConnection.Create;

  Result := FInstance;
end;

function TSQLiteConnection.IsConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

function TSQLiteConnection.Logger: TLogger;
begin
  Result := TLogger.Instance;
end;

function TSQLiteConnection.OpenAsInteger(AScript: string): Largeint;
begin
  FQuery.Open(AScript);
  if FQuery.RecordCount > 0 then
    Result := FQuery.Fields[0].AsLargeInt
  else
    Result := -1;
end;

procedure TSQLiteConnection.RollBackTrans;
begin
  FConnection.Transaction.Rollback;
end;

function TSQLiteConnection.SetConnectionParam(AConnectionParams: TSQLiteConnectionParams): TSQLiteConnection;
begin
  FConnectionParams := AConnectionParams;

  with FConnection.Params, FConnectionParams do
  begin
    Clear;
    Add('DriverID=SQLite');
    Add('Database=' + FileName);
    if UserName <> '' then
    begin
      Add('User_Name=' + UserName);
      Add('Password=' + Pass);
    end;
    Add('LockingMode=Normal');
  end;

  Result := FInstance;
end;

end.
