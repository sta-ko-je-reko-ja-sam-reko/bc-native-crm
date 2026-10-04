namespace NBC.Test;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.CRM.Opportunity;
using NBC.CRM.Process;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;
using NBC.Governance;
using System.Diagnostics;
using System.TestLibraries.Utilities;

/// <summary>
/// Governance (FEAT-GOV-001), DB-bound: enabling CRM audit logging activates the standard Change Log and registers
/// the CRM tables for all-field logging (idempotently), and duplicate detection finds customers / contacts that
/// share a name.
/// </summary>
codeunit 69018 "NBC Governance Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Any: Codeunit Any;
        NotRegisteredTok: Label 'Table %1 must be registered in the Change Log.', Locked = true;

    [Test]
    [HandlerFunctions('AuditEnabledMessageHandler')]
    procedure AuditLoggingActivatesChangeLogForCrmTables()
    var
        ChangeLogSetup: Record "Change Log Setup";
        AuditMgt: Codeunit "NBC Audit Mgt.";
    begin
        // [GIVEN] no Change Log setup and none of the CRM tables registered
        TestLibrary.Initialize();
        ChangeLogSetup.DeleteAll();
        UnregisterCrmTables();

        // [WHEN] CRM audit logging is enabled
        AuditMgt.EnableCrmAuditLogging();

        // [THEN] the Change Log is active and the four CRM tables log every field on insert/modify/delete
        ChangeLogSetup.FindFirst();
        Assert.IsTrue(ChangeLogSetup."Change Log Activated", 'Change Log activated');
        VerifyTableRegistered(Database::"NBC CDS Team");
        VerifyTableRegistered(Database::"NBC CDS Activity");
        VerifyTableRegistered(Database::"NBC CRM Opp. Line");
        VerifyTableRegistered(Database::"NBC CRM Process State");
    end;

    [Test]
    [HandlerFunctions('AuditEnabledMessageHandler')]
    procedure AuditLoggingIsIdempotentAndKeepsCustomSettings()
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
        AuditMgt: Codeunit "NBC Audit Mgt.";
    begin
        // [GIVEN] audit logging enabled once, then an admin narrows the team table to "Some Fields" on modify
        TestLibrary.Initialize();
        UnregisterCrmTables();
        AuditMgt.EnableCrmAuditLogging();
        ChangeLogSetupTable.Get(Database::"NBC CDS Team");
        ChangeLogSetupTable."Log Modification" := ChangeLogSetupTable."Log Modification"::"Some Fields";
        ChangeLogSetupTable.Modify();

        // [WHEN] it is enabled again
        AuditMgt.EnableCrmAuditLogging();

        // [THEN] no duplicates and the admin's choice is kept
        ChangeLogSetupTable.Get(Database::"NBC CDS Team");
        Assert.AreEqual(ChangeLogSetupTable."Log Modification"::"Some Fields", ChangeLogSetupTable."Log Modification", 'Customised table setting');
    end;

    [Test]
    [HandlerFunctions('CustomerListHandler')]
    procedure DuplicateCustomersAreShown()
    var
        FirstCustomer: Record Customer;
        SecondCustomer: Record Customer;
        DuplicateMgt: Codeunit "NBC Duplicate Mgt.";
        SharedName: Text[100];
    begin
        // [GIVEN] two customers sharing a unique name
        TestLibrary.Initialize();
        SharedName := CopyStr(Any.AlphanumericText(50), 1, MaxStrLen(SharedName));
        CreateNamedCustomer(FirstCustomer, SharedName);
        CreateNamedCustomer(SecondCustomer, SharedName);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(FirstCustomer."No.");
        LibraryVariableStorage.Enqueue(SecondCustomer."No.");

        // [WHEN] duplicate customers are searched
        DuplicateMgt.ShowDuplicateCustomers();

        // [THEN] the customer list opened on them (verified in the handler)
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NoDuplicatesMessageHandler')]
    procedure NoDuplicateCustomersGivesMessage()
    var
        Customer: Record Customer;
        DuplicateMgt: Codeunit "NBC Duplicate Mgt.";
    begin
        // [GIVEN] only customers with distinct names
        TestLibrary.Initialize();
        Customer.DeleteAll();
        CreateNamedCustomer(Customer, 'NBC Unique A');
        CreateNamedCustomer(Customer, 'NBC Unique B');

        // [WHEN] duplicates are searched  [THEN] a "no duplicates" message is shown (handler)
        DuplicateMgt.ShowDuplicateCustomers();
    end;

    [Test]
    [HandlerFunctions('ContactListHandler')]
    procedure DuplicateContactsAreShown()
    var
        FirstContact: Record Contact;
        SecondContact: Record Contact;
        DuplicateMgt: Codeunit "NBC Duplicate Mgt.";
        SharedName: Text[100];
    begin
        // [GIVEN] two contacts sharing a unique name
        TestLibrary.Initialize();
        SharedName := CopyStr(Any.AlphanumericText(50), 1, MaxStrLen(SharedName));
        CreateNamedContact(FirstContact, SharedName);
        CreateNamedContact(SecondContact, SharedName);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(FirstContact."No.");
        LibraryVariableStorage.Enqueue(SecondContact."No.");

        // [WHEN] duplicate contacts are searched
        DuplicateMgt.ShowDuplicateContacts();

        // [THEN] the contact list opened on them (verified in the handler)
        LibraryVariableStorage.AssertEmpty();
    end;

    [MessageHandler]
    procedure AuditEnabledMessageHandler(Message: Text[1024])
    begin
        Assert.ExpectedMessage('CRM audit logging is enabled', Message);
    end;

    [MessageHandler]
    procedure NoDuplicatesMessageHandler(Message: Text[1024])
    begin
        Assert.ExpectedMessage('No customers share the same name.', Message);
    end;

    [PageHandler]
    procedure CustomerListHandler(var CustomerList: TestPage "Customer List")
    begin
        Assert.IsTrue(CustomerList.GoToKey(LibraryVariableStorage.DequeueText()), 'First duplicate customer must be listed.');
        Assert.IsTrue(CustomerList.GoToKey(LibraryVariableStorage.DequeueText()), 'Second duplicate customer must be listed.');
    end;

    [PageHandler]
    procedure ContactListHandler(var ContactList: TestPage "Contact List")
    begin
        Assert.IsTrue(ContactList.GoToKey(LibraryVariableStorage.DequeueText()), 'First duplicate contact must be listed.');
        Assert.IsTrue(ContactList.GoToKey(LibraryVariableStorage.DequeueText()), 'Second duplicate contact must be listed.');
    end;

    local procedure CreateNamedCustomer(var Customer: Record Customer; CustomerName: Text[100])
    begin
        TestLibrary.CreateCustomer(Customer);
        Customer.Name := CustomerName;
        Customer.Modify();
    end;

    local procedure CreateNamedContact(var Contact: Record Contact; ContactName: Text[100])
    begin
        Contact.Init();
        Contact."No." := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(Contact."No."));
        Contact.Insert(true);
        Contact.Name := ContactName;
        Contact.Modify();
    end;

    local procedure UnregisterCrmTables()
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
    begin
        ChangeLogSetupTable.SetFilter("Table No.", '%1|%2|%3|%4',
            Database::"NBC CDS Team", Database::"NBC CDS Activity", Database::"NBC CRM Opp. Line", Database::"NBC CRM Process State");
        ChangeLogSetupTable.DeleteAll();
    end;

    local procedure VerifyTableRegistered(TableId: Integer)
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
    begin
        Assert.IsTrue(ChangeLogSetupTable.Get(TableId), StrSubstNo(NotRegisteredTok, TableId));
        Assert.AreEqual(ChangeLogSetupTable."Log Insertion"::"All Fields", ChangeLogSetupTable."Log Insertion", 'Log insertion');
        Assert.AreEqual(ChangeLogSetupTable."Log Modification"::"All Fields", ChangeLogSetupTable."Log Modification", 'Log modification');
        Assert.AreEqual(ChangeLogSetupTable."Log Deletion"::"All Fields", ChangeLogSetupTable."Log Deletion", 'Log deletion');
    end;
}
