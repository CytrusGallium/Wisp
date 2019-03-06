unit WispUserEditor;

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
  WispUser,
  WispUserGrid,
  WispStyleManager,
  WispConstantManager,
  WispImageTools,
  WispButton;

Const
  EdtWidth = 320;

type
  TUserEditor = Class(TObject)
  private
    // User Editor
    CurrentID: String;
    EditMode: Boolean;
    BoxUserEditor: TScrollBox;
    DbColumns: Array of string;
    BtnOk: TWispButton;
    Tab: TcxTabSheet;
    EdtUserName: TWispEditBox;
    EdtPassWord: TWispEditBox;
    EdtPassConf: TWispEditBox;
    EdtFirstName: TWispEditBox;
    EdtFamilyName: TWispEditBox;
    EdtUserPhone: TWispEditBox;
    EdtUserMail: TWispEditBox;
    LookUpProfile: TWispLookUpComboBox;
    Procedure NewUserToDb;
    Procedure UpdateUserToDb;
    procedure BtnOk_OnClick(Sender: TObject);
    procedure TabOnShow(Sender: TObject);
  protected
  public
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl;
      ParamUserId: string = '0');
  end;

implementation

uses WispMainMenuManager;

// =============================================================================
Constructor TUserEditor.Create(ParamOwner: TComponent; ParamParent: TWinControl;
  ParamUserId: string = '0');
var
  H, YOffset: integer;
  TmpUser: TWispUser;
begin
  // The editor is owned and drawn on a tab
  Tab := TcxTabSheet(ParamOwner); // So basicly tab is ParamOwner
  Tab.OnShow := Self.TabOnShow;
  YOffset := 16;

  if ParamUserId = '0' then
  begin
    EditMode := FALSE;
  end;

  // ...
  if ParamUserId <> '0' then
  begin
    EditMode := TRUE;
    TmpUser := TWispUser.Create;
    TmpUser.LoadFromDbById(ParamUserId);
  end;

  // Create the entity editor form
  BoxUserEditor := TScrollBox.Create(ParamOwner);
  with BoxUserEditor do
  begin
    Width := 320;
    Height := H;
    BorderStyle := bsNone;
    Parent := ParamParent;
    Color := clGray;
    Align := alClient;
    Global_Singleton_MainMenuManager.CurrentFocusedScrollBox :=
      Self.BoxUserEditor;
  end;

  // BG
  DrawBgImage(BoxUserEditor);

  // Username
  EdtUserName := TWispEditBox.Create(ParamOwner, BoxUserEditor, EdtWidth, 1, 0,
    YOffset, 'Username');
  EdtUserName.CenterHorizontally;
  YOffset := YOffset + 80;

  // Password 1
  EdtPassWord := TWispEditBox.Create(ParamOwner, BoxUserEditor, EdtWidth, 1, 0,
    YOffset, 'Password');
  EdtPassWord.EdtBox.Properties.EchoMode := eemPassword;
  EdtPassWord.CenterHorizontally;
  YOffset := YOffset + 80;

  // Password 2
  EdtPassConf := TWispEditBox.Create(ParamOwner, BoxUserEditor, EdtWidth, 1, 0,
    YOffset, 'Password Confirmation');
  EdtPassConf.EdtBox.Properties.EchoMode := eemPassword;
  EdtPassConf.CenterHorizontally;
  YOffset := YOffset + 80;

  // First Name
  EdtFirstName := TWispEditBox.Create(ParamOwner, BoxUserEditor, EdtWidth, 1, 0,
    YOffset, 'First Name');
  EdtFirstName.CenterHorizontally;
  YOffset := YOffset + 80;

  // Family Name
  EdtFamilyName := TWispEditBox.Create(ParamOwner, BoxUserEditor, EdtWidth, 1,
    0, YOffset, 'Family Name');
  EdtFamilyName.CenterHorizontally;
  YOffset := YOffset + 80;

  // Phone Number
  EdtUserPhone := TWispEditBox.Create(ParamOwner, BoxUserEditor, EdtWidth, 1, 0,
    YOffset, 'Phone Number');
  EdtUserPhone.CenterHorizontally;
  YOffset := YOffset + 80;

  // E-Mail
  EdtUserMail := TWispEditBox.Create(ParamOwner, BoxUserEditor, EdtWidth, 1, 0,
    YOffset, 'E-Mail');
  EdtUserMail.CenterHorizontally;
  YOffset := YOffset + 80;

  // Profile
  LookUpProfile := TWispLookUpComboBox.Create(ParamOwner, BoxUserEditor,
    EdtWidth, 0, YOffset, 'Profile');
  LookUpProfile.CenterHorizontally;
  LookUpProfile.LoadFromTable('wisp_profiles', 'WISP_NAME', 'Name', 'WISP_ID');
  YOffset := YOffset + 80;

  // Add Ok and Cancel buttons
  BtnOk := TWispButton.Create(BoxUserEditor);
  with BtnOk do
  begin
    Parent := BoxUserEditor;
    Width := 64;
    Height := 24;
    Caption := 'OK';
    Top := YOffset + 50;
    Left := Round((Parent.Width - Width) / 2);
    Default := TRUE;
    OnClick := BtnOk_OnClick;
  end;

  if ParamUserId <> '0' then
  begin
    EdtUserName.EdtBox.Text := TmpUser.UserName;
    EdtFirstName.EdtBox.Text := TmpUser.FirstName;
    EdtFamilyName.EdtBox.Text := TmpUser.FamilyName;
    EdtUserPhone.EdtBox.Text := TmpUser.PhoneNumber;
    EdtUserMail.EdtBox.Text := TmpUser.Email;
  end;

  // ...
  BoxUserEditor.Show;
end;

// =============================================================================
procedure TUserEditor.BtnOk_OnClick(Sender: TObject);
begin
  if EditMode = FALSE then
    NewUserToDb;
end;

// =============================================================================
Procedure TUserEditor.NewUserToDb;
const
  WM_KILLTAB = WM_USER + 1;
Var
  TmpUserGrid: TUserGrid;
  TmpUser: TWispUser;
begin

  if EdtUserName.GetText = '' then
  begin
    ShowMessage('Please enter a username');
    EXIT;
  end;

  if Global_Singleton_AccesManager.CheckIfUserNameExists(EdtUserName.GetText)
  then
  begin
    ShowMessage('This username is already used');
    EXIT;
  end;

  if EdtPassWord.GetText = '' then
  begin
    ShowMessage('Please enter a password');
    EXIT;
  end;

  if not(EdtPassWord.GetText = EdtPassConf.GetText) then
  begin
    ShowMessage('Passwords does not match');
    EXIT;
  end;

  if LookUpProfile.LookUpComboBox.ItemIndex = -1 then
  begin
    ShowMessage('Please select a profile');
    EXIT;
  end;

  Global_Singleton_AccesManager.AddNewUser(EdtUserName.GetText,
    EdtPassWord.GetText);

  TmpUser := TWispUser.Create;
  TmpUser.UserName := EdtUserName.GetText;
  TmpUser.FirstName := EdtFirstName.GetText;
  TmpUser.FamilyName := EdtFamilyName.GetText;
  TmpUser.PhoneNumber := EdtUserPhone.GetText;
  TmpUser.Email := EdtUserMail.GetText;

  Global_Singleton_AccesManager.SaveUserByUserName(TmpUser);

  TmpUser.LoadFromDbByUserName(EdtUserName.GetText);
  TmpUser.UpdateProfileId
    (LookUpProfile.GetKey(LookUpProfile.LookUpComboBox.ItemIndex));

  TmpUserGrid := TUserGrid(Global_Singleton_MainMenuManager.PageControlMain.
    GetParentObject('USER_EDIT', 'USER', '0'));
  // TmpUserGrid.RefreshGrid;
  Global_Singleton_MainMenuManager.PageControlMain.UnRegisterTab('USER_EDIT',
    'USER', '0');
  PostMessage(Global_Singleton_MainMenuManager.PageControlMain.Handle,
    WM_KILLTAB, 0, Tab.PageIndex);
end;

// =============================================================================
Procedure TUserEditor.UpdateUserToDb;
begin

end;

// =============================================================================

procedure TUserEditor.TabOnShow(Sender: TObject);
begin
  Global_Singleton_MainMenuManager.CurrentFocusedScrollBox :=
    Self.BoxUserEditor;
end;

end.
