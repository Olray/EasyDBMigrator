{***************************************************}
{                                                   }
{   Author: Ali Dehbansiahkarbon(adehban@gmail.com) }
{   SQLite: Olray Dragon (prog@allanime.org)        }
{   GitHub: https://github.com/Olray/EasyDBMigrator }
{                                                   }
{***************************************************}
unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, System.StrUtils, System.TypInfo,

  EasyDB.Core,
  EasyDB.Logger,
  EasyDB.Migration,
  EasyDB.SQLiteRunner;

type
  TfrmMain = class(TForm)
    Label1: TLabel;
    btnDowngradeDatabase: TButton;
    btnUpgradeDatabase: TButton;
    btnAddMigrations: TButton;
    edtVersion: TEdit;
    mmoLog: TMemo;
    pbTotal: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure btnAddMigrationsClick(Sender: TObject);
    procedure btnUpgradeDatabaseClick(Sender: TObject);
    procedure btnDowngradeDatabaseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    Runner: TSQLiteRunner;
    procedure OnLog(AActionType: TActionTypes; AException, AClassName: string; AVersion: Int64);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.btnAddMigrationsClick(Sender: TObject);
begin
  Runner.Clear;
  Runner.Add(TMigration.Create('TbUsers', 2, 'Olray', 'Create table Users, #2701',
  procedure
  var LvScript: string;
  begin
    LvScript := 'CREATE TABLE IF NOT EXISTS TbUsers ( ' + #10
     + '    ID INT NOT NULL PRIMARY KEY, ' + #10
     + '    UserName NVARCHAR(100), ' + #10
     + '    Pass NVARCHAR(100) ' + #10
     + '    );';

    Runner.SQLite.ExecuteAdHocQuery(LvScript);
  end,
  procedure
  begin
    Runner.SQLite.ExecuteAdHocQuery('DROP TABLE TbUsers');
  end
  ));
  //============================================
  Runner.Add(TMigration.Create('TbUsers', 3, 'Olray', 'Add NewField2 to TbUsers',
  procedure
  begin
    Runner.SQLite.ExecuteAdHocQuery('ALTER TABLE TbUsers ADD NewField2 VARCHAR(50)');
  end,
  procedure
  begin
    Runner.SQLite.ExecuteAdHocQuery('ALTER TABLE TbUsers DROP COLUMN NewField2');
  end
  ));
  //============================================
  Runner.Add(TMigration.Create('TbUsers', 4, 'Olray', 'Add NewField3 to TbUsers',
  procedure
  begin
    Runner.SQLite.ExecuteAdHocQuery('ALTER TABLE TbUsers ADD NewField3 INT');
  end,
  procedure
  begin
    Runner.SQLite.ExecuteAdHocQuery('ALTER TABLE TbUsers DROP COLUMN NewField3');
  end
  ));
  //============================================
  Runner.Add(TMigration.Create('TbCustomers', 5, 'Olray', 'Add table TbCustomers',
  procedure
  var LvScript: string;
  begin
    LvScript := 'CREATE TABLE IF NOT EXISTS TbCustomers ( ' + #10
     + '    ID INT NOT NULL PRIMARY KEY, ' + #10
     + '    Name NVARCHAR(100), ' + #10
     + '    Family NVARCHAR(100) ' + #10
     + '    );';

    Runner.SQLite.ExecuteAdHocQuery(LvScript);
  end,
  procedure
  begin
    Runner.SQLite.ExecuteAdHocQuery('DROP TABLE TbCustomers');
  end
  ));
  TLogger.Instance.Log(atUpgrade, 'Migrations have been added');
end;

procedure TfrmMain.btnDowngradeDatabaseClick(Sender: TObject);
begin
  Runner.DowngradeDatabase(StrToInt64Def(edtVersion.Text, 1));
end;

procedure TfrmMain.btnUpgradeDatabaseClick(Sender: TObject);
begin
  Runner.UpgradeDatabase;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  LvConnectionParams: TSQLiteConnectionParams;
begin
  with LvConnectionParams do // The information can be sourced from an ini file, registry or other location.
  begin
    UserName := '';
    FileName := 'Log.db3';
    Schema := 'Library';
  end;

  Runner := TSQLiteRunner.Create(LvConnectionParams);
  Runner.Config
    .LogAllExecutions(True) // Optional
    .UseInternalThread(False) //Optional
    .SetProgressbar(pbTotal); //Optional

  {Use this line if you don't need local log}
  Runner.GetLogger.OnLog := OnLog;

  {Use this line if you need local log}
  //Runner.GetLogger.ConfigLocal(True, 'C:\Temp\EasyDBLog.txt').OnLog := OnLog;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  Runner.Free;
end;

procedure TfrmMain.OnLog(AActionType: TActionTypes; AException, AClassName: string; AVersion: Int64);
begin
  // This method will run anyway even if you ignore the Local Log file.
  //...
  //...
  // ShowMessage(AException);
  // Do anything you need here with the log data, log on Graylog, Telegram, email, etc...

  mmoLog.Lines.BeginUpdate;
  mmoLog.Lines.Add('========== ' + DateTimeToStr(Now) + ' ==========');
  mmoLog.Lines.Add('Action Type: ' + GetEnumName(TypeInfo(TActionTypes), Ord(AActionType)));
  mmoLog.Lines.Add('Msg: ' + AException);
  mmoLog.Lines.Add('Class Name: ' + IfThen(AClassName.IsEmpty, 'N/A', AClassName));
  mmoLog.Lines.Add('Version: ' + IfThen(AVersion = 0, 'N/A', IntToStr(AVersion)));
  mmoLog.Lines.EndUpdate;
  mmoLog.Lines.Add('');
end;

end.
