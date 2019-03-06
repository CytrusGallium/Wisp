unit WispPanelShortCuts;

interface

uses
  ExtCtrls,
  CxLabel,
  Controls,
  Graphics,
  Classes,
  SysUtils,
  Forms,
  CxButtons,
  WispEntity,
  WispEntityManager,
  WispPageControl,
  WispConsole,
  WispButton,
  WispStyleManager,
  WispStyleConstants,
  cxPC,
  WispAccesManager,
  WispImageTools;

type
  TWispPanelShortCuts = Class(TObject)
  Private
    procedure Btn_OnClick(Sender: TObject);
  Public
    PanelMain: TPanel;
    Constructor Create(ParamParent: TWinControl;
      ParamWidth, ParamHeigth, ParamLeft, ParamTop: integer);
  End;

implementation

uses
  WispMainMenuManager;

// =============================================================================
procedure TWispPanelShortCuts.Btn_OnClick(Sender: TObject);
Var
  TmpTab: TcxTabSheet;
begin

  TmpTab := Global_Singleton_MainMenuManager.PageControlMain.CheckIfTabExists
    ('GRID', (Sender As TComponent).Name, '0');

  if TmpTab = nil then
  begin
    Global_Singleton_MainMenuManager.NewEntityGrid
      (TWispButton(Sender).CommandString);
  end
  else
  begin
    Global_Singleton_MainMenuManager.PageControlMain.ActivePage := TmpTab;
  end;
end;

// =============================================================================
Constructor TWispPanelShortCuts.Create(ParamParent: TWinControl;
  ParamWidth, ParamHeigth, ParamLeft, ParamTop: integer);
Var
  MaxButtonsPerRow: integer;
  MaxButtonsRows: integer;
  MaxButtons: integer;
  I: integer;
  J: integer;
  C: integer;
  TmpS: String;
  BtnTmp: TWispButton;
  E: TEntity;
  Lbl : TcxLabel;
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

  // ======================================
  DrawBgImage(PanelMain);

  // Style 1
  if ShortcutPanelStyle = 1 then
  begin
    // Calculate max botton columns and rows
    MaxButtonsPerRow := (ParamWidth - 16) div 32;
    Global_Singleton_Console.Echo('Maximum shortcut buttons in a row : ' +
      IntToStr(MaxButtonsPerRow));
    MaxButtonsRows := (ParamHeigth - 16) div 32;
    Global_Singleton_Console.Echo('Maximum shortcut buttons rows : ' +
      IntToStr(MaxButtonsRows));
    MaxButtons := Global_Singleton_EntityManager.GetEntityCount;
    C := 0;

    //
    for I := 0 to MaxButtonsPerRow - 1 do
    begin
      for J := 0 to MaxButtonsRows - 1 do
      begin
        C := C + 1;
        E := Global_Singleton_EntityManager.GetEntityById(C - 1);
        if (C <= MaxButtons) And (E.DisplayShortcut) then
        begin
          BtnTmp := TWispButton.Create(PanelMain);
          with BtnTmp do
          begin
            Parent := PanelMain;
            Width := 32;
            Height := 32;
            TmpS := E.GetEntityName;
            Caption := UpperCase(TmpS[1]);
            Top := 4 + J * 32;
            Left := 4 + I * 32;
            OnClick := Btn_OnClick;
            CommandString := TmpS;
            Glyph := Global_Singleton_Style.GetBitmapByName(E.GlyphName);
            Global_Singleton_Console.Echo('Creating Shortcut Button : ' + TmpS +
              ' (Done)');
          end;
        end;
      end;
    end;
  end;

  // Style 2
  if ShortcutPanelStyle = 2 then
  begin
    MaxButtons := Global_Singleton_EntityManager.GetEntityCount;
    for I := 0 to MaxButtons - 1 do
    begin
      E := Global_Singleton_EntityManager.GetEntityById(I);
      if (E.DisplayShortcut) and (Global_Singleton_AccesManager.CurrentProfile.GetAcces('ENTITY_'+E.GetEntityName)) then
      begin
        BtnTmp := TWispButton.Create(PanelMain);
        with BtnTmp do
        begin
          Parent := PanelMain;
          Width := 48;
          Height := 48;
          TmpS := E.GetEntityName;

          if E.GlyphName = '' then
          begin
            Caption := UpperCase(TmpS[1]);
          end
          else
            Glyph := Global_Singleton_Style.GetBitmapByName(E.GlyphName);

          Top := 4 + I * 48;
          Left := 4;
          OnClick := Btn_OnClick;
          CommandString := TmpS;
          Global_Singleton_Console.Echo('Creating Shortcut Button : ' + TmpS +
            ' (Done)');

          LookAndFeel.NativeStyle := TRUE;

          // =====================================
          Lbl := TcxLabel.Create(PanelMain);
          with Lbl do
          begin
          Parent := PanelMain;
          Left := 56;
          Top := 4 + (I * 48) + 12;
          Caption := E.DisplayName;
          Height := 32;
          Width := 256;
          // ParentColor := FALSE;
          Style.Font.Color := Global_Singleton_Style.TextColor;
          Style.Font.Size := 10;
          Style.Font.Name := Global_Singleton_Style.DefaultFont;
          Transparent := TRUE;
          end;
        end;
      end;
    end;
  end;

end;

end.
