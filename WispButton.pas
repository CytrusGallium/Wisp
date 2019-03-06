unit WispButton;

interface

uses
  cxButtons,
  Controls,
  Classes,
  WispVisualComponent,
  WispStyleManager,
  Graphics;

type
  TWispButton = Class(TcxButton)
  private
    FCommandString: String;
  public
    Property CommandString: String Read FCommandString Write FCommandString;
    constructor Create(AOwner: TComponent); override;
    Procedure CenterHorizontally;
    Procedure CenterVertically;
  End;

implementation

// =============================================================================
constructor TWispButton.Create(AOwner: TComponent);
begin
  inherited;
  LookAndFeel.NativeStyle := FALSE;
  ParentFont := FALSE;

  // Text colors
  Colors.DefaultText := Global_Singleton_Style.TextColor;
  Colors.NormalText := Global_Singleton_Style.TextColor;
  Colors.HotText := Global_Singleton_Style.TextColor;
  Colors.PressedText := Global_Singleton_Style.HighlightTextColor;
  Colors.DisabledText := Global_Singleton_Style.QuietTextColor;

  // BG Colors
  Colors.Default := Global_Singleton_Style.BtnBgColor;
  Colors.Normal := Global_Singleton_Style.BtnBgColor;
  Colors.Hot := Global_Singleton_Style.BtnBgColor;
  Colors.Pressed := Global_Singleton_Style.BtnBgColor;
end;

// =============================================================================
Procedure TWispButton.CenterHorizontally;
begin
  Left := Round((Parent.Width - Width) / 2)
end;

// =============================================================================
Procedure TWispButton.CenterVertically;
begin
  Top := Round((Parent.Height - Height) / 2)
end;

end.
