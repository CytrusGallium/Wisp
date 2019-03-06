{Deprecated}
unit WispLoginDialog;

interface

uses
  Dialogs,
  Forms,
  StdCtrls,
  ExtCtrls,
  Graphics,
  Controls,
  Classes,
  cxTextEdit,
  cxButtons,
  WispEditBox,
  WispDatePicker;

type
  TLoginDialogResult = record
    UserName: string;
    PassWord: string;
  end;

type
  TLoginDialog = Class(TObject)
  private
    LoginDialogForm: TForm;
    Panel: TPanel;
    UserEdtBox: TWispEditBox;
    PassEdtBox: TWispEditBox;
    DateEdtBox: TWispDatePicker;
    BtnOk: TcxButton;
    BtnCancel: TcxButton;
    UserName : string;
    PassWord : string;
    procedure BtnOk_OnClick(Sender: TObject);
    procedure BtnCancel_OnClick(Sender: TObject);
  protected
  public
    function ShowLoginDialog(): TLoginDialogResult;
  end;

implementation

// =============================================================================
Function TLoginDialog.ShowLoginDialog(): TLoginDialogResult;
begin
  LoginDialogForm := TForm.Create(nil);
  with LoginDialogForm do
  begin
    Width := 320;
    Height := 200;
    BorderStyle := bsNone;
    Color := clGray;
  end;

  UserEdtBox := TWispEditBox.Create(LoginDialogForm, LoginDialogForm, 256, 1, 16,
    32, 'Username');
  UserEdtBox.CenterHorizontally;
  PassEdtBox := TWispEditBox.Create(LoginDialogForm, LoginDialogForm, 256, 1, 16,
    80, 'Password');
  PassEdtBox.CenterHorizontally;

  BtnOk := TcxButton.Create(LoginDialogForm);
  with BtnOk do
  begin
    Parent := LoginDialogForm;
    Width := 64;
    Height := 24;
    Caption := 'OK';
    Top := 144;
    Left := 80;
    Default := TRUE;
    OnClick := BtnOk_OnClick;
  end;

  BtnCancel := TcxButton.Create(LoginDialogForm);
  with BtnCancel do
  begin
    Parent := LoginDialogForm;
    Width := 64;
    Height := 24;
    Caption := 'Cancel';
    Top := 144;
    Left := 176;
    OnClick := BtnCancel_OnClick;
  end;

  LoginDialogForm.Left := (Screen.Width - LoginDialogForm.Width) div 2;
  LoginDialogForm.Top := (Screen.Height - LoginDialogForm.Height) div 2;

  LoginDialogForm.ShowModal;

  Result.UserName := UserName;
  Result.PassWord := PassWord;

end;

// =============================================================================
procedure TLoginDialog.BtnOk_OnClick(Sender: TObject);
begin
  // Global_Singleton_AccesManager.Login(UserEdtBox.EdtBox.Text,
  // PassEdtBox.EdtBox.Text);
  // LoginDialogForm.Free;
  UserName := UserEdtBox.EdtBox.Text;
  PassWord := PassEdtBox.EdtBox.Text;
  LoginDialogForm.Release;
  LoginDialogForm.Close;
  // LoginDialogForm.ModalResult := mrOk;
  // Self.Free;
end;

// =============================================================================
procedure TLoginDialog.BtnCancel_OnClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.
