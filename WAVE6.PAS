unit Wave6;
{unit for subrutines to save wav format files}
interface

uses SySUtils, Wave4;

procedure SaveAs(Inceput,Sfirsit,NewName,OldName:string);

implementation

procedure SaveAs(Inceput,Sfirsit,NewName,OldName:string);
type
  vector=array[1..65534] of byte;
  bufer=array[1..4] of char;
var
  buf:bufer;
  sir1:string[8];
  l,r,d,i,size:longint;
  f,g:file;
  aa:^vector;
  Start_data:word;
begin
  size:=65534;
  Start_data:=Search_data(OldName)+4;
  if BitsPerSample(OldName)=8 then
  begin
    l:=StrToInt(Inceput);
    r:=StrToInt(Sfirsit);
    d:=r-l+36;
    sir1:=IntToHex(d,8);
    AssignFile(f,OldName);
    Reset(f,1);
    AssignFile(g,NewName);
    Rewrite(g,1);
    BlockRead(f,buf,4);
    BlockWrite(g,buf,4);{am scris RIFF}

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
    d:=r-l;
    sir1:=IntToHex(d,8);
    buf[1]:=Chr(StrToInt('$'+sir1[7]+sir1[8]));
    buf[2]:=Chr(StrToInt('$'+sir1[5]+sir1[6]));
    buf[3]:=Chr(StrToInt('$'+sir1[3]+sir1[4]));
    buf[4]:=Chr(StrToInt('$'+sir1[1]+sir1[2]));
    BlockWrite(g,buf,4);{am scris cite car urmeaza}
    Seek(f,l+Start_data);
    new(aa);
    repeat
      if size<=d then
      begin
        BlockRead(f,aa^,size);
        {for i:=1 to size do aa^[i]:=aa^[i]-12;}
        BlockWrite(g,aa^,size);
      end else
      begin
        size:=d;
        BlockRead(f,aa^,size);
        {for i:=1 to size do aa^[i]:=aa^[i]-12;}
        BlockWrite(g,aa^,size);
      end;
      dec(d,size);
    until d<=0;
    dispose(aa);
    CloseFile(f);
    CloseFile(g);
  end;{end de la if 1}
  if BitsPerSample(OldName)=16 then
  begin
    l:=StrToInt(Inceput);
    r:=StrToInt(Sfirsit);
    d:=2*(r-l)+36;
    sir1:=IntToHex(d,8);
    AssignFile(f,OldName);
    Reset(f,1);
    AssignFile(g,NewName);
    Rewrite(g,1);
    BlockRead(f,buf,4);
    BlockWrite(g,buf,4);
    buf[1]:=Chr(StrToInt('$'+sir1[7]+sir1[8]));
    buf[2]:=Chr(StrToInt('$'+sir1[5]+sir1[6]));
    buf[3]:=Chr(StrToInt('$'+sir1[3]+sir1[4]));
    buf[4]:=Chr(StrToInt('$'+sir1[1]+sir1[2]));
    BlockWrite(g,buf,4);
    Seek(f,8);
    for i:=1 to 7 do
    begin
      BlockRead(f,buf,4);
      if i=3 then Buf[1]:=chr(16);
      BlockWrite(g,buf,4);
    end;
    Buf[1]:='d';buf[2]:='a';buf[3]:='t';buf[4]:='a';
    BlockWrite(g,buf,4);
    d:=2*(r-l);
    sir1:=IntToHex(d,8);
    buf[1]:=Chr(StrToInt('$'+sir1[7]+sir1[8]));
    buf[2]:=Chr(StrToInt('$'+sir1[5]+sir1[6]));
    buf[3]:=Chr(StrToInt('$'+sir1[3]+sir1[4]));
    buf[4]:=Chr(StrToInt('$'+sir1[1]+sir1[2]));
    BlockWrite(g,buf,4);
    Seek(f,2*l+Start_data);
    New(aa);
    repeat
      if size<d then
      begin
        BlockRead(f,aa^,size);
        BlockWrite(g,aa^,size);
      end else
      begin
        size:=d;
        BlockRead(f,aa^,size);
        BlockWrite(g,aa^,size);
      end;
      dec(d,size);
    until d<=0;
    Dispose(aa);
    CloseFile(f);
    CloseFile(g);
  end;
end;

end.
