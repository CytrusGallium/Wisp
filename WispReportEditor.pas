unit WispReportEditor;

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
  frxClass,
  frxDesgn,
  frxDBSet,
  DB,
  Printers,
  WispStyleManager,
  WispConstantManager,
  WispImageTools,
  WispButton;

Const
  EdtWidth = 320;

type
  TReportEditor = Class(TObject)
  private
    // Entity Editor
    CurrentID: String;
    Report: TFrxReport;
    ReportDesigner: TfrxDesigner;
    TmpQ: TZQuery;
    BoxEntityEditor: TScrollBox;
    BtnOk: TcxButton;
    Tab: TcxTabSheet;
  protected
  public

    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl;
      ParamId: string = '0');
    procedure Save;
    procedure CloseDesigner;
    procedure TabOnShow(Sender: TObject);
  end;

implementation

uses WispMainMenuManager;

// =============================================================================
Constructor TReportEditor.Create(ParamOwner: TComponent;
  ParamParent: TWinControl; ParamId: string = '0');
var
  I, TmpI, H, YOffset: integer;
  S, TmpName: string;
  FrxDataSet: TFrxDBDataSet;
  DataBand: TfrxMasterData;
  Band: TfrxBand;
  GroupFooter: TfrxGroupFooter;
  Stream: TStream;
  Page: TfrxReportPage;
  TmpBoolean: Boolean;
begin
  // ...
  CurrentID := ParamId;

  // The editor is owned and drawn on a tab
  Tab := TcxTabSheet(ParamOwner); // So basicly tab is ParamOwner
  Tab.OnShow := Self.TabOnShow;

  // Create the entity editor form
  BoxEntityEditor := TScrollBox.Create(ParamOwner);
  with BoxEntityEditor do
  begin
    Width := 320;
    Height := H;
    BorderStyle := bsNone;
    Parent := ParamParent;
    Color := clGray;
    Align := alClient;
    Global_Singleton_MainMenuManager.CurrentFocusedScrollBox :=
      Self.BoxEntityEditor;
  end;

  Report := TFrxReport.Create(ParamOwner);
  TmpQ := OpenQuery(Global_Singleton_DbConnection,
    'SELECT NAME,REPORT FROM wisp_reports WHERE ID=' + ParamId + ';').ZQuery;
  TmpName := TmpQ.FieldByName('NAME').AsString;
  Stream := TmpQ.CreateBlobStream(TmpQ.FieldByName('REPORT'), bmRead);
  Stream.Position := 0;
  Report.LoadFromStream(Stream);
  TmpQ.Free;

  S := Global_Singleton_EntityManager.GetEntityByName(TmpName)
    .GetInstanceQueryString('0');
  TmpQ := OpenQuery(Global_Singleton_DbConnection, S).ZQuery;

  FrxDataSet := TFrxDBDataSet.Create(Global_Singleton_DbConnection);
  FrxDataSet.DataSet := TmpQ;
  FrxDataSet.UserName := 'Report';
  // FrxDataSet.Enabled := TRUE;

  if Report.DataSets.Count = 0 then
  begin
    Report.DataSets.Add(FrxDataSet);
    Report.DataSets.Items[0].DataSet.Enabled := TRUE;
    Report.DataSets.Items[0].DataSet.First;
  end
  else if Report.DataSets.Count = 1 then
  begin
    Report.DataSets.Items[0].DataSet := FrxDataSet;
    Report.DataSets.Items[0].DataSet.First;
  end;

  if Report.PagesCount = 1 Then
  begin
    Page := TfrxReportPage.Create(Report);
    Page.CreateUniqueName;
    Page.SetDefaults;
    Page.PaperSize := DMPAPER_LETTER;
    // Page.Orientation := poLandscape;

    // Add report title band
    Band := TfrxReportTitle.Create(Page);
    Band.CreateUniqueName;
    Band.Top := 0;
    Band.Height := 20;

    // Add masterdata band
    DataBand := TfrxMasterData.Create(Page);
    DataBand.CreateUniqueName;
    DataBand.DataSet := FrxDataSet;
    DataBand.Top := 30;
    DataBand.Height := 20;

    // Group footer creation
    {
      GroupFooter := TfrxGroupFooter.Create(Page);
      GroupFooter.Parent := Page;
      with GroupFooter do
      begin
      CreateUniqueName;
      // SetBounds(0, 0, Page.Width - 75.6, 20);
      Top := 60;
      Height := 20;
      end;
    }
  end;

  Report.DesignReportInPanel(BoxEntityEditor);

  // ...
  BoxEntityEditor.Show;

  // ...
  // Report.DesignReportInPanel(BoxEntityEditor);

end;

// =============================================================================
procedure TReportEditor.Save;
var
  Stream: TMemoryStream;
//  FileStream: TFileStream;
begin
  Stream := TMemoryStream.Create;
  Report.SaveToStream(Stream);
  Stream.Seek(0, soFromBeginning);

  TmpQ.SQL.Clear;
  TmpQ.SQL.Text := 'UPDATE wisp_reports SET REPORT=:blobparam WHERE ID=' +
    CurrentID + ';';
  TmpQ.ParamByName('blobparam').LoadFromStream(Stream, ftBlob);
  TmpQ.ExecSQL;
end;

// =============================================================================
procedure TReportEditor.CloseDesigner;
begin
  Report.Designer.Modified := FALSE;
  Report.Designer.Close;
end;

// =============================================================================
procedure TReportEditor.TabOnShow(Sender: TObject);
begin
  Global_Singleton_MainMenuManager.CurrentFocusedScrollBox :=
    Self.BoxEntityEditor;
end;

end.
