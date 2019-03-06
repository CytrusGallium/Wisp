unit WispMathTools;

interface

uses
  SysUtils,
  Variants;

Function ReverseOperator(ParamOperator: String): string;
function GetBooleanOf(X: variant): Boolean;

implementation

// =============================================================================
Function ReverseOperator(ParamOperator: String): string;
begin
  if (ParamOperator = '+') or (ParamOperator = '-') or (ParamOperator = '*') or
    (ParamOperator = '/') then
  begin

    if ParamOperator = '+' then
    begin
      Result := '-';
      EXIT;
    end;

    if ParamOperator = '-' then
    begin
      Result := '+';
      EXIT;
    end;

    if ParamOperator = '*' then
    begin
      Result := '/';
      EXIT;
    end;

    if ParamOperator = '/' then
    begin
      Result := '*';
      EXIT;
    end;

  end
  else
    Result := '';
end;

// ==============================================================================
// Get Boolean from Integer or String
// Boolean = 11
// Integer = 3
// String = 258
function GetBooleanOf(X: variant): Boolean;
Var
  Totv: Word; // Type of the variant
  TempB: Boolean;
  TempI: Integer;
  TempS: String;
begin
  Totv := VarType(X);
  // ShowMessage(IntToStr(VarType(X))); Leave this showmessage here to display the ID of the variant
  if Totv = 11 then
  begin
    Result := X;
  end
  else if Totv = 3 then
  begin
    TempI := X;
    if TempI > 0 then
      Result := TRUE
    else if TempI = 0 then
      Result := FALSE;
  end
  else if Totv = 258 then
  begin
    TempS := X;
    if (TempS = 'TRUE') or (TempS = '1') then
      Result := TRUE
    else if (TempS = 'FALSE') or (TempS = '0') then
      Result := FALSE
    else
      Result := FALSE;
  end;

end;

end.
