unit WispMainMenuManager;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Dialogs,
  Forms,
  ExtCtrls,
  Graphics,
  Controls,
  StrUtils,
  Menus,
  cxButtons,
  WispDbConnection,
  ZConnection,
  WispQueryTools,
  WispLoginDialog,
  WispAccesManager,
  WispDistanceTools,
  Vcl.StdCtrls,
  WispPanelUserInfo,
  WispPanelShortCuts,
  WispPanelSearch,
  WispPanelAds,
  WispStyleConstants,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxLabel,
  cxImage,
  WispTimeTools,
  WispEntityManager,
  Vcl.ComCtrls,
  dxCore,
  cxDateUtils,
  cxTextEdit,
  cxMaskEdit,
  cxDropDownEdit,
  cxCalendar,
  WispDatePicker,
  WispEditBox,
  cxPC,
  WispEntityGrid,
  WispEntityEditor,
  WispPageControl,
  WispStyleManager,
  WispHooks,
  WispConsole,
  WispEntity,
  WispPopupMenu,
  WispButton,
  WispConstantManager,
  WispReportGrid,
  WispReportEditor,
  WispUserGrid,
  WispUserEditor,
  WispProfileGrid,
  WispProfileEditor,
  CxStyles,
  WispImageTools,
  CxPcPainters;

type
  TMainMenuManager = class(TObject)
  private
    PanelTop: TPanel;
    PanelMainMenu, PanelLogin, PanelDrm, PanelDevDrm: TPanel;
    BtnExit: TcxButton;
    BtnMinimize: TcxButton;
    BtnConfig: TcxButton;
    BtnLeft: TcxButton;
    BtnRight: TcxButton;
    BtnHome: TcxButton;
    PcBtnExit, PcBtnMinimize, PcBtnConfig, PcBtnLeft, PcBtnRight,
      PcBtnHome: TcxPcButton;
    PcBtnImageList: TCxImageList;
    DbConnection: TDbConnection;
    PanelUserInfo: TWispPanelUserInfo;
    PanelShortCuts: TWispPanelShortCuts;
    PanelSearch: TWispPanelSearch;
    PanelAds: TWispPanelAds;
    DatePicker: TWispDatePicker;
    EdtBox: TWispEditBox;
    TabSheetHome, TabSheetLogin, TabSheetDrm, TabSheetDevDrm: TcxTabSheet;
    fMainMenuForm: TForm;
    KeyboardHook: TKeyboardHook;
    DebugKeyLevel: Integer;
    PopupMenuConfig: TPopupMenu;
    PopupItemUserConfig: TMenuItem;
    PopupItemProfileConfig: TMenuItem;
    PopupItemListsConfig: TMenuItem;
    PopupItemListsReports: TMenuItem;
    aPopupItemLists: Array of TWispMenuItem;
    PictureBackGround: TPicture;
    ImageBackGround: TcxImage;
    DistanceCalculator: TDistanceCalculator;
    EdtUser, EdtPass, EdtDrmInfoCode, EdtLicenseKey: TWispEditBox;
    BtnOK, BtnCancel, BtnDrmOk, BtnDrmCancel: TWispButton;
    procedure BtnExit_OnClick(Sender: TObject);
    procedure BtnMinimize_OnClick(Sender: TObject);
    procedure BtnConfig_OnClick(Sender: TObject);
    procedure BtnOk_OnClick(Sender: TObject);
    procedure BtnCancel_OnClick(Sender: TObject);
    procedure MainForm_OnShow(Sender: TObject);
    procedure ListsMenuItem_OnClick(Sender: TObject);
    procedure ListsMenuItemReport_OnClick(Sender: TObject);
    procedure ListsMenuItemUser_OnClick(Sender: TObject);
    procedure ListsMenuItemProfile_OnClick(Sender: TObject);
    Procedure KeyboardHookPREExecute(Hook: THook; var Hookmsg: THookMsg);
    Procedure OpenHomeTab;
    Procedure OpenLoginTab;
    Procedure OpenDrmTab;
    procedure BtnDrmOk_OnClick(Sender: TObject);
    // Procedure OpenUserEditor(ParamUserId: String);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure CxButtonOnClick_Close(Sender: TObject);
    procedure CxButtonOnClick_Minimize(Sender: TObject);
    procedure CxButtonOnClick_Config(Sender: TObject);
  public
    PageControlMain: TWispPageControl;
    // I see no way to avoid this global variable
    CurrentFocusedScrollBox: TScrollBox;
    Property MainMenuForm: TForm read fMainMenuForm write fMainMenuForm;
    Constructor Create(ParamMainMenu: TForm); reintroduce;
    // Read about "reintroduce" in the link below :
    // http://docwiki.embarcadero.com/RADStudio/XE8/fr/W1010_La_m%C3%A9thode_'%25s'_cache_la_m%C3%A9thode_virtuelle_du_type_de_base_'%25s'_(Delphi)
    Destructor Destroy; override;
    Function GetPageControl(): TWispPageControl;
    Function NewTab(ParamCaption: String): TcxTabSheet;
    Function NewEntityGrid(ParamEntityName: String): TcxTabSheet;
    Function NewEntityEditor(ParamEntityName: String;
      ParamEntityId: Integer = 0): TcxTabSheet;
    procedure OnTabClosedEx(Sender: TObject; ATabIndex: Integer;
      var ACanClose: Boolean);
    Function NewReportGrid(): TcxTabSheet;
    Function NewReportEditor(ParamReportId: string = '0'): TcxTabSheet;
    Function NewUserEditor(ParamUserId: string = '0'): TcxTabSheet;
    Function NewUserGrid(): TcxTabSheet;
    Function NewProfileGrid(): TcxTabSheet;
    Function NewProfileEditor(ParamProfileId: string = '0'): TcxTabSheet;
    procedure PcOnDrawTabEx(AControl: TcxCustomTabControl; aTab: TcxTab;
      Font: TFont);
  end;

var
  Global_Singleton_MainMenuManager: TMainMenuManager;
  M: TMainMenuManager; // Shorter version

implementation

// =============================================================================
Constructor TMainMenuManager.Create(ParamMainMenu: TForm);
Var
  Screen: TScreen;
  X1, X2, Y1, Y2, W, H, I: Integer;
  TmpPanel: TPanel;
  ImgTest: TBitmap;
  TmpTab: TcxTabSheet;
  TmpEntity: TEntity;
  TmpItem: TWispMenuItem;
begin

  if Global_Singleton_MainMenuManager <> nil then
  begin
    // Lets try ...
    Self := Global_Singleton_MainMenuManager;
  end
  else
  begin
    inherited Create;
    Global_Singleton_MainMenuManager := Self;
    M := Self;
  end;

  KeyboardHook := TKeyboardHook.Create;
  KeyboardHook.OnPreExecute := KeyboardHookPREExecute;
  KeyboardHook.Active := True;

  MainMenuForm := ParamMainMenu;
  Screen := TScreen.Create(ParamMainMenu);
  try
    // ==============================
    With ParamMainMenu do
    begin
      W := Screen.Width;
      H := Screen.Height;
      Width := W;
      Height := H;
      DistanceCalculator := TDistanceCalculator.Create(H, W);
      BorderStyle := bsNone;
      Color := clGray;
      OnMouseWheelDown := Self.FormMouseWheelDown;
      OnMouseWheelUp := Self.FormMouseWheelUp;
    end;

    // =============================
    Global_Singleton_Style.Initialize;

    // =============================
    DrawBgImage(PanelTop);

    PopupMenuConfig := TPopupMenu.Create(ParamMainMenu);

    PopupItemUserConfig := TMenuItem.Create(PopupMenuConfig);
    PopupItemUserConfig.Caption := 'User Manager';
    PopupItemUserConfig.OnClick := ListsMenuItemUser_OnClick;

    PopupItemProfileConfig := TMenuItem.Create(PopupMenuConfig);
    PopupItemProfileConfig.Caption := 'Profile Manager';
    PopupItemProfileConfig.OnClick := ListsMenuItemProfile_OnClick;

    PopupItemListsReports := TMenuItem.Create(PopupMenuConfig);
    PopupItemListsReports.Caption := 'Report Manager';
    PopupItemListsReports.OnClick := ListsMenuItemReport_OnClick;

    PopupItemListsConfig := TMenuItem.Create(PopupMenuConfig);
    PopupItemListsConfig.Caption := 'Predefined lists';

    PopupMenuConfig.Items.Add(PopupItemUserConfig);
    PopupMenuConfig.Items.Add(PopupItemProfileConfig);
    PopupMenuConfig.Items.Add(PopupItemListsConfig);
    PopupMenuConfig.Items.Add(PopupItemListsReports);

    for I := 0 to Global_Singleton_EntityManager.EntityCount - 1 do
    begin
      TmpEntity := Global_Singleton_EntityManager.GetEntityById(I);
      if TmpEntity.PredefinedList then
      begin
        TmpItem := TWispMenuItem.Create(PopupItemListsConfig);
        SetLength(aPopupItemLists, Length(aPopupItemLists) + 1);
        aPopupItemLists[Length(aPopupItemLists) - 1] := TmpItem;
        TmpItem.Caption := TmpEntity.DisplayName;
        TmpItem.CommandString := TmpEntity.GetEntityName;
        TmpItem.OnClick := ListsMenuItem_OnClick;
        PopupItemListsConfig.Add(TmpItem);
      end;
    end;

    // ...
    PcBtnImageList := TCxImageList.Create(ParamMainMenu);
    PcBtnImageList.Width := 16;
    PcBtnImageList.Height := 16;

    PcBtnImageList.Add(Global_Singleton_Style.GetBitmapByName('Close16'), nil);

    PcBtnImageList.Add(Global_Singleton_Style.GetBitmapByName('Mini16'), nil);

    PcBtnImageList.Add(Global_Singleton_Style.GetBitmapByName('Cog16'), nil);

    PageControlMain := TWispPageControl.Create(ParamMainMenu);
    with PageControlMain do
    begin
      Parent := ParamMainMenu;
      Align := alClient;
      ParentBackground := FALSE;
      ParentColor := FALSE;
      Properties.CloseButtonMode := cbmEveryTab;
      OnCanCloseEx := OnTabClosedEx;
      OnDrawTabEx := PcOnDrawTabEx;
      LookAndFeel.NativeStyle := True;
      Properties.CustomButtons.HeaderImages := PcBtnImageList;

      PcBtnConfig := Properties.CustomButtons.Buttons.Add;
      PcBtnConfig.HeaderImageIndex := 2;
      PcBtnConfig.OnClick := CxButtonOnClick_Config;

      PcBtnMinimize := Properties.CustomButtons.Buttons.Add;
      PcBtnMinimize.HeaderImageIndex := 1;
      PcBtnMinimize.OnClick := CxButtonOnClick_Minimize;

      PcBtnExit := Properties.CustomButtons.Buttons.Add;
      PcBtnExit.HeaderImageIndex := 0;
      PcBtnExit.OnClick := CxButtonOnClick_Close;
    end;

    // ============================= Open console automaticly for debug pupose
    // TmpTab := NewTab('Console');
    // PageControlMain.RegisterTab('CONSOLE', 'Console', '0', TmpTab,
    // TWispConsole.Create(TmpTab, TmpTab));

    // ...
    if (T.DrmEnabled = FALSE) or (A.DRM.State) then
      OpenLoginTab
    else
      OpenDrmTab;

    // =============================
    ParamMainMenu.Top := 0;
    ParamMainMenu.Left := 0;
    ParamMainMenu.OnShow := MainForm_OnShow;
  finally
    // MainMenu.Free;
  end;

end;

// =============================================================================
Destructor TMainMenuManager.Destroy;
begin
  if Global_Singleton_MainMenuManager = Self then
  begin
    Global_Singleton_MainMenuManager := nil;
  end;
  inherited Destroy;
end;

// =============================================================================
Procedure FreeGlobalObjects; far;
begin
  if Global_Singleton_MainMenuManager <> nil then
  begin
    Global_Singleton_MainMenuManager.Free;
  end;
end;

// =============================================================================
Function TMainMenuManager.GetPageControl(): TWispPageControl;
begin
  result := TWispPageControl(PageControlMain);
end;

// =============================================================================
Function TMainMenuManager.NewTab(ParamCaption: String): TcxTabSheet;
begin
  result := TcxTabSheet.Create(Global_Singleton_MainMenuManager.MainMenuForm);
  result.PageControl := GetPageControl;
  result.Caption := ParamCaption;
end;

// =============================================================================
Function TMainMenuManager.NewEntityGrid(ParamEntityName: String): TcxTabSheet;
Var
  TmpTab: TcxTabSheet;
begin
  TmpTab := NewTab(Global_Singleton_EntityManager.GetEntityByName
    (ParamEntityName).DisplayName);
  PageControlMain.RegisterTab('GRID', ParamEntityName, '0', TmpTab,
    TEntityGrid.Create(TmpTab, TmpTab, ParamEntityName));
  PageControlMain.ActivePage := TmpTab;
end;

// =============================================================================
Function TMainMenuManager.NewReportGrid(): TcxTabSheet;
Var
  TmpTab: TcxTabSheet;
begin
  TmpTab := NewTab('Gestion des rapport');
  PageControlMain.RegisterTab('REPORT', 'REPORT', '0', TmpTab,
    TReportGrid.Create(TmpTab, TmpTab));
  PageControlMain.ActivePage := TmpTab;

end;

// =============================================================================
Function TMainMenuManager.NewReportEditor(ParamReportId: string = '0')
  : TcxTabSheet;
Var
  TmpTab, ResultTab: TcxTabSheet;
begin
  ResultTab := PageControlMain.CheckIfTabExists('REPORT_EDIT', 'REPORT',
    ParamReportId);

  if ResultTab = nil then
  begin
    TmpTab := NewTab('Edition rapport');
    PageControlMain.RegisterTab('REPORT_EDIT', 'REPORT', ParamReportId, TmpTab,
      TReportEditor.Create(TmpTab, TmpTab, ParamReportId));
    PageControlMain.ActivePage := TmpTab;
  end
  else
  begin
    PageControlMain.ActivePage := ResultTab;
  end;

end;

// =============================================================================
Function TMainMenuManager.NewUserGrid(): TcxTabSheet;
Var
  TmpTab, ResultTab: TcxTabSheet;
begin

  ResultTab := PageControlMain.CheckIfTabExists('USER', 'USER', '0');

  if ResultTab = nil then
  begin
    TmpTab := NewTab('Gestion des utilisateurs');
    PageControlMain.RegisterTab('USER', 'USER', '0', TmpTab,
      TUserGrid.Create(TmpTab, TmpTab));
    PageControlMain.ActivePage := TmpTab;
  end
  else
  begin
    PageControlMain.ActivePage := ResultTab;
  end;
end;

// =============================================================================
Function TMainMenuManager.NewProfileGrid(): TcxTabSheet;
Var
  TmpTab, ResultTab: TcxTabSheet;
begin

  ResultTab := PageControlMain.CheckIfTabExists('PROFILE', 'PROFILE', '0');

  if ResultTab = nil then
  begin
    TmpTab := NewTab('Gestion des profiles d''utilisateurs');
    PageControlMain.RegisterTab('PROFILE', 'PROFILE', '0', TmpTab,
      TWispProfileGrid.Create(TmpTab, TmpTab));
    PageControlMain.ActivePage := TmpTab;
  end
  else
  begin
    PageControlMain.ActivePage := ResultTab;
  end;
end;

// =============================================================================
Function TMainMenuManager.NewUserEditor(ParamUserId: string = '0'): TcxTabSheet;
Var
  TmpTab, ResultTab: TcxTabSheet;
begin
  ResultTab := PageControlMain.CheckIfTabExists('USER_EDIT', 'USER',
    ParamUserId);

  if ResultTab = nil then
  begin
    TmpTab := NewTab('Utilisateur');
    PageControlMain.RegisterTab('USER_EDIT', 'USER', ParamUserId, TmpTab,
      TUserEditor.Create(TmpTab, TmpTab, ParamUserId));
    PageControlMain.ActivePage := TmpTab;
  end
  else
  begin
    PageControlMain.ActivePage := ResultTab;
  end;

end;

// =============================================================================
Function TMainMenuManager.NewProfileEditor(ParamProfileId: string = '0')
  : TcxTabSheet;
Var
  TmpTab, ResultTab: TcxTabSheet;
begin
  ResultTab := PageControlMain.CheckIfTabExists('PROFILE_EDIT', 'PROFILE',
    ParamProfileId);

  if ResultTab = nil then
  begin
    TmpTab := NewTab('Profile');
    PageControlMain.RegisterTab('PROFILE_EDIT', 'PROFILE', ParamProfileId,
      TmpTab, TWispProfileEditor.Create(TmpTab, TmpTab, ParamProfileId));
    PageControlMain.ActivePage := TmpTab;
  end
  else
  begin
    PageControlMain.ActivePage := ResultTab;
  end;

end;

// =============================================================================
Function TMainMenuManager.NewEntityEditor(ParamEntityName: String;
  ParamEntityId: Integer = 0): TcxTabSheet;
Var
  TmpTab, ResultTab: TcxTabSheet;
begin

  if ParamEntityId = 0 then
  begin
    TmpTab := NewTab('Ajouter : ' + Global_Singleton_EntityManager.
      GetEntityByName(ParamEntityName).DisplayName);
    TEntityEditor.Create(TmpTab, TmpTab, ParamEntityName);
    PageControlMain.ActivePage := TmpTab;
  end
  else
  begin
    ResultTab := PageControlMain.CheckIfTabExists('EDIT', ParamEntityName,
      IntToStr(ParamEntityId));

    if ResultTab = nil then
    begin
      TmpTab := NewTab('Edition : ' + Global_Singleton_EntityManager.
        GetEntityByName(ParamEntityName).DisplayName);
      PageControlMain.ActivePage := TmpTab;
      PageControlMain.RegisterTab('EDIT', ParamEntityName,
        IntToStr(ParamEntityId), TmpTab, TEntityEditor.Create(TmpTab, TmpTab,
        ParamEntityName, ParamEntityId));
    end
    else
    begin
      PageControlMain.ActivePage := ResultTab;
    end;

  end;

end;

// =============================================================================
procedure TMainMenuManager.OnTabClosedEx(Sender: TObject; ATabIndex: Integer;
  var ACanClose: Boolean);
Var
  I, Btn: Integer;
  TmpTabInfo: TWispTabInfo;
  TmpReportEditor: TReportEditor;
  S, S1, S2, S3: String;
begin
  I := ATabIndex;

  TmpTabInfo := PageControlMain.GetTabInfo(PageControlMain.Pages[I]);
  S1 := TmpTabInfo.TabType;
  S2 := TmpTabInfo.TabName;
  S3 := TmpTabInfo.TabId;

  if S1 = 'REPORT_EDIT' then
  begin
    S := Global_Singleton_ConstantManager.GetLanguageConst('ReportAskSave');
    Btn := messagedlg(S, mtCustom, [mbYes, mbNo, mbCancel], 0);
    if Btn = 6 then
    begin
      // Save modifications and close report editor
      TmpReportEditor :=
        TReportEditor(PageControlMain.GetParentObject(S1, S2, S3));
      TmpReportEditor.Save;
      TmpReportEditor.CloseDesigner;
      PageControlMain.UnRegisterTab(PageControlMain.Pages[I]);
    end
    else if Btn = 7 then
    begin
      // Discard modifications and close report editor
      TmpReportEditor :=
        TReportEditor(PageControlMain.GetParentObject(S1, S2, S3));
      TmpReportEditor.CloseDesigner;
      PageControlMain.UnRegisterTab(PageControlMain.Pages[I]);
    end
    else if Btn = 2 then
    begin
      // Keep the report editor opened (cancel closing)
      ACanClose := FALSE;
    end;
  end
  else
  begin
    PageControlMain.UnRegisterTab(PageControlMain.Pages[I]);
  end;

end;

// =============================================================================
procedure TMainMenuManager.BtnExit_OnClick(Sender: TObject);
begin
  Application.Terminate;
end;

// =============================================================================
procedure TMainMenuManager.BtnMinimize_OnClick(Sender: TObject);
begin
  Application.Minimize;
end;

// =============================================================================
procedure TMainMenuManager.BtnConfig_OnClick(Sender: TObject);
begin
  PopupMenuConfig.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

// =============================================================================
procedure TMainMenuManager.BtnOk_OnClick(Sender: TObject);
begin
  if Global_Singleton_AccesManager.Login(EdtUser.EdtBox.Text, EdtPass.EdtBox.Text) then
  begin
    OpenHomeTab;
    PostMessage(Global_Singleton_MainMenuManager.PageControlMain.Handle,
      WM_KILLTAB, 0, TabSheetLogin.PageIndex);
  end
  else
  begin
    ShowMessage(T.GetLanguageConst('LoginError'));
    EdtUser.EdtBox.SetFocus;
  end;
end;

// =============================================================================
procedure TMainMenuManager.BtnCancel_OnClick(Sender: TObject);
begin
  Application.Terminate;
end;

// =============================================================================
procedure TMainMenuManager.BtnDrmOk_OnClick(Sender: TObject);
var
  TmpList: TStringlist;
begin
  if A.DRM.CheckKey(EdtLicenseKey.EdtBox.Text) then
  begin
    TmpList := TStringlist.Create;
    try
      TmpList.Add(EdtLicenseKey.EdtBox.Text);
      TmpList.SaveToFile(ExtractFilePath(Application.ExeName) + 'Key');
    finally
      TmpList.Free
    end;
  end;

end;

// =============================================================================
procedure TMainMenuManager.MainForm_OnShow(Sender: TObject);
begin
  if EdtUser <> nil then
    EdtUser.EdtBox.SetFocus;
end;

// =============================================================================
procedure TMainMenuManager.ListsMenuItem_OnClick(Sender: TObject);
Var
  TmpTab: TcxTabSheet;
begin
  TmpTab := Global_Singleton_MainMenuManager.PageControlMain.CheckIfTabExists
    ('GRID', (Sender As TComponent).Name, '0');

  if TmpTab = nil then
  begin
    Global_Singleton_MainMenuManager.NewEntityGrid(TWispMenuItem(Sender)
      .CommandString);
  end
  else
  begin
    Global_Singleton_MainMenuManager.PageControlMain.ActivePage := TmpTab;
  end;
end;

// =============================================================================
procedure TMainMenuManager.ListsMenuItemReport_OnClick(Sender: TObject);
Var
  TmpTab: TcxTabSheet;
begin
  if PageControlMain.CheckIfTabExists('REPORT', 'REPORT', '0') = nil then
  begin
    TmpTab := NewTab('Gestion des rapport');
    PageControlMain.RegisterTab('REPORT', 'REPORT', '0', TmpTab,
      TReportGrid.Create(TmpTab, TmpTab));
    PageControlMain.ActivePage := TmpTab;
  end;
end;

// =============================================================================
procedure TMainMenuManager.ListsMenuItemUser_OnClick(Sender: TObject);
begin
  NewUserGrid;
end;

// =============================================================================
procedure TMainMenuManager.ListsMenuItemProfile_OnClick(Sender: TObject);
begin
  NewProfileGrid;
end;

// =============================================================================
// handles KeyboardHook's OnPREExecute
Procedure TMainMenuManager.KeyboardHookPREExecute(Hook: THook;
  var Hookmsg: THookMsg);
var
  Key: Word;
  TmpTab, TmpTab2: TcxTabSheet;
  I: Integer;
begin
  // Here you can choose if you want to return
  // the key stroke to the application or not
  Hookmsg.result := 0;
  Key := Hookmsg.WPARAM;
  // For debug pupose
  // TabSheetMain.Caption := IntToStr(Hookmsg.Code) + '/' + IntToStr(Key) + '/' + IntToStr(Hookmsg.LParam);

  // Show console Tab
  if Key = 123 then
  begin
    TmpTab2 := Global_Singleton_MainMenuManager.PageControlMain.CheckIfTabExists
      ('CONSOLE', 'Console', '0');

    if TmpTab2 = nil then
    begin
      TmpTab := NewTab('Console');
      PageControlMain.RegisterTab('CONSOLE', 'Console', '0', TmpTab,
        TWispConsole.Create(TmpTab, TmpTab));
      PageControlMain.ActivePage := TmpTab;
    end
    else
    begin
      Global_Singleton_MainMenuManager.PageControlMain.ActivePage := TmpTab2;
    end;

  end;

  // Global_Singleton_Console.Echo('Key : '+IntToStr(Key));

  // Close current tab
  {
    if Key = 27 then
    begin
    I := PageControlMain.ActivePageIndex;
    if I > 0 then
    begin
    PageControlMain.UnRegisterTab(PageControlMain.Pages[I]);
    PostMessage(Global_Singleton_MainMenuManager.PageControlMain.Handle,
    WM_KILLTAB, 0, PageControlMain.Pages[I].PageIndex);
    end;
    end;
  }

end;

// =============================================================================
Procedure TMainMenuManager.OpenHomeTab;
Var
  X1, X2, Y1, Y2, W, H, I: Integer;
begin
  TabSheetHome := TcxTabSheet.Create(MainMenuForm);
  With TabSheetHome do
  begin
    PageControl := PageControlMain;
    Caption := 'Home';
    ParentColor := FALSE;
    Color := clGray;
    AllowCloseButton := FALSE;
  end;

  // =============================
  PanelMainMenu := TPanel.Create(TabSheetHome);
  With PanelMainMenu do
  begin
    Caption := '';
    Parent := TabSheetHome;
    ParentBackground := FALSE;
    Color := cl3DDkShadow;
    Align := alClient;
  end;

  // =============================
  DrawBgImage(PanelMainMenu);

  // =============================
  X1 := DistanceCalculator.WidthPercentToDist(40 - 1);
  Y1 := DistanceCalculator.HeigthPercentToDist(15 - 1);
  X2 := DistanceCalculator.WidthPercentToDist(20);
  Y2 := DistanceCalculator.HeigthPercentToDist(5);

  PanelUserInfo := TWispPanelUserInfo.Create(PanelMainMenu, X1, Y1, X2, Y2);

  PanelUserInfo.SetUserFullName
    (Global_Singleton_AccesManager.GetCurrentUserFullName);

  PanelUserInfo.SetLoginTimeInfo
    (Global_Singleton_ConstantManager.GetLanguageConst('ConnectedSince') +
    GetDateFromServer() + ' ' + Global_Singleton_ConstantManager.
    GetLanguageConst('At') + ' ' + GetTimeFromServer());
  // =============================
  X1 := DistanceCalculator.WidthPercentToDist(20);
  Y1 := DistanceCalculator.HeigthPercentToDist(65 - 1);
  X2 := DistanceCalculator.WidthPercentToDist(60);
  Y2 := DistanceCalculator.HeigthPercentToDist(5);

  PanelShortCuts := TWispPanelShortCuts.Create(PanelMainMenu, X1, Y1, X2, Y2);

  // =============================
  X1 := DistanceCalculator.WidthPercentToDist(40 - 1);
  Y1 := DistanceCalculator.HeigthPercentToDist(50 - 1);
  X2 := DistanceCalculator.WidthPercentToDist(20);
  Y2 := DistanceCalculator.HeigthPercentToDist(20);

  PanelSearch := TWispPanelSearch.Create(PanelMainMenu, X1, Y1, X2, Y2);

  // =============================
  X1 := DistanceCalculator.WidthPercentToDist(60);
  Y1 := DistanceCalculator.HeigthPercentToDist(20);
  X2 := DistanceCalculator.WidthPercentToDist(20);
  Y2 := DistanceCalculator.HeigthPercentToDist(70);

  if DrawAdPanel then
    PanelAds := TWispPanelAds.Create(PanelMainMenu, X1, Y1, X2, Y2);
  // =============================
  PageControlMain.ActivePage := TabSheetHome;
end;

// =============================================================================
Procedure TMainMenuManager.OpenLoginTab;
Var
  TmpDistanceCalculator: TDistanceCalculator;
  W, H, I: Integer;
begin
  TabSheetLogin := TcxTabSheet.Create(MainMenuForm);
  With TabSheetLogin do
  begin
    PageControl := PageControlMain;
    Caption := Global_Singleton_ConstantManager.GetLanguageConst('Login');
    ParentColor := FALSE;
    Color := clGray;
    AllowCloseButton := FALSE;
  end;

  // =============================
  PanelLogin := TPanel.Create(TabSheetLogin);
  With PanelLogin do
  begin
    Caption := '';
    Parent := TabSheetLogin;
    ParentBackground := FALSE;
    Color := Global_Singleton_Style.BgColor;
    Align := alClient;
  end;

  // =============================
  DrawBgImage(PanelLogin);

  // =============================
  TmpDistanceCalculator := TDistanceCalculator.Create(PanelLogin.ClientHeight,
    PanelLogin.ClientWidth);

  // ==============================
  H := TmpDistanceCalculator.HeigthPercentToDist(60);
  EdtUser := TWispEditBox.Create(PanelLogin, PanelLogin, 320, 1, 0, H,
    Global_Singleton_ConstantManager.GetLanguageConst('Username'), FALSE);
  EdtUser.CenterHorizontally;

  // ==============================
  H := TmpDistanceCalculator.HeigthPercentToDist(70);
  EdtPass := TWispEditBox.Create(PanelLogin, PanelLogin, 320, 1, 0, H,
    Global_Singleton_ConstantManager.GetLanguageConst('Password'), FALSE);
  EdtPass.EdtBox.Properties.EchoMode := eemPassword;
  EdtPass.CenterHorizontally;

  // ==============================
  H := TmpDistanceCalculator.HeigthPercentToDist(80);
  W := TmpDistanceCalculator.WidthPercentToDist(50);
  BtnOK := TWispButton.Create(PanelLogin);
  with BtnOK do
  begin
    Parent := PanelLogin;
    Width := 64;
    Height := 24;
    Caption := Global_Singleton_ConstantManager.GetLanguageConst('OK');
    Top := H;
    Left := W - BtnOK.Width - 16;
    Default := True;
    OnClick := BtnOk_OnClick;

  end;

  // ==============================
  BtnCancel := TWispButton.Create(PanelLogin);
  with BtnCancel do
  begin
    Parent := PanelLogin;
    Width := 64;
    Height := 24;
    Caption := Global_Singleton_ConstantManager.GetLanguageConst('Cancel');
    Top := H;
    Left := W + 16;
    OnClick := BtnCancel_OnClick;
  end;

end;

// =============================================================================
Procedure TMainMenuManager.OpenDrmTab;
Var
  TmpDistanceCalculator: TDistanceCalculator;
  W, H, I: Integer;
begin
  TabSheetDrm := TcxTabSheet.Create(MainMenuForm);
  With TabSheetDrm do
  begin
    PageControl := PageControlMain;
    Caption := Global_Singleton_ConstantManager.GetLanguageConst('License');
    ParentColor := FALSE;
    Color := clGray;
    AllowCloseButton := FALSE;
  end;

  // =============================
  PanelDrm := TPanel.Create(TabSheetDrm);
  With PanelDrm do
  begin
    Caption := '';
    Parent := TabSheetDrm;
    ParentBackground := FALSE;
    Color := Global_Singleton_Style.BgColor;
    Align := alClient;
  end;

  // =============================
  DrawBgImage(PanelDrm);

  // =============================
  TmpDistanceCalculator := TDistanceCalculator.Create(PanelDrm.ClientHeight,
    PanelDrm.ClientWidth);

  // ==============================
  H := TmpDistanceCalculator.HeigthPercentToDist(20);
  EdtDrmInfoCode := TWispEditBox.Create(PanelDrm, PanelDrm, 320, 5, 0, H,
    Global_Singleton_ConstantManager.GetLanguageConst('ActivationCode'), FALSE);
  EdtDrmInfoCode.CenterHorizontally;
  EdtDrmInfoCode.MemoBox.Text := A.DRM.EncryptedSerialNumber;

  // ==============================
  H := TmpDistanceCalculator.HeigthPercentToDist(60);
  EdtLicenseKey := TWispEditBox.Create(PanelDrm, PanelDrm, 320, 1, 0, H,
    Global_Singleton_ConstantManager.GetLanguageConst('LicenseKey'), FALSE);
  EdtLicenseKey.CenterHorizontally;

  // ==============================
  H := TmpDistanceCalculator.HeigthPercentToDist(80);
  W := TmpDistanceCalculator.WidthPercentToDist(50);
  BtnDrmOk := TWispButton.Create(PanelDrm);
  with BtnDrmOk do
  begin
    Parent := PanelDrm;
    Width := 64;
    Height := 24;
    Caption := Global_Singleton_ConstantManager.GetLanguageConst('OK');
    Top := H;
    Left := W - BtnDrmOk.Width - 16;
    Default := True;
    OnClick := BtnDrmOk_OnClick;

  end;

  // ==============================
  BtnDrmCancel := TWispButton.Create(PanelDrm);
  with BtnDrmCancel do
  begin
    Parent := PanelDrm;
    Width := 64;
    Height := 24;
    Caption := Global_Singleton_ConstantManager.GetLanguageConst('Cancel');
    Top := H;
    Left := W + 16;
    // OnClick := BtnCancel_OnClick;
  end;

end;

// =============================================================================
{ Procedure TMainMenuManager.OpenUserEditor(ParamUserId: String);
  Var
  TmpDistanceCalculator: TDistanceCalculator;
  W, H, I: Integer;
  begin
  TabSheetLogin := TcxTabSheet.Create(MainMenuForm);
  With TabSheetLogin do
  begin
  PageControl := PageControlMain;
  Caption := Global_Singleton_ConstantManager.GetLanguageConst('Login');
  ParentColor := FALSE;
  Color := clGray;
  AllowCloseButton := FALSE;
  end;

  // =============================
  PanelLogin := TPanel.Create(TabSheetLogin);
  With PanelLogin do
  begin
  Caption := '';
  Parent := TabSheetLogin;
  ParentBackground := FALSE;
  Color := cl3DDkShadow;
  Align := alClient;
  end;

  // =============================
  TmpDistanceCalculator := TDistanceCalculator.Create(PanelLogin.ClientHeight,
  PanelLogin.ClientWidth);

  // ==============================
  H := TmpDistanceCalculator.HeigthPercentToDist(60);
  EdtUser := TWispEditBox.Create(PanelLogin, PanelLogin, 320, 1, 0, H,
  Global_Singleton_ConstantManager.GetLanguageConst('Username'), FALSE);
  EdtUser.CenterHorizontally;

  // ==============================
  H := TmpDistanceCalculator.HeigthPercentToDist(70);
  EdtPass := TWispEditBox.Create(PanelLogin, PanelLogin, 320, 1, 0, H,
  Global_Singleton_ConstantManager.GetLanguageConst('Password'), FALSE);
  EdtPass.CenterHorizontally;

  // ==============================
  H := TmpDistanceCalculator.HeigthPercentToDist(80);
  W := TmpDistanceCalculator.WidthPercentToDist(50);
  BtnOK := TWispButton.Create(PanelLogin);
  with BtnOK do
  begin
  Parent := PanelLogin;
  Width := 64;
  Height := 24;
  Caption := Global_Singleton_ConstantManager.GetLanguageConst('OK');
  Top := H;
  Left := W - BtnOK.Width - 16;
  Default := True;
  OnClick := BtnOk_OnClick;
  end;

  // ==============================
  BtnCancel := TWispButton.Create(PanelLogin);
  with BtnCancel do
  begin
  Parent := PanelLogin;
  Width := 64;
  Height := 24;
  Caption := Global_Singleton_ConstantManager.GetLanguageConst('Cancel');
  Top := H;
  Left := W + 16;
  OnClick := BtnCancel_OnClick;
  end;

  // ===============================

  end; }

// =============================================================================
procedure TMainMenuManager.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if CurrentFocusedScrollBox <> nil then
    CurrentFocusedScrollBox.VertScrollBar.Position :=
      CurrentFocusedScrollBox.VertScrollBar.Position + 1;
end;

// =============================================================================
procedure TMainMenuManager.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if CurrentFocusedScrollBox <> nil then
    CurrentFocusedScrollBox.VertScrollBar.Position :=
      CurrentFocusedScrollBox.VertScrollBar.Position - 1;
end;

// =============================================================================
procedure TMainMenuManager.PcOnDrawTabEx(AControl: TcxCustomTabControl;
  aTab: TcxTab; Font: TFont);
begin
  aTab.Color := Global_Singleton_Style.BgColor;
  Font.Color := Global_Singleton_Style.TextColor;
  Font.Name := Global_Singleton_Style.DefaultFont;
end;

// =============================================================================
procedure TMainMenuManager.CxButtonOnClick_Close(Sender: TObject);
begin
  Application.Terminate;
end;

// =============================================================================
procedure TMainMenuManager.CxButtonOnClick_Minimize(Sender: TObject);
begin
  Application.Minimize;
end;

// =============================================================================
procedure TMainMenuManager.CxButtonOnClick_Config(Sender: TObject);
begin
  PopupMenuConfig.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

// =============================================================================
begin
  AddExitProc(FreeGlobalObjects);

end.
