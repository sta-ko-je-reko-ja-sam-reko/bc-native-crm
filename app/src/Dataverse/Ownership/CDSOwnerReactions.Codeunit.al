namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using NBC.Setup;
using System.Security.User;

/// <summary>
/// Default owner-defaulting reactions: on insert of an ownable record with no owner, stamp the
/// creating user's salesperson. Resolved via the CRM Service Locator so it stays swappable.
/// </summary>
codeunit 50022 "NBC CDS Owner Reactions" implements "NBC CDS IOwnerReactions"
{
    Access = Public;

    procedure OnInsertCustomer(var Customer: Record Customer)
    var
        OwnerMgt: Codeunit "NBC CDS Owner Mgt.";
        FeatureMgt: Codeunit "NBC Feature Mgt.";
        OwnerType: Enum "NBC CDS Owner Type";
        OwnerCode: Code[20];
    begin
        if not FeatureMgt.IsEnabled(Enum::"NBC Feature"::Ownership) then
            exit;
        if Customer.IsTemporary() then
            exit;
        if Customer."NBC CDS Owner Code" <> '' then
            exit;
        if not OwnerMgt.GetDefaultOwner(OwnerType, OwnerCode) then
            exit;
        Customer."NBC CDS Owner Type" := OwnerType;
        Customer."NBC CDS Owner Code" := OwnerCode;
        Customer.Modify(false);
    end;

    procedure OnInsertContact(var Contact: Record Contact)
    var
        OwnerMgt: Codeunit "NBC CDS Owner Mgt.";
        FeatureMgt: Codeunit "NBC Feature Mgt.";
        OwnerType: Enum "NBC CDS Owner Type";
        OwnerCode: Code[20];
    begin
        if not FeatureMgt.IsEnabled(Enum::"NBC Feature"::Ownership) then
            exit;
        if Contact.IsTemporary() then
            exit;
        if Contact."NBC CDS Owner Code" <> '' then
            exit;
        if not OwnerMgt.GetDefaultOwner(OwnerType, OwnerCode) then
            exit;
        Contact."NBC CDS Owner Type" := OwnerType;
        Contact."NBC CDS Owner Code" := OwnerCode;
        Contact.Modify(false);
    end;
}
