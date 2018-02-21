unit MainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Actions, Vcl.ActnList, System.UITypes;

type
  TMainForm = class(TForm)
    pnBottom: TPanel;
    pnClient: TPanel;
    btnStop: TButton;
    btnStart: TButton;
    btnClose: TButton;
    meProgress: TMemo;
    ActionList: TActionList;
    actStart: TAction;
    actStop: TAction;
    actClearResults: TAction;
    Timer: TTimer;
    edPeriod: TLabeledEdit;
    procedure actStartExecute(Sender: TObject);
    procedure actClearResultsExecute(Sender: TObject);
    procedure Log(AMessage: string);
    procedure FormCreate(Sender: TObject);
    procedure edPeriodChange(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure edPeriodExit(Sender: TObject);
  private
    procedure LoadResults;
    procedure SetPeriod(const Value: Integer);
    procedure SetStarted(const Value: Boolean);
    function GetStarted: Boolean;
  public
    property Period: Integer write SetPeriod;
    property Started: Boolean read GetStarted write SetStarted;
  end;

var
  MainForm: TMainForm;

implementation

uses
  LottoModelUnit, LottoControllers, LottoConst, LottoConfig;

{$R *.dfm}

procedure TMainForm.actClearResultsExecute(Sender: TObject);
var
  DBController: TDBController;
const
  MSG = 'Do you really want to clear database?';
begin
  if MessageDlg(MSG, mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    DBController := TDBController.Create;
    try
      DBController.StoredProc.StoredProcName := DB_SP_CLEAR_RESULTS;
      DBController.StoredProc.ExecProc;
      Log('Database successfully cleared');
    finally
      DBController.Free;
    end;
  end;
end;

procedure TMainForm.actStartExecute(Sender: TObject);
begin
  Started := True;
end;

procedure TMainForm.actStopExecute(Sender: TObject);
begin
  Started := False;
end;

procedure TMainForm.edPeriodChange(Sender: TObject);
begin
  Period := StrToIntDef(edPeriod.Text, 1);
end;

procedure TMainForm.edPeriodExit(Sender: TObject);
begin
  if StrToIntDef(edPeriod.Text, 1) < 1 then
    edPeriod.Text := '1';
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Log('All program settings are in the configuration file:' + #13#10 +
    Config.IniFile.FileName);

  Period := Config.Period;
  Started := False;
end;

function TMainForm.GetStarted: Boolean;
begin
  Result := Timer.Enabled;
end;

procedure TMainForm.LoadResults;
var
  LotteryList: TLotteryList;
  DataController: TDataController;
  I: Integer;
begin
  LotteryList := TLotteryList.Create(nil);
  try
//    DataController := TTestDataController.Create;
    //Load
    DataController := TWebDataController.Create;
    try
      LotteryList.InitDataController(DataController);
      Log('Start updating the lottery results');
      LotteryList.DataController.Load;
      Log('Data received:');
      for I := 0 to LotteryList.Count - 1 do
        Log(LotteryList[I].Name);
    finally
      DataController.Free;
    end;

    //Save
    DataController := TDBDataController.Create;
    try
      LotteryList.InitDataController(DataController);
      LotteryList.DataController.Save;
      Log('Data stored in the database');
    finally
      DataController.Free;
    end;
  finally
    LotteryList.Free;
  end;
end;

procedure TMainForm.Log(AMessage: string);
begin
  meProgress.Lines.Add(DateTimeToStr(Now) + ' - ' + Trim(AMessage));
end;

procedure TMainForm.SetPeriod(const Value: Integer);
begin
  Config.Period := Value;
  Timer.Interval := Value*SecsPerHour*MSecsPerSec;
end;

procedure TMainForm.SetStarted(const Value: Boolean);
begin
  Timer.Enabled := Value;
  actStart.Enabled := not Started;
  actStop.Enabled := Started;
  if Started then
    LoadResults;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  LoadResults;
end;

end.
