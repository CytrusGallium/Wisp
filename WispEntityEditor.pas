unit WispEntityEditor;

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
  ZDataset,
  cxTextEdit,
  cxButtons,
  WispEditBox,
  WispDatePicker,
  WispLookUpComboBox,
  WispEntity,
  WispEntityGrid,
  WispArrayTools,
  WispEntityManager,
  WispQueryTools,
  WispDbConnection,
  WispTimeTools,
  WispAccesManager,
  WispCheckBox,
  WispVisualComponent,
  WispTimePicker,
  WispStrTools,
  WispMathTools,
  cxPC,
  Messages,
  Windows,
  WispImageTools,
  WispStyleManager,
  WispButton,
  WispPageControl,
  WispTabSheet;

Const
  EdtWidth = 320;
  ColumnCount = 3;

type
  TEntityEditor = Class(TObject)
  private
    // Entity Editor
    CurrentID: String;
    CurrentEntityID: string;
    aVisualComponents: Array of TWispVisualComponent;
    BoxEntityEditor: TScrollBox;
    PanelBottom: TPanel;
    CurrentEntity: TEntity;
    DbColumns: Array of string;
    BtnOk: TWispButton;
    Tab: TWispTabSheet;
    GroupPageControl: TWispPageControl;
    FMultiGroup: Boolean;
    FDistanceCalculator: TWispColumnDistanceCalculator;
    procedure BtnOk_OnClick(Sender: TObject);
    procedure TabOnShow(Sender: TObject);
    Function GetCorrespondingParent(ParamEntityProperty: TEntityProperty)
      : TWinControl;
    Function GetGroupCount(): integer;
    Function IsMultiGroup(): Boolean;
    Function GetCalculatorFromParent(ParamParent: TWinControl)
      : TWispColumnDistanceCalculator;
  protected
  public
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl;
      ParamEntityName: String; ParamId: integer = 0);
    Function EntityToDb(): Boolean;
    Function PreEntityToDb(): String;
    Function GetVisualComponentFromPropertyName(ParamPropertyName: String)
      : TWispVisualComponent;
  end;

implementation

uses WispMainMenuManager;

// =============================================================================
Constructor TEntityEditor.Create(ParamOwner: TComponent;
  ParamParent: TWinControl; ParamEntityName: String; ParamId: integer = 0);
var
  I, TmpI, H, YOffset, ColSize: integer;
  TmpEpText: TEPText;
  TmpEpDate: TEPDate;
  TmpEpSubEntity: TEPSubEntity;
  TmpEpBoolean: TEPBoolean;
  TmpEpTime: TEPTime;
  TmpEdTimeAlert: TEDTimeAlert;
  TmpWispEdt: TWispEditBox;
  TmpDatePicker: TWispDatePicker;
  TmpTimePicker: TWispTimePicker;
  TmpLookUp: TWispLookUpComboBox;
  TmpWispChk: TWispCheckBox;
  S, TmpS: string;
  TmpQ: TZQuery;
  TmpBoolean: Boolean;
  TmpWinControl: TWinControl;
  TmpDC: TWispColumnDistanceCalculator;
begin
  // The editor is owned and drawn on a tab
  Tab := TWispTabSheet(ParamOwner); // So basicly tab is ParamOwner
  Tab.OnShow := Self.TabOnShow;

  // Select the current entity to edit
  CurrentEntity := Global_Singleton_EntityManager.GetEntityByName
    (ParamEntityName);
  CurrentID := IntToStr(ParamId);

  // ...
  FMultiGroup := IsMultiGroup;

  if IsMultiGroup then
  begin
    // Group Page Control
    GroupPageControl := TWispPageControl.Create(Tab);
    with GroupPageControl do
    begin
      Parent := Tab;
      Align := alClient;
      ParentBackground := FALSE;
      ParentColor := FALSE;
      Properties.CloseButtonMode := cbmNone;
      LookAndFeel.NativeStyle := True;
      TabPosition := tpLeft;
      Rotate := True;
      Font.Size := 14;
    end;
    // Get column width
    ColSize := Round(GroupPageControl.ClientWidth / ColumnCount);
  end;

  // ...
  if ParamId = 0 then
  begin
    CurrentID := PreEntityToDb;
  end;

  CurrentEntityID := OpenQuery(Global_Singleton_DbConnection,
    'SELECT ENTITY_ID FROM entity_' + ParamEntityName + ' WHERE ID="' +
    CurrentID + '";').FirstFieldAsString;
  // Get the number of properties for the current entity
  TmpI := CurrentEntity.GetPropertyCount;

  // Calculate the form heigth
  H := (TmpI * 70) + 140;
  // Prepare visual components array
  SetLength(aVisualComponents, TmpI);
  // Spacing from the top of the form to the first visual component
  YOffset := -16;
  // Query for the entity if on edit mode
  if ParamId > 0 then
  begin
    S := CurrentEntity.GetInstanceQueryString(CurrentID);
    TmpQ := OpenQuery(Global_Singleton_DbConnection, S).ZQuery;
  end;

  // Create the entity editor form
  if not(IsMultiGroup) then
  begin
    BoxEntityEditor := TScrollBox.Create(ParamOwner);
    with BoxEntityEditor do
    begin
      Width := 320;
      Height := H;
      BorderStyle := bsNone;
      Parent := Tab;
      Color := clGray;
      Align := alClient;
      Global_Singleton_MainMenuManager.CurrentFocusedScrollBox :=
        Self.BoxEntityEditor;
    end;
    // Get column width
    // ColSize := Round(BoxEntityEditor.ClientWidth / ColumnCount);
    FDistanceCalculator := TWispColumnDistanceCalculator.Create(ColumnCount,
      EdtWidth, BoxEntityEditor.ClientWidth);
  end;

  // BG
  DrawBgImage(BoxEntityEditor);

  SetLength(DbColumns, 0);

  // Build ENTITY_ID and VERSION_ID Columns array
  // ENTITY_ID
  SetLength(DbColumns, Length(DbColumns) + 1);
  DbColumns[Length(DbColumns) - 1] := 'ENTITY_ID';

  // VERSION_ID
  SetLength(DbColumns, Length(DbColumns) + 1);
  DbColumns[Length(DbColumns) - 1] := 'VERSION_ID';

  // IS_LAST
  SetLength(DbColumns, Length(DbColumns) + 1);
  DbColumns[Length(DbColumns) - 1] := 'IS_LAST';

  // WISP_DTC
  SetLength(DbColumns, Length(DbColumns) + 1);
  DbColumns[Length(DbColumns) - 1] := 'DTC';

  // WISP_UID
  SetLength(DbColumns, Length(DbColumns) + 1);
  DbColumns[Length(DbColumns) - 1] := 'UID';

  // Draw the visual components
  // Build Columns array
  for I := 0 to TmpI - 1 do
  begin
    // TEPText
    if CurrentEntity.aProperty[I] is TEPText then
    begin

      TmpEpText := CurrentEntity.aProperty[I] As (TEPText);
      TmpWinControl := GetCorrespondingParent(TmpEpText);
      TmpDC := GetCalculatorFromParent(TmpWinControl);

      aVisualComponents[I] := TWispEditBox.Create(TmpWinControl, TmpWinControl,
        EdtWidth, TmpEpText.LineCount, TmpDC.GetCurrentX, TmpDC.GetCurrentY,
        TmpEpText.LabelText, TmpEpText.LocalFileSelector);

      TmpDC.PushY(60);
      TmpDC.GetNextColumn;

      TmpWispEdt := aVisualComponents[I] As (TWispEditBox);
      TmpWispEdt.LinkedEpName := TmpEpText.Name;
      TmpWispEdt.SuffixLbl.Caption := TmpEpText.SuffixLabel;

      if TmpEpText.Editable = FALSE then
      begin
        if TmpWispEdt.EdtBox <> nil then
          TmpWispEdt.EdtBox.Properties.ReadOnly := True
        else if TmpWispEdt.MemoBox <> nil then
          TmpWispEdt.MemoBox.Properties.ReadOnly := True;
      end;

      SetLength(DbColumns, Length(DbColumns) + 1);
      DbColumns[Length(DbColumns) - 1] := TmpEpText.GetDbColumnName;

      if ParamId > 0 then
      begin
        TmpWispEdt.EdtBox.Text :=
          TmpQ.FieldByName(TmpEpText.GetDbColumnName).AsString;
        TmpWispEdt.MemoBox.Text :=
          TmpQ.FieldByName(TmpEpText.GetDbColumnName).AsString;
      end
      else if (ParamId = 0) and (TmpEpText.DefaultValue <> nil) then
      begin
        TmpWispEdt.EdtBox.Text := CurrentEntity.GetDefaultValueOf
          (TmpEpText.DefaultValue, TmpEpText, CurrentID);
      end;

    end
    // TEPDate
    else if CurrentEntity.aProperty[I] is TEPDate then
    begin
      TmpEpDate := CurrentEntity.aProperty[I] As (TEPDate);
      TmpWinControl := GetCorrespondingParent(TmpEpDate);
      TmpDC := GetCalculatorFromParent(TmpWinControl);

      aVisualComponents[I] := TWispDatePicker.Create
        (GetCorrespondingParent(TmpEpDate), GetCorrespondingParent(TmpEpDate),
        EdtWidth, TmpDC.GetCurrentX, TmpDC.GetCurrentY, TmpEpDate.LabelText);

      TmpDC.PushY(60);
      TmpDC.GetNextColumn;

      TmpDatePicker := aVisualComponents[I] As (TWispDatePicker);
      TmpDatePicker.LinkedEpName := TmpEpDate.Name;

      if TmpEpDate.Editable = FALSE then
      begin
        TmpDatePicker.DateBox.Properties.ReadOnly := True;
      end;

      SetLength(DbColumns, Length(DbColumns) + 1);
      DbColumns[Length(DbColumns) - 1] := TmpEpDate.GetDbColumnName;

      if ParamId > 0 then
      begin
        TmpDatePicker.DateBox.Text :=
          TmpQ.FieldByName(TmpEpDate.GetDbColumnName).AsString;
      end
      else if (ParamId = 0) and (TmpEpDate.DefaultValue <> nil) then
      begin
        TmpDatePicker.DateBox.Text := CurrentEntity.GetDefaultValueOf
          (TmpEpDate.DefaultValue, TmpEpDate, CurrentID);
      end;
    end
    // TEPTime
    else if CurrentEntity.aProperty[I] is TEPTime then
    begin
      TmpEpTime := CurrentEntity.aProperty[I] As (TEPTime);
      TmpWinControl := GetCorrespondingParent(TmpEpTime);
      TmpDC := GetCalculatorFromParent(TmpWinControl);

      aVisualComponents[I] := TWispTimePicker.Create
        (GetCorrespondingParent(TmpEpTime), GetCorrespondingParent(TmpEpTime),
        EdtWidth, TmpDC.GetCurrentX, TmpDC.GetCurrentY, TmpEpTime.LabelText);

      TmpDC.PushY(60);
      TmpDC.GetNextColumn;

      TmpTimePicker := aVisualComponents[I] As (TWispTimePicker);
      TmpTimePicker.LinkedEpName := TmpEpTime.Name;

      if TmpEpTime.Editable = FALSE then
      begin
        TmpTimePicker.TimeBox.Properties.ReadOnly := True;
      end;

      SetLength(DbColumns, Length(DbColumns) + 1);
      DbColumns[Length(DbColumns) - 1] := TmpEpTime.GetDbColumnName;

      if ParamId > 0 then
      begin
        TmpTimePicker.TimeBox.Text :=
          TmpQ.FieldByName(TmpEpTime.GetDbColumnName).AsString;
      end
      else if (ParamId = 0) and (TmpEpTime.DefaultValue <> nil) then
      begin
        TmpTimePicker.TimeBox.Text := CurrentEntity.GetDefaultValueOf
          (TmpEpTime.DefaultValue, TmpEpTime, CurrentID);
      end;
    end
    // TEPSubEntity
    else if CurrentEntity.aProperty[I] is TEPSubEntity then
    begin
      TmpEpSubEntity := CurrentEntity.aProperty[I] As (TEPSubEntity);
      TmpWinControl := GetCorrespondingParent(TmpEpSubEntity);
      TmpDC := GetCalculatorFromParent(TmpWinControl);

      aVisualComponents[I] := TWispLookUpComboBox.Create(TmpWinControl,
        TmpWinControl, EdtWidth, TmpDC.GetCurrentX, TmpDC.GetCurrentY,
        TmpEpSubEntity.LabelText, TmpEpSubEntity, TmpEpSubEntity.Multi);

      TmpDC.PushY(60);
      TmpDC.GetNextColumn;

      TmpLookUp := aVisualComponents[I] As (TWispLookUpComboBox);
      TmpLookUp.LinkedEpName := TmpEpSubEntity.Name;

      if TmpEpSubEntity.Editable = FALSE then
      begin
        TmpLookUp.LookUpComboBox.Properties.ReadOnly := True;
      end;

      if TmpEpSubEntity.Multi = FALSE then
      begin
        SetLength(DbColumns, Length(DbColumns) + 1);
        DbColumns[Length(DbColumns) - 1] := TmpEpSubEntity.GetDbColumnName;
      end;

      if ParamId > 0 then
      begin
        // Single
        if TmpEpSubEntity.Multi = FALSE then
        begin
          TmpLookUp.LookUpComboBox.ItemIndex :=
            TmpLookUp.GetItem(TmpQ.FieldByName(TmpEpSubEntity.GetDbColumnName)
            .AsString);
        end
        else if (ParamId = 0) and (TmpEpSubEntity.DefaultValue <> nil) then
        begin
          TmpS := CurrentEntity.GetDefaultValueOf(TmpEpSubEntity.DefaultValue,
            TmpEpSubEntity, CurrentID);
          if TmpS = '' then
            TmpLookUp.LookUpComboBox.ItemIndex := -1
          else
            TmpLookUp.LookUpComboBox.ItemIndex := StrToInt(TmpS);
        end
        // Multi
        else
        begin
          TmpLookUp.MultiLoadFromTable(CurrentEntity.GetTableName + '_' +
            TmpLookUp.LinkedEpName, CurrentEntity.GetEntityName,
            IntToStr(ParamId));
        end;
      end;
    end
    // TEPBoolean
    else if CurrentEntity.aProperty[I] is TEPBoolean then
    begin
      TmpEpBoolean := CurrentEntity.aProperty[I] As (TEPBoolean);
      TmpWinControl := GetCorrespondingParent(TmpEpBoolean);
      TmpDC := GetCalculatorFromParent(TmpWinControl);

      aVisualComponents[I] := TWispCheckBox.Create
        (GetCorrespondingParent(TmpEpBoolean),
        GetCorrespondingParent(TmpEpBoolean), EdtWidth, TmpDC.GetCurrentX,
        TmpDC.GetCurrentY, TmpEpBoolean.LabelText);

      TmpDC.PushY(60);
      TmpDC.GetNextColumn;

      TmpWispChk := aVisualComponents[I] As (TWispCheckBox);
      TmpWispChk.LinkedEpName := TmpEpBoolean.Name;

      if TmpEpBoolean.Editable = FALSE then
      begin
        TmpWispChk.ChkBox.Properties.ReadOnly := True;
      end;

      SetLength(DbColumns, Length(DbColumns) + 1);
      DbColumns[Length(DbColumns) - 1] := TmpEpBoolean.GetDbColumnName;

      if ParamId > 0 then
      begin
        TmpWispChk.ChkBox.Checked :=
          Boolean(TmpQ.FieldByName(TmpEpBoolean.GetDbColumnName).AsInteger);
      end
      else if (ParamId = 0) and (TmpEpBoolean.DefaultValue <> nil) then
      begin
        TmpWispChk.ChkBox.Checked :=
          StrToBool(CurrentEntity.GetDefaultValueOf(TmpEpBoolean.DefaultValue,
          TmpEpBoolean, CurrentID));
      end;
    end
  end;

  // Bottom Panel
  PanelBottom := TPanel.Create(Tab);
  with PanelBottom do
  begin
    Parent := Tab;
    Height := 64;
    Align := alBottom;
  end;

  // Bottom Panel BG
  DrawBgImage(PanelBottom);

  // Add Ok and Cancel buttons
  BtnOk := TWispButton.Create(BoxEntityEditor);
  with BtnOk do
  begin
    Parent := PanelBottom;
    Width := 64;
    Height := 24;
    Caption := 'OK';
    CenterHorizontally;
    CenterVertically;
    Default := True;
    OnClick := BtnOk_OnClick;
  end;

  // ...
  if IsMultiGroup <> True then
    BoxEntityEditor.Show;

  // Apply Decorators
  if ParamId > 0 then
  begin

    for I := 0 to Length(CurrentEntity.aDecorator) - 1 do
    begin
      if CurrentEntity.aDecorator[I] is TEDTimeAlert then
      begin
        TmpBoolean := Global_Singleton_EntityManager.GetTimeAlertState
          (CurrentEntity.GetEntityName, TEDTimeAlert(CurrentEntity.aDecorator[I]
          ).Name, IntToStr(ParamId));

        if TmpBoolean = True then
        begin
          TmpEdTimeAlert := CurrentEntity.aDecorator[I] As TEDTimeAlert;
          TmpDatePicker := Self.GetVisualComponentFromPropertyName
            (TmpEdTimeAlert.OriginDateProperty) As TWispDatePicker;
          TmpDatePicker.DateBox.Style.Color := clWebLightSalmon;
        end;
      end;
    end;

  end;
end;

// =============================================================================
procedure TEntityEditor.BtnOk_OnClick(Sender: TObject);
const
  WM_KILLTAB = WM_USER + 1;
Var
  TmpEntityGrid: TEntityGrid;
begin
  EntityToDb;
  TmpEntityGrid := TEntityGrid(Global_Singleton_MainMenuManager.PageControlMain.
    GetParentObject('GRID', CurrentEntity.GetEntityName, '0'));
  TmpEntityGrid.RefreshGrid;
  Global_Singleton_MainMenuManager.PageControlMain.UnRegisterTab('EDIT',
    CurrentEntity.GetEntityName, CurrentID);
  PostMessage(Global_Singleton_MainMenuManager.PageControlMain.Handle,
    WM_KILLTAB, 0, Tab.PageIndex);
end;

// =============================================================================
Function TEntityEditor.EntityToDb(): Boolean;
var
  I, J, TmpI, TmpJ: integer;
  S, S0, S1, S2, S3, S4, S5, TmpId, LastInsertId: String;
  TmpWispEdtBox: TWispEditBox;
  TmpWispDatePicker: TWispDatePicker;
  TmpWispTimePicker: TWispTimePicker;
  TmpWispLookUp: TWispLookUpComboBox;
  TmpWispCheckBox: TWispCheckBox;
  TmpEpText: TEPText;
  TmpEpDate: TEPDate;
  TmpEpSubEntity: TEPSubEntity;
  TmpEoPropertyOperator: TEOPropertyOperator;
  TmpEoPropertyUpdater: TEOPropertyUpdater;
  aVals: array of string;
  B1, B2, SubEntityMultipleExist: Boolean;
begin

  if CurrentID <> '0' then
  begin
    S := 'UPDATE entity_' + CurrentEntity.GetEntityName +
      ' SET IS_LAST="0" WHERE ID="' + CurrentID + '";';
    ExecuteQuery(Global_Singleton_DbConnection, S);
  end;

  // Store ENTITY_ID value in the array
  SetLength(aVals, Length(aVals) + 1);
  if CurrentID <> '0' then
  begin
    S0 := OpenQuery(Global_Singleton_DbConnection,
      'SELECT ENTITY_ID FROM entity_' + CurrentEntity.GetEntityName +
      ' WHERE ID="' + CurrentID + '";').FirstFieldAsString;
    CurrentEntityID := S0;
    // Store ENTITY_ID before the insert because this entity is at EDIT mode and not NEW mode
    aVals[Length(aVals) - 1] := CurrentEntityID;
  end
  else if CurrentID = '0' then
  begin
    aVals[Length(aVals) - 1] :=
      IntToStr(Global_Singleton_EntityManager.GetEntityCounter
      (CurrentEntity.GetEntityName) + 1);
  end;

  // Store VERSION_ID value in the array
  if CurrentID = '0' then
  begin
    S1 := '1';
  end
  else
  begin
    S1 := OpenQuery(Global_Singleton_DbConnection,
      'SELECT MAX(VERSION_ID) AS LAST_VERSION_ID FROM entity_' +
      CurrentEntity.GetEntityName + ' WHERE ENTITY_ID="' + CurrentEntityID +
      '";').FirstFieldAsString;
    S1 := IntToStr(StrToInt(S1) + 1);
  end;
  SetLength(aVals, Length(aVals) + 1);
  aVals[Length(aVals) - 1] := S1;

  SetLength(aVals, Length(aVals) + 1);
  aVals[Length(aVals) - 1] := '1';

  SetLength(aVals, Length(aVals) + 1);
  aVals[Length(aVals) - 1] := CxDateToMySqlDate(GetDateFromServer) + ' ' +
    GetTimeFromServer;

  SetLength(aVals, Length(aVals) + 1);
  aVals[Length(aVals) - 1] := Global_Singleton_AccesManager.CurrentUser.ID;

  for I := 0 to Length(aVisualComponents) - 1 do
  begin
    if aVisualComponents[I] is TWispEditBox then
    begin
      TmpWispEdtBox := aVisualComponents[I] As TWispEditBox;

      SetLength(aVals, Length(aVals) + 1);
      aVals[Length(aVals) - 1] := CharDoubler(CharDoubler(TmpWispEdtBox.GetText,
        '\'), '"');
    end
    else if aVisualComponents[I] is TWispDatePicker then
    begin
      TmpWispDatePicker := aVisualComponents[I] As TWispDatePicker;

      SetLength(aVals, Length(aVals) + 1);
      aVals[Length(aVals) - 1] :=
        CxDateToMySqlDate(TmpWispDatePicker.DateBox.Text);

    end
    else if aVisualComponents[I] is TWispTimePicker then
    begin
      TmpWispTimePicker := aVisualComponents[I] As TWispTimePicker;

      SetLength(aVals, Length(aVals) + 1);
      aVals[Length(aVals) - 1] := TmpWispTimePicker.TimeBox.Text;

    end
    else if aVisualComponents[I] is TWispLookUpComboBox then
    begin
      TmpWispLookUp := aVisualComponents[I] As TWispLookUpComboBox;

      TmpEpSubEntity := CurrentEntity.PropertyByName(TmpWispLookUp.LinkedEpName)
        as TEPSubEntity;

      if TmpEpSubEntity.Multi = FALSE then
      Begin
        SetLength(aVals, Length(aVals) + 1);
        aVals[Length(aVals) - 1] := TmpWispLookUp.GetKey
          (TmpWispLookUp.LookUpComboBox.ItemIndex);
      End
      else
      Begin
        SubEntityMultipleExist := True;
      End;

    end
    else if aVisualComponents[I] is TWispCheckBox then
    begin
      TmpWispCheckBox := aVisualComponents[I] As TWispCheckBox;

      SetLength(aVals, Length(aVals) + 1);
      aVals[Length(aVals) - 1] :=
        IntToStr(integer(TmpWispCheckBox.ChkBox.Checked));
    end;
  end;

  LastInsertId := ExecuteSqlInsert(Global_Singleton_DbConnection,
    'entity_' + CurrentEntity.GetEntityName, DbColumns, aVals);

  if SubEntityMultipleExist then
  begin
    TmpWispLookUp.MultiSaveToTable(CurrentEntity.GetTableName + '_' +
      TmpWispLookUp.LinkedEpName, CurrentEntity.GetEntityName, LastInsertId);
  end;

  if CurrentID = '0' then
  begin
    Global_Singleton_EntityManager.IncrementEntityCounter
      (CurrentEntity.GetEntityName);
  end;

  // ===========================================================================
  // Execute Operations
  TmpI := Length(CurrentEntity.aOperation);
  S1 := '';
  S2 := '';

  for I := 0 to TmpI - 1 do
  begin
    // Case of : TEOPropertyOperator
    if CurrentEntity.aOperation[I] is TEOPropertyOperator then
    begin
      TmpEoPropertyOperator := CurrentEntity.aOperation[I]
        As TEOPropertyOperator;
      // Get Last_Insert_Id which is specific to each client
      TmpId := OpenQuery(Global_Singleton_DbConnection,
        'SELECT LAST_INSERT_ID();').FirstFieldAsString;
      // Get Boolean fields states from Database
      B1 := OpenQuery(Global_Singleton_DbConnection,
        'SELECT ' + 'EP_' + TmpEoPropertyOperator.ConfirmationEPBooleanName +
        ' FROM entity_' + CurrentEntity.GetEntityName + ' WHERE ID=' + TmpId +
        ';').FirstFieldAsBoolean;
      B2 := OpenQuery(Global_Singleton_DbConnection,
        'SELECT ' + TmpEoPropertyOperator.GetDbColumnName + ' FROM entity_' +
        CurrentEntity.GetEntityName + ' WHERE ID=' + TmpId + ';')
        .FirstFieldAsBoolean;

      S3 := TmpEoPropertyOperator.Operator_;
      if B1 = B2 then
      begin
        // Do Nothing ...
      end
      else if B1 <> B2 then
      begin
        // Find the correct operator direction
        if (B1 = True) AND (B2 = FALSE) then
          S5 := '1'
        else if (B1 = FALSE) AND (B2 = True) then
        begin
          S3 := ReverseOperator(S3);
          S5 := '0';
        end;
        // Find the corresponding visual component using this loop (target)
        for J := 0 to Length(aVisualComponents) - 1 do
        begin
          if aVisualComponents[J].LinkedEpName = TmpEoPropertyOperator.TargetSubEntity
          then
          begin
            // Build the UPDATE Query segments
            S0 := OpenQuery(Global_Singleton_DbConnection,
              'SELECT ' + 'ID_' + TmpEoPropertyOperator.TargetSubEntity +
              ' FROM entity_' + CurrentEntity.GetEntityName + ' WHERE ID=' +
              TmpId + ';').FirstFieldAsString;
            S1 := TmpEoPropertyOperator.TargetSubEntity;
            S2 := 'EP_' + TmpEoPropertyOperator.TargetProperty;
            S0 := OpenQuery(Global_Singleton_DbConnection,
              'SELECT ' + 'ID' + ' FROM entity_' + S1 + ' WHERE ENTITY_ID=' + S0
              + ' AND IS_LAST="1";').FirstFieldAsString;
            BREAK;
          end;
        end;
        // Find the corresponding visual component using this loop  (source)
        for J := 0 to Length(aVisualComponents) - 1 do
        begin
          if aVisualComponents[J].LinkedEpName = TmpEoPropertyOperator.SourceProperty
          then
          begin
            // Build the UPDATE Query segments
            S4 := '"' + StrToNumbers(TWispEditBox(aVisualComponents[J])
              .EdtBox.Text) + '"';
            BREAK;
          end;
        end;
        // Build the UPDATE Query
        S := 'UPDATE entity_' + LowerCase(S1) + ' SET ' + S2 + '=' + S2 + S3 +
          S4 + ' WHERE ID=' + S0 + ';';
        ExecuteQuery(Global_Singleton_DbConnection, S);
        S := 'UPDATE entity_' + CurrentEntity.GetEntityName + ' SET ' +
          TmpEoPropertyOperator.GetDbColumnName + '=' + S5 + ';';
        ExecuteQuery(Global_Singleton_DbConnection, S);
      end;
    end;

    // Case of : TEOPropertyUpdater
    if CurrentEntity.aOperation[I] is TEOPropertyUpdater then
    begin
      TmpEoPropertyUpdater := CurrentEntity.aOperation[I] As TEOPropertyUpdater;
      // Get Last_Insert_Id which is specific to each client
      TmpId := OpenQuery(Global_Singleton_DbConnection,
        'SELECT LAST_INSERT_ID();').FirstFieldAsString;
      // Get the value that will replace the old value
      S1 := OpenQuery(Global_Singleton_DbConnection,
        'SELECT EP_' + TmpEoPropertyUpdater.SourceProperty + ' FROM entity_' +
        CurrentEntity.GetEntityName + ' WHERE ID=' + TmpId).FirstFieldAsString;
      S1 := CxDateToMySqlDate(S1);
      // Get Target Entity_ID
      S0 := OpenQuery(Global_Singleton_DbConnection,
        'SELECT ' + 'ID_' + TmpEoPropertyUpdater.TargetSubEntity +
        ' FROM entity_' + CurrentEntity.GetEntityName + ' WHERE ID=' + TmpId +
        ';').FirstFieldAsString;
      // ...
      S := 'UPDATE entity_' + LowerCase(TmpEoPropertyUpdater.TargetSubEntity) +
        ' SET EP_' + TmpEoPropertyUpdater.TargetProperty + '="' + S1 +
        '" WHERE ENTITY_ID=' + S0 + ' AND IS_LAST=1;';
      ExecuteQuery(Global_Singleton_DbConnection, S);
    end;
  end;

end;

// =============================================================================
Function TEntityEditor.PreEntityToDb(): String;
var
  S1: String;
  aVals: array of string;
begin

  if CurrentID <> '0' then
    EXIT;

  SetLength(aVals, 0);
  SetLength(DbColumns, 0);

  // Build Values array
  // Store ENTITY_ID value in the array
  SetLength(aVals, Length(aVals) + 1);
  aVals[Length(aVals) - 1] :=
    IntToStr(Global_Singleton_EntityManager.GetEntityCounter
    (CurrentEntity.GetEntityName) + 1);

  // Version
  SetLength(aVals, Length(aVals) + 1);
  aVals[Length(aVals) - 1] := '1';

  // IS_LAST
  SetLength(aVals, Length(aVals) + 1);
  aVals[Length(aVals) - 1] := '1';

  // Time Stamp
  SetLength(aVals, Length(aVals) + 1);
  aVals[Length(aVals) - 1] := CxDateToMySqlDate(GetDateFromServer) + ' ' +
    GetTimeFromServer;

  // User ID
  SetLength(aVals, Length(aVals) + 1);
  aVals[Length(aVals) - 1] := Global_Singleton_AccesManager.CurrentUser.ID;

  // Build Columns array
  // ENTITY_ID
  SetLength(DbColumns, Length(DbColumns) + 1);
  DbColumns[Length(DbColumns) - 1] := 'ENTITY_ID';

  // VERSION_ID
  SetLength(DbColumns, Length(DbColumns) + 1);
  DbColumns[Length(DbColumns) - 1] := 'VERSION_ID';

  // IS_LAST
  SetLength(DbColumns, Length(DbColumns) + 1);
  DbColumns[Length(DbColumns) - 1] := 'IS_LAST';

  // WISP_DTC
  SetLength(DbColumns, Length(DbColumns) + 1);
  DbColumns[Length(DbColumns) - 1] := 'DTC';

  // WISP_UID
  SetLength(DbColumns, Length(DbColumns) + 1);
  DbColumns[Length(DbColumns) - 1] := 'UID';

  ExecuteSqlInsert(Global_Singleton_DbConnection,
    'entity_' + CurrentEntity.GetEntityName, DbColumns, aVals);

  Result := OpenQuery(Global_Singleton_DbConnection, 'SELECT LAST_INSERT_ID();')
    .FirstFieldAsString;

  Global_Singleton_EntityManager.IncrementEntityCounter
    (CurrentEntity.GetEntityName);

end;

// =============================================================================
Function TEntityEditor.GetVisualComponentFromPropertyName(ParamPropertyName
  : String): TWispVisualComponent;
Var
  I: integer;
begin
  for I := 0 to Length(aVisualComponents) - 1 do
  begin
    if aVisualComponents[I].LinkedEpName = ParamPropertyName then
    begin
      Result := aVisualComponents[I];
      BREAK;
    end;
  end;
end;

// =============================================================================
// Function TEntityEditor.GetCurrentY(): integer;
// begin
// Result := aColumnOffset[CurrentColumn];
// end;

// =============================================================================
// Function TEntityEditor.GetCurrentX(): integer;
// begin
// Result := aColumnXPos[CurrentColumn];
// end;

// =============================================================================
// Function TEntityEditor.GetNextColumn(): integer;
// begin
// CurrentColumn := CurrentColumn + 1;
// if CurrentColumn > ColumnCount - 1 then
// CurrentColumn := 0;
//
// Result := CurrentColumn;
// end;

// =============================================================================
// Function TEntityEditor.PushY(ParamAmount: integer): integer;
// begin
// aColumnOffset[CurrentColumn] := aColumnOffset[CurrentColumn] + ParamAmount;
// end;

// =============================================================================
// Function TEntityEditor.GetMaxY(): integer;
// Var
// I, TmpI: integer;
// begin
// TmpI := 0;
//
// for I := 0 to Length(aColumnOffset) - 1 do
// begin
// if aColumnOffset[I] > TmpI then
// TmpI := aColumnOffset[I];
// end;
//
// Result := TmpI;
// end;

// =============================================================================
procedure TEntityEditor.TabOnShow(Sender: TObject);
begin
  Global_Singleton_MainMenuManager.CurrentFocusedScrollBox :=
    Self.BoxEntityEditor;
end;

// =============================================================================
// Decides if the visual component will be drawn on the scroll box panel directly
// or into a specific Tab
Function TEntityEditor.GetCorrespondingParent(ParamEntityProperty
  : TEntityProperty): TWinControl;
Var
  tmpTab: TcxTabSheet;
begin
  if IsMultiGroup then
  begin
    tmpTab := GroupPageControl.GetTabFromCaption(ParamEntityProperty.GroupName);
    if tmpTab = nil then
    begin
      Result := GroupPageControl.AddScrollBoxTab(ParamEntityProperty.GroupName,
        ColumnCount, EdtWidth);
    end
    else
    begin
      Result := tmpTab;
    end;
  end
  else
    Result := BoxEntityEditor;
end;

// =============================================================================
Function TEntityEditor.GetGroupCount(): integer;
begin

end;

// =============================================================================
Function TEntityEditor.IsMultiGroup(): Boolean;
Var
  S: String;
  I: integer;
begin
  if Length(CurrentEntity.aProperty) = 0 then
  begin
    Result := FALSE;
    // IsMultiGroup := FALSE;
    EXIT;
  end;

  S := TEntityProperty(CurrentEntity.aProperty[0]).GroupName;

  for I := 0 to Length(CurrentEntity.aProperty) - 1 do
  begin
    if S <> TEntityProperty(CurrentEntity.aProperty[I]).GroupName then
    begin
      Result := True;
      // IsMultiGroup := TRUE;
      EXIT;
    end;
  end;

  Result := FALSE;
  // IsMultiGroup := FALSE;

end;

// =============================================================================
Function TEntityEditor.GetCalculatorFromParent(ParamParent: TWinControl)
  : TWispColumnDistanceCalculator;
begin
  if ParamParent is TWispTabSheet then
  begin
    Result := TWispTabSheet(ParamParent).DistanceCalculator;
  end
  else if ParamParent is TScrollBox then
  begin
    Result := FDistanceCalculator;
  end;
end;

end.
