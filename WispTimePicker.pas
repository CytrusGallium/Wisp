unit WispTimePicker;

interface

uses
  cxTimeEdit,
  cxLabel,
  Controls,
  Classes,
  WispVisualComponent,
  WispStyleManager;

type
  TWispTimePicker = Class(TWispVisualComponent)
  private
    Spacing: integer;
  public
    Lbl: TcxLabel;
    TimeBox: TcxTimeEdit;
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl;
      ParamEdtWidth, ParamX, ParamY: integer; ParamCaption: String);
    procedure CenterHorizontally;
  End;

implementation

// =============================================================================
Constructor TWispTimePicker.Create(ParamOwner: TComponent;
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

  TimeBox := TcxTimeEdit.Create(ParamOwner);
  with TimeBox do
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
procedure TWispTimePicker.CenterHorizontally;
Var
  TmpInt: integer;
begin
  TmpInt := Round((TimeBox.Parent.Width - TimeBox.Width) / 2);
  Lbl.Left := TmpInt;
  TimeBox.Left := TmpInt;
end;

end.
