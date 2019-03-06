unit WispTabSheet;

interface

uses
  cxPC, Forms, Messages, Controls;

type

  TWispColumnDistanceCalculator = Class(TObject)
  Private
    FColumnCount: Integer;
    aColumnOffset: array of Integer; // Store Y offset of each column
    aColumnXPos: array of Integer; // Store X offset of each column
    FCurrentColumn: Integer; // Current column where we will draw
    FColSize: Integer; // Size of each column
  Public
    Constructor Create(ParamColumnCount, ParamComponentWidth, ParamParentWidth
      : Integer);
    Function GetCurrentX(): Integer;
    Function GetCurrentY(): Integer;
    Function GetNextColumn(): Integer;
    Function PushY(ParamAmount: Integer): Integer;
    Function GetMaxY(): Integer;
  End;

  TWispTabSheet = Class(TcxTabSheet)
  private
    FScrollBox: TScrollBox;
    FDistanceCalculator: TWispColumnDistanceCalculator;
  public
    Property ScrollBox: TScrollBox Read FScrollBox Write FScrollBox;
    Property DistanceCalculator: TWispColumnDistanceCalculator
      Read FDistanceCalculator Write FDistanceCalculator;
  End;

implementation

// =============================================================================
Constructor TWispColumnDistanceCalculator.Create(ParamColumnCount,
  ParamComponentWidth, ParamParentWidth: Integer);
Var
  I: Integer;
begin
  FColumnCount := ParamColumnCount;

  // Calculate the size of each column
  FColSize := Round(ParamParentWidth / ParamColumnCount) - 16;

  // Initialize the columns offset and x positions array
  SetLength(aColumnOffset, ParamColumnCount);
  for I := 0 to Length(aColumnOffset) - 1 do
  begin
    aColumnOffset[I] := 16;
  end;

  SetLength(aColumnXPos, ParamColumnCount);
  for I := 0 to Length(aColumnXPos) - 1 do
  begin
    aColumnXPos[I] := (FColSize * I) +
      Round((FColSize - ParamComponentWidth) / 2);
  end;

  // Current column
  FCurrentColumn := 0;
end;

// =============================================================================
Function TWispColumnDistanceCalculator.GetCurrentX(): Integer;
begin
  Result := aColumnXPos[FCurrentColumn];
end;

// =============================================================================
Function TWispColumnDistanceCalculator.GetCurrentY(): Integer;
begin
  Result := aColumnOffset[FCurrentColumn];
end;

// =============================================================================
Function TWispColumnDistanceCalculator.GetNextColumn(): Integer;
begin
  FCurrentColumn := FCurrentColumn + 1;
  if FCurrentColumn > FColumnCount - 1 then
    FCurrentColumn := 0;

  Result := FCurrentColumn;
end;

// =============================================================================
Function TWispColumnDistanceCalculator.PushY(ParamAmount: Integer): Integer;
begin
  aColumnOffset[FCurrentColumn] := aColumnOffset[FCurrentColumn] + ParamAmount;
end;

// =============================================================================
// Get highest
Function TWispColumnDistanceCalculator.GetMaxY(): Integer;
Var
  I, TmpI: Integer;
begin
  TmpI := 0;

  for I := 0 to Length(aColumnOffset) - 1 do
  begin
    if aColumnOffset[I] > TmpI then
      TmpI := aColumnOffset[I];
  end;

  Result := TmpI;
end;

end.
