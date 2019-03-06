unit WispPanelSearch;

interface

uses
  ExtCtrls,
  CxLabel,
  Controls,
  Graphics,
  Classes,
  SysUtils,
  CxButtons,
  CxGrid,
  CxGridLevel,
  CxGridTableView,
  CxGridDbTableView,
  WispEntity,
  WispEntityManager,
  WispPageControl,
  WispConsole,
  WispButton,
  WispEditBox,
  WispStyleManager,
  WispStyleConstants,
  cxPC,
  WispConstantManager;

type
  TWispPanelSearch = Class(TObject)
  Private
    procedure Btn_OnClick(Sender: TObject);
  Public
    PanelMain: TPanel;
    Constructor Create(ParamParent: TWinControl;
      ParamWidth, ParamHeigth, ParamLeft, ParamTop: integer);
  End;

implementation

uses
  WispMainMenuManager;

// =============================================================================
procedure TWispPanelSearch.Btn_OnClick(Sender: TObject);
Var
  TmpTab: TcxTabSheet;
begin

  TmpTab := Global_Singleton_MainMenuManager.PageControlMain.CheckIfTabExists
    ('GRID', (Sender As TComponent).Name, '0');

  if TmpTab = nil then
  begin
    Global_Singleton_MainMenuManager.NewEntityGrid
      (TWispButton(Sender).CommandString);
  end
  else
  begin
    Global_Singleton_MainMenuManager.PageControlMain.ActivePage := TmpTab;
  end;
end;

// =============================================================================
Constructor TWispPanelSearch.Create(ParamParent: TWinControl;
  ParamWidth, ParamHeigth, ParamLeft, ParamTop: integer);
Var
  MaxButtonsPerRow: integer;
  MaxButtonsRows: integer;
  MaxButtons: integer;
  I: integer;
  J: integer;
  C: integer;
  TmpS: String;
  BtnTmp: TWispButton;
  E: TEntity;
  Lbl: TcxLabel;
  EdtSearch: TWispEditBox;
  Grid: TcxGrid;
  GridLevelOne: TCxGridLevel;
  GridViewOne: TcxGridTableView;
begin

  // =====================================
  PanelMain := TPanel.Create(ParamParent);
  With PanelMain do
  begin
    Caption := '';
    Parent := ParamParent;
    ParentBackground := FALSE;
    Color := Global_Singleton_Style.BgColor;
    Height := ParamHeigth;
    Width := ParamWidth;
    Left := ParamLeft;
    Top := ParamTop;
  end;

  // =====================================
  EdtSearch := TWispEditBox.Create(PanelMain, PanelMain, 320, 1, 16, 16, '');
  EdtSearch.EdtBox.Align := alTop;
  EdtSearch.EdtBox.TextHint := 'Search...';

  // =====================================
  // Create the grid
  Grid := TcxGrid.Create(PanelMain);
  with Grid do
  begin
    Parent := PanelMain;
    Align := alClient;
    Font.Name := Global_Singleton_Style.DefaultFont;
    Font.Size := 10;
    Font.Color := Global_Singleton_Style.TextColor;
    Width := Parent.Width - 64;
    Height := Parent.Height - 96;
    Left := Parent.Width - (Parent.Width - 32);
    Top := 64;
  end;

  // Create a level and a view in the grid
  GridViewOne := Grid.CreateView(TcxGridDbTableView) as TcxGridDbTableView;
  GridViewOne.Name := 'SomeViewName';

  GridLevelOne := Grid.levels.Add;
  GridLevelOne.Name := 'SomeLevelName';
  GridLevelOne.GridView := GridViewOne;

  // Customize the view
  GridViewOne.OptionsView.NoDataToDisplayInfoText :=
    Global_Singleton_ConstantManager.GetLanguageConst('NoDataToDisplay');
  GridViewOne.OptionsView.GroupByBox := FALSE;
  GridViewOne.OptionsSelection.CellSelect := FALSE;
  GridViewOne.OptionsCustomize.ColumnFiltering := FALSE;
  GridViewOne.Styles.Content := Global_Singleton_Style.CurrentStyle;
  GridViewOne.Styles.Background := Global_Singleton_Style.CurrentStyle;

end;

end.
