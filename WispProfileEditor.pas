unit WispProfileEditor;

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
  cxTL,
  cxLookAndFeelPainters,
  Messages,
  Windows,
  WispProfile,
  WispPrivilege,
  WispProfileGrid,
  WispTreeListNode,
  DB,
  DBTables,
  WispStyleManager,
  WispConstantManager,
  WispImageTools,
  WispButton;

Const
  EdtWidth = 320;

type
  TWispProfileEditor = Class(TObject)
  private
    // Profile Editor
    CurrentID: String;
    EditMode: Boolean;
    BoxProfileEditor: TScrollBox;
    DbColumns: Array of string;
    BtnOk: TWispButton;
    Tab: TcxTabSheet;
    EdtName: TWispEditBox;
    TreeList: TcxTreeList;
    TreeListColumnName: TcxTreeListColumn;
    TreeListColumnCheckbox: TcxTreeListColumn;
    CurrentProfile: TWispProfile;
    CurrentNode: TWispTreeListNode;
    Procedure NewProfileToDb;
    Procedure UpdateProfileToDb;
    procedure BtnOk_OnClick(Sender: TObject);
    procedure TabOnShow(Sender: TObject);
    procedure TreeListOnCheck(Sender: TcxCustomTreeList; ANode: TcxTreeListNode;
      AState: TcxCheckBoxState);
    procedure TreeListEditValueChanged(Sender: TcxCustomTreeList;
      AColumn: TcxTreeListColumn);
    procedure TreeListNodeChanged(Sender: TcxCustomTreeList;
      ANode: TcxTreeListNode; AColumn: TcxTreeListColumn);
  protected
  public
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl;
      ParamProfileId: string = '0');
  end;

implementation

uses WispMainMenuManager;

// =============================================================================
Constructor TWispProfileEditor.Create(ParamOwner: TComponent;
  ParamParent: TWinControl; ParamProfileId: string = '0');
var
  H, YOffset: integer;
begin
  // The editor is owned and drawn on a tab
  Tab := TcxTabSheet(ParamOwner); // So basicly tab is ParamOwner
  Tab.OnShow := Self.TabOnShow;
  YOffset := 16;

  if ParamProfileId = '0' then
  begin
    EditMode := FALSE;
    CurrentProfile := TWispProfile.Create('New', TRUE);
    // CurrentGlobalPrivilege := TWispGlobalPrivilege.Create;
    // CurrentEntityPriviege := TWispEntityPrivilege.Create;
  end;

  // ...
  if ParamProfileId <> '0' then
  begin
    EditMode := TRUE;
  end;

  // Create the entity editor scroll box
  BoxProfileEditor := TScrollBox.Create(ParamOwner);
  with BoxProfileEditor do
  begin
    Width := 320;
    Height := H;
    BorderStyle := bsNone;
    Parent := ParamParent;
    Color := clGray;
    Align := alClient;
    Global_Singleton_MainMenuManager.CurrentFocusedScrollBox :=
      Self.BoxProfileEditor;
  end;

  // BG
  DrawBgImage(BoxProfileEditor);

  // Profile name edit box
  EdtName := TWispEditBox.Create(ParamOwner, BoxProfileEditor, EdtWidth, 1, 0,
    YOffset, 'Profile name');
  EdtName.CenterHorizontally;

  YOffset := YOffset + 80;

  // Tree
  TreeList := TcxTreeList.Create(BoxProfileEditor);
  with TreeList do
  begin
    Parent := BoxProfileEditor;
    Width := Round(BoxProfileEditor.ClientWidth / 2);
    Height := Round((Parent.Height) * 0.75);
    Top := YOffset + 32;
    Left := Round((Parent.Width - Width) / 2);
    // OnNodeCheckChanged := TreeListOnCheck;
    // OnEditValueChanged := TreeListEditValueChanged;
    // OnNodeChanged := TreeListNodeChanged;
  end;

  YOffset := YOffset + TreeList.Height;

  TreeList.Bands.Add;

  TreeListColumnName := TreeList.CreateColumn(TreeList.Bands[0]);
  TreeListColumnName.Caption.Text := 'Privilege';
  TreeListColumnName.Options.Editing := FALSE;

  TreeListColumnCheckbox := TreeList.CreateColumn(TreeList.Bands[0]);
  TreeListColumnCheckbox.Caption.Text := 'Availability';
  TreeListColumnCheckbox.PropertiesClassName := 'TcxCheckBoxProperties';

  // Draw privileges content
  // CurrentGlobalPrivilege.Draw(TreeList);
  // CurrentEntityPriviege.Draw(TreeList);
  CurrentProfile.Draw(TreeList);

  // Add Ok and Cancel buttons
  BtnOk := TWispButton.Create(BoxProfileEditor);
  with BtnOk do
  begin
    Parent := BoxProfileEditor;
    Width := 64;
    Height := 24;
    Caption := 'OK';
    Top := YOffset + 50;
    Left := Round((Parent.Width - Width) / 2);
    Default := TRUE;
    OnClick := BtnOk_OnClick;
  end;

  if ParamProfileId <> '0' then
  begin
    // EdtUserName.EdtBox.Text := TmpUser.UserName;
  end;

  // ...
  BoxProfileEditor.Show;
end;

// =============================================================================
procedure TWispProfileEditor.BtnOk_OnClick(Sender: TObject);
const
  WM_KILLTAB = WM_USER + 1;
Var
  TmpProfileGid: TWispProfileGrid;
begin
  CurrentProfile.LoadFromList;
  CurrentProfile.NewToDb(EdtName.EdtBox.Text);

  TmpProfileGid := TWispProfileGrid
    (Global_Singleton_MainMenuManager.PageControlMain.GetParentObject
    ('PROFILE_EDIT', 'PROFILE', '0'));
  // TmpProfileGid.RefreshGrid;
  Global_Singleton_MainMenuManager.PageControlMain.UnRegisterTab('PROFILE_EDIT',
    'PROFILE', '0');
  PostMessage(Global_Singleton_MainMenuManager.PageControlMain.Handle,
    WM_KILLTAB, 0, Tab.PageIndex);
end;

// =============================================================================
Procedure TWispProfileEditor.NewProfileToDb;
const
  WM_KILLTAB = WM_USER + 1;
Var
  TmpProfileGrid: TWispProfileGrid;
  // TmpUser: TWispUser;
begin

  if EdtName.GetText = '' then
  begin
    ShowMessage('Please enter a name');
    EXIT;
  end;

  TmpProfileGrid := TWispProfileGrid
    (Global_Singleton_MainMenuManager.PageControlMain.GetParentObject
    ('PROFILE_EDIT', 'PROFILE', '0'));
  Global_Singleton_MainMenuManager.PageControlMain.UnRegisterTab('PROFILE_EDIT',
    'PROFILE', '0');
  PostMessage(Global_Singleton_MainMenuManager.PageControlMain.Handle,
    WM_KILLTAB, 0, Tab.PageIndex);
end;

// =============================================================================
Procedure TWispProfileEditor.UpdateProfileToDb;
begin

end;

// =============================================================================
procedure TWispProfileEditor.TabOnShow(Sender: TObject);
begin
  Global_Singleton_MainMenuManager.CurrentFocusedScrollBox :=
    Self.BoxProfileEditor;
end;

// =============================================================================
procedure TWispProfileEditor.TreeListOnCheck(Sender: TcxCustomTreeList;
  ANode: TcxTreeListNode; AState: TcxCheckBoxState);
begin
  // ShowMessage('Useless event ?');
end;

// =============================================================================
procedure TWispProfileEditor.TreeListEditValueChanged(Sender: TcxCustomTreeList;
  AColumn: TcxTreeListColumn);
var
  I: integer;
begin
  // Must find a solution for this laterfo

  // if CurrentNode.Level = 1 then
  // begin
  // CurrentNode[0].Values[1] := TRUE;
  // end
  // else if CurrentNode.Level = 2 then
  // begin
  // CurrentNode.Parent.Values[1] := TRUE;
  // end;
end;

// =============================================================================
procedure TWispProfileEditor.TreeListNodeChanged(Sender: TcxCustomTreeList;
  ANode: TcxTreeListNode; AColumn: TcxTreeListColumn);
begin
  // CurrentNode := TWispTreeListNode(ANode);
end;

end.
