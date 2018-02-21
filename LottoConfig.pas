unit LottoConfig;

interface

uses
  IniFiles;

type
  TDBInfo = class
  private
    FHost: string;
    FPort: Integer;
    FUser: string;
    FPass: string;
    FDBName: string;
  public
    property Host: string read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property User: string read FUser write FUser;
    property Pass: string read FPass write FPass;
    property DBName: string read FDBName write FDBName;
  end;

  TLottoConfig = class
  private
    FIniFile: TIniFile;
    FLottoURL: string;
    FDBInfo: TDBInfo;
    FPeriod: Integer;
  public
    constructor Create(APathToConfig: string);
    destructor Destroy; override;
    procedure Apply;
    procedure Load;
    property LottoURL: string read FLottoURL write FLottoURL;
    property Period: Integer read FPeriod write FPeriod;
    property IniFile: TIniFile read FIniFile write FIniFile;
    property DBInfo: TDBInfo read FDBInfo write FDBInfo;
  end;

var
  Config: TLottoConfig;

implementation

uses
  Winapi.WinInet, Winapi.UrlMon, System.SysUtils, System.IOUtils;

function GetLottoPath: string;
begin
  Result := TPath.GetDocumentsPath + PathDelim + 'LottoResults' + PathDelim;
  ForceDirectories(Result);
end;

{ TKindleConfig }

procedure TLottoConfig.Apply;
begin
  IniFile.WriteString('General', 'LottoURL', LottoURL);
  IniFile.WriteInteger('General', 'Period', Period);
  IniFile.WriteString('DBInfo', 'Host', DBInfo.Host);
  IniFile.WriteInteger('DBInfo', 'Port', DBInfo.Port);
  IniFile.WriteString('DBInfo', 'User', DBInfo.User);
  IniFile.WriteString('DBInfo', 'Pass', DBInfo.Pass);
  IniFile.WriteString('DBInfo', 'DBName', DBInfo.DBName);
end;

constructor TLottoConfig.Create(APathToConfig: string);
begin
  FIniFile := TIniFile.Create(APathToConfig);
  FDBInfo := TDBInfo.Create;
  Load;
end;

destructor TLottoConfig.Destroy;
begin
  Apply;
  if Assigned(FIniFile) then
    FIniFile.Free;
  if Assigned(FDBInfo) then
    FDBInfo.Free;
  inherited;
end;

procedure TLottoConfig.Load;
begin
  FLottoURL := FIniFile.ReadString('General', 'LottoURL', 'http://www.ozlotteries.com/lotto-results#');
  FPeriod := FIniFile.ReadInteger('General', 'Period', 1);
  DBInfo.Host := FIniFile.ReadString('DBInfo', 'Host', 'localhost');
  DBInfo.Port := FIniFile.ReadInteger('DBInfo', 'Port', 3306);
  DBInfo.User := FIniFile.ReadString('DBInfo', 'User', 'root');
  DBInfo.Pass := FIniFile.ReadString('DBInfo', 'Pass', 'root');
  DBInfo.DBName := FIniFile.ReadString('DBInfo', 'DBName', 'lotto');
end;

{ TProxyParams }

initialization
  Config := TLottoConfig.Create(GetLottoPath + 'LottoConfig.ini');

finalization
  if Assigned(Config) then
    Config.Free;

end.
