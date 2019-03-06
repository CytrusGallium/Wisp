unit WispReportGrid;

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
  TReportGrid = Class(TObject)
  private
    FormReportGrid: TForm;
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
  protected
  public
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl);
    procedure BtnEdit_OnClick(Sender: TObject);
    Procedure RefreshGrid;
  end;

implementation

uses
  WispMainMenuManager,
  CxPC;

// =============================================================================
Constructor TReportGrid.Create(ParamOwner: TComponent;
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
  FormReportGrid := TForm.Create(ParamOwner);
  with FormReportGrid do
  begin
    // Width := TcxTabSheet(ParamOwner).Width;
    // Height := 600;
    BorderStyle := bsNone;
    Color := clGray;
    Parent := ParamParent;
    Align := alClient;
  end;

  // Create the toolbar panel
  PanelTop := TPanel.Create(FormReportGrid);
  With PanelTop do
  begin
    Caption := '';
    Parent := FormReportGrid;
    ParentBackground := FALSE;
    Color := cl3DDkShadow;
    Align := alTop;
    Width := Screen.Width;
    Height := 32;
  end;

  // BG
  DrawBgImage(PanelTop);

  // Create Toolbar buttons
  BtnEdit := TWispButton.Create(PanelTop);
  with BtnEdit do
  begin
    Parent := PanelTop;
    Width := 72;
    Height := 24;
    Caption := 'Edit';
    Top := 4;
    Left := 4 + 72;
    OnClick := BtnEdit_OnClick;
  end;

  Grid := TWispGrid.Create(FormReportGrid);

  QueryString := 'SELECT * FROM wisp_reports;';

  RefreshGrid;

  FormReportGrid.Show;

end;

// =============================================================================
procedure TReportGrid.RefreshGrid;
begin
  // ...
  HasController := FALSE;

  ShowQueryResult(Global_Singleton_DbConnection, QueryString, Grid);

  Grid.GridMainView.Columns[GetColumnIndexFromColumnCaption(Grid.GridMainView, 'ID')
    ].Visible := FALSE;

  // Auto resize columns
  Grid.GridMainView.ApplyBestFit();
    MaximizeColumnWidth(Grid.GridMainView as TcxGridDBTableView,
    FormReportGrid.Parent.Width);

  // ...
  HasController := TRUE;
  // RefreshButtons;
end;

// =============================================================================
procedure TReportGrid.BtnEdit_OnClick(Sender: TObject);
Var
  TmpId: String;
begin
  // ShowMessage(GridViewOne.Controller.FocusedRow.Values[0]);
  TmpId := IntToStr(Grid.GridMainView.Controller.FocusedRow.Values[0]);
  Global_Singleton_MainMenuManager.NewReportEditor(TmpId);
end;

end.
