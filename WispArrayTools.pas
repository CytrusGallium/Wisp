unit WispArrayTools;

interface

type

  TObjectArray = array of TObject;
procedure ResizeObjectArray(var ParamArray: TObjectArray; Size: integer);
Function PushArray(var ParamArray: TObjectArray) : Integer;

implementation

// =============================================================================
Procedure ResizeObjectArray(var ParamArray: TObjectArray; Size: integer);
begin
  SetLength(ParamArray, Size);
end;

// =============================================================================
Function PushArray(var ParamArray: TObjectArray) : Integer;
begin
  SetLength(ParamArray, Length(ParamArray) + 1);
  Result := Length(ParamArray) - 1; // Return the index of the last element and not the length of the array
end;

end.
