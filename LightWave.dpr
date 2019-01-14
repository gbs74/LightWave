program LightWave;

uses
  Forms,
  Main in 'MAIN.PAS' {Form1},
  Wave2 in 'WAVE2.PAS' {Form2},
  Wave3 in 'WAVE3.PAS',
  Wave4 in 'WAVE4.PAS',
  Wave5 in 'WAVE5.PAS',
  Wave6 in 'WAVE6.PAS',
  Wave7 in 'WAVE7.PAS',
  Setting in 'SETTING.PAS' {Settings},
  Wave8 in 'WAVE8.PAS',
  Wave9 in 'WAVE9.PAS',
  About in 'About.pas' {AboutBox};

{$E exe}

{$R *.RES}

begin
  Application.Title := 'LightWave';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TSettings, Settings);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
