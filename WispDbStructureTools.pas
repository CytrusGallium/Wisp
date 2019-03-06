unit WispDbStructureTools;

interface

uses
  WispQueryTools,
  WispDbConnection;

function CheckIfTableExists(ParamDbConnection: TDbConnection;
  ParamTableName: string): Boolean;
function CheckIfColumnExists(ParamDbConnection: TDbConnection;
  ParamTableName, ParamColumnName: string): Boolean;
function AddTable(ParamDbConnection: TDbConnection; ParamTableName: string;
  ParamEntityTable: Boolean): Boolean;
Function AddColumn(ParamDbConnection: TDbConnection;
  ParamTableName, ParamColumnName, ParamFieldType, ParamOptions
  : string): Boolean;

implementation

// =============================================================================
function AddTable(ParamDbConnection: TDbConnection; ParamTableName: string;
  ParamEntityTable: Boolean): Boolean;
begin
  if ParamEntityTable then
  begin
    // If The Table is gonna hold entities it shall have this structure
    ExecuteQuery(ParamDbConnection, 'CREATE TABLE ' + ParamTableName +
      sLineBreak + '(' + sLineBreak + ' ID INT NOT NULL AUTO_INCREMENT,' +
      sLineBreak + ' ENTITY_ID INT NOT NULL DEFAULT 0,' + sLineBreak +
      ' VERSION_ID INT NOT NULL DEFAULT 0,' + sLineBreak + ' IS_LAST BOOLEAN NULL DEFAULT FALSE,' +
      sLineBreak + ' DTC TIMESTAMP NULL DEFAULT "0000-00-00",' + sLineBreak +
      ' UID INTEGER NOT NULL DEFAULT 0,' + sLineBreak + ' IS_DELETED BOOLEAN NULL DEFAULT FALSE,' +
      sLineBreak + ' PRIMARY KEY (`ID`));');
  end
  else
  begin
    // If its another table type it shall have this structure
    ExecuteQuery(ParamDbConnection, 'CREATE TABLE ' + ParamTableName +
      sLineBreak + '(' + sLineBreak + ' ID INT NOT NULL AUTO_INCREMENT,' +
      ' PRIMARY KEY (`ID`));');
  end;

end;

// =============================================================================
function AddColumn(ParamDbConnection: TDbConnection;
  ParamTableName, ParamColumnName, ParamFieldType, ParamOptions
  : string): Boolean;
begin
  ExecuteQuery(ParamDbConnection, 'ALTER TABLE ' + ParamTableName + ' ADD ' +
    ParamColumnName + ' ' + ParamFieldType + ' ' + ParamOptions + ';');
end;

// =============================================================================
function CheckIfTableExists(ParamDbConnection: TDbConnection;
  ParamTableName: string): Boolean;
Var
  DbName: string;
begin
  DbName := ParamDbConnection.Database;
  Result := OpenQuery(ParamDbConnection,
    'SELECT * FROM information_schema.tables WHERE table_schema = "' + DbName +
    '" AND table_name ="' + ParamTableName + '";').RecordsAvailable;
end;

// =============================================================================
function CheckIfColumnExists(ParamDbConnection: TDbConnection;
  ParamTableName, ParamColumnName: string): Boolean;
Var
  DbName: string;
begin
  DbName := ParamDbConnection.Database;
  Result := OpenQuery(ParamDbConnection,
    'SELECT * FROM information_schema.COLUMNS WHERE table_schema = "' + DbName +
    '" AND table_name ="' + ParamTableName + '" AND column_name = "' +
    ParamColumnName + '";').RecordsAvailable;
end;

end.
