unit WispTimeTools;

interface

uses
  SysUtils,
  DateUtils,
  WispDbConnection,
  WispQueryTools,
  WispStrTools;

Function GetTimeFromServer(): string;
Function GetDateFromServer(): string;
Function GetTimeStampFromServer(): string;
Function GetNowFromServer() : TDateTime;
Function CxDateToMySqlDate(ParamDateText : string) : string;
Function MySqlDateToDMYString(ParamDateText : string) : string;

implementation

Function GetTimeFromServer(): string;
begin
  Result := OpenQuery(Global_Singleton_DbConnection, 'SELECT CURTIME();')
    .FirstFieldAsString;
end;

Function GetDateFromServer(): string;
begin
  Result := OpenQuery(Global_Singleton_DbConnection, 'SELECT CURDATE();')
    .FirstFieldAsString;
end;

Function GetTimeStampFromServer(): string;
begin
  Result := OpenQuery(Global_Singleton_DbConnection, 'SELECT NOW();')
    .FirstFieldAsString;
end;

Function CxDateToMySqlDate(ParamDateText : string) : string;
Var
  TmpStrArray : TArrayOfString;
begin
  if ParamDateText = '' then
  begin
    Result := '';
    EXIT;
  end;

  TmpStrArray := WispStringSplit(ParamDateText, '/');
  Result := TmpStrArray[2]+'-'+TmpStrArray[1]+'-'+TmpStrArray[0];
end;

Function MySqlDateToDMYString(ParamDateText : string) : string;
Var
  TmpStrArray : TArrayOfString;
begin
  TmpStrArray := WispStringSplit(ParamDateText, '-');
  Result := TmpStrArray[2]+'/'+TmpStrArray[1]+'/'+TmpStrArray[0];
end;

Function GetNowFromServer() : TDateTime;
Var
  D, T : TArrayOfString;
begin
  D := WispStringSplit(GetDateFromServer, '/');
  T := WispStringSplit(GetTimeFromServer, ':');
  Result := EncodeDateTime(StrToInt(D[2]), StrToInt(D[1]),
    StrToInt(D[0]), StrToInt(T[0]), StrToInt(T[1]),
    StrToInt(T[2]), 0);
end;

end.
