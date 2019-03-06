unit WispReportManager;

interface

uses
  SysUtils,
  DateUtils,
  Classes,
  Forms,
  ZDataset,
  ZConnection,
  ZAbstractConnection,
  WispEntity,
  WispArrayTools,
  Dialogs,
  WispDbStructureTools,
  WispDbConnection,
  WispQueryTools,
  WispStrTools,
  WispTimeTools,
  frxClass,
  frxDesgn,
  DB,
  DBTables;

type
  TReportManager = Class(TObject)
  Private
  Public
    Constructor Create; reintroduce;
    Procedure RegisterEntityReportToDb(ParamEntityName: String);
    // Read about "reintroduce" in the link below :
    // http://docwiki.embarcadero.com/RADStudio/XE8/fr/W1010_La_m%C3%A9thode_'%25s'_cache_la_m%C3%A9thode_virtuelle_du_type_de_base_'%25s'_(Delphi)
    Destructor Destroy; override;
  End;

var

  Global_Singleton_ReportManager: TReportManager;
  R: TReportManager; // Shorter version

implementation

// =============================================================================
Constructor TReportManager.Create;
begin
  if Global_Singleton_ReportManager <> nil then
  begin
    // Lets try ...
    Self := Global_Singleton_ReportManager;
  end
  else
  begin
    inherited Create();
    Global_Singleton_ReportManager := Self;
    R := Global_Singleton_ReportManager;
    with Global_Singleton_ReportManager do

      // Database structure : reports
      If Not(CheckIfTableExists(Global_Singleton_DbConnection,
        'wisp_reports')) Then
      begin
        ExecuteQuery(Global_Singleton_DbConnection,
          'CREATE TABLE ' + 'wisp_reports' + sLineBreak + '(' + sLineBreak +
          ' ID INT NOT NULL AUTO_INCREMENT,' + sLineBreak + ' REPORT BLOB,' +
          sLineBreak + ' NAME VARCHAR(255) NOT NULL,' + sLineBreak +
          ' TYPE VARCHAR(255) NOT NULL,' + sLineBreak +
          ' LABEL VARCHAR(255) NOT NULL,' + sLineBreak +
          ' PRIMARY KEY (`ID`));');
      end;

  end;
end;

// =============================================================================
Destructor TReportManager.Destroy;
begin
  if Global_Singleton_ReportManager = Self then
  begin
    Global_Singleton_ReportManager := nil;
    R := nil;
  end;
  inherited Destroy;
end;

// =============================================================================
Procedure FreeGlobalObjects; far;
begin
  if Global_Singleton_ReportManager <> nil then
  begin
    Global_Singleton_ReportManager.Free;
  end;
end;

// =============================================================================
Procedure TReportManager.RegisterEntityReportToDb(ParamEntityName: String);
var
  TmpId: String;
  Report: TFrxReport;
  Stream: TStream;
  FileStream: TFileStream;
  TmpQ: TZQuery;
begin
  // Create empty report for single entity instance
  if Not(OpenQuery(Global_Singleton_DbConnection,
    'SELECT * FROM wisp_reports WHERE NAME=''' + ParamEntityName +
    ''' AND TYPE=''SINGLE'';').RecordsAvailable) then
  begin
    ExecuteQuery(Global_Singleton_DbConnection,
      'INSERT INTO wisp_reports (NAME,TYPE,LABEL) VALUES (''' + ParamEntityName
      + ''',''SINGLE'',''No Label'');');

    TmpId := OpenQuery(Global_Singleton_DbConnection,
      'SELECT LAST_INSERT_ID();').FirstFieldAsString;

    TmpQ := OpenQuery(Global_Singleton_DbConnection,
      'SELECT REPORT FROM wisp_reports WHERE ID=' + TmpId + ';').ZQuery;

    FileStream := TFileStream.Create(ExtractFilePath(Application.ExeName) +
      'Default.fr3', fmShareDenyWrite);
    FileStream.Position := 0;

    TmpQ.SQL.Clear;
    TmpQ.SQL.Text := 'UPDATE wisp_reports SET REPORT=:blobparam WHERE ID=' +
      TmpId + ';';
    TmpQ.ParamByName('blobparam').LoadFromStream(FileStream, ftBlob);
    TmpQ.ExecSQL;

    FileStream.Free;
    Stream.Free;
  end;

  // Create empty report for multiple entity instances
  if Not(OpenQuery(Global_Singleton_DbConnection,
    'SELECT * FROM wisp_reports WHERE NAME=''' + ParamEntityName +
    ''' AND TYPE=''MULTI'';').RecordsAvailable) then
  begin
    ExecuteQuery(Global_Singleton_DbConnection,
      'INSERT INTO wisp_reports (NAME,TYPE,LABEL) VALUES (''' + ParamEntityName
      + ''',''MULTI'',''No Label'');');

    TmpId := OpenQuery(Global_Singleton_DbConnection,
      'SELECT LAST_INSERT_ID();').FirstFieldAsString;

    TmpQ := OpenQuery(Global_Singleton_DbConnection,
      'SELECT REPORT FROM wisp_reports WHERE ID=' + TmpId + ';').ZQuery;

    FileStream := TFileStream.Create(ExtractFilePath(Application.ExeName) +
      'Default.fr3', fmShareDenyWrite);
    FileStream.Position := 0;

    TmpQ.SQL.Clear;
    TmpQ.SQL.Text := 'UPDATE wisp_reports SET REPORT=:blobparam WHERE ID=' +
      TmpId + ';';
    TmpQ.ParamByName('blobparam').LoadFromStream(FileStream, ftBlob);
    TmpQ.ExecSQL;

    FileStream.Free;
    Stream.Free;
  end;

end;

// =============================================================================
begin
  AddExitProc(FreeGlobalObjects);

end.
