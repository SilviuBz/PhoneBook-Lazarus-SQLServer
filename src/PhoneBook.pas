program PhoneBook;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, UMainMenu, URegister,UdmConSQL, UdmQrySQL
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Phonebook';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TdmConSQL, dmConSQL);
  Application.CreateForm(TdmQrySQL, dmQrySQL);
  Application.CreateForm(TFPhoneBook, FPhoneBook);
  Application.Run;
end.

