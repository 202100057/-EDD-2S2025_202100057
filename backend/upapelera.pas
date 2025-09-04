unit uPapelera;

{$mode objfpc}{$H+}

interface

uses
  uCorreos; //uso PCorreo para volver a usar el nodo del correo

type
  TPilaPapelera = record
    top: PCorreo //tope de la pila
  end;

procedure InitPapelera(var P: TPilaPapelera);
procedure PushPapelera(var P: TPilaPapelera; correo: PCorreo);
function  PopPapelera(var P: TPilaPapelera): PCorreo;
function  BuscarEnPapelera(var P: TPilaPapelera; id: longint): PCorreo;
procedure EliminarDefinitivo(var P: TPilaPapelera; id: longint);

implementation

procedure InitPapelera(var P: TPilaPapelera);
begin
  //inicializo la pila
  P.top := nil;
end;

procedure PushPapelera(var P: TPilaPapelera; correo: PCorreo);
begin
  //pongo el nodo arriba de la pila
  if correo = nil then exit;
  //reseteo enlaces para que se comporte como pila simple
  correo^.prev := nil;
  correo^.next := P.top;
  P.top := correo;
end;

function PopPapelera(var P: TPilaPapelera): PCorreo;
var aux: PCorreo;
begin
  //saco el de arriba
  if P.top = nil then
  begin
    PopPapelera := nil;
    exit;
  end;
  aux := P.top;
  P.top := aux^.next;
  //desacoplo por seguridad
  aux^.next := nil;
  aux^.prev := nil;
  PopPapelera := aux;
end;

function BuscarEnPapelera(var P: TPilaPapelera; id: longint): PCorreo;
var aux: PCorreo;
begin
  //busco por id recorriendo la pila
  aux := P.top;
  while aux <> nil do
  begin
    if aux^.id = id then
    begin
      BuscarEnPapelera := aux;
      exit;
    end;
    aux := aux^.next;
  end;
  BuscarEnPapelera := nil;
end;

procedure EliminarDefinitivo(var P: TPilaPapelera; id: longint);
var cur, prev: PCorreo;
begin
  //elimino del todo un nodo de la pila y libero memoria
  cur := P.top;
  prev := nil;
  while cur <> nil do
  begin
    if cur^.id = id then
    begin
      if prev = nil then
        P.top := cur^.next
      else
        prev^.next := cur^.next;
      //libero memoria del correo borrado definitivo
      dispose(cur);
      exit;
    end;
    prev := cur;
    cur := cur^.next;
  end;
end;

end.

