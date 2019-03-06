unit WispEntityManager;
// Read About Entities here : https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model

interface

uses
  SysUtils,
  DateUtils,
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
  WispReportManager,
  WispDefaultValue;

type
  TEntityManager = Class(TObject)
  Private
    aEntity: array of TEntity;
    FEntityCount: Integer;
  Public
    Property EntityCount: Integer Read FEntityCount;
    Constructor Create; reintroduce;
    // Read about "reintroduce" in the link below :
    // http://docwiki.embarcadero.com/RADStudio/XE8/fr/W1010_La_m%C3%A9thode_'%25s'_cache_la_m%C3%A9thode_virtuelle_du_type_de_base_'%25s'_(Delphi)
    Procedure RegisterEntity(ParamEntityName, ParamDisplayName: string);
    Function GetEntityByName(ParamEntityName: string): TEntity;
    Function GetEntityCount(): Integer;
    Function GetEntityById(ParamId: Integer): TEntity;
    Function GetEntityCounter(ParamEntityName: string): Integer;
    Procedure IncrementEntityCounter(ParamEntityName: string);
    Function GetEpByName(ParamEntity: TEntity; ParamEpName: String)
      : TEntityProperty;
    Function GetTimeAlertState(ParamEntityName, ParamEDName,
      ParamId: String): Boolean;
    Function GetEdByName(ParamEntity: TEntity; ParamEDName: String)
      : TEntityDecorator;
    //Function GetEntityInstanceSelectQueryStrin(ParamEntityName,
    //  ParamEntityId: String): String;
    Destructor Destroy; override;
  End;

var

  Global_Singleton_EntityManager: TEntityManager;
  E: TEntityManager; // Shorter version
  LHE: TEntity; // Last handled entity
  LastHandledEP: TEntityProperty;
  LastHandledEO: TEntityOperation;
  LastHandledED: TEntityDecorator;
  LastHandledDV: TWispDefaultValue;

implementation

// =============================================================================
Constructor TEntityManager.Create;
begin
  if Global_Singleton_EntityManager <> nil then
  begin
    // Lets try ...
    Self := Global_Singleton_EntityManager;
  end
  else
  begin
    inherited Create();
    Global_Singleton_EntityManager := Self;
    E := Self;
    with Global_Singleton_EntityManager do

    begin
      FEntityCount := 0;
    end;

    // Database structure : entities
    If Not(CheckIfTableExists(Global_Singleton_DbConnection,
      'wisp_entities')) Then
    begin
      ExecuteQuery(Global_Singleton_DbConnection,
        'CREATE TABLE ' + 'wisp_entities' + sLineBreak + '(' + sLineBreak +
        ' ID INT NOT NULL AUTO_INCREMENT,' + sLineBreak +
        ' NAME VARCHAR(255) NOT NULL,' + sLineBreak + ' COUNTER INT NOT NULL,' +
        sLineBreak + ' PRIMARY KEY (`ID`));');
    end;

  end;
end;

// =============================================================================
Destructor TEntityManager.Destroy;
begin
  if Global_Singleton_EntityManager = Self then
    Global_Singleton_EntityManager := nil;
  inherited Destroy;
end;

// =============================================================================
Procedure FreeGlobalObjects; far;
begin
  if Global_Singleton_EntityManager <> nil then
    Global_Singleton_EntityManager.Free;
end;

// =============================================================================
Procedure TEntityManager.RegisterEntity(ParamEntityName,
  ParamDisplayName: string);
begin
  FEntityCount := FEntityCount + 1;
  SetLength(aEntity, FEntityCount);
  aEntity[FEntityCount - 1] := TEntity.Create(ParamEntityName,
    ParamDisplayName);
  LHE := aEntity[FEntityCount - 1];
  // Database structure
  If Not(CheckIfTableExists(Global_Singleton_DbConnection,
    'entity_' + ParamEntityName)) Then
    AddTable(Global_Singleton_DbConnection, 'entity_' + ParamEntityName, TRUE);
  // Check if entity exists in entity table
  If OpenQuery(Global_Singleton_DbConnection,
    'SELECT * FROM wisp_entities WHERE NAME = "' + ParamEntityName + '";')
    .RecordsAvailable = TRUE Then
    // its okey
  Else
    ExecuteQuery(Global_Singleton_DbConnection, 'INSERT INTO ' + 'wisp_entities'
      + ' ' + '(NAME, COUNTER)' + ' VALUES ' + '("' + ParamEntityName +
      '", 0)' + ';');
  // Add empty reports to DB
  Global_Singleton_ReportManager.RegisterEntityReportToDb(ParamEntityName);
end;

// =============================================================================
Function TEntityManager.GetEntityByName(ParamEntityName: string): TEntity;
var
  i: Integer;
begin

  for i := 0 to FEntityCount - 1 do
  begin
    if aEntity[i].GetEntityName = ParamEntityName then
    begin
      Result := aEntity[i];
      EXIT;
    end;
  end;

  Result := nil;
  ShowMessage('Entity named ' + ParamEntityName + ' Not found');
end;

// =============================================================================
Function TEntityManager.GetEntityCount(): Integer;
begin
  Result := FEntityCount;
end;

// ==============================================================================
Function TEntityManager.GetEntityCounter(ParamEntityName: string): Integer;
begin
  Result := StrToInt(OpenQuery(Global_Singleton_DbConnection,
    'SELECT COUNTER FROM wisp_entities WHERE NAME="' + ParamEntityName + '";')
    .FirstFieldAsString);
end;

// ==============================================================================
Procedure TEntityManager.IncrementEntityCounter(ParamEntityName: string);
begin
  ExecuteQuery(Global_Singleton_DbConnection,
    'UPDATE wisp_entities SET COUNTER= COUNTER+1 WHERE NAME="' +
    ParamEntityName + '";');
end;

// =============================================================================
Function TEntityManager.GetEntityById(ParamId: Integer): TEntity;
begin
  Result := aEntity[ParamId];
end;

// =============================================================================
Function TEntityManager.GetEpByName(ParamEntity: TEntity; ParamEpName: String)
  : TEntityProperty;
Var
  i, TmpI: Integer;
begin
  TmpI := Length(ParamEntity.aProperty);
  Result := nil;

  if TmpI = 0 then
    Result := nil
  else if TmpI >= 1 then
  begin
    for i := 0 to TmpI - 1 do
    begin
      if TEntityProperty(ParamEntity.aProperty[i]).Name = ParamEpName then
      begin
        Result := TEntityProperty(ParamEntity.aProperty[i]);
      end;
    end;
  end;

end;

// =============================================================================
Function TEntityManager.GetEdByName(ParamEntity: TEntity; ParamEDName: String)
  : TEntityDecorator;
Var
  i, TmpI: Integer;
begin
  TmpI := Length(ParamEntity.aDecorator);
  Result := nil;

  if TmpI = 0 then
    Result := nil
  else if TmpI >= 1 then
  begin
    for i := 0 to TmpI - 1 do
    begin
      if TEntityDecorator(ParamEntity.aDecorator[i]).Name = ParamEDName then
      begin
        Result := TEntityDecorator(ParamEntity.aDecorator[i]);
      end;
    end;
  end;

end;

// =============================================================================
Function TEntityManager.GetTimeAlertState(ParamEntityName, ParamEDName,
  ParamId: String): Boolean;
Var
  TmpEntity: TEntity;
  TmpEd: TEDTimeAlert;
  TmpEpDate: TEPDate;
  TmpEpTime: TEPTime;
  TmpEpOffset: TEPText;
  Q: TZQuery;
  ColDate, ColTime, ColOffset: String;
  S, U, DateStr, TimeStr, OffsetStr: String;
  Offset, OffsetSec: Int64;
  aDate, aTime: TArrayOfString;
  Origin, Offseted, Now_: TDateTime;
begin
  TmpEntity := GetEntityByName(ParamEntityName);
  TmpEd := TEDTimeAlert(GetEdByName(TmpEntity, ParamEDName));
  TmpEpDate := TEPDate(GetEpByName(TmpEntity, TmpEd.OriginDateProperty));
  TmpEpTime := TEPTime(GetEpByName(TmpEntity, TmpEd.OriginTimeProperty));
  TmpEpOffset := TEPText(GetEpByName(TmpEntity, TmpEd.OffsetProperty));
  U := TmpEd.OffsetUnit;

  if TmpEpTime = nil then
  begin
    ColDate := TmpEpDate.GetDbColumnName;
    // ColTime := TmpEpTime.GetDbColumnName;
    ColOffset := TmpEpOffset.GetDbColumnName;
    Q := OpenQuery(Global_Singleton_DbConnection, 'SELECT ' + ColDate + ',' +
      ColOffset + ' FROM entity_' + TmpEntity.GetEntityName + ' WHERE ID=' +
      ParamId + ';').ZQuery;
    DateStr := Q.FieldByName(ColDate).AsString;
    TimeStr := '00:00:00';
    // Since the origin time property can be left blank by the developper
    OffsetStr := Q.FieldByName(ColOffset).AsString;
  end
  else if TmpEpTime <> nil then
  begin
    ColDate := TmpEpDate.GetDbColumnName;
    ColTime := TmpEpTime.GetDbColumnName;
    ColOffset := TmpEpOffset.GetDbColumnName;
    Q := OpenQuery(Global_Singleton_DbConnection, 'SELECT ' + ColDate + ',' +
      ColTime + ',' + ColOffset + ' FROM entity_' + TmpEntity.GetEntityName +
      ' WHERE ID=' + ParamId + ';').ZQuery;
    DateStr := Q.FieldByName(ColDate).AsString;
    TimeStr := Q.FieldByName(ColTime).AsString;
    OffsetStr := Q.FieldByName(ColOffset).AsString;
  end;

  if OffsetStr = '' then
    Offset := 0
  else
    Offset := StrToInt(OffsetStr);

  if DateStr = '' then
  begin
    Result := FALSE;
    EXIT;
  end;

  if U = '' then
    U := 'D';

  if U = 'Y' then
    OffsetSec := Offset * 365 * 86400
  else if U = 'M' then
    OffsetSec := Offset * 30 * 86400
  else if U = 'D' then
    OffsetSec := Offset * 86400
  else if U = 'H' then
    OffsetSec := Offset * 3600
  else if U = 'M' then
    OffsetSec := Offset * 60
  else
    OffsetSec := Offset;

  aDate := WispStringSplit(DateStr, '/');
  aTime := WispStringSplit(TimeStr, ':');

  Origin := EncodeDateTime(StrToInt(aDate[2]), StrToInt(aDate[1]),
    StrToInt(aDate[0]), StrToInt(aTime[0]), StrToInt(aTime[1]),
    StrToInt(aTime[2]), 0);

  Now_ := GetNowFromServer;

  if TmpEd.OffsetDirection = TRUE then
  begin
    Offseted := IncSecond(Origin, OffsetSec);
    if Now_ >= Offseted then
      Result := TRUE;
  end
  else if TmpEd.OffsetDirection = FALSE then
  begin
    Offseted := IncSecond(Origin, OffsetSec * -1);
    if Now <= Offseted then
      Result := TRUE;
  end
  else
    Result := FALSE;

end;

// =============================================================================
{
Function TEntityManager.GetEntityInstanceSelectQueryStrin(ParamEntityName,
  ParamEntityId: String): String;
begin
  if ParamEntityId = '0' then
  begin
    Result := 'SELECT * FROM entity_' + ParamEntityName + ';'
  end
  else
  begin
    Result := 'SELECT * FROM entity_' + ParamEntityName + ' WHERE ID="' +
      ParamEntityId + '";'
  end;

end;}

// =============================================================================
begin
  AddExitProc(FreeGlobalObjects);

end.
