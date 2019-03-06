unit WispDefaultValue;

interface

uses
  Classes;

type
  // Abstract
  TWispDefaultValue = Class(TObject)
  public
    Constructor Create; Overload;
  End;

  // Simple variant default value
  TWispDVSimple = Class(TWispDefaultValue)
  private
    FValue: String;
  public
    Property Value : String Read FValue Write FValue;
  End;

  // Get the current ENTITY_ID
  TWispDVEntityId = Class(TWispDefaultValue)
  private
    // FValue : Variant;
  public
    // Property Value : String Read FValue Write FValue;
  End;

  // Get current Date
  TWispDVCurrentDate = Class(TWispDefaultValue)
  private
    // FValue : Variant;
  public
    // Property Value : String Read FValue Write FValue;
  End;

  // Get current time
  TWispDVCurrentTime = Class(TWispDefaultValue)
  private
    // FValue : Variant;
  public
    // Property Value : String Read FValue Write FValue;
  End;

implementation

uses

  WispEntityManager;

// =============================================================================
Constructor TWispDefaultValue.Create;
begin
  inherited Create;
  LastHandledDV := Self;
end;

end.
