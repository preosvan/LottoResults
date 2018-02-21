program LottoResults;

uses
  Vcl.Forms,
  MainFrm in 'MainFrm.pas' {MainForm},
  LottoModelUnit in 'LottoModelUnit.pas',
  LottoConfig in 'LottoConfig.pas',
  LottoControllers in 'LottoControllers.pas',
  LottoConst in 'LottoConst.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
