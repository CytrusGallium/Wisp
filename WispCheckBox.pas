unit WispCheckBox;

interface

uses
  cxCheckBox,
  cxLabel,
  Controls,
  Classes,
  WispVisualComponent,
  WispStyleManager;

type
  TWispCheckBox = Class(TWispVisualComponent)
  private
    Spacing: integer;
  public
    Lbl: TcxLabel;
    ChkBox: TcxCheckBox;
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl;
      ParamEdtWidth, ParamX, ParamY: integer; ParamCaption: String);
    procedure CenterHorizontally;
  End;

implementation

Constructor TWispCheckBox.Create(ParamOwner: TComponent;
  ParamParent: TWinControl; ParamEdtWidth, ParamX, ParamY: integer;
  ParamCaption: String);

  begin
    ChkBox := TcxCheckBox.Create(ParamOwner);
    with ChkBox do
    begin
      Width := ParamEdtWidth;
      Height := 32;
      Parent := ParamParent;
      ParentFont := FALSE;
      Caption := ParamCaption;
      Left := ParamX;
      Top := ParamY + Spacing;
      Transparent := TRUE;
      Style.TextColor := Global_Singleton_Style.TextColor;
      Style.Font.Name := Global_Singleton_Style.DefaultFont;
    end;
end;

procedure TWispCheckBox.CenterHorizontally;
Var TmpInt : integer;
begin
  TmpInt := Round((ChkBox.Parent.Width - ChkBox.Width)/2);
  ChkBox.Left :=  TmpInt;
end;

end.
