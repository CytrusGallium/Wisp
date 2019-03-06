unit WispQueryTools;

interface

uses
  ZConnection,
  ZAbstractConnection,
  ZDataset,
  Data.DB,
  ZStoredProcedure,
  CxGrid,
  CxGridDbTableView,
  CxGridTableView,
  Classes,
  SysUtils,
  DBTables;

type
  TOpenQueryResult = record
    ZQuery: TZQuery;
    RecordsAvailable: Boolean;
    FirstFieldAsString: string;
    FirstFieldAsBoolean: Boolean;
    // FirstFieldAsInteger: integer;
  end;

Function CreateDataSet(C: TZConnection): TZQuery;
Function CreateDataSource(Q: TZQuery): TDataSource;
Procedure ExecuteQuery(C: TZConnection; QueryStr: AnsiString);
Function OpenQuery(C: TZConnection; QueryStr: String): TOpenQueryResult;
Function ExecuteSqlInsert(ParamDbConnection: TZConnection;
  ParamTableName: string; ParamColumns, ParamValues: array of string): String;
Procedure ShowQueryResult(C: TZConnection; QueryStr: String; O: TObject);
procedure SaveCompToBlob(AField: TBlobField; AComponent: TComponent);
procedure LoadCompFromBlob(AField: TBlobField; AComponent: TComponent);
Function UploadFileToDb(ParamConnection: TZConnection; ParamFilePath: String;
  ParamTableName: String; ParamColumnName: String; ParamIdColumn: String;
  ParamId: String): Boolean;

implementation

// ==============================================================================
// Create a dataset (zquery component)
function CreateDataSet(C: TZConnection): TZQuery;
Var
  Q: TZQuery; // Q as Query
begin
  Q := TZQuery.Create(nil);
  try
    Q.Connection := C;
    result := Q;
  finally
    // Q.Free;
  end;
end;
// CreateDataSet END//

// ==============================================================================
// Create a datasource (datasource component)
function CreateDataSource(Q: TZQuery): TDataSource;
Var
  DS: TDataSource; // DS as Data Source
begin
  DS := TDataSource.Create(nil);
  try
    DS.DataSet := Q;
    result := DS;
  finally
    // DS.Free;
  end;
end;
// CreateDataSource END//

// =============================================================Need Optimization
// Show Query result in Table
procedure ExecuteQuery(C: TZConnection; QueryStr: AnsiString);
Var
  Q: TZQuery;
begin
  Q := CreateDataSet(C);
  Q.Sql.Clear;
  Q.Sql.Add(QueryStr);
  Q.ExecSQL;
end;
// ExecuteQuery END //

// =============================================================================
function OpenQuery(C: TZConnection; QueryStr: String): TOpenQueryResult;
Var
  Q: TZQuery;
begin
  Q := CreateDataSet(C);
  Q.Sql.Clear;
  Q.Sql.Add(QueryStr);
  Q.Open;

  result.ZQuery := Q;

  if Q.RecordCount > 0 then
  begin
    result.RecordsAvailable := TRUE;
    result.FirstFieldAsString := Q.Fields[0].AsString;

    if result.FirstFieldAsString = '1' then
      result.FirstFieldAsBoolean := TRUE
    else if result.FirstFieldAsString = '0' then
      result.FirstFieldAsBoolean := FALSE
    else if result.FirstFieldAsString = '' then
      result.FirstFieldAsBoolean := FALSE

      // result.FirstFieldAsInteger := Q.Fields[0].AsInteger;
  end
  else
    result.RecordsAvailable := FALSE;

end;
// OpenQuery END //

// =============================================================================
function ExecuteQueryFromFile(C: TZConnection; QueryStr: String)
  : TOpenQueryResult;
Var
  Q: TZQuery;
begin
  Q := CreateDataSet(C);
  Q.Sql.Clear;
  Q.Sql.Add(QueryStr);
  Q.Open;

  result.ZQuery := Q;

  if Q.RecordCount > 0 then
    result.RecordsAvailable := TRUE
  else
    result.RecordsAvailable := FALSE;

end;
// OpenQuery END //

// =============================================================================
Function ExecuteSqlInsert(ParamDbConnection: TZConnection;
  ParamTableName: string; ParamColumns, ParamValues: array of string): String;
Var
  TmpCols, TmpVals, S: string;
  I, A, B: integer;
begin

  A := Length(ParamColumns);
  B := Length(ParamValues);

  if (A = 0) or (Length(ParamValues) = 0) then
    EXIT;

  if A <> B then
    EXIT;

  TmpCols := '';
  TmpVals := '';

  for I := 0 to A - 1 do
  begin
    TmpCols := TmpCols + ParamColumns[I];
    TmpVals := TmpVals + '"' + ParamValues[I] + '"';
    if I < A - 1 then
    begin
      TmpCols := TmpCols + ',';
      TmpVals := TmpVals + ',';
    end;
  end;

  TmpCols := '(' + TmpCols + ')';
  TmpVals := '(' + TmpVals + ')';

  S := 'INSERT INTO ' + ParamTableName + ' ' + TmpCols + ' VALUES ' +
    TmpVals + ';';

  ExecuteQuery(ParamDbConnection, S);

  result := OpenQuery(ParamDbConnection, 'SELECT LAST_INSERT_ID();')
    .FirstFieldAsString;

end;

// =============================================================================
// Show Query result in Table
Procedure ShowQueryResult(C: TZConnection; QueryStr: String; O: TObject);
Var
  DS: TDataSource; // DS as Data Source
  G: TcxGrid; // G as Grid
  V: TcxGridDBTableView; // V as View
  Q: TZQuery;
begin
  Q := CreateDataSet(C);
  if O is TcxGridDBTableView then
  begin
    V := O as TcxGridDBTableView;
  end
  else if O is TcxGrid then
  begin
    G := O as TcxGrid;
    V := G.levels[0].GridView as TcxGridDBTableView;
  end;
  Q.Sql.Clear;
  Q.Sql.Add(QueryStr);
  Q.Open;
  DS := CreateDataSource(Q);
  V.ClearItems;
  V.DataController.DataSource := DS;
  V.DataController.CreateAllItems();
  Q.Sql.Clear;
  Q.Sql.Add(QueryStr);
  Q.Open;

end;

// =============================================================================
// http://www.scalabium.com/faq/dct0065.htm
procedure SaveCompToBlob(AField: TBlobField; AComponent: TComponent);
var
  Stream: TBlobStream;
  CompName: string;
begin
  CompName := Copy(AComponent.ClassName, 2, 99);
  Stream := TBlobStream.Create(AField, bmWrite);
  try
    Stream.WriteComponentRes(CompName, AComponent);
  finally
    Stream.Free;
  end;
end;

// =============================================================================
// http://www.scalabium.com/faq/dct0065.htm
procedure LoadCompFromBlob(AField: TBlobField; AComponent: TComponent);
var
  Stream: TBlobStream;
  I: integer;
begin
  try
    Stream := TBlobStream.Create(AField, bmRead);
    try
      { delete the all child components }
      for I := AComponent.ComponentCount - 1 downto 0 do
        AComponent.Components[I].Free;
      Stream.ReadComponentRes(AComponent);
    finally
      Stream.Free;
    end;
  except
    on EFOpenError do { nothing };
  end;
end;

// =============================================================================
Function UploadFileToDb(ParamConnection: TZConnection; ParamFilePath: String;
  ParamTableName: String; ParamColumnName: String; ParamIdColumn: String;
  ParamId: String): Boolean;
Var
  FileStream: TFileStream;
  TmpQ: TZQuery;
begin
  TmpQ := CreateDataSet(ParamConnection);

  FileStream := TFileStream.Create(ParamFilePath, fmShareDenyWrite);
  FileStream.Position := 0;

  TmpQ.Sql.Clear;
  TmpQ.Sql.Text := 'UPDATE ' + ParamTableName + ' SET ' + ParamColumnName +
    '=:blobparam WHERE ' + ParamIdColumn + '=' + ParamId + ';';
  TmpQ.ParamByName('blobparam').LoadFromStream(FileStream, ftBlob);
  TmpQ.ExecSQL;

  FileStream.Free;
end;

end.
