//reporte en dot para ver la lista doble de correos
//para checar enlaces next y prev

unit uReportesDot;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, uCorreos, uMatrizUsuarios, uUsuarios;//uso TProcess para llamar dot y matriz

procedure GenerarDOTCorreos(var L: TListaCorreos; const rutaDot: string);
function  DotAPng(const rutaDot, rutaPng: string): boolean;

//matriz usuarios x usuarios (fila-emisor, col-receptor)
procedure GenerarDOTMatrizUsuarios(var M: TMatrizUsuarios; const rutaDot: string);

//usuarios (lista simple)
procedure GenerarDOTUsuarios(var LU: TListaUsuarios; const rutaDot: string);

implementation

procedure GenerarDOTCorreos(var L: TListaCorreos; const rutaDot: string);
var
  listStringTemp: TStringList;//guarda lineas para el dot
  correoT: PCorreo;//camina en la lista
  i: longint;//contador simpke
begin
  //armo un .dot basico con nodos y flechas doble via
  listStringTemp := TStringList.Create;
  try
    listStringTemp.Add('digraph G {');
    listStringTemp.Add('  rankdir=LR;');//izq a der
    listStringTemp.Add('  node [shape=record];');
    listStringTemp.Add('  label="lista doble correos"; labelloc=t; fontsize=21;');

    //declaro nodos con etiquetas
    correoT := L.head;
    i := 0;
    while correoT <> nil do
    begin
      //id unico y datos basicos
      listStringTemp.Add(Format('  n%d [label="{id:%d|rem:%s|asunto:%s|estado:%s}"];',
        [ i, correoT^.id,
          StringReplace(correoT^.remitente,'"','''',[rfReplaceAll]),
          StringReplace(correoT^.asunto,'"','''',[rfReplaceAll]),
          String(correoT^.estado)//char a string pa %s
        ]));
      correoT := correoT^.next;
      inc(i);
    end;

    //ahora las aristas next y prev
    correoT := L.head;
    i := 0;
    while correoT <> nil do
    begin
      if correoT^.next <> nil then
        listStringTemp.Add(Format('  n%d -> n%d [label="next"];', [i, i+1]));
      if correoT^.prev <> nil then
        listStringTemp.Add(Format('  n%d -> n%d [label="prev",color="gray"];', [i, i-1]));
      correoT := correoT^.next;
      inc(i);
    end;

    //marco head y tail con cajas
    if L.head <> nil then listStringTemp.Add('  head [shape=box,label="HEAD"];');
    if L.tail <> nil then listStringTemp.Add('  tail [shape=box,label="TAIL"];');
    if L.head <> nil then listStringTemp.Add('  head -> n0 [style=dashed];');
    if (L.tail <> nil) and (i > 0) then
      listStringTemp.Add(Format('  tail -> n%d [style=dashed];', [i-1]));

    listStringTemp.Add('}');
    //guardo a archivo
    listStringTemp.SaveToFile(rutaDot);
  finally
    listStringTemp.Free;
  end;
end;

function DotAPng(const rutaDot, rutaPng: string): boolean;
var
  P: TProcess;
  exe: string;
begin
  //intento usar dot del PATH, si no, poner ruta completa a dot.exe
  exe := 'dot';
  {$IFDEF WINDOWS}
  //ejemplo si no esta en PATH:
  //exe := 'C:\Program Files\Graphviz\bin\dot.exe';
  {$ENDIF}

  Result := False;
  P := TProcess.Create(nil);
  try
    P.Executable := exe;
    P.Parameters.Add('-Tpng');
    P.Parameters.Add(rutaDot);
    P.Parameters.Add('-o');
    P.Parameters.Add(rutaPng);
    P.Options := [poUsePipes, poNoConsole, poWaitOnExit];//se debe esperar
    try
      P.Execute;
      //si por alguna razon exitstatus no es 0 pero el archivo existe
      if (P.ExitStatus = 0) or FileExists(rutaPng) then
        Result := True
      else
        Result := False;
    except
      Result := FileExists(rutaPng); //por si igual lo genero
    end;
  finally
    P.Free;
  end;
end;

//-------------------------------
//matriz dispersa
//grafico cabeceras de filas y cols, y cada celda como un cuadrito
//pongo flechas horizontales right y verticales down pa ver la mallita :p

procedure GenerarDOTMatrizUsuarios(var M: TMatrizUsuarios; const rutaDot: string);
var
  txt: TStringList;
  f: PCabFila;//fila header
  c: PCabCol;//col header
  cell: PCelda;//puntero de la celdita de la matriz dispersa
  ridx: longint;//indices contador
begin
  txt := TStringList.Create;
  try
    txt.Add('digraph G {');
    txt.Add('  rankdir=LR;');
    txt.Add('  node [shape=record, fontsize=10];');
    txt.Add('  label="matriz usuarios x usuarios (fila=emisor col=receptor)"; labelloc=t; fontsize=20;');

    //cabeceras de filas
    f := M.filas;
    while f <> nil do
    begin
      txt.Add(Format('  F%d [shape=box,label="F:%d"];', [f^.id, f^.id]));
      f := f^.next;
    end;

    //cabeceras de columnas
    c := M.cols;
    while c <> nil do
    begin
      txt.Add(Format('  C%d [shape=box,label="C:%d"];', [c^.id, c^.id]));
      c := c^.next;
    end;

    //celdas por fila, enlaces right
    f := M.filas;
    while f <> nil do
    begin
      cell := f^.first;
      ridx := 0;
      while cell <> nil do
      begin
        //nodo de celda, muestro f a c y veces
        txt.Add(Format('  N_%d_%d [label="{%d->%d|x%d}"];',
          [cell^.filaId, cell^.colId, cell^.filaId, cell^.colId, cell^.veces]));
        if ridx = 0 then
          //conecto cabecera de fila al primer nodo
          txt.Add(Format('  F%d -> N_%d_%d [color="blue"];',
            [f^.id, cell^.filaId, cell^.colId]));
        //enlace horizontal si hay siguiente
        if cell^.right <> nil then
          txt.Add(Format('  N_%d_%d -> N_%d_%d [label="right"];',
            [cell^.filaId, cell^.colId, cell^.right^.filaId, cell^.right^.colId]));
        cell := cell^.right;
        inc(ridx);
      end;
      f := f^.next;
    end;

    //enlaces verticales (down) por columna
    c := M.cols;
    while c <> nil do
    begin
      cell := c^.first;
      if cell <> nil then
        //conecto cabecera de col a su primera celda
        txt.Add(Format('  C%d -> N_%d_%d [color="green"];',
          [c^.id, cell^.filaId, cell^.colId]));
      while cell <> nil do
      begin
        if cell^.down <> nil then
          txt.Add(Format('  N_%d_%d -> N_%d_%d [label="down",color="gray"];',
            [cell^.filaId, cell^.colId, cell^.down^.filaId, cell^.down^.colId]));
        cell := cell^.down;
      end;
      c := c^.next;
    end;

    txt.Add('}');
    txt.SaveToFile(rutaDot);
  finally
    txt.Free;
  end;
end;

//reporte en dot de usuarios (lista simple)
//para ver nodos y el enlace next

procedure GenerarDOTUsuarios(var LU: TListaUsuarios; const rutaDot: string);
var
  sl: TStringList;
  u: PUsuario;
  i: longint;
begin
  sl := TStringList.Create;
  try
    sl.Add('digraph G {');
    sl.Add('  rankdir=LR;');
    sl.Add('  node [shape=record, fontsize=10];');
    sl.Add('  label="usuarios (lista simple)"; labelloc=t; fontsize=20;');

    //declaro nodos
    u := LU.head;
    i := 0;
    while u <> nil do
    begin
      sl.Add(Format('  u%d [label="{id:%d|%s|%s}"];',
        [i, u^.id,
         StringReplace(u^.nombre,'"','''',[rfReplaceAll]),
         StringReplace(u^.email,'"','''',[rfReplaceAll])]));
      u := u^.next;
      inc(i);
    end;

    //enlaces next
    u := LU.head;
    i := 0;
    while u <> nil do
    begin
      if u^.next <> nil then sl.Add(Format('  u%d -> u%d;', [i, i+1]));
      u := u^.next;
      inc(i);
    end;

    //marco head
    if LU.head <> nil then begin
      sl.Add('  head [shape=box,label="HEAD"];');
      sl.Add('  head -> u0 [style=dashed];');
    end;

    sl.Add('}');
    sl.SaveToFile(rutaDot);
  finally
    sl.Free;
  end;
end;



end.

