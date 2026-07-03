namespace NBC.CRM.Catalog;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;

/// <summary>
/// Catalog lifecycle services: the draft/active/retired transitions and the sell-window gate that BC's
/// Blocked flag alone cannot express. IsSellable is pure (no DB) so it is unit-testable.
/// </summary>
codeunit 50090 "NBC CRM Catalog Mgt."
{
    Access = Public;

    /// <summary>True when a catalog record is Active and OnDate falls inside its sell window.</summary>
    procedure IsSellable(Status: Enum "NBC CRM Catalog Status"; ValidFrom: Date; ValidTo: Date; OnDate: Date): Boolean
    begin
        if Status <> Status::Active then
            exit(false);
        if (ValidFrom <> 0D) and (OnDate < ValidFrom) then
            exit(false);
        if (ValidTo <> 0D) and (OnDate > ValidTo) then
            exit(false);
        exit(true);
    end;

    /// <summary>Move an item to Active (publish for selling).</summary>
    procedure PublishItem(var Item: Record Item)
    begin
        Item."NBC CRM Catalog Status" := Item."NBC CRM Catalog Status"::Active;
        Item.Modify(true);
    end;

    /// <summary>Move an item to Retired (withdraw from selling).</summary>
    procedure RetireItem(var Item: Record Item)
    begin
        Item."NBC CRM Catalog Status" := Item."NBC CRM Catalog Status"::Retired;
        Item.Modify(true);
    end;

    /// <summary>Move a resource to Active (publish for selling).</summary>
    procedure PublishResource(var Resource: Record Resource)
    begin
        Resource."NBC CRM Catalog Status" := Resource."NBC CRM Catalog Status"::Active;
        Resource.Modify(true);
    end;

    /// <summary>Move a resource to Retired (withdraw from selling).</summary>
    procedure RetireResource(var Resource: Record Resource)
    begin
        Resource."NBC CRM Catalog Status" := Resource."NBC CRM Catalog Status"::Retired;
        Resource.Modify(true);
    end;
}
