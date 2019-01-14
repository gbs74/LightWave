unit Wave4;
{unit for reading wav file properties}
interface

uses SysUtils;

function ExistaRIFF(sir:string):Boolean;
function ExistaWAVEfmt(sir:string):Boolean;
function Search_data(sir:string):integer;
function FormatType(sir:string):Byte;
function Chanels (sir:string):Byte;
function PlaybackFrequency(sir:string):Word;
function BitsPerSample(sir:string):Byte;
function AudioDataLength(sir:string):longint;
procedure PregatesteHeader(kind,XByte:byte;Freq:longint;nume:string);

implementation

function ExistaRIFF(sir:string):Boolean;
var
  f:file of char;
  c0,c1,c2,c3:char;
begin
  AssignFile(f,sir);
  Reset(f);
  Read(f,c0);Read(f,c1);Read(f,c2);Read(f,c3);
  CloseFile(f);
  if (c0='R')and(c1='I')and(c2='F')and(c3='F')then
  ExistaRIFF:=True else ExistaRIFF:=False;
end;

function ExistaWAVEfmt(sir:string):Boolean;
var
  f:file of char;
  c8,c9,c10,c11,c12,c13,c14:char;
begin
  AssignFile(f,sir);
  Reset(f);
  Seek(f,8);
  Read(f,c8);Read(f,c9);Read(f,c10);Read(f,c11);
  Read(f,c12);Read(f,c13);Read(f,c14);
  CloseFile(f);
  if (c8='W')and(c9='A')and(c10='V')and(c11='E')and(c12='f')and(c13='m')and(c14='t')then
  ExistaWAVEfmt:=True else ExistaWAVEfmt:=False;
end;

function Search_data(sir:string):integer;
type
  buffer=array[1..4] of char;
var
  Buf1,Buf2:^buffer;
  found:boolean;
  f:file;
  i:word;
begin
  New(Buf1);New(Buf2);
  Buf2^[1]:='d';Buf2^[2]:='a';Buf2^[3]:='t';Buf2^[4]:='a';
  AssignFile(f,sir);
  Reset(f,1);
  Seek(f,16);
  repeat
    BlockRead(f,Buf1^,4);
    found:=True;
    for i:=1 to 4 do
    begin
      if ord(Buf1^[i])<>ord(Buf2^[i]) then found:=false;
    end;
    if found=false then Seek(f,FilePos(f)-3);
  until found=True;

   Search_data:=FilePos(f);
   CloseFile(f);
   Dispose(Buf1);Dispose(Buf2);
end;

function FormatType(sir:string):Byte;
var
  f:file of char;
  c20:char;
begin
  AssignFile(f,sir);
  Reset(f);
  Seek(f,20);
  Read(f,c20);
  CloseFile(f);
  FormatType:=ord(c20);
end;

function Chanels (sir:string):Byte;
var
  f:file of char;
  c22:char;
begin
  AssignFile(f,sir);
  Reset(f);
  Seek(f,22);
  Read(f,c22);
  CloseFile(f);
  Chanels:=ord(c22);
end;

function PlaybackFrequency(sir:string):Word;
var
  f:file of char;
  c24,c25:char;
begin
  AssignFile(f,sir);
  Reset(f);
  Seek(f,24);
  Read(f,c24);
  Read(f,c25);
  CloseFile(f);
  PlaybackFrequency:=StrToInt('$'+IntToHex(ord(c25),2)+IntToHex(ord(c24),2));
end;

function BitsPerSample(sir:string):Byte;
var
  f:file of char;
  c34:char;
begin
  AssignFile(f,sir);
  Reset(f);
  Seek(f,34);
  Read(f,c34);
  CloseFile(f);
  BitsPerSample:=ord(c34);
end;

function AudioDataLength(sir:string):longint;
var
  f:file of char;
  Start_data:word;
  c40,c41,c42,c43:char;
begin
  Start_data:=Search_data(sir);
  AssignFile(f,sir);
  Reset(f);
  Seek(f,Start_data);
  Read(f,c40);Read(f,c41);Read(f,c42);Read(f,c43);
  CloseFile(f);
  AudioDataLength:=StrToInt('$'+IntToHex(ord(c43),2)+IntToHex(ord(c42),2)+
                               IntToHex(ord(c41),2)+IntToHex(ord(c40),2));
end;

procedure PregatesteHeader(kind,XByte:byte;Freq:longint;nume:string);
type
  XHeader=array[1..44] of char;
var
  f:file;
  XH:^XHeader;
  temp:longint;
  SForuc:string[8];
begin
  New(XH);
  XH^[1]:='R';XH^[2]:='I';XH^[3]:='F';XH^[4]:='F';{RIFF}
  XH^[5]:='$';XH^[6]:=chr(0);;XH^[7]:=chr(0);XH^[8]:=chr(0);{rLen}
  XH^[9]:='W';XH^[10]:='A';XH^[11]:='V';XH^[12]:='E';{WAVE}
  XH^[13]:='f';XH^[14]:='m';XH^[15]:='t';XH^[16]:=chr(32);{fmt32}
  XH^[17]:=chr(16);XH^[18]:=chr(0);XH^[19]:=chr(0);XH^[20]:=chr(0);{fLen}
  XH^[21]:=chr(1);XH^[22]:=chr(0);{wFormatTag adica PCM}
  XH^[23]:=chr(Kind);XH^[24]:=chr(0);{nChanels}
  SForuc:=IntToHex(Freq,8);
  XH^[25]:=chr(StrToInt('$'+SForuc[7]+SForuc[8]));
  XH^[26]:=chr(StrToInt('$'+SForuc[5]+SForuc[6]));
  XH^[27]:=chr(StrToInt('$'+SForuc[3]+SForuc[4]));
  XH^[28]:=chr(StrToInt('$'+SForuc[1]+SForuc[2]));{nSamplesPerSecond}
  temp:=XByte div 8*kind*Freq;
  SForuc:=IntToHex(temp,8);
  XH^[29]:=chr(StrToInt('$'+SForuc[7]+SForuc[8]));
  XH^[30]:=chr(StrToInt('$'+SForuc[5]+SForuc[6]));
  XH^[31]:=chr(StrToInt('$'+SForuc[3]+SForuc[4]));
  XH^[32]:=chr(StrToInt('$'+SForuc[1]+SForuc[2]));{nAvgBytesPerSec}
  if XByte=8 then temp:=1 else temp:=2;
  XH^[33]:=chr(temp);XH^[34]:=chr(0);{nBlockAlign}
  XH^[35]:=chr(XByte);XH^[36]:=chr(0);{FormatSpecific}
  XH^[37]:='d';XH^[38]:='a';XH^[39]:='t';XH^[40]:='a';{data}
  XH^[41]:=chr(0);XH^[42]:=chr(0);XH^[43]:=chr(0);XH^[44]:=chr(0);{dData}
  AssignFile(f,nume);
  Rewrite(f,1);
  BlockWrite(f,XH^,44);
  CloseFile(f);
  Dispose(XH);
end;


end.

