unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Menus, Buttons, Wave2,  Wave3,
  Wave4, Wave5, MPlayer, Setting, About, ToolWin, ComCtrls;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    Contents1: TMenuItem;
    Index1: TMenuItem;
    N2: TMenuItem;
    AboutWaveG1: TMenuItem;
    Window1: TMenuItem;
    Cascade1: TMenuItem;
    TileVertical1: TMenuItem;
    TileHorizontal1: TMenuItem;
    ArrangeIcons1: TMenuItem;
    OpenDialog1: TOpenDialog;
    N3: TMenuItem;
    MinimizeAll1: TMenuItem;
    CloseAll1: TMenuItem;
    MediaPlayer1: TMediaPlayer;
    Previous1: TMenuItem;
    Next1: TMenuItem;
    SaveDialog1: TSaveDialog;
    Timer1: TTimer;
    Options1: TMenuItem;
    Settings1: TMenuItem;
    CoolBar1: TCoolBar;
    procedure New1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Cascade1Click(Sender: TObject);
    procedure TileVertical1Click(Sender: TObject);
    procedure TileHorizontal1Click(Sender: TObject);
    procedure ArrangeIcons1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure MinimizeAll1Click(Sender: TObject);
    procedure CloseAll1Click(Sender: TObject);
    procedure Previous1Click(Sender: TObject);
    procedure Next1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure AboutWaveG1Click(Sender: TObject);
  private
    { Private declarations }
    procedure NewMDIChild(const Name: string);
    procedure OpenMDIChild(const Name:string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.NewMDIChild(const Name: string);
var
  Child: TForm2;
begin
  try
    Child := TForm2.Create(Self);
  except
    on EMenuError do
    begin
      Child.Free;
      MessageDlg('That all folks!',mtInformation, [mbOk],0);
      Exit;
    end else
    begin
      Child.Free;
      MessageDlg('That all folks!',mtInformation, [mbOk],0);
      Exit;
    end;
  end;
  Child.Caption := Name;
  Child.Tag:=0;
end;

procedure TForm1.OpenMDIChild(const Name:string);
var
  Child:TForm2;
  Inceput,Sfirsit,fes:longint;
  Zeroline,Kind:boolean;
  DCOffset:shortint;
  es_pixel:single;
begin
  try
    Child := TForm2.Create(Self);
  except
    on EMenuError do
    begin
      MessageDlg('That all folks!',mtInformation, [mbOk],0);
      Child.Free;
      Exit;
    end else
    begin
      MessageDlg('That all folks!',mtInformation, [mbOk],0);
      Child.Free;
      Exit;
    end;
  end;
  Child.Caption := Name;
  Form1.MediaPlayer1.FileName:='';
  Form1.MediaPlayer1.Close;
  Timer1.Enabled:=False;
  //test for wav* file
  if ExistaRIFF(Name)=False then
  begin
    MessageDlg('This file ' +ExtractFileName(Name)+
    ' does not start with the magic word ''RIFF'' !',mtError,[mbOk],0);
    Exit;
  end;
  if ExistaWAVEfmt(Name)=False then
  begin
    MessageDlg('This file ' +ExtractFileName(Name)+
    ' does not have a WAVEfmt part !',mtError,[mbOk],0);
    Exit;
  end;
  if Chanels(Name)<>1 then
  begin
    MessageDlg('The file is recorded stereo.This version of the program '+
    'cannot process stereo files.',mtError,[mbOk],0);
    Exit;
  end;
  if BitsPerSample(Name)=8 then
  begin
    Kind:=True;
    Sfirsit:=AudioDataLength(Name);
  end else
  begin
    Kind:=False;
    Sfirsit:=AudioDataLength(Name) div 2;
  end;
  ZeroLine:=True;DCOffset:=0;Inceput:=0;

  Child.Label1.Caption:='0';
  Child.Label1.Tag:=Sfirsit;
  Child.Label2.Caption:='0';
  Child.Label3.Caption:=IntToStr(Sfirsit);
  es_pixel:=Sfirsit/Child.PaintBox1.Width;
  Child.Label4.Caption:=FloatToStr(es_pixel);
  fes:=PlayBackFrequency(Name);
  Child.Label5.Caption:=IntToStr(fes);
  Child.Label6.Caption:=IntToStr(Sfirsit);
  if not kind then Child.Label6.Color:=clRed;

  DrawFast(Inceput,Sfirsit,Name,Child.PaintBox1,ZeroLine,Kind,DCOffset,true);
  Child.Tag:=1;
  UpdateHeaderOnOpen(Child.Header1,Child.Caption,kind,fes,inceput,sfirsit)
end;

procedure TForm1.New1Click(Sender: TObject);
var
  s:string;
  fn:array[0..255] of char;
begin
  GetDir(0,s); { 0 = Current drive }
  s:=s+'\NONAME'+IntToStr(MDIChildCount + 1)+'.WAV';
  if FileExists(s) then
  if MessageDlg('File '+s+' already exists. Owerwrite?',
  mtConfirmation, [mbYes, mbNo], 0) = mrNo then
  if SaveDialog1.Execute then s:=SaveDialog1.FileName else Exit;
  StrPCopy(fn,s);
  DeleteFile(fn);
  NewMdiChild(s);
end;

procedure TForm1.Exit1Click(Sender: TObject);
var
  clip : string;
begin
  CloseAll1.Click;
  clip := ExpandFileName(ExtractFileDir(Application.ExeName))+ '\clip.wav';
  DeleteFile(PChar(clip));
  Close;
end;

procedure TForm1.Cascade1Click(Sender: TObject);
begin
  Cascade;
end;

procedure TForm1.TileVertical1Click(Sender: TObject);
begin
  TileMode:=tbVertical;
  Tile;
end;

procedure TForm1.TileHorizontal1Click(Sender: TObject);
begin
  TileMode:=tbHorizontal;
  Tile;
end;

procedure TForm1.ArrangeIcons1Click(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TForm1.Open1Click(Sender: TObject);
var
  i : integer;
begin
  if OpenDialog1.Execute then
  begin
    for  i := 0 to OpenDialog1.Files.Count-1 do
    begin
      OpenMDIChild(OpenDialog1.Files[i]);
    end;
    Start.X:=0;Final.X:=0;
  end;
end;

procedure TForm1.MinimizeAll1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := MDIChildCount - 1 downto 0 do
    MDIChildren[I].WindowState := wsMinimized;
end;

procedure TForm1.CloseAll1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := MDIChildCount - 1 downto 0 do
  begin
    Application.ProcessMessages;
    MDIChildren[I].Close;
    Application.ProcessMessages;
  end;
end;

procedure TForm1.Previous1Click(Sender: TObject);
begin
  Previous;
end;

procedure TForm1.Next1Click(Sender: TObject);
begin
  Next;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  Child:TForm2;
  init,pozitie0,temp:longint;
begin
  Child:=ActiveMdiChild as TForm2;
  if (MediaPlayer1.Mode=mpStopped) or (MediaPlayer1.Tag=0) then
  begin
    Timer1.Enabled:=False;
    MediaPlayer1.Filename:='';
    Mediaplayer1.Close;
    MediaPlayer1.Tag:=0;
    InvertRect(Child.PaintBox1.Canvas.Handle,D);
    D.Left:=0;D.Top:=0;D.Right:=0;D.Bottom:=0;
  end else
  begin
    temp:=StrToInt(Child.Label1.Caption);
    pozitie0:=MediaPlayer1.Position-temp;
    init:=Trunc(pozitie0/StrToFloat(Child.Label4.Caption));
    InvertRect(Child.PaintBox1.Canvas.Handle,D);      // erase previous if any
    D.Left:=init;D.Top:=0;D.Right:=init+1;D.Bottom:=Height;
    InvertRect(Child.PaintBox1.Canvas.Handle,D);      // draw new line
  end;
end;

procedure TForm1.Settings1Click(Sender: TObject);
begin
  Settings.ShowModal;
end;

procedure TForm1.AboutWaveG1Click(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

end.

