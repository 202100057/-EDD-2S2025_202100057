//enviar correo

unit uEnviar;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uAppState, uContactosListCircular, uMatrizUsuarios, uCorreos, uUsuarios;

type

  { TFormEnviar }

  TFormEnviar = class(TForm)
    btnEnviar: TButton;
    edtAsunto: TEdit;
    edtPara: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    lblMsg: TLabel;
    memMensaje: TMemo;
    procedure btnEnviarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    procedure SetMsg(const s: string);
    function NuevoIdCorreo(var L: TListaCorreos): longint;//id dentro de esta bandeja
  public
  end;

var
  FormEnviar: TFormEnviar;

implementation

{$R *.lfm}

{ TFormEnviar }

//genera un id simple revisando lo que ya hay y va sumando
function TFormEnviar.NuevoIdCorreo(var L: TListaCorreos): longint;
var
  p: PCorreo;
  maxid: longint;
begin
  maxid := 0;
  p := L.head;
  while p <> nil do
  begin
    if p^.id > maxid then maxid := p^.id;
    p := p^.next;
  end;
  Result := maxid + 1;
end;

procedure TFormEnviar.SetMsg(const s: string);
begin
  lblMsg.Caption := s;
end;

procedure TFormEnviar.btnEnviarClick(Sender: TObject);
var
  emailDst: string;
  contacto: PContacto;//busca en contactos
  destino: PUsuario;//usuario receptor
  idEmi, idRec, nuevoId: longint;
  asunto, mensaje: string;
begin
  //agarro datos
  emailDst := Trim(LowerCase(edtPara.Text));
  asunto := Trim(edtAsunto.Text);
  mensaje := memMensaje.Text;

  //validaciones
  if (GUsuarioActual = nil) then
  begin
    SetMsg('no hay usuario');
    exit;
  end;
  if (emailDst = '') then begin SetMsg('pon un correo destino');
    exit;
  end;

  //debe estar en contactos la lista ciruclar
  contacto := BuscarContactoPorEmail(GUsuarioActual^.contactos, emailDst);
  if contacto = nil then
  begin
    //no esta en contactos tons error
    SetMsg('no esta en contactos');
    ShowMessage('debes agregar primero el contacto');
    exit;
  end;

  //contacto debe existir como usuario real para tener bandeja
  destino := BuscarUsuarioPorEmail(GUsuarios, emailDst);
  if destino = nil then
  begin
    SetMsg('ese usuario no existe');
    exit;
  end;

  //inserto en la bandeja del usuario actual pa simular de recibido
  nuevoId := NuevoIdCorreo(destino^.bandeja);
  InsertarCorreoFinal(
    destino^.bandeja,
    nuevoId,
    GUsuarioActual^.email,//remitente el usuario actual
    asunto,
    FormatDateTime('yyyy-mm-dd hh:nn', Now),
    mensaje,
    false //no es programado
  );
  Inc(destino^.bandeja.noLeidos);//le suma a NL del destino

  //marco relacion en la matriz emisor a receptor
  idEmi := GUsuarioActual^.id;
  idRec := contacto^.id;//id se gaurada al agregar contacto
  InsertarRelacion(GMatriz, idEmi, idRec);

  SetMsg('enviado :)');
  ShowMessage('enviado a ' + contacto^.email);
  //Close;
end;


procedure TFormEnviar.FormShow(Sender: TObject);
begin
  //para limpar los camibos
  edtPara.Text := '';
  edtAsunto.Text := '';
  memMensaje.Lines.Clear;
  SetMsg('listo para enviar :)');
end;

end.

