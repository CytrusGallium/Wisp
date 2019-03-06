unit WispTreeListNode;

interface

uses
  cxTL;

type
  TWispTreeListNodeType = Char;

type
  TWispTreeListNode = Class(TcxTreeListNode)
  private
    FLevel: Integer;
    FTypeCode: TWispTreeListNodeType;
    FParentCode: Char;
    FChildCode: Char;
    FEntityId: Integer;
    FExtraCode: Integer;
  public
    Property Level: Integer Read FLevel;
    Property TypeCode: TWispTreeListNodeType Read FTypeCode;
    Property ParentCode: Char Read FParentCode;
    Property ChildCode: Char Read FChildCode;
    Property EntityId: Integer Read FEntityId;
    Property ExtraCode: Integer Read FExtraCode;
    // Level: Integer;
    // TypeCode: AnsiString;
    // ParentCode: AnsiString;
    // ChildCode: AnsiString;
    Procedure SetInfo(ParamLevel: Integer; ParamType: TWispTreeListNodeType;
      ParamParentCode: Char; ParamChildCode: Char = #0;
      ParamEntityId: Integer = 0; ParamExtraCode: Integer = 0);
  End;

Const
  wntGlobalPrivilege: TWispTreeListNodeType = 'G';
  wntEntityPrivilege: TWispTreeListNodeType = 'E';

implementation

Procedure TWispTreeListNode.SetInfo(ParamLevel: Integer; ParamType: TWispTreeListNodeType;
  ParamParentCode: Char; ParamChildCode: Char = #0; ParamEntityId: Integer = 0;
  ParamExtraCode: Integer = 0);
begin
  FLevel := ParamLevel;
  FTypeCode := ParamType;
  FParentCode := ParamParentCode;
  FChildCode := ParamChildCode;
  FEntityId := ParamEntityId;
  FExtraCode := ParamExtraCode;
end;

end.
