//estado global de la app
//guarda las estructuras para que las vean los forms
unit uAppState;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, uUsuarios, uCorreos, uPapelera, uCorreosProgramados,
  uContactosListCircular, uMatrizUsuarios;

var
  GUsuarios: TListaUsuarios;//lista simple de usuariaoi
  GCorreos: TListaCorreos; //lista doble de correo
  GPapelera: TPilaPapelera;//pila de borradores
  GProgramados: TColaProgramados;//cola de programados
  GContactos: TListaContactosCircular;//contactos circular
  GMatriz: TMatrizUsuarios;//matriz usarios x usuarios
  GUsuarioActual: PUsuario;//quien ingreso

procedure AppInit;//esto inicia las estructuras y asegura root

implementation

//para pruebas de email --------------
procedure SeedCorreosDemo; forward;

procedure AppInit;
begin
  //inicio todo vacio
  InitUsuarios(GUsuarios);
  InitCorreos(GCorreos);
  InitPapelera(GPapelera);
  InitProgramados(GProgramados);
  InitContactos(GContactos);
  InitMatriz(GMatriz);

  //añadir para prueba --------------------
  SeedCorreosDemo; //solo para pruebas rapidas de la bandeja (quitar luego)--------------

  //aseguro root fijo
  if BuscarUsuarioPorEmail(GUsuarios, 'root@edd.com') = nil then
    InsertarUsuario(GUsuarios, 100, 'root', 'root', 'root@edd.com', '00000000');
end;

//solo para pruebas rapidas de la bandeja
procedure SeedCorreosDemo;
var
  c: PCorreo;
  id: integer;
begin
  if (GCorreos.head <> nil) then exit; //si ya hay correos, no hago nada

  id := 1;

  //pruebas -----------------------------
  //1er correo (NO LEIDO)
  New(c);
  c^.id        := id; inc(id);
  c^.remitente := 'teacher@edd.com';
  c^.asunto    := 'tttt';
  c^.mensaje   := 'Bbbbb' + LineEnding + 'aslkdjflañsdk';
  c^.fecha     := '03/09/25 11:20';
  c^.estado    := 'N';
  c^.prev := nil;
  c^.next := nil;
  GCorreos.head := c;
  GCorreos.tail := c;
  GCorreos.noLeidos := 1;

  //2do correo (LEIDO)
  New(c^.next);
  c^.next^.prev := c;
  c := c^.next;
  c^.id        := id; inc(id);
  c^.remitente := 'root@edd.com';
  c^.asunto    := 'holiiii';
  c^.mensaje   := 'correo de prueba';
  c^.fecha     := FormatDateTime('dd/mm/yy hh:nn', Now);
  c^.estado    := 'L';
  c^.next := nil;
  GCorreos.tail := c;
end; //----------------------------------------

end.

