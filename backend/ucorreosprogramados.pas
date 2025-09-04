unit uCorreosProgramados;

{$mode objfpc}{$H+}

interface

type
  PProgCorreo = ^TProgCorreo;
  TProgCorreo = record
    id: longint;
    remitente: string;
    asunto: string;
    fecha: string;//yyyy-mm-dd por ahorita, luego veo si cambio
    mensaje: string;
    next: PProgCorreo;//siguiente en la cola
  end;

  TColaProgramados = record
    front: PProgCorreo;//frente o sea que sale por aqui
    back: PProgCorreo;//final es decir entra por aqui
    size: longint;//contador por si las dudas jeje
  end;

procedure InitProgramados(var Q: TColaProgramados);
procedure EncolarProgramado(var Q: TColaProgramados; id: longint; const remitente, asunto, fecha, mensaje: string);
function DesencolarProgramado(var Q: TColaProgramados): PProgCorreo;
function VerSiguienteProgramado(var Q: TColaProgramados): PProgCorreo;

implementation

procedure InitProgramados(var Q: TColaProgramados);
begin
  //inicializo cola vacia, todo en nil y size 0 :)
  Q.front := nil;
  Q.back := nil;
  Q.size := 0;
end;

procedure EncolarProgramado(var Q: TColaProgramados; id: longint; const remitente, asunto, fecha, mensaje: string);
var nuevo: PProgCorreo;
begin
  //meto al final --- cola simple enlazada
  new(nuevo);
  nuevo^.id := id;
  nuevo^.remitente := remitente;
  nuevo^.asunto := asunto;
  nuevo^.fecha := fecha;
  nuevo^.mensaje := mensaje;
  nuevo^.next := nil;

  if Q.back <> nil then
    Q.back^.next := nuevo;//pego detras del ultimo
  Q.back := nuevo;

  if Q.front = nil then
    Q.front := nuevo;//si estaba vacia, el frente es este mismo

  inc(Q.size);//cuento uno mas
end;

function DesencolarProgramado(var Q: TColaProgramados): PProgCorreo;
var aux: PProgCorreo;
begin
  //saco del frente (dequeue). si esta vacia retorna nil
  if Q.front = nil then
  begin
    DesencolarProgramado := nil;
    exit;
  end;

  aux := Q.front;
  Q.front := aux^.next;//avanzo el frente

  if Q.front = nil then
    Q.back := nil;//si se vacio, back tambien a nil

  aux^.next := nil;//lo dejo limpito por si lo uso afuera
  if Q.size > 0 then dec(Q.size);
  DesencolarProgramado := aux;
end;

function VerSiguienteProgramado(var Q: TColaProgramados): PProgCorreo;
begin
  //solo miro el frente, no lo saco
  VerSiguienteProgramado := Q.front;
end;

end.

