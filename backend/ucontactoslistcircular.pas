unit uContactosListCircular;
//codigo O(n) al insertar busca el ultimo o recorre hata llegar al ultimo

{$mode objfpc}{$H+}

interface

type
  PContacto = ^TContacto;
  TContacto = record
    id: longint;
    nombre: string;
    email: string;
    next: PContacto;//apunta al siguiente y el ultimo apunta al primero
  end;

  TListaContactosCircular = record
    head: PContacto;//puntero al primero, pero si es nil no hay nada
  end;

procedure InitContactos(var LC: TListaContactosCircular);
procedure AgregarContacto(var LC: TListaContactosCircular; id: longint; const nombre, email: string);
function  BuscarContactoPorEmail(var LC: TListaContactosCircular; const email: string): PContacto;
procedure MostrarContactos(var LC: TListaContactosCircular);//impreme rapido, para probar

implementation

procedure InitContactos(var LC: TListaContactosCircular);
begin
  //dejo la lista vacia
  LC.head := nil;
end;

procedure AgregarContacto(var LC: TListaContactosCircular; id: longint; const nombre, email: string);
var nuevo, tail: PContacto;
begin
  //agrego al final para mantener circular
  new(nuevo);
  nuevo^.id := id;
  nuevo^.nombre := nombre;
  nuevo^.email := email;

  if LC.head = nil then
  begin
    //primer nodo
    nuevo^.next := nuevo;//cierra el circulo xd
    LC.head := nuevo;
    exit;
  end;

  //busco el ultimo (el que apunta a head)
  tail := LC.head;
  while tail^.next <> LC.head do
    tail := tail^.next;

  tail^.next := nuevo;//el viejo ultimo ahora apunta al nuevo
  nuevo^.next := LC.head;//y el nuevo cierra apuntando a head
end;

function BuscarContactoPorEmail(var LC: TListaContactosCircular; const email: string): PContacto;
var cur: PContacto;
begin
  //recorro circular, paro si doy la vuelta
  if LC.head = nil then
  begin
    BuscarContactoPorEmail := nil;
    exit;
  end;

  cur := LC.head;
  repeat
    if cur^.email = email then
    begin
      BuscarContactoPorEmail := cur;
      exit;
    end;
    cur := cur^.next;
  until cur = LC.head;

  BuscarContactoPorEmail := nil;
end;

procedure MostrarContactos(var LC: TListaContactosCircular);
var cur: PContacto;
begin
  //imprimo la vuelta completa solo 1 en teoria
  if LC.head = nil then
  begin
    writeln('contactos vacios');
    exit;
  end;

  cur := LC.head;
  repeat
    writeln('contacto -> ', cur^.id, ' | ', cur^.nombre, ' | ', cur^.email);
    cur := cur^.next;
  until cur = LC.head;
end;

end.

