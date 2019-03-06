unit WispPopupMenu;

interface

uses
  Menus,
  Controls,
  Classes,
  WispVisualComponent;

type
  TWispMenuItem = Class(TMenuItem)
  private
    FCommandString : String;
  public
    Property CommandString : String Read FCommandString Write FCommandString;
  End;

implementation

end.
