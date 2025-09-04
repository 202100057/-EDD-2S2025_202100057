unit uCorreos;

{$mode objfpc}{$H+}

interface

type
  PCorreo = ^TCorreo;
  TCorreo = record
    id: longint;
    remitente: string;
    estado: char;//N no leido, L leido
    programado: boolean;
    asunto: string;
    fecha: string;//por ahora cadena simple yyyy-mm-dd :)
    mensaje: string;
    prev: PCorreo;//puntero al anterior
    next: PCorreo;//puntero al siguiente
  end;

  TListaCorreos = record
    head: PCorreo;//inicio de la lista
    tail: PCorreo;//fin de la lista
    noLeidos: longint;//contador rapido de no leidos
  end;

procedure InitCorreos(var L: TListaCorreos);
procedure InsertarCorreoFinal(var L: TListaCorreos; id: longint; const remitente, asunto, fecha, mensaje: string; programado: boolean);
procedure MarcarLeido(var L: TListaCorreos; c: PCorreo);
function  BuscarPorAsunto(var L: TListaCorreos; const clave: string): PCorreo;//simple, primera coincidencia

procedure EliminarCorreoPorId(var L: TListaCorreos; id: longint; out borrado: PCorreo);

implementation

procedure InitCorreos(var L: TListaCorreos);
begin
  //inicializo la lista doble
  L.head := nil;
  L.tail := nil;
  L.noLeidos := 0;
end;

procedure InsertarCorreoFinal(var L: TListaCorreos; id: longint; const remitente, asunto, fecha, mensaje: string; programado: boolean);
var nuevo: PCorreo;
begin
  //inserto al final
  new(nuevo);
  nuevo^.id := id;
  nuevo^.remitente := remitente;
  nuevo^.estado := 'N';
  nuevo^.programado := programado;
  nuevo^.asunto := asunto;
  nuevo^.fecha := fecha;
  nuevo^.mensaje := mensaje;
  nuevo^.prev := L.tail;
  nuevo^.next := nil;

  if L.tail <> nil then
    L.tail^.next := nuevo;
  L.tail := nuevo;

  if L.head = nil then
    L.head := nuevo;

  //si entra como no leido aumento contador
  inc(L.noLeidos);
end;

procedure MarcarLeido(var L: TListaCorreos; c: PCorreo);
begin
  //si esta no leido lo marco y actualizo contador
  if (c <> nil) and (c^.estado = 'N') then
  begin
    c^.estado := 'L';
    if L.noLeidos > 0 then dec(L.noLeidos);
  end;
end;

function BuscarPorAsunto(var L: TListaCorreos; const clave: string): PCorreo;
var aux: PCorreo;
begin
  //busco primera coincidencia en asunto (igualdad exacta por ahora)
  aux := L.head;
  while aux <> nil do
  begin
    if aux^.asunto = clave then
    begin
      BuscarPorAsunto := aux;
      exit;
    end;
    aux := aux^.next;
  end;
  BuscarPorAsunto := nil;
end;

procedure EliminarCorreoPorId(var L: TListaCorreos; id: longint; out borrado: PCorreo);
var cur: PCorreo;
begin
  //elimino de la lista doble y retorno el nodo en borrado (sin liberar)
  borrado := nil;
  cur := L.head;
  while cur <> nil do
  begin
    if cur^.id = id then
    begin
      //ajusto enlaces de la lista doble
      if cur^.prev <> nil then
        cur^.prev^.next := cur^.next
      else
        L.head := cur^.next;

      if cur^.next <> nil then
        cur^.next^.prev := cur^.prev
      else
        L.tail := cur^.prev;

      //si estaba no leido, bajo el contador
      if (cur^.estado = 'N') and (L.noLeidos > 0) then dec(L.noLeidos);

      //desacoplo el nodo para reutilizarlo en la pila
      cur^.prev := nil;
      cur^.next := nil;

      borrado := cur;
      exit;
    end;
    cur := cur^.next;
  end;
end;


end.

