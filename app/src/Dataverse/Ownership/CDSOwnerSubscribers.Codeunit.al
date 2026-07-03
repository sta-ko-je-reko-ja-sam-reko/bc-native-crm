namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Core;

/// <summary>
/// Base-app subscriber proxy — hooks Customer/Contact inserts published by MS BaseApp, so it fires for EVERY user in
/// the tenant. Entitled Unlicensed (via the base-subscriber permission set/entitlement) so the subscription never
/// errors for anyone. Each body delegates two lines: the swappable **access policy** (effective-permission check by
/// object id — never instantiates our own object) gates entitlement, then the owner reaction runs only for entitled
/// users. Both are resolved through the Service Locator, so the guard and the reaction are independently swappable.
/// </summary>
codeunit 50023 "NBC CDS Owner Subscribers"
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterInsertEvent, '', true, true)]
    local procedure CustomerOnAfterInsert(var Rec: Record Customer; RunTrigger: Boolean)
    var
        ServiceLocator: Codeunit "NBC Service Locator";
    begin
        if not ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"NBC Service Locator") then
            exit;
        ServiceLocator.OwnerReactions().OnInsertCustomer(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, OnAfterInsertEvent, '', true, true)]
    local procedure ContactOnAfterInsert(var Rec: Record Contact; RunTrigger: Boolean)
    var
        ServiceLocator: Codeunit "NBC Service Locator";
    begin
        if not ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"NBC Service Locator") then
            exit;
        ServiceLocator.OwnerReactions().OnInsertContact(Rec);
    end;
}
