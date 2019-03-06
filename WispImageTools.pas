unit WispImageTools;

interface

uses
  SysUtils,
  Graphics,
  cxImage,
  Controls,
  cxGraphics,
  WispStyleManager;

Function DrawBgImage(ParamParent: TWinControl): TcxImage;

implementation

// =============================================================================
Function DrawBgImage(ParamParent: TWinControl): TcxImage;
Var
  ImageBackGround : TcxImage;
begin
  ImageBackGround := TcxImage.Create(ParamParent);
  ImageBackGround.Picture := Global_Singleton_Style.PictureBackGround;
  ImageBackGround.Align := alClient;
  ImageBackGround.Parent := ParamParent;
  ImageBackGround.Transparent := True;
  ImageBackGround.Properties.FitMode := ifmFill;
end;

end.
