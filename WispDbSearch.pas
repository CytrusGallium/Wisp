unit WispDbSearch;

interface

uses
  Variants,
  KwhCommon,
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ZAbstractConnection,
  ZConnection,
  Data.DB,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  TypInfo,
  cxGridDBTableView,
  cxCheckBox,
  cxTextEdit,
  stdCtrls,
  cxCalendar,
  StrUtils,
  StrFlex,
  cxGrid,
  ExtCtrls,
  cxStyles,
  dxSkinsCore,
  dxSkinsDefaultPainters,
  dxSkinscxPCPainter,
  cxCustomData,
  cxGraphics,
  cxFilter,
  cxData,
  cxDataStorage,
  cxEdit,
  cxDBData,
  cxGridLevel,
  cxGridCustomTableView,
  cxClasses,
  cxControls,
  cxGridCustomView,
  ViewTools,
  cxGridTableView,
  cxProgressBar,
  cxLabel,
  FuzzyMatchingResultDialog,
  ArrayFlex;

type
  TFuzzySearchResult = record
    TopID: StrArray;
    aTopRow: array of Integer;
    IDArrayAsString: string;
    TopRate: Real;
    TopString: String;
  end;

implementation

end.
