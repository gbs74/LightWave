unit Wave5;
{unit for Header updates and other miscelaneous things}

interface

uses ExtCtrls, SysUtils, StdCtrls;

procedure UpdateHeaderOnOpen(Header:THeader;name:string;kind:boolean;
          fes,inceput,sfirsit:longint);

procedure UpdateHeaderOnMouseDown(Header:THeader;Inceput:string);

procedure UpDateHeaderOnMouseMove(Header:THeader;Inceput,Sfirsit:string;fes:longint);

procedure UpdateHeaderOnMouseUp(Header:THeader;Inceput,Sfirsit,StartZoomIn:string;
EndZoomIn,fes:longint);

procedure SwitchMax(inceput,sfirsit:TLabel);

implementation

procedure SwitchMax(inceput,sfirsit:TLabel);
var
  swich:string;
begin
  if StrToInt(Inceput.Caption)>StrToInt(Sfirsit.Caption) then
  begin
    swich:=Inceput.Caption;
    Inceput.Caption:=Sfirsit.Caption;
    Sfirsit.Caption:=Swich;
  end;
end;

procedure UpdateHeaderOnOpen(Header:THeader;name:string;kind:boolean;
          fes,inceput,sfirsit:longint);
var
  selection:longint;
begin
  Header.Sections[0]:=ExtractFileName(name);
  if kind then Header.Sections[1]:='8 Bit ' else Header.Sections[1]:='16 Bit ';
  Header.Sections[2]:=IntToStr(abs(Sfirsit-Inceput))+' Samples';
  Header.Sections[3]:='Mono ';
  Header.Sections[4]:=IntToStr(fes)+' Hz';
  Header.Sections[5]:='Begin: '+IntToStr(inceput);
  Header.Sections[6]:='End: '+IntToStr(Sfirsit);
  selection:=Trunc(1000/fes*abs(sfirsit-inceput));
  Header.Sections[7]:=FloatToStrF(selection,ffFixed,18,2)+' ms';
end;

procedure UpdateHeaderOnMouseDown(Header:THeader;Inceput:string);
begin
  Header.Sections[5]:='Begin: '+Inceput;
end;

procedure UpDateHeaderOnMouseMove(Header:THeader;Inceput,Sfirsit:string;fes:longint);
var
  XInceput,XSfirsit:longint;
  durata:single;
begin
  Header.Sections[6]:='End: '+Sfirsit;
  XInceput:=StrToInt(Inceput);
  XSfirsit:=StrToInt(Sfirsit);
  durata:=abs(XSfirsit-XInceput)/fes*1000;
  Header.Sections[2]:=IntToStr(abs(Xsfirsit-Xinceput))+' Samples';
  Header.Sections[7]:=FloatToStrF(durata,ffFixed,18,2)+' ms';
end;

procedure UpdateHeaderOnMouseUp(Header:THeader;Inceput,Sfirsit,StartZoomIn:string;
EndZoomIn,fes:longint);
var
  XInceput,XSfirsit,temp:longint;
  durata:single;
begin
  XInceput:=StrToInt(Inceput);
  XSfirsit:=StrToInt(Sfirsit);
  if XInceput>XSfirsit then
  begin
    Temp:=XInceput;
    XInceput:=XSfirsit;
    XSfirsit:=Temp;
  end;
  Header.Sections[2]:=IntToStr(abs(Xsfirsit-Xinceput))+' Samples';
  Header.Sections[5]:='Begin: '+IntToStr(XInceput);
  Header.Sections[6]:='End: '+IntToStr(XSfirsit);
  durata:=abs(XSfirsit-XInceput)/fes*1000;
  Header.Sections[7]:=FloatToStrF(durata,ffFixed,18,2)+' ms';
end;

end.
