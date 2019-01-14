unit Wave2;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, MPlayer, ExtCtrls, Menus, Wave3, Wave4, Wave5,
  Wave6, Wave7, Setting, Wave8;

type
  TForm2 = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    SaveSelectionAs1: TMenuItem;
    N4: TMenuItem;
    Exit1: TMenuItem;
    Close2: TMenuItem;
    Wave1: TMenuItem;
    Play1: TMenuItem;
    Record1: TMenuItem;
    Pause1: TMenuItem;
    Stop1: TMenuItem;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Edit1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    ClearSelection1: TMenuItem;
    Delete1: TMenuItem;
    Undo1: TMenuItem;
    N1: TMenuItem;
    SaveAs1: TMenuItem;
    N2: TMenuItem;
    View1: TMenuItem;
    ZoomOut1: TMenuItem;
    ZoomIn1: TMenuItem;
    FullView1: TMenuItem;
    PaintBox1: TPaintBox;
    N3: TMenuItem;
    SelectAll1: TMenuItem;
    SpectralView: TMenuItem;
    N5: TMenuItem;
    Analyze1: TMenuItem;
    TimeDomain1: TMenuItem;
    FrequencyDomain1: TMenuItem;
    ZeroCrosingRate1: TMenuItem;
    ShortTimeEnergy1: TMenuItem;
    TemporalDerivatives1: TMenuItem;
    WaveletDecomposition1: TMenuItem;
    Panel1: TPanel;
    Header1: THeader;
    ScrollBarH: TScrollBar;
    Panel2: TPanel;
    ScrollBarV: TScrollBar;
    Button1: TButton;
    procedure New1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Close2Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FullView1Click(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ZoomIn1Click(Sender: TObject);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ZoomOut1Click(Sender: TObject);
    procedure Play1Click(Sender: TObject);
    procedure Stop1Click(Sender: TObject);
    procedure Pause1Click(Sender: TObject);
    procedure Record1Click(Sender: TObject);
    procedure SaveSelectionAs1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure ClearSelection1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure SpectralViewClick(Sender: TObject);
    procedure ScrollBarHScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure ScrollBarHKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ScrollBarHKeyPress(Sender: TObject; var Key: Char);
    procedure ScrollBarHKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure RedrawOnX(DoRefresh:boolean);
    procedure CloseWaveAndTimer;
    procedure Spectogram(cancel_selection:boolean);
  public
    { Public declarations }
    Drawing,inregistreaza,overrecord:Boolean;
    DeleteRect,InitialRect:TRect;
  end;

var
  XPause,XPaint, XScroll :boolean;
  D:TRect;
  Start,Initial,Final:TPoint;
  XLine,SBPosition:integer;
  Form2: TForm2;
  FormActiveTimeStamp : DWORD;

implementation

{$R *.DFM}

uses Main;

procedure TForm2.CloseWaveAndTimer;
begin
  Form1.Timer1.Enabled:=False;
  Form1.MediaPlayer1.Filename:='';
  Form1.Mediaplayer1.Close;
  Form1.MediaPlayer1.Tag:=0;
  InvertRect(PaintBox1.Canvas.Handle,D);
  D.Left:=0;D.Top:=0;D.Right:=0;D.Bottom:=0;
end;

procedure TForm2.RedrawOnX(DoRefresh:Boolean);
var
  Inceput,Sfirsit,DCOffset,StartZoomIn,EndZoomIn:longint;
  ZeroLine,Kind:Boolean;
  es_pixel:single;
begin
  if Tag=0 then Exit;{daca nu este deschis nici un wav in forma}
  CloseWaveAndTimer;
  if BitsPerSample(Caption)=8 then
  begin
    Kind:=True;
    Sfirsit:=AudioDataLength(Caption);
  end else
  begin
    Kind:=False;
    Sfirsit:=AudioDataLength(Caption) div 2;
  end;
  if Sfirsit<>StrToInt(Label6.Caption)then
  begin
    FullView1.Click{if in the mean time size fo wav fiel changed then re-open}
  end else
  begin
    CloseWaveAndTimer;
    Inceput:=StrToInt(Label1.Caption);
    Sfirsit:=Label1.Tag;
    if Label6.Color=clRed then Kind:=False else Kind:=True;
    ZeroLine:=Settings.CheckBox2.Checked;
    DCOffset:=StrToInt(Settings.Edit2.Text);

    if SpectralView.Checked then Spectogram(false)
    else DrawFast(Inceput,Sfirsit,Caption,PaintBox1,Zeroline,Kind,DCOffset,DoRefresh);

    {Update Esantioane/Pixel}
    es_pixel:=(abs(Sfirsit-Inceput)/PaintBox1.Width);
    Label4.Caption:=FloatToStr(es_pixel);
    {Update Start.X si Final.X}
    StartZoomIn:=StrToInt(Label2.Caption);
    EndZoomIn:=StrToInt(Label3.Caption);
    if ((StartZoomIn=Inceput) and (EndZoomIn=Sfirsit)) and (SelectAll1.Checked=False) then
    {daca este selectat tot wav-ul fara a folosi SelectAll}
    begin
      Start.X:=-1;Final.X:=-1;{anuleaza selectia totala}
    end else
    begin
      if (abs(Label3.Tag-Label2.Tag)>0) or (abs(StartZoomIn-EndZoomIn)>0) then{if selection then update}
      begin
        if es_pixel=0 then Exit;
        Start.X:=Trunc((StartZoomIn-Inceput)/es_pixel);
        Label2.Tag:=Start.X;
        Final.X:=Trunc((EndZoomIn-Inceput)/es_pixel);
        if Final.X=StrToInt(Label6.Caption) then Final.X:=0;
        Label3.Tag:=Final.X;
        Header1.Tag:=-1;
      end else{if no selection then cancel selection}
      begin
        Start.X:=-1;Final.X:=-1;
        Label2.Tag:=Start.X;
        Label3.Tag:=Final.X;
        {draw status line}
        PaintBox1.Canvas.MoveTo(Round(Header1.Tag/1000*PaintBox1.Width),0);
        PaintBox1.Canvas.Pen.Mode:=pmNot;
        PaintBox1.Canvas.LineTo(Round(Header1.Tag/1000*PaintBox1.Width),PaintBox1.Height);
        PaintBox1.Canvas.Pen.Mode:=pmCopy;
      end;
    end;
    {inverse rect}
    DeleteRect.Left:=Start.X;{Label2.Tag}
    DeleteRect.Top:=0;
    DeleteRect.Right:=Final.X;{Label3.Tag;}
    DeleteRect.Bottom:=PaintBox1.Height;
    InvertRect(PaintBox1.Canvas.Handle,DeleteRect);
  end;
end;

procedure TForm2.Spectogram(cancel_selection:boolean);
var
  inceput,sfirsit,lungime,frecventa,domeniu:longint;
  nivel:shortint;
  kind:boolean;
begin
  CloseWaveAndTimer;
  Inceput:=StrToInt(Label1.Caption);
  Sfirsit:=Label1.Tag;
  if BitsPerSample(Caption)=8 then kind:=True else Kind:=False;
  if kind then Lungime:=AudioDataLength(Caption)
  else Lungime:=AudioDataLength(Caption) div 2;{cite es pe 16 biti sint}
  Frecventa:=StrToInt(Label5.Caption);
  Domeniu:=StrToInt(Settings.Edit6.Text);
  nivel:=StrToInt(Settings.Edit2.Text);
  if cancel_selection then
  begin
    Start.X:=-1;Final.X:=-1;
    Label2.Tag:=-1;Label3.Tag:=-1;
    Header1.Tag:=-1;{anulez selectia si linia de stare}
  end;
  Spectograma(inceput,sfirsit,lungime,frecventa,domeniu,Caption,nivel,PaintBox1,kind,
  StrToInt(Settings.Edit4.Text));
end;

procedure TForm2.New1Click(Sender: TObject);
begin
  Form1.New1.Click;
end;

procedure TForm2.Exit1Click(Sender: TObject);
begin
  CloseWaveAndTimer;
  Form1.Exit1.Click;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
var
  fn:array[0..255] of char;
begin
 if Undo1.Enabled then
   if MessageDlg('File '+ExtractFileName(Caption)+' has change. Save last change ?',
                      mtConfirmation, [mbYes, mbNo], 0) = mrNo then
   begin
     StrPCopy(fn,Caption);
     DeleteFile(fn);
     RenameFile(ChangeFileExt(Caption,'.tmp'),Caption);
   end else
   begin
     StrPCopy(fn,ChangeFileExt(Caption,'.tmp'));
     DeleteFile(fn);
   end;
   CloseWaveAndTimer;
   Action:=caFree;
end;

procedure TForm2.Close2Click(Sender: TObject);
begin
 CloseWaveAndTimer;
 Close;
end;

procedure TForm2.Open1Click(Sender: TObject);
begin
 Form1.Open1.Click;
end;

procedure TForm2.FormActivate(Sender: TObject);
var
  Exista1,Exista2:boolean;
begin
  Exista1:=FileExists(Caption);
  if not Exista1 then Tag:=0;
  Exista2:=FileExists(PChar(ExpandFileName(ExtractFileDir(Application.ExeName))+ '\clip.wav'));
  if Exista2 then Paste1.Enabled:=True else Paste1.Enabled:=False;
  CloseWaveAndTimer;
  FormActiveTimeStamp := GetTickCount();
end;

procedure TForm2.FullView1Click(Sender: TObject);
var
  Inceput,Sfirsit:longint;
  Zeroline,Kind:boolean;
  DCOffset:shortint;
  es_pixel:single;
  sir:string;
begin
  SpectralView.Checked:=False;
  if Tag=0 then Exit;{if not wav file is open in the form}
  CloseWaveAndTimer;
  sir:=ExtractFilePath(Caption);
  sir:=Copy(sir,1,(Length(sir)-1));
  ChDir(sir);
  ZeroLine:=Settings.CheckBox2.Checked;
  DCOffset:=StrToInt(Settings.Edit2.Text);Inceput:=0;
  if BitsPerSample(Caption)=8 then
  begin
    Kind:=True;
    Sfirsit:=AudioDataLength(Caption);
  end else
  begin
    Kind:=False;
    Sfirsit:=AudioDataLength(Caption) div 2;
  end;
  Label1.Caption:='0';
  Label2.Caption:='0';
  Label3.Caption:=IntToStr(Sfirsit);
  es_pixel:=Sfirsit/PaintBox1.Width;
  Label4.Caption:=FloatToStr(es_pixel);
  Label5.Caption:=IntToStr(PlayBackFrequency(Caption));
  Label6.Caption:=IntToStr(Sfirsit);
  Label1.Tag:=Sfirsit;
  if not kind then Label6.Color:=clRed;
  XPaint:=True;
  Start.X:=-1;Final.X:=-1;Label2.Tag:=-1;Label3.Tag:=-1;
  Header1.Tag:=-1;{anulez selectia si linia de stare}
  DrawFast(Inceput,Sfirsit,Caption,PaintBox1,ZeroLine,Kind,DCOffset,true);
  Application.ProcessMessages;{scap de OnPaint}
  XPaint:=False;
  UpdateHeaderOnOpen(Header1,Caption,kind,StrToInt(Label5.Caption),inceput,sfirsit)
end;

procedure TForm2.ZoomIn1Click(Sender: TObject);
var
  kind,ZeroLine:boolean;
  Inceput,Sfirsit,DCOffset:Longint;
begin
  if Tag=0 then Exit;{if no wav file is open in the form}
  CloseWaveAndTimer;
  SwitchMax(Label2,Label3);
  ZeroLine:=Settings.CheckBox2.Checked;
  if Label6.Color=clRed then Kind:=False else Kind:=True;
  Label1.Caption:=Label2.Caption;{update zoom in bounds}
  Label1.Tag:=StrToInt(Label3.Caption);
  Inceput:=StrToInt(Label1.Caption);
  Sfirsit:=StrToInt(Label3.Caption);
  DCOffset:=StrToInt(Settings.Edit2.Text);
  Start.X:=-1;Final.X:=-1;Header1.Tag:=-1;
  Label2.Tag:=-1;Label3.Tag:=-1;
  SelectAll1.Checked:=False;
  XPaint:=True;
  if SpectralView.Checked then
    Spectogram(false)
  else begin
    DrawFast(Inceput,Sfirsit,Caption,PaintBox1,ZeroLine,Kind,DCOffset,true);
  end;
  Application.ProcessMessages;{scap de OnPaint}
  XPaint:=False;
  Label4.Caption:=FloatToStr(abs(Sfirsit-Inceput)/PaintBox1.Width);
end;

procedure TForm2.ZoomOut1Click(Sender: TObject);
var
  Inceput,Sfirsit,cuanta,Zoom_Factor:Longint;
begin
  if Tag=0 then Exit;{daca nu este deschis nici un wav in forma}
  CloseWaveAndTimer;
  Zoom_Factor:=StrToInt(Settings.Edit3.Text);
  Label2.Tag:=Label3.Tag-1;
  cuanta:=Trunc(abs(StrToInt(Label1.Caption)-Label1.Tag)/Zoom_Factor);
  Inceput:=StrToInt(Label1.Caption);
  Inceput:=Inceput-cuanta;
  if Inceput<0 then Inceput:=0;
  Sfirsit:=Label1.Tag+cuanta;
  if Sfirsit>StrToInt(Label6.Caption) then Sfirsit:=StrToInt(Label6.Caption);
  Label1.Caption:=IntToStr(Inceput);
  Label1.Tag:=Sfirsit;
  if SpectralView.Checked then RedrawOnX(False)
  else begin
    RedrawOnX(False);
  end;
end;

procedure TForm2.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if ( GetTickCount()-FormActiveTimeStamp < 250 ) then Exit;
 if Tag=0 then Exit;   // no file open in window
 if Button=mbLeft then
  begin
   Drawing:=True;
   if SelectAll1.Checked=True then SelectAll1.Checked:=False else
    begin
     DeleteRect.Left:=Label2.Tag;
     DeleteRect.Right:=Label3.Tag;
     DeleteRect.Bottom:=PaintBox1.Height;
     DeleteRect.Top:=0;
    end;
   if Header1.Tag>=0 then
   begin
    {delete old line}
    PaintBox1.Canvas.MoveTo(Round(Header1.Tag/1000*PaintBox1.Width),0);
    PaintBox1.Canvas.Pen.Mode:=pmNot;
    PaintBox1.Canvas.LineTo(Round(Header1.Tag/1000*PaintBox1.Width),PaintBox1.Height);
    PaintBox1.Canvas.Pen.Mode:=pmCopy;
   end;
   Label4.Tag:=StrToInt(Label2.Caption);{ memo pentru OnPaint in cazul formelor suprapuse}
   Label2.Caption:=IntToStr(StrToInt(Label1.Caption)+Trunc(x*StrToFloat(Label4.Caption)));
   {this is the temporal Start Zoom In}
   {draw new line}
   Header1.Tag:=Round(x/PaintBox1.Width*1000);
   PaintBox1.Canvas.MoveTo(Round(Header1.Tag/1000*PaintBox1.Width),0);
   PaintBox1.Canvas.Pen.Mode:=pmNot;
   PaintBox1.Canvas.LineTo(Round(Header1.Tag/1000*PaintBox1.Width),PaintBox1.Height);
   PaintBox1.Canvas.Pen.Mode:=pmCopy;
   InvertRect(PaintBox1.Canvas.Handle,DeleteRect);
   Start.X:=X;
   Label2.Tag:=X;
   Initial.X:=X;
   UpdateHeaderOnMouseDown(Header1,Label2.Caption);
  end;
end;

procedure TForm2.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Drawing then
  begin
    if x>=PaintBox1.Width then x:=PaintBox1.Width;
    if x<=0 then x:=0;
    Label3.Caption:=IntToStr(StrToInt(Label1.Caption)+Trunc(x*StrToFloat(Label4.Caption)));
    InitialRect.Left:=Initial.X;
    InitialRect.Top:=0;
    InitialRect.Right:=X;
    InitialRect.Bottom:=PaintBox1.Height;
    InvertRect(PaintBox1.Canvas.Handle,InitialRect);
    Initial.X:=X;
    UpDateHeaderOnMouseMove(Header1,Label2.Caption,Label3.Caption,StrToInt(Label5.Caption));
  end;
end;

procedure TForm2.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Drawing then
  begin
    if Button=mbLeft then
    begin
      if x>=PaintBox1.Width then x:=PaintBox1.Width;
      if x<=0 then x:=0;
      Label3.Caption:=IntToStr(StrToInt(Label1.Caption)+Trunc(x*StrToFloat(Label4.Caption)));
      Drawing:=False;
      Final.X:=X;
      Label3.Tag:=X;
      UpdateHeaderOnMouseUp(Header1,Label2.Caption,Label3.Caption,Label1.Caption,
      Label1.Tag,StrToInt(Label5.Caption));
    end;
  end;
end;

procedure TForm2.Play1Click(Sender: TObject);
begin
  if (Tag=0) or inregistreaza then Exit;{there is no open wav}
  SwitchMax(Label2,Label3);
  with Form1.MediaPlayer1 do
  begin
    FileName:=Caption;
    Open;
    TimeFormat := tfSamples;
    if StrToInt(Label2.Caption)=StrToInt(Label3.Caption) then
    begin
      StartPos:=StrToInt(Label1.Caption);
      EndPos:=Label1.Tag;
    end else
    begin
      StartPos:=StrToInt(Label2.Caption);
      EndPos:=StrToInt(Label3.caption);
    end;
    Play;
    Tag:=1;{mediaplayer open = true}
  end;
  Form1.Timer1.Enabled:=True;
end;

procedure TForm2.Stop1Click(Sender: TObject);
var
  fn:array[0..255] of char;
begin
  if Form1.MediaPlayer1.Tag=1{if open wav} then Form1.MediaPlayer1.Stop;
  if inregistreaza then
  begin
    if FileExists(Caption) and (Tag=0) then
       if MessageDlg('This file allready exist. Do you want to overwrite?',
         mtConfirmation, [mbYes, mbNo], 0) = mrNo then
         if Form1.SaveDialog1.Execute then Caption:=Form1.SaveDialog1.FileName
         else begin
           Form1.MediaPlayer1.Filename:='';
           Form1.MediaPlayer1.Close;
           DeleteFile('header.wav');
           Tag:=0;
           inregistreaza:=False;
           Exit;
         end;
         if overrecord then
         begin
           Form1.MediaPlayer1.Filename:=ChangeFileExt(Caption,'.wa~');
           Form1.MediaPlayer1.Save;
           Form1.MediaPlayer1.Close;
           StrPCopy(fn,ChangeFileExt(Caption,'.tmp'));
           DeleteFile(fn);
           RenameFile(Caption,ChangeFileExt(Caption,'.tmp'));
           StrPCopy(fn,Caption);
           DeleteFile(fn);
           RenameFile(ChangeFileExt(Caption,'.wa~'),Caption);
           Undo1.Enabled:=True;
         end else
         begin
           Form1.MediaPlayer1.Filename:=Caption;
           Form1.MediaPlayer1.Save;
           Form1.MediaPlayer1.Close;
           DeleteFile('header.wav');
         end;
         inregistreaza:=false;
         Tag:=1;
         FullView1.Click;
  end;
end;

procedure TForm2.Pause1Click(Sender: TObject);
begin
  if Form1.MediaPlayer1.Tag=1{daca este deschis} then
  try
    if  XPause then Form1.MediaPlayer1.PauseOnly else Form1.MediaPlayer1.Resume
    except
      on EMCIDeviceError do Exit;
  end;
  XPause:=not XPause;
end;

procedure TForm2.Record1Click(Sender: TObject);
var
  Resolutie,SamplingRate:word;
begin
  if inregistreaza then Exit;
  if Settings.CheckBox1.Checked then
    SamplingRate:=StrToInt(Settings.ComboBox1.Text)
  else SamplingRate:=StrToInt(Settings.Edit1.Text);
  if Settings.RadioButton1.Checked then Resolutie:=8 else Resolutie:=16;

  if Tag=1 then overrecord:=True else overrecord:=false;
  with Form1.MediaPlayer1 do
  begin
    if overrecord then
    begin
      FileName:=Caption;
      Open;
      StartPos := TrackLength[1];
    end else
    begin
      PregatesteHeader(1,Resolutie,SamplingRate,'header.wav');
      Filename:='header.wav';
      Open;
    end;
    StartRecording;
    Form1.MediaPlayer1.Tag:=1;{flag mediaplayer Open}
    inregistreaza:=true;
  end;
end;

procedure TForm2.SaveSelectionAs1Click(Sender: TObject);
begin
  if Tag=0 then Exit;
  SwitchMax(Label2,Label3);
  if Form1.SaveDialog1.Execute then
  begin
    CloseWaveAndTimer;
    SaveAs(Label2.Caption,Label3.Caption,Form1.SaveDialog1.FileName,Caption);
  end;
end;

procedure TForm2.Delete1Click(Sender: TObject);
var
  fn:array[0..255] of char;
begin
  if MessageDlg('Do you really want to delete ' + ExtractFileName(Caption) + '?',
               mtConfirmation, [mbYes,mbNo],0) = mrYes then
  begin
    Close;
    StrPCopy(fn,Caption);
    DeleteFile(fn);
    StrPCopy(fn,ChangeFileExt(Caption,'.tmp'));
    DeleteFile(fn);
  end;
end;

procedure TForm2.ClearSelection1Click(Sender: TObject);
var
  kind:boolean;
  Selection:longint;
begin
  if Tag=0 then Exit;
  if Label6.Color=clBtnFace then Kind:=True else Kind:=False;
  SwitchMax(Label2,Label3);
  CloseWaveAndTimer;
  ClearSelection(Caption,StrToInt(Label2.Caption),StrToInt(Label3.Caption),
                 StrToInt(Label6.Caption),kind);
  Undo1.Enabled:=True;
  {refac sfirsit,memorez startzoomIn si EndZoomIn in Label5,6.Tag ,noua lungime}
  Selection:=abs(StrToInt(Label3.Caption)-StrToInt(Label2.Caption));
  Label1.Tag:=Label1.Tag-Selection;{sfirsit}
  Label5.Tag:=StrToInt(Label2.Caption);Label6.Tag:=StrToInt(Label3.Caption);{memorez}
  Label2.Caption:='0';Label3.Caption:='0';{nu am zoom}
  Label6.Caption:=IntToStr(StrToInt(Label6.Caption)-Selection);
  RedrawOnX(True);
  Label2.Caption:=Label1.Caption;
  Label3.Caption:=IntTostr(Label1.Tag);{refac zoom}
  UpdateHeaderOnOpen(Header1,Caption,kind,StrToInt(Label5.Caption),StrToInt(Label1.Caption),Label1.Tag);
end;

procedure TForm2.Undo1Click(Sender: TObject);
var
  selection,lungime:longint;
  fn:array[0..255] of char;
begin
  if Tag=0 then Undo1.Enabled:=False;{daca nu am wave deschis in forma}
  {trebuie prevazut si cazul in care undo file a fost sters accidental}
  if Undo1.Enabled=False then Exit;
  CloseWaveAndTimer;
  StrPCopy(fn,Caption);
  DeleteFile(fn);
  RenameFile(ChangeFileExt(Caption,'.tmp'),Caption);
  Undo1.Enabled:=False;
  {refac conditiile a.i. sa am portiunea selectata}

  {refac zoomul a.i. sa cuprinda sectiunea "taiata" anterior}
  if StrToInt(Label1.Caption)>Label5.Tag then Label1.Caption:='0';{de la ce es incepe afisarea}
  Label2.Caption:=IntToStr(Label5.Tag);{incarcat memo de la StartZoomIn}

  Label3.Caption:=IntTostr(Label6.Tag);{incarcat EndZoomIn din undo}

  { if Label6.Color=clBtnFace then Lungime:=AudioDataLength(Caption) else
  Lungime:=AudioDataLength(Caption) div 2;}
  selection:=abs(Label5.Tag-Label6.Tag);{lungimea bucatii taiate anterior}
  lungime:=StrToInt(Label6.Caption)+selection;
  Label6.Caption:=IntToStr(Lungime);
  if (Label1.Tag<StrToInt(Label3.Caption))or(Label1.Tag>StrToInt(Label6.Caption)) then
  Label1.Tag:=Lungime;

  RedrawOnX(false);
end;

procedure TForm2.SaveAs1Click(Sender: TObject);
var
  fn:array[0..255] of char;
begin
  if Form1.SaveDialog1.Execute then
  begin
    StrPCopy(fn,Form1.SaveDialog1.FileName);
    DeleteFile(fn);
    RenameFile(Caption,Form1.SaveDialog1.FileName);
    Caption:=Form1.SaveDialog1.Filename;
  end;
end;

procedure TForm2.FormPaint(Sender: TObject);
var
  Exista:boolean;
begin
  if XPaint then Exit;
  Exista:=FileExists(Caption);
  if Exista then
  begin
    if Drawing then
    begin
      Application.ProcessMessages;
      Drawing:=False;
      if Label4.Tag<>StrToInt(Label2.Caption) then Label2.Caption:=IntToStr(Label4.Tag);
      {folosita in cazul suprapunerilor de childform}
    end;
    RedrawOnX(False);  // no refresh
  end else Tag:=0;
end;

procedure TForm2.Copy1Click(Sender: TObject);
begin
  if Tag=0 then Exit;
  SwitchMax(Label2,Label3);
  CloseWaveAndTimer;
  SaveAs(Label2.Caption,Label3.Caption,PChar(ExpandFileName(ExtractFileDir(Application.ExeName))+ '\clip.wav'),Caption);
  Paste1.Enabled:=True;
end;

procedure TForm2.Cut1Click(Sender: TObject);
begin
  Copy1.Click;
  ClearSelection1.Click;
  Paste1.Enabled:=True;
end;

procedure TForm2.Paste1Click(Sender: TObject);
var
  kind,LungimeClip,LungimeCut,LungimeFinalaWav:longint;
begin
  if tag=1 then
  begin
    if CompareWavHeaders(Caption,PChar(ExpandFileName(ExtractFileDir(Application.ExeName))+ '\clip.wav')) then
    begin
      MessageDlg('Incompatible format with clipboard data !',mtInformation, [mbOK],0);
      Exit;
    end;
    SwitchMax(Label2,Label3);
    Label5.Tag:=StrToInt(Label2.Caption);Label6.Tag:=StrToInt(Label3.Caption);{memorez}
    if Label6.Color=clBtnFace then kind:=1 else kind:=2;
    LungimeCut:=abs(StrToInt(Label2.Caption)-strToInt(Label3.Caption));
    LungimeClip:=PasteOver(Caption,PChar(ExpandFileName(ExtractFileDir(Application.ExeName))+ '\clip.wav'),
    StrToInt(Label2.Caption),StrToInt(Label3.Caption),StrToInt(Label6.Caption),kind);
    LungimeFinalaWav:=StrToInt(Label6.Caption)-LungimeCut+LungimeClip;
    Undo1.Enabled:=True;
    Header1.Tag:=-1;Label2.Tag:=Label3.Tag-1;Tag:=1;
    Label1.Tag:=Label1.Tag+LungimeClip-LungimeCut;{end}
    Label3.Caption:=IntToStr(StrToInt(Label3.Caption)+LungimeClip-LungimeCut);{EndZoomIn}
    Label6.Caption:=IntToStr(LungimeFinalaWav);
    RedrawOnX(false);
  end else
  begin
    SaveAs(IntToStr(0),IntToStr(AudioDataLength(PChar(ExpandFileName(ExtractFileDir(Application.ExeName))+ '\clip.wav'))),Caption,'C:/clip.wav');
    Tag:=1;
    FullView1.Click;
  end;
end;

procedure TForm2.SelectAll1Click(Sender: TObject);
begin
  if tag<>1 then Exit;
  {inverse rect}
  DeleteRect.Left:=Label2.Tag;
  DeleteRect.Top:=0;
  DeleteRect.Right:=Label3.Tag;
  DeleteRect.Bottom:=PaintBox1.Height;
  InvertRect(PaintBox1.Canvas.Handle,DeleteRect);
  {delete status line}
  if abs(Label3.Tag-Label2.Tag)>=0 then
  begin
    {delete oldline}
    PaintBox1.Canvas.MoveTo(Round(Header1.Tag/1000*PaintBox1.Width),0);
    PaintBox1.Canvas.Pen.Mode:=pmNot;
    PaintBox1.Canvas.LineTo(Round(Header1.Tag/1000*PaintBox1.Width),PaintBox1.Height);
    PaintBox1.Canvas.Pen.Mode:=pmCopy;
  end;

  Header1.Tag:=-1;
  Label2.Caption:=Label1.Caption;
  Label3.Caption:=IntToStr(Label1.Tag);
  Label2.Tag:=0;Label3.Tag:=PaintBox1.Width;
  {inverse rect}
  DeleteRect.Left:=Label2.Tag;
  DeleteRect.Top:=0;
  DeleteRect.Right:=Label3.Tag;
  DeleteRect.Bottom:=PaintBox1.Height;
  InvertRect(PaintBox1.Canvas.Handle,DeleteRect);
  UpdateHeaderOnMouseUp(Header1,Label2.Caption,Label3.Caption,Label1.Caption,
                        Label1.Tag,StrToInt(Label5.Caption));
  SelectAll1.Checked:=True;
end;

procedure TForm2.SpectralViewClick(Sender: TObject);
begin
  Spectogram(true);
  if Settings.CheckBox3.Checked then SpectralView.Checked:=True;
end;

procedure TForm2.ScrollBarHScroll(Sender: TObject; ScrollCode: TScrollCode;
var
  ScrollPos: Integer);
var
  DeltaESBposition, DeltaChange, Inceput,Sfirsit,Lungime:longint;
begin
  //OnScroll generates 2 events

  Inceput:=StrToInt(Label1.Caption);
  Sfirsit:=Label1.Tag;
  Lungime:=StrToInt(Label6.Caption);
  // ScrolbarH set to:
  // Min=1, Max=101, Position=51,
  // SmallChange=1, LargeChange=10,
  // Set 1 hundreth of curent zoom as a scrollbar unit of change
  DeltaESBPosition:=Trunc(Abs(Inceput-Sfirsit)/100);
  DeltaChange := DeltaESBPosition*(ScrollPos-ScrollBarH.Position);

  // skip second scroll event when not at min or max position
  // will still double load on min and max position
  if (ScrollPos = ScrollBarH.Min) then DeltaChange := -DeltaESBPosition
  else if (ScrollPos = ScrollBarH.Max) then DeltaChange := DeltaESBPosition
  else if DeltaChange = 0 then Exit;

  Inceput := Inceput + DeltaChange;
  Sfirsit := Sfirsit + DeltaChange;
  if Inceput < 0 then Inceput:=0;
  if Sfirsit>Lungime then Sfirsit:=Lungime;
  Label1.Caption:=IntToStr(Inceput);
  Label1.Tag:=Sfirsit;
  RedrawOnX(False);
end;

procedure TForm2.ScrollBarHKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Exit;
end;

procedure TForm2.ScrollBarHKeyPress(Sender: TObject; var Key: Char);
begin
  Exit;
end;

procedure TForm2.ScrollBarHKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Exit;
end;

initialization
begin
  XPause:=True;XPaint:=False;
  D.Left:=-1;D.Top:=-1;D.Right:=-1;D.Bottom:=-1;
  XLine:=-1;
end;

end.
