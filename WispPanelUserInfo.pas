unit WispPanelUserInfo;

interface

uses
  SysUtils,
  ExtCtrls,
  CxLabel,
  Controls,
  Graphics,
  Forms,
  WispImageTools,
  WispStyleManager,
  WispConstantManager;

type
  TWispPanelUserInfo = Class(TObject)
  Private
    LabelTitle: TcxLabel;
    LabelUserFullName: TcxLabel;
    LabelLoginTime: TcxLabel;
  Public
    PanelMain: TPanel;
    Constructor Create(ParamParent: TWinControl;
      ParamWidth, ParamHeigth, ParamLeft, ParamTop: integer);
    Procedure SetUserFullName(ParamCaption: string);
    Procedure SetLoginTimeInfo(ParamCaption: string);
  End;

implementation

Constructor TWispPanelUserInfo.Create(ParamParent: TWinControl;
  ParamWidth, ParamHeigth, ParamLeft, ParamTop: integer);
begin
  // =====================================
  PanelMain := TPanel.Create(ParamParent);
  With PanelMain do
  begin
    Caption := '';
    Parent := ParamParent;
    ParentBackground := FALSE;
    Color := Global_Singleton_Style.BgColor;
    Height := ParamHeigth;
    Width := ParamWidth;
    Left := ParamLeft;
    Top := ParamTop;
  end;

  // =============================
  DrawBgImage(PanelMain);

  // =====================================
  LabelTitle := TcxLabel.Create(PanelMain);
  with LabelTitle do
  begin
    Parent := PanelMain;
    Left := 8;
    Top := 8;
    Caption := Global_Singleton_ConstantManager.GetLanguageConst('CurrentUser');
    Height := 32;
    Width := 256;
    // ParentColor := FALSE;
    Style.Font.Color := Global_Singleton_Style.TextColor;
    Style.Font.Size := 10;
    Style.Font.Name := Global_Singleton_Style.DefaultFont;
    Transparent := TRUE;
  end;
  // =====================================
  LabelUserFullName := TcxLabel.Create(PanelMain);
  with LabelUserFullName do
  begin
    Parent := PanelMain;
    Left := 8;
    Top := 32;
    Caption := 'Full name not found !';
    Height := 32;
    Width := 256;
    // ParentColor := FALSE;
    Style.Font.Color := Global_Singleton_Style.QuietTextColor;
    Style.Font.Size := 16;
    Style.Font.Name := Global_Singleton_Style.DefaultFont;
    Transparent := TRUE;
  end;
  // =====================================
  LabelLoginTime := TcxLabel.Create(PanelMain);
  with LabelLoginTime do
  begin
    Parent := PanelMain;
    Left := 8;
    Top := 56;
    Caption := '...';
    Height := 16;
    Width := 256;
    // ParentColor := FALSE;
    Style.Font.Color := Global_Singleton_Style.TextColor;
    Style.Font.Size := 10;
    Style.Font.Name := Global_Singleton_Style.DefaultFont;
    Transparent := TRUE;
  end;
end;

// =============================================================================
Procedure TWispPanelUserInfo.SetUserFullName(ParamCaption: string);
begin
  LabelUserFullName.Caption := ParamCaption;
end;

// =============================================================================
Procedure TWispPanelUserInfo.SetLoginTimeInfo(ParamCaption: string);
begin
  LabelLoginTime.Caption := ParamCaption;
end;

end.
