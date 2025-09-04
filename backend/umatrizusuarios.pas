//matriz dispersa usuarios x usuarios
//fila = emisor
//columna = receptor
//en cada celda guardo cuantas veces le mando (contador)
//nota: ortogonal con punteros up,down,left,right

unit uMatrizUsuarios;

{$mode objfpc}{$H+}

interface

type
  PCelda = ^TCelda;
  TCelda = record
    filaId: longint;//id emisor
    colId: longint;//id receptor
    veces: longint;//cuantos correos le ha mandado
    up, down: PCelda;
    left, right: PCelda;
  end;

  PCabFila = ^TCabFila;
  TCabFila = record
    id: longint;//id usuario osea el emisor
    first: PCelda;//primer celda de esta fils, va por right
    next: PCabFila; //siguiente cabecera de fila
  end;

  PCabCol = ^TCabCol;
  TCabCol = record
    id: longint;//id usuario osea el receptor
    first: PCelda;//primer celda de esta col, va por down
    next: PCabCol; //siguiente cabecera de col
  end;

  TMatrizUsuarios = record
    filas: PCabFila;//lista de cabeceras de fila ordenadas por id
    cols: PCabCol;//lista de cabeceras de col ordenadas por id
  end;

procedure InitMatriz(var M: TMatrizUsuarios);
procedure InsertarRelacion(var M: TMatrizUsuarios; emisorId, receptorId: longint);
function  BuscarRelacion(var M: TMatrizUsuarios; emisorId, receptorId: longint): PCelda;
function  TotalEnviadosDesde(var M: TMatrizUsuarios; emisorId: longint): longint;
function  TotalRecibidosPor(var M: TMatrizUsuarios; receptorId: longint): longint;

implementation

//helpers internos pa no repetir tanto

function AsegurarCabFila(var M: TMatrizUsuarios; id: longint): PCabFila;
var cur, ant, nuevo: PCabFila;
begin
  //busco en orden, perooo si no esta lo creo y lo inserto ordenado
  ant := nil; cur := M.filas;
  while (cur <> nil) and (cur^.id < id) do begin ant := cur; cur := cur^.next; end;
  if (cur <> nil) and (cur^.id = id) then begin AsegurarCabFila := cur; exit; end;

  new(nuevo); nuevo^.id := id; nuevo^.first := nil; nuevo^.next := cur;
  if ant = nil then M.filas := nuevo else ant^.next := nuevo;
  AsegurarCabFila := nuevo;
end;

function AsegurarCabCol(var M: TMatrizUsuarios; id: longint): PCabCol;
var cur, ant, nuevo: PCabCol;
begin
  ant := nil; cur := M.cols;
  while (cur <> nil) and (cur^.id < id) do begin ant := cur; cur := cur^.next; end;
  if (cur <> nil) and (cur^.id = id) then begin AsegurarCabCol := cur; exit; end;

  new(nuevo); nuevo^.id := id; nuevo^.first := nil; nuevo^.next := cur;
  if ant = nil then M.cols := nuevo else ant^.next := nuevo;
  AsegurarCabCol := nuevo;
end;

procedure InsertarEnFila(cab: PCabFila; celda: PCelda);
var cur, ant: PCelda;
begin
  //inserto ordenado por colId en la lista derecha (right)
  ant := nil; cur := cab^.first;
  while (cur <> nil) and (cur^.colId < celda^.colId) do begin ant := cur; cur := cur^.right; end;
  celda^.right := cur; celda^.left := ant;
  if ant = nil then cab^.first := celda else ant^.right := celda;
  if cur <> nil then cur^.left := celda;
end;

procedure InsertarEnCol(cab: PCabCol; celda: PCelda);
var cur, ant: PCelda;
begin
  //inserto ordenado por filaId en la lista vertical (down )
  ant := nil; cur := cab^.first;
  while (cur <> nil) and (cur^.filaId < celda^.filaId) do begin ant := cur; cur := cur^.down; end;
  celda^.down := cur; celda^.up := ant;
  if ant = nil then cab^.first := celda else ant^.down := celda;
  if cur <> nil then cur^.up := celda;
end;

procedure InitMatriz(var M: TMatrizUsuarios);
begin
  //reset :)
  M.filas := nil;
  M.cols := nil;
end;

procedure InsertarRelacion(var M: TMatrizUsuarios; emisorId, receptorId: longint);
var f: PCabFila; c: PCabCol; cel, walk: PCelda;
begin
  //si ya existe la celda, solo sumo, si no, creo y enlazo ortogonal
  f := AsegurarCabFila(M, emisorId);
  c := AsegurarCabCol(M, receptorId);

  //busco si ya esta en la fila, mas barato que recorrer toda la matriz
  walk := f^.first;
  while (walk <> nil) and (walk^.colId < receptorId) do walk := walk^.right;
  if (walk <> nil) and (walk^.colId = receptorId) then
  begin
    inc(walk^.veces);
    exit;
  end;

  //no estaba tonslo creo
  new(cel);
  cel^.filaId := emisorId;
  cel^.colId := receptorId;
  cel^.veces := 1;
  cel^.up := nil; cel^.down := nil; cel^.left := nil; cel^.right := nil;

  //lo meto en la fila y en la columna(dos listas distintas)
  InsertarEnFila(f, cel);
  InsertarEnCol(c, cel);
end;

function BuscarRelacion(var M: TMatrizUsuarios; emisorId, receptorId: longint): PCelda;
var f: PCabFila; curF: PCabFila; cel: PCelda;
begin
  //busco cabecera de fila
  curF := M.filas;
  while (curF <> nil) and (curF^.id <> emisorId) do curF := curF^.next;
  if curF = nil then begin BuscarRelacion := nil; exit; end;

  //busco en la fila
  cel := curF^.first;
  while (cel <> nil) and (cel^.colId <> receptorId) do cel := cel^.right;
  BuscarRelacion := cel;
end;

function TotalEnviadosDesde(var M: TMatrizUsuarios; emisorId: longint): longint;
var f: PCabFila; cel: PCelda; suma: longint;
begin
  suma := 0;
  f := M.filas;
  while (f <> nil) and (f^.id <> emisorId) do f := f^.next;
  if f = nil then begin TotalEnviadosDesde := 0; exit; end;

  cel := f^.first;
  while cel <> nil do begin inc(suma, cel^.veces); cel := cel^.right; end;
  TotalEnviadosDesde := suma;
end;

function TotalRecibidosPor(var M: TMatrizUsuarios; receptorId: longint): longint;
var c: PCabCol; cel: PCelda; suma: longint;
begin
  suma := 0;
  c := M.cols;
  while (c <> nil) and (c^.id <> receptorId) do c := c^.next;
  if c = nil then begin TotalRecibidosPor := 0; exit; end;

  cel := c^.first;
  while cel <> nil do begin inc(suma, cel^.veces); cel := cel^.down; end;
  TotalRecibidosPor := suma;
end;

end.

