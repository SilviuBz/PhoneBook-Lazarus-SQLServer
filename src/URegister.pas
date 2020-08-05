unit uRegister;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, SQLDB, DB,
  DBCtrls, UdmQrySQL;

type

  { TFRegister }

  TFRegister = class(TForm)
    cbActivRegister: TCheckBox;
    DBFullName: TDBEdit;
    DBEmail: TDBEdit;
    DBOras: TDBEdit;
    DBJudet: TDBEdit;
    DBAdress: TDBEdit;
    DBEPhoneNumber: TDBEdit;
    lblRegistratioForm: TLabel;
    pRegistrationlbl: TPanel;
    btnSubmitEdit: TButton;
    lblJudet: TLabel;
    lblOras: TLabel;
    lblAdress: TLabel;
    lblEmail: TLabel;
    lblPhoneNumber: TLabel;
    lblFullName: TLabel;
    PannelRegisterInformation: TPanel;
    procedure cbActivRegisterChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnSubmitEditClick(Sender: TObject);
    Procedure RegisterFormDecider();
    Procedure MissingData();

  private

  public

  end;


implementation

{$R *.lfm}

{ TFRegister }

procedure TFRegister.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
     With dmQrySQL do
     begin
           SQLQryReadOnlyDecider(True, dmQrySQL.dsSQlQryDetails.DataSet);
     end;

  CloseAction:=  caFree;

end;

procedure TFRegister.cbActivRegisterChange(Sender: TObject);
begin
    If cbActivRegister.Checked then
    begin
         cbActivRegister.Caption := 'Activ';
    end else
    begin
         cbActivRegister.Caption := 'Inactiv';
    end;
end;


procedure TFRegister.FormCreate(Sender: TObject);
begin
     dmQrySQL.SQLQryReadOnlyDecider(False, dmQrySQL.dsSQlQryDetails.DataSet);
end;

procedure TFRegister.btnSubmitEditClick(Sender: TObject);
Var
  A: Integer;
begin
    A:= 0;
     MissingData();
    If lblRegistratioForm.Caption = 'Edit Form'  then
    Begin
          IF cbActivRegister.Checked then A:= 1;

          With dmQrySQl do
          begin
               If SQLQryDetails.FieldByName('Activ').AsInteger <> A then
               begin;
                  With SQLQryDetails do
                  begin
                        Edit;
                        FieldByName('Activ').asInteger := A;
                        //Post;
                  end;
               end;
          SQLUpdateDetails();
          end;
          Close;
    end else
    IF  lblRegistratioForm.Caption = 'Register Form' then
    begin
        dmQrySQl.SQLInsertDetails();
        dmQrySQl.SQLQryDetailsFill(dmQrySQl.GetNextId() -1);
        Close;
    end;
    //ModalResult := mrOK;
end;

procedure TFRegister.RegisterFormDecider();
 Var
  //IDvar: integer;
  Activ: boolean;
begin
     If lblRegistratioForm.Caption = 'Edit Form' then
     begin
          Activ := (dmQrySQl.dsSQLQryDetails.DataSet.FieldByName('Activ').AsInteger = 1);
          cbActivRegister.Checked:= Activ;
     end;

end;

Procedure TFRegister.MissingData();
begin
    If (DBEPhoneNumber.Text = '') or
       (DBFullName.Text = '') or
       (DBEmail.Text = '') or
       (DBOras.Text = '') or
       (DBJudet.Text = '') or
       (DBAdress.Text = '') Then
    Begin
         ShowMessage('Please enter the Missing Data');
         Abort;
    end;
end;

end.

