unit WispUser;

interface

uses
  SysUtils,
  WispQueryTools,
  WispDbConnection,
  ZDataset;

Type

  TWispUser = Class(TObject)
  private
    FID: String;
    FUserName: String;
    FFirstName: String;
    FFamilyName: String;
    FPhoneNumber: String;
    FEmail: String;
    FProfileID : String;
  public
    Property ID: String Read FID;
    Property UserName: String Read FUserName Write FUserName;
    Property FirstName: String Read FFirstName Write FFirstName;
    Property FamilyName: String Read FFamilyName Write FFamilyName;
    Property PhoneNumber: String Read FPhoneNumber Write FPhoneNumber;
    Property Email: String Read FEmail Write FEmail;
    Property ProfileId : String Read FProfileID;
    Constructor Create;
    Procedure LoadFromDbByUserName(ParamUserName: String); overload;
    Procedure LoadFromDbById(ParamId: String); overload;
    Procedure UpdateProfileId(ParamProfileId: String);
  End;

implementation

Constructor TWispUser.Create;
begin
  // ...
end;

// =============================================================================
Procedure TWispUser.LoadFromDbByUserName(ParamUserName: String);
Var
  TmpQ: TZQuery;
begin
  TmpQ := OpenQuery(Global_Singleton_DbConnection,
    'SELECT * FROM wisp_users WHERE WISP_USERNAME="' + ParamUserName +
    '";').ZQuery;

  FID := TmpQ.FieldByName('WISP_ID').AsString;
  FUserName := TmpQ.FieldByName('WISP_USERNAME').AsString;
  FFirstName := TmpQ.FieldByName('WISP_FIRST_NAME').AsString;
  FFamilyName := TmpQ.FieldByName('WISP_FAMILY_NAME').AsString;
  FPhoneNumber := TmpQ.FieldByName('WISP_PHONE_NUMBER').AsString;
  FEmail := TmpQ.FieldByName('WISP_EMAIL').AsString;
  FProfileID := TmpQ.FieldByName('ID_PROFILE').AsString;
end;

// =============================================================================
Procedure TWispUser.LoadFromDbById(ParamId: String);
Var
  TmpQ: TZQuery;
begin
  TmpQ := OpenQuery(Global_Singleton_DbConnection,
    'SELECT * FROM wisp_users WHERE WISP_ID="' + ParamId + '";').ZQuery;

  FID := TmpQ.FieldByName('WISP_ID').AsString;
  FUserName := TmpQ.FieldByName('WISP_USERNAME').AsString;
  FFirstName := TmpQ.FieldByName('WISP_FIRST_NAME').AsString;
  FFamilyName := TmpQ.FieldByName('WISP_FAMILY_NAME').AsString;
  FPhoneNumber := TmpQ.FieldByName('WISP_PHONE_NUMBER').AsString;
  FEmail := TmpQ.FieldByName('WISP_EMAIL').AsString;
end;

// =============================================================================
Procedure TWispUser.UpdateProfileId(ParamProfileId: String);
begin
  ExecuteQuery(Global_Singleton_DbConnection,
    'UPDATE wisp_users SET ID_PROFILE="' + ParamProfileId + '" WHERE WISP_ID = '
    + FID + ';');
end;

end.
