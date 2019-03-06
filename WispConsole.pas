unit WispConsole;

interface

uses
  Dialogs,
  Forms,
  StdCtrls,
  ExtCtrls,
  Graphics,
  Controls,
  Classes,
  SysUtils,
  cxTextEdit,
  cxButtons,
  WispEditBox,
  WispDatePicker,
  WispEntity,
  WispArrayTools,
  WispEntityManager,
  WispQueryTools,
  WispDbConnection,
  WispTimeTools,
  WispViewTools,
  WispStrTools,
  CxGrid,
  CxGridLevel,
  CxGridTableView,
  CxGridDbTableView,
  CxStyles,
  CxGridCustomTableView,
  CxMemo;

type
  TWispConsole = Class(TObject)
  private
    FormEntityGrid: TForm;
    Memo: TCxMemo;
  protected
  public
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl);
    procedure Echo(ParamText : String);
  end;

var
  Global_Singleton_Console: TWispConsole;

implementation

// =============================================================================
procedure TWispConsole.Echo(ParamText : String);
begin
  if Global_Singleton_Console <> nil then
  begin
    Memo.Text := Memo.Text + ParamText + sLineBreak;
  end
end;

// =============================================================================
Constructor TWispConsole.Create(ParamOwner: TComponent; ParamParent: TWinControl);
begin
  // Singleton
  if Global_Singleton_Console <> nil then
  begin
    // Lets try ...
    Self := Global_Singleton_Console;
  end
  else
  begin
    inherited Create;
    Global_Singleton_Console := Self;
  end;

  // Create the entity grid form
  FormEntityGrid := TForm.Create(ParamOwner);
  with FormEntityGrid do
  begin
    BorderStyle := bsNone;
    Color := clGray;
    Parent := ParamParent;
    Align := alClient;
  end;

  // Create the memo used as read only console
  Memo := TcxMemo.Create(ParamOwner);
  With Memo do
  begin
    Parent := FormEntityGrid;
    Align := alClient;
    ParentColor := FALSE;
    Style.Font.Name := 'Courrier';
    Style.Font.Color := clGreen;
    Style.Color := clBlack;
    Properties.ReadOnly := TRUE;
  end;

  FormEntityGrid.Show;
end;

end.
