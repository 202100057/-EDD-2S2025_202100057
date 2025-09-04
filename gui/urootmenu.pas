//menu root
//botone scarga json, reporte usuarios, reporte relaciones

unit uRootMenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uAppState, uCargaJson, uReportesDot, uMatrizUsuarios;

type

  { TFormRootMenu }

  TFormRootMenu = class(TForm)
    btnCargaMasiva: TButton;
    btnRepUsuarios: TButton;
    btnRepRelaciones: TButton;
    btnCerrar: TButton;
    OpenDialog1: TOpenDialog;
    procedure btnCargaMasivaClick(Sender: TObject);
    procedure btnRepUsuariosClick(Sender: TObject);
    procedure btnRepRelacionesClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
  private
  public
  end;

var
  FormRootMenu: TFormRootMenu;

implementation

uses uLogin;

{$R *.lfm}

{ TFormRootMenu }

procedure TFormRootMenu.btnCargaMasivaClick(Sender: TObject);
var r: TCargaResultado;

begin

  //root carga json y ya
  OpenDialog1.Filter := 'JSON|*.json|Todos|*.*';
  if OpenDialog1.Execute then
  begin
    CargarUsuariosDesdeJSON(GUsuarios, OpenDialog1.FileName, r);
    ShowMessage(Format('json:%d repId:%d repEmail:%d err:%d',
      [r.insertados, r.repetidosId, r.repetidosEmail, r.errores]));
  end;
end;


procedure TFormRootMenu.btnRepUsuariosClick(Sender: TObject);
begin
  //genera imagen de usuarios
  ForceDirectories('Root-Reportes');
  GenerarDOTUsuarios(GUsuarios, 'Root-Reportes/usuarios.dot');
  if DotAPng('Root-Reportes/usuarios.dot', 'Root-Reportes/usuarios.png') then
    ShowMessage('reporte usuarios en Root-Reportes/usuarios.png')
  else
    ShowMessage('no pude generar usuarios.png (dot no esta en PATH?)');
end;

procedure TFormRootMenu.btnRepRelacionesClick(Sender: TObject);
begin
  //usa la matriz global GMatriz para el dot
  ForceDirectories('Root-Reportes');
  GenerarDOTMatrizUsuarios(GMatriz, 'Root-Reportes/relaciones.dot');
  if DotAPng('Root-Reportes/relaciones.dot', 'Root-Reportes/relaciones.png') then
    ShowMessage('reporte relaciones en Root-Reportes/relaciones.png')
  else
    ShowMessage('no pude generar relaciones.png ');
end;

procedure TFormRootMenu.btnCerrarClick(Sender: TObject);
begin
  //limpio la sesion
  GUsuarioActual := nil;

  //muestro login de nuevo
  if not Assigned(FormLogin) then
    Application.CreateForm(TFormLogin, FormLogin);
  FormLogin.Show;

  //cierro este menu
  Self.Close;
end;


end.

