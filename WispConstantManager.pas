unit WispConstantManager;

interface

uses SysUtils,
     IniFiles,
     Forms;

type
  TConstantManager = Class(TObject)
  Private
    fCurrentLanguage : String;
    LanguageIni : TIniFile;
    fAppPath : String;
  Public
    AppTitle : String;
    AppSubTitle : String;
    AppVersion : String;
    DbHostName : String;
    DbPort : Integer;
    DbUser : String;
    DbPass : String;
    DbName : String;
    DrmEnabled : Boolean;
    DrmKey : String;
    DrmInfoKey : String;
    Property CurrentLanguage : String Read fCurrentLanguage Write fCurrentLanguage;
    Constructor Create; reintroduce;
    // Read about "reintroduce" in the link below :
    // http://docwiki.embarcadero.com/RADStudio/XE8/fr/W1010_La_m%C3%A9thode_'%25s'_cache_la_m%C3%A9thode_virtuelle_du_type_de_base_'%25s'_(Delphi)
    Destructor Destroy; override;
    Function GetLanguageConst(ParamName : String) : String;
  End;

var

  Global_Singleton_ConstantManager: TConstantManager;
  T : TConstantManager; // Shorter version

implementation

// Connect to an SQL 5 Database
Constructor TConstantManager.Create;
begin
  if Global_Singleton_ConstantManager <> nil then
  begin
    // Lets try ...
    Self := Global_Singleton_ConstantManager;
  end
  else
  begin
    inherited Create;
    Global_Singleton_ConstantManager := Self;
    T := Self;
    // =========================================================================
    AppTitle := '';
    AppSubTitle := '';
    AppVersion := '';
    DbHostName := 'localhost';
    DbPort := 3306;
    DbUser := 'root';
    DbPass := '';
    DbName := '';
    // =========================================================================
    FCurrentLanguage := 'English';
    FAppPath := ExtractFilePath(Application.ExeName);
    LanguageIni := TIniFile.Create(fAppPath+'Language.ini');
  end;
end;

// =============================================================================
Function TConstantManager.GetLanguageConst(ParamName : String) : String;
begin
  Result := LanguageIni.ReadString(fCurrentLanguage, ParamName, '!TEXT NOT FOUND!')
end;

// =============================================================================
Destructor TConstantManager.Destroy;
begin
  if Global_Singleton_ConstantManager = Self then
    Global_Singleton_ConstantManager := nil;
  inherited Destroy;
end;

// =============================================================================
Procedure FreeGlobalObjects; far;
begin
  if Global_Singleton_ConstantManager <> nil then
    Global_Singleton_ConstantManager.Free;
end;

begin
  AddExitProc(FreeGlobalObjects);

end.
