unit WispEditBox;

interface

uses
  cxTextEdit,
  cxLabel,
  cxButtons,
  WispButton,
  Windows,
  SysUtils,
  Controls,
  Classes,
  Dialogs,
  ShellAPI,
  cxMemo,
  WispVisualComponent,
  WispStyleManager;

type
  TWispEditBox = Class(TWispVisualComponent)
  private
    Spacing: integer;
    LineCount: integer;
    FLocalFileSelector: Boolean;
    Owner: TComponent;
    // Parent: TWinControl;
    // X, Y, EdtWidth: integer;
    procedure BtnSelect_OnClick(Sender: TObject);
    procedure BtnOpen_OnClick(Sender: TObject);
  public
    Lbl: TcxLabel;
    SuffixLbl: TcxLabel;
    EdtBox: TcxTextEdit;
    MemoBox: TcxMemo;
    BtnSelector: TcxButton;
    BtnOpen: TcxButton;
    // Property LocalFileSelector: Boolean Read FLocalFileSelector
    // Write FLocalFileSelector;
    Constructor Create(ParamOwner: TComponent; ParamParent: TWinControl;
      ParamEdtWidth, ParamLineCount, ParamX, ParamY: integer;
      ParamCaption: String; ParamSelector: Boolean = FALSE);
    procedure CenterHorizontally;
    Function GetText(): String;
  End;

implementation

// =============================================================================
Constructor TWispEditBox.Create(ParamOwner: TComponent;
  ParamParent: TWinControl; ParamEdtWidth, ParamLineCount, ParamX,
  ParamY: integer; ParamCaption: String; ParamSelector: Boolean = FALSE);
Var
  TmpI: integer;
begin
  Owner := ParamOwner;
  // Parent := ParamParent;
  // X := ParamX;
  // Y := ParamY;
  // EdtWidth := ParamEdtWidth;

  if ParamLineCount <= 1 then
  begin
    TmpI := 1;
    LineCount := 1;
  end
  else if ParamLineCount > 1 then
  begin
    TmpI := ParamLineCount;
    LineCount := ParamLineCount;
  end;

  Lbl := TcxLabel.Create(ParamOwner);
  with Lbl do
  begin
    if ParamCaption = '' then
    begin
      Height := 16;
      Width := ParamEdtWidth;
    end;
    Parent := ParamParent;
    ParentFont := FALSE;
    Caption := ParamCaption;
    Left := ParamX;
    Top := ParamY;
    // Style.Color := Global_Singleton_Style.CurrentStyle;
    Style.Font.Name := 'Segoe UI';
    Style.Font.Color := Global_Singleton_Style.TextColor;
    Transparent := TRUE;
  end;

  if TmpI = 1 then
  begin
    EdtBox := TcxTextEdit.Create(ParamOwner);
    with EdtBox do
    begin
      Width := ParamEdtWidth;
      Height := 32;
      Parent := ParamParent;
      ParentFont := FALSE;
      Text := '';
      Left := ParamX;
      Top := ParamY + Lbl.Height + Spacing;
    end;
  end
  else if TmpI > 1 then
  begin
    MemoBox := TcxMemo.Create(ParamOwner);
    with MemoBox do
    begin
      Width := ParamEdtWidth;
      Height := 15 * TmpI;
      Parent := ParamParent;
      ParentFont := FALSE;
      Text := '';
      Left := ParamX;
      Top := ParamY + Lbl.Height + Spacing;
    end;
  end;

  SuffixLbl := TcxLabel.Create(ParamOwner);
  with SuffixLbl do
  begin
    Height := 16;
    Width := ParamEdtWidth;
    Parent := ParamParent;
    ParentFont := FALSE;
    Caption := '';
    Left := ParamX + ParamEdtWidth + 16;
    Top := ParamY + Lbl.Height + 4;
    Style.Font.Name := 'Segoe UI';
    Style.Font.Color := Global_Singleton_Style.TextColor;
    Transparent := TRUE;
  end;

  if ParamSelector then
  begin
    FLocalFileSelector := TRUE;
    begin
      BtnSelector := TcxButton.Create(ParamOwner);
      with BtnSelector do
      begin
        Parent := ParamParent;
        ParentFont := FALSE;
        Width := 24;
        Height := 24;
        Caption := 'S';
        Top := ParamY + 16;
        Left := ParamX + ParamEdtWidth + 16;
        OnClick := BtnSelect_OnClick;
      end;
      BtnOpen := TcxButton.Create(ParamOwner);
      with BtnOpen do
      begin
        Parent := ParamParent;
        ParentFont := FALSE;
        Width := 24;
        Height := 24;
        Caption := 'O';
        Top := ParamY + 16;
        Left := ParamX + ParamEdtWidth + 40;
        OnClick := BtnOpen_OnClick;
      end;
    end;
  end;

end;

// =============================================================================
procedure TWispEditBox.CenterHorizontally;
Var
  TmpInt: integer;
begin
  if LineCount = 1 then
  begin
    TmpInt := Round((EdtBox.Parent.Width - EdtBox.Width) / 2);
    Lbl.Left := TmpInt;
    SuffixLbl.Left := TmpInt + EdtBox.Width + 4;
    EdtBox.Left := TmpInt;

    if FLocalFileSelector then
    begin
      BtnSelector.Left := TmpInt + EdtBox.Width + 2;
      BtnOpen.Left := TmpInt + EdtBox.Width + 26;
    end;

  end
  else if LineCount > 1 then
  begin
    TmpInt := Round((MemoBox.Parent.Width - MemoBox.Width) / 2);
    Lbl.Left := TmpInt;
    SuffixLbl.Left := TmpInt + MemoBox.Width + 4;
    MemoBox.Left := TmpInt;

    if FLocalFileSelector then
    begin
      BtnSelector.Left := TmpInt + EdtBox.Width + 2;
      BtnOpen.Left := TmpInt + EdtBox.Width + 26;
    end;

  end;
end;

// =============================================================================
Function TWispEditBox.GetText(): String;
Var
  TmpInt: integer;
begin
  if LineCount = 1 then
  begin
    Result := EdtBox.Text;
  end
  else if LineCount > 1 then
  begin
    Result := MemoBox.Text;
  end;
end;

// =============================================================================
procedure TWispEditBox.BtnSelect_OnClick(Sender: TObject);
Var
  openDialog: TOpenDialog;
begin
  // Create the open dialog object - assign to our open dialog variable
  openDialog := TOpenDialog.Create(Owner);

  // Set up the starting directory to be the current one
  // openDialog.InitialDir := GetCurrentDir;

  // Only allow existing files to be selected
  openDialog.Options := [ofFileMustExist];

  // Allow only .dpr and .pas files to be selected
  // openDialog.Filter :=
  // 'Delphi project files|*.dpr|Delphi pascal files|*.pas';

  // Select pascal files as the starting filter type
  // openDialog.FilterIndex := 2;

  // Display the open file dialog
  if openDialog.Execute then
    EdtBox.Text := openDialog.FileName;

  // Free up the dialog
  openDialog.Free;
end;

// =============================================================================
procedure TWispEditBox.BtnOpen_OnClick(Sender: TObject);
Var
  Path: String;
begin
  Path := EdtBox.Text;
  if FileExists(Path) then
    ShellExecute(HInstance, 'open', PChar(Path), nil, nil, SW_NORMAL);
end;

end.
