//lector json de usuarios
//mete users a la lista simple
//valida duplicados por id y por email

unit uCargaJson;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, uUsuarios;

type
  TCargaResultado = record
    insertados: longint;
    repetidosId: longint;
    repetidosEmail: longint;
    errores: longint;
  end;

procedure CargarUsuariosDesdeJSON(var LU: TListaUsuarios; const ruta: string; out res: TCargaResultado);

implementation

function ExisteId(var LU: TListaUsuarios; id: longint): boolean;
var p: PUsuario;
begin
  //busca por id
  p := LU.head;
  while p <> nil do
  begin
    if p^.id = id then begin ExisteId := true; exit; end;
    p := p^.next;
  end;
  ExisteId := false;
end;

function ExisteEmail(var LU: TListaUsuarios; const email: string): boolean;
begin
  //uso el buscador por email
  ExisteEmail := (BuscarUsuarioPorEmail(LU, email) <> nil);
end;

procedure CargarUsuariosDesdeJSON(var LU: TListaUsuarios; const ruta: string; out res: TCargaResultado);
var
  j: TJSONData;
  objRoot, uobj: TJSONObject;
  arr: TJSONArray;
  i, id: longint;
  nombre, usuario, email, tel, pass: string;
begin
  //inicializo counters
  res.insertados := 0; res.repetidosId := 0; res.repetidosEmail := 0; res.errores := 0;

  if not FileExists(ruta) then exit;

  try
    j := GetJSON(TFileStream.Create(ruta, fmOpenRead or fmShareDenyNone), true);
  except
    inc(res.errores); exit;
  end;

  try
    objRoot := j as TJSONObject;
    arr := objRoot.Arrays['usuarios'];
    for i := 0 to arr.Count - 1 do
    begin
      uobj := arr.Objects[i];

      //saco campos
      id := uobj.Get('id', 0);
      nombre := uobj.Get('nombre', '');
      usuario := uobj.Get('usuario', '');
      email := uobj.Get('email', '');
      tel := uobj.Get('telefono', '');
      pass := uobj.Get('password', '1234');//en caso de no venir le pongo algo simple

      //valido duplicados por id y email
      if ExisteId(LU, id) then begin inc(res.repetidosId); continue; end;
      if ExisteEmail(LU, email) then begin inc(res.repetidosEmail); continue; end;

      //inserto enlista somple
      InsertarUsuario(LU, id, nombre, usuario, email, tel);
      inc(res.insertados);
    end;
  except
    inc(res.errores);
  end;

  j.Free;
end;

end.

