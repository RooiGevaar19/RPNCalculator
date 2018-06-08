unit Unit6;
// Unit with Stacks

{$mode objfpc}{$H+}

interface

uses Unit7, Classes, SysUtils;

type StackDB = record
  Values : array of Entity;
end;

function stack_null() : StackDB;
procedure stack_push(var pocz:StackDB; node : Entity);
function stack_pop(var pocz:StackDB) : Entity;
procedure stack_justpop(var pocz:StackDB);
procedure stack_clear(var pocz:StackDB);
function stack_get(pocz : StackDB) : Entity;
function stack_getback(pocz : StackDB; index : LongInt) : Entity;
function stack_size(poc : StackDB) : Longint;
function stack_show(poc : StackDB; mask : String) : String;
function stack_reverse(poc : StackDB) : StackDB;

implementation

// STACK OPERATIONS

function stack_null() : StackDB;
var
    pom : StackDB;
begin
    SetLength(pom.Values, 0);
    stack_null := pom;
end;

procedure stack_push(var pocz:StackDB; node : Entity);
var
    len : LongInt;
begin
    len := Length(pocz.Values);
    SetLength(pocz.Values, len+1);
    pocz.Values[len] := node;
end;

function stack_pop(var pocz:StackDB) : Entity;
var
    len : LongInt;
    pom : Entity;
begin
    len := Length(pocz.Values);
    pom := pocz.Values[len-1];
    SetLength(pocz.Values, len-1);
    stack_pop := pom;
end;

procedure stack_justpop(var pocz:StackDB);
var
    len : LongInt;
    pom : Entity;
begin
    len := Length(pocz.Values);
    SetLength(pocz.Values, len-1);
end;

procedure stack_clear(var pocz:StackDB);
begin
    while Length(pocz.Values) > 0 do stack_justpop(pocz);
end;

function stack_get(pocz : StackDB) : Entity;
begin
    stack_get := pocz.Values[Length(pocz.Values)-1];
end;

function stack_getback(pocz : StackDB; index : LongInt) : Entity;
begin
    stack_getback := pocz.Values[Length(pocz.Values)-index];
end;

function stack_size(poc : StackDB) : Longint;
begin
    stack_size := Length(poc.Values);
end;

function stack_show(poc : StackDB; mask : String) : String;
var
  z : String;
  i : Entity;
begin
    z := '';
    for i in poc.Values do
    begin
        if (i.EntityType = TNUM) then z := z + FormatFloat(mask, i.Num) + ' ';
        if (i.EntityType = TSTR) then z := z + '"' + i.Str + '" ';
    end;
    z := LeftStr(z, Length(z)-1);
    stack_show := z;
end;


function stack_reverse(poc : StackDB) : StackDB;
var
  pom : StackDB;
  i   : LongInt;
begin
    pom := stack_null();
    for i := Length(poc.Values)-1 downto 0 do
    begin
        stack_push(pom, poc.Values[i]);
    end;
    stack_reverse := pom;   
end;


end.

