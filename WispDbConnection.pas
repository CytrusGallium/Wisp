unit WispDbConnection;

interface

uses SysUtils,
  ZConnection,
  ZAbstractConnection,
  WispConstantManager;

type
  TDbConnection = Class(TZConnection)
  public
    Constructor Create; reintroduce;
    // Read about "reintroduce" in the link below :
    // http://docwiki.embarcadero.com/RADStudio/XE8/fr/W1010_La_m%C3%A9thode_'%25s'_cache_la_m%C3%A9thode_virtuelle_du_type_de_base_'%25s'_(Delphi)
    Destructor Destroy; override;
  End;

var

  Global_Singleton_DbConnection: TDbConnection;
  C : TDbConnection; // Shorter version

implementation

// Connect to an SQL 5 Database
Constructor TDbConnection.Create;
begin
  if Global_Singleton_DbConnection <> nil then
  begin
    // Lets try ...
    Self := Global_Singleton_DbConnection;
  end
  else
  begin
    inherited Create(nil);
    Global_Singleton_DbConnection := Self;
    C := Self;
    with Global_Singleton_DbConnection do
      HostName := Global_Singleton_ConstantManager.DbHostName;
      User := Global_Singleton_ConstantManager.DbUser;
      Password := Global_Singleton_ConstantManager.DbPass;
      Database := Global_Singleton_ConstantManager.DbName;
      Port := Global_Singleton_ConstantManager.DbPort;
      Protocol := 'mysql-5';
      LibraryLocation := 'libmySQL.dll';
      Connect;
  end;
end;

Destructor TDbConnection.Destroy;
begin
  if Global_Singleton_DbConnection = Self then
    Global_Singleton_DbConnection := nil;
  inherited Destroy;
end;

Procedure FreeGlobalObjects; far;
begin
  if Global_Singleton_DbConnection <> nil then
    Global_Singleton_DbConnection.Free;
end;

begin
  AddExitProc(FreeGlobalObjects);

end.
