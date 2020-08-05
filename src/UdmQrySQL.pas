unit UdmQrySQL;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, UdmConSQL, Dialogs,Buttons, Controls,StdCtrls,Graphics, ExtCtrls,
  Menus, ComCtrls;

type

  { TdmQrySQL }

  TdmQrySQL = class(TDataModule)
    dsSQLQryDetails: TDataSource;
    dsGetNextID: TDataSource;
    dsQryList: TDataSource;
    SQLgetNextID: TSQLQuery;
    SQLQryDetails: TSQLQuery;
    SQLQueryList: TSQLQuery;
    SQLQueryListID:TIntegerField;
    procedure SQLQryDetailsAfterOpen(DataSet: TDataSet);
    procedure SQLQryReadOnlyDecider(Flag: boolean; DataSet: TDataSet);
    Procedure SQLUpdateDetails();
    Procedure SQLQryDetailsFill(Id: Integer);
    Procedure SQLInsertDetails();
  private

  public
    Procedure GetSQLPersonList();
    Procedure CloseSqlQery();
    Function  GetNextId():Integer;
  end;

var
  dmQrySQL: TdmQrySQL;


implementation

{$R *.lfm}

uses typinfo;


procedure TdmQrySQL.SQLQryDetailsAfterOpen(DataSet: TDataSet);
begin
   SQLQryReadOnlyDecider(True, Dataset);
end;

Procedure TdmQrySQL.SQLQryReadOnlyDecider(Flag: boolean; DataSet: TDataSet);
Var I: integer;
begin
  for I := 0 to DataSet.FieldCount - 1 do
  DataSet.Fields[I].ReadOnly:= Flag;
end;

Procedure TdmQrySQL.GetSQLPersonList();
Begin
     SQLQueryList.Close;
     SQLQueryList.SQL.Text := 'Select top 100 ID, FullName from Person';
     dmConSQL.SQLConn.Connected := True;
     SQLQueryList.Open;
end;

Procedure TdmQrySQL.CloseSqlQery();
begin
     SQLQueryList.Close;
end;


Function TdmQrySQL.GetNextId(): Integer;
Begin
      SQLgetNextID.Close;
      SQLgetNextID.Open;
      Result := dsGetNextID.DataSet.FieldByName('nextID').AsInteger;
      SQLgetNextId.Close;
end;

procedure TdmQrySQL.SQLUpdateDetails();
begin
  If SQLQryDetails.Modified then
  begin
     SQLQryDetails.CheckBrowseMode;
     try
        dmConSQL.SQLTran.StartTransaction;
        SQLQryDetails.ApplyUpdates;
        dmConSQL.SQlTran.Commit;
     except
        dmConSQL.SQLTran.Rollback;
        raise;
     end;
     SQlQueryList.Close;
     SQlQueryList.Open;
     SQLQryDetails.close;
     SQLQryDetails.Open;
     ShowMessage ('Success!');
  end else
  begin
      If MessageDlg('Warning', 'Nothing to execute! Do you wish to close the window?',
      mtWarning,[mbYes,mbNo],0)<> mrYes then
      begin
          Abort;
      end;
  end;
end;

Procedure TdmQrySQL.SQLQryDetailsFill(Id: Integer);
begin
  IF id  = -1 then
  begin
       with SQLQryDetails Do
       begin
          close;
          SQL.text:= 'Select top 0 * from person ';
          Open;
          Append;
       end;
  end else
  begin

  With SQLQryDetails do
  begin
      Close;
      SQL.Text:= 'Select * from person where id =' + IntToStr(Id);
      Open;
  end;
  end;
end;

Procedure TdmQrySQL.SQLInsertDetails();
Var
   ID: Integer;
begin
  ID:= GetNextId();
  SQLQryDetails.Edit;
  SQLQryDetails.FieldByName('ID').AsInteger := ID;
  SQLQryDetails.FieldByName('Activ').AsInteger := 1;
  SQLUpdateDetails();
end;

end.

