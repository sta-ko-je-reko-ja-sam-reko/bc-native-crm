namespace NBC.Test;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Setup;
using Microsoft.Sales.Customer;
using NBC.Dataverse.PartyEnrichment;
using System.TestLibraries.Utilities;

/// <summary>
/// Party enrichment (FEAT-PTY-001), DB-bound: the account hierarchy, firmographic and consent fields on Customer
/// and Contact are stored and their table relations reject unknown parents / industries.
/// </summary>
codeunit 69020 "NBC CDS Party Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";
        LibraryUtility: Codeunit "Library - Utility";
        RelatedRecordMissingTok: Label 'cannot be found in the related table', Locked = true;

    [Test]
    procedure CustomerHierarchyAndFirmographicsAreStored()
    var
        Parent: Record Customer;
        Subsidiary: Record Customer;
        IndustryGroup: Record "Industry Group";
    begin
        // [GIVEN] a parent customer, an industry group and a subsidiary customer
        TestLibrary.Initialize();
        TestLibrary.CreateCustomer(Parent);
        TestLibrary.CreateCustomer(Subsidiary);
        IndustryGroup.Init();
        IndustryGroup.Code := LibraryUtility.GenerateRandomCode(IndustryGroup.FieldNo(Code), Database::"Industry Group");
        IndustryGroup.Insert(true);

        // [WHEN] the subsidiary is enriched
        Subsidiary.Validate("NBC CDS Parent Customer No.", Parent."No.");
        Subsidiary.Validate("NBC CDS Industry Group Code", IndustryGroup.Code);
        Subsidiary.Validate("NBC CDS Annual Revenue", 1250000);
        Subsidiary.Validate("NBC CDS No. of Employees", 42);
        Subsidiary.Validate("NBC CDS Contact Method", Subsidiary."NBC CDS Contact Method"::Phone);
        Subsidiary.Validate("NBC CDS Do Not Email", true);
        Subsidiary.Modify(true);

        // [THEN] the values are stored and the parent's subsidiaries can be found
        Subsidiary.Get(Subsidiary."No.");
        Assert.AreEqual(Parent."No.", Subsidiary."NBC CDS Parent Customer No.", 'Parent customer');
        Assert.AreEqual(IndustryGroup.Code, Subsidiary."NBC CDS Industry Group Code", 'Industry group');
        Assert.AreEqual(1250000, Subsidiary."NBC CDS Annual Revenue", 'Annual revenue');
        Assert.AreEqual(42, Subsidiary."NBC CDS No. of Employees", 'No. of employees');
        Assert.AreEqual(Subsidiary."NBC CDS Contact Method"::Phone, Subsidiary."NBC CDS Contact Method", 'Preferred contact method');
        Assert.IsTrue(Subsidiary."NBC CDS Do Not Email", 'Do not email');
        Subsidiary.Reset();
        Subsidiary.SetRange("NBC CDS Parent Customer No.", Parent."No.");
        Assert.RecordCount(Subsidiary, 1);
    end;

    [Test]
    procedure UnknownParentCustomerIsRejected()
    var
        Customer: Record Customer;
    begin
        // [GIVEN] a customer
        TestLibrary.Initialize();
        TestLibrary.CreateCustomer(Customer);

        // [WHEN] a non-existing parent is validated  [THEN] the table relation rejects it
        asserterror Customer.Validate("NBC CDS Parent Customer No.", 'NBC-NO-SUCH-CUST');
        Assert.ExpectedError(RelatedRecordMissingTok);
    end;

    [Test]
    procedure UnknownIndustryGroupIsRejected()
    var
        Customer: Record Customer;
    begin
        // [GIVEN] a customer
        TestLibrary.Initialize();
        TestLibrary.CreateCustomer(Customer);

        // [WHEN] a non-existing industry group is validated  [THEN] it is rejected
        asserterror Customer.Validate("NBC CDS Industry Group Code", 'NBC-NONE');
        Assert.ExpectedError(RelatedRecordMissingTok);
    end;

    [Test]
    procedure ContactConsentFlagsAreStored()
    var
        Contact: Record Contact;
        LibraryMarketing: Codeunit "Library - Marketing";
    begin
        // [GIVEN] a person contact
        TestLibrary.Initialize();
        LibraryMarketing.CreatePersonContact(Contact);

        // [WHEN] consent and preference are set
        Contact.Validate("NBC CDS Contact Method", Contact."NBC CDS Contact Method"::Email);
        Contact.Validate("NBC CDS Do Not Phone", true);
        Contact.Validate("NBC CDS Do Not Bulk Email", true);
        Contact.Modify(true);

        // [THEN] they are stored and selectable (e.g. to exclude from bulk email)
        Contact.Get(Contact."No.");
        Assert.AreEqual(Contact."NBC CDS Contact Method"::Email, Contact."NBC CDS Contact Method", 'Preferred contact method');
        Assert.IsTrue(Contact."NBC CDS Do Not Phone", 'Do not phone');
        Assert.IsFalse(Contact."NBC CDS Do Not Email", 'Do not email stays off');
        Contact.Reset();
        Contact.SetRange("No.", Contact."No.");
        Contact.SetRange("NBC CDS Do Not Bulk Email", false);
        Assert.RecordIsEmpty(Contact);
    end;
}
