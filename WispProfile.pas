unit WispProfile;

interface

uses
  WispPrivilege,
  WispEntityManager,
  CxTL,
  Classes,
  WispDbConnection,
  WispQueryTools,
  ZDataSet,
  WispStrTools,
  WispMathTools;

type
  TWispProfile = Class(TComponent)
  Private
    FID: String;
    FName: String;
    FPrivilegeArray: Array of TWispPrivilege;
  Public
    Property ID: String Read FID Write FID;
    Constructor Create(ParamName: String; ParamDefaultValue: Boolean;
      ParamDefault: Boolean = FALSE);
    Procedure AddPrivilege(ParamName, ParamLabel: String; ParamValue: Boolean;
      ParamParent: String = '');
    Procedure Draw(ParamTreeList: TCxTreeList);
    Function GetPrivilegeByName(ParamName: String): TWispPrivilege;
    Procedure LoadFromList;
    Procedure NewToDb(ParamName: String);
    Procedure UpdateToDb(ParamName: String);
    Procedure LoadFromDbById(ParamProfileId: String);
    Function GetAcces(ParamPrivilegeName: String): Boolean;
  End;

implementation

// =============================================================================
Constructor TWispProfile.Create(ParamName: String; ParamDefaultValue: Boolean;
  ParamDefault: Boolean = FALSE);
var
  I: Integer;
  S: String;
begin
  AddPrivilege('GLOBAL_ACCES', 'Global Acces', ParamDefaultValue);
  AddPrivilege('SUPER_USER', 'Super User', ParamDefaultValue);
  AddPrivilege('DEVELOPER', 'Developer', ParamDefaultValue);

  AddPrivilege('USER_MANAGER', 'User Manager', ParamDefaultValue);
  AddPrivilege('USER_ADD', 'Add', ParamDefaultValue, 'USER_MANAGER');
  AddPrivilege('USER_EDIT', 'Edit', ParamDefaultValue, 'USER_MANAGER');
  AddPrivilege('USER_DELETE', 'Delete', ParamDefaultValue, 'USER_MANAGER');

  AddPrivilege('PROFILE_MANAGER', 'Profile Manager', ParamDefaultValue);
  AddPrivilege('PROFILE_ADD', 'Add', ParamDefaultValue, 'PROFILE_MANAGER');
  AddPrivilege('PROFILE_EDIT', 'Edit', ParamDefaultValue, 'PROFILE_MANAGER');
  AddPrivilege('PROFILE_DELETE', 'Delete', ParamDefaultValue,
    'PROFILE_MANAGER');

  AddPrivilege('REPORT_MANAGER', 'Report Manager', ParamDefaultValue);
  AddPrivilege('REPORT_ADD', 'Add', ParamDefaultValue, 'REPORT_MANAGER');
  AddPrivilege('REPORT_EDIT', 'Edit', ParamDefaultValue, 'REPORT_MANAGER');
  AddPrivilege('REPORT_DELETE', 'Delete', ParamDefaultValue, 'REPORT_MANAGER');

  if ParamDefault <> TRUE then
  begin
    for I := 0 to Global_Singleton_EntityManager.EntityCount - 1 do
    begin
      S := 'ENTITY_' + Global_Singleton_EntityManager.GetEntityById(I)
        .GetEntityName;
      AddPrivilege(S, Global_Singleton_EntityManager.GetEntityById(I)
        .DisplayName, ParamDefaultValue);
      AddPrivilege(S + '_ADD', 'Add', ParamDefaultValue, S);
      AddPrivilege(S + '_EDIT', 'Edit', ParamDefaultValue, S);
      AddPrivilege(S + '_VIEW', 'View', ParamDefaultValue, S);
      AddPrivilege(S + '_DELETE', 'Delete', ParamDefaultValue, S);
      AddPrivilege(S + '_LOCK', 'Lock', ParamDefaultValue, S);
      AddPrivilege(S + '_UNLOCK', 'Unlock', ParamDefaultValue, S);
    end;
  end;
end;

// =============================================================================
Procedure TWispProfile.AddPrivilege(ParamName, ParamLabel: String;
  ParamValue: Boolean; ParamParent: String = '');
Var
  tmpPrivilege: TWispPrivilege;
begin
  tmpPrivilege := TWispPrivilege.Create(ParamName, ParamLabel, ParamValue, nil,
    ParamParent);
  SetLength(FPrivilegeArray, Length(FPrivilegeArray) + 1);
  FPrivilegeArray[Length(FPrivilegeArray) - 1] := tmpPrivilege;
end;

// =============================================================================
Function TWispProfile.GetPrivilegeByName(ParamName: String): TWispPrivilege;
Var
  I: Integer;
begin
  for I := 0 to Length(FPrivilegeArray) - 1 do
  begin
    if FPrivilegeArray[I].Name = ParamName then
    begin
      result := FPrivilegeArray[I];
      EXIT;
    end;
  end;
end;

// =============================================================================
Procedure TWispProfile.Draw(ParamTreeList: TCxTreeList);
Var
  I: Integer;
  tmpNode: TcxTreeListNode;
  tmpParent: TWispPrivilege;
begin
  for I := 0 to Length(FPrivilegeArray) - 1 do
  begin
    if FPrivilegeArray[I].ParentName <> '' then
    begin
      tmpParent := GetPrivilegeByName(FPrivilegeArray[I].ParentName);
      tmpNode := tmpParent.Node.AddChild;
      tmpNode.Texts[0] := FPrivilegeArray[I].DisplayName;
      tmpNode.Values[1] := FPrivilegeArray[I].Value;
      FPrivilegeArray[I].Node := tmpNode;
    end
    else
    begin
      tmpNode := ParamTreeList.Add;
      tmpNode.Texts[0] := FPrivilegeArray[I].DisplayName;
      tmpNode.Values[1] := FPrivilegeArray[I].Value;
      FPrivilegeArray[I].Node := tmpNode;
    end;
  end;
end;

// =============================================================================
Procedure TWispProfile.LoadFromList();
Var
  I: Integer;
begin
  for I := 0 to Length(FPrivilegeArray) - 1 do
  begin
    if FPrivilegeArray[I].Node <> nil then
      FPrivilegeArray[I].Value := FPrivilegeArray[I].Node.Values[1];
  end;
end;

// =============================================================================
Procedure TWispProfile.NewToDb(ParamName: String);
Var
  TmpQ: TZQuery;
  I: Integer;
  S, TmpId: String;
begin
  S := 'INSERT INTO wisp_profiles (WISP_NAME) VALUES ("' + ParamName + '");';
  ExecuteQuery(Global_Singleton_DbConnection, S);

  TmpId := OpenQuery(Global_Singleton_DbConnection, 'SELECT LAST_INSERT_ID();')
    .FirstFieldAsString;
  ID := TmpId;

  for I := 0 to Length(FPrivilegeArray) - 1 do
  begin
    S := 'INSERT INTO wisp_privileges (NAME,LABEL,VALUE,PARENT_NAME,ID_PROFILE) VALUES ("'
      + FPrivilegeArray[I].Name + '","' + FPrivilegeArray[I].DisplayName + '",'
      + BooleanToString(FPrivilegeArray[I].Value) + ',"' + FPrivilegeArray[I]
      .ParentName + '",' + ID + ');';

    ExecuteQuery(Global_Singleton_DbConnection, S);
  end;
end;

// =============================================================================
Procedure TWispProfile.UpdateToDb(ParamName: String);
Var
  TmpQ: TZQuery;
  I: Integer;
  S, TmpId: String;
begin
  // need rework
  S := 'INSERT INTO wisp_profiles (WISP_NAME) VALUES ("' + ParamName + '");';
  ExecuteQuery(Global_Singleton_DbConnection, S);

  TmpId := OpenQuery(Global_Singleton_DbConnection, 'SELECT LAST_INSERT_ID();')
    .FirstFieldAsString;
  ID := TmpId;

  for I := 0 to Length(FPrivilegeArray) - 1 do
  begin
    S := 'INSERT INTO wisp_privileges (NAME,LABEL,VALUE,PARENT_NAME,ID_PROFILE) VALUES ("'
      + FPrivilegeArray[I].Name + '","' + FPrivilegeArray[I].DisplayName + '",'
      + BooleanToString(FPrivilegeArray[I].Value) + ',"' + FPrivilegeArray[I]
      .ParentName + '",' + ID + ');';

    ExecuteQuery(Global_Singleton_DbConnection, S);
  end;
end;

// =============================================================================
Procedure TWispProfile.LoadFromDbById(ParamProfileId: String);
Var
  TmpQ: TZQuery;
  I: Integer;
  TmpName, TmpLabel, tmpParent: String;
  TmpValue: Boolean;
begin
  TmpQ := OpenQuery(Global_Singleton_DbConnection,
    'SELECT * FROM wisp_privileges WHERE ID_PROFILE=' + ParamProfileId +
    ';').ZQuery;

  SetLength(FPrivilegeArray, 0);

  for I := 0 to TmpQ.RecordCount - 1 do
  begin
    TmpName := TmpQ.FieldByName('NAME').AsString;
    TmpLabel := TmpQ.FieldByName('LABEL').AsString;
    TmpValue := GetBooleanOf(TmpQ.FieldByName('VALUE').AsString);
    tmpParent := TmpQ.FieldByName('PARENT_NAME').AsString;

    TmpQ.Next;

    AddPrivilege(TmpName, TmpLabel, TmpValue, tmpParent);
  end;
end;

// =============================================================================
Function TWispProfile.GetAcces(ParamPrivilegeName: String): Boolean;
Var
  I: Integer;
  TmpBool: Boolean;
  tmpPrivilege: TWispPrivilege;
  // TmpName, TmpLabel, TmpParent : String;
  // TmpValue : Boolean;
begin

  tmpPrivilege := GetPrivilegeByName('GLOBAL_ACCES');
  if tmpPrivilege <> nil then
  begin
    TmpBool := tmpPrivilege.Value;
    if TmpBool then
    begin
      result := TRUE;
      EXIT;
    end;
  end;

  tmpPrivilege := GetPrivilegeByName(ParamPrivilegeName);
  if tmpPrivilege <> nil then
  begin
    TmpBool := tmpPrivilege.Value;
    if TmpBool then
    begin
      result := TRUE;
      EXIT;
    end;
  end;

  result := FALSE;

end;

end.
