unit WispDistanceTools;

interface

type
  TDistanceCalculator = Class(TObject)
    private
      ParentHeigth : integer;
      ParentWidth : integer;
    public
      Constructor Create(ParamParentHeigth, ParamParentWidth : Integer);
      Function WidthPercentToDist(ParamPercentage : Integer) : Integer;
      Function HeigthPercentToDist(ParamPercentage : Integer) : Integer;
  End;

implementation

// =============================================================================
Constructor TDistanceCalculator.Create(ParamParentHeigth: Integer; ParamParentWidth: Integer);
begin
  ParentHeigth := ParamParentHeigth;
  ParentWidth := ParamParentWidth;
end;

// =============================================================================
Function TDistanceCalculator.HeigthPercentToDist(ParamPercentage: Integer) : Integer;
begin
  Result := (ParentHeigth * ParamPercentage) div 100;
end;

// =============================================================================
Function TDistanceCalculator.WidthPercentToDist(ParamPercentage: Integer) : Integer;
begin
  Result := (ParentWidth * ParamPercentage) div 100;
end;

end.
