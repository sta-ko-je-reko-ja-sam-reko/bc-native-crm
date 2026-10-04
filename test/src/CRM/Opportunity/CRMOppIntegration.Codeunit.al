namespace NBC.Test;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using NBC.CRM.Opportunity;
using NBC.Dataverse.Activities;
using System.TestLibraries.Utilities;

/// <summary>
/// Opportunity depth (FEAT-OPP-001), DB-bound: product/resource lines pull price and description from the catalog
/// master data, roll up into the estimated revenue FlowField, stakeholders resolve their contact, and the won/lost
/// outcome is logged as a completed activity regarding the opportunity (reusing FEAT-ACT-001).
/// </summary>
codeunit 69012 "NBC CRM Opp. Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";
        LibraryMarketing: Codeunit "Library - Marketing";
        RelatedRecordMissingTok: Label 'cannot be found in the related table', Locked = true;

    [Test]
    procedure ItemLinePullsDescriptionAndPrice()
    var
        OpportunityLine: Record "NBC CRM Opp. Line";
        ItemNo: Code[20];
    begin
        // [GIVEN] an item priced 120
        TestLibrary.Initialize();
        ItemNo := TestLibrary.CreateItem(120, 80);

        // [WHEN] an item line is given quantity 2 and then the item
        OpportunityLine.Type := OpportunityLine.Type::Item;
        OpportunityLine.Quantity := 2;
        OpportunityLine.Validate("No.", ItemNo);

        // [THEN] the line carries the item's price and description, amount = 240
        Assert.AreEqual(120, OpportunityLine."Unit Price", 'Unit price');
        Assert.AreNotEqual('', OpportunityLine.Description, 'Description');
        Assert.AreEqual(240, OpportunityLine."Line Amount", 'Line amount');
    end;

    [Test]
    procedure ResourceLinePullsNameAndPrice()
    var
        OpportunityLine: Record "NBC CRM Opp. Line";
        ResourceNo: Code[20];
    begin
        // [GIVEN] a resource priced 95
        TestLibrary.Initialize();
        ResourceNo := TestLibrary.CreateResource(95, 50);

        // [WHEN] a resource line for 8 hours is given the resource
        OpportunityLine.Type := OpportunityLine.Type::Resource;
        OpportunityLine.Quantity := 8;
        OpportunityLine.Validate("No.", ResourceNo);

        // [THEN] price, name and amount come from the resource
        Assert.AreEqual(95, OpportunityLine."Unit Price", 'Unit price');
        Assert.AreEqual(ResourceNo, OpportunityLine.Description, 'Description = resource name (the library names resources by their No.)');
        Assert.AreEqual(760, OpportunityLine."Line Amount", 'Line amount');
    end;

    [Test]
    procedure EstimatedRevenueRollsUpLineAmounts()
    var
        Opportunity: Record Opportunity;
        OpportunityNo: Code[20];
        OtherOpportunityNo: Code[20];
    begin
        // [GIVEN] an opportunity with two lines (300 + 450) and another opportunity with one line
        TestLibrary.Initialize();
        OpportunityNo := TestLibrary.CreateOpportunity('');
        OtherOpportunityNo := TestLibrary.CreateOpportunity('');
        InsertLine(OpportunityNo, 10000, 3, 100);
        InsertLine(OpportunityNo, 20000, 1, 450);
        InsertLine(OtherOpportunityNo, 10000, 1, 999);

        // [WHEN] the estimated revenue is calculated
        Opportunity.Get(OpportunityNo);
        Opportunity.CalcFields("NBC CRM Estimated Revenue");

        // [THEN] it is the sum of that opportunity's lines only
        Assert.AreEqual(750, Opportunity."NBC CRM Estimated Revenue", 'Estimated revenue');
    end;

    [Test]
    procedure EstimatedRevenueFollowsLineChanges()
    var
        Opportunity: Record Opportunity;
        OpportunityLine: Record "NBC CRM Opp. Line";
        OpportunityNo: Code[20];
    begin
        // [GIVEN] an opportunity with one line of 2 × 100
        TestLibrary.Initialize();
        OpportunityNo := TestLibrary.CreateOpportunity('');
        InsertLine(OpportunityNo, 10000, 2, 100);

        // [WHEN] the line quantity is raised to 5
        OpportunityLine.Get(OpportunityNo, 10000);
        OpportunityLine.Validate(Quantity, 5);
        OpportunityLine.Modify(true);

        // [THEN] the estimated revenue follows
        Opportunity.Get(OpportunityNo);
        Opportunity.CalcFields("NBC CRM Estimated Revenue");
        Assert.AreEqual(500, Opportunity."NBC CRM Estimated Revenue", 'Estimated revenue after the change');
    end;

    [Test]
    procedure OpportunityFromMarketingLibraryRollsUp()
    var
        Contact: Record Contact;
        Opportunity: Record Opportunity;
    begin
        // [GIVEN] a standard opportunity created the way the Marketing module does it (contact, salesperson, sales cycle)
        TestLibrary.Initialize();
        LibraryMarketing.CreateCompanyContact(Contact);
        LibraryMarketing.CreateOpportunity(Opportunity, Contact."No.");

        // [WHEN] an item line is added
        InsertLine(Opportunity."No.", 10000, 4, 25);

        // [THEN] the CRM revenue roll-up works on it
        Opportunity.CalcFields("NBC CRM Estimated Revenue");
        Assert.AreEqual(100, Opportunity."NBC CRM Estimated Revenue", 'Estimated revenue');
    end;

    [Test]
    procedure StakeholderShowsContactName()
    var
        Contact: Record Contact;
        Stakeholder: Record "NBC CRM Opp. Stakeholder";
        OpportunityNo: Code[20];
    begin
        // [GIVEN] a contact on an opportunity as decision maker
        TestLibrary.Initialize();
        LibraryMarketing.CreatePersonContact(Contact);
        OpportunityNo := TestLibrary.CreateOpportunity('');
        Stakeholder.Init();
        Stakeholder."Opportunity No." := OpportunityNo;
        Stakeholder."Contact No." := Contact."No.";
        Stakeholder.Role := Stakeholder.Role::"Decision Maker";
        Stakeholder.Insert(true);

        // [THEN] the stakeholder resolves the contact's name
        Stakeholder.CalcFields("Contact Name");
        Assert.AreEqual(Contact.Name, Stakeholder."Contact Name", 'Contact name');
    end;

    [Test]
    procedure StakeholderContactMustExist()
    var
        Stakeholder: Record "NBC CRM Opp. Stakeholder";
    begin
        // [WHEN] a non-existing contact is validated on a stakeholder
        TestLibrary.Initialize();
        asserterror Stakeholder.Validate("Contact No.", 'NBC-NO-SUCH-CT');

        // [THEN] the table relation rejects it
        Assert.ExpectedError(RelatedRecordMissingTok);
    end;

    [Test]
    procedure CompetitorsAreKeptPerOpportunity()
    var
        Competitor: Record "NBC CRM Opp. Competitor";
        OpportunityNo: Code[20];
    begin
        // [GIVEN] an opportunity with two competitors
        TestLibrary.Initialize();
        OpportunityNo := TestLibrary.CreateOpportunity('');
        InsertCompetitor(OpportunityNo, 10000, Competitor."Threat Level"::High);
        InsertCompetitor(OpportunityNo, 20000, Competitor."Threat Level"::Low);

        // [THEN] both are stored against the opportunity with their threat level
        Competitor.SetRange("Opportunity No.", OpportunityNo);
        Assert.RecordCount(Competitor, 2);
        Competitor.Get(OpportunityNo, 10000);
        Assert.AreEqual(Competitor."Threat Level"::High, Competitor."Threat Level", 'Threat level');
    end;

    [Test]
    procedure WonOutcomeLogsCompletedNote()
    begin
        VerifyOutcomeActivity(true, 'Opportunity won');
    end;

    [Test]
    procedure LostOutcomeLogsCompletedNote()
    begin
        VerifyOutcomeActivity(false, 'Opportunity lost');
    end;

    local procedure VerifyOutcomeActivity(Won: Boolean; ExpectedSubject: Text)
    var
        Opportunity: Record Opportunity;
        Activity: Record "NBC CDS Activity";
        OpportunityMgt: Codeunit "NBC CRM Opportunity Mgt.";
        OpportunityNo: Code[20];
    begin
        // [GIVEN] an opportunity
        TestLibrary.Initialize();
        OpportunityNo := TestLibrary.CreateOpportunity('');
        Opportunity.Get(OpportunityNo);

        // [WHEN] its outcome is logged
        OpportunityMgt.LogOutcomeActivity(Opportunity, Won);

        // [THEN] exactly one completed note regards the opportunity, with the outcome as subject
        Activity.SetRange("Regarding Table No.", Database::Opportunity);
        Activity.SetRange("Regarding System ID", Opportunity.SystemId);
        Assert.RecordCount(Activity, 1);
        Activity.FindFirst();
        Assert.AreEqual(Activity."Activity Type"::Note, Activity."Activity Type", 'Activity type');
        Assert.AreEqual(Activity.Status::Completed, Activity.Status, 'Status');
        Assert.AreEqual(ExpectedSubject, Activity.Subject, 'Subject');
        Assert.AreEqual(Opportunity.Description, Activity."Regarding Description", 'Regarding description');
        Assert.AreNotEqual(0DT, Activity."Closed DateTime", 'Closed date-time');
    end;

    local procedure InsertLine(OpportunityNo: Code[20]; LineNo: Integer; Quantity: Decimal; UnitPrice: Decimal)
    var
        OpportunityLine: Record "NBC CRM Opp. Line";
    begin
        OpportunityLine.Init();
        OpportunityLine."Opportunity No." := OpportunityNo;
        OpportunityLine."Line No." := LineNo;
        OpportunityLine.Type := OpportunityLine.Type::Comment;
        OpportunityLine.Validate(Quantity, Quantity);
        OpportunityLine.Validate("Unit Price", UnitPrice);
        OpportunityLine.Insert(true);
    end;

    local procedure InsertCompetitor(OpportunityNo: Code[20]; LineNo: Integer; ThreatLevel: Enum "NBC CRM Threat Level")
    var
        Competitor: Record "NBC CRM Opp. Competitor";
    begin
        Competitor.Init();
        Competitor."Opportunity No." := OpportunityNo;
        Competitor."Line No." := LineNo;
        Competitor.Name := 'Competitor';
        Competitor."Threat Level" := ThreatLevel;
        Competitor.Insert(true);
    end;
}
