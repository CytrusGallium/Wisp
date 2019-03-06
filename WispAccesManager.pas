unit WispAccesManager;

interface

uses
  WispDbConnection,
  WispQueryTools,
  WispDbStructureTools,
  SysUtils,
  Windows,
  Dialogs,
  Forms,
  ZDataset,
  WispUser,
  StdCtrls,
  ExtCtrls,
  Graphics,
  Controls,
  Classes,
  cxTextEdit,
  cxButtons,
  WispEditBox,
  WispLoginDialog,
  WispProfile,
  DECUtil,
  DECCipher,
  DECHash,
  DECFmt,
  WispConstantManager;

type
  TPBKDF2Result = record
    FinalHash: string;
    Salt: string;
  end;

  TWispDRM = Class(TObject)
  private
    ACipherClass: TDECCipherClass;
    ACipherMode: TCipherMode;
    AHashClass: TDECHashClass;
    ATextFormat: TDECFormatClass;
    AKDFIndex: LongWord;
    SerialNumber: String;
    FEncryptedSerialNumber: String;
    EncryptedSerialNumberForLicense: String;
    FinalDesiredHash: String;
    FDesiredResult: String;
    FState: Boolean; // Define if the user is allowed to use the software
  public
    Property EncryptedSerialNumber: String Read FEncryptedSerialNumber;
    Property State : Boolean Read FState;
//    Property DesiredResult: String Read FDesiredResult;
    Constructor Create;
    Function CheckKey(ParamKey: String): Boolean;
    Function GetMD5_Unicode(input: UnicodeString): String;
    Function GetMD5_Ansi(input: AnsiString): String;
    function Encrypt(const AText: String; const APassword: String): String;
    function Decrypt(const AText: String; const APassword: String): String;
  End;

  TAccesManager = Class(TObject)
  private
    DbConnection: TDbConnection;
    FDrm: TWispDRM;
  public
    CurrentUser: TWispUser;
    CurrentProfile: TWispProfile;
    Property DRM: TWispDRM Read FDrm;
    constructor Create();
    function CheckIfUserNameExists(ParamUserName: string): Boolean;
    procedure AddNewUser(ParamUserName, ParamUserPassword: string);
    function LocalPBKDF2Generator(ParamPassWord: string;
      Iteration_Count: integer): TPBKDF2Result;
    function LocalPBKDF2Calculator(ParamPassWord, ParamSalt: string;
      Iteration_Count: integer): String;
    function Login(ParamUserName, ParamPassWord: string): Boolean;
    procedure SaveUserByUserName(ParamUser: TWispUser);
    Function GetCurrentUserFullName(): string;
    Destructor Destroy; override;
  End;

Var
  Global_Singleton_AccesManager: TAccesManager;
  A: TAccesManager; // Shorter version

implementation

// =============================================================================
constructor TWispDRM.Create;
Var
  TmpSerialNum: DWord;
  A, B: DWord;
  C: array [0 .. 255] of Char;
  Buffer: array [0 .. 255] of Char;
  KeyPath: String;
  KeyFile: File;
  Key: String;
  TmpList: TStringList;
begin
  ACipherClass := TCipher_Rijndael;
  ACipherMode := cmCBCx;
  AHashClass := THash_Whirlpool;
  ATextFormat := TFormat_Mime64;
  AKDFIndex := 1;

  // ...
  FState := FALSE;

  // ...
  KeyPath := ExtractFilePath(Application.ExeName);
  KeyPath := KeyPath + 'Key';
  AssignFile(KeyFile, KeyPath);

  if FileExists(KeyPath) = FALSE then
  begin
    Rewrite(KeyFile);
  end
  else
  begin
    TmpList := TStringList.Create;
    TmpList.Loadfromfile(KeyPath);
    Key := TmpList.text;
    Key := Copy(Key, 0, 16);
    TmpList.Free;
  end;

  // Get The serial number, for now we use the volume serial number
  // shall add thing like the cpu id, motherboard id, a random string stored in the registry ... etc
  if GetVolumeInformation(PChar('C:\'), Buffer, 256, @TmpSerialNum, A, B, C, 256)
  then
  begin
    // Raw serial number
    SerialNumber := IntToStr(TmpSerialNum);
    // Encrypted serial number, not to be seen by the user
    // Shall be sent to the software producer
    FEncryptedSerialNumber := Encrypt(SerialNumber, T.DrmInfoKey);
    // Encrypted serial number, that shall be used for the resulting license key
    EncryptedSerialNumberForLicense := Encrypt(SerialNumber, T.DrmKey);
    // MD5 (first 16 characters are needed to activate the software)
    FinalDesiredHash := GetMD5_Unicode(EncryptedSerialNumberForLicense);
    // The license key
    FDesiredResult := Copy(FinalDesiredHash, 0, 16);
    // SerialNumber := Decrypt(EncryptedSerialNumber, T.DrmInfoKey);
  end;

  // Auto check from Key file
  CheckKey(Key);
end;

// =============================================================================
Function TWispDRM.CheckKey(ParamKey: String): Boolean;
begin
  if ParamKey = FDesiredResult then
  begin
    FState := TRUE;
    Result := TRUE;
  end
  else
  begin
    FState := FALSE;
    Result := FALSE;
  end;
end;

// =============================================================================
Function TWispDRM.GetMD5_Unicode(input: UnicodeString): String;
var
  val: tStringStream;
  hash: tHash_MD5;
  len: int64;
Begin
  val := tStringStream.Create;
  len := length(input) * 2;
  val.Write(input[1], len);
  val.Seek(0, soFromBeginning);
  hash := tHash_MD5.Create();
  Result := string(hash.CalcStream(val, len, TFormat_HEX));
  hash.Free;
  val.Free;
End;

// =============================================================================
Function TWispDRM.GetMD5_Ansi(input: AnsiString): String;
var
  val: tStringStream;
  hash: tHash_MD5;
  len: int64;
Begin
  val := tStringStream.Create;
  len := length(input);
  val.Write(input[1], len);
  val.Seek(0, soFromBeginning);
  hash := tHash_MD5.Create();
  Result := string(hash.CalcStream(val, len, TFormat_HEX));
  hash.Free;
  val.Free;
End;

// =============================================================================
function TWispDRM.Encrypt(const AText: String; const APassword: String): String;
var
  ASalt: Binary;
  AData: Binary;
  APass: Binary;
  TmpCipher: TDECCipherClass;
begin
  with ValidCipher(ACipherClass).Create do
    try
      ASalt := RandomBinary(16);
      APass := ValidHash(AHashClass).KDFx(APassword[1],
        length(APassword) * SizeOf(APassword[1]), ASalt[1], length(ASalt),
        Context.KeySize, TFormat_Copy, AKDFIndex);
      Mode := ACipherMode;
      Init(APass);
      SetLength(AData, length(AText) * SizeOf(AText[1]));
      Encode(AText[1], AData[1], length(AData));
      Result := ValidFormat(ATextFormat).Encode(ASalt + AData + CalcMAC);
    finally
      Free;
      ProtectBinary(ASalt);
      ProtectBinary(AData);
      ProtectBinary(APass);
    end;
end;

// =============================================================================
function TWispDRM.Decrypt(const AText: String; const APassword: String): String;
var
  ASalt: Binary;
  AData: Binary;
  ACheck: Binary;
  APass: Binary;
  ALen: integer;
begin
  with ValidCipher(ACipherClass).Create do
    try
      ASalt := ValidFormat(ATextFormat).Decode(AText);
      ALen := length(ASalt) - 16 - Context.BufferSize;
      AData := System.Copy(ASalt, 17, ALen);
      ACheck := System.Copy(ASalt, ALen + 17, Context.BufferSize);
      SetLength(ASalt, 16);
      APass := ValidHash(AHashClass).KDFx(APassword[1],
        length(APassword) * SizeOf(APassword[1]), ASalt[1], length(ASalt),
        Context.KeySize, TFormat_Copy, AKDFIndex);
      Mode := ACipherMode;
      Init(APass);
      SetLength(Result, ALen div SizeOf(AText[1]));
      Decode(AData[1], Result[1], ALen);
      if ACheck <> CalcMAC then
        raise Exception.Create('Invalid data');
    finally
      Free;
      ProtectBinary(ASalt);
      ProtectBinary(AData);
      ProtectBinary(ACheck);
      ProtectBinary(APass);
    end;
end;

// =============================================================================
constructor TAccesManager.Create;
Var
  DbName: String;
  ResultFound: Boolean;
  LoginDialog: TLoginDialog;
  LoginDialogResult: TLoginDialogResult;
  TmpUser: TWispUser;
  ColumnExist: Boolean;
begin
  // Creating Acces Manager Singleton
  if Global_Singleton_AccesManager <> nil then
  begin
    // I could be wrong doing this
    Self := Global_Singleton_AccesManager;
  end
  else
  begin
    // Create the acces manager
    inherited Create();
    Global_Singleton_AccesManager := Self;
    A := Self;

    // Create the DRM
    if T.DrmEnabled then
      FDrm := TWispDRM.Create;
  end;

  // Ensuring connexion to db is established
  DbConnection := TDbConnection.Create;
  DbName := DbConnection.Database;

  // Check if wisp_user table exists in the Database
  ResultFound := CheckIfTableExists(DbConnection, 'wisp_users');

  // If the wisp_users table does not exist, create it and create a default user
  if not(ResultFound) then
  begin
    ExecuteQuery(DbConnection, 'CREATE TABLE wisp_users' + sLineBreak + '(' +
      sLineBreak + ' WISP_ID int NOT NULL AUTO_INCREMENT,' + sLineBreak +
      ' WISP_USERNAME varchar(255),' + sLineBreak +
      ' WISP_PASSWORD varchar(255),' + sLineBreak + ' WISP_SALT varchar(16),' +
      sLineBreak + ' WISP_FIRST_NAME varchar(255),' + sLineBreak +
      ' WISP_FAMILY_NAME varchar (255),' + sLineBreak +
      ' WISP_PHONE_NUMBER varchar (255),' + sLineBreak +
      ' WISP_EMAIL varchar (255),' + sLineBreak + 'PRIMARY KEY (`WISP_ID`));');

    // Addtional user table checks
    ColumnExist := CheckIfColumnExists(Global_Singleton_DbConnection,
      'wisp_users', 'ID_PROFILE');

    if not(ColumnExist) then
      AddColumn(Global_Singleton_DbConnection, 'wisp_users', 'ID_PROFILE',
        'INT', 'NULL DEFAULT "0"');

    // Create the default user
    AddNewUser('Admin', 'pass');

    TmpUser := TWispUser.Create;
    TmpUser.UserName := 'Admin';
    TmpUser.FirstName := 'Administrator';
    TmpUser.FamilyName := '(Default)';

    SaveUserByUserName(TmpUser);

    TmpUser.LoadFromDbByUserName('Admin');
    TmpUser.UpdateProfileId('1');
  end;

  // Addtional user table checks
  ColumnExist := CheckIfColumnExists(Global_Singleton_DbConnection,
    'wisp_users', 'ID_PROFILE');

  if not(ColumnExist) then
    AddColumn(Global_Singleton_DbConnection, 'wisp_users', 'ID_PROFILE', 'INT',
      'NULL DEFAULT "0"');

  // Check if wisp_profiles table exists in the Database
  ResultFound := CheckIfTableExists(DbConnection, 'wisp_profiles');

  // If the wisp_profiles table does not exist, create it
  if not(ResultFound) then
  begin
    ExecuteQuery(DbConnection, 'CREATE TABLE wisp_profiles' + sLineBreak + '(' +
      sLineBreak + ' WISP_ID int NOT NULL AUTO_INCREMENT,' + sLineBreak +
      ' WISP_NAME varchar(255),' + sLineBreak + 'PRIMARY KEY (`WISP_ID`));');
  end;

  // Check if wisp_privileges table exists in the Database
  ResultFound := CheckIfTableExists(DbConnection, 'wisp_privileges');

  // If the wisp_privileges table does not exist, create it
  if not(ResultFound) then
  begin
    ExecuteQuery(DbConnection, 'CREATE TABLE wisp_privileges' + sLineBreak + '('
      + sLineBreak + ' WISP_ID int NOT NULL AUTO_INCREMENT,' + sLineBreak +
      ' NAME varchar(255),' + sLineBreak + ' LABEL varchar(255),' + sLineBreak +
      ' VALUE BOOLEAN,' + sLineBreak + ' PARENT_NAME varchar(255),' + sLineBreak
      + ' ID_PROFILE INT,' + sLineBreak + 'PRIMARY KEY (`WISP_ID`));');

    // Create default profile
    CurrentProfile := TWispProfile.Create('Default', TRUE, TRUE);
    CurrentProfile.NewToDb('Default');
    CurrentProfile.LoadFromDbById('1');
  end;

  // Make sure we have an instance of the current profile
  if CurrentProfile = nil then
    CurrentProfile := TWispProfile.Create('Empty', FALSE, TRUE);

  // Check if PBKDF2 stored procedure exists in the Database
  ResultFound := OpenQuery(DbConnection,
    'SELECT * FROM information_schema.routines WHERE routine_schema = "' +
    DbName + '" AND routine_type = "procedure" AND routine_name = "PBKDF2";')
    .RecordsAvailable;

  // Display an error message if the procedure has not been found and terminate the App
  if not(ResultFound) then
  begin
    // Later we shall add the stored proc automaticly
    // MessageDlg('Stored procedure not found !', mtError, mbOKCancel, 0);
    // Application.Terminate;
  end;

end;

// =============================================================================
function TAccesManager.CheckIfUserNameExists(ParamUserName: string): Boolean;
begin
  Result := OpenQuery(Self.DbConnection,
    'SELECT * FROM wisp_users WHERE WISP_USERNAME = "' + ParamUserName + '";')
    .RecordsAvailable;
end;

// =============================================================================
function TAccesManager.LocalPBKDF2Generator(ParamPassWord: string;
  Iteration_Count: integer): TPBKDF2Result;
Var
  TmpPassHash, TmpSalt, FinalHash: string;
begin
  TmpPassHash := OpenQuery(DbConnection, 'SELECT SHA2("' + ParamPassWord +
    '", 256);').FirstFieldAsString;
  TmpSalt := OpenQuery(DbConnection,
    'SELECT SUBSTRING(MD5(RAND()) FROM 1 FOR 16);').FirstFieldAsString;
  FinalHash := OpenQuery(DbConnection, 'SELECT SHA2("' + TmpPassHash + TmpSalt +
    '", 256);').FirstFieldAsString;

  Result.Salt := TmpSalt;
  Result.FinalHash := FinalHash;
end;

// =============================================================================
procedure TAccesManager.AddNewUser(ParamUserName, ParamUserPassword: string);
Var
  Q: TZQuery;
  FinalHash, Salt: String;
  PBKDF2Result: TPBKDF2Result;
begin
  if not(CheckIfUserNameExists(ParamUserName)) then
  begin
    PBKDF2Result := LocalPBKDF2Generator(ParamUserPassword, 0);
    FinalHash := PBKDF2Result.FinalHash;
    Salt := PBKDF2Result.Salt;
    ExecuteQuery(DbConnection,
      'INSERT INTO wisp_users (WISP_USERNAME, WISP_PASSWORD, WISP_SALT) VALUES ("'
      + ParamUserName + '","' + FinalHash + '","' + Salt + '");');
  end
  else
    ShowMessage('This user name already exists !'); // Need fix

end;

// =============================================================================
function TAccesManager.LocalPBKDF2Calculator(ParamPassWord, ParamSalt: string;
  Iteration_Count: integer): String;
Var
  TmpPassHash: string;
begin
  TmpPassHash := OpenQuery(DbConnection, 'SELECT SHA2("' + ParamPassWord +
    '", 256);').FirstFieldAsString;
  Result := OpenQuery(DbConnection, 'SELECT SHA2("' + TmpPassHash + ParamSalt +
    '", 256);').FirstFieldAsString;
end;

// =============================================================================
function TAccesManager.Login(ParamUserName, ParamPassWord: string): Boolean;
Var
  TmpSalt, FinalHash, TmpHashFromDb: string;
begin
  if CheckIfUserNameExists(ParamUserName) then
  begin
    TmpSalt := OpenQuery(DbConnection,
      'SELECT WISP_SALT FROM wisp_users WHERE WISP_USERNAME="' + ParamUserName +
      '";').FirstFieldAsString;
    FinalHash := LocalPBKDF2Calculator(ParamPassWord, TmpSalt, 0);
    TmpHashFromDb := OpenQuery(DbConnection,
      'SELECT WISP_PASSWORD FROM wisp_users WHERE WISP_USERNAME="' +
      ParamUserName + '";').FirstFieldAsString;
    if FinalHash = TmpHashFromDb then
    begin
      // ShowMessage('Welcome !');
      if Assigned(CurrentUser) then
      begin
        // CurrentUser.Create;
        CurrentUser.LoadFromDbByUserName(ParamUserName);
        CurrentProfile.LoadFromDbById(CurrentUser.ProfileId);
      end
      else
      begin
        CurrentUser := TWispUser.Create;
        CurrentUser.LoadFromDbByUserName(ParamUserName);
        CurrentProfile.LoadFromDbById(CurrentUser.ProfileId);
      end;
      Result := TRUE;
    end
    else
    begin
      // ShowMessage('Wrong Password !');
      Result := FALSE;
    end;
  end
  else
    Result := FALSE;
  // ShowMessage('User name does not exist !');
end;

// =============================================================================
procedure TAccesManager.SaveUserByUserName(ParamUser: TWispUser);
begin
  ExecuteQuery(Global_Singleton_DbConnection,
    'UPDATE wisp_users SET WISP_FIRST_NAME = "' + ParamUser.FirstName +
    '" WHERE WISP_USERNAME = "' + ParamUser.UserName + '";');
  ExecuteQuery(Global_Singleton_DbConnection,
    'UPDATE wisp_users SET WISP_FAMILY_NAME = "' + ParamUser.FamilyName +
    '" WHERE WISP_USERNAME = "' + ParamUser.UserName + '";');
  ExecuteQuery(Global_Singleton_DbConnection,
    'UPDATE wisp_users SET WISP_PHONE_NUMBER = "' + ParamUser.PhoneNumber +
    '" WHERE WISP_USERNAME = "' + ParamUser.UserName + '";');
  ExecuteQuery(Global_Singleton_DbConnection,
    'UPDATE wisp_users SET WISP_EMAIL = "' + ParamUser.Email +
    '" WHERE WISP_USERNAME = "' + ParamUser.UserName + '";');
end;

// =============================================================================
Function TAccesManager.GetCurrentUserFullName(): string;
begin
  Result := CurrentUser.FirstName + ' ' + CurrentUser.FamilyName;
end;

// =============================================================================
Destructor TAccesManager.Destroy;
begin
  if Global_Singleton_AccesManager = Self then
    Global_Singleton_AccesManager := nil;
  inherited Destroy;
end;

end.
