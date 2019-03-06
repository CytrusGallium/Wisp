unit WispUserGrid;

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
  TUserGrid = Class(TObject)
  private
    FormUserGrid: TForm;
    PanelEntityGrid: TPanel;
    CurrentEntity: TEntity;
    PanelTop: TPanel;
    Grid: TWispGrid;
//    GridLevelOne: TCxGridLevel;
//    GridViewOne: TcxGridTableView;
    QueryString: String;
    aTable, aAlias: TArrayOfString;
    EOLockPresent: Boolean;
    BtnAdd, BtnEdit, BtnDelete: TWispButton;
    EOLockDbColumnName, EOLockColumnName, EOLockValue: String;
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
Constructor TUserGrid.Create(ParamOwner: TComponent; ParamParent: TWinControl);
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
  FormUserGrid := TForm.Create(ParamOwner);
  with FormUserGrid do
  begin
    // Width := TcxTabSheet(ParamOwner).Width;
    // Height := 600;
    BorderStyle := bsNone;
    Color := clGray;
    Parent := ParamParent;
    Align := alClient;
  end;

  // Create the toolbar panel
  PanelTop := TPanel.Create(FormUserGrid);
  With PanelTop do
  begin
    Caption := '';
    Parent := FormUserGrid;
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
    Caption := Global_Singleton_ConstantManager.GetLanguageConst('Add');
    Top := 4;
    Left := 4;
    OnClick := BtnAdd_OnClick;
  end;

  // Create Toolbar buttons
  // BtnEdit := TcxButton.Create(PanelTop);
  // with BtnEdit do
  // begin
  // Parent := PanelTop;
  // Width := 72;
  // Height := 24;
  // Caption := 'Edit';
  // Top := 4;
  // Left := 4 + 72;
  // OnClick := BtnEdit_OnClick;
  // end;

  Grid := TWispGrid.Create(FormUserGrid);

  RefreshGrid;

  FormUserGrid.Show;

end;

// =============================================================================
procedure TUserGrid.RefreshGrid;
begin
  // ...
  HasController := FALSE;

  // Re-assigning the query string because it gets erased for unknown reasons ...
  QueryString :=
    'SELECT WISP_ID AS ID, WISP_USERNAME AS Username, CONCAT(WISP_FIRST_NAME, " ", WISP_FAMILY_NAME) AS Name, WISP_PHONE_NUMBER As "Phone Number", WISP_EMAIL AS "E-mail" FROM wisp_users;';

  ShowQueryResult(Global_Singleton_DbConnection, QueryString, Grid);

  Grid.GridMainView.Columns[GetColumnIndexFromColumnCaption(Grid.GridMainView, 'ID')
    ].Visible := FALSE;

  // Auto resize columns
  Grid.GridMainView.ApplyBestFit();
  MaximizeColumnWidth(Grid.GridMainView as TcxGridDbTableView,
    FormUserGrid.Parent.Width);

  // ...
  HasController := TRUE;
  // RefreshButtons;
end;

// =============================================================================
procedure TUserGrid.BtnEdit_OnClick(Sender: TObject);
Var
  TmpId: String;
begin
  // ShowMessage(GridViewOne.Controller.FocusedRow.Values[0]);
  TmpId := IntToStr(Grid.GridMainView.Controller.FocusedRow.Values[0]);
  Global_Singleton_MainMenuManager.NewUserEditor(TmpId);
end;

// =============================================================================
procedure TUserGrid.BtnAdd_OnClick(Sender: TObject);
Var
  TmpId: String;
begin
  Global_Singleton_MainMenuManager.NewUserEditor('0');
end;

end.
