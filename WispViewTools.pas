unit WispViewTools;

interface

uses

  CxGrid,
  CxGridLevel,
  CxGridTableView,
  CxGridDbTableView;

function GetColumnIndexFromColumnCaption(ParamView: TcxGridDBTableView;
  ParamColumnCaption: String): Integer; overload;

function GetColumnIndexFromColumnCaption(ParamView: TcxGridTableView;
  ParamColumnCaption: String): Integer; overload;

Procedure MaximizeColumnWidth(ParamView: TcxGridDBTableView;
  ParamWidth: Integer);

implementation

// =============================================================================
// Get the column index from the caption of a column
function GetColumnIndexFromColumnCaption(ParamView: TcxGridDBTableView;
  ParamColumnCaption: String): Integer;
var
  I: Integer;
begin
  for I := 0 to ParamView.ColumnCount - 1 do
  begin
    if ParamView.Columns[I].Caption = ParamColumnCaption then
    begin
      result := I;
      EXIT;
    end;
  end;
end;

// =============================================================================
// Get the column index from the caption of a column
function GetColumnIndexFromColumnCaption(ParamView: TcxGridTableView;
  ParamColumnCaption: String): Integer;
var
  I: Integer;
begin
  for I := 0 to ParamView.ColumnCount - 1 do
  begin
    if ParamView.Columns[I].Caption = ParamColumnCaption then
    begin
      result := I;
      EXIT;
    end;
  end;
end;

// =============================================================================
// ...
Procedure MaximizeColumnWidth(ParamView: TcxGridDBTableView;
  ParamWidth: Integer);
var
  I, Width, ColumnsWidth: Integer;
  ScalingValue, TmpR: Real;
begin
  // Width := (ParamView.Control as TcxGrid);
  Width := ParamWidth;
  ColumnsWidth := 0;

  for I := 0 to ParamView.ColumnCount - 1 do
  begin
    if ParamView.Columns[I].Visible = TRUE then
      ColumnsWidth := ColumnsWidth + ParamView.Columns[I].Width;
  end;

  if ColumnsWidth < Width then
  begin
    ScalingValue := Width / ColumnsWidth;
    for I := 0 to ParamView.ColumnCount - 1 do
    begin
      if ParamView.Columns[I].Visible = TRUE then
        TmpR := ParamView.Columns[I].Width * ScalingValue;
        ParamView.Columns[I].Width := Round(TmpR);
    end;
  end;

end;

end.
