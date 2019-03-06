unit WispColors;

interface

uses
  Graphics, Windows;

Function RgbToColor(ParamR, ParamG, ParamB: Byte): TColor;

implementation

Function RgbToColor(ParamR, ParamG, ParamB: Byte): TColor;
begin
  result := RGB(ParamR, ParamG, ParamB);
end;

end.
