unit Wave7;

{implement Edit menu methods}

interface

Uses SysUtils, Wave4;

procedure ClearSelection(NumeFisier:string;Inceput,Sfirsit,LungimeInitiala:longint;kind:boolean);
function CompareWavHeaders(File1,File2:string):boolean;
function PasteOver(Oldwav,XClip:string;Inceput,Sfirsit,LungimeWav,kind:longint):longint;

implementation

procedure ClearSelection(NumeFisier:string;Inceput,Sfirsit,LungimeInitiala:longint;kind:boolean);
type
  vector=array[1..65534] of byte;
  bufer=array[1..4] of char;
var
  buf:bufer;
  sir1:string[8];
  aa:^vector;
  LungimeFinala,i,Start_Data,size,delta:longint;
  B_es:shortint;
  f,g:file;
  sir:string;
begin
  sir:=ExtractFilePath(NumeFisier);
  sir:=Copy(sir,1,(Length(sir)-1));
  ChDir(sir);
  DeleteFile(ChangeFileExt(NumeFisier,'.tmp'));
  RenameFile(NumeFisier,ChangeFileExt(NumeFisier,'.tmp'));
  size:=65534;
  Start_data:=Search_data(ChangeFileExt(NumeFisier,'.tmp'))+4;
  {Steps:
    0. Redenumesc wav in tmp
    1. Refac headerul pentru wav
    2. Copiez pina la Inceput din tmp
    3. Sar la Sfirsit
    4. Copiez restul in wav
  }
  LungimeFinala:=LungimeInitiala-abs(Sfirsit-Inceput);{esantioane}
  if Kind then B_es:=1 else B_es:=2;
  LungimeFinala:=LungimeFinala*B_es;{daca e codat pe 16 biti se dubleaza}
  AssignFile(f,ChangeFileExt(NumeFisier,'.tmp'));
  Reset(f,1);
  AssignFile(g,NumeFisier);
  Rewrite(g,1);
  BlockRead(f,buf,4);
  BlockWrite(g,buf,4);{am scris RIFF in temp.wav}
  sir1:=IntToHex(LungimeFinala+36,8);
  buf[1]:=Chr(StrToInt('$'+sir1[7]+sir1[8]));
  buf[2]:=Chr(StrToInt('$'+sir1[5]+sir1[6]));
  buf[3]:=Chr(StrToInt('$'+sir1[3]+sir1[4]));
  buf[4]:=Chr(StrToInt('$'+sir1[1]+sir1[2]));
  BlockWrite(g,buf,4);{am scris cite caractere urmeaza}
  Seek(f,8);
  for i:=1 to 7 do
  begin
    BlockRead(f,buf,4);
    if i=3 then Buf[1]:=chr(16);
   BlockWrite(g,buf,4);
  end;
  Buf[1]:='d';Buf[2]:='a';Buf[3]:='t';Buf[4]:='a';
  BlockWrite(g,buf,4);{am scris 'data'}
  sir1:=IntToHex(LungimeFinala,8);
  buf[1]:=Chr(StrToInt('$'+sir1[7]+sir1[8]));
  buf[2]:=Chr(StrToInt('$'+sir1[5]+sir1[6]));
  buf[3]:=Chr(StrToInt('$'+sir1[3]+sir1[4]));
  buf[4]:=Chr(StrToInt('$'+sir1[1]+sir1[2]));
  BlockWrite(g,buf,4);{am scris cite caractere urmeaza}
  {effective copy of chars until begining}
  Seek(f,Start_data);
  delta:=Inceput*B_es;
  new(aa);i:=0;

  repeat
    while delta>0 do
    begin
      if size<=delta then
      begin
        BlockRead(f,aa^,size);
        BlockWrite(g,aa^,size);
      end else
      begin
        size:=delta;
        BlockRead(f,aa^,size);
        BlockWrite(g,aa^,size);
      end;
      dec(delta,size);
    end;
    if i=0 then
    begin
      Seek(f,Start_data+Sfirsit*B_es);{jump to end}
      delta:=(LungimeInitiala-Sfirsit)*B_es;
    end;
    inc(i);
  until i>1;

  Dispose(aa);CloseFile(f);CloseFile(g);{am terminat pasul 4}
end;

function CompareWavHeaders(File1,File2:string):boolean;
type
  bufer=array[1..16] of char;
var
  buf1,buf2:bufer;
  f1,f2:file;
  i:shortint;
begin
  Assignfile(f1,File1);
  Reset(f1,1);
  Seek(f1,20);
  BlockRead(f1,Buf1,16);
  CloseFile(f1);
  Assignfile(f2,File2);
  Reset(f2,1);
  Seek(f2,20);
  BlockRead(f2,Buf2,16);
  CloseFile(f2);
  Result:=false;
  for i:=1 to 16 do if Buf1[i]<>Buf2[i] then begin Result:=true; Exit; end;
end;

{includes header preparation for the rezultat file,
returns the length of the clipboard file
kind:=1 8bit, kind:=2 16bit}
function PasteOver(Oldwav,XClip:string;Inceput,Sfirsit,LungimeWav,kind:longint):longint;
type
  vector=array[1..65534] of byte;
  bufer=array[1..4] of char;
var
  buf:bufer;
  sir1:string[8];
  LungimeClip,LungimeFinalaWav,d,size:Longint;
  StartDataWav,i:integer;
  aa:^vector;
  f1,f2,f3:file;
  sir:string;
begin
  sir:=ExtractFilePath(OldWav);
  sir:=Copy(sir,1,(Length(sir)-1));
  ChDir(sir);
  size:=65534;
  StartDataWav:=Search_data(OldWav)+4;
  LungimeClip:=AudioDataLength(XClip) div kind;{how many samples are in clip.wav}
  LungimeFinalaWav:=LungimeWav+LungimeClip-abs(Sfirsit-Inceput);{samples}
  sir1:=IntToHex(LungimeFinalaWav*kind+36,8);{bytes}
  {steps:
    - 1 rename the old one to *.tmp
    - 2 create *.wav file and Prepare header
    - 3 copy from *.wav until begining
    - 4 add clip.wav
    - 5 copy the rest fo the file until the end}
  DeleteFile(ChangeFileExt(Oldwav,'.tmp'));
  RenameFile(Oldwav,ChangeFileExt(Oldwav,'.tmp'));
  AssignFile(f1,Oldwav);
  Rewrite(f1,1);{scriu in el}
  AssignFile(f2,XClip);
  Reset(f2,1);{citesc din el clipboard}
  AssignFile(f3,ChangeFileExt(Oldwav,'.tmp'));
  Reset(f3,1);{citesc din el undo file}
  {prepare header}
  BlockRead(f3,buf,4);
  BlockWrite(f1,buf,4);{am scris RIFF}
  buf[1]:=Chr(StrToInt('$'+sir1[7]+sir1[8]));
  buf[2]:=Chr(StrToInt('$'+sir1[5]+sir1[6]));
  buf[3]:=Chr(StrToInt('$'+sir1[3]+sir1[4]));
  buf[4]:=Chr(StrToInt('$'+sir1[1]+sir1[2]));
  BlockWrite(f1,buf,4);{am scris cite caractere urmeaza}
  Seek(f3,8);
  for i:=1 to 7 do
  begin
    BlockRead(f3,buf,4);
    if i=3 then Buf[1]:=chr(16);
    BlockWrite(f1,buf,4);
  end;
  Buf[1]:='d';Buf[2]:='a';Buf[3]:='t';Buf[4]:='a';
  BlockWrite(f1,buf,4);{am scris 'data'}
  sir1:=IntToHex(LungimeFinalaWav*kind,8);{wrote how many chars will follow after data}
  buf[1]:=Chr(StrToInt('$'+sir1[7]+sir1[8]));
  buf[2]:=Chr(StrToInt('$'+sir1[5]+sir1[6]));
  buf[3]:=Chr(StrToInt('$'+sir1[3]+sir1[4]));
  buf[4]:=Chr(StrToInt('$'+sir1[1]+sir1[2]));
  BlockWrite(f1,buf,4);{wrote how many chars follow}
  Seek(f3,StartdataWav);
  d:=Inceput*kind;{size of first block until begining in chars}
  new(aa);
  repeat
    if d=0 then break;
    if size<=d then
    begin
      BlockRead(f3,aa^,size);
      BlockWrite(f1,aa^,size);
    end else
    begin
      size:=d;
      BlockRead(f3,aa^,size);
      BlockWrite(f1,aa^,size);
    end;
  dec(d,size);
  until d<=0;{I copied the first block now I have to copy the clipboard}

  Seek(f2,44);
  d:=LungimeClip*kind;

  repeat
    if d=0 then break;
    if size<=d then
    begin
      BlockRead(f2,aa^,size);
      BlockWrite(f1,aa^,size);
    end else
    begin
      size:=d;
      BlockRead(f2,aa^,size);
      BlockWrite(f1,aa^,size);
    end;
    dec(d,size);
  until d<=0;{I copied the clipboard now I have to copy the second block}

  CloseFile(f2);
  Seek(f3,StartDataWav+(Sfirsit*kind));
  d:=(LungimeWav-Sfirsit)*kind;

  repeat
    if d=0 then break;
    if size<=d then
    begin
      BlockRead(f3,aa^,size);
      BlockWrite(f1,aa^,size);
    end else
    begin
      size:=d;
      BlockRead(f3,aa^,size);
      BlockWrite(f1,aa^,size);
    end;
    dec(d,size);
  until d<=0;{finsihed everything is copied}

  CloseFile(f3);CloseFile(f1);dispose(aa);
  Result:=LungimeClip;{done on 8 or 16 bits}
end;

end.
