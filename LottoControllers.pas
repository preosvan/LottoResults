unit LottoControllers;

interface

uses
  LottoModelUnit, LottoConfig, MyAccess, System.RegularExpressions,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.URLClient;

type
  // For Unit Test
  TTestDataController = class(TDataController)
  public
    procedure Load; override;
    procedure Save; override;
  end;

  // For web loader
  TWebController = class
  private
    FHTTPClient: TNetHTTPClient;
    FHTTPRequest: TNetHTTPRequest;
    procedure InitHTTP;
  public
    constructor Create;
    destructor Destroy; override;
    property HTTPClient: TNetHTTPClient read FHTTPClient write FHTTPClient;
    property HTTPRequest: TNetHTTPRequest read FHTTPRequest write FHTTPRequest;
  end;

  TWebDataController = class(TDataController)
  private
    FWebController: TWebController;
    function LottoDateStrToDate(ALottoDateStr: string): TDateTime;
    procedure RequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load; override;
    procedure Save; override;
    property WebController: TWebController read FWebController;
  end;

  // For database
  TDBController = class
  private
    FConnection: TMyConnection;
    FStoredProc: TMyStoredProc;
    function InitConnection: Boolean;
    procedure InitDBInfo;
    procedure SaveDBInfo;
  public
    constructor Create;
    destructor Destroy; override;
    property Connection: TMyConnection read FConnection write FConnection;
    property StoredProc: TMyStoredProc read FStoredProc write FStoredProc;
  end;

  // For database
  TDBDataController = class(TDataController)
  private
    FDBController: TDBController;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load; override;
    procedure Save; override;
    property DBController: TDBController read FDBController;
  end;


implementation

uses
  System.SysUtils, LottoConst;

procedure TTestDataController.Load;
var
  Lottery: TLottery;
  Draw: TDraw;
  Number: TNumber;
  I, J: Integer;
begin
  if Assigned(LotteryList) then
  begin
    Lottery := TLottery.Create(1, 'Lottery 2');
    for I := 1 to 2 do
    begin
      Draw := TDraw.Create(I, IntToStr(100 + I), Now);
      Lottery.DrawList.Add(Draw);
      for J := 1 to 10 do
      begin
        if J <= 8 then
          Number := TNumber.Create(J, ntMain, 200 - J * 2)
        else
          Number := TNumber.Create(J, ntSupplementary, 100 - J * 2);
        Draw.NumberList.Add(Number);
      end;
    end;
    LotteryList.Add(Lottery);
  end;
end;

procedure TTestDataController.Save;
begin
  // The implementation is not needed
end;

{ TWebDataController }

constructor TWebDataController.Create;
begin
  FWebController := TWebController.Create;
  FWebController.FHTTPRequest.OnRequestCompleted := RequestCompleted;
end;

destructor TWebDataController.Destroy;
begin
  if Assigned(FWebController) then
    FWebController.Free;
  inherited;
end;

procedure TWebDataController.Load;
begin
  WebController.InitHTTP;
  WebController.HTTPRequest.Execute();
end;

function TWebDataController.LottoDateStrToDate(
  ALottoDateStr: string): TDateTime;
var
  FormatSettings: TFormatSettings;
  Day, Month, Year: Word;
  Splitted: TArray<String>;
  I: Integer;
begin
  Splitted := ALottoDateStr.Split([' '], 3);

  Day := StrToInt(Trim(Splitted[0]));

  Month := 0;
  FormatSettings := TFormatSettings.Create('en-US');
  for I := Low(FormatSettings.LongMonthNames) to High(FormatSettings.LongMonthNames) do
  if (FormatSettings.LongMonthNames[I] = Trim(Splitted[1])) then
  begin
    Month := I;
    Break;
  end;

  Year := StrToInt(Trim(Splitted[2]));

  Result := EncodeDate(Year, Month, Day)
end;

procedure TWebDataController.RequestCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);
var
  Content: string;
  I, J, K: Integer;
  RegEx: TRegEx;
  ONC, ONCLottery, ONCDate, ONCDraw, ONCNumber1, ONCNumber2: TMatchCollection;
  Lottery: TLottery;
  Draw: TDraw;
  Number: TNumber;
  DrawValue: string;
  DrawDate: TDateTime;
  NumberValue: Integer;
begin
  if Assigned(LotteryList) then
  begin
    Content := AResponse.ContentAsString;

    RegEx := TRegEx.Create('<div class="_37zgIOHe mguY2q3N _1jhZrNmV _3t76jRD2">(.*?)/div></div></div></div></div>');
    ONC := RegEx.Matches(Content);
    for I := 0 to ONC.Count - 1 do
    begin
      //Lottery
      RegEx := TRegEx.Create('game-logo__(.*?)is-');
      ONCLottery := RegEx.Matches(ONC.Item[I].Groups.Item[1].Value);
      Lottery := TLottery.Create(I + 1, Trim(ONCLottery.Item[0].Groups.Item[1].Value.Replace('-', ' ')));

      //DrawDate
      RegEx := TRegEx.Create('_3MgX05Zq"><span>(.*?)</span>');
      ONCDate := RegEx.Matches(ONC.Item[I].Groups.Item[1].Value);
      DrawDate := LottoDateStrToDate(Trim(ONCDate.Item[0].Groups.Item[1].Value));

      //DrawValue
      RegEx := TRegEx.Create('_2Jth68qx"><span>Draw(.*?)</span>');
      ONCDraw := RegEx.Matches(ONC.Item[I].Groups.Item[1].Value);
      DrawValue := Trim(ONCDraw.Item[0].Groups.Item[1].Value);

      Draw := TDraw.Create(I + 1, DrawValue, DrawDate);
      Lottery.DrawList.Add(Draw);

      //Numbers main
      RegEx := TRegEx.Create('ns1" data-id="drawNumber_number">(.*?)<');
      ONCNumber1 := RegEx.Matches(ONC.Item[I].Groups.Item[1].Value);
      for J := 0 to ONCNumber1.Count - 1 do
      begin
        NumberValue := StrToIntDef(ONCNumber1.Item[J].Groups.Item[1].Value, -1);
        if NumberValue >= 0 then
        begin
          Number := TNumber.Create(J + 1, ntMain, NumberValue);
          Draw.NumberList.Add(Number);
        end;
      end;

      //Numbers supplementary
      RegEx := TRegEx.Create('ns2" data-id="drawNumber_number">(.*?)<');
      ONCNumber2 := RegEx.Matches(ONC.Item[I].Groups.Item[1].Value);
      for K := 0 to ONCNumber2.Count - 1 do
      begin
        NumberValue := StrToIntDef(ONCNumber2.Item[K].Groups.Item[1].Value, -1);
        if NumberValue >= 0 then
        begin
          Number := TNumber.Create(J + K + 1, ntSupplementary, NumberValue);
          Draw.NumberList.Add(Number);
        end;
      end;
      LotteryList.Add(Lottery);
    end;
  end;
end;


procedure TWebDataController.Save;
begin
  // The implementation is not needed
end;

{ TDBDataController }

constructor TDBDataController.Create;
begin
  FDBController := TDBController.Create;
end;

destructor TDBDataController.Destroy;
begin
  if Assigned(FDBController) then
    FDBController.Free;
  inherited;
end;

procedure TDBDataController.Load;
begin
  // The implementation is not needed
end;

procedure TDBDataController.Save;
var
  Lottery: TLottery;
  Draw: TDraw;
  Number: TNumber;
  I, J, K: Integer;
begin
  if Assigned(DBController) and Assigned(LotteryList) then
  begin
    if DBController.InitConnection then
    begin
      //Save LotteryList
      for I := 0 to LotteryList.Count - 1 do
      begin
        Lottery := LotteryList[I];
        DBController.StoredProc.StoredProcName := DB_SP_GET_LOTTERY_ID;
        DBController.StoredProc.Params.ParamByName('AName').Value := Lottery.Name;
        DBController.StoredProc.ExecProc;
        Lottery.Id := DBController.StoredProc.Params.ParamByName('Result').AsInteger;

        //Save DrawList
        for J := 0 to Lottery.DrawList.Count - 1 do
        begin
          Draw := Lottery.DrawList[J];
          DBController.StoredProc.StoredProcName := DB_SP_GET_DRAW_ID;
          DBController.StoredProc.Params.ParamByName('ALotteryId').Value := Lottery.Id;
          DBController.StoredProc.Params.ParamByName('ADate').Value := Draw.Date;
          DBController.StoredProc.Params.ParamByName('ADrawValue').Value := Draw.Name;
          DBController.StoredProc.ExecProc;
          Draw.Id := DBController.StoredProc.Params.ParamByName('Result').AsInteger;

          //Save NumberList
          for K := 0 to Draw.NumberList.Count - 1 do
          begin
            Number := Draw.NumberList[K];
            DBController.StoredProc.StoredProcName := DB_SP_ADD_DRAW_NUMBER;
            DBController.StoredProc.Params.ParamByName('ADrawId').Value := Draw.Id;
            DBController.StoredProc.Params.ParamByName('ANumber').Value := Number.Id;
            DBController.StoredProc.Params.ParamByName('ANumberType').Value := Number.NumberType;
            DBController.StoredProc.Params.ParamByName('ANumberValue').Value := Number.NumberValue;
            DBController.StoredProc.ExecProc;
          end;
        end;
      end;
    end;
  end;
end;

{ TDBController }

constructor TDBController.Create;
begin
  FConnection := TMyConnection.Create(nil);
  FStoredProc := TMyStoredProc.Create(nil);
  InitConnection;
  inherited;
end;

destructor TDBController.Destroy;
begin
  if FConnection.Connected then
    FConnection.Close;
  FreeAndNil(FStoredProc);
  FreeAndNil(FConnection);
  inherited;
end;

function TDBController.InitConnection: Boolean;
begin
  try
    InitDBInfo;
    StoredProc.Connection := Connection;
    try
      if not Connection.Connected then
      begin
        Connection.Open;
        if Connection.Connected then
          SaveDBInfo;
      end;
    except
      //Save to log (not for test app)
    end;
  finally
    Result := Connection.Connected;
  end;
end;

procedure TDBController.InitDBInfo;
begin
  Config.Load;
  Connection.Server := Config.DBInfo.Host;
  Connection.Port := Config.DBInfo.Port;
  Connection.Username := Config.DBInfo.User;
  Connection.Password := Config.DBInfo.Pass;
  Connection.Database := Config.DBInfo.DBName;
  Connection.LoginPrompt := False;
end;

procedure TDBController.SaveDBInfo;
begin
  Config.DBInfo.Host := Connection.Server;
  Config.DBInfo.Port := Connection.Port;
  Config.DBInfo.User := Connection.Username;
  Config.DBInfo.Pass := Connection.Password;
  Config.DBInfo.DBName := Connection.Database;
  Config.Apply;
end;

{ TWebController }

constructor TWebController.Create;
begin
  FHTTPClient := TNetHTTPClient.Create(nil);
  FHTTPRequest := TNetHTTPRequest.Create(nil);
  InitHTTP;
  inherited;
end;

destructor TWebController.Destroy;
begin
  if Assigned(FHTTPRequest) then
    FHTTPRequest.Free;
  if Assigned(FHTTPClient) then
    FHTTPClient.Free;
  inherited;
end;

procedure TWebController.InitHTTP;
begin
  HTTPRequest.Client := HTTPClient;
  HTTPRequest.URL := Config.LottoURL;
  HTTPRequest.MethodString := 'GET';
end;

end.
