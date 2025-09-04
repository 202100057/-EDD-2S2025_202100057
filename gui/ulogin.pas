//login basico
//root puede cargar json y generar reporte usuarios
//usuario normal entra buscando por email

unit uLogin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, uAppState,
  uCargaJson, uReportesDot, uUsuarios, uRootMenu, uUserMenu;

type

  { TFormLogin }

  TFormLogin = class(TForm)
    btnEntrar: TButton;
    btnCargarJSON: TButton;
    edtPass: TEdit;
    edtEmail: TEdit;
    lblMsg: TLabel;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnEntrarClick(Sender: TObject);
    procedure btnCargarJSONClick(Sender: TObject);
  private
    procedure SetMsg(const s: string);

  public

  end;

var
  FormLogin: TFormLogin;

implementation

{$R *.lfm}

procedure TFormLogin.SetMsg(const s: string);
begin
  lblMsg.Caption := s;
end;

procedure TFormLogin.FormCreate(Sender: TObject);
begin
  //valores de prueba para ir rapido
  edtEmail.Text := 'root@edd.com';
  edtPass.Text  := 'root123';
  SetMsg('listo para entrar');
end;

procedure TFormLogin.btnEntrarClick(Sender: TObject);
var
  p: PUsuario;
  email, pass: string;
begin
  email := Trim(LowerCase(edtEmail.Text));
  pass  := edtPass.Text;

  //root fijo (enunciado)
  if (email='root@edd.com') and (pass='root123') then
  begin
    SetMsg('Holu root :)');
    //abrir menu root y ocultar login
    if not Assigned(FormRootMenu) then
      Application.CreateForm(TFormRootMenu, FormRootMenu);
    FormRootMenu.Show;
    Self.Hide;
    exit;
  end;

  //usuario normal por ahora valido solo por email
  p := BuscarUsuarioPorEmail(GUsuarios, email);
  if p <> nil then
  begin
    //guarda quien ingreso para que el resto de formularios lo use
    GUsuarioActual := p;

    SetMsg('bienvenido ' + p^.nombre);
    //abrir menu de usuario y ocultar login
    if not Assigned(FormUserMenu) then
      Application.CreateForm(TFormUserMenu, FormUserMenu);
    FormUserMenu.Show;
    Self.Hide;
  end
  else
  begin
    SetMsg('no encontre el usuario');
    ShowMessage('no encontre el usuario');
  end;
end;

procedure TFormLogin.btnCargarJSONClick(Sender: TObject);
var
  r: TCargaResultado;
begin
  if not (LowerCase(Trim(edtEmail.Text))='root@edd.com') then
  begin
    ShowMessage('esta opcion es para root');
    exit;
  end;

  OpenDialog1.Filter := 'JSON|*.json|Todos|*.*';
  if OpenDialog1.Execute then
  begin
    CargarUsuariosDesdeJSON(GUsuarios, OpenDialog1.FileName, r);
    SetMsg(Format('json:%d repId:%d repEmail:%d err:%d',
       [r.insertados, r.repetidosId, r.repetidosEmail, r.errores]));

    //reporte de usuarios
    ForceDirectories('Root-Reportes');
    GenerarDOTUsuarios(GUsuarios, 'Root-Reportes/usuarios.dot');
    if DotAPng('Root-Reportes/usuarios.dot', 'Root-Reportes/usuarios.png') then
      ShowMessage('reporte usuarios listo en Root-Reportes/usuarios.png')
    else
      ShowMessage('no pude generar usuarios.png (checa graphviz/dot)');
  end;
end;


end.

