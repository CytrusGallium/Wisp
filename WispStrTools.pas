unit WispStrTools;

interface

uses
  Dialogs,
  SysUtils;

type

  TArrayOfString = array of String;

  TMatchingRate = Record
    OrderRate: Real;
    CharactersRate: Real;
    SoundexRate: Real;
    Rate: Real;
  end;

function StrToNumbers(Mixed: string): string;
function GetOrderSimilarity(Input, Searchable: string): Real;
function GetCharactersSimilarity(Input, Searchable: string): Real;
function SteveSoundex(sName: string): string;
function GetMatchingRate(Input, Searchable: String): Real;
function GetMatchingRateAdvanced(Input, Searchable: String;
  CaseSens, SameIfSoundexMatch: Boolean; SoundexCoef, OrderCoef,
  CharCoef: Integer): TMatchingRate;
function MultiWordSoundex(Input, Searchable: String): Real;
function GetBestMatchFromArray(Input: String;
  Searchable: Array of String): Integer;
function WispStringSplit(Splitable, Separator: String): TArrayOfString;
function CharDoubler(ParamString, ParamChar: String): String;
function ConditionalString(ParamBoolean: Boolean; ParamString: String): String;
function BooleanToString(ParamBool: Boolean): String;
Function PushStringArray(Var ParamStringArray: TArrayOfString;
  Const ParamString: String): Integer;
Function CheckIfArrayContainString(ParamStringArray: TArrayOfString;
  ParamString: String): Boolean;

function SplitString(const aSeparator, aString: String; aMax: Integer = 0)
  : TArrayOfString; // Deprecated !

implementation

// =============================================================================
// String Filtring Function (Return Numbers and remove anything else)

function StrToNumbers(Mixed: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Length(Mixed) do
  begin
    if (Mixed[i] = '0') then
      Result := Result + Mixed[i]

    else if (Mixed[i] = '1') then
      Result := Result + Mixed[i]

    else if (Mixed[i] = '2') then
      Result := Result + Mixed[i]

    else if (Mixed[i] = '3') then
      Result := Result + Mixed[i]

    else if (Mixed[i] = '4') then
      Result := Result + Mixed[i]

    else if (Mixed[i] = '5') then
      Result := Result + Mixed[i]

    else if (Mixed[i] = '6') then
      Result := Result + Mixed[i]

    else if (Mixed[i] = '7') then
      Result := Result + Mixed[i]

    else if (Mixed[i] = '8') then
      Result := Result + Mixed[i]

    else if (Mixed[i] = '9') then
      Result := Result + Mixed[i];

  end;
end;

// =============================================================================
// String Spliting Function (Deprecated !)

function SplitString(const aSeparator, aString: String; aMax: Integer = 0)
  : TArrayOfString;
var
  i, strt, cnt: Integer;
  sepLen: Integer;

  procedure AddString(aEnd: Integer = -1);
  var
    endPos: Integer;
  begin
    if (aEnd = -1) then
      endPos := i
    else
      endPos := aEnd + 1;

    if (strt < endPos) then
      Result[cnt] := Copy(aString, strt, endPos - strt)
    else
      Result[cnt] := '';

    Inc(cnt);
  end;

begin
  if (aString = '') or (aMax < 0) then
  begin
    SetLength(Result, 0);
    EXIT;
  end;

  if (aSeparator = '') then
  begin
    SetLength(Result, 1);
    Result[0] := aString;
    EXIT;
  end;

  sepLen := Length(aSeparator);
  SetLength(Result, (Length(aString) div sepLen) + 1);

  i := 1;
  strt := i;
  cnt := 0;
  while (i <= (Length(aString) - sepLen + 1)) do
  begin
    if (aString[i] = aSeparator[1]) then
      if (Copy(aString, i, sepLen) = aSeparator) then
      begin
        AddString;

        if (cnt = aMax) then
        begin
          SetLength(Result, cnt);
          EXIT;
        end;

        Inc(i, sepLen - 1);
        strt := i + 1;
      end;

    Inc(i);
  end;

  AddString(Length(aString));

  // here we should check for empty strings in the array and remove them from the array
  // and thats why this function is deprecated

  SetLength(Result, cnt);

end;

// =============================================================================
// Gets how correctly a string is ordered in another string

function GetOrderSimilarity(Input, Searchable: string): Real;
Var
  InputLength, SearchableLength, i, j, k, InputCharPos, SimilarityPos, OffSet,
    TempInt: Integer;
  InputCharValue, S, TempS: string;
  SimilarityArray: array of Integer;
  OneCharValue, OrderSimilarityRate: Real;
begin

  if (Length(Input) = 0) and (Length(Searchable) = 0) then
  begin
    Result := 100;
    EXIT;
  end;

  if (Length(Input) = 0) or (Length(Searchable) = 0) then
  begin
    Result := 0;
    EXIT;
  end;

  if Length(Input) > Length(Searchable) then
  begin
    TempS := Searchable;
    Searchable := Input;
    Input := TempS;
    TempS := '';
  end;

  // Initialization of variables
  InputLength := Length(Input);
  SearchableLength := Length(Searchable);
  OffSet := 0;
  i := 1;

  // This array is one cell longer to avoid an "end of array" bug
  SetLength(SimilarityArray, InputLength + 1);

  OneCharValue := 100 / InputLength;
  // ==========================
  for i := 1 to InputLength do
  begin
    InputCharPos := i;
    SimilarityPos := 0;
    InputCharValue := Input[i];
    j := 1;
    for j := InputCharPos + OffSet to SearchableLength do
    begin
      if InputCharValue = Searchable[j] then
      begin
        SimilarityArray[i] := SimilarityPos;
        OffSet := OffSet + SimilarityPos;
        Break;
      end
      else
        SimilarityPos := SimilarityPos + 1;
      if j = SearchableLength then
      begin
        SimilarityArray[i] := (-1);
      end;
    end;
  end;
  // ==========================
  S := '';
  for k := 1 to Length(SimilarityArray) do
  begin
    TempInt := SimilarityArray[k];
    S := S + IntToStr(TempInt);
  end;
  // ==========================
  OrderSimilarityRate := 0;
  for i := 1 to Length(SimilarityArray) - 1 do
  begin
    TempInt := SimilarityArray[i];
    if TempInt = 0 then
    begin
      OrderSimilarityRate := OrderSimilarityRate + OneCharValue;
      Result := OrderSimilarityRate;
    end;
  end;
end;

// =============================================================================
function GetCharactersSimilarity(Input, Searchable: string): Real;
Var
  InputLength, SearchableLength, i, j, L1, L2: Integer;
  S1, S2: string;
begin
  // Initialization of variables
  InputLength := Length(Input);
  SearchableLength := Length(Searchable);
  S1 := Input;
  S2 := Searchable;
  L1 := Length(Input);
  L2 := Length(Searchable);

  if (L1 = 0) and (L2 = 0) then
  begin
    Result := 100;
    EXIT;
  end;

  if (L1 = 0) xor (L2 = 0) then
  begin
    Result := 0;
    EXIT;
  end;

  i := 1;
  j := 1;

  while i <= L1 do
  begin
    for j := 1 to L2 do
    begin
      if S1[i] = S2[j] then
      begin
        Delete(S1, i, 1);
        Delete(S2, j, 1);
        L1 := Length(S1);
        L2 := Length(S2);
        Break;
      end
      else if j = L2 then
        i := i + 1;
    end;
    // ShowMessage(S1+'/'+S2);
  end;

  Result := 100 - ((Length(S1) + Length(S2)) /
    (Length(Input) + Length(Searchable))) * 100;
end;

// =============================================================================
// By : Steve Peacocke
// Website : stevepeacocke.blogspot.com
// Soundex is also available in MySQL via a query

function SteveSoundex(sName: string): string;
var
  Ch, LastCh: Char;
  i: Integer;
  sx: string;
begin
  sName := UpperCase(trim(sName));
  if Length(sName) < 1 then
    sx := '' // got nothing, send nothing back
  else
  begin
    LastCh := #0;
    for i := 1 to Length(sName) do
    begin // step through each character in the name
      if i = 1 then
        sx := sName[1] // store the first character
      else
      begin
        Ch := #0;
        if sName[i] <> LastCh then
        begin
          case sName[i] of
            'B', 'F', 'P', 'V':
              Ch := '1';
            'C', 'G', 'J', 'K', 'Q', 'S', 'X', 'Z':
              Ch := '2';
            'D', 'T':
              Ch := '3';
            'L':
              Ch := '4';
            'M', 'N':
              Ch := '5';
            'R':
              Ch := '6';
            // Note no ELSE - ignore all other letters
          end;
          if Ch <> #0 then
            sx := sx + Ch;
          if Length(sx) > 3 then
            Break; // we got all we need
        end;
      end;
      LastCh := sName[i];
    end;
    while Length(sx) < 4 do
      sx := sx + '0'; // pad out remaining with zero
  end;
  Result := sx;
end;

// =============================================================================
function GetMatchingRate(Input, Searchable: String): Real;
Var
  OrderRate, CharactersRate, SoundexRate: Real;
begin

  Input := AnsiLowerCase(Input);
  Searchable := AnsiLowerCase(Searchable);

  OrderRate := GetOrderSimilarity(Input, Searchable);
  CharactersRate := GetCharactersSimilarity(Input, Searchable);
  if SteveSoundex(Input) = SteveSoundex(Searchable) then
    SoundexRate := 100
  else
    SoundexRate := 0;

  Result := (OrderRate + CharactersRate + SoundexRate) / 3;

end;

// =============================================================================
function GetMatchingRateAdvanced(Input, Searchable: String;
  CaseSens, SameIfSoundexMatch: Boolean; SoundexCoef, OrderCoef,
  CharCoef: Integer): TMatchingRate;
Var
  OrderRate, CharactersRate, SoundexRate, TmpReal: Real;
  CoefSum: Integer;
  Results: TMatchingRate;
begin

  if Not(CaseSens) then
  begin
    Input := AnsiLowerCase(Input);
    Searchable := AnsiLowerCase(Searchable);
  end;

  TmpReal := { 100; } MultiWordSoundex(Input, Searchable);

  if TmpReal = 100 then
  begin

    if SameIfSoundexMatch then
    begin
      Result.Rate := 100;
      EXIT;
    end;
  end
  else
    SoundexRate := TmpReal;

  OrderRate := GetOrderSimilarity(Input, Searchable);
  CharactersRate := GetCharactersSimilarity(Input, Searchable);

  Results.OrderRate := OrderRate;
  Results.CharactersRate := CharactersRate;
  Results.SoundexRate := SoundexRate;

  CoefSum := OrderCoef + CharCoef + SoundexCoef;

  Results.Rate := ((OrderRate * OrderCoef) + (CharactersRate * CharCoef) +
    (SoundexRate * SoundexCoef)

    ) / CoefSum;
  Result := Results;

end;

// =============================================================================
function MultiWordSoundex(Input, Searchable: String): Real;
Var
  S: String;
  InputLength, SearchableLength, aInputWordsLength,
    aSearchableWordsLength: Integer;
  aInputWords, aSearchableWords: TArrayOfString;
  OneCharValue: Real;
  i: Integer;
  aInputSoundexMatcher: Array of Integer;
begin

  InputLength := Length(Input);
  SearchableLength := Length(Searchable);

  if (InputLength <= 0) or (SearchableLength <= 0) then
  begin
    Result := 0;
    EXIT;
  end;

  if InputLength > SearchableLength then
  begin
    S := Input;
    Input := Searchable;
    Searchable := S;
  end;

  aInputWords := WispStringSplit(Input, ' ');
  aSearchableWords := WispStringSplit(Searchable, ' ');

  if aSearchableWords[Length(aSearchableWords) - 1] = '' then
  begin
    SetLength(aSearchableWords, Length(aSearchableWords) - 1);
  end;

  aInputWordsLength := Length(aInputWords);
  aSearchableWordsLength := Length(aSearchableWords);
  SetLength(aInputSoundexMatcher, aInputWordsLength);

  OneCharValue := 100 / aSearchableWordsLength;

  for i := 0 to Length(aInputSoundexMatcher) - 1 do
    aInputSoundexMatcher[i] := -1;

  for i := 0 to aInputWordsLength - 1 do
  begin
    aInputWords[i] := SteveSoundex(aInputWords[i]);
  end;

  for i := 0 to aSearchableWordsLength - 1 do
  begin
    aSearchableWords[i] := SteveSoundex(aSearchableWords[i]);
  end;

  for i := 0 to aInputWordsLength - 1 do
  begin
    aInputSoundexMatcher[i] := GetBestMatchFromArray(aInputWords[i],
      aSearchableWords);
  end;

  Result := 0;

  for i := 0 to Length(aInputSoundexMatcher) - 1 do
  begin
    if aInputSoundexMatcher[i] >= 0 then
    begin
      Result := Result + OneCharValue;
    end;

  end;

end;

// =============================================================================
function GetBestMatchFromArray(Input: String;
  Searchable: Array of String): Integer;
Var
  SearchableLength, BestRatePos, i: Integer;
  BestRate, TmpRate: Real;
begin

  SearchableLength := Length(Searchable);

  if SearchableLength <= 0 then
  begin
    Result := -1;
    EXIT;
  end;

  BestRatePos := 0;
  BestRate := 0;

  for i := 0 to SearchableLength - 1 do
  begin
    TmpRate := (GetOrderSimilarity(Input, Searchable[i]) +
      GetCharactersSimilarity(Input, Searchable[i])) / 2;

    if TmpRate > BestRate then
    begin
      BestRate := TmpRate;
      BestRatePos := i;
    end;

  end;

  if BestRate >= 87.5 then
    Result := BestRatePos
  else
    Result := -1;

end;

// =============================================================================
function WispStringSplit(Splitable, Separator: String): TArrayOfString;
Var
  aResults: TArrayOfString;
  i, ActualWritingPosition: Integer;
begin

  if Splitable = '' then
  begin
    SetLength(Result, 0);
    EXIT;
  end;

  if Separator = '' then
  begin
    SetLength(Result, 1);
    Result[0] := Splitable;
    EXIT;
  end;

  SetLength(aResults, 1);
  aResults[Length(aResults) - 1] := '';

  for i := 1 to Length(Splitable) do
  begin
    if Splitable[i] <> Separator then
    begin
      aResults[Length(aResults) - 1] := aResults[Length(aResults) - 1] +
        Splitable[i];
    end
    else if (Splitable[i] = Separator) and (Splitable[i + 1] <> Separator) then
    begin
      SetLength(aResults, Length(aResults) + 1);
      aResults[Length(aResults) - 1] := '';
    end;

  end;

  Result := aResults;

end;

// =============================================================================
function ConditionalString(ParamBoolean: Boolean; ParamString: String): String;
begin
  if ParamBoolean = FALSE then
    Result := ''
  else
    Result := ParamString;
end;

// =============================================================================
// Doubles every ParamChar in ParamString
function CharDoubler(ParamString, ParamChar: String): String;
Var
  A: TArrayOfString;
  i: Integer;
  TmpS: String;
begin
  if (ParamString = '') or (ParamChar = '') then
  begin
    Result := '';
    EXIT;
  end;

  A := WispStringSplit(ParamString, ParamChar);
  for i := 0 to Length(A) - 1 do
  begin
    if i < Length(A) - 1 then
      TmpS := TmpS + A[i] + ParamChar + ParamChar
    else
      TmpS := TmpS + A[i];
  end;

  Result := TmpS;

end;

// =============================================================================
function BooleanToString(ParamBool: Boolean): String;
begin
  if ParamBool = TRUE then
    Result := 'TRUE'
  else
    Result := 'FALSE';
end;

// =============================================================================
Function CheckIfArrayContainString(ParamStringArray: TArrayOfString;
  ParamString: String): Boolean;
Var
  i, L: Integer;
begin
  L := Length(ParamStringArray);

  if L = 0 then
  begin
    Result := FALSE;
    EXIT;
  end;

  for i := 0 to L - 1 do
  begin
    if ParamStringArray[i] = ParamString then
    begin
      Result := TRUE;
      EXIT;
    end;
  end;

end;

// =============================================================================
// Add a string to the array and return the index of the added string
Function PushStringArray(Var ParamStringArray: TArrayOfString;
  Const ParamString: String): Integer;
Var
  L: Integer;
begin

  L := Length(ParamStringArray);

  SetLength(ParamStringArray, L + 1);
  ParamStringArray[L] := ParamString;

end;

end.
