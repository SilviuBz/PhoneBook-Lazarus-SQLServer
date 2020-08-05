unit UdmConSQL;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, MSSQLConn;

type

  { TdmConSQL }

  TdmConSQL = class(TDataModule)
    SQLConn: TSQLConnector;
    SQLTran: TSQLTransaction;

  private

  public

  end;

var
  dmConSQL: TdmConSQL;

implementation

{$R *.lfm}



{ TdmConSQL }


end.

