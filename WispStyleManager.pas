unit WispStyleManager;

interface

uses
  SysUtils,
  Graphics,
  Forms,
  CxStyles,
  WispStrTools,
  WispStyleConstants,
  WispColors;

type
  TStyleManager = Class(TObject)
  Private
    fAppPath: String;
    aBmpNames: TArrayOfString;
    aBitmap: Array of TBitmap;
  public
    UseCustomSkin : Boolean;
    BgColor: TColor;
    GridBgColor: TColor;
    TitleBgColor: TColor;
    PanelBgColor: TColor;
    BtnBgColor: TColor;
    TextColor: TColor;
    HighlightTextColor: TColor;
    QuietTextColor: TColor;
    DefaultFont: TFontName;
    CurrentStyle: TcxStyle;
    CurrentHighlightStyle: TcxStyle;
    CurrentQuietStyle: TcxStyle;
    PictureBackGround: TPicture;
    Property AppPath: String read fAppPath;
    Constructor Create; reintroduce;
    // Read about "reintroduce" in the link below :
    // http://docwiki.embarcadero.com/RADStudio/XE8/fr/W1010_La_m%C3%A9thode_'%25s'_cache_la_m%C3%A9thode_virtuelle_du_type_de_base_'%25s'_(Delphi)
    Destructor Destroy; override;
    Procedure RegisterBitmap(ParamName, ParamPath: String);
    Function GetBitmapByName(ParamName: String): TBitmap;
    Procedure Initialize;
    Procedure ChangeDefaultBg(ParamPath : String);
  End;

Const

  MetroGrayBgColor = clBlack;
  MetroGrayFontName = 'Segoe UI';
  MetroGrayFontSize = 10;
  MetroGrayFontColor = clBlack;

  BtnImgHome = 'Skin\Icons\Home.bmp';
  BtnImgClose = 'Skin\Icons\Close.bmp';
  BtnImgMinimize = 'Skin\Icons\Minimize.bmp';
  BtnImgConfig = 'Skin\Icons\Cog.bmp';
  BtnImgLeft = 'Skin\Icons\Left Arrow.bmp';
  BtnImgRight = 'Skin\Icons\Right Arrow.bmp';

  BtnImgClose16 = 'Skin\Icons\new_close_16.bmp';
  BtnImgMinimize16 = 'Skin\Icons\new_minimize_16.bmp';
  BtnImgConfig16 = 'Skin\Icons\new_config_16.bmp';

  BgImgMainMenu = 'Skin\BG\Workshop-Dark.jpg';
  BgImgLogin = 'Skin\BG\Wisp BG.jpg';
  BgImgAd = 'Skin\BG\Ad.png';

  ShortcutPanelStyle = 2;
  DrawAdPanel = FALSE;

var

  Global_Singleton_Style: TStyleManager;
  S: TStyleManager; // Shorter version

implementation

uses
  WispMainMenuManager;

// =============================================================================
Constructor TStyleManager.Create;
begin
  if Global_Singleton_Style <> nil then
  begin
    // Lets try ...
    Self := Global_Singleton_Style;
  end
  else
  begin
    inherited Create;
    Global_Singleton_Style := Self;
    S := Self;

    // App path
    fAppPath := ExtractFilePath(Application.ExeName);

    // Register bitmaps
    RegisterBitmap('Home', BtnImgHome);
    RegisterBitmap('Config', BtnImgConfig);
    RegisterBitmap('Right', BtnImgRight);
    RegisterBitmap('Left', BtnImgLeft);
    RegisterBitmap('Close', BtnImgClose);
    RegisterBitmap('Minimize', BtnImgMinimize);

    RegisterBitmap('Cog16', BtnImgConfig16);
    RegisterBitmap('Close16', BtnImgClose16);
    RegisterBitmap('Mini16', BtnImgMinimize16);
  end;
end;

// =============================================================================
Destructor TStyleManager.Destroy;
begin
  if Global_Singleton_Style = Self then
    Global_Singleton_Style := nil;
  inherited Destroy;
end;

// =============================================================================
Procedure FreeGlobalObjects; far;
begin
  if Global_Singleton_Style <> nil then
    Global_Singleton_Style.Free;
end;

// =============================================================================
Procedure TStyleManager.RegisterBitmap(ParamName, ParamPath: String);
Var
  TmpBmp: TBitmap;
begin
  SetLength(aBmpNames, Length(aBmpNames) + 1);
  aBmpNames[Length(aBmpNames) - 1] := ParamName;

  TmpBmp := TBitmap.Create;
  TmpBmp.LoadFromFile(AppPath + ParamPath);
  // TmpBmp.TransparentMode := tmFixed;
  // TmpBmp.TransparentColor := clRed;
  // TmpBmp.Transparent := FALSE;

  SetLength(aBitmap, Length(aBitmap) + 1);
  aBitmap[Length(aBitmap) - 1] := TmpBmp;
end;

// =============================================================================
Function TStyleManager.GetBitmapByName(ParamName: String): TBitmap;
var
  I: Integer;
begin
  for I := 0 to Length(aBmpNames) do
  begin
    if ParamName = aBmpNames[I] then
    begin
      Result := aBitmap[I];
      EXIT;
    end;
  end;

  Result := nil;
end;

// =============================================================================
Procedure TStyleManager.Initialize;
begin
  // Background picture
  if Not(UseCustomSkin) then
  begin
  PictureBackGround := TPicture.Create;
  PictureBackGround.LoadFromFile(ExtractFilePath(Application.ExeName) + BgImgLogin);
  end;

  // Basic Style
  CurrentStyle := TcxStyle.Create
    (Global_Singleton_MainMenuManager.MainMenuForm);

  // Highlight style
  CurrentHighlightStyle := TcxStyle.Create
    (Global_Singleton_MainMenuManager.MainMenuForm);

  // Quiet style
  CurrentQuietStyle := TcxStyle.Create
    (Global_Singleton_MainMenuManager.MainMenuForm);

  if Not(UseCustomSkin) then
  begin
  // Colors
  BgColor := clBlack;
  GridBgColor := RgbToColor(0, 45, 45);
  TextColor := clWhite;
  HighlightTextColor := clAqua;
  QuietTextColor := clTeal;
  BtnBgColor := RgbToColor(0, 45, 45);

  // Fonts
  DefaultFont := 'Segoe UI';
  end;

  // B
  CurrentStyle.TextColor := TextColor;
  CurrentStyle.Color := GridBgColor;
  CurrentStyle.Font.Name := DefaultFont;
  CurrentStyle.Font.Size := 12;

  // H
  CurrentHighlightStyle.TextColor := HighlightTextColor;
  CurrentHighlightStyle.Color := QuietTextColor;
  CurrentHighlightStyle.Font.Name := DefaultFont;
  CurrentHighlightStyle.Font.Size := 12;

  // Q
  CurrentQuietStyle.TextColor := QuietTextColor;
  CurrentQuietStyle.Color := GridBgColor;
  CurrentQuietStyle.Font.Name := DefaultFont;
  CurrentQuietStyle.Font.Size := 12;
end;

// =============================================================================
Procedure TStyleManager.ChangeDefaultBg(ParamPath : String);
begin
  PictureBackGround.Free;
  PictureBackGround := TPicture.Create;
  PictureBackGround.LoadFromFile(ExtractFilePath(Application.ExeName) + ParamPath);
end;

// =============================================================================
begin
  AddExitProc(FreeGlobalObjects);

end.
