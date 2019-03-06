unit WispEntity;

interface

uses
  SysUtils,
  WispArrayTools,
  WispDbStructureTools,
  WispDbConnection,
  WispStrTools,
  WispQueryFilter,
  WispDefaultValue,
  WispTimeTools,
  WispQueryTools;

type
  TEntityProperty = Class(TObject)
  Private
    FName: String;
    FLabelText: String;
    FDbColNamePrefix: string;
    FDbColNameSuffix: String;
    FDisplayInGrid: Boolean;
    FDisplayInEditor: Boolean;
    FEditable: Boolean;
    FDefaultValue: TWispDefaultValue;
    FGroupName: String;
  Public
    Property Name: String Read FName;
    Property LabelText: String Read FLabelText;
    Property DisplayInGrid: Boolean Read FDisplayInGrid;
    Property DisplayInEditor: Boolean Read FDisplayInEditor;
    Property Editable: Boolean Read FEditable Write FEditable;
    Property DefaultValue: TWispDefaultValue Read FDefaultValue
      Write FDefaultValue;
    Property GroupName: String Read FGroupName Write FGroupName;
    Constructor Create; overload;
    Function GetDbColumnName(): String;
  End;

  TEPText = Class(TEntityProperty) // EP stand for : Entity Property
  private
    MinimumLength: integer;
    MaximumLength: integer;
    DefaultLanguage: string; // Maybe create a language type
    Dictionary: String;
    NextAvailableId: integer; // <=== What is this ??
    FLineCount: integer;
    FSuffixLabel: String;
    FLocalFileSelector: Boolean;
    // Dictionary Should be a boolean and the dictionary name shall be generated automticly by Wisp, in this case two entities cant share the same dictionary
    // Vision, Edition and Deletion privileges shall be automaticly visible in the privilege/user-profile configurator
  public
    Property LineCount: integer Read FLineCount;
    Property SuffixLabel: String Read FSuffixLabel Write FSuffixLabel;
    Property LocalFileSelector: Boolean Read FLocalFileSelector
      Write FLocalFileSelector;
    Constructor Create(ParamPropertyName, ParamLabelText: string;
      ParamLineCount: integer = 1);
  End;

  TEPDate = Class(TEntityProperty) // EP stand for : Entity Property
  private
    MinimumDate: TDate;
    MaximumDate: TDate;
  public
    Constructor Create(ParamPropertyName, ParamLabelText: string);
  End;

  TEPTime = Class(TEntityProperty) // EP stand for : Entity Property
  private
    MinimumTime: TTime;
    MaximumTime: TTime;
  public
    Constructor Create(ParamPropertyName, ParamLabelText: string);
  End;

  TEPSubEntity = Class(TEntityProperty) // EP stand for : Entity Property
  private
    FSubEntityName: string;
    FSubEntityProperties: TArrayOfString;
    FUseLastEntityVersion: Boolean;
    FMulti: Boolean;
  public
    Property SubEntityName: string read FSubEntityName;
    Property SubEntityProperties: TArrayOfString read FSubEntityProperties;
    Property UseLastEntityVersion: Boolean read FUseLastEntityVersion;
    Property Multi: Boolean read FMulti;
    Constructor Create(ParamPropertyName, ParamLabelText, ParamSubEntityName
      : string; ParamSubEntityProperties: String;
      ParamUseLastEntityVersion: Boolean; ParamMulti: Boolean = FALSE);
  End;

  TEPBoolean = Class(TEntityProperty) // EP stand for : Entity Property
  private
    FTrueLabel: string;
    FFalseLabel: string;
  public
    Property TrueLabel: string read FTrueLabel;
    Property FalseLabel: string read FFalseLabel;
    Constructor Create(ParamPropertyName, ParamLabelText, ParamTrueLabel,
      ParamFalseLabel: string);
  End;

  TEntityOperation = Class(TObject)
  private
    FName: String;
    FLabel: String;
    FConfirmationEPBooleanName: String;
    FDbColNamePrefix: string;
    FDbColNameSuffix: String;
  Public
    Property Name: String Read FName;
    Property LabelText: String Read FLabel;
    Property ConfirmationEPBooleanName: String Read FConfirmationEPBooleanName;
    Constructor Create;
    Function GetDbColumnName(): String;
  End;

  TEOLockEdition = Class(TEntityOperation)
  Public
    Constructor Create(ParamOperationName, ParamDisplayName,
      ParamConfirmationProperty: string);
  End;

  TEOPropertyOperator = Class(TEntityOperation)
  Private
    FTargetSubEntity: String;
    FTargetProperty: String;
    FSourceProperty: String;
    FOperator: String;
  Public
    Property TargetSubEntity: String Read FTargetSubEntity;
    Property TargetProperty: String Read FTargetProperty;
    Property SourceProperty: String Read FSourceProperty;
    Property Operator_: String Read FOperator;
    Constructor Create(ParamOperationName, ParamOperationLabel,
      ParamTargetSubEntity, ParamTargetProperty, ParamSourceProperty,
      ParamOperator, ParamConfirmationBoolean: String);
  End;

  TEOPropertyUpdater = Class(TEntityOperation)
  Private
    FTargetSubEntity: String;
    FTargetProperty: String;
    FSourceProperty: String;
  Public
    Property TargetSubEntity: String Read FTargetSubEntity;
    Property TargetProperty: String Read FTargetProperty;
    Property SourceProperty: String Read FSourceProperty;
    Constructor Create(ParamOperationName, ParamOperationLabel,
      ParamTargetSubEntity, ParamTargetProperty, ParamSourceProperty,
      ParamConfirmationBoolean: String);
  End;

  TEntityDecorator = Class(TObject)
  private
    FName: String;
    FDbColNamePrefix: string;
    FDbColNameSuffix: String;
  Public
    Property Name: String Read FName;
    Constructor Create;
    Function GetDbColumnName(): String;
  End;

  TEDTimeAlert = Class(TEntityDecorator)
  Private
    FOriginDateProperty: String;
    FOriginTimeProperty: String;
    FOffsetProperty: String;
    FOffsetUnit: String;
    FOffsetDirection: Boolean;
  Public
    Property OriginDateProperty: String Read FOriginDateProperty;
    Property OriginTimeProperty: String Read FOriginTimeProperty;
    Property OffsetProperty: String Read FOffsetProperty;
    Property OffsetUnit: String Read FOffsetUnit;
    Property OffsetDirection: Boolean Read FOffsetDirection;
    Constructor Create(ParamDecoratorName, ParamOriginDateProperty,
      ParamOriginTimeProperty, ParamOffsetProperty, ParamOffsetUnit: String;
      ParamOffsetDirection: Boolean);
  End;

  TEntity = Class(TObject)
    // Read About Entities here : https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model
  private
    EntityName: string;
    FDisplayName: string;
    PropertyCount: integer;
    FGlyphName: String;
    FDisplayShortcut: Boolean;
    FPredefinedList: Boolean;
    FQuickSearchProperty: TEntityProperty;
  public
    aProperty: TObjectArray;
    aOperation: TObjectArray;
    aDecorator: TObjectArray;
    Property DisplayName: String Read FDisplayName;
    Property GlyphName: String Read FGlyphName Write FGlyphName;
    Property DisplayShortcut: Boolean Read FDisplayShortcut
      Write FDisplayShortcut;
    Property PredefinedList: Boolean Read FPredefinedList Write FPredefinedList;
    Property QuickSearchProperty: TEntityProperty Read FQuickSearchProperty
      Write FQuickSearchProperty;
    Constructor Create(ParamEntityName, ParamDisplayName: string);
    function GetPropertyCount(): integer;
    function AddProperty(ParamEntityProperty: TEntityProperty;
      ParamGroupName: String = ''): integer;
    function AddOperation(ParamEntityOperation: TEntityOperation): integer;
    function AddDecorator(ParamEntityDecorator: TEntityDecorator): integer;
    Procedure SetName(ParamName: string);
    function GetEntityName(): string;
    Function PropertyByName(ParamPropertyName: String): TEntityProperty;
    Function CheckSubEntityPresence(): Boolean;
    Function GetInstanceQueryString(ParamInstanceId: String): String;
    Function GetGridQueryString(ParamFilter: TWispFilter): String;
    Function GetDefaultValueOf(ParamDefaultValueObject: TWispDefaultValue;
      ParamEntityProperty: TEntityProperty = nil;
      ParamInstanceId: String = ''): String;
    Procedure DuplicateInstance(ParamInstanceId: String);
    Function GetTableName(): String;
  End;

implementation

Uses
  WispEntityManager, WispAccesManager;

// =============================================================================
Function GetAliasFromTable(ParamTableName: string;
  ParamTables, ParamAliases: TArrayOfString): String;
Var
  I, L: integer;
begin
  L := Length(ParamTables);

  for I := 0 to L - 1 do
  begin
    if ParamTables[I] = ParamTableName then
    begin
      result := ParamAliases[I];
      BREAK;
    end;

  end;

end;

// =============================================================================
Constructor TEntity.Create(ParamEntityName, ParamDisplayName: string);
begin
  EntityName := ParamEntityName;
  FDisplayName := ParamDisplayName;
  FDisplayShortcut := TRUE;
  LHE := Self;

end;

procedure TEntity.DuplicateInstance(ParamInstanceId: String);
var
  S: String;
begin
  // Create a temporary table that contains our source instance that we want to duplicate
  ExecuteQuery(C, 'CREATE TEMPORARY TABLE tmp SELECT * from ' + GetTableName +
    ' WHERE ID=' + ParamInstanceId + ';');

  // Remove columns with values that are gonna change in the target instance
  ExecuteQuery(C,
    'ALTER TABLE tmp DROP ID, DROP ENTITY_ID, DROP VERSION_ID, DROP IS_LAST, DROP DTC, DROP UID, DROP IS_DELETED;');

  // Insert a new record in our source table based on the source instance
  S := 'INSERT INTO ' + GetTableName + ' SELECT 0, ' +
    IntToStr(E.GetEntityCounter(GetEntityName) + 1) + ', 1, 1, ' +
    'CURRENT_TIMESTAMP(), ' + A.CurrentUser.ID + ', 0, tmp.* FROM tmp;';
  ExecuteQuery(C, S);

  // Remove the temporary table
  ExecuteQuery(C, 'DROP TABLE tmp;');

end;

// =============================================================================
function TEntity.GetEntityName(): string;
begin
  result := Self.EntityName;
end;

// =============================================================================
function TEntity.GetPropertyCount(): integer;
begin
  result := Self.PropertyCount;
end;

// =============================================================================
function TEntity.GetTableName: String;
begin
  result := 'entity_' + GetEntityName;
end;

// =============================================================================
function TEntity.AddProperty(ParamEntityProperty: TEntityProperty;
  ParamGroupName: String = ''): integer;
Var
  TmpEpText: TEPText;
  TmpEpDate: TEPDate;
  TmpEpSubEntity: TEPSubEntity;
  TmpEpBoolean: TEPBoolean;
  TmpEpTime: TEPTime;
  ColumnExist, TableExist: Boolean;
  TmpTableName: String;
begin
  if ParamEntityProperty <> nil then
  begin
    Self.PropertyCount := Self.PropertyCount + 1;
    ResizeObjectArray(Self.aProperty, Self.PropertyCount);
    Self.aProperty[Self.PropertyCount - 1] := ParamEntityProperty;
    LastHandledEP := ParamEntityProperty;
    ParamEntityProperty.GroupName := ParamGroupName;

    if (ParamEntityProperty is TEPText) then
    begin
      TmpEpText := ParamEntityProperty As TEPText;
      ColumnExist := CheckIfColumnExists(Global_Singleton_DbConnection,
        'entity_' + Self.EntityName, TmpEpText.GetDbColumnName);
      if TmpEpText.LineCount = 1 then
      begin
        if Not(ColumnExist) then
          AddColumn(Global_Singleton_DbConnection, 'entity_' + Self.EntityName,
            'EP_' + TmpEpText.Name, 'VARCHAR(255)', 'NULL DEFAULT ""');
      end
      else if TmpEpText.LineCount > 1 then
      begin
        if Not(ColumnExist) then
          AddColumn(Global_Singleton_DbConnection, 'entity_' + Self.EntityName,
            'EP_' + TmpEpText.Name, 'TEXT', 'NULL');
      end;
    end;

    if (ParamEntityProperty is TEPDate) then
    begin
      TmpEpDate := ParamEntityProperty As TEPDate;
      ColumnExist := CheckIfColumnExists(Global_Singleton_DbConnection,
        'entity_' + Self.EntityName, 'EP_' + TmpEpDate.Name);
      if Not(ColumnExist) then
        AddColumn(Global_Singleton_DbConnection, 'entity_' + Self.EntityName,
          'EP_' + TmpEpDate.Name, 'DATE', 'NULL DEFAULT "0000-00-00"');
    end;

    if (ParamEntityProperty is TEPTime) then
    begin
      TmpEpTime := ParamEntityProperty As TEPTime;
      ColumnExist := CheckIfColumnExists(Global_Singleton_DbConnection,
        'entity_' + Self.EntityName, 'EP_' + TmpEpTime.Name);
      if Not(ColumnExist) then
        AddColumn(Global_Singleton_DbConnection, 'entity_' + Self.EntityName,
          'EP_' + TmpEpTime.Name, 'TIME', 'NULL DEFAULT "00:00:00"');
    end;

    if (ParamEntityProperty is TEPSubEntity) then
    begin
      TmpEpSubEntity := ParamEntityProperty As TEPSubEntity;
      if TmpEpSubEntity.Multi = FALSE then
      begin
        // Single
        ColumnExist := CheckIfColumnExists(Global_Singleton_DbConnection,
          'entity_' + Self.EntityName, 'ID_' + TmpEpSubEntity.Name);
        if Not(ColumnExist) then
          AddColumn(Global_Singleton_DbConnection, 'entity_' + Self.EntityName,
            'ID_' + TmpEpSubEntity.Name, 'INT', 'NULL DEFAULT "0"');
      end
      else
      begin
        // Multi
        TmpTableName := 'entity_' + Self.EntityName + '_' +
          LowerCase(TmpEpSubEntity.Name);

        TableExist := CheckIfTableExists(C, TmpTableName);

        if TableExist = FALSE then
        begin
          AddTable(C, TmpTableName, FALSE);
          AddColumn(C, TmpTableName, 'ID_' + Self.EntityName, 'INT',
            'NULL DEFAULT "0"');
          AddColumn(C, TmpTableName, 'ID_' + TmpEpSubEntity.Name, 'INT',
            'NULL DEFAULT "0"');
        end;

      end;
    end;

    if (ParamEntityProperty is TEPBoolean) then
    begin
      TmpEpBoolean := ParamEntityProperty As TEPBoolean;
      ColumnExist := CheckIfColumnExists(Global_Singleton_DbConnection,
        'entity_' + Self.EntityName, 'EP_' + TmpEpBoolean.Name);
      if Not(ColumnExist) then
        AddColumn(Global_Singleton_DbConnection, 'entity_' + Self.EntityName,
          'EP_' + TmpEpBoolean.Name, 'BOOLEAN', 'NULL DEFAULT FALSE');

      // BOOLEAN is also known as TINYINT
    end;

  end;
end;

// =============================================================================
function TEntity.AddOperation(ParamEntityOperation: TEntityOperation): integer;
Var
  TmpEoLock: TEOLockEdition;
  TmpEoPropertyOperator: TEOPropertyOperator;
  TmpEoPropertyUpdater: TEOPropertyUpdater;
  ColumnExist: Boolean;
begin
  if ParamEntityOperation <> nil then
  begin
    // Self.PropertyCount := Self.PropertyCount + 1;
    SetLength(aOperation, Length(aOperation) + 1);
    aOperation[Length(aOperation) - 1] := ParamEntityOperation;
    LastHandledEO := ParamEntityOperation;

    if (ParamEntityOperation is TEOPropertyOperator) then
    begin
      TmpEoPropertyOperator := ParamEntityOperation As TEOPropertyOperator;
      ColumnExist := CheckIfColumnExists(Global_Singleton_DbConnection,
        'entity_' + Self.EntityName, TmpEoPropertyOperator.GetDbColumnName);
      if Not(ColumnExist) then
        AddColumn(Global_Singleton_DbConnection, 'entity_' + Self.EntityName,
          TmpEoPropertyOperator.GetDbColumnName, 'BOOLEAN',
          'NULL DEFAULT NULL');
      EXIT;
    end;

    if (ParamEntityOperation is TEOPropertyUpdater) then
    begin
      TmpEoPropertyUpdater := ParamEntityOperation As TEOPropertyUpdater;
      ColumnExist := CheckIfColumnExists(Global_Singleton_DbConnection,
        'entity_' + Self.EntityName, TmpEoPropertyUpdater.GetDbColumnName);
      if Not(ColumnExist) then
        AddColumn(Global_Singleton_DbConnection, 'entity_' + Self.EntityName,
          TmpEoPropertyUpdater.GetDbColumnName, 'BOOLEAN', 'NULL DEFAULT NULL');
      EXIT;
    end;

  end;
end;

// =============================================================================
function TEntity.AddDecorator(ParamEntityDecorator: TEntityDecorator): integer;
begin
  if ParamEntityDecorator <> nil then
  begin
    SetLength(aDecorator, Length(aDecorator) + 1);
    aDecorator[Length(aDecorator) - 1] := ParamEntityDecorator;
    LastHandledED := ParamEntityDecorator;
  end;
end;

// =============================================================================
Procedure TEntity.SetName(ParamName: string);
begin
  Self.EntityName := ParamName;
end;

// =============================================================================
Function TEntity.PropertyByName(ParamPropertyName: String): TEntityProperty;
var
  I: integer;
  TmpEP: TEntityProperty;
begin
  if Length(aProperty) = 0 then
  begin
    result := nil;
  end
  else
  begin
    for I := 0 to Length(aProperty) - 1 do
    begin
      TmpEP := aProperty[I] as TEntityProperty;
      if TmpEP.Name = ParamPropertyName then
      begin
        result := TmpEP;
      end;
    end;
  end;
end;

// =============================================================================
Function TEntity.CheckSubEntityPresence(): Boolean;
Var
  I, TmpI: integer;
begin
  TmpI := Self.GetPropertyCount;
  for I := 0 to TmpI - 1 do
  begin
    if Self.aProperty[I] is TEPSubEntity then
    begin
      result := TRUE;
      BREAK;
    end;
  end;
end;

// =============================================================================
Function TEntity.GetInstanceQueryString(ParamInstanceId: String): String;
begin
  if ParamInstanceId = '0' then
  begin
    result := 'SELECT * FROM entity_' + Self.GetEntityName + ';'
  end
  else
  begin
    result := 'SELECT * FROM entity_' + Self.GetEntityName + ' WHERE ID="' +
      ParamInstanceId + '";'
  end;
end;

// =============================================================================
Function TEntity.GetGridQueryString(ParamFilter: TWispFilter): String;
Var
  I, J, TmpI, TmpL: integer;

  TmpS, TmpAlias1, TmpAlias2, TmpVersion, TmpLeftJoinString, TmpConcat,
    TmpFieldFilterString, QueryString, MainTable, MainAlias: String;

  SubEntityPresent, FilterPresent, FieldFilterPresent: Boolean;

  CurrentAlias: Char;

  aTable, aAlias, aSubEntityTable, aLeftJoinString, aSubEntityColumn
    : TArrayOfString;

  TmpEpText: TEPText;
  TmpEpDate: TEPDate;
  TmpEpSubEntity: TEPSubEntity;
  TmpEpBoolean: TEPBoolean;
  TmpEpTime: TEPTime;

  aSubEntityVersion: Array of Boolean;

  TmpFieldFilter: TWispFieldFilter;

  tmpAliasArray: TArrayOfString;

  DuplicatedAlias: Boolean;
begin
  // Check if there is filters to be applied
  if ParamFilter is TWispFieldFilter then
  begin
    FilterPresent := TRUE;
    FieldFilterPresent := TRUE;
  end;

  // Get the number of properties for the current entity
  TmpI := Self.GetPropertyCount;

  // Init some variables
  TmpS := '';
  SubEntityPresent := FALSE;
  CurrentAlias := 'A';
  SetLength(aTable, 0);
  SetLength(aAlias, 0);
  SetLength(aSubEntityTable, 0);
  SetLength(aLeftJoinString, 0);

  // Check if the entity has sub entities as properties
  SubEntityPresent := Self.CheckSubEntityPresence;

  // if their is sub entities we need to register all tables that will be handled
  // and generate an alias for each table
  if SubEntityPresent = TRUE then
  begin
    // Main table will not be registred in table and allias array
    // Will be registred in 2 strings
    MainTable := 'entity_' + Self.GetEntityName;
    MainAlias := CurrentAlias;

    // Managing sub entities ...
    for I := 0 to TmpI - 1 do
    begin
      if Self.aProperty[I] is TEPSubEntity then
      begin
        TmpEpSubEntity := Self.aProperty[I] As (TEPSubEntity);

        if TmpEpSubEntity.Multi = FALSE then
        begin
          SetLength(aTable, Length(aTable) + 1);
          aTable[Length(aTable) - 1] := 'entity_' +
            TmpEpSubEntity.SubEntityName;

          SetLength(aAlias, Length(aAlias) + 1);
          Inc(CurrentAlias);
          aAlias[Length(aAlias) - 1] := CurrentAlias;

          // Generate list of tables where sub entities are stored
          // Used to generate LEFT JOIN strings
          SetLength(aSubEntityTable, Length(aSubEntityTable) + 1);
          aSubEntityTable[Length(aSubEntityTable) - 1] := 'entity_' +
            TmpEpSubEntity.SubEntityName;

          // Data For LEFT JOINT strings
          SetLength(aSubEntityColumn, Length(aSubEntityColumn) + 1);
          aSubEntityColumn[Length(aSubEntityColumn) - 1] :=
            TmpEpSubEntity.GetDbColumnName;

          SetLength(aSubEntityVersion, Length(aSubEntityVersion) + 1);
          aSubEntityVersion[Length(aSubEntityVersion) - 1] :=
            TmpEpSubEntity.UseLastEntityVersion;
        end;
      end;
    end;

  end;

  // if their is sub entities we generate LEFT JOIN strings
  if SubEntityPresent = TRUE then
  begin
    for I := 0 to Length(aSubEntityTable) - 1 do
    begin
      TmpAlias1 := GetAliasFromTable(aSubEntityTable[I], aTable, aAlias);
      TmpAlias2 := MainAlias;

      // Add TmpAlias1 to TmpAliasArray if it is not already in the TmpAliasArray,
      // to avoid duplicated aliases (which cause an error with LEFT JOIN)
      DuplicatedAlias := CheckIfArrayContainString(tmpAliasArray, TmpAlias1);
      if DuplicatedAlias = FALSE then
      begin
        PushStringArray(tmpAliasArray, TmpAlias1);
      end;

      if aSubEntityVersion[I] = FALSE then
        TmpVersion := 'ID'
      else
        TmpVersion := 'ENTITY_ID';

      if DuplicatedAlias = FALSE then
      begin
        TmpS := 'LEFT JOIN ' + aSubEntityTable[I] + ' AS ' + TmpAlias1 + ' ON '
          + TmpAlias2 + '.' + aSubEntityColumn[I] + ' = ' + TmpAlias1 + '.' +
          TmpVersion + ' AND ' + TmpAlias1 + '.' + 'IS_LAST = 1';
      end
      else
      begin
        TmpS := 'LEFT JOIN ' + aSubEntityTable[I] + ' ON ' + TmpAlias2 + '.' +
          aSubEntityColumn[I] + ' = ' + TmpAlias1 + '.' + TmpVersion + ' AND ' +
          TmpAlias1 + '.' + 'IS_LAST = 1';
      end;

      SetLength(aLeftJoinString, Length(aLeftJoinString) + 1);
      aLeftJoinString[Length(aLeftJoinString) - 1] := TmpS;

    end;
  end;

  // Clear String
  TmpS := '';

  // Prevent aAlias[0] from being not accesible
  if SubEntityPresent = FALSE then
  begin
    SetLength(aAlias, Length(aAlias) + 1);
    aAlias[Length(aAlias) - 1] := '';
  end;

  // Generate the query string
  for I := 0 to TmpI - 1 do
  begin
    if Self.aProperty[I] is TEPText then
    begin
      TmpEpText := Self.aProperty[I] As (TEPText);

      TmpS := TmpS + ConditionalString(SubEntityPresent, MainAlias + '.') +
        TmpEpText.GetDbColumnName + ' AS ' + '"' + TmpEpText.LabelText + '"';
      if I < TmpI - 1 then
        TmpS := TmpS + ',';
    end
    else if Self.aProperty[I] is TEPDate then
    begin
      TmpEpDate := Self.aProperty[I] As (TEPDate);

      TmpS := TmpS + ConditionalString(SubEntityPresent, MainAlias + '.') +
        TmpEpDate.GetDbColumnName + ' AS ' + '"' + TmpEpDate.LabelText + '"';
      if I < TmpI - 1 then
        TmpS := TmpS + ',';
    end
    else if Self.aProperty[I] is TEPTime then
    begin
      TmpEpTime := Self.aProperty[I] As (TEPTime);

      TmpS := TmpS + ConditionalString(SubEntityPresent, MainAlias + '.') +
        TmpEpTime.GetDbColumnName + ' AS ' + '"' + TmpEpTime.LabelText + '"';
      if I < TmpI - 1 then
        TmpS := TmpS + ',';
    end
    else if Self.aProperty[I] is TEPSubEntity then
    begin
      TmpEpSubEntity := Self.aProperty[I] As (TEPSubEntity);

      if TmpEpSubEntity.Multi = FALSE then
      begin
        // Single
        TmpL := Length(TmpEpSubEntity.SubEntityProperties);
        TmpAlias1 := GetAliasFromTable('entity_' + TmpEpSubEntity.SubEntityName,
          aTable, aAlias);
        TmpConcat := '';

        for J := 0 to TmpL - 1 do
        begin
          TmpConcat := TmpConcat + TmpAlias1 + '.EP_' +
            TmpEpSubEntity.SubEntityProperties[J];
          if J < TmpL - 1 then
            TmpConcat := TmpConcat + '," ",';
        end;

        TmpConcat := 'CONCAT(' + TmpConcat + ')';

        TmpS := TmpS + TmpConcat + ' AS ' + '"' +
          TmpEpSubEntity.LabelText + '"';
        if I < TmpI - 1 then
          TmpS := TmpS + ',';

      end
      else
      begin
        // Multi
        TmpS := TmpS + '0 AS ' + '"' + TmpEpSubEntity.LabelText + '"';
        if I < TmpI - 1 then
          TmpS := TmpS + ',';
      end;
    end
    else if Self.aProperty[I] is TEPBoolean then
    begin
      TmpEpBoolean := Self.aProperty[I] As (TEPBoolean);

      TmpS := TmpS + 'IF(' + ConditionalString(SubEntityPresent,
        MainAlias + '.') + TmpEpBoolean.GetDbColumnName + ', "' +
        TmpEpBoolean.TrueLabel + '", "' + TmpEpBoolean.FalseLabel + '")' +
        ' AS ' + '"' + TmpEpBoolean.LabelText + '"';
      if I < TmpI - 1 then
        TmpS := TmpS + ',';
    end;
  end;

  // Left Joint String
  TmpLeftJoinString := '';
  for I := 0 to Length(aLeftJoinString) - 1 do
  begin
    TmpLeftJoinString := TmpLeftJoinString + aLeftJoinString[I] + ' ';
  end;

  // Filed Filter
  if FieldFilterPresent then
  begin
    TmpFieldFilter := ParamFilter as TWispFieldFilter;
    TmpFieldFilterString := ' AND ' + TmpFieldFilter.SourceFiledName + '= "' +
      TmpFieldFilter.SearchFor + '"';
  end;

  QueryString := 'SELECT ' + ConditionalString(SubEntityPresent,
    MainAlias + '.') + 'ID, ' + ConditionalString(SubEntityPresent,
    MainAlias + '.') + 'ENTITY_ID, ' + ConditionalString(SubEntityPresent,
    MainAlias + '.') + 'VERSION_ID, ' + TmpS + ' FROM entity_' +
    Self.GetEntityName + ConditionalString(SubEntityPresent, ' AS ' + MainAlias)
    + ConditionalString(SubEntityPresent, ' ' + TmpLeftJoinString) + ' WHERE ' +
    ConditionalString(SubEntityPresent, MainAlias + '.') + 'IS_LAST="1" AND ' +
    ConditionalString(SubEntityPresent, MainAlias + '.') + 'IS_DELETED="0"' +
    TmpFieldFilterString + ';';

  result := QueryString;
end;

// =============================================================================
Function TEntity.GetDefaultValueOf(ParamDefaultValueObject: TWispDefaultValue;
  ParamEntityProperty: TEntityProperty = nil;
  ParamInstanceId: String = ''): String;
Var
  S: String;
begin
  //
  if ParamDefaultValueObject is TWispDVSimple then
  begin
    result := TWispDVSimple(ParamDefaultValueObject).Value;
  end
  //
  else if ParamDefaultValueObject is TWispDVEntityId then
  begin
    S := OpenQuery(Global_Singleton_DbConnection,
      Self.GetInstanceQueryString(ParamInstanceId))
      .ZQuery.FieldByName('ENTITY_ID').AsString;

    result := S;
  end
  //
  else if ParamDefaultValueObject is TWispDVCurrentDate then
  begin
    result := GetDateFromServer;
  end
  //
  else if ParamDefaultValueObject is TWispDVCurrentTime then
  begin
    result := GetTimeFromServer;
  end
  //
  else
  begin
    result := '';
  end;
end;

// =============================================================================
Constructor TEntityProperty.Create;
begin
  inherited Create;
  Editable := TRUE;
  LastHandledEP := Self;
  FGroupName := '';
end;

// =============================================================================
Function TEntityProperty.GetDbColumnName(): String;
begin
  result := FDbColNamePrefix + FName + FDbColNameSuffix;
end;

// =============================================================================
constructor TEPText.Create(ParamPropertyName, ParamLabelText: string;
  ParamLineCount: integer = 1);
begin
  Inherited Create;
  FName := ParamPropertyName;
  FLabelText := ParamLabelText;
  FDbColNamePrefix := 'EP_';
  FDefaultValue := nil;
  FLineCount := ParamLineCount;
end;

// =============================================================================
constructor TEPDate.Create(ParamPropertyName, ParamLabelText: string);
begin
  Inherited Create;
  FName := ParamPropertyName;
  FLabelText := ParamLabelText;
  FDbColNamePrefix := 'EP_';
  FDefaultValue := nil;
end;

// =============================================================================
constructor TEPTime.Create(ParamPropertyName, ParamLabelText: string);
begin
  Inherited Create;
  FName := ParamPropertyName;
  FLabelText := ParamLabelText;
  FDbColNamePrefix := 'EP_';
  FDefaultValue := nil;
end;

// =============================================================================
Constructor TEPSubEntity.Create(ParamPropertyName, ParamLabelText,
  ParamSubEntityName: string; ParamSubEntityProperties: String;
  ParamUseLastEntityVersion: Boolean; ParamMulti: Boolean = FALSE);
begin
  Inherited Create;
  FName := ParamPropertyName;
  FLabelText := ParamLabelText;
  FSubEntityName := ParamSubEntityName;
  FSubEntityProperties := WispStringSplit(ParamSubEntityProperties, ',');
  FUseLastEntityVersion := ParamUseLastEntityVersion;
  FMulti := ParamMulti;
  FDbColNamePrefix := 'ID_';
  FDefaultValue := nil;
end;

// =============================================================================
constructor TEPBoolean.Create(ParamPropertyName, ParamLabelText, ParamTrueLabel,
  ParamFalseLabel: string);
begin
  Inherited Create;
  FName := ParamPropertyName;
  FLabelText := ParamLabelText;
  FTrueLabel := ParamTrueLabel;
  FFalseLabel := ParamFalseLabel;
  FDbColNamePrefix := 'EP_';
  FDefaultValue := nil;
end;

// =============================================================================
Constructor TEntityOperation.Create;
begin
  inherited Create;
  LastHandledEO := Self;
end;

// =============================================================================
Function TEntityOperation.GetDbColumnName(): String;
begin
  result := FDbColNamePrefix + FName + FDbColNameSuffix;
end;

// =============================================================================
Constructor TEOLockEdition.Create(ParamOperationName, ParamDisplayName,
  ParamConfirmationProperty: string);
begin
  inherited Create;
  FName := ParamOperationName;
  FLabel := ParamDisplayName;
  FConfirmationEPBooleanName := ParamConfirmationProperty;
end;

// =============================================================================
Constructor TEOPropertyOperator.Create(ParamOperationName, ParamOperationLabel,
  ParamTargetSubEntity, ParamTargetProperty, ParamSourceProperty, ParamOperator,
  ParamConfirmationBoolean: String);
begin
  inherited Create;
  FDbColNamePrefix := 'EO_';
  FName := ParamOperationName;
  FLabel := ParamOperationLabel;
  FTargetSubEntity := ParamTargetSubEntity;
  FTargetProperty := ParamTargetProperty;
  FSourceProperty := ParamSourceProperty;
  FOperator := ParamOperator;
  FConfirmationEPBooleanName := ParamConfirmationBoolean;
end;

// =============================================================================
Constructor TEOPropertyUpdater.Create(ParamOperationName, ParamOperationLabel,
  ParamTargetSubEntity, ParamTargetProperty, ParamSourceProperty,
  ParamConfirmationBoolean: String);
begin
  inherited Create;
  FDbColNamePrefix := 'EO_';
  FName := ParamOperationName;
  FLabel := ParamOperationLabel;
  FTargetSubEntity := ParamTargetSubEntity;
  FTargetProperty := ParamTargetProperty;
  FSourceProperty := ParamSourceProperty;
  FConfirmationEPBooleanName := ParamConfirmationBoolean;
end;

// =============================================================================
Constructor TEntityDecorator.Create;
begin
  inherited Create;
  LastHandledED := Self;
end;

// =============================================================================
Function TEntityDecorator.GetDbColumnName(): String;
begin
  result := FDbColNamePrefix + FName + FDbColNameSuffix;
end;

// =============================================================================
Constructor TEDTimeAlert.Create(ParamDecoratorName, ParamOriginDateProperty,
  ParamOriginTimeProperty, ParamOffsetProperty, ParamOffsetUnit: String;
  ParamOffsetDirection: Boolean);
begin
  inherited Create;
  FName := ParamDecoratorName;
  FOriginDateProperty := ParamOriginDateProperty;
  FOriginTimeProperty := ParamOriginTimeProperty;
  FOffsetProperty := ParamOffsetProperty;
  FOffsetUnit := ParamOffsetUnit;
  FOffsetDirection := ParamOffsetDirection;

  LastHandledED := Self;
end;

end.
