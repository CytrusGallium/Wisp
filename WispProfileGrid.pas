unit WispProfileGrid;

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
  WispButton,
  WispStyleManager,
  WispImageTools,
  WispConstantManager,
  WispGrid;

type
  TWispProfileGrid = Class(TObject)
  private
    FormProfileGrid: TForm;
    PanelProfileGrid: TPanel;
    // CurrentEntity: TEntity;
    PanelTop: TPanel;
    Grid: TWispGrid;
//    GridLevelOne: TCxGridLevel;
//    GridViewOne: TcxGridTableView;
    QueryString: String;
    aTable, aAlias: TArrayOfString;
    // EOLockPresent: Boolean;
    BtnAdd, BtnEdit, BtnDelete: TWispButton;
    // EOLockDbColumnName, EOLockColumnName, EOLockValue: String;
    HasController: Boolean;
    procedure BtnEdit_OnClick(Sender: TObject);
    Procedure BtnAdd_OnClick(Sender: TObject);
  protected
  public
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl);
    Procedure RefreshGrid;
  end;

implementation

uses
  WispMainMenuManager,
  CxPC;

// =============================================================================
Constructor TWispProfileGrid.Create(ParamOwner: TComponent;
  ParamParent: TWinControl);
Var
  I, J, TmpI, TmpL: Integer;
  TmpEpText: TEPText;
  TmpEpDate: TEPDate;
  TmpEpSubEntity: TEPSubEntity;
  TmpEpBoolean: TEPBoolean;
  TmpEpTime: TEPTime;
  TmpEoLockEdition: TEOLockEdition;
  TmpS, TmpAlias1, TmpAlias2, TmpVersion, TmpLeftJoinString, TmpConcat: String;
  Tab: TcxTabSheet;
  SubEntityPresent: Boolean;
  CurrentAlias: Char;
  aSubEntityTable, aLeftJoinString, aSubEntityColumn: TArrayOfString;
  aSubEntityVersion: Array of Boolean;
  StyleMetroGrey: TcxStyle;
begin
  // Create the entity grid form
  FormProfileGrid := TForm.Create(ParamOwner);
  with FormProfileGrid do
  begin
    // Width := TcxTabSheet(ParamOwner).Width;
    // Height := 600;
    BorderStyle := bsNone;
    Color := clGray;
    Parent := ParamParent;
    Align := alClient;
  end;

  // Create the toolbar panel
  PanelTop := TPanel.Create(FormProfileGrid);
  With PanelTop do
  begin
    Caption := '';
    Parent := FormProfileGrid;
    ParentBackground := FALSE;
    Color := cl3DDkShadow;
    Align := alTop;
    Width := Screen.Width;
    Height := 32;
  end;

  // BG
  DrawBgImage(PanelTop);

  // Create Toolbar buttons
  BtnAdd := TWispButton.Create(PanelTop);
  with BtnAdd do
  begin
    Parent := PanelTop;
    Width := 72;
    Height := 24;
    Caption := 'Add';
    Top := 4;
    Left := 4;
    OnClick := BtnAdd_OnClick;
  end;

  Grid := TWispGrid.Create(FormProfileGrid);

  QueryString := 'SELECT WISP_ID AS ID, WISP_NAME AS Name FROM wisp_profiles;';

  RefreshGrid;

  FormProfileGrid.Show;

end;

// =============================================================================
procedure TWispProfileGrid.RefreshGrid;
begin
  // ...
  HasController := FALSE;

  ShowQueryResult(Global_Singleton_DbConnection, QueryString, Grid);

  Grid.GridMainView.Columns[GetColumnIndexFromColumnCaption(Grid.GridMainView, 'ID')
    ].Visible := FALSE;

  // Auto resize columns
  Grid.GridMainView.ApplyBestFit();
    MaximizeColumnWidth(Grid.GridMainView as TcxGridDBTableView,
    FormProfileGrid.Parent.Width);

  // ...
  HasController := TRUE;
end;

// =============================================================================
procedure TWispProfileGrid.BtnAdd_OnClick(Sender: TObject);
Var
  TmpId: String;
begin
  Global_Singleton_MainMenuManager.NewProfileEditor('0');
end;

// =============================================================================
procedure TWispProfileGrid.BtnEdit_OnClick(Sender: TObject);
Var
  TmpId: String;
begin
  TmpId := IntToStr(Grid.GridMainView.Controller.FocusedRow.Values[0]);
  Global_Singleton_MainMenuManager.NewProfileEditor(TmpId);
end;

end.
