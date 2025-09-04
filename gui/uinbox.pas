//bandeja de entrada del usuario

unit uInbox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  uAppState, uCorreos, uPapelera;

type
  //arreglo auxiliar para mapear filas punteros reales
  TArrPCorreo = array of PCorreo;

  { TFormInbox }

  TFormInbox = class(TForm)
    btnEliminar: TButton;
    btnLeer: TButton;
    btnOrdenar: TButton;
    grid: TStringGrid;
    lblCont: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnOrdenarClick(Sender: TObject);
    procedure btnLeerClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
  private
    FOrdenAZ: boolean;
    FMap: TArrPCorreo;//mapea cada fila con un PCorreo
    procedure LlenarGrid;
    procedure RefrescarContador;
    function BandejaVacia: boolean;
  public

  end;

var
  FormInbox: TFormInbox;

implementation

{$R *.lfm}

function CompareAsunto(const A, B: PCorreo): integer;
begin
  Result := CompareText(A^.asunto, B^.asunto);
end;

function TFormInbox.BandejaVacia: boolean;
begin
  Result := (GUsuarioActual = nil) or (GUsuarioActual^.bandeja.head = nil);
end;

{ TFormInbox }

procedure TFormInbox.FormShow(Sender: TObject);
begin
  //debe haber iniciado sesion
  if (GUsuarioActual = nil) then
  begin
    ShowMessage('No hay usuario en sesion');
    Close;
    Exit;
  end;

  //cabeceras del grid
  grid.ColCount := 4;
  grid.FixedRows := 1;
  grid.Cells[0,0] := 'Estado';
  grid.Cells[1,0] := 'Asunto';
  grid.Cells[2,0] := 'Remitente';
  grid.Cells[3,0] := 'Fecha';
  FOrdenAZ := false;
  LlenarGrid;
  RefrescarContador;
end;

procedure TFormInbox.LlenarGrid;
var
  p: PCorreo;
  tmp: array of PCorreo;
  i, j, n: Integer;
  t: PCorreo;
begin
  //seguridad
  if GUsuarioActual = nil then Exit;

  //contar correos en la bandeja del usuario
  n := 0;
  p := GUsuarioActual^.bandeja.head;
  while p <> nil do begin
    Inc(n);
    p := p^.next;
  end;

  //si no hay correos entonces dejar solo los headers
  if n = 0 then
  begin
    SetLength(FMap, 0);
    grid.RowCount := 1;
    Exit;
  end;

  //copiar a arreglo temporal para poder ordenar
  SetLength(tmp, n);
  SetLength(FMap, n);
  p := GUsuarioActual^.bandeja.head;
  i := 0;
  while p <> nil do
  begin
    tmp[i] := p;
    p := p^.next;
    Inc(i);
  end;

  //ordenamiento de burbuja por asunto
  if FOrdenAZ and (n > 1) then
  begin
    for i := 0 to n-2 do
      for j := 0 to n-2-i do
        if CompareAsunto(tmp[j], tmp[j+1]) > 0 then
        begin
          t := tmp[j];
          tmp[j] := tmp[j+1];
          tmp[j+1] := t;
        end;
  end;

  //redimensionar grid y llenar filas
  grid.RowCount := n + 1;
  for i := 0 to n-1 do
  begin
    FMap[i] := tmp[i];
    grid.Cells[0, i+1] := string(tmp[i]^.estado); //'N' no leidos  o 'L' leidos
    grid.Cells[1, i+1] := tmp[i]^.asunto;
    grid.Cells[2, i+1] := tmp[i]^.remitente;
    grid.Cells[3, i+1] := tmp[i]^.fecha;
  end;
end;


procedure TFormInbox.RefrescarContador;
begin
  if GUsuarioActual = nil then Exit;
  lblCont.Caption := IntToStr(GUsuarioActual^.bandeja.noLeidos) + ' No Leidos';
end;

procedure TFormInbox.btnOrdenarClick(Sender: TObject);
begin
  //toggle ordenar
  FOrdenAZ := not FOrdenAZ;
  LlenarGrid;
end;

procedure TFormInbox.btnLeerClick(Sender: TObject);
var
  idx: integer;
  c: PCorreo;
begin
  //fila seleccionada
  if (GUsuarioActual = nil) then Exit;
  if (grid.RowCount <= 1) then Exit;//sin datos
  if (grid.Row <= 0) then Exit;//cabezera
  if Length(FMap) = 0 then Exit;

  idx := grid.Row - 1;
  if (idx < 0) or (idx >= Length(FMap)) then Exit;

  c := FMap[idx];
  if c = nil then exit;

  //marco leido y muestro mensaje
  MarcarLeido(GUsuarioActual^.bandeja, c);
  //muestra el contenidp
  ShowMessage('Remitente: ' + c^.remitente + LineEnding +
              'Fecha: ' + c^.fecha + LineEnding +
              'Mensaje:' + LineEnding + c^.mensaje);

  //refresco vista o  contador
  LlenarGrid;
  RefrescarContador;
end;

procedure TFormInbox.btnEliminarClick(Sender: TObject);
var
  idx: integer;
  c, borr: PCorreo;
begin
  if (GUsuarioActual = nil) then Exit;
  if (grid.RowCount <= 1) then Exit;
  if (grid.Row <= 0) then Exit;
  if Length(FMap) = 0 then Exit;

  idx := grid.Row - 1;
  if (idx < 0) or (idx >= Length(FMap)) then Exit;

  c := FMap[idx];
  if c = nil then Exit;

  //elimino de la bandeja dle usuario y mandar a papelera
  borr := nil;
  EliminarCorreoPorId(GUsuarioActual^.bandeja, c^.id, borr);
  if borr <> nil then
  begin
    PushPapelera(GUsuarioActual^.papelera, borr);
    ShowMessage('Eliminé id:' + IntToStr(borr^.id) + ' a Papelera');
  end;

  LlenarGrid;
  RefrescarContador;
end;

end.

