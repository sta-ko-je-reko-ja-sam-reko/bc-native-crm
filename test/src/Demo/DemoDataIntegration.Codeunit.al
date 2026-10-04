namespace NBC.Test;

using Microsoft.CRM.Opportunity;
using Microsoft.Pricing.PriceList;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using NBC.CRM.Catalog;
using NBC.CRM.Opportunity;
using NBC.CRM.Pricing;
using NBC.CRM.Process;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;
using NBC.Demo;
using System.IO;
using System.Security.User;
using System.TestLibraries.Utilities;

/// <summary>
/// Demo data layer, DB-bound: each seeder is idempotent (a second run creates nothing), creates its RapidStart
/// package only once, and the master SeedAll is safe to re-run. Seeders that depend on CRONUS master data skip
/// gracefully elsewhere, so the assertions compare first and second runs rather than absolute counts where the
/// outcome depends on the company's demo data.
/// </summary>
codeunit 69007 "NBC Demo Data Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";
        RowsAfterSecondRunTok: Label 'Rows in table %1 after the second SeedAll', Locked = true;

    [Test]
    procedure Pricing_ImportIsIdempotent()
    var
        DiscountList: Record "NBC CRM Discount List";
        DiscountTier: Record "NBC CRM Discount Tier";
        DemoPricing: Codeunit "NBC Demo Pricing";
        ListsAfterFirst: Integer;
        TiersAfterFirst: Integer;
    begin
        // [WHEN] the pricing demo seeder runs once
        TestLibrary.Initialize();
        DemoPricing.Import();
        ListsAfterFirst := DiscountList.Count();
        TiersAfterFirst := DiscountTier.Count();

        // [THEN] it created the two demo discount lists with their tiers
        Assert.IsTrue(DiscountList.Get('VOL-STD'), 'VOL-STD discount list');
        Assert.IsTrue(DiscountList.Get('REBATE-A'), 'REBATE-A discount list');
        DiscountTier.SetRange("Discount List Code", 'VOL-STD');
        Assert.RecordCount(DiscountTier, 4);
        DiscountTier.Reset();

        // [WHEN] it runs a second time  [THEN] nothing is duplicated
        DemoPricing.Import();
        Assert.AreEqual(ListsAfterFirst, DiscountList.Count(), 'Discount lists after the second run');
        Assert.AreEqual(TiersAfterFirst, DiscountTier.Count(), 'Discount tiers after the second run');
    end;

    [Test]
    procedure Pricing_DemoTiersResolveAsDocumented()
    var
        DemoPricing: Codeunit "NBC Demo Pricing";
        DiscountMgt: Codeunit "NBC CRM Discount Mgt.";
    begin
        // [GIVEN] the pricing demo data
        TestLibrary.Initialize();
        DemoPricing.Import();

        // [THEN] the volume bands resolve 5% at 10, 15% at 100+ and the rebate 5.0 at 25+
        Assert.AreEqual(5, DiscountMgt.ResolveDiscountValue('VOL-STD', 10), 'VOL-STD at 10');
        Assert.AreEqual(15, DiscountMgt.ResolveDiscountValue('VOL-STD', 250), 'VOL-STD at 250');
        Assert.AreEqual(5, DiscountMgt.ResolveDiscountValue('REBATE-A', 25), 'REBATE-A at 25');
    end;

    [Test]
    procedure Pricing_ConfigPackageNarrowsExtendedTable()
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
        DemoPricing: Codeunit "NBC Demo Pricing";
    begin
        // [GIVEN] no pricing package yet
        TestLibrary.Initialize();
        if ConfigPackage.Get('NBC-PRICING') then
            ConfigPackage.Delete(true);

        // [WHEN] the pricing demo data is imported
        DemoPricing.Import();

        // [THEN] the package holds the two own tables and the Price List Line, the latter narrowed to PK + affix fields
        Assert.IsTrue(ConfigPackage.Get('NBC-PRICING'), 'NBC-PRICING package');
        Assert.IsTrue(ConfigPackageTable.Get('NBC-PRICING', Database::"NBC CRM Discount List"), 'Discount list table');
        Assert.IsTrue(ConfigPackageTable.Get('NBC-PRICING', Database::"NBC CRM Discount Tier"), 'Discount tier table');
        Assert.IsTrue(ConfigPackageTable.Get('NBC-PRICING', Database::"Price List Line"), 'Price List Line table');
        ConfigPackageField.SetRange("Package Code", 'NBC-PRICING');
        ConfigPackageField.SetRange("Table ID", Database::"Price List Line");
        ConfigPackageField.SetRange("Include Field", true);
        ConfigPackageField.SetRange("Primary Key", false);
        Assert.RecordCount(ConfigPackageField, 6);
        ConfigPackageField.SetFilter("Field ID", '<%1|>%2', 65100, 65105);
        Assert.RecordIsEmpty(ConfigPackageField);
    end;

    [Test]
    procedure Governance_ImportCreatesDuplicatePairOnce()
    var
        Customer: Record Customer;
        DemoGovernance: Codeunit "NBC Demo Governance";
    begin
        // [WHEN] the governance seeder runs twice
        TestLibrary.Initialize();
        DemoGovernance.Import();
        DemoGovernance.Import();

        // [THEN] exactly the two demo customers share the demo name
        Customer.SetFilter("No.", 'NBC-DUP-01|NBC-DUP-02');
        Customer.SetRange(Name, 'Contoso Trading Ltd');
        Assert.RecordCount(Customer, 2);
    end;

    [Test]
    procedure Process_ImportPutsDemoOpportunityMidFlow()
    var
        Opportunity: Record Opportunity;
        State: Record "NBC CRM Process State";
        DemoProcess: Codeunit "NBC Demo Process";
    begin
        // [GIVEN] the demo opportunity exists
        TestLibrary.Initialize();
        if not Opportunity.Get('NBC-OPP-001') then begin
            Opportunity.Init();
            Opportunity."No." := 'NBC-OPP-001';
            Opportunity.Insert();
        end;
        if State.Get(Database::Opportunity, Opportunity.SystemId) then
            State.Delete();

        // [WHEN] the process seeder runs twice
        DemoProcess.Import();
        DemoProcess.Import();

        // [THEN] the opportunity sits at Propose (30) of the default process, created once
        State.Get(Database::Opportunity, Opportunity.SystemId);
        Assert.AreEqual('OPP-SALES', State."Process Code", 'Process');
        Assert.AreEqual(30, State."Current Stage No.", 'Stage');
    end;

    [Test]
    procedure RoleCenter_ImportMapsUnmappedUserOnly()
    var
        UserSetup: Record "User Setup";
        DemoRoleCenter: Codeunit "NBC Demo Role Center";
        MySalesperson: Code[20];
    begin
        // [GIVEN] the current user without a salesperson
        TestLibrary.Initialize();
        TestLibrary.CreateSalesperson();
        TestLibrary.SetCurrentUserSalesperson('');

        // [WHEN] the role-center seeder runs  [THEN] the user is mapped to a salesperson
        DemoRoleCenter.Import();
        UserSetup.Get(UserId());
        Assert.AreNotEqual('', UserSetup."Salespers./Purch. Code", 'Mapped salesperson');

        // [GIVEN] the user mapped to a specific salesperson
        MySalesperson := TestLibrary.CreateSalespersonForCurrentUser();

        // [WHEN] it runs again  [THEN] the existing mapping is kept
        DemoRoleCenter.Import();
        UserSetup.Get(UserId());
        Assert.AreEqual(MySalesperson, UserSetup."Salespers./Purch. Code", 'Existing mapping must be kept.');
    end;

    [Test]
    procedure Linkage_ImportIsIdempotent()
    var
        SalesHeader: Record "Sales Header";
        DemoOpportunity: Codeunit "NBC Demo Opportunity";
        DemoLinkage: Codeunit "NBC Demo Linkage";
        OrdersAfterFirst: Integer;
    begin
        // [GIVEN] the demo opportunities (the linkage seeder links its orders to NBC-OPP-001)
        TestLibrary.Initialize();
        DemoOpportunity.Import();

        // [WHEN] the linkage seeder runs twice
        DemoLinkage.Import();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        OrdersAfterFirst := SalesHeader.Count();
        DemoLinkage.Import();

        // [THEN] the second run creates no further orders
        Assert.AreEqual(OrdersAfterFirst, SalesHeader.Count(), 'Sales orders after the second run');
    end;

    [Test]
    procedure SeedAllIsIdempotent()
    var
        DemoDataMgt: Codeunit "NBC Demo Data Mgt.";
        TableIds: List of [Integer];
        CountsAfterFirst: Dictionary of [Integer, Integer];
        TableId: Integer;
    begin
        // [GIVEN] every table the demo seeders write to
        TestLibrary.Initialize();
        TableIds.Add(Database::"NBC CDS Team");
        TableIds.Add(Database::"NBC CDS Team Member");
        TableIds.Add(Database::"NBC CDS Activity");
        TableIds.Add(Database::Opportunity);
        TableIds.Add(Database::"NBC CRM Opp. Line");
        TableIds.Add(Database::"NBC CRM Opp. Competitor");
        TableIds.Add(Database::"NBC CRM Opp. Stakeholder");
        TableIds.Add(Database::"NBC CRM Process");
        TableIds.Add(Database::"NBC CRM Process Stage");
        TableIds.Add(Database::"NBC CRM Process State");
        TableIds.Add(Database::"NBC CRM Bundle");
        TableIds.Add(Database::"NBC CRM Bundle Line");
        TableIds.Add(Database::"NBC CRM Product Rel.");
        TableIds.Add(Database::"NBC CRM Discount List");
        TableIds.Add(Database::"NBC CRM Discount Tier");
        TableIds.Add(Database::Customer);
        TableIds.Add(Database::"Sales Header");
        TableIds.Add(Database::"Config. Package");

        // [WHEN] SeedAll runs once
        DemoDataMgt.SeedAll();
        foreach TableId in TableIds do
            CountsAfterFirst.Add(TableId, CountRows(TableId));

        // [WHEN] it runs a second time
        DemoDataMgt.SeedAll();

        // [THEN] no table gained rows
        foreach TableId in TableIds do
            Assert.AreEqual(CountsAfterFirst.Get(TableId), CountRows(TableId), StrSubstNo(RowsAfterSecondRunTok, TableId));
    end;

    local procedure CountRows(TableId: Integer): Integer
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(TableId);
        exit(RecRef.Count());
    end;
}
