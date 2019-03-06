unit WispGrid;

interface

uses
  cxGrid,
  cxGridLevel,
  cxGridTableView,
  cxGridDbTableView,
  Messages,
  Controls,
  Classes,
  WispStyleManager;

type
  TWispGrid = Class(TcxGrid)
  private
    GridLevelTwo: TCxGridLevel;
    GridViewTwo: TcxGridTableView;
  public
    GridMainLevel: TCxGridLevel;
    GridMainView: TcxGridTableView;

    Constructor Create(AOwner: TComponent); override;
  End;

implementation

// =============================================================================
Constructor TWispGrid.Create(AOwner: TComponent);
begin
  Inherited;
  Parent := TWinControl(AOwner);
  Align := alClient;
  Font.Name := S.DefaultFont;
  Font.Size := 10;
  // Color := clGray;

  // Create a level and a view in the grid
  GridMainView := Self.CreateView(TcxGridDBTableView) as TcxGridDBTableView;
  GridMainView.Name := 'SomeViewName';

  GridMainLevel := Self.levels.Add;
  GridMainLevel.Name := 'SomeLevelName';
  GridMainLevel.GridView := GridMainView;

  // Customize the view
  With GridMainView do
  begin
    LookAndFeel.NativeStyle := FALSE;
    OptionsView.NoDataToDisplayInfoText := ' No Data To Display ';
    OptionsView.GroupByBox := FALSE;
    OptionsSelection.CellSelect := FALSE;
    OptionsCustomize.ColumnFiltering := FALSE;
    Styles.Content := S.CurrentStyle;
    Styles.Background := S.CurrentStyle;
    Styles.Selection := S.CurrentHighlightStyle;
    Styles.Inactive := S.CurrentQuietStyle;
    OptionsData.Deleting := FALSE;
  end;
end;

end.
