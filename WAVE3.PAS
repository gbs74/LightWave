unit Wave3;
{implement ghaphical methods}

interface

uses SysUtils, ExtCtrls, Graphics, Wave4;

procedure Put_Point(x,y:integer;Culoare:TColor;PaintBox:TPaintBox;caz:byte);

procedure DrawFast(Inceput,Sfirsit:Longint;sir:string;PaintBox:TPaintBox;
                      ZeroLine,Kind:Boolean;DCOffset:shortint;DoRefresh:boolean);

procedure Erase(PaintBox:TPaintBox;Color1:TColor);

implementation


procedure Put_Point(x,y:integer;culoare:TColor;PaintBox:TPaintBox;caz:byte);
begin
  case caz of
  1:{3 or 1 point}
    begin
      PaintBox.Canvas.Pixels[x,y]:=Culoare;
    end;
  2:{5 points}
    begin
      PaintBox.Canvas.Pixels[x-1,y]:=Culoare;
      PaintBox.Canvas.Pixels[x,y+1]:=Culoare;
      PaintBox.Canvas.Pixels[x,y]:=Culoare;
      PaintBox.Canvas.Pixels[x,y-1]:=Culoare;
      PaintBox.Canvas.Pixels[x+1,y]:=Culoare;
    end;
  3:{9 points}
    begin
      PaintBox.Canvas.Pixels[x-1,y-1]:=Culoare;
      PaintBox.Canvas.Pixels[x-1,y]:=Culoare;
      PaintBox.Canvas.Pixels[x-1,y+1]:=Culoare;
      PaintBox.Canvas.Pixels[x,y-1]:=Culoare;
      PaintBox.Canvas.Pixels[x,y]:=Culoare;
      PaintBox.Canvas.Pixels[x,y+1]:=Culoare;
      PaintBox.Canvas.Pixels[x+1,y-1]:=Culoare;
      PaintBox.Canvas.Pixels[x+1,y]:=Culoare;
      PaintBox.Canvas.Pixels[x+1,y+1]:=Culoare;
    end;
  4:{25 points}
    begin
      PaintBox.Canvas.Pixels[x-2,y-2]:=Culoare;
      PaintBox.Canvas.Pixels[x-2,y-1]:=Culoare;
      PaintBox.Canvas.Pixels[x-2,y]:=Culoare;
      PaintBox.Canvas.Pixels[x-2,y+1]:=Culoare;
      PaintBox.Canvas.Pixels[x-2,y+2]:=Culoare;

      PaintBox.Canvas.Pixels[x-1,y-2]:=Culoare;
      PaintBox.Canvas.Pixels[x-1,y-1]:=Culoare;
      PaintBox.Canvas.Pixels[x-1,y]:=Culoare;
      PaintBox.Canvas.Pixels[x-1,y+1]:=Culoare;
      PaintBox.Canvas.Pixels[x-1,y+2]:=Culoare;

      PaintBox.Canvas.Pixels[x,y-2]:=Culoare;
      PaintBox.Canvas.Pixels[x,y-1]:=Culoare;
      PaintBox.Canvas.Pixels[x,y]:=Culoare;
      PaintBox.Canvas.Pixels[x,y+1]:=Culoare;
      PaintBox.Canvas.Pixels[x,y+2]:=Culoare;

      PaintBox.Canvas.Pixels[x+1,y-2]:=Culoare;
      PaintBox.Canvas.Pixels[x+1,y-1]:=Culoare;
      PaintBox.Canvas.Pixels[x+1,y]:=Culoare;
      PaintBox.Canvas.Pixels[x+1,y+1]:=Culoare;
      PaintBox.Canvas.Pixels[x+1,y+2]:=Culoare;

      PaintBox.Canvas.Pixels[x+2,y-2]:=Culoare;
      PaintBox.Canvas.Pixels[x+2,y-1]:=Culoare;
      PaintBox.Canvas.Pixels[x+2,y]:=Culoare;
      PaintBox.Canvas.Pixels[x+2,y+1]:=Culoare;
      PaintBox.Canvas.Pixels[x+2,y+2]:=Culoare;
    end;
  end;
end;

procedure DrawFast(Inceput,Sfirsit:Longint;sir:string;PaintBox:TPaintBox;
                      ZeroLine,kind:Boolean;DCOffset:shortint;DoRefresh:boolean);
{Inceput,Sfirsit from and to which sample to paint
 sir:file name; Kind=true 8b / false 16b}
type
  buf=array[1..65534] of byte;
  XPaintVector=array[1..10000] of integer;  // 32 bit
var
  buffer:^buf;
  PaintVector:^XPaintVector;
  a,rest,rest_m,temp,scalare:single;{quantity used for vertical scalling}
  f:file;
  g:textfile;
  Start_Data,i,j,min,max,es,cc,Lim1,pozitia_curenta_in_buffer,index_linii,
  Offset,size,nr_citiri,nr_linii,nr1,nr2,centru:longint;
  citiri_multiple:boolean;
begin
  size:=32767;
  Start_data:=Search_data(sir)+4;
  New(Buffer);New(PaintVector);
  a:=Abs(inceput-sfirsit)/PaintBox.Width;{samples per pixel}
  if a+1>size then citiri_multiple:=false else citiri_multiple:=true;
  rest:=0;
  AssignFile(f,sir);
  Reset(f,1);
  cc:=DCOffset+128;
  centru:=PaintBox.Height div 2;
  {size of a sample where mode is max 128 must be center scalled}
  scalare:=centru/127;
  nr_linii:=PaintBox.Width;
  (************* very fast reading ****************)
  if kind then     // 8 bit
  begin
    Seek(f,Inceput+Start_data);
    if citiri_multiple then
    begin
      index_linii:=0;
      rest_m:=0;
      repeat
        rest:=0;
        size:=65530;
        nr_citiri:=trunc(size/a);
        if nr_citiri>nr_linii then nr_citiri:=nr_linii;(*how many "lines" to read*)
        size:=Trunc(nr_citiri*a+rest_m);(*cite esantioane voi citi*)
        rest_m:=nr_citiri*a-size;(*read sampling error <1 sample*)
        BlockRead(f,Buffer^,size);(*I read the samples*)
        pozitia_curenta_in_buffer:=0;
        for i:=index_linii+1 to index_linii+nr_citiri do
        begin
          (* compute size of Lim1 in samples for the current read*)
          min:=200000;max:=-200000;
          Lim1:=Trunc(a+rest);
          for j:=pozitia_curenta_in_buffer+1 to pozitia_curenta_in_buffer+Lim1 do
          begin
            (* insert data into PaintVector *)
            if Buffer^[j]>max then max:=Buffer^[j];
            if Buffer^[j]<min then min:=Buffer^[j];
          end;(* from samples per line*)
          inc(pozitia_curenta_in_buffer,Lim1);
          min:=Round((min-cc)*scalare);
          max:=Round((max-cc)*scalare);(*scalling*)
          PaintVector^[2*i-1]:=centru-min;
          PaintVector^[2*i]:=centru-max;(*centering*)
          temp:=a+rest;
          rest:=temp-Trunc(temp);
        end;(*pe linii*)
        inc(index_linii,nr_citiri);
        dec(nr_linii,nr_citiri);
      until nr_linii<=0;
    end else(* from if multiple reads *)
    begin
      for i:=1 to PaintBox.Width do
      begin
        min:=200000;max:=-200000;
        Lim1:=Trunc(a+rest);{how many samples have to read for current line}
        if Lim1>size then
        begin
          Offset:=Lim1-size;{by how many samples I have to shift current position in *.wav after blockread}
          Lim1:=size;
        end;
        BlockRead(f,Buffer^,Lim1);
        Seek(f,FilePos(f)+Offset);
        for j:=1 to Lim1 do
        begin
          if Buffer^[j]>max then max:=Buffer^[j];
          if Buffer^[j]<min then min:=Buffer^[j];
        end;
        min:=Round((min-cc)*scalare);
        max:=Round((max-cc)*scalare);
        if Lim1>0 then
        begin
          PaintVector^[2*i-1]:=centru-min;
          PaintVector^[2*i]:=centru-max;
        end else
        begin
          PaintVector^[2*i-1]:=-10000;
          PaintVector^[2*i]:=-10000;
        end;
        temp:=a+rest;
        rest:=temp-Trunc(temp);{only rest is modified}
      end;{from for PaintBox.Width}
    end;{from else for multipel reads}
  end else{16b}(* from kind *)
  begin
    Seek(f,(Inceput*2)+Start_data);
    for i:=1 to PaintBox.Width do
    begin
      min:=200000;max:=-200000;
      Lim1:=Trunc(a+rest);
      if Lim1>size then
      begin
        Offset:=Lim1-size;// read less and then seek to end of Lim1
        Lim1:=size;
      end else Offset:=0;
      BlockRead(f,Buffer^,2*Lim1);
      Seek(f,FilePos(f)+2*Offset);
      for j:=1 to Lim1 do
      begin
        es:=Buffer^[2*j];
        case es of
          0..127: es:=es+127;
          128   : es:=es;
        else
          es   := es-127;
        end;
        es:=es-cc; {in [-127..128] }
        {min>-127 max<128 for each decoded sample}
        if es>max then max:=es;
        if es<min then min:=es;
      end;
      min:=Trunc(min*scalare);
      max:=Trunc(max*scalare);
      if i=1 then
      begin
        if min>=200000 then min:=0;
        if max<=-200000 then max:=0;
        PaintBox.Canvas.LineTo(0,centru{-min});
      end;
      if Lim1<>0 then
      begin
        PaintVector^[2*i-1]:=centru-min;
        PaintVector^[2*i]:=centru-max;
      end else
      begin
        PaintVector^[2*i-1]:=-10000;
        PaintVector^[2*i]:=-10000;
      end;
      temp:=a+rest;
      rest:=temp-Trunc(temp);
    end;
  end;
  CloseFile(f);Dispose(Buffer);

  {refresh paintbox}
  if DoRefresh then PaintBox.Refresh else Erase(PaintBox,clBlack);
  //AssignFile(g,'file.txt');
  //Rewrite(g);
  PaintBox.Canvas.Pen.Color:=clLime{Navy};
  PaintBox.Canvas.MoveTo(0,centru);
  for i:=1 to PaintBox.Width do
  begin
    if (PaintVector^[2*i-1]>-10000)and(PaintVector^[2*i]>-10000) then
    begin
      PaintBox.Canvas.LineTo(i,PaintVector^[2*i-1]);
      //Writeln(g,PaintVector^[2*i-1]);
      PaintBox.Canvas.LineTo(i,PaintVector^[2*i]);
      //Writeln(g,PaintVector^[2*i]);
    end;
  end;
  //CloseFile(g);

  if abs(Sfirsit-Inceput)=0 then Exit;

  if (PaintBox.Width/abs(Inceput-Sfirsit)>=3)and(PaintBox.Width/abs(Inceput-Sfirsit)<=6) then
  begin
    for i:=1 to PaintBox.width do
    begin
      if (PaintVector^[2*i-1]>-10000)and(PaintVector^[2*i]>-10000) then
      begin
       Put_Point(i,PaintVector^[2*i-1],clYellow,PaintBox,2);
       Put_Point(i,PaintVector^[2*i],clYellow,PaintBox,2);
      end;
    end;
  end;

  if (PaintBox.Width/abs(Inceput-Sfirsit)>6)and(PaintBox.Width/abs(Inceput-Sfirsit)<=10) then
  begin
    for i:=1 to PaintBox.width do
    begin
      if (PaintVector^[2*i-1]>-10000)and(PaintVector^[2*i]>-10000) then
      begin
       Put_Point(i,PaintVector^[2*i-1],clYellow,PaintBox,3);
       Put_Point(i,PaintVector^[2*i],clYellow,PaintBox,3);
      end;
    end;
  end;

  if (PaintBox.Width/abs(Inceput-Sfirsit)>10) then
  begin
    for i:=1 to PaintBox.width do
    begin
      if (PaintVector^[2*i-1]>-10000)and(PaintVector^[2*i]>-10000) then
      begin
       Put_Point(i,PaintVector^[2*i-1],clYellow,PaintBox,4);
       Put_Point(i,PaintVector^[2*i],clYellow,PaintBox,4);
      end;
    end;
  end;

  PaintBox.Canvas.LineTo(PaintBox.Width,centru);

  if ZeroLine then
  begin
    PaintBox.Canvas.Pen.Color:=clGreen;
    PaintBox.Canvas.MoveTo(0,centru);
    PaintBox.Canvas.LineTo(PaintBox.Width,centru);
  end;
  Dispose(PaintVector);

end;

procedure Erase(PaintBox:TPaintBox;Color1:TColor);
begin
  PaintBox.Canvas.Pen.Color:=Color1;
  PaintBox.Canvas.Pen.Width:=PaintBox.Height+10;
  PaintBox.Canvas.MoveTo(0,PaintBox.Height div 2);
  PaintBox.Canvas.LineTo(PaintBox.Width,PaintBox.Height div 2+2);
  PaintBox.Canvas.Pen.Width:=1;
end;

end.
