unit WispEntityGrid;

interface

uses
  Dialogs,
  Forms,
  StdCtrls,
  ExtCtrls,
  Graphics,
  Controls,
  Classes,
  SysUtils,
  cxTextEdit,
  cxButtons,
  WispEditBox,
  WispDatePicker,
  WispEntity,
  WispArrayTools,
  WispEntityManager,
  WispQueryTools,
  WispDbConnection,
  WispTimeTools,
  WispViewTools,
  WispStrTools,
  CxGrid,
  CxGridLevel,
  CxGridTableView,
  CxGridDbTableView,
  CxStyles,
  CxGridCustomTableView,
  frxClass,
  frxDesgn,
  frxDBSet,
  ZDataset,
  DB,
  WispConstantManager,
  WispQueryFilter,
  WispStyleManager,
  WispImageTools,
  WispButton,
  WispAccesManager,
  WispGrid;

type
  TEntityGrid = Class(TObject)
  private
    FormEntityGrid: TForm;
    PanelEntityGrid: TPanel;
    CurrentEntity: TEntity;
    PanelTop: TPanel;
    Grid: TWispGrid;
    QueryString: String;
    EOLockPresent: Boolean;
    BtnAdd, BtnEdit, BtnDelete, BtnLock, BtnPrint, BtnQuickSearch, BtnRefresh,
      BtnDuplicate: TWispButton;
    EOLockDbColumnName, EOLockColumnName, EOLockValue: String;
    HasController: Boolean;
    FirstPrintAttempt: Boolean;
    procedure BtnAdd_OnClick(Sender: TObject);
    procedure BtnEdit_OnClick(Sender: TObject);
    procedure BtnDelete_OnClick(Sender: TObject);
    procedure BtnLock_OnClick(Sender: TObject);
    procedure BtnPrint_OnClick(Sender: TObject);
    procedure BtnQuickSearch_OnClick(Sender: TObject);
    procedure BtnRefresh_OnClick(Sender: TObject);
    procedure BtnDuplicate_OnClick(Sender: TObject);
  protected
  public
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl;
      ParamEntityName: String);
    Procedure RefreshGrid;
    Function GetAliasFromTable(ParamTableName: string;
      ParamTables, ParamAliases: TArrayOfString): String;
    procedure OnFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    Procedure RefreshButtons;
    Function PrepareReportForPrinting(): Boolean;
  end;

implementation

uses
  WispMainMenuManager,
  CxPC;

// =============================================================================
procedure TEntityGrid.RefreshGrid;
begin
  // ...
  HasController := FALSE;

  ShowQueryResult(Global_Singleton_DbConnection, QueryString, Grid);

  Grid.GridMainView.Columns[GetColumnIndexFromColumnCaption(Grid.GridMainView,
    'ID')].Visible := FALSE;
  Grid.GridMainView.Columns[GetColumnIndexFromColumnCaption(Grid.GridMainView,
    'ENTITY_ID')].Visible := FALSE;
  Grid.GridMainView.Columns[GetColumnIndexFromColumnCaption(Grid.GridMainView,
    'VERSION_ID')].Visible := FALSE;

  // Auto resize columns
  Grid.GridMainView.ApplyBestFit();
  MaximizeColumnWidth(Grid.GridMainView as TcxGridDBTableView,
    FormEntityGrid.Parent.Width);

  // ...
  HasController := TRUE;
  RefreshButtons;
end;

// =============================================================================
Constructor TEntityGrid.Create(ParamOwner: TComponent; ParamParent: TWinControl;
  ParamEntityName: String);
Var
  I: Integer;
  TmpEpBoolean: TEPBoolean;
  TmpEoLockEdition: TEOLockEdition;
  StyleMetroGrey: TcxStyle;
begin
  // remove later plz , or maybe just keep it ...
  // basicly this is here because fast report was unable to show report print preview
  // at first attempt, so i trick him to prepare the report without showing the preview
  // using a function
  // 22 Feb 2017 : Problem seems to be solved
  // FirstPrintAttempt := TRUE;

  // Select the current entity to view
  CurrentEntity := Global_Singleton_EntityManager.GetEntityByName
    (ParamEntityName);

  // Check if the entity have a lock edition operation
  if Length(CurrentEntity.aOperation) = 0 then
  begin
    EOLockPresent := FALSE;
  end
  else
  begin
    for I := 0 to Length(CurrentEntity.aOperation) - 1 do
    begin
      if CurrentEntity.aOperation[I] is TEOLockEdition then
      begin
        TmpEoLockEdition := CurrentEntity.aOperation[I] as TEOLockEdition;
        EOLockPresent := TRUE;
        TmpEpBoolean := CurrentEntity.PropertyByName
          (TmpEoLockEdition.ConfirmationEPBooleanName) as TEPBoolean;
        EOLockDbColumnName := TmpEpBoolean.GetDbColumnName;
        EOLockColumnName := TmpEpBoolean.LabelText;
        EOLockValue := TmpEpBoolean.TrueLabel;
        BREAK;
      end;
    end;
  end;

  // Create the entity grid form
  FormEntityGrid := TForm.Create(ParamOwner);
  with FormEntityGrid do
  begin
    BorderStyle := bsNone;
    Color := Global_Singleton_Style.BgColor;
    Parent := ParamParent;
    Align := alClient;
  end;

  // Create the toolbar panel
  PanelTop := TPanel.Create(FormEntityGrid);
  With PanelTop do
  begin
    Caption := '';
    Parent := FormEntityGrid;
    ParentBackground := FALSE;
    Color := Global_Singleton_Style.BgColor;
    Align := alTop;
    Width := Screen.Width;
    Height := 32;
  end;

  // BG
  DrawBgImage(PanelTop);

  // Create Toolbar buttons
  if Global_Singleton_AccesManager.CurrentProfile.GetAcces
    ('ENTITY_' + CurrentEntity.GetEntityName + '_ADD') then
  begin
    BtnAdd := TWispButton.Create(PanelTop);
    with BtnAdd do
    begin
      Parent := PanelTop;
      Width := 72;
      Height := 24;
      Caption := Global_Singleton_ConstantManager.GetLanguageConst('Add');
      Top := 4;
      Align := alLeft;
      OnClick := BtnAdd_OnClick;
    end;
  end;

  // Create Toolbar buttons
  if Global_Singleton_AccesManager.CurrentProfile.GetAcces
    ('ENTITY_' + CurrentEntity.GetEntityName + '_EDIT') then
  begin
    BtnEdit := TWispButton.Create(PanelTop);
    with BtnEdit do
    begin
      Parent := PanelTop;
      Width := 72;
      Height := 24;
      Caption := Global_Singleton_ConstantManager.GetLanguageConst('Edit');
      Top := 4;
      Align := alLeft;
      OnClick := BtnEdit_OnClick;
    end;
  end;

  // Create Toolbar buttons
  if Global_Singleton_AccesManager.CurrentProfile.GetAcces
    ('ENTITY_' + CurrentEntity.GetEntityName + '_DELETE') then
  begin
    BtnDelete := TWispButton.Create(PanelTop);
    with BtnDelete do
    begin
      Parent := PanelTop;
      Width := 72;
      Height := 24;
      Caption := Global_Singleton_ConstantManager.GetLanguageConst('Delete');
      Top := 4;
      Align := alLeft;
      OnClick := BtnDelete_OnClick;
    end;
  end;

  // Create Toolbar buttons
  if (EOLockPresent) and Global_Singleton_AccesManager.CurrentProfile.GetAcces
    ('ENTITY_' + CurrentEntity.GetEntityName + '_LOCK') then
  begin
    BtnLock := TWispButton.Create(PanelTop);
    with BtnLock do
    begin
      Parent := PanelTop;
      Width := 72;
      Height := 24;
      Caption := Global_Singleton_ConstantManager.GetLanguageConst('Lock');
      Top := 4;
      Align := alLeft;
      OnClick := BtnLock_OnClick;
    end;
  end;

  // Create Toolbar buttons
  BtnPrint := TWispButton.Create(PanelTop);
  with BtnPrint do
  begin
    Parent := PanelTop;
    Width := 72;
    Height := 24;
    Caption := Global_Singleton_ConstantManager.GetLanguageConst('Print');
    Top := 4;
    Align := alLeft;
    OnClick := BtnPrint_OnClick;
  end;

  // Create Toolbar buttons
  if CurrentEntity.QuickSearchProperty <> nil then
  begin
    BtnQuickSearch := TWispButton.Create(PanelTop);
    with BtnQuickSearch do
    begin
      Parent := PanelTop;
      Width := 128;
      Height := 24;
      Caption := Global_Singleton_ConstantManager.GetLanguageConst
        ('QuickSearch');
      Top := 4;
      Align := alLeft;
      OnClick := BtnQuickSearch_OnClick;
    end;
  end;

  // Create Toolbar buttons
  BtnRefresh := TWispButton.Create(PanelTop);
  with BtnRefresh do
  begin
    Parent := PanelTop;
    Width := 72;
    Height := 24;
    Caption := Global_Singleton_ConstantManager.GetLanguageConst('Refresh');
    Top := 4;
    Align := alLeft;
    OnClick := BtnRefresh_OnClick;
  end;

  // Create Toolbar buttons
  if Global_Singleton_AccesManager.CurrentProfile.GetAcces
    ('ENTITY_' + CurrentEntity.GetEntityName + '_ADD') then
  begin
    BtnDuplicate := TWispButton.Create(PanelTop);
    with BtnDuplicate do
    begin
      Parent := PanelTop;
      Width := 72;
      Height := 24;
      Caption := Global_Singleton_ConstantManager.GetLanguageConst('Duplicate');
      Top := 4;
      Align := alLeft;
      OnClick := BtnDuplicate_OnClick;
    end;
  end;

  Grid := TWispGrid.Create(FormEntityGrid);

  Grid.GridMainView.OnFocusedRecordChanged := OnFocusedRecordChanged;

  QueryString := CurrentEntity.GetGridQueryString(nil);

  RefreshGrid;

  FormEntityGrid.Show;

end;

// =============================================================================
procedure TEntityGrid.BtnAdd_OnClick(Sender: TObject);
begin
  Global_Singleton_MainMenuManager.NewEntityEditor(CurrentEntity.GetEntityName);
end;

// =============================================================================
procedure TEntityGrid.BtnDuplicate_OnClick(Sender: TObject);
Var
  TmpId: Integer;
begin
  TmpId := Grid.GridMainView.Controller.FocusedRow.Values[0];
  CurrentEntity.DuplicateInstance(IntToStr(TmpId));

  QueryString := CurrentEntity.GetGridQueryString(nil);
  RefreshGrid;
end;

// =============================================================================
procedure TEntityGrid.BtnEdit_OnClick(Sender: TObject);
Var
  TmpId: Integer;
begin
  // ShowMessage(GridViewOne.Controller.FocusedRow.Values[0]);
  TmpId := Grid.GridMainView.Controller.FocusedRow.Values[0];
  Global_Singleton_MainMenuManager.NewEntityEditor(CurrentEntity.GetEntityName,
    Grid.GridMainView.Controller.FocusedRow.Values[0]);
end;

// =============================================================================
procedure TEntityGrid.BtnDelete_OnClick(Sender: TObject);
Var
  S: String;
begin
  S := 'UPDATE ' + CurrentEntity.GetTableName + ' SET IS_DELETED="1" WHERE ID="'
    + IntToStr(Grid.GridMainView.Controller.FocusedRow.Values[0]) + '";';
  ExecuteQuery(Global_Singleton_DbConnection, S);
  RefreshGrid;
end;

// =============================================================================
procedure TEntityGrid.BtnLock_OnClick(Sender: TObject);
Var
  S: String;
  Btn: TcxButton;
begin
  Btn := TcxButton(Sender);
  if Btn.Caption = 'Lock' then
  begin
    S := 'UPDATE entity_' + CurrentEntity.GetEntityName + ' SET ' +
      EOLockDbColumnName + '="1" WHERE ID="' +
      IntToStr(Grid.GridMainView.Controller.FocusedRow.Values[0]) + '";';

    ExecuteQuery(Global_Singleton_DbConnection, S);
    HasController := FALSE;

    RefreshGrid;
  end
  else if Btn.Caption = 'Unlock' then
  begin
    S := 'UPDATE entity_' + CurrentEntity.GetEntityName + ' SET ' +
      EOLockDbColumnName + '="0" WHERE ID="' +
      IntToStr(Grid.GridMainView.Controller.FocusedRow.Values[0]) + '";';

    ExecuteQuery(Global_Singleton_DbConnection, S);
    HasController := FALSE;

    RefreshGrid;
  end;
end;

// =============================================================================
// procedure TEntityGrid.BtnPrint_OnClick(Sender: TObject);
// Var
// S, TmpName, TmpId: String;
// FrxDataSet: TFrxDBDataSet;
// Report: TFrxReport;
// TmpQ, TmpQ2: TZQuery;
// Stream: TStream;
// I : Integer;
// begin
//
// if FirstPrintAttempt then
// begin
// if Self.PrepareReportForPrinting then
// begin
// FirstPrintAttempt := FALSE;
// end
// else
// begin
// showmessage(T.GetLanguageConst('ReportNotAvailable'));
// EXIT;
// end;
//
// end;
//
// TmpName := CurrentEntity.GetEntityName;
// TmpId := IntToStr(Grid.GridMainView.Controller.FocusedRow.Values[0]);
//
/// /  SetLength(aReport, Length(aReport) + 1);
/// /  I := Length(aReport);
/// /
/// /  SetLength(aStream, Length(aStream) + 1);
//
// Report := TFrxReport.Create(FormEntityGrid);
// Report.Clear;
//
// TmpQ := OpenQuery(Global_Singleton_DbConnection,
// 'SELECT REPORT FROM wisp_reports WHERE NAME="' + TmpName +
// '" AND TYPE="SINGLE";').ZQuery;
// Stream := TmpQ.CreateBlobStream(TmpQ.FieldByName('REPORT'), bmRead);
// Stream.Position := 0;
// Report.LoadFromStream(Stream);
// TmpQ.Free;
//
// S := Global_Singleton_EntityManager.GetEntityByName(TmpName)
// .GetInstanceQueryString(TmpId);
//
// TmpQ2 := OpenQuery(Global_Singleton_DbConnection, S).ZQuery;
//
// FrxDataSet := TFrxDBDataSet.Create(Global_Singleton_DbConnection);
// FrxDataSet.UserName := 'Report';
// FrxDataSet.DataSet := TmpQ2;
//
// Report.DataSets.Items[0].DataSet := FrxDataSet;
//
// Report.PrepareReport(TRUE);
//
// Report.PreviewOptions.Clear;
//
/// /  Report.PrepareReport(TRUE);
// Report.ShowReport(TRUE);
// FrxDataSet.Free;
// Report.Clear;
//
// TmpQ2.Free;
//
// end;

// =============================================================================
procedure TEntityGrid.BtnPrint_OnClick(Sender: TObject);
Var
  S, TmpName, TmpId: String;
  FrxDataSet: TFrxDBDataSet;
  Report: TFrxReport;
  TmpQ, TmpQ2: TZQuery;
  Stream: TStream;
  I: Integer;
begin

  TmpName := CurrentEntity.GetEntityName;
  TmpId := IntToStr(Grid.GridMainView.Controller.FocusedRow.Values[0]);

  Report := TFrxReport.Create(FormEntityGrid);
  Report.Clear;

  TmpQ := OpenQuery(Global_Singleton_DbConnection,
    'SELECT REPORT FROM wisp_reports WHERE NAME="' + TmpName +
    '" AND TYPE="SINGLE";').ZQuery;

  Stream := TmpQ.CreateBlobStream(TmpQ.FieldByName('REPORT'), bmRead);
  Stream.Position := 0;
  Report.LoadFromStream(Stream);
  TmpQ.Free;

  S := Global_Singleton_EntityManager.GetEntityByName(TmpName)
    .GetInstanceQueryString(TmpId);

  TmpQ2 := OpenQuery(Global_Singleton_DbConnection, S).ZQuery;

  FrxDataSet := TFrxDBDataSet.Create(Global_Singleton_DbConnection);
  FrxDataSet.UserName := 'Report';
  FrxDataSet.DataSet := TmpQ2;

  if Report.DataSets.Count = 0 then
  begin
    ShowMessage(T.GetLanguageConst('ReportNotAvailable'));
    EXIT;
  end;

  Report.DataSets.Items[0].DataSet := FrxDataSet;

  Report.PrepareReport(TRUE);

  Report.PreviewOptions.Clear;

  Report.ShowReport(TRUE);

  FrxDataSet.Free;

  Report.Clear;

  TmpQ2.Free;

end;

// =============================================================================
procedure TEntityGrid.BtnQuickSearch_OnClick(Sender: TObject);
Var
  S1, S2: String;
  TmpFilter: TWispFieldFilter;
begin
  if CurrentEntity.QuickSearchProperty = nil then
  begin
    EXIT;
  end;

  S1 := TEPText(CurrentEntity.QuickSearchProperty).LabelText;
  S2 := InputBox('Quick Search', S1, '');

  if S2 <> '' then
  begin
    TmpFilter := TWispFieldFilter.Create;
    TmpFilter.SourceFiledName := CurrentEntity.QuickSearchProperty.
      GetDbColumnName;
    TmpFilter.SearchFor := S2;

    QueryString := CurrentEntity.GetGridQueryString(TmpFilter);
    RefreshGrid;
  end;

end;

// =============================================================================
procedure TEntityGrid.BtnRefresh_OnClick(Sender: TObject);
begin
  QueryString := CurrentEntity.GetGridQueryString(nil);
  RefreshGrid;
end;

// =============================================================================
Function TEntityGrid.PrepareReportForPrinting(): Boolean;
Var
  S, TmpName, TmpId: String;
  FrxDataSet: TFrxDBDataSet;
  Report: TFrxReport;
  TmpQ, TmpQ2: TZQuery;
  Stream: TStream;
begin

  TmpName := CurrentEntity.GetEntityName;
  TmpId := IntToStr(Grid.GridMainView.Controller.FocusedRow.Values[0]);

  Report := TFrxReport.Create(FormEntityGrid);
  Report.Clear;

  TmpQ := OpenQuery(Global_Singleton_DbConnection,
    'SELECT REPORT FROM wisp_reports WHERE NAME="' + TmpName +
    '" AND TYPE="SINGLE";').ZQuery;
  Stream := TmpQ.CreateBlobStream(TmpQ.FieldByName('REPORT'), bmRead);
  Stream.Position := 0;
  Report.LoadFromStream(Stream);
  TmpQ.Free;

  S := Global_Singleton_EntityManager.GetEntityByName(TmpName)
    .GetInstanceQueryString(TmpId);

  TmpQ2 := OpenQuery(Global_Singleton_DbConnection, S).ZQuery;

  FrxDataSet := TFrxDBDataSet.Create(Global_Singleton_DbConnection);
  FrxDataSet.UserName := 'Report';
  FrxDataSet.DataSet := TmpQ2;

  if Report.DataSets.Count = 0 then
  begin
    Result := FALSE;
    EXIT;
  end;

  Report.DataSets.Items[0].DataSet := FrxDataSet;
  Report.PrepareReport;
  Report.Clear;

  Result := TRUE;
end;

// =============================================================================
procedure TEntityGrid.OnFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  RefreshButtons;
end;

// =============================================================================
Procedure TEntityGrid.RefreshButtons;
Var
  Index, EoLockColumnIndex: Integer;
  S: String;
begin
  // if Entity Operation Lock Edition is present we change buttons state
  if Grid.GridMainView.Controller.FocusedRow = nil then
    Index := -1
  else
  begin
    Index := Grid.GridMainView.Controller.FocusedRow.Index;
    if EOLockPresent and HasController then
    begin
      EoLockColumnIndex := GetColumnIndexFromColumnCaption(Grid.GridMainView,
        EOLockColumnName);
      S := Grid.GridMainView.Controller.FocusedRow.Values[EoLockColumnIndex];
      if EOLockValue = S then
      begin
        BtnEdit.Enabled := FALSE;
        BtnDelete.Enabled := FALSE;
        BtnLock.Caption := 'Unlock';
      end
      else
      begin
        BtnEdit.Enabled := TRUE;
        BtnDelete.Enabled := TRUE;
        BtnLock.Caption := 'Lock';
      end;
    end;
  end;

end;

// =============================================================================
Function TEntityGrid.GetAliasFromTable(ParamTableName: string;
  ParamTables, ParamAliases: TArrayOfString): String;
Var
  I, L: Integer;
begin
  L := Length(ParamTables);

  for I := 0 to L - 1 do
  begin
    if ParamTables[I] = ParamTableName then
    begin
      Result := ParamAliases[I];
      BREAK;
    end;

  end;

end;

end.
