program EDDMailApp;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uLogin, uCargaJson, uContactosListCircular, uCorreos,
  uCorreosProgramados, uMatrizUsuarios, uPapelera, uReportesDot, uUsuarios,
  uAppState, uRootMenu, uUserMenu, uInbox, uContactos, uEnviar
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  AppInit;
  Application.CreateForm(TFormLogin, FormLogin);
  Application.CreateForm(TFormRootMenu, FormRootMenu);
  Application.CreateForm(TFormUserMenu, FormUserMenu);
  Application.CreateForm(TFormInbox, FormInbox);
  Application.CreateForm(TFormContactos, FormContactos);
  Application.CreateForm(TFormEnviar, FormEnviar);
  Application.Run;
end.

