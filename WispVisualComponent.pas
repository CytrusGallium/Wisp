unit WispVisualComponent;

interface

uses
  Controls,
  Classes;

type
  TWispVisualComponent = Class(TObject)
  Private
    FLinkedEpName : String;
  public
    Property LinkedEpName : String Read FLinkedEpName Write FLinkedEpName;
    Constructor Create;
  End;

implementation

Constructor TWispVisualComponent.Create;
begin
  Inherited Create;
end;

end.
