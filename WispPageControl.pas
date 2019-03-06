unit WispPageControl;

interface

uses
  cxPC, Messages, Controls, Forms, WispTabSheet, WispImageTools;

const
  WM_KILLTAB = WM_USER + 1;

type
  TWispTabInfo = record
    TabType: String;
    TabName: String;
    TabId: String;
  end;

  TWispPageControl = Class(TcxPageControl)
  private
    aTabType: array of string;
    aTabName: array of string;
    aTabId: array of string;
    aTab: array of TcxTabSheet;
    aParentObject: array of TObject;
  public
    function RegisterTab(ParamType: string; ParamName: string; ParamId: string;
      ParamTab: TcxTabSheet; ParamParentObject: TObject): Boolean;
    function UnRegisterTab(ParamType: string; ParamName: string;
      ParamId: string): Boolean; overload;
    function UnRegisterTab(ParamTab: TcxTabSheet): Boolean; overload;
    function CheckIfTabExists(ParamType: string; ParamName: string;
      ParamId: string): TcxTabSheet;
    function GetParentObject(ParamType: string; ParamName: string;
      ParamId: string): TObject;
    procedure KillTab(var message: TMessage); message WM_KILLTAB;
    function GetTabInfo(ParamTab: TcxTabSheet): TWispTabInfo;
    Function GetTabFromCaption(ParamTabCaption: String): TcxTabSheet;
    Function AddScrollBoxTab(ParamTabCaption: String;
      ParamColumnCount, ParamComponentWidth: Integer): TWispTabSheet;
  End;

implementation

// ==============================================================================
function TWispPageControl.RegisterTab(ParamType: string; ParamName: string;
  ParamId: string; ParamTab: TcxTabSheet; ParamParentObject: TObject): Boolean;
begin
  SetLength(aTabType, Length(aTabType) + 1);
  aTabType[Length(aTabType) - 1] := ParamType;

  SetLength(aTabName, Length(aTabName) + 1);
  aTabName[Length(aTabName) - 1] := ParamName;

  SetLength(aTabId, Length(aTabId) + 1);
  aTabId[Length(aTabId) - 1] := ParamId;

  SetLength(aTab, Length(aTab) + 1);
  aTab[Length(aTab) - 1] := ParamTab;

  SetLength(aParentObject, Length(aParentObject) + 1);
  aParentObject[Length(aParentObject) - 1] := ParamParentObject;
end;

// ==============================================================================
function TWispPageControl.CheckIfTabExists(ParamType: string; ParamName: string;
  ParamId: string): TcxTabSheet;
Var
  I, ArrayLength: Integer;
begin

  ArrayLength := Length(aTabType);

  if Length(aTabType) = 0 then
  begin
    Result := nil;
  end
  else
  begin

    for I := 0 to ArrayLength - 1 do
    begin
      if aTabType[I] = ParamType then
      begin
        if aTabName[I] = ParamName then
        begin
          if aTabId[I] = ParamId then
          begin
            Result := aTab[I];
            EXIT;
          end;
        end;
      end;
    end;

    Result := nil;

  end;

end;

// ==============================================================================
function TWispPageControl.GetParentObject(ParamType: string; ParamName: string;
  ParamId: string): TObject;
Var
  I, ArrayLength: Integer;
begin

  ArrayLength := Length(aTabType);

  if Length(aTabType) = 0 then
  begin
    Result := nil;
  end
  else
  begin

    for I := 0 to ArrayLength - 1 do
    begin
      if aTabType[I] = ParamType then
      begin
        if aTabName[I] = ParamName then
        begin
          if aTabId[I] = ParamId then
          begin
            Result := aParentObject[I];
            EXIT;
          end;
        end;
      end;
    end;

    Result := nil;

  end;

end;

// =============================================================================
procedure TWispPageControl.KillTab(var message: TMessage);
var
  control: TcxTabSheet;
begin
  Pages[message.LParam].Free;
end;

// =============================================================================
function TWispPageControl.UnRegisterTab(ParamType: string; ParamName: string;
  ParamId: string): Boolean;
Var
  I, ArrayLength, LastIndex: Integer;
begin

  ArrayLength := Length(aTabType);
  LastIndex := ArrayLength - 1;

  if ArrayLength = 0 then
  begin
    Result := FALSE;
  end
  else
  begin

    for I := 0 to LastIndex do
    begin
      if aTabType[I] = ParamType then
      begin
        if aTabName[I] = ParamName then
        begin
          if aTabId[I] = ParamId then
          begin
            aTabType[I] := aTabType[LastIndex];
            aTabName[I] := aTabName[LastIndex];
            aTabId[I] := aTabId[LastIndex];
            aTab[I] := aTab[LastIndex];
            aParentObject[I] := aParentObject[LastIndex];

            SetLength(aTabType, LastIndex);
            SetLength(aTabName, LastIndex);
            SetLength(aTabId, LastIndex);
            SetLength(aTab, LastIndex);
            SetLength(aParentObject, LastIndex);

            Result := TRUE;
            EXIT;
          end;
        end;
      end;
    end;

    Result := FALSE;

  end;

end;

// =============================================================================
function TWispPageControl.UnRegisterTab(ParamTab: TcxTabSheet): Boolean;
Var
  I, ArrayLength, LastIndex: Integer;
begin

  ArrayLength := Length(aTab);
  LastIndex := ArrayLength - 1;

  if ArrayLength = 0 then
  begin
    Result := FALSE;
  end
  else
  begin

    for I := 0 to LastIndex do
    begin
      if aTab[I] = ParamTab then
      begin
        aTabType[I] := aTabType[LastIndex];
        aTabName[I] := aTabName[LastIndex];
        aTabId[I] := aTabId[LastIndex];
        aTab[I] := aTab[LastIndex];
        aParentObject[I] := aParentObject[LastIndex];

        SetLength(aTabType, LastIndex);
        SetLength(aTabName, LastIndex);
        SetLength(aTabId, LastIndex);
        SetLength(aTab, LastIndex);
        SetLength(aParentObject, LastIndex);

        Result := TRUE;
        EXIT;
      end;
    end;

    Result := FALSE;

  end;

end;

// =============================================================================
function TWispPageControl.GetTabInfo(ParamTab: TcxTabSheet): TWispTabInfo;
Var
  I, ArrayLength, LastIndex: Integer;
begin

  ArrayLength := Length(aTab);
  LastIndex := ArrayLength - 1;

  if ArrayLength = 0 then
  begin
    Result.TabType := '';
    Result.TabName := '';
    Result.TabId := '';
  end
  else
  begin

    for I := 0 to LastIndex do
    begin
      if aTab[I] = ParamTab then
      begin
        Result.TabType := aTabType[I];
        Result.TabName := aTabName[I];
        Result.TabId := aTabId[I];
        EXIT;
      end;
    end;

    Result.TabType := '';
    Result.TabName := '';
    Result.TabId := '';

  end;

end;

// =============================================================================
Function TWispPageControl.GetTabFromCaption(ParamTabCaption: String)
  : TcxTabSheet;
Var
  I: Integer;
begin

  if Tabs.Count = 0 then
  begin
    Result := nil;
    EXIT;
  end;

  for I := 0 to Tabs.Count - 1 do
  begin
    if Tabs[I].Caption = ParamTabCaption then
    begin
      Result := Self.Pages[Tabs[I].Index];
      EXIT;
    end;
  end;

end;

// =============================================================================
// Add a page(tab) with a scroll box + background
Function TWispPageControl.AddScrollBoxTab(ParamTabCaption: String;
  ParamColumnCount, ParamComponentWidth: Integer): TWispTabSheet;
Var
  tmpScrollBox: TScrollBox;
  tmpDistanceCalculator: TWispColumnDistanceCalculator;
begin
  Result := TWispTabSheet.Create(Self);
  Result.PageControl := Self;
  Result.Caption := ParamTabCaption;

  tmpScrollBox := TScrollBox.Create(Result);
  with tmpScrollBox do
  begin
    parent := Result;
    Align := alClient;
  end;

  tmpDistanceCalculator := TWispColumnDistanceCalculator.Create
    (ParamColumnCount, ParamComponentWidth, tmpScrollBox.ClientWidth);

  Result.ScrollBox := tmpScrollBox;
  Result.DistanceCalculator := tmpDistanceCalculator;

  // BG
  DrawBgImage(tmpScrollBox);

end;

end.
