unit uUsuarios;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uCorreos, uPapelera, uCorreosProgramados, uContactosListCircular;

type
  PUsuario = ^TUsuario;
  TUsuario = record
    id: longint;
    nombre: string;
    usuario: string;
    email: string;
    telefono: string;

    //para que cada usuario tenga su propia bandeja
    bandeja: TListaCorreos;
    papelera: TPilaPapelera;
    programados: TColaProgramados;
    contactos: TListaContactosCircular;

    next: PUsuario//apunta al siguiente en la lista
  end;

  TListaUsuarios = record
    head: PUsuario//puntero a la cabeza de la lista
  end;

procedure InitUsuarios(var L: TListaUsuarios);
procedure InsertarUsuario(var L: TListaUsuarios; id: longint; const nombre, usuario, email, telefono: string);
function  BuscarUsuarioPorEmail(var L: TListaUsuarios; const email: string): PUsuario;

implementation

procedure InitUsuarios(var L: TListaUsuarios);
begin
  //inicializo la lista, la cabeza apunta a nil
  L.head := nil;
end;

procedure InsertarUsuario(var L: TListaUsuarios; id: longint; const nombre, usuario, email, telefono: string);
var nuevo: PUsuario;
begin
  //inserto al inicio de la lista
  new(nuevo);
  nuevo^.id := id;
  nuevo^.nombre := nombre;
  nuevo^.usuario := usuario;
  nuevo^.email := email;
  nuevo^.telefono := telefono;

  //inicializo estructuras propias del usuario
  InitCorreos(nuevo^.bandeja);
  InitPapelera(nuevo^.papelera);
  InitProgramados(nuevo^.programados);
  InitContactos(nuevo^.contactos);

  //engancho en la lista
  nuevo^.next := L.head;
  L.head := nuevo;

end;

function BuscarUsuarioPorEmail(var L: TListaUsuarios; const email: string): PUsuario;
var aux: PUsuario;
begin
  //recorro la lista buscando por email
  aux := L.head;
  while aux <> nil do
  begin
    if aux^.email = email then
    begin
      BuscarUsuarioPorEmail := aux;
      exit;
    end;
    aux := aux^.next;
  end;
  BuscarUsuarioPorEmail := nil;
end;

end.

