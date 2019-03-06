unit WispDatePicker;

interface

uses
  cxTextEdit,
  cxCalendar,
  cxLabel,
  Controls,
  Classes,
  WispVisualComponent,
  WispStyleManager;

type
  TWispDatePicker = Class(TWispVisualComponent)
  private
    Spacing: integer;
  public
    Lbl: TcxLabel;
    DateBox: TcxDateEdit;
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl;
      ParamEdtWidth, ParamX, ParamY: integer; ParamCaption: String);
    procedure CenterHorizontally;
  End;

implementation

// =============================================================================
Constructor TWispDatePicker.Create(ParamOwner: TComponent;
  ParamParent: TWinControl; ParamEdtWidth, ParamX, ParamY: integer;
  ParamCaption: String);

begin
  Lbl := TcxLabel.Create(ParamOwner);
  with Lbl do
  begin
    Height := 16;
    Width := ParamEdtWidth;
    Parent := ParamParent;
    ParentFont := FALSE;
    Caption := ParamCaption;
    Left := ParamX;
    Top := ParamY;
    Transparent := TRUE;
    Style.TextColor := Global_Singleton_Style.TextColor;
    Style.Font.Name := Global_Singleton_Style.DefaultFont;
  end;

  DateBox := TcxDateEdit.Create(ParamOwner);
  with DateBox do
  begin
    Width := ParamEdtWidth;
    Height := 32;
    Parent := ParamParent;
    ParentFont := FALSE;
    Text := '';
    Left := ParamX;
    Top := ParamY + Lbl.Height + Spacing;
    Style.Font.Name := Global_Singleton_Style.DefaultFont;
  end;
end;

// =============================================================================
procedure TWispDatePicker.CenterHorizontally;
Var
  TmpInt: integer;
begin
  TmpInt := Round((DateBox.Parent.Width - DateBox.Width) / 2);
  Lbl.Left := TmpInt;
  DateBox.Left := TmpInt;
end;

end.
