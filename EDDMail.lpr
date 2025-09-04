program EDDMail;

{$mode objfpc}{$H+}

uses
  SysUtils, uUsuarios, uCorreos, uPapelera, uCorreosProgramados, uContactosListCircular,
  uReportesDot, uMatrizUsuarios, uCargaJson;

//variables
var
  ListUsua: TListaUsuarios;//lista simple de los usuariosi
  p: PUsuario;//puntero pa buscar un usuario
  ListCorreos: TListaCorreos;//lista doble de correos
  c: PCorreo;//puntero pa correo temporal
  Papelera: TPilaPapelera;//pila de correos eliminados
  borrador: PCorreo;//para saber de la bandeja y mandar a papaelera
  colaProg: TColaProgramados;//cola de correos programados
  progTemp: PProgCorreo;//puntero para ver o sacar los programados
  //contactos list circular
  contactos: TListaContactosCircular;
  pc: PContacto;//puntero de contactos
  //matriz usuarios x usuarios
  M: TMatrizUsuarios;
  celFound: PCelda;//puntero de celdas
  r: TCargaResultado;

begin

  //prueba de lista simple :)

  //inicializo la lista de usuarios
  InitUsuarios(ListUsua);

  //meto 3 usuarios
  InsertarUsuario(ListUsua, 100, 'root', 'root', 'root@edd.com', '00000000');
  InsertarUsuario(ListUsua, 20, 'Claire', 'kclaire', 'kaxpuac@gmail.com', '12345678');
  InsertarUsuario(ListUsua, 30, 'alex', 'alexdev', 'alex@dev.com', '87654321');

  //busco por email y muestro datos si existe
  p := BuscarUsuarioPorEmail(ListUsua, 'kaxpuac@gmail.com');
  if p <> nil then
    writeln('encontre: ', p^.nombre, ' (', p^.email, ')')
  else
    writeln('no encontre el usuario');


  //prueba de correos (lista doble)

  //inicializo correos
  InitCorreos(ListCorreos);

  //inserto 2 correos al final
  InsertarCorreoFinal(ListCorreos, 100, 'aux@edd.com', 'hola', '2025-09-01', 'mensaje 100', false);
  InsertarCorreoFinal(ListCorreos, 20, 'profe@edd.com', 'tarea', '2025-09-02', 'mensaje 20', false);

  //muestro contador de no leidos
  writeln('no leidos: ', ListCorreos.noLeidos);

  //busco por asunto y lo marco leido
  c := BuscarPorAsunto(ListCorreos, 'hola');
  if c <> nil then
  begin
    writeln('lei el correo con asunto: ', c^.asunto);
    MarcarLeido(ListCorreos, c);
  end;

  //contador despues
  writeln('no leidos despues: ', ListCorreos.noLeidos);


  //------------------------------------
  //papelera (pila)
  InitPapelera(Papelera);

  //elimino de la bandeja el correo con id 20 y lo mando a papelera
  EliminarCorreoPorId(ListCorreos, 20, borrador);
  if borrador <> nil then
  begin
    PushPapelera(Papelera, borrador);
    writeln('mande a papelera el id: ', borrador^.id);
  end;

  //busco en la papelera por id
  c := BuscarEnPapelera(Papelera, 20);
  if c <> nil then
    writeln('en papelera encontre id: ', c^.id);

  //elimino definitivo ese id
  EliminarDefinitivo(Papelera, 20);
  c := BuscarEnPapelera(Papelera, 20);
  if c = nil then
    writeln('ya no existe en papelera el id 20');


  //-----------------------------------------------------
  //correos programados (cola) :)
  InitProgramados(colaProg);
  EncolarProgramado(colaProg, 100, 'yo@edd.com', 'recordatorio', '2025-09-10', 'mandar informe');
  EncolarProgramado(colaProg, 101, 'root@edd.com', 'backup', '2025-09-11', 'revisar respaldito je');
  writeln('programados en cola: ', colaProg.size);

  //miro el de adelante
  progTemp := VerSiguienteProgramado(colaProg);
  if progTemp <> nil then
    writeln('siguiente por enviar: ', progTemp^.asunto, ' en ', progTemp^.fecha);

  //saco uno (como si ya se envio) y muestro cuantos quedan
  progTemp := DesencolarProgramado(colaProg);
  if progTemp <> nil then
  begin
    writeln('enviado (simulado) id: ', progTemp^.id, ' asunto: ', progTemp^.asunto);
    dispose(progTemp);//libero memoria del que ya use
  end;
  writeln('programados ahora: ', colaProg.size);


  //--------------------------------------
  //contactos aqui es donde utilizo mas la lista circular
  InitContactos(contactos);//inicio vacio

  //agrego 3 contactos (les pongo datos rapidos)
  AgregarContacto(contactos, 20, 'claire', 'kaxpuac@gmail.com');
  AgregarContacto(contactos, 30, 'alex', 'alex@dev.com');
  AgregarContacto(contactos, 100, 'root', 'root@edd.com');

  //muestro una vuelta
  writeln('');
  writeln('----->contactos (circular)<------');
  MostrarContactos(contactos);

  //busco a usuario por email
  pc := BuscarContactoPorEmail(contactos, 'kaxpuac@gmail.com');
  if pc <> nil then
     writeln('encontre contacto: ', pc^.nombre, ' ', pc^.email)
  else
    writeln('no encontre el contacto');


  //----------------------------------------------------
  //paa el reporte de la lista doble

  GenerarDOTCorreos(ListCorreos, 'correos.dot');

  //png con graphviz
  if DotAPng('correos.dot', 'correos.png') then
    writeln('genere correos.png con exito')
  else
    writeln('no pude generar el png, revisa si dot esta en el PATH');


  //--------------------------------------------
  //pruebas de matriz dispersa ( quien le manda a quien)
  InitMatriz(M);//dejo en blanco

  //simulo envios: 20a30,20a100,30a100,20a30
  InsertarRelacion(M, 20, 30);
  InsertarRelacion(M, 20, 100);
  InsertarRelacion(M, 30, 100);
  InsertarRelacion(M, 20, 30);//repite, aqui debe sumar

  //miro totales rapidos
  writeln('');
  writeln('envios desde 20: ', TotalEnviadosDesde(M, 20));//espera 30
  writeln('recibidos por 100: ', TotalRecibidosPor(M, 100));//espera 20

  //busco la celda 2a3
  celFound := BuscarRelacion(M, 20, 30);
  if celFound <> nil then
    writeln('20 le ha mandado a 30: ', celFound^.veces, ' veces :)');



  //dump de la matriz a dot y a png para ver la malla :)
  GenerarDOTMatrizUsuarios(M, 'matriz.dot');
  if DotAPng('matriz.dot', 'matriz.png') then
    writeln('se genere matriz.png')
  else
    writeln('no pude generar matriz.png, revisar el dot en PATH');



  //--------------------------------------------------
  //carga masiva desde json
  if FileExists('ArchivosPruebaP1.json') then
  begin
    CargarUsuariosDesdeJSON(ListUsua, 'ArchivosPruebaP1.json', r);
    writeln('carga json:', r.insertados, ' repetidosId:', r.repetidosId, ' repetidosEmail:', r.repetidosEmail, ' errores:', r.errores);
  end
  else
    writeln('no encontre ArchivosPruebaP1.json (ponlo junto al exe o usa ruta completa)');

  //reporte de usuarios pa root
  ForceDirectories('Root-Reportes');//aseguro carpeta
  GenerarDOTUsuarios(ListUsua, 'Root-Reportes/usuarios.dot');
  if DotAPng('Root-Reportes/usuarios.dot', 'Root-Reportes/usuarios.png') then
    writeln('reporte usuarios en Root-Reportes/usuarios.png')
  else
    writeln('no pude generar usuarios.png (checa dot en PATH)');







  //pausa para ver salida
  readln;
end.

