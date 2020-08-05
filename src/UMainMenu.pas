unit UMainMenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Menus, ComCtrls, EditBtn, DBGrids, LResources, DBCtrls, Buttons, URegister,
  UdmQrySql, UdmConSQL, SQLDB, MSSQLConn,  DB, BufDataset ;

type
  { TFPhoneBook }

  TSearchRecord = record
    FieldName: String;
    AnOperator: String;
    Value: String;
  end;
  PSearchRecord = ^TSearchRecord;

  TFPhoneBook = class(TForm)
    btnNewPersone: TButton;
    btnEdit: TButton;
    cbActivList: TCheckBox;
    cbAll: TCheckBox;
    DBFullName: TDBEdit;
    DBEditAdress: TDBEdit;
    DBEditEmail: TDBEdit;
    DBEditJudet: TDBEdit;
    DBEditOras: TDBEdit;
    DBEditPhoneNuber: TDBEdit;
    DBGrid1: TDBGrid;
    lblActiv: TLabel;
    lblOras: TLabel;
    lblJudetInfo: TLabel;
    lblJudet: TLabel;
    lblAdressInfo: TLabel;
    lblAdress: TLabel;
    lblFullNameInfo: TLabel;
    lblPhoneNumberInfo: TLabel;
    lblPhoneNumber: TLabel;
    lblEmailInfo: TLabel;
    lblEmail: TLabel;
    lblOrasInfo: TLabel;
    lblPersonDetail: TLabel;
    memSQLlog: TMemo;
    Panel1: TPanel;
    SearchTimer: TTimer;
    txtSearch: TEdit;
    lblSearch: TLabel;
    MDView: TMainMenu;
    MenuItem1: TMenuItem;
    pPersonDetails: TPanel;
    smRegister: TMenuItem;
    mmPhoneBook: TMenuItem;
    pPersonList: TPanel;
    procedure btnEditClick(Sender: TObject);
    procedure btnNewPersoneClick(Sender: TObject);
    procedure cbActivListChange(Sender: TObject);
    procedure cbAllChange(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1KeyDown(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure smRegisterClick(Sender: TObject);
    procedure SearchTimerTimer(Sender: TObject);
    procedure txtSearchChange(Sender: TObject);
    procedure FillDetails(Id: Integer);
    procedure SQLConnLog(Sender: TSQLConnection; EventType: TDBEventType;  const Msg: String);
  protected
    FFilterAppling : Boolean;
    FFilterList : TStringList;
    procedure AddFilterToData(AFieldName : String; AOperator : String; AValue : String);
    procedure ControlChangeFilterToData(AControl : String; AnEvent: String; AFieldName : String; AOperator : String; AValue : String);
    procedure FormAddFilterToData(Sender: TObject);
  private
    FRegister: TFRegister;
  public

  end;
  type
  TMyDBGrid = class(TDBGrid);

var
  FPhoneBook: TFPhoneBook;
  PersonID: Integer;
  Q: TdmQrySQL;
  QList: TSQLQuery;



implementation

{$R *.lfm}

uses typinfo, strUtils;

{ TFPhoneBook }

procedure TFPhoneBook.cbActivListChange(Sender: TObject);
begin
   if FFilterAppling then Exit;
   try
     FFilterAppling := True;
     AddFilterToData('Activ', '=', IfThen(cbAll.Checked, '', ifThen(cbActivList.Checked, '1', '0')));
     cbAll.Checked:= False;
     cbActivList.Caption:= ifThen (cbActivList.Checked, 'Activ', 'Inactiv');
   finally
     FFilterAppling := False;
   end;
end;

procedure TFPhoneBook.cbAllChange(Sender: TObject);
begin
   if FFilterAppling then Exit;
   try
     FFilterAppling := True;

   AddFilterToData('Activ', '=', IfThen(cbAll.Checked, '', ifThen(cbActivList.Checked, '1', '0')));

   IF cbAll.Checked then
   begin
      cbActivList.Checked:= False;
      cbActivList.Caption:= 'Activ/Inactiv';
   end else
   begin
      cbActivList.Checked:=True;
      cbActivlist.Caption:= 'Activ';
   end;
   finally
     FFilterAppling := False;
   end;
end;


procedure TFPhoneBook.btnEditClick(Sender: TObject);
var
   lEdit: TFRegister;
begin
  lEdit := TFRegister.Create(Self);
  lEdit.lblRegistratioForm.Caption := 'Edit Form';
  lEdit.btnSubmitEdit.Caption := 'Edit';
  lEdit.RegisterFormDecider();
  lEdit.cbActivRegister.Visible := True;
  try
    lEdit.ShowModal;
  finally
    lEdit.Free;
  end
end;

procedure TFPhoneBook.btnNewPersoneClick(Sender: TObject);
begin
  smRegisterClick(nil);
end;

procedure TFPhoneBook.DBGrid1CellClick(Column: TColumn);
begin
   PersonID := DBGrid1.DataSource.DataSet.FieldByName('ID').AsInteger;
   FillDetails(PersonID);
end;

procedure TFPhoneBook.DBGrid1KeyDown(Sender: TObject);
begin
    DBGrid1CellClick(nil);
end;

procedure TFPhoneBook.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
     Q.CloseSqlQery();
     CloseAction:= caFree;
end;

procedure TFPhoneBook.FormCreate(Sender: TObject);
begin
  Q:= dmQrySQL;
  QList := Q.SQLQueryList;
  FFilterList := TStringList.Create;
   FFilterList.Clear;
   FFilterAppling := False;
   memSQLlog.Clear;
   Q.GetSQLPersonList();
   DBGrid1CellClick(nil);
   dmConSQL.SQLConn.OnLog := @SQLConnLog;
//   if sqSupportParams in   dmConSQL.SQLConn.ConnOptions then;
end;

procedure TFPhoneBook.FormDestroy(Sender: TObject);
begin
  if Assigned(FRegister) then
   FRegister.Free;
  if Assigned(FFilterList) then
   FFilterList.Free;

  dmConSQL.SQLConn.OnLog := nil;

end;

procedure TFPhoneBook.smRegisterClick(Sender: TObject);
var
   lRegister: TFRegister;
   NewId: Integer;
begin
  lRegister := TFRegister.Create(Self);
  lRegister.lblRegistratioForm.Caption := 'Register Form';
  lRegister.btnSubmitEdit.Caption := 'Submit';
  lRegister.cbActivRegister.Checked:= True;
  lRegister.RegisterFormDecider();
  FillDetails(-1);
  Q.SQLQryReadOnlyDecider(False, Q.dsSQlQryDetails.DataSet);
  lRegister.cbActivRegister.Visible := false;
  try
    lRegister.ShowModal;
  finally
    lRegister.Free;
  end;
end;

procedure TFPhoneBook.SearchTimerTimer(Sender: TObject);
var
  SQLString, Condition: String;
  I : Integer;
begin
  SearchTimer.Enabled:= False;
  SQLString := 'Select top 100 * from Person ';
  Condition:= '';

  for I := 0 To FFilterList.Count -1 do
   if I = 0 then
     Condition:= 'where ' + FFilterList.ValueFromIndex[I]
   else
     Condition:= Condition + ' and ' + FFilterList.ValueFromIndex[I];

  //implementam delay de citire
  if QList.SQL.Text <> SQLString + condition then
  begin
       QList.Close;
       QList.SQL.Text:= SQLString + condition;
       QList.Open;
       DBGrid1CellClick(nil);
  end;
end;

procedure TFPhoneBook.txtSearchChange(Sender: TObject);
begin
 AddFilterToData('FullName', 'like', '''%' + txtSearch.Text + '%''');
end;

procedure TFPhoneBook.FillDetails(Id: Integer);
var Activ: boolean;
    AColor: Tcolor;
begin
  AColor:= clGreen;
  Q.SQLQryDetailsFill(Id);
  Activ := (Q.dsSQLQryDetails.DataSet.FieldByName('Activ').AsInteger = 1);
  lblActiv.Caption:= ifthen(Activ, 'Activ', 'Inactiv');

  If not Activ then AColor := clRed;
    lblActiv.Font.Color:= AColor;
    lblActiv.Layout:= tlCenter;
end;

procedure TFPhoneBook.SQLConnLog(Sender: TSQLConnection;
  EventType: TDBEventType; const Msg: String);
begin
  memSQLlog.Lines.Add( GetEnumName(TypeInfo(TDBEventType),Ord(EventType)) + ' ' +   Msg);
end;

procedure TFPhoneBook.AddFilterToData(AFieldName: String; AOperator: String;
  AValue: String);
var
  lIndex : Integer;
begin
    lIndex := FFilterList.IndexOfName(AFieldName);
   if lIndex = -1 then
   begin
     if AValue <> '' then
       FFilterList.AddPair(AFieldName, AFieldName + ' ' + AOperator + ' ' + AValue);
   end
   else
   begin
     if AValue = '' then
       FFilterList.Delete(lIndex)
     else
       FFilterList.Values[AFieldName] := AFieldName + ' ' + AOperator + ' ' + AValue;
   end;
  SearchTimer.Enabled:= True;
 // SearchTimer(nil);
end;

procedure TFPhoneBook.ControlChangeFilterToData(AControl: String;
  AnEvent: String; AFieldName: String; AOperator: String; AValue: String);
var
   I : Integer;
begin
//  TCustomEdit
//  TButtonControl
   for I := 0 to Self.ComponentCount - 1 do
    if AnsiCompareStr(Components[I].Name, AControl) = 1 then
    begin
      if Components[I] is TCustomCheckBox then
        TCustomCheckBox(Components[I]).OnChange:= @FormAddFilterToData;
    end
end;

procedure TFPhoneBook.FormAddFilterToData(Sender: TObject);
begin
  //
  //AddFilterToData();
end;


end.

