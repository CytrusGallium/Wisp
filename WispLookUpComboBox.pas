unit WispLookUpComboBox;

interface

uses
  cxDBLookUpComboBox,
  cxDBExtLookUpComboBox,
  cxDropDownEdit,
  cxLabel,
  Controls,
  StdCtrls,
  Classes,
  SysUtils,
  Dialogs,
  ZDataset,
  Data.DB,
  WispQueryTools,
  WispDbConnection,
  WispEntity,
  WispVisualComponent,
  WispStrTools,
  WispStyleManager,
  WispGrid,
  cxGrid,
  cxGridLevel,
  cxGridTableView,
  cxGridDbTableView,
  CxGridCustomTableView,
  cxDataStorage,
  cxCheckBox,
  WispViewTools,
  Variants;

type
  TWispLookUpComboBox = Class(TWispVisualComponent)
  private
    Spacing: integer;
    DS: TDataSource;
    Q: TZQuery;
    FMulti: Boolean;
    ViewRepository: TcxGridViewRepository;
    GridMainLevel: TCxGridLevel;
    GridMainView: TcxGridDbTableView;
    FIdColumn: TcxGridDBColumn;
    FStateColumn: TcxGridDBColumn;
    FNameColumn: TcxGridDBColumn;
    FCheckColumn: TcxGridDBColumn;
  public
    Lbl: TcxLabel;
    LookUpComboBox: TcxExtLookUpComboBox;
    // GridLookUpComboBox: TcxExtLookUpComboBox;
    Property Multi: Boolean Read FMulti;
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl;
      ParamEdtWidth, ParamX, ParamY: integer; ParamCaption: String;
      ParamSubEntity: TEPSubEntity = nil; ParamMultiSelection: Boolean = FALSE);
    procedure CenterHorizontally;
    Function GetKey(ParamItemIndex: integer): String;
    Function GetItem(ParamKey: String): integer;
    Procedure LoadFromTable(ParamTableName, ParamColumns, ParamLabel: String;
      ParamIdColumn: String = 'ID');
    Procedure MultiSaveToTable(ParamTableName, ParamParentName,
      ParamId: String);
    Procedure MultiLoadFromTable(ParamTableName, ParamParentName,
      ParamId: String);
    procedure OnViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  End;

implementation

// =============================================================================
Constructor TWispLookUpComboBox.Create(ParamOwner: TComponent;
  ParamParent: TWinControl; ParamEdtWidth, ParamX, ParamY: integer;
  ParamCaption: String; ParamSubEntity: TEPSubEntity = nil;
  ParamMultiSelection: Boolean = FALSE);
Var
  QueryStr, ConcatStr, IdStr: String;
  I: integer;
  TmpField: TField;
begin

  FMulti := ParamMultiSelection;

  // Label
  Lbl := TcxLabel.Create(ParamOwner);
  with Lbl do
  begin
    Height := 16;
    Width := ParamEdtWidth;
    Parent := ParamParent;
    ParentFont := FALSE;
    Caption := ParamCaption;
    Left := ParamX;
    Top := ParamY;
    Transparent := TRUE;
    Style.TextColor := Global_Singleton_Style.TextColor;
    Style.Font.Name := Global_Singleton_Style.DefaultFont;
  end;

  // Query and Datasource
  if ParamSubEntity <> nil then
  begin
    if ParamSubEntity.UseLastEntityVersion then
      IdStr := 'ENTITY_ID'
    else
      IdStr := 'ID';

    ConcatStr := '';
    for I := 0 to Length(ParamSubEntity.SubEntityProperties) - 1 do
    begin
      ConcatStr := ConcatStr + 'EP_' + ParamSubEntity.SubEntityProperties[I];
      if I < Length(ParamSubEntity.SubEntityProperties) - 1 then
        ConcatStr := ConcatStr + '," ",';
    end;
    ConcatStr := '(' + ConcatStr + ')';

    QueryStr := 'SELECT ' + IdStr + ' AS ID, CONCAT' + ConcatStr +
      ' AS Name FROM entity_' + ParamSubEntity.SubEntityName +
      ' WHERE IS_LAST = "1" AND IS_DELETED = "0";';

    Q := CreateDataSet(C);
    DS := CreateDataSource(Q);
    Q.Sql.Clear;
    Q.Sql.Add(QueryStr);
    Q.Open;
  end;

  // View repository
  ViewRepository := TcxGridViewRepository.Create(ParamOwner);

  // Multi
  if ParamMultiSelection = TRUE then
  begin
    // View
    GridMainView := ViewRepository.CreateItem(TcxGridDbTableView)
      as TcxGridDbTableView;
    with GridMainView do
    begin
      DataController.DataSource := DS;
      DataController.DetailKeyFieldNames := 'Name';
      DataController.KeyFieldNames := 'Name';
      DataController.DataModeController.GridMode := FALSE;
      DataController.DataModeController.SmartRefresh := TRUE;

      OptionsView.ScrollBars := ssVertical;

      OptionsView.GroupByBox := FALSE;
      OptionsCustomize.ColumnFiltering := FALSE;
      OptionsData.Deleting := FALSE;
      OptionsView.Header := FALSE;

      FCheckColumn := CreateColumn;
      FCheckColumn.Name := 'CheckColumn_' + ParamSubEntity.SubEntityName;
      FCheckColumn.Caption := 'Check';
      FCheckColumn.DataBinding.ValueTypeClass := TcxBooleanValueType;
      FCheckColumn.Width := 20;

      FCheckColumn.PropertiesClass := TcxCheckBoxProperties;
      with FCheckColumn.Properties as TcxCheckBoxProperties do
      begin
        AllowGrayed := FALSE;
        ValueChecked := TRUE;
        ValueUnchecked := FALSE;
        NullStyle := nssUnchecked;
      end;

      OptionsData.Editing := TRUE;

      FIdColumn := CreateColumn;
      FIdColumn.DataBinding.FieldName := 'ID';
      FIdColumn.Visible := FALSE;

      FNameColumn := CreateColumn;
      FNameColumn.DataBinding.FieldName := 'Name';
      FNameColumn.Width := 256;

      // ...
      ApplyBestFit;

    end;

    // Lookup ComboBox
    LookUpComboBox := TcxExtLookUpComboBox.Create(ParamOwner);
    with LookUpComboBox do
    begin
      Width := ParamEdtWidth;
      Height := 32;
      Parent := ParamParent;
      ParentFont := FALSE;
      Text := '';
      Left := ParamX;
      Top := ParamY + Lbl.Height + Spacing;

      Properties.DropDownListStyle := lsEditList;
      Properties.FocusPopup := TRUE;
      Properties.View := GridMainView;
      Properties.KeyFieldNames := 'Name';
      Properties.ListFieldItem := FNameColumn;

    end;

    MaximizeColumnWidth(GridMainView, LookUpComboBox.Width);
  end
  // Single
  else
  begin
    // View
    GridMainView := ViewRepository.CreateItem(TcxGridDbTableView)
      as TcxGridDbTableView;
    with GridMainView do
    begin
      DataController.DataSource := DS;
      DataController.DetailKeyFieldNames := 'Name';
      DataController.KeyFieldNames := 'Name';
      DataController.DataModeController.GridMode := FALSE;
      DataController.DataModeController.SmartRefresh := TRUE;

      OptionsView.ScrollBars := ssVertical;

      OptionsView.GroupByBox := FALSE;
      OptionsCustomize.ColumnFiltering := FALSE;
      OptionsData.Deleting := FALSE;
      OptionsView.Header := FALSE;

      OptionsData.Editing := TRUE;

      FIdColumn := CreateColumn;
      FIdColumn.DataBinding.FieldName := 'ID';
      FIdColumn.Visible := FALSE;

      FNameColumn := CreateColumn;
      FNameColumn.DataBinding.FieldName := 'Name';
      FNameColumn.Width := 256;

      // ...
      ApplyBestFit;

    end;

    // Lookup ComboBox
    LookUpComboBox := TcxExtLookUpComboBox.Create(ParamOwner);
    with LookUpComboBox do
    begin
      Width := ParamEdtWidth;
      Height := 32;
      Parent := ParamParent;
      ParentFont := FALSE;
      Text := '';
      Left := ParamX;
      Top := ParamY + Lbl.Height + Spacing;

      Properties.DropDownListStyle := lsEditList;
      Properties.FocusPopup := FALSE;
      Properties.View := GridMainView;
      Properties.KeyFieldNames := 'Name';
      Properties.ListFieldItem := FNameColumn;

      if ParamSubEntity <> nil then
      begin

      end;

    end;

    MaximizeColumnWidth(GridMainView, LookUpComboBox.Width);
  end;

end;

// =============================================================================
procedure TWispLookUpComboBox.CenterHorizontally;
Var
  TmpInt: integer;
begin
  TmpInt := Round((LookUpComboBox.Parent.Width - LookUpComboBox.Width) / 2);
  Lbl.Left := TmpInt;
  LookUpComboBox.Left := TmpInt;
end;

// =============================================================================
Function TWispLookUpComboBox.GetKey(ParamItemIndex: integer): String;
Var
  I: integer;
begin
  if ParamItemIndex = -1 then
  begin
    Result := '0';
  end
  else if ParamItemIndex = 0 then
  begin
    Q.First;
    Result := Q.FieldByName('ID').AsString
  end
  else
  begin
    Q.First;
    for I := 0 to ParamItemIndex - 1 do
    begin
      Q.Next;
      Result := Q.FieldByName('ID').AsString;
    end;

  end;
end;

// =============================================================================
Function TWispLookUpComboBox.GetItem(ParamKey: String): integer;
Var
  I: integer;
begin
  if Q.RecordCount = 0 then
    Result := -1
  else
  begin
    Q.First;
    for I := 0 to Q.RecordCount do
    begin
      if Q.FieldByName('ID').AsString = ParamKey then
      begin
        Result := I;
        EXIT;
      end
      else
        Q.Next;
    end;

  end;
  Result := -1;
  // needs optimization, so that if no ID is present in the DB the lookup loads empty
end;

// =============================================================================
Procedure TWispLookUpComboBox.LoadFromTable(ParamTableName, ParamColumns,
  ParamLabel: String; ParamIdColumn: String = 'ID');
Var
  QueryStr, ConcatStr, IdStr: String;
  I: integer;
  Columns: TArrayOfString;
begin

  IdStr := ParamIdColumn;
  Columns := WispStringSplit(ParamColumns, ',');

  ConcatStr := '';
  for I := 0 to Length(Columns) - 1 do
  begin
    ConcatStr := ConcatStr + Columns[I];
    if I < Length(Columns) - 1 then
      ConcatStr := ConcatStr + '," ",';
  end;
  ConcatStr := '(' + ConcatStr + ')';

  QueryStr := 'SELECT ' + IdStr + ' AS ID, CONCAT' + ConcatStr + ' AS ' +
    ParamLabel + ' FROM ' + ParamTableName + ';';

  Q := CreateDataSet(Global_Singleton_DbConnection);
  DS := CreateDataSource(Q);
  Q.Sql.Clear;
  Q.Sql.Add(QueryStr);
  Q.Open;

  with LookUpComboBox do
  begin
    // Properties.ListSource := DS;
    Properties.KeyFieldNames := 'ID';
    // Properties.ListColumns.Add.FieldName := 'ID';
    // Properties.ListColumns.Add.FieldName := ParamLabel;
    // Properties.ListFieldIndex := 0;
    // Properties.ListOptions.ShowHeader := FALSE;
  end;

end;

// =============================================================================
procedure TWispLookUpComboBox.OnViewCellClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
Var
  Row, Col: integer;
begin
  Row := ACellViewInfo.GridRecord.Index;
  Col := ACellViewInfo.Item.Index;

  // showmessage(IntToStr(ACellViewInfo.Item.Index));
  // showmessage(IntToStr(ACellViewInfo.GridRecord.Index));

  // GridMainView.ViewData.Rows[ACellViewInfo.GridRecord.Index].Values
  // [ACellViewInfo.Item.Index] := TRUE;
end;

// =============================================================================
procedure TWispLookUpComboBox.MultiSaveToTable(ParamTableName, ParamParentName,
  ParamId: String);
Var
  QueryString: String;
  I: integer;

  VTS: String;
  B: Boolean;
  D: Double;

  aColumn: TArrayOfString;
  aValue: TArrayOfString;

begin

  if (LinkedEpName = '') or (FMulti = FALSE) then
  begin
    EXIT;
  end
  else
  begin
    // Delete existing childs ...
    ExecuteQuery(C, 'DELETE FROM ' + ParamTableName + ' WHERE ID_' +
      ParamParentName + ' = ' + ParamId);

    // Build insert columns and values
    for I := 0 to GridMainView.ViewData.RecordCount - 1 do
    begin
      VTS := VarToStr(GridMainView.ViewData.Rows[I].Values[0]);

      if (VTS = 'True') then
        B := TRUE
      else
        B := FALSE;

      if B then
      begin
        D := GridMainView.ViewData.Rows[I].Values[1];

        PushStringArray(aColumn, 'ID_' + ParamParentName);
        PushStringArray(aValue, ParamId);

        PushStringArray(aColumn, 'ID_' + LinkedEpName);
        PushStringArray(aValue, FloatToStr(D));

        ExecuteSqlInsert(C, ParamTableName, aColumn, aValue);

        SetLength(aColumn, 0);
        SetLength(aValue, 0);
      end;
    end;

  end;

end;

// =============================================================================
procedure TWispLookUpComboBox.MultiLoadFromTable(ParamTableName,
  ParamParentName, ParamId: String);
Var
  TmpQuery: TZQuery;
  I, J, TmpI: integer;
  TmpS: String;
begin
  TmpQuery := OpenQuery(C, 'SELECT * FROM ' + ParamTableName + ' WHERE ID_' +
    ParamParentName + ' = ' + ParamId).ZQuery;

  TmpQuery.First;

  // for I := 0 to GridMainView.ViewData.RecordCount - 1 do
  // begin
  // GridMainView.ViewData.Rows[I].Values[0] := 'TRUE';
  // end;

  for I := 0 to TmpQuery.RecordCount - 1 do
  begin
    TmpS := TmpQuery.FieldByName('ID_' + LinkedEpName).AsString;

    for J := 0 to GridMainView.ViewData.RecordCount - 1 do
    begin
      if GridMainView.ViewData.Rows[J].Values[1] = TmpS then
      begin
        GridMainView.ViewData.Rows[J].Values[0] := 'TRUE';
      end;
    end;
    TmpQuery.Next;
  end;

end;

end.
