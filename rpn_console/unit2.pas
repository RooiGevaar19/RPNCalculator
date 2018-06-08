unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, Process, Unit6, Unit7;

const
	PI = 3.1415926535897932384626433832795;
	EU = 2.7182818284590452353602874713526;
	FI = 1.6180339887498948482045868343656;

//function pow(x,y:Extended):Extended;
//function pow2(x,y:Extended):Extended;
//function fact(x:Extended):Extended;
//function newton_int(n, k: Extended) : Extended;
//function newton_real(n, k: Extended) : Extended;
//function fib(n: Extended) : Extended;

//procedure qs_engine(var AI: array of Extended; ALo, AHi: Integer);
//procedure ms_merge(var a : array of Extended; l,r,x,y:Integer);
//procedure ms_engine(var a : array of Extended; l,r:Integer);
//function bs_isSorted(var data : array of Extended) : Boolean;
//procedure bs_shuffle(var data : array of Extended);
//procedure bubblesort(var tab : array of Extended);
procedure quicksort(var tab : array of Extended);
procedure mergesort(var tab : array of Extended);
procedure bogosort(var tab : array of Extended);

function commentcut(input : String) : String;
procedure evaluate(i : String; var pocz : StackDB; var Steps : Integer; var sets : TSettings; var vardb : VariableDB);
function read_sourcefile(filename : String; var pocz : StackDB; var sets : TSettings; var vardb : VariableDB) : String;
function parseRPN(input : string; var pocz : StackDB; var sets : TSettings; var vardb : VariableDB) : String;
function calc_parseRPN(input : string; var sets : TSettings) : String;

implementation
uses Unit5;

var
        Steps : Integer;

// MATHEMATICAL FUNCTIONS

function pow(x,y:Extended):Extended;
var
        s : Extended;
        i : integer;
begin
        s := 1;
        for i := 1 to trunc(abs(y)) do s := s * x;
        if (y < 0) then s := 1 / s;
        pow := s;
end;

function pow2(x,y:Extended):Extended;
var
        s : Extended;
begin
        s := exp(y*ln(x));
        pow2 := s;
end;

function fact(x:Extended):Extended;
var
        s : Extended;
        i : integer;
begin
     s := 1;
     for i := 1 to trunc(abs(x)) do s := s * i;
     fact := s;
end;

function newton_int(n, k : Extended) : Extended;
begin
     //newton (n, 0) = 1;
     //newton (n, n) = 1;
     //newton (n, k) = newton (n-1, k-1) + newton (n-1, k);
     if (k = 0.0) or (k = n) then newton_int := 1.0
     else newton_int := newton_int(n-1, k-1) + newton_int(n-1, k);
end;

function newton_real(n, k : Extended) : Extended;
var s, j : Extended;
begin
  s := 1;
  if (n < 0) then
    newton_real := pow(-1.0, k) * newton_real(k-n-1, k)
  else begin
    j := 1.0;
    while (j <= k) do
    begin
      s := s * (n-k+j)/j;
      j := j + 1;
    end;
    newton_real := s;
  end;
end;

function gcd(a, b : Extended) : Extended;
begin
	while (a <> b) do
	begin
        if (a > b) then a := a - b
        else b := b - a;
    end;
	gcd := a;
end;

function lcm(a, b : Extended) : Extended;
begin
	lcm := (a*b)/gcd(a, b);
end;

function fib(n: Extended) : Extended;
begin
     if n = 0.0 then fib := 0.0
     else if n = 1.0 then fib := 1.0
     else fib := fib(n-1.0) + fib(n-2.0);
end;

// TABLES AGGREGATE

procedure table_reverse(var tab : array of Extended);
var 
	pom : array of Extended;
	i   : Integer;
begin
	SetLength(pom, Length(tab));
	for i := 0 to Length(tab)-1 do pom[i] := tab[Length(tab)-1-i];
	for i := 0 to Length(tab)-1 do tab[i] := pom[i];
	SetLength(pom, 0);
end;

function table_sum(tab : array of Extended) : Extended;
var
	i : Integer;
	s : Extended;
begin
	s := 0.0;
  for i := 0 to Length(tab)-1 do
  	s := s + tab[i];
  table_sum := s;
end;

function table_product(tab : array of Extended) : Extended;
var
	i : Integer;
	s : Extended;
begin
	s := 1.0;
  for i := 0 to Length(tab)-1 do
  	s := s * tab[i];
  table_product := s;
end;

function table_avg(tab : array of Extended) : Extended;
var
	i : Integer;
	s : Extended;
begin
	s := 0.0;
  for i := 0 to Length(tab)-1 do
  	s := s + tab[i];
  table_avg := s/Length(tab);
end;

function table_min(tab : array of Extended) : Extended;
var
	i : Integer;
	s : Extended;
begin
	s := tab[0];
  for i := 1 to Length(tab)-1 do
  	if (tab[i] < s) then s := tab[i];
  table_min := s;
end;

function table_max(tab : array of Extended) : Extended;
var
	i : Integer;
	s : Extended;
begin
	s := tab[0];
  for i := 1 to Length(tab)-1 do
  	if (tab[i] > s) then begin
  		s := tab[i];
  		//writeln(s);
  	end; 
  table_max := s;
end;

function table_median(tab : array of Extended) : Extended;
begin
	quicksort(tab);
	if (Length(tab) mod 2 = 0) then table_median := 0.5*(tab[Length(tab) div 2 - 1] + tab[Length(tab) div 2])
	else table_median := tab[Length(tab) div 2];
end;

function table_abs(tab : array of Extended) : Extended;
var
	i : Integer;
	s : Extended;
begin
	s := 0.0;
  for i := 0 to Length(tab)-1 do
  	s := s + tab[i]*tab[i];
  table_abs := sqrt(s);
end;

function table_variance(tab : array of Extended) : Extended;
var
	i    : Integer;
	s    : Extended;
	mean : Extended;
begin
  mean := table_avg(tab);
  s := 0.0;
  for i := 0 to Length(tab)-1 do
    s := s + sqr(tab[i]-mean);
  table_variance := s/Length(tab);
end;

function table_stddev(tab : array of Extended) : Extended;
begin
	table_stddev := sqrt(table_variance(tab));
end;

// SORTS

procedure bubblesort(var tab : array of Extended);
var
  i, j : Longint;
  pom  : Extended;
begin
  for j := Length(tab)-1 downto 1 do
    for i := 0 to j-1 do 
      if (tab[i] > tab[i+1]) then begin
        pom := tab[i];
        tab[i] := tab[i+1];
        tab[i+1] := pom;
      end;
end;

procedure qs_engine(var AI: array of Extended; ALo, AHi: Integer);
var
  Lo, Hi   : Integer;
  Pivot, T : Extended;
begin
  Lo := ALo;
  Hi := AHi;
  Pivot := AI[(Lo + Hi) div 2];
  repeat
    while AI[Lo] < Pivot do
      Inc(Lo) ;
    while AI[Hi] > Pivot do
      Dec(Hi) ;
    if Lo <= Hi then
    begin
      T := AI[Lo];
      AI[Lo] := AI[Hi];
      AI[Hi] := T;
      Inc(Lo);
      Dec(Hi);
    end;
  until Lo > Hi;
  if Hi > ALo then
    qs_engine(AI, ALo, Hi);
  if Lo < AHi then
    qs_engine(AI, Lo, AHi);
end;

procedure quicksort(var tab : array of Extended);
begin
  qs_engine(tab, 0, Length(tab)-1);
end;

procedure ms_merge(var a : array of Extended; l,r,x,y:Integer);
var 
  i,j,k,s : Integer;
  c       : array of Extended;
begin
  i:=l;
  j:=y;
  k:=0;
  SetLength(c,r-l+1+y-x+1);
  while (l<=r) and (x<=y) do
  begin
    if a[l]<a[x] then
    begin
      c[k]:=a[l];
      inc(l);
    end else begin
      c[k]:=a[x];
      inc(x);
    end;
    inc(k);
  end;

  if l<=r then
    for s:=l to r do
    begin
      c[k]:=a[s];
      inc(k);
    end 
  else
    for s:=x to y do
    begin
      c[k]:=a[s];
      inc(k);
    end;

  k:=0;
  for s:=i to j do
  begin
    a[s]:=c[k];
    inc(k);
  end;
end;

procedure ms_engine(var a : array of Extended; l,r:Integer);
var 
  m : Integer;
begin
  if l=r then Exit;
  m:=(l+r) div 2;
  ms_engine(a, l, m);
  ms_engine(a, m+1, r);
  ms_merge(a, l, m, m+1, r);
end;

procedure mergesort(var tab : array of Extended);
begin
  ms_engine(tab, 0, Length(tab)-1);
end;

function bs_isSorted(var data : array of Extended) : Boolean;
var
  Count : Longint;
  res   : Boolean;
begin
  res := true;
  for count := Length(data)-1 downto 1 do
    if (data[count] < data[count - 1]) then res := false;
  bs_isSorted := res;
end;

procedure bs_shuffle(var data : array of Extended);
var
  Count, rnd, i : Longint;
  pom           : Extended;
begin
  Count := Length(data);
  for i := 0 to Count-1 do
  begin   
    rnd := random(count);
    pom := data[i];
    data[i] := data[rnd];
    data[rnd] := pom;
  end;
end;

procedure bogosort(var tab : array of Extended);
begin
  randomize();
  while not (bs_isSorted(tab)) do bs_shuffle(tab);
end;

// COMMANDS' EXECUTION

function executeCommand(input, Shell : String) : String;
var
	s : String;
begin
	s := '';
	{$IFDEF MSWINDOWS}
	RunCommand(Shell,['/c', input],s);
 	{$ELSE}
  	RunCommand(Shell,['-c', input],s);
 	{$ENDIF}
 	executeCommand := s;
end;


// EVALUATION

procedure evaluate(i : String; var pocz : StackDB; var Steps : Integer; var sets : TSettings; var vardb : VariableDB);
var
    x, y, z, a, Im : Extended;
    Code, index    : Longint;
    Size           : Longint;
    Sizer          : StackDB;
    HelpETable     : array of Entity;
    HelpNTable     : array of Extended;
    HelpSTable     : array of String;
    HelpTStrings   : TStrings;
    StrEax, StrEbx : String;
    StrEcx, StrEdx : String;
    EntEax, EntEbx : Entity;
    ExtEax, ExtEbx : Extended; 
    IntEax, IntEbx : integer; 
    LogEax         : Boolean;
begin
    Steps := 1;
    SetLength(HelpETable, 0);
    SetLength(HelpNTable, 0);
    SetLength(HelpSTable, 0);

    StrEcx := i;
    if not (sets.CaseSensitive) then i := LowerCase(i);
    Val (i,Im,Code);
    If Code<>0 then
      begin
        case i of
          // binary
          '+' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            x := stack_pop(pocz).Num;
            z := x+y;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          '-' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            x := stack_pop(pocz).Num;
            z := x-y;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          '*' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            x := stack_pop(pocz).Num;
            z := x*y;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          '/' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            x := stack_pop(pocz).Num;
            z := x/y;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          '^' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            x := stack_pop(pocz).Num;
            if (y = trunc(y)) then begin
               z := pow(x,y);
            end else begin
                z := pow2(x,y);
            end;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          'pow' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            x := stack_pop(pocz).Num;
            if (y = trunc(y)) then begin
               z := pow(x,y);
            end else begin
                z := pow2(x,y);
            end;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          'log' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            x := stack_pop(pocz).Num;
            z := ln(x)/ln(y);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          'root' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            x := stack_pop(pocz).Num;
            z := pow2(x,1/y);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          'mod' : begin
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            x := stack_pop(pocz).Num;
            z := trunc(x) mod trunc(y);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          'div' : begin
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            x := stack_pop(pocz).Num;
            z := trunc(x) div trunc(y);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          'cdiv' : begin
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            x := stack_pop(pocz).Num;
            if trunc(x/y) < 0 then begin
               z := trunc(x/y)-1;
            end else begin
               z := trunc(x/y);
            end;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          'cmod' : begin
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            x := stack_pop(pocz).Num;
            if (x > 0) and (y < 0) then begin
               z := ((trunc(x) mod trunc(y))+3)*(-1);
            end else if (x < 0) and (y > 0) then begin
               z := (trunc(x) mod trunc(y))+3;
            end else begin
               z := trunc(x) mod trunc(y);
            end;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          'choose' : begin
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            x := stack_pop(pocz).Num;
            if (x = trunc(x)) then begin
                z := newton_int(x,y);
            end else begin
                z := newton_real(x,y);
            end;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          'gcd' : begin
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            x := stack_pop(pocz).Num;
            z := gcd(x, y);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;
          'lcm' : begin
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            x := stack_pop(pocz).Num;
            z := lcm(x, y);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
            end;
            stack_push(pocz, buildNumber(z));
          end;


          // constants
          'PI' : begin
            stack_push(pocz, buildNumber(PI));
          end;
          'EU' : begin
            stack_push(pocz, buildNumber(EU));
          end;
          'FI' : begin
            stack_push(pocz, buildNumber(FI));
          end;

          // unary
          'exp' : begin
          	if (sets.StrictType) then assertIntegerLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            z := exp(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'abs' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := abs(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'sqrt' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := sqrt(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'sin' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := sin(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'cos' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := cos(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'csc' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := 1/sin(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'sec' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := 1/cos(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'tan' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := sin(y)/cos(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'cot' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := cos(y)/sin(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          '!' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            z := fact(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'fact' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            z := fact(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'ln' : begin
          	if (sets.StrictType) then assertNotNegativeLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            z := ln(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'trunc' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := trunc(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'floor' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
			if (y = trunc(y)) then z := trunc(y)
			else if (y < 0) then z := trunc(y)-1 else z := trunc(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'ceiling' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            if (y = trunc(y)) then z := trunc(y)
			else if (y < 0) then z := trunc(y) else z := trunc(y)+1;
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'round' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := round(y);
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'fib' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i);
            y := stack_pop(pocz).Num;
            z := fib(trunc(y));
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'inc' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := y + 1;
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          'dec' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := y - 1;
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
          '++' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := y + 1;
            stack_push(pocz, buildNumber(z));
          end;
          '--' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i); 
            y := stack_pop(pocz).Num;
            z := y - 1;
            stack_push(pocz, buildNumber(z));
          end;

          // String operations
          'concat' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEbx := stack_pop(pocz).Str;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEax := stack_pop(pocz).Str;
            StrEcx := concat(StrEax, StrEbx);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEax));
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEcx));
          end;
          'crush' : begin
          	SetLength(HelpSTable, 0);
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEbx := stack_pop(pocz).Str;
            IntEbx := 1;
            while (IntEbx <= Length(StrEbx)) do begin
            	SetLength(HelpSTable, IntEbx+1);
            	HelpSTable[IntEbx] := Copy(StrEbx, IntEbx, 1);
            	IntEbx := IntEbx + 1; 
            end;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(y));
              stack_push(pocz, buildString(StrEbx));
            end;
            for index := 1 to Length(HelpSTable)-1 do stack_push(pocz, buildString(HelpSTable[index])); 
            SetLength(HelpSTable, 0);
          end;
          'crushby' : begin
          	SetLength(HelpSTable, 0);
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i);  
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            IntEax := 1;
            IntEbx := 1;
            while (IntEax <= Length(StrEbx)) do begin
            	SetLength(HelpSTable, IntEbx+1);
            	HelpSTable[IntEbx] := Copy(StrEbx, IntEax, trunc(y));
            	IntEax := IntEax + trunc(y);
            	IntEbx := IntEbx + 1; 
            end;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(y));
              stack_push(pocz, buildString(StrEbx));
            end;
            for index := 1 to Length(HelpSTable)-1 do stack_push(pocz, buildString(HelpSTable[index])); 
            SetLength(HelpSTable, 0);
          end;
          'leftstr' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i);  
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEbx := stack_pop(pocz).Str;
            StrEax := LeftStr(StrEbx, trunc(y));
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(y));
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEax));
          end;
          'rightstr' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            StrEax := RightStr(StrEbx, trunc(y));
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(y));
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEax));
          end;
          'trim' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            StrEcx := Trim(StrEbx);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEcx));
          end;
          'ltrim' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            StrEcx := TrimLeft(StrEbx);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEcx));
          end;
          'rtrim' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEbx := stack_pop(pocz).Str;
            StrEcx := TrimRight(StrEbx);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEcx));
          end;
          'despace' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            StrEcx := DelChars(StrEbx, ' ');
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEcx));
          end;
          'onespace' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEbx := stack_pop(pocz).Str;
            StrEcx := DelSpace1(StrEbx);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEcx));
          end;
          'dechar' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEcx := stack_pop(pocz).Str;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            StrEcx := DelChars(StrEbx, StrEcx[1]);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEcx));
          end;
          'bind' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEbx := stack_pop(pocz).Str;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEax := stack_pop(pocz).Str;
            
            StrEcx := StrEax + ' ' + StrEbx;

            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEax));
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEcx));
          end;
          'bindby' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEcx := stack_pop(pocz).Str;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEax := stack_pop(pocz).Str;
            
            StrEdx := StrEax + StrEcx + StrEbx;

            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEax));
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEdx));
          end;
          'split' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEbx := stack_get(pocz).Str;
            if (sets.Autoclear) then stack_pop(pocz); 
            
            HelpTStrings := TStringlist.Create;
            HelpTStrings.Delimiter := ' ';
            HelpTStrings.QuoteChar := '"';
            HelpTStrings.StrictDelimiter := false;
            HelpTStrings.DelimitedText := StrEbx;

            for StrEax in HelpTStrings do stack_push(pocz, buildString(StrEax)); 
            HelpTStrings.Free;
          end;
          'splitby' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEcx := stack_pop(pocz).Str;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEbx := stack_get(pocz).Str;
            if (sets.Autoclear) then stack_pop(pocz); 
            
            HelpTStrings := TStringlist.Create;
            HelpTStrings.Delimiter := StrEcx[1];
            HelpTStrings.QuoteChar := '"';
            HelpTStrings.StrictDelimiter := false;
            HelpTStrings.DelimitedText := StrEbx;

            for StrEax in HelpTStrings do stack_push(pocz, buildString(StrEax)); 
            HelpTStrings.Free;
          end;
          'substr' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i);  
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
            x := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            StrEax := Copy(StrEbx, trunc(x), trunc(y));
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEax)); 
          end;
          'strbetween' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
            x := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEbx := stack_pop(pocz).Str;
            StrEax := Copy(StrEbx, trunc(x), trunc(y)-trunc(x)+1);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildNumber(x));
              stack_push(pocz, buildNumber(y));
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEax)); 
          end;
          'pos' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEax := stack_pop(pocz).Str;
            ExtEax := Pos(StrEbx, StrEax);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEax));
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildNumber(ExtEax)); 
          end;
          'strremove' : begin 
          	if (stack_get(pocz).EntityType = TSTR) then
          	begin
          	  if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
              StrEbx := stack_pop(pocz).Str;
              if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
              StrEax := stack_pop(pocz).Str;
              Delete(StrEax, Pos(StrEbx, StrEax), Length(StrEbx));
              if not (sets.Autoclear) then begin
                stack_push(pocz, buildString(StrEax));
                stack_push(pocz, buildString(StrEbx));
              end;
              stack_push(pocz, buildString(StrEax)); 
          	end else begin
          	  if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
              y := stack_pop(pocz).Num;
          	  if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
              x := stack_pop(pocz).Num;
              if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
              StrEax := stack_pop(pocz).Str;
              Delete(StrEax, trunc(x), trunc(y)); 
              if not (sets.Autoclear) then begin
                stack_push(pocz, buildString(StrEax));
                stack_push(pocz, buildNumber(x));
                stack_push(pocz, buildNumber(y));
              end;
              stack_push(pocz, buildString(StrEax));
          	end;
          end;
          'strinsert' : begin
            if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
            y := stack_pop(pocz).Num;
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEax := stack_pop(pocz).Str;
            Insert(StrEbx, StrEax, trunc(y));
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEax));
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEax)); 
          end;
          'npos' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i);  
            y := stack_pop(pocz).Num;
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEax := stack_pop(pocz).Str;
            ExtEax := NPos(StrEbx, StrEax, trunc(y));
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEax));
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildNumber(ExtEax)); 
          end;
          'occur' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEax := stack_pop(pocz).Str;
            IntEax := 0;
            repeat
              IntEbx := NPos(StrEbx, StrEax, IntEax+1);
              if (IntEbx <> 0) then Inc(IntEax);
            until (IntEbx = 0);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEax));
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildNumber(IntEax)); 
          end;
          'strparse' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEbx := stack_pop(pocz).Str;
            StrEcx := parseRPN(StrEbx, pocz, sets, vardb);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEbx));
            end;
            //stack_push(pocz, buildString(StrEcx));
          end;

          'shell' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEbx := stack_pop(pocz).Str;
            StrEcx := executeCommand(StrEbx, sets.Shell);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEbx));
            end;
            stack_push(pocz, buildString(StrEcx));
          end;

          'vset' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEax := stack_pop(pocz).Str;
            EntEax := stack_pop(pocz);
            setVariable(vardb, StrEax, EntEax);
            if not (sets.Autoclear) then begin
              stack_push(pocz, EntEax);
              stack_push(pocz, buildString(StrEax));
            end;
          end;

          'vget' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEax := stack_pop(pocz).Str;
            EntEax := getVariable(vardb, StrEax);
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEax));
            end;
            stack_push(pocz, EntEax);
          end;

          'vexists' : begin
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i);  
            StrEax := stack_pop(pocz).Str;
            LogEax := isVarAssigned(vardb, StrEax);
            if (LogEax) then IntEax := 0 else IntEax := 1;
            if not (sets.Autoclear) then begin
              stack_push(pocz, buildString(StrEax));
            end;
            stack_push(pocz, buildNumber(IntEax));
          end;


          // Directives
          '@silent' : begin
             sets.Prevent := true;
          end;
          '@autoclear(true)' : begin
             sets.Autoclear := true;
          end;
          '@autoclear(false)' : begin
             sets.Autoclear := false;
          end;
          '@stricttype(true)' : begin
             sets.StrictType := true;
          end;
          '@stricttype(false)' : begin
             sets.StrictType := false;
          end;
          '@casesensitive(true)' : begin
             sets.CaseSensitive := true;
          end;
          '@casesensitive(false)' : begin
             sets.CaseSensitive := false;
          end;
          '@real' : begin
             sets.Mask := '0.################';
          end;
          '@decimal' : begin
             sets.Mask := '#,###.################';
          end;
          '@milli' : begin
             sets.Mask := '0.000';
          end;
          '@float' : begin
             sets.Mask := '0.000000';
          end;
          '@double' : begin
             sets.Mask := '0.000000000000000';
          end;
          '@money' : begin
             sets.Mask := '0.00';
          end;
          '@amoney' : begin
             sets.Mask := '#,###.00';
          end;
          '@int' : begin
             sets.Mask := '0';
          end;
          '@scientific' : begin
             sets.Mask := '0.################E+00';
          end;
          '@scientific1' : begin
             sets.Mask := '0.000000000000000E+0000';
          end;
          '@sorttype(BUBBLESORT)' : begin
             sets.sorttype := 0;
          end;
          '@sorttype(QUICKSORT)' : begin
             sets.sorttype := 1;
          end;
          '@sorttype(MERGESORT)' : begin
             sets.sorttype := 2;
          end;
          '@sorttype(BOGOSORT)' : begin
             sets.sorttype := 3;
          end;
          '@sorttype(RANDOMSORT)' : begin
             sets.sorttype := 3;
          end;
          '@sorttype(BSORT)' : begin
             sets.sorttype := 0;
          end;
          '@sorttype(QSORT)' : begin
             sets.sorttype := 1;
          end;
          '@sorttype(MSORT)' : begin
             sets.sorttype := 2;
          end;
          '@sorttype(RSORT)' : begin
             sets.sorttype := 3;
          end;
          '@sorttype(0)' : begin
             sets.sorttype := 0;
          end;
          '@sorttype(1)' : begin
             sets.sorttype := 1;
          end;
          '@sorttype(2)' : begin
             sets.sorttype := 2;
          end;
          '@sorttype(3)' : begin
             sets.sorttype := 3;
          end;
          '@useshell(BASH)' : begin
             sets.Shell := SHELL_BASH;
          end;
          '@useshell(ZSH)' : begin
             sets.Shell := SHELL_ZSH;
          end;
          '@useshell(SH)' : begin
             sets.Shell := SHELL_SH;
          end;
          '@useshell(CMD)' : begin
             sets.Shell := SHELL_CMD;
          end;
          '@useshell(POWERSHELL)' : begin
             sets.Shell := SHELL_PWSH;
          end;
          '@useshell(PWSH)' : begin
             sets.Shell := SHELL_PWSH;
          end;
          


          // single operands
          'scan' : begin
            EntEax := scan_value();
            stack_push(pocz, EntEax);
          end;
          'scannum' : begin
            EntEax := scan_number();
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
            stack_push(pocz, EntEax);
          end;
          'scanstr' : begin
            EntEax := scan_string();
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            stack_push(pocz, EntEax);
          end;
          'times' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
            y := stack_get(pocz).Num;
            stack_pop(pocz);
            if (y >= 0) then Steps := trunc(y);
          end;
          'tilleof' : begin
          	Steps := -1;
          end;
          'clone' : begin
            EntEax := stack_get(pocz);
            stack_push(pocz, EntEax);
          end;
          'type' : begin
          	EntEax := stack_get(pocz);
          	if (sets.Autoclear) then stack_pop(pocz);
          	stack_push(pocz, buildString(getEntityTypeName(EntEax.EntityType)));
          end;
          'tostring' : begin
          	EntEax := stack_get(pocz);
            if (sets.Autoclear) then stack_pop(pocz);
            stack_push(pocz, buildString(EntEax.Str));
          end;
          'length' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEax := stack_get(pocz).Str;
            if (sets.Autoclear) then stack_pop(pocz);
            stack_push(pocz, buildNumber(Length(StrEax)));
          end;
          'len' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEax := stack_get(pocz).Str;
            //if (sets.Autoclear) then stack_pop(pocz);
            stack_push(pocz, buildNumber(Length(StrEax)));
          end;
          'val' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TSTR, i); 
            StrEax := stack_get(pocz).Str;
            if (sets.Autoclear) then stack_pop(pocz);
            val(StrEax, ExtEax, IntEax); 
            if (IntEax = 0) then begin
              stack_push(pocz, buildNumber(ExtEax));
            end else begin
              stack_push(pocz, buildString(StrEax));
            end;
          end;
          'print' : begin
            EntEax := stack_get(pocz);
            if (sets.Autoclear) then stack_pop(pocz);
            if (EntEax.EntityType = TNUM) then write(FormatFloat(sets.Mask, EntEax.Num));
            if (EntEax.EntityType = TSTR) then write(EntEax.Str);
          end;
          'println' : begin
            EntEax := stack_get(pocz);
            if (sets.Autoclear) then stack_pop(pocz);
            if (EntEax.EntityType = TNUM) then writeln(FormatFloat(sets.Mask, EntEax.Num));
            if (EntEax.EntityType = TSTR) then writeln(EntEax.Str);
          end;
          'rprint' : begin
            EntEax := stack_get(pocz);
            stack_pop(pocz);
            if (EntEax.EntityType = TNUM) then write(FormatFloat(sets.Mask, EntEax.Num));
            if (EntEax.EntityType = TSTR) then write(EntEax.Str);
          end;
          'rprintln' : begin
            EntEax := stack_get(pocz);
            stack_pop(pocz);
            if (EntEax.EntityType = TNUM) then writeln(FormatFloat(sets.Mask, EntEax.Num));
            if (EntEax.EntityType = TSTR) then writeln(EntEax.Str);
          end;
          'newln' : begin
            writeln();
          end;
          'status' : begin
            write(stack_show(pocz, sets.Mask));
          end;
          'statusln' : begin
            writeln(stack_show(pocz, sets.Mask));
          end;

          'rem' : begin
            stack_justpop(pocz);
          end;
          'clear' : begin
            stack_clear(pocz);
          end;
          'keep' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
          	y := stack_pop(pocz).Num;
          	if (y >= 1) then begin
          		SetLength(HelpETable, trunc(y));
          		for index := 0 to trunc(y)-1 do HelpETable[index] := stack_pop(pocz);
          		stack_clear(pocz);
          		for index := trunc(y)-1 downto 0 do stack_push(pocz, HelpETable[index]);
          		SetLength(HelpETable, 0);
          	end else if (y = 0) then begin
          	  stack_clear(pocz);
          	end;
          end;
          'copy' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
            y := stack_get(pocz).Num;
            stack_pop(pocz);
            if (y >= 1) then begin
              SetLength(HelpETable, trunc(y));
              for index := 0 to trunc(y)-1 do HelpETable[index] := stack_pop(pocz);
              for index := trunc(y)-1 downto 0 do stack_push(pocz, HelpETable[index]);
              for index := trunc(y)-1 downto 0 do stack_push(pocz, HelpETable[index]);
              SetLength(HelpETable, 0);
            end else if (y = 0) then begin
              stack_clear(pocz);
            end;
          end;
          'mcopy' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
          	y := stack_get(pocz).Num;
          	stack_pop(pocz);
          	if (y >= 1) then begin
          		SetLength(HelpETable, trunc(y));
          		for index := 0 to trunc(y)-1 do begin
          		  HelpETable[index] := stack_get(pocz);
          		  stack_pop(pocz);
          		end;
          		for index := trunc(y)-1 downto 0 do stack_push(pocz, HelpETable[index]);
          		for index := 0 to trunc(y)-1 do stack_push(pocz, HelpETable[index]);
          		SetLength(HelpETable, 0);
          	end else if (y = 0) then begin
          	    stack_clear(pocz);
          	end;
          end;
          'sort' : begin
            if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i);
            size := trunc(stack_pop(pocz).Num);
          	//size := stack_size(pocz);
            SetLength(HelpNTable, size);
            for index := 0 to size-1 do begin
              if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
              HelpNTable[index] := stack_pop(pocz).Num;
            end;
            if (sets.sorttype = 0) then bubblesort(HelpNTable);
            if (sets.sorttype = 1) then quicksort(HelpNTable);
            if (sets.sorttype = 2) then mergesort(HelpNTable);
            if (sets.sorttype = 3) then bogosort(HelpNTable);
            for index := 0 to size-1 do stack_push(pocz, buildNumber(HelpNTable[index]));         
            SetLength(HelpNTable, 0);
          end;
          'rand' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
            y := stack_get(pocz).Num;
            stack_pop(pocz);
            z := random(trunc(y));
            if not (sets.Autoclear) then stack_push(pocz, buildNumber(y));
            stack_push(pocz, buildNumber(z));
          end;
             


          // stack operands
          'sum' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
          	y := stack_get(pocz).Num;
          	stack_pop(pocz);
          	if (y >= 1) then begin
          		SetLength(HelpNTable, trunc(y));
          		for index := 0 to trunc(y)-1 do begin
          		    if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
          		    HelpNTable[index] := stack_pop(pocz).Num;
          		end;
          		z := table_sum(HelpNTable);
          		if not (sets.Autoclear) then begin 
          			IntEax := trunc(y)-1;
          			repeat
          				stack_push(pocz, buildNumber(HelpNTable[IntEax]));
          				Dec(IntEax);
          			until IntEax = 0;
          		end;
          		SetLength(HelpNTable, 0);
          		stack_push(pocz, buildNumber(z));
          	end else if (y = 0) then begin
          	  stack_push(pocz, buildNumber(0.0));
          	end;
          end;
          'product' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
          	y := stack_get(pocz).Num;
          	stack_pop(pocz);
          	if (y >= 1) then begin
          		SetLength(HelpNTable, trunc(y));
          		for index := 0 to trunc(y)-1 do begin
          			if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
                    HelpNTable[index] := stack_pop(pocz).Num;
          		end;
          		table_reverse(HelpNTable);
          		z := table_product(HelpNTable);
          		if not (sets.Autoclear) then begin 
          			IntEax := trunc(y)-1;
          			repeat
          				stack_push(pocz, buildNumber(HelpNTable[IntEax]));
          				Dec(IntEax);
          			until IntEax = 0;
          		end;
          		SetLength(HelpNTable, 0);
          		stack_push(pocz, buildNumber(z));
          	end else if (y = 0) then begin
          	  stack_push(pocz, buildNumber(1.0));
          	end;
          end;
          'count' : begin
          	z := 0.0;
          	while (stack_size(pocz) > 0) do
          	begin
          		z := z + 1;
          		stack_justpop(pocz);
          	end;
          	stack_push(pocz, buildNumber(z));
          end;
          'size' : begin
          	z := stack_size(pocz);
          	stack_push(pocz, buildNumber(z));
          end;
          'all' : begin
          	z := stack_size(pocz);
          	stack_push(pocz, buildNumber(z));
          end;
          'avg' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
          	y := stack_get(pocz).Num;
          	stack_pop(pocz);
          	if (y >= 1) then begin
          		SetLength(HelpNTable, trunc(y));
          		for index := 0 to trunc(y)-1 do begin
          			if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
          		  HelpNTable[index] := stack_get(pocz).Num;
          		  stack_pop(pocz);
          		end;
          		//table_reverse(HelpNTable);
          		z := table_avg(HelpNTable);
          		if not (sets.Autoclear) then begin 
          			IntEax := trunc(y)-1;
          			repeat
          				stack_push(pocz, buildNumber(HelpNTable[IntEax]));
          				Dec(IntEax);
          			until IntEax = 0;
          		end;
          		SetLength(HelpNTable, 0);
          		stack_push(pocz, buildNumber(z));
          	end else if (y = 0) then begin
          	  stack_push(pocz, buildNumber(0.0));
          	end;
          end;
          'min' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
          	y := stack_get(pocz).Num;
          	stack_pop(pocz);
          	if (y >= 1) then begin
          		SetLength(HelpNTable, trunc(y));
          		for index := 0 to trunc(y)-1 do begin
          			if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
          		  HelpNTable[index] := stack_get(pocz).Num;
          		  stack_pop(pocz);
          		end;
          		table_reverse(HelpNTable);
          		z := table_min(HelpNTable);
          		if not (sets.Autoclear) then begin 
          			IntEax := trunc(y)-1;
          			repeat
          				stack_push(pocz, buildNumber(HelpNTable[IntEax]));
          				Dec(IntEax);
          			until IntEax = 0;
          		end;
          		SetLength(HelpNTable, 0);
          		stack_push(pocz, buildNumber(z));
          	end else if (y = 0) then begin
          	  stack_push(pocz, buildNumber(0.0));
          	end;
          end;
          'max' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
          	y := stack_get(pocz).Num;
          	stack_pop(pocz);
          	if (y >= 1) then begin
          		SetLength(HelpNTable, trunc(y));
          		for index := 0 to trunc(y)-1 do begin
          			if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
          		  HelpNTable[index] := stack_get(pocz).Num;
          		  stack_pop(pocz);
          		end;
          		table_reverse(HelpNTable);
          		z := table_max(HelpNTable);
          		if not (sets.Autoclear) then begin 
          			IntEax := trunc(y)-1;
          			repeat
          				stack_push(pocz, buildNumber(HelpNTable[IntEax]));
          				Dec(IntEax);
          			until IntEax = 0;
          		end;
          		SetLength(HelpNTable, 0);
          		stack_push(pocz, buildNumber(z));
          	end else if (y = 0) then begin
          	  stack_push(pocz, buildNumber(0.0));
          	end;
          end;
          'median' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
          	y := stack_get(pocz).Num;
          	stack_pop(pocz);
          	if (y >= 1) then begin
          		SetLength(HelpNTable, trunc(y));
          		for index := 0 to trunc(y)-1 do begin
          			if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
          		  HelpNTable[index] := stack_get(pocz).Num;
          		  stack_pop(pocz);
          		end;
          		table_reverse(HelpNTable);
          		z := table_median(HelpNTable);
          		if not (sets.Autoclear) then begin 
          			IntEax := trunc(y)-1;
          			repeat
          				stack_push(pocz, buildNumber(HelpNTable[IntEax]));
          				Dec(IntEax);
          			until IntEax = 0;
          		end;
          		SetLength(HelpNTable, 0);
          		stack_push(pocz, buildNumber(z));
          	end else if (y = 0) then begin
          	  stack_push(pocz, buildNumber(0.0));
          	end;
          end;
          'variance' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
          	y := stack_get(pocz).Num;
          	stack_pop(pocz);
          	if (y >= 1) then begin
          		SetLength(HelpNTable, trunc(y));
          		for index := 0 to trunc(y)-1 do begin
          			if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
          		  HelpNTable[index] := stack_get(pocz).Num;
          		  stack_pop(pocz);
          		end;
          		table_reverse(HelpNTable);
          		z := table_variance(HelpNTable);
          		if not (sets.Autoclear) then begin 
          			IntEax := trunc(y)-1;
          			repeat
          				stack_push(pocz, buildNumber(HelpNTable[IntEax]));
          				Dec(IntEax);
          			until IntEax = 0;
          		end;
          		SetLength(HelpNTable, 0);
          		stack_push(pocz, buildNumber(z));
          	end else if (y = 0) then begin
          	  stack_push(pocz, buildNumber(0.0));
          	end;
          end;
          'stddev' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
          	y := stack_get(pocz).Num;
          	stack_pop(pocz);
          	if (y >= 1) then begin
          		SetLength(HelpNTable, trunc(y));
          		for index := 0 to trunc(y)-1 do begin
          			if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
          		  HelpNTable[index] := stack_get(pocz).Num;
          		  stack_pop(pocz);
          		end;
          		table_reverse(HelpNTable);
          		z := table_stddev(HelpNTable);
          		if not (sets.Autoclear) then begin 
          			IntEax := trunc(y)-1;
          			repeat
          				stack_push(pocz, buildNumber(HelpNTable[IntEax]));
          				Dec(IntEax);
          			until IntEax = 0;
          		end;
          		SetLength(HelpNTable, 0);
          		stack_push(pocz, buildNumber(z));
          	end else if (y = 0) then begin
          	  stack_push(pocz, buildNumber(0.0));
          	end;
          end;
          'rev' : begin
          	pocz := stack_reverse(pocz);
          end;
             
          // stack creators
          'seq' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
          	z := stack_get(pocz).Num;
            stack_pop(pocz);
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
          	y := stack_get(pocz).Num;
            stack_pop(pocz);
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
            x := stack_get(pocz).Num;
            stack_pop(pocz);
            if (x <= z) then
            begin
            	while (x <= z) do 
            	begin
            		stack_push(pocz, buildNumber(x));
            		x := x + y;
            	end;
            end else begin
            	while (x >= z) do 
            	begin
            		stack_push(pocz, buildNumber(x));
            		x := x - y;
            	end;
            end;
          end;

          'seql' : begin
            if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
            z := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
            x := stack_pop(pocz).Num;
            a := 1.0;
          	while (a <= z) do 
            begin
              stack_push(pocz, buildNumber(x));
              x := x + y;
              a := a + 1.0;
            end;
          end;

          'gseq' : begin
          	if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
            z := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
            x := stack_pop(pocz).Num;
            if (x <= z) then
            begin
              while (x <= z) do 
              begin
                stack_push(pocz, buildNumber(x));
                x := x * y;
              end;
            end else begin
              while (x >= z) do 
              begin
                stack_push(pocz, buildNumber(x));
                x := x / y;
              end;
            end;
          end;

          'gseql' : begin
          	if (sets.StrictType) then assertNaturalLocated(stack_get(pocz), i); 
            z := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
            y := stack_pop(pocz).Num;
            if (sets.StrictType) then assertEntityLocated(stack_get(pocz), TNUM, i);
            x := stack_pop(pocz).Num;
            a := 1.0;
          	while (a <= z) do 
            begin
              stack_push(pocz, buildNumber(x));
              x := x * y;
              a := a + 1.0;
            end;
          end;

          else begin
            case LeftStr(i, 1) of
              'X' : begin
                if (RightStr(i, Length(i)-1) = '*') and (not (Unit5.is_gui)) then Steps := -1
                else Steps := StrToInt(RightStr(i, Length(i)-1));
              end;
              else begin
                case LeftStr(i, 9) of
                  '@source("' : begin
                    if (RightStr(i, 2) = '")') then begin
                      StrEax := RightStr(i, Length(i)-9);
                      StrEax := LeftStr(StrEax, Length(StrEax)-2);
                      StrEbx := read_sourcefile(StrEax, pocz, sets, vardb);
                    end else begin
                      
                    end;
                  end;
                  else begin
                    stack_push(pocz, buildString(StrEcx));
                  end;
                end;
              end;
            end;
          end;
        end;
      end else begin
        stack_push(pocz, buildNumber(Im));
      end;
end;

function commentcut(input : String) : String;
var 
  pom         : String;
  togglequote : Boolean;
  i           : Integer;
begin
  pom := '';
  togglequote := false;
  for i := 0 to Length(input) do begin
  	if (input[i] = '"') then togglequote := not (togglequote);
    if (not ((input[i] = '/') and (input[i+1] = '/'))) or (togglequote) then begin
      pom := concat(pom, input[i]);
    end else begin
      if not (togglequote) then break;
    end;
  end;
  commentcut := pom;
end;

function read_sourcefile(filename : String; var pocz : StackDB; var sets : TSettings; var vardb : VariableDB) : String;
var
  fun, S : String;
  fp     : Text;
begin
  fun := '';
  assignfile(fp, filename);
  reset(fp);
  while not eof(fp) do
  begin
    readln(fp, S);
    if (S <> '') then S := commentcut(S);
    fun := fun + ' ' + S;
  end;
  closefile(fp);
  S := parseRPN(fun, pocz, sets, vardb);
  read_sourcefile := S;
end;

function parseRPN(input : string; var pocz : StackDB; var sets : TSettings; var vardb : VariableDB) : String;
var
        L      : TStrings;
        i      : String;
        index  : LongInt;
        z      : String;
        step   : Integer;
        cursor : LongInt;
        nestlv : ShortInt;
        nesttx : String;
begin
  L := TStringlist.Create;
  L.Delimiter := ' ';
  L.QuoteChar := '"';
  L.StrictDelimiter := false;
  L.DelimitedText := input;

  //writeln(input);

  Steps := 1;

  index := 0;
  while index < L.Count do
  begin
    if L[index] = '{' then begin
      nestlv := 1;
      nesttx := '';
      cursor := index + 1;
      while (nestlv > 0) and (cursor < L.Count) do begin
        if (L[cursor] = '{') then Inc(nestlv);
        if (L[cursor] = '}') then Dec(nestlv);
        if (nestlv > 0) and (L[cursor] <> DelSpace(L[cursor])) then nesttx := nesttx + ' ' + ANSIQuotedStr(L[cursor], '"')
        else if (nestlv > 0) then nesttx := nesttx + ' ' + L[cursor];
        Inc(cursor);
      end;
      if Steps = -1 then begin
        repeat
          parseRPN(nesttx, pocz, sets, vardb); 
        until EOF;
        stack_pop(pocz);
      end else for step := 1 to Steps do parseRPN(nesttx, pocz, sets, vardb); 
      index := cursor - 1;
    end else begin
      if Steps = -1 then begin
        repeat
          evaluate(L[index], pocz, Steps, sets, vardb);
        until EOF;
        stack_pop(pocz);
      end else for step := 1 to Steps do evaluate(L[index], pocz, Steps, sets, vardb); 
    end;


    Inc(index);
  end;
  z := '';
  L.Free;

  parseRPN := z;
end;

function calc_parseRPN(input : string; var sets : TSettings) : String;
var
  stack  : StackDB;
  res    : String;
  vardb  : VariableDB;
begin
  stack := stack_null();
  vardb := createVariables();
  res := parseRPN(input, stack, sets, vardb);
  res := stack_show(stack, sets.Mask);
  calc_parseRPN := res;
end;


end.
