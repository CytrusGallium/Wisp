unit WispQueryFilter;

interface

uses
  Classes;

type
  // Abstract
  TWispFilter = Class(TObject);

  // Simple filter, where a field equal a certain value
  TWispFieldFilter = Class(TWispFilter)
  private
    FSourceFiledName : String;
    FSearchFor : String;
  public
    Property SourceFiledName : String Read FSourceFiledName Write FSourceFiledName;
    Property SearchFor : String Read FSearchFor Write FSearchFor;
  End;

implementation

end.
