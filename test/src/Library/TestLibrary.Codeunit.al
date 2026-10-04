namespace NBC.Test;

using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using NBC.Core;
using NBC.CRM.Linkage;
using NBC.CRM.Pricing;
using NBC.CRM.Process;
using NBC.Dataverse.Ownership;
using NBC.Setup;
using System.Security.User;

/// <summary>
/// Shared arrange helpers for the CRM test codeunits: feature toggles without the setup page's session restart,
/// service-locator injection of the test doubles, the current user's salesperson mapping and small CRM fixtures.
/// The test runner isolates per codeunit, so every test arranges the state it relies on through these helpers
/// instead of assuming what an earlier test left behind.
/// </summary>
codeunit 69090 "NBC Test Library"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryResource: Codeunit "Library - Resource";
        LibraryERM: Codeunit "Library - ERM";
        StageNameTok: Label 'Stage %1', Locked = true;

    /// <summary>
    /// Standard arrange step: every effective-permission check passes and the default owner and linkage reactions
    /// are active again (a previous test may have injected spies into the single-instance Service Locator).
    /// </summary>
    procedure Initialize()
    begin
        SetAccessGranted(true);
        RestoreDefaultReactions();
    end;

    /// <summary>Routes the Service Locator's access policy to the fake, granting or denying every check.</summary>
    /// <param name="Grant">Whether effective-permission checks pass.</param>
    procedure SetAccessGranted(Grant: Boolean)
    var
        FakeAccessPolicy: Codeunit "NBC Fake Access Policy";
        ServiceLocator: Codeunit "NBC Service Locator";
    begin
        FakeAccessPolicy.SetGrant(Grant);
        ServiceLocator.ImplementAccessPolicy(FakeAccessPolicy);
    end;

    /// <summary>Puts the app's own access policy back into the Service Locator.</summary>
    procedure RestoreDefaultAccessPolicy()
    var
        DefaultPolicy: Codeunit "NBC Access Policy";
        ServiceLocator: Codeunit "NBC Service Locator";
    begin
        ServiceLocator.ImplementAccessPolicy(DefaultPolicy);
    end;

    /// <summary>Puts the app's own owner and linkage reactions back into the Service Locator.</summary>
    procedure RestoreDefaultReactions()
    var
        DefaultOwnerReactions: Codeunit "NBC CDS Owner Reactions";
        DefaultLinkageReactions: Codeunit "NBC CRM Linkage Reactions";
        ServiceLocator: Codeunit "NBC Service Locator";
    begin
        ServiceLocator.ImplementOwnerReactions(DefaultOwnerReactions);
        ServiceLocator.ImplementLinkageReactions(DefaultLinkageReactions);
    end;

    /// <summary>Sets a feature's Enabled flag directly on its setup record (creating it), without the page's session restart.</summary>
    /// <param name="Feature">The feature.</param>
    /// <param name="Enable">The Enabled state.</param>
    procedure SetFeatureEnabled(Feature: Enum "NBC Feature"; Enable: Boolean)
    var
        OwnershipSetup: Record "NBC Ownership Setup";
        ActivitySetup: Record "NBC Activity Setup";
        PartySetup: Record "NBC Party Setup";
        OpportunitySetup: Record "NBC Opportunity Setup";
        ProcessSetup: Record "NBC Process Setup";
        RoleCenterSetup: Record "NBC Role Center Setup";
        GovernanceSetup: Record "NBC Governance Setup";
        CatalogSetup: Record "NBC Catalog Setup";
        PricingSetup: Record "NBC Pricing Setup";
        LinkageSetup: Record "NBC Linkage Setup";
    begin
        case Feature of
            Feature::Ownership:
                begin
                    if not OwnershipSetup.Get() then
                        OwnershipSetup.Insert();
                    OwnershipSetup.Enabled := Enable;
                    OwnershipSetup.Modify();
                end;
            Feature::Activities:
                begin
                    if not ActivitySetup.Get() then
                        ActivitySetup.Insert();
                    ActivitySetup.Enabled := Enable;
                    ActivitySetup.Modify();
                end;
            Feature::Party:
                begin
                    if not PartySetup.Get() then
                        PartySetup.Insert();
                    PartySetup.Enabled := Enable;
                    PartySetup.Modify();
                end;
            Feature::Opportunity:
                begin
                    if not OpportunitySetup.Get() then
                        OpportunitySetup.Insert();
                    OpportunitySetup.Enabled := Enable;
                    OpportunitySetup.Modify();
                end;
            Feature::Process:
                begin
                    if not ProcessSetup.Get() then
                        ProcessSetup.Insert();
                    ProcessSetup.Enabled := Enable;
                    ProcessSetup.Modify();
                end;
            Feature::RoleCenter:
                begin
                    if not RoleCenterSetup.Get() then
                        RoleCenterSetup.Insert();
                    RoleCenterSetup.Enabled := Enable;
                    RoleCenterSetup.Modify();
                end;
            Feature::Governance:
                begin
                    if not GovernanceSetup.Get() then
                        GovernanceSetup.Insert();
                    GovernanceSetup.Enabled := Enable;
                    GovernanceSetup.Modify();
                end;
            Feature::Catalog:
                begin
                    if not CatalogSetup.Get() then
                        CatalogSetup.Insert();
                    CatalogSetup.Enabled := Enable;
                    CatalogSetup.Modify();
                end;
            Feature::Pricing:
                begin
                    if not PricingSetup.Get() then
                        PricingSetup.Insert();
                    PricingSetup.Enabled := Enable;
                    PricingSetup.Modify();
                end;
            Feature::Linkage:
                begin
                    if not LinkageSetup.Get() then
                        LinkageSetup.Insert();
                    LinkageSetup.Enabled := Enable;
                    LinkageSetup.Modify();
                end;
        end;
    end;

    /// <summary>Removes the setup record of every feature (the "never set up" state).</summary>
    procedure DeleteAllFeatureSetups()
    var
        OwnershipSetup: Record "NBC Ownership Setup";
        ActivitySetup: Record "NBC Activity Setup";
        PartySetup: Record "NBC Party Setup";
        OpportunitySetup: Record "NBC Opportunity Setup";
        ProcessSetup: Record "NBC Process Setup";
        RoleCenterSetup: Record "NBC Role Center Setup";
        GovernanceSetup: Record "NBC Governance Setup";
        CatalogSetup: Record "NBC Catalog Setup";
        PricingSetup: Record "NBC Pricing Setup";
        LinkageSetup: Record "NBC Linkage Setup";
    begin
        OwnershipSetup.DeleteAll();
        ActivitySetup.DeleteAll();
        PartySetup.DeleteAll();
        OpportunitySetup.DeleteAll();
        ProcessSetup.DeleteAll();
        RoleCenterSetup.DeleteAll();
        GovernanceSetup.DeleteAll();
        CatalogSetup.DeleteAll();
        PricingSetup.DeleteAll();
        LinkageSetup.DeleteAll();
    end;

    /// <summary>Maps the current user to a salesperson in User Setup ('' removes the mapping).</summary>
    /// <param name="SalespersonCode">The salesperson code.</param>
    procedure SetCurrentUserSalesperson(SalespersonCode: Code[20])
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."Salespers./Purch. Code" := SalespersonCode;
        UserSetup.Modify();
    end;

    /// <summary>Removes the current user's User Setup record entirely.</summary>
    procedure DeleteCurrentUserSetup()
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            UserSetup.Delete();
    end;

    /// <summary>Creates a new salesperson.</summary>
    /// <returns>The salesperson code.</returns>
    procedure CreateSalesperson(): Code[20]
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        LibrarySales.CreateSalesperson(SalespersonPurchaser);
        exit(SalespersonPurchaser.Code);
    end;

    /// <summary>Creates a salesperson and maps the current user to it.</summary>
    /// <returns>The salesperson code.</returns>
    procedure CreateSalespersonForCurrentUser(): Code[20]
    var
        SalespersonCode: Code[20];
    begin
        SalespersonCode := CreateSalesperson();
        SetCurrentUserSalesperson(SalespersonCode);
        exit(SalespersonCode);
    end;

    /// <summary>Creates a CRM team.</summary>
    /// <returns>The team code.</returns>
    procedure CreateTeam(): Code[20]
    var
        Team: Record "NBC CDS Team";
    begin
        Team.Init();
        Team.Code := LibraryUtility.GenerateRandomCode20(Team.FieldNo(Code), Database::"NBC CDS Team");
        Team.Name := Team.Code;
        Team.Insert(true);
        exit(Team.Code);
    end;

    /// <summary>Adds a salesperson to a CRM team.</summary>
    /// <param name="TeamCode">The team.</param>
    /// <param name="SalespersonCode">The salesperson.</param>
    procedure AddTeamMember(TeamCode: Code[20]; SalespersonCode: Code[20])
    var
        TeamMember: Record "NBC CDS Team Member";
    begin
        TeamMember.Init();
        TeamMember."Team Code" := TeamCode;
        TeamMember."Salesperson Code" := SalespersonCode;
        TeamMember.Insert(true);
    end;

    /// <summary>Inserts a customer with a given number through the standard insert trigger.</summary>
    /// <param name="Customer">The new customer.</param>
    procedure CreateCustomer(var Customer: Record Customer)
    begin
        Customer.Init();
        Customer."No." := LibraryUtility.GenerateRandomCode20(Customer.FieldNo("No."), Database::Customer);
        Customer.Name := Customer."No.";
        Customer.Insert(true);
    end;

    /// <summary>Inserts a bare opportunity (no sales cycle) with a given number.</summary>
    /// <param name="SalespersonCode">The opportunity's salesperson.</param>
    /// <returns>The opportunity number.</returns>
    procedure CreateOpportunity(SalespersonCode: Code[20]): Code[20]
    var
        Opportunity: Record Opportunity;
    begin
        Opportunity.Init();
        Opportunity."No." := LibraryUtility.GenerateRandomCode20(Opportunity.FieldNo("No."), Database::Opportunity);
        Opportunity.Description := Opportunity."No.";
        Opportunity."Salesperson Code" := SalespersonCode;
        Opportunity.Insert();
        exit(Opportunity."No.");
    end;

    /// <summary>Creates an item with a given unit price and unit cost.</summary>
    /// <param name="UnitPrice">The unit price.</param>
    /// <param name="UnitCost">The unit cost.</param>
    /// <returns>The item number.</returns>
    procedure CreateItem(UnitPrice: Decimal; UnitCost: Decimal): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        Item."Unit Price" := UnitPrice;
        Item."Unit Cost" := UnitCost;
        Item.Modify();
        exit(Item."No.");
    end;

    /// <summary>Creates a resource with a given unit price and unit cost.</summary>
    /// <param name="UnitPrice">The unit price.</param>
    /// <param name="UnitCost">The unit cost.</param>
    /// <returns>The resource number.</returns>
    procedure CreateResource(UnitPrice: Decimal; UnitCost: Decimal): Code[20]
    var
        Resource: Record Resource;
    begin
        LibraryResource.CreateResourceNew(Resource);
        Resource."Unit Price" := UnitPrice;
        Resource."Unit Cost" := UnitCost;
        Resource.Modify();
        exit(Resource."No.");
    end;

    /// <summary>Creates a discount list.</summary>
    /// <param name="DiscountType">Percentage or amount.</param>
    /// <returns>The discount list code.</returns>
    procedure CreateDiscountList(DiscountType: Enum "NBC CRM Discount Type"): Code[20]
    var
        DiscountList: Record "NBC CRM Discount List";
    begin
        DiscountList.Init();
        DiscountList.Code := LibraryUtility.GenerateRandomCode20(DiscountList.FieldNo(Code), Database::"NBC CRM Discount List");
        DiscountList."Discount Type" := DiscountType;
        DiscountList.Insert(true);
        exit(DiscountList.Code);
    end;

    /// <summary>Adds a quantity band to a discount list.</summary>
    /// <param name="DiscountListCode">The discount list.</param>
    /// <param name="LineNo">The line number.</param>
    /// <param name="MinQty">The minimum quantity.</param>
    /// <param name="MaxQty">The maximum quantity (0 = open-ended).</param>
    /// <param name="TierValue">The discount value of the band.</param>
    procedure AddDiscountTier(DiscountListCode: Code[20]; LineNo: Integer; MinQty: Decimal; MaxQty: Decimal; TierValue: Decimal)
    var
        DiscountTier: Record "NBC CRM Discount Tier";
    begin
        DiscountTier.Init();
        DiscountTier."Discount List Code" := DiscountListCode;
        DiscountTier."Line No." := LineNo;
        DiscountTier."Minimum Quantity" := MinQty;
        DiscountTier."Maximum Quantity" := MaxQty;
        DiscountTier.Value := TierValue;
        DiscountTier.Insert(true);
    end;

    /// <summary>A table number no real process is bound to, so process tests never collide with the seeded OPP-SALES process.</summary>
    /// <returns>The table number.</returns>
    procedure ProcessTestTableNo(): Integer
    begin
        exit(69999);
    end;

    /// <summary>Removes every process, stage and state bound to the given table.</summary>
    /// <param name="TableNo">The table number.</param>
    procedure DeleteProcessesForTable(TableNo: Integer)
    var
        Process: Record "NBC CRM Process";
        Stage: Record "NBC CRM Process Stage";
        State: Record "NBC CRM Process State";
    begin
        State.SetRange("Table No.", TableNo);
        State.DeleteAll();
        Process.SetRange("Table No.", TableNo);
        if Process.FindSet() then
            repeat
                Stage.SetRange("Process Code", Process.Code);
                Stage.DeleteAll();
            until Process.Next() = 0;
        Process.DeleteAll();
    end;

    /// <summary>Creates a process for a table with the given stage numbers.</summary>
    /// <param name="TableNo">The table the process applies to.</param>
    /// <param name="Active">Whether it is the active process.</param>
    /// <param name="StageNos">The stage numbers (any order).</param>
    /// <returns>The process code.</returns>
    procedure CreateProcess(TableNo: Integer; Active: Boolean; StageNos: List of [Integer]): Code[20]
    var
        Process: Record "NBC CRM Process";
        Stage: Record "NBC CRM Process Stage";
        StageNo: Integer;
    begin
        Process.Init();
        Process.Code := LibraryUtility.GenerateRandomCode20(Process.FieldNo(Code), Database::"NBC CRM Process");
        Process.Name := Process.Code;
        Process."Table No." := TableNo;
        Process.Active := Active;
        Process.Insert(true);
        foreach StageNo in StageNos do begin
            Stage.Init();
            Stage."Process Code" := Process.Code;
            Stage."Stage No." := StageNo;
            Stage.Name := CopyStr(StrSubstNo(StageNameTok, StageNo), 1, MaxStrLen(Stage.Name));
            Stage.Insert(true);
        end;
        exit(Process.Code);
    end;

    /// <summary>Creates a sales order for a new customer with one G/L account line, optionally linked to an opportunity.</summary>
    /// <param name="SalesHeader">The new order.</param>
    /// <param name="OpportunityNo">The CRM opportunity to link ('' for none).</param>
    procedure CreateSalesOrder(var SalesHeader: Record "Sales Header"; OpportunityNo: Code[20])
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        SalesHeader."NBC CRM Opportunity No." := OpportunityNo;
        SalesHeader.Modify();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup(), 1);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Modify(true);
    end;
}
