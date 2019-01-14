unit Wave9;

interface

uses SysUtils, Setting;

function Blackman(n,M:word):single;
function Hamming(n,M:word):single;
function Hanning(n,M:word):single;
function Cosinus(n,M:word):single;

function CeFereastra:word;


implementation

function Blackman(n,M:word):single;
{n current window point, M window width in samples}
begin
 Blackman:=0.42-0.5*cos(2*pi*n/M)+0.08*cos(4*pi*n/M);
end;

function Hamming(n,M:word):single;
const alfa=0.54;
begin
 Hamming:=alfa-(1-alfa)*cos(2*pi*n/M);
end;

function Hanning(n,M:word):single;
begin
 Hanning:=0.5-0.5*cos(2*pi*n/M);
end;

function Cosinus(n,M:word):single;
begin
 Cosinus:=sin(pi*n/M);
end;

function CeFereastra:word;
type
  ferestre=array[0..4] of string;
var
  fereastra:ferestre;
  i:shortint;
  find:boolean;
begin
  fereastra[0]:='None';
  fereastra[1]:='Blackman';
  fereastra[2]:='Hamming';
  fereastra[3]:='Hanning';
  fereastra[4]:='Cosinus';
  find:=true;
  for i:=0 to 4 do
  begin
    if Settings.ComboBox2.Text=fereastra[i] then
    begin
      Result:=i;
      find:=true;
      break;
    end;
  end;
  if not find then
  begin
    Result:=2;
    Settings.ComboBox2.Text:=fereastra[2];
  end;
 end;


end.
