unit Wave8;
//here are implemented frequency transforms

interface

uses SysUtils, ExtCtrls, Graphics, Setting, Wave4, Wave9;

type
  Table=array[0..2047] of single;{max fft=4096 12 bit}
var
  LookUpR,LookUpI:Table;
  argument:single;
  N,m:word;

function decodare(z:longint):longint;
function codare(z:longint):longint;
function IntPower(X: word; I: Word): word;
procedure Tab_LookUp(biti:byte);
procedure Spectograma(Inceput,Sfirsit,Lungime,Frecventa,Domeniu:longint;sir:string;
                      nivel:shortint;PaintBox:TPaintBox;kind:boolean;biti:byte);

implementation

function decodare(z:longint):longint;{din 0..65535 in -32768..-1,1..32768}
begin
  z:=z-32768;
  if z<0 then z:=z+32768{-32768..-1 to 0..32767}
  else z:=z-32768;{0..32767 to -32768..-1}
  Result:=z;
end;

function codare(z:longint):longint;{din -32768..32767 in 0..65535}
begin
  if z<0 then z:=z+32768{-32768..-1 to 0..32767}
  else z:=z-32768;{0..32767 to -32768..-1}
  Result:=z+32768;
end;

function IntPower(X: word; I: Word): word;
var
  Y: Integer;
begin
  y:=abs(i);
  Result := 1;
  while Y > 0 do begin
    while not Odd(Y) do
    begin
      Y := Y shr 1;
      X := X * X
    end;
    Dec(Y);
    Result := Result * X
  end;
end;


 {where Lungime= lenght of wav in samples,
 Frecventa is the sampling frequency,
 Domeniu frequency domain to dispolay the spectogram in e.g. 5000Hz means 0-5000Hz,
 nivel este valoarea componentei continue
 kind true denotes 8 bit wav and  false 16 bit}
procedure Spectograma(Inceput,Sfirsit,Lungime,Frecventa,Domeniu:longint;sir:string;
                      nivel:shortint;PaintBox:TPaintBox;kind:boolean;biti:byte);
type
  vector=array[1..4096] of single;
  Table=array[0..2047] of single;
  buffer=array[1..8192] of byte;
  linie=array[1..1024] of single;
var
  img:^linie;
  buf:^buffer;
  xr,xi:^vector;
  mag:^vector;
  pondere:^vector;
  Lim1,Lim2,L,k,i,j,u:longint;
  nr1,nr2,z,DC_Offset:longint;
  nr_intrari,nr_fluturi,indice0,indice1,indice2,w,arg1:word;
  TfR,TfI,TempR,TempI:single;
  g:textfile;
  f:file;
  pas,pas1,XDomeniu,fer:word;
  size:integer;
  rest,rest1,NrEs_Linie,NrPc_Pixel,Temp:single;
  Lungime1,contor:longint;
  max_1,max_2,max_3,max_4,max_5,max_6,max,d_1,d_2,d_3,d_4,d_5,factor:single;
  corect:boolean;
  xxdom:word;
  argument,power_fraction:single;
  LookUpR,LookUpI:^Table;
  M,N,Start_data,Data_Width:word;
begin
  New(img);New(Buf);New(XR);New(Xi);New(Mag);New(LookUpR);New(LookUpI);
  New(pondere);
  fer:=CeFereastra;
  (***adjustment***)
  Data_Width:=Round(StrToFloat(Settings.Edit5.Text)*Frecventa/1000);
  N:=IntPower(2,biti);
  i:=0;
  while Data_Width>N do
  begin
    N:=N*2;
    inc(i);
  end;
  m:=biti+i;
  Settings.Edit4.Text:=IntToStr(m);
  N:=IntPower(2,m);
  case N of      // graph constants experimentally set
    256  : power_fraction:=1.1;
    512  : power_fraction:=1;
    1024 : power_fraction:=1.1;
    2048 : power_fraction:=1;
    4096 : power_fraction:=0.9;
  end;

  power_fraction:=Data_Width/N;

  (*****Start calc Table LookUp*****)
  argument:=2*pi/N;
  for contor:=0 to (N div 2)-1 do
  begin
    LookUpR^[contor]:=cos(argument*contor);
    LookUpI^[contor]:=sin(argument*contor);
  end;
  (*****End calcul Table LookUp*****)
  case fer of // graph constants experimentally set
    0 : factor:=1;
    1 : factor:=1/0.42;
    2 : factor:=1/0.54;
    3 : factor:=1/0.5;
    4 : factor:=1/0.637;
  end;
  Start_data:=Search_data(sir)+4;

  max:=100.1/factor*Data_Width/power_fraction;

  if kind then max:=max else max:=256*max;
  max_1:=max/1000;{Black}max_2:=max/750;{Blue}
  max_3:=max/400;{Purple}max_4:=max/100;{Red}
  max_5:=max/10;{Yellow}max_6:=max/2.5;{Lime}
  d_1:=128/(max_2-max_1);d_2:=128/(max_3-max_2);
  d_3:=128/(max_4-max_3);d_4:=255/(max_5-max_4);
  d_5:=255/(max_6-max_5);

  AssignFile(f,sir);
  Reset(f,1);
  if kind then Seek(f,Inceput+Start_data) else Seek(f,Start_data+2*Inceput);
  rest:=0;{pentru NrEs_Linie}
  contor:=0;

  XDomeniu:=Trunc(Domeniu/Frecventa*N);
  if XDomeniu>(N div 2) then XDomeniu:=N div 2;

  NrPc_Pixel:=XDomeniu/PaintBox.Height;
  NrEs_Linie:=(Sfirsit-Inceput)/PaintBox.Width;{esantioane pe linie}
  Lungime1:=Lungime-Inceput;{cite esantioane sint pina la sfirsitul fisierului}
  if kind then DC_Offset:=128+nivel else DC_Offset:=nivel*256;

  for L:=1 to PaintBox.Width do {pentru toate liniile calc 1 FFT}
  begin
    pas:=Trunc(NrEs_Linie+rest);

    if Lungime1<Data_Width{N} then size:=Lungime1 else size:=Data_Width{N};

    (*****Start Input Data*****)
    try
      if kind then BlockRead(f,Buf^,size) else BlockRead(f,Buf^,2*size);
    except on EInOutError do
    begin
      Corect:=True;
      CloseFile(f);
      Dispose(Buf);
      Dispose(Xr);
      Dispose(Xi);
      Dispose(Mag);
      Dispose(Img);
      Dispose(LookUpR);
      Dispose(LookUpI);
      Exit;
    end;
    end;{from try}
    (*******Atention*****)
    if kind then
    begin
      for i:=1 to size do
      begin
        XR^[i]:=Buf^[i]-DC_Offset;
        XI^[i]:=0;
      end;
    end else
    begin
      for i:=1 to size do
      begin
        nr1:=buf^[2*i];nr2:=buf^[2*i-1];
        z:=nr1*256+nr2;
        Xr^[i]:=decodare(z)-DC_Offset;
        XI^[i]:=0;
      end;
    end;
    if size<N then {o comparatie pentru a adauga zerouri}
    begin
      for i:=size+1 to N do
      begin
        XR^[i]:=0;
        XI^[i]:=0;
      end;
    end;
    (*****End Input Data*****)
    (***ponder***)
    case fer of
      0 : for i:=1 to size do pondere^[i]:=1;
      1 : for i:=1 to size do pondere^[i]:=Blackman(i,size);
      2 : for i:=1 to size do pondere^[i]:=Hamming(i,size);
      3 : for i:=1 to size do pondere^[i]:=Hanning(i,size);
      4 : for i:=1 to size do pondere^[i]:=Cosinus(i,size);
    end;

    for i:=1 to size do XR^[i]:=XR^[i]*pondere^[i];

    (*****Start Shufle Input Data*****)
    Lim1:=N-1;Lim2:=N div 2;J:=1;
    for i:=1 to Lim1 do
    begin
      if i<=(j-0.01) then
      begin
        TfR:=Xr^[j];TfI:=Xi^[j];
        Xr^[j]:=XR^[i];Xi^[j]:=Xi^[i];
        Xr^[i]:=TfR;Xi^[i]:=TfI;
      end;
      k:=Lim2;
      while true do
      begin
        if k>(j-0.01) then Break;
        j:=j-k;
        k:=k div 2;
      end;
      j:=j+k;
    end;
    (*****End Shufle Input Data*****)
    (*****Start In Place Transformation*****)
    for i:=1 to m do
    begin  (*for every level*)
      nr_intrari:=IntPower(2,(i-1));(*no of inputs in each buterfly filter/2 !*)
      nr_fluturi:=Lim2 div nr_intrari;{IntPower(2,(m-i))};(*nr of buterfly filters per level*)
      Lim1:=2*nr_intrari;
      for j:=1 to nr_fluturi do
      begin (*for each buterfly filter*)
        indice0:=Lim1*(j-1);
        arg1:=0;
        for k:=1 to nr_intrari do
        begin (*for each filter entry/2 !*)
          indice1:=k+indice0;
          indice2:=nr_intrari+indice1;
          TempR:=xr^[indice1];TempI:=xi^[indice1];
          (*LookUp*) (*compute twidle factor*)
          TfR:=XR^[indice2]*LookUpR^[arg1]+XI^[indice2]*LookUpI^[arg1];
          TfI:=-XR^[indice2]*LookUpI^[arg1]+XI^[indice2]*LookUpR^[arg1];
          (*compute filter output*)
          xr^[indice1]:=TempR+TfR;xi^[indice1]:=TempI+TfI;
          xr^[indice2]:=TempR-TfR;xi^[indice2]:=TempI-TfI;
          inc(arg1,nr_fluturi);
        end;
      end;
    end;
    (*****End In Place Transformation*****)
    (*****Start Modulus computations*****){only for the Domain}
    {XXDom:=XDomeniu;
    if XXDom>(N div 2) then XXDom:=N div 2;}

    for K:=1 to XDomeniu do
    begin
      MAG^[k]:=sqrt(sqr(XR^[K])+sqr(XI^[K]));
    end;{got a vector of XDomeniu components to be placed on line}
    (*****End Moduls computations*****)
    (*****Start the vertical alignment phase and color conversion*****)
    rest1:=0;
    pas1:=0;
    z:=1;
    for i:=1 to PaintBox.Height do
    begin
      Img^[i]:=-100000000;
      inc(z,pas1);
      pas1:=Trunc(NrPc_Pixel+rest1);
      case pas1 of
        0 : Img^[i]:=Mag^[z];
        1 : Img^[i]:=Mag^[z+1]
      else begin
        for j:=z to z+pas1 do
        begin
          if Img^[i]<Mag^[j] then Img^[i]:=Mag^[j];
        end;
      end;
      end;{de la case}

      if Img^[i]<max_1 then
      PaintBox.Canvas.Pixels[L-1,PaintBox.Height-i]:=clBlack;

      if (Img^[i]>max_1) and (Img^[i]<=max_2) then         {1000 750}
      PaintBox.Canvas.Pixels[L-1,PaintBox.Height-i]:=
      Trunc(128+(img^[i]-max_1)*d_1)*65536;                {Black Blue}
                                                           {000088 FF0000}
      if (Img^[i]>max_2) and (Img^[i]<=max_3) then         {750 600}
      PaintBox.Canvas.Pixels[L-1,PaintBox.Height-i]:=
      (255-Trunc((img^[i]-max_2) *d_2))*65536
      +Trunc((img^[i]-max_2)*d_2);                         {Blue Purple}
                                                           {FF0000 880088} {OK PINA AICI}
      if (Img^[i]>max_3) and (Img^[i]<=max_4) then         {600 400}
      PaintBox.Canvas.Pixels[L-1,PaintBox.Height-i]:=
      128+Trunc((img^[i]-max_3)*d_3)+
      65536*(128-Trunc((img^[i]-max_3)*d_3));              {Purple Red}  {OK }
                                                           {880088 0000FF}
      if (Img^[i]>max_4) and (Img^[i]<=max_5) then         {400 100}
      PaintBox.Canvas.Pixels[L-1,PaintBox.Height-i]:=
      $0000ff+256*(Trunc((img^[i]-max_4)*d_4));            {Red Yellow}
                                                           {0000FF 00FFFF}
      if (Img^[i]>max_5) and (Img^[i]<max_6) then
      PaintBox.Canvas.Pixels[L-1,PaintBox.Height-i]:=
      $00ff00+(255-Trunc((img^[i]-max_5)*d_5));            {Yellow Lime}
                                                           {00FFFF 00FF00}

      if Img^[i]>max_6 then
      PaintBox.Canvas.Pixels[L-1,PaintBox.Height-i]:=clLime;

      Temp:=NrPc_Pixel+rest1;
      rest1:=Temp-Trunc(Temp);
    end;{from i:=1 to PaintBox.Height}
    (*****End vertical alignment and color conversion*****)

    inc(contor,pas);{contor = how many samples were skipped from start}
    if kind then Seek(f,Start_data+contor+Inceput) else Seek(f,Start_data+2*(contor+Inceput));
    {curent position setat to next bloxk start}
    dec(Lungime1,pas);
    Temp:=NrEs_Linie+rest;{ rest pentru NrEs_Linie}
    rest:=Temp-Trunc(Temp);
  end;{from all lines cycle by index L}
  CloseFile(f);Dispose(Buf);Dispose(Xr);Dispose(Xi);Dispose(Mag);Dispose(Img);
  Dispose(LookUpR);Dispose(LookUpI);Dispose(pondere);
end;

procedure Tab_LookUp(biti:byte);
var
  contor : word;
begin
  N:=IntPower(2,biti);m:=biti;
  argument:=2*pi/N;
  for contor:=0 to (N div 2)-1 do
  begin
    LookUpR[contor]:=cos(argument*contor);
    LookUpI[contor]:=sin(argument*contor);
  end;
end;

initialization
begin
  m:=11;
  Tab_LookUp(m);
end;

end.

