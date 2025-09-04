//contactos agrego por email y veo uno x uno

unit uContactos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uAppState, uUsuarios, uContactosListCircular;

type

  { TFormContactos }

  TFormContactos = class(TForm)
    btnAgregar: TButton;
    btnVer: TButton;
    btnSig: TButton;
    edtEmail: TEdit;
    lblInfo: TLabel;
    procedure btnAgregarClick(Sender: TObject);
    procedure btnSigClick(Sender: TObject);
    procedure btnVerClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FActual: PContacto;//puntero al contacto actual, lista circular
    procedure MostrarActual;
  public
  end;

var
  FormContactos: TFormContactos;

implementation

{$R *.lfm}

{ TFormContactos }

procedure TFormContactos.MostrarActual;
begin
  if (GUsuarioActual = nil) then begin
    lblInfo.Caption := 'sin sesión';
    Exit;
  end;
  if (GUsuarioActual^.contactos.head=nil) then begin
    lblInfo.Caption := 'sin contactos';
    exit;
  end;
  if FActual=nil then FActual := GUsuarioActual^.contactos.head;
  lblInfo.Caption := 'id:'+ IntToStr(FActual^.id) +' | '+FActual^.nombre+' | '+FActual^.email;
end;

procedure TFormContactos.FormShow(Sender: TObject);
begin
  if GUsuarioActual = nil then begin
    ShowMessage('No hay usuario logueado');
    Close; // opcional
    Exit;
  end;

  //inicio en head
  FActual := GUsuarioActual^.contactos.head;
  MostrarActual;
end;


procedure TFormContactos.btnAgregarClick(Sender: TObject);
var
  em: string;
  u: PUsuario;
  ya: PContacto;

begin
  if GUsuarioActual = nil then begin ShowMessage('No hay sesión');
    Exit;
  end;

  em := Trim(LowerCase(edtEmail.Text));
  if em='' then begin ShowMessage('pon un email');
    exit;
  end;

  u := BuscarUsuarioPorEmail(GUsuarios, em);
  if u = nil then begin
    ShowMessage('no existe ese usuario en el sistema');
    exit;
  end;

  ya := BuscarContactoPorEmail(GUsuarioActual^.contactos, em);
  if ya <> nil then begin
    ShowMessage('ya está en tus contactos');
    Exit;
  end;

  //agrego a lista circular
  AgregarContacto(GUsuarioActual^.contactos, u^.id, u^.nombre, u^.email);
  ShowMessage('agregado :)');
  edtEmail.Clear;


  //me muevo a head para ver el agregado
  FActual := GUsuarioActual^.contactos.head;
  MostrarActual;
end;

//lista circularrrrrr
procedure TFormContactos.btnSigClick(Sender: TObject);
begin
  //lista circular: voy al siguiente o a head si esta en nil
  if (GUsuarioActual = nil) or (GUsuarioActual^.contactos.head = nil) then Exit;
  if FActual = nil then FActual := GUsuarioActual^.contactos.head
  else FActual := FActual^.next;
  MostrarActual;
end;

procedure TFormContactos.btnVerClick(Sender: TObject);
begin
  if (GUsuarioActual = nil) or (GUsuarioActual^.contactos.head = nil) then
  begin
    ShowMessage('sin contactos');
    Exit;
  end;
  if FActual = nil then FActual := GUsuarioActual^.contactos.head;
  ShowMessage(FActual^.nombre + LineEnding + FActual^.email);
end;

end.

