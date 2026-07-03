namespace NBC.CRM.Catalog;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;

/// <summary>Default implementation of CRM IBundle — component lookup and amount calc.</summary>
codeunit 50091 "NBC CRM Bundle Logic" implements "NBC CRM IBundle"
{
    Access = Public;

    procedure Validate_No(var BundleLine: Record "NBC CRM Bundle Line")
    var
        Item: Record Item;
        Resource: Record Resource;
    begin
        case BundleLine."Component Type" of
            BundleLine."Component Type"::Item:
                if Item.Get(BundleLine."No.") then begin
                    BundleLine.Description := CopyStr(Item.Description, 1, MaxStrLen(BundleLine.Description));
                    BundleLine."Unit Price" := Item."Unit Price";
                end;
            BundleLine."Component Type"::Resource:
                if Resource.Get(BundleLine."No.") then begin
                    BundleLine.Description := CopyStr(Resource.Name, 1, MaxStrLen(BundleLine.Description));
                    BundleLine."Unit Price" := Resource."Unit Price";
                end;
        end;
        Validate_Amounts(BundleLine);
    end;

    procedure Validate_Amounts(var BundleLine: Record "NBC CRM Bundle Line")
    begin
        BundleLine."Line Amount" := Round(BundleLine.Quantity * BundleLine."Unit Price");
    end;
}
