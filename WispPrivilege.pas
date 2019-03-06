unit WispPrivilege;

interface

uses cxTL,
  Dialogs,
  WispEntityManager,
  WispTreeListNode,
  Classes;

type
  TWispPrivilege = Class(TComponent)
  Private
    FName: String;
    FLabel: String;
    FValue: Boolean;
    FNode: TCxTreeListNode;
    FParentName: String;
  Public
    Property Name: String Read FName;
    Property DisplayName: String Read FLabel;
    Property Value: Boolean Read FValue Write FValue;
    Property Node: TCxTreeListNode Read FNode Write FNode;
    Property ParentName: String Read FParentName;
    Constructor Create(ParamName, ParamLabel: String; ParamValue: Boolean;
      ParamNode: TCxTreeListNode; ParamParent: String);
  End;

implementation

// =============================================================================
Constructor TWispPrivilege.Create(ParamName, ParamLabel: String;
  ParamValue: Boolean; ParamNode: TCxTreeListNode; ParamParent: String);
begin
  FName := ParamName;
  FLabel := ParamLabel;
  FValue := ParamValue;
  FNode := ParamNode;
  FParentName := ParamParent;
end;

end.
