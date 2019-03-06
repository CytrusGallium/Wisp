unit WispPanelAds;

interface

uses
  ExtCtrls,
  CxLabel,
  Controls,
  Graphics,
  Classes,
  Forms,
  SysUtils,
  CxButtons,
  CxImage,
  CxGraphics,
  WispEntity,
  WispEntityManager,
  WispPageControl,
  WispConsole,
  WispButton,
  WispStyleManager,
  WispStyleConstants,
  cxPC;

type
  TWispPanelAds = Class(TObject)
  Private
    PictureBackGround: TPicture;
    ImageBackGround: TcxImage;
  Public
    PanelMain: TPanel;
    Constructor Create(ParamParent: TWinControl;
      ParamWidth, ParamHeigth, ParamLeft, ParamTop: integer);
  End;

implementation

uses
  WispMainMenuManager;

// =============================================================================
Constructor TWispPanelAds.Create(ParamParent: TWinControl;
  ParamWidth, ParamHeigth, ParamLeft, ParamTop: integer);
begin

  // =====================================
  PanelMain := TPanel.Create(ParamParent);
  With PanelMain do
  begin
    Caption := '';
    Parent := ParamParent;
    ParentBackground := FALSE;
    Color := cl3DDkShadow;
    Height := ParamHeigth;
    Width := ParamWidth;
    Left := ParamLeft;
    Top := ParamTop;
  end;

  // =============================
  PictureBackGround := TPicture.Create;
  PictureBackGround.LoadFromFile(ExtractFilePath(Application.ExeName) +
    BgImgAd);
  ImageBackGround := TcxImage.Create(PanelMain);
  ImageBackGround.Picture := PictureBackGround;
  ImageBackGround.Align := alClient;
  ImageBackGround.Parent := PanelMain;
  ImageBackGround.Transparent := TRUE;
  ImageBackGround.Properties.FitMode := ifmFit;

end;

end.
