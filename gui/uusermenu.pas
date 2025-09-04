//menu usuario

unit uUserMenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uAppState, uUsuarios, uInbox, uContactos, uEnviar;

type

  { TFormUserMenu }

  TFormUserMenu = class(TForm)
    btnBandeja: TButton;
    btnCerrar: TButton;
    btnEnviar: TButton;
    btnPapelera: TButton;
    btnProgramar: TButton;
    btnProgramados: TButton;
    btnContactos: TButton;
    btnPerfil: TButton;
    btnReportes: TButton;
    lblHola: TLabel;
    procedure btnContactosClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
    procedure btnPapeleraClick(Sender: TObject);
    procedure btnPerfilClick(Sender: TObject);
    procedure btnProgramadosClick(Sender: TObject);
    procedure btnProgramarClick(Sender: TObject);
    procedure btnReportesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBandejaClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
  private
    procedure Pendiente;
  public
  end;


var
  FormUserMenu: TFormUserMenu;

implementation

uses
  uLogin;

{$R *.lfm}

{ TFormUserMenu }

procedure TFormUserMenu.FormShow(Sender: TObject);
var
  nombre: string;
begin
  //saludo
  if (GUsuarioActual<>nil) and (GUsuarioActual^.usuario<>'') then
    nombre := GUsuarioActual^.usuario
  else if (GUsuarioActual<>nil) then
    nombre := GUsuarioActual^.nombre
  else
    nombre := 'usuario';
  lblHola.Caption := 'Hola: ' + nombre;
end;


procedure TFormUserMenu.btnReportesClick(Sender: TObject);
begin

end;

procedure TFormUserMenu.btnEnviarClick(Sender: TObject);
begin
  //abrir el form de enviar
  if not Assigned(FormEnviar) then
    Application.CreateForm(TFormEnviar, FormEnviar);
  FormEnviar.ShowModal;//para regresar al menu
end;


procedure TFormUserMenu.btnContactosClick(Sender: TObject);
begin
  if not Assigned(FormContactos) then
    Application.CreateForm(TFormContactos, FormContactos);
  FormContactos.ShowModal;
end;

procedure TFormUserMenu.btnPapeleraClick(Sender: TObject);
begin

end;

procedure TFormUserMenu.btnPerfilClick(Sender: TObject);
begin

end;

procedure TFormUserMenu.btnProgramadosClick(Sender: TObject);
begin

end;

procedure TFormUserMenu.btnProgramarClick(Sender: TObject);
begin

end;

procedure TFormUserMenu.btnBandejaClick(Sender: TObject);
begin
  //abrir la bandeja
  if not Assigned(FormInbox) then
    Application.CreateForm(TFormInbox, FormInbox);
  FormInbox.ShowModal;
end;

procedure TFormUserMenu.btnCerrarClick(Sender: TObject);
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

procedure TFormUserMenu.Pendiente;
begin
  ShowMessage('pendiente');
end;

end.

