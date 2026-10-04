namespace NBC.Test;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Core;
using NBC.Dataverse.Ownership;
using NBC.Setup;
using System.TestLibraries.Utilities;

/// <summary>
/// Ownership and teams (FEAT-OWN-001), DB-bound: owner identity through User Setup, team membership and lead
/// rules, team delete cascade, the "my records" filter, and the default-owner stamp the Customer/Contact insert
/// subscribers apply through the Service Locator (feature toggle and access policy honoured).
/// </summary>
codeunit 69010 "NBC CDS Ownership Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";
        OwnerMgt: Codeunit "NBC CDS Owner Mgt.";
        Any: Codeunit Any;

    [Test]
    procedure CurrentUserSalespersonComesFromUserSetup()
    var
        SalespersonCode: Code[20];
    begin
        // [GIVEN] the current user mapped to a salesperson
        TestLibrary.Initialize();
        SalespersonCode := TestLibrary.CreateSalespersonForCurrentUser();

        // [THEN] the owner identity is that salesperson
        Assert.AreEqual(SalespersonCode, OwnerMgt.GetCurrentUserSalesperson(), 'Current user salesperson');
    end;

    [Test]
    procedure UserWithoutUserSetupHasNoSalesperson()
    var
        OwnerType: Enum "NBC CDS Owner Type";
        OwnerCode: Code[20];
    begin
        // [GIVEN] no User Setup for the current user
        TestLibrary.Initialize();
        TestLibrary.DeleteCurrentUserSetup();

        // [THEN] no salesperson and no default owner
        Assert.AreEqual('', OwnerMgt.GetCurrentUserSalesperson(), 'Salesperson of an unmapped user');
        Assert.IsFalse(OwnerMgt.GetDefaultOwner(OwnerType, OwnerCode), 'GetDefaultOwner must be false for an unmapped user.');
        Assert.AreEqual('', OwnerCode, 'Owner code of an unmapped user');
    end;

    [Test]
    procedure DefaultOwnerIsTheCurrentSalesperson()
    var
        OwnerType: Enum "NBC CDS Owner Type";
        OwnerCode: Code[20];
        SalespersonCode: Code[20];
    begin
        // [GIVEN] the current user mapped to a salesperson
        TestLibrary.Initialize();
        SalespersonCode := TestLibrary.CreateSalespersonForCurrentUser();

        // [WHEN] resolving the default owner
        Assert.IsTrue(OwnerMgt.GetDefaultOwner(OwnerType, OwnerCode), 'GetDefaultOwner');

        // [THEN] it is the salesperson, as a Salesperson owner
        Assert.AreEqual(OwnerType::Salesperson, OwnerType, 'Owner type');
        Assert.AreEqual(SalespersonCode, OwnerCode, 'Owner code');
    end;

    [Test]
    procedure TeamMembershipIsDetected()
    var
        TeamCode: Code[20];
        MemberCode: Code[20];
        OutsiderCode: Code[20];
    begin
        // [GIVEN] a team with one member
        TestLibrary.Initialize();
        TeamCode := TestLibrary.CreateTeam();
        MemberCode := TestLibrary.CreateSalesperson();
        OutsiderCode := TestLibrary.CreateSalesperson();
        TestLibrary.AddTeamMember(TeamCode, MemberCode);

        // [THEN] only the member is in the team
        Assert.IsTrue(OwnerMgt.IsSalespersonInTeam(TeamCode, MemberCode), 'Member');
        Assert.IsFalse(OwnerMgt.IsSalespersonInTeam(TeamCode, OutsiderCode), 'Outsider');
    end;

    [Test]
    procedure RecordOwnedDirectlyByCurrentUser()
    var
        OwnerType: Enum "NBC CDS Owner Type";
        SalespersonCode: Code[20];
    begin
        // [GIVEN] the current user is a salesperson
        TestLibrary.Initialize();
        SalespersonCode := TestLibrary.CreateSalespersonForCurrentUser();

        // [THEN] a record owned by that salesperson is "mine", one owned by another salesperson is not
        Assert.IsTrue(OwnerMgt.IsOwnedByCurrentUser(OwnerType::Salesperson, SalespersonCode), 'Own record');
        Assert.IsFalse(OwnerMgt.IsOwnedByCurrentUser(OwnerType::Salesperson, TestLibrary.CreateSalesperson()), 'Colleague record');
    end;

    [Test]
    procedure RecordOwnedThroughTeamMembership()
    var
        OwnerType: Enum "NBC CDS Owner Type";
        MyTeam: Code[20];
        OtherTeam: Code[20];
        SalespersonCode: Code[20];
    begin
        // [GIVEN] the current user's salesperson is in one team but not in another
        TestLibrary.Initialize();
        SalespersonCode := TestLibrary.CreateSalespersonForCurrentUser();
        MyTeam := TestLibrary.CreateTeam();
        OtherTeam := TestLibrary.CreateTeam();
        TestLibrary.AddTeamMember(MyTeam, SalespersonCode);

        // [THEN] records owned by the own team are "mine", by the other team are not
        Assert.IsTrue(OwnerMgt.IsOwnedByCurrentUser(OwnerType::Team, MyTeam), 'Own team');
        Assert.IsFalse(OwnerMgt.IsOwnedByCurrentUser(OwnerType::Team, OtherTeam), 'Other team');
    end;

    [Test]
    procedure UnmappedUserOwnsNothing()
    var
        OwnerType: Enum "NBC CDS Owner Type";
    begin
        // [GIVEN] the current user has no salesperson
        TestLibrary.Initialize();
        TestLibrary.SetCurrentUserSalesperson('');

        // [THEN] even a blank owner is not "mine"
        Assert.IsFalse(OwnerMgt.IsOwnedByCurrentUser(OwnerType::Salesperson, ''), 'Blank owner');
    end;

    [Test]
    procedure MyOwnerCodeFilterCoversSalespersonAndTeams()
    var
        Customer: Record Customer;
        SalespersonCode: Code[20];
        TeamCode: Code[20];
        OwnFilter: Text;
    begin
        // [GIVEN] the current user's salesperson in a team
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Ownership, false);
        SalespersonCode := TestLibrary.CreateSalespersonForCurrentUser();
        TeamCode := TestLibrary.CreateTeam();
        TestLibrary.AddTeamMember(TeamCode, SalespersonCode);

        // [WHEN] building the "my records" filter
        OwnFilter := OwnerMgt.GetMyOwnerCodeFilter();

        // [THEN] it is salesperson|team and selects a team-owned customer
        Assert.AreEqual(SalespersonCode + '|' + TeamCode, OwnFilter, 'My owner code filter');
        TestLibrary.CreateCustomer(Customer);
        Customer."NBC CDS Owner Type" := Customer."NBC CDS Owner Type"::Team;
        Customer."NBC CDS Owner Code" := TeamCode;
        Customer.Modify();
        Customer.Reset();
        Customer.SetFilter("NBC CDS Owner Code", OwnFilter);
        Assert.RecordCount(Customer, 1);
    end;

    [Test]
    procedure DeletingTeamDeletesItsMembers()
    var
        Team: Record "NBC CDS Team";
        TeamMember: Record "NBC CDS Team Member";
        TeamCode: Code[20];
        OtherTeamCode: Code[20];
    begin
        // [GIVEN] two teams with members
        TestLibrary.Initialize();
        TeamCode := TestLibrary.CreateTeam();
        OtherTeamCode := TestLibrary.CreateTeam();
        TestLibrary.AddTeamMember(TeamCode, TestLibrary.CreateSalesperson());
        TestLibrary.AddTeamMember(TeamCode, TestLibrary.CreateSalesperson());
        TestLibrary.AddTeamMember(OtherTeamCode, TestLibrary.CreateSalesperson());

        // [WHEN] the first team is deleted
        Team.Get(TeamCode);
        Team.Delete(true);

        // [THEN] its members are gone, the other team's member stays
        TeamMember.SetRange("Team Code", TeamCode);
        Assert.RecordIsEmpty(TeamMember);
        TeamMember.SetRange("Team Code", OtherTeamCode);
        Assert.RecordCount(TeamMember, 1);
    end;

    [Test]
    procedure MemberCountFlowFieldCountsMembers()
    var
        Team: Record "NBC CDS Team";
        TeamCode: Code[20];
    begin
        // [GIVEN] a team with three members
        TestLibrary.Initialize();
        TeamCode := TestLibrary.CreateTeam();
        TestLibrary.AddTeamMember(TeamCode, TestLibrary.CreateSalesperson());
        TestLibrary.AddTeamMember(TeamCode, TestLibrary.CreateSalesperson());
        TestLibrary.AddTeamMember(TeamCode, TestLibrary.CreateSalesperson());

        // [THEN] Member Count = 3
        Team.Get(TeamCode);
        Team.CalcFields("Member Count");
        Assert.AreEqual(3, Team."Member Count", 'Member Count');
    end;

    [Test]
    procedure TeamLeadIsUniqueAndShownOnTeam()
    var
        Team: Record "NBC CDS Team";
        TeamMember: Record "NBC CDS Team Member";
        TeamCode: Code[20];
        FirstLead: Code[20];
        SecondLead: Code[20];
    begin
        // [GIVEN] a team with two members, the first one the lead
        TestLibrary.Initialize();
        TeamCode := TestLibrary.CreateTeam();
        FirstLead := TestLibrary.CreateSalesperson();
        SecondLead := TestLibrary.CreateSalesperson();
        TestLibrary.AddTeamMember(TeamCode, FirstLead);
        TestLibrary.AddTeamMember(TeamCode, SecondLead);
        SetTeamLead(TeamCode, FirstLead);

        // [WHEN] the second member becomes lead
        SetTeamLead(TeamCode, SecondLead);

        // [THEN] only the second member is lead, and the team header shows them
        TeamMember.Get(TeamCode, FirstLead);
        Assert.IsFalse(TeamMember."Team Lead", 'The previous lead must be cleared.');
        TeamMember.Get(TeamCode, SecondLead);
        Assert.IsTrue(TeamMember."Team Lead", 'The new lead must be set.');
        Team.Get(TeamCode);
        Assert.AreEqual(SecondLead, Team."Team Lead Salesp. Code", 'Team lead on the header');
    end;

    [Test]
    procedure ClearingTeamLeadKeepsHeader()
    var
        Team: Record "NBC CDS Team";
        TeamMember: Record "NBC CDS Team Member";
        TeamCode: Code[20];
        LeadCode: Code[20];
    begin
        // [GIVEN] a team whose lead is set
        TestLibrary.Initialize();
        TeamCode := TestLibrary.CreateTeam();
        LeadCode := TestLibrary.CreateSalesperson();
        TestLibrary.AddTeamMember(TeamCode, LeadCode);
        SetTeamLead(TeamCode, LeadCode);

        // [WHEN] the lead flag is removed
        TeamMember.Get(TeamCode, LeadCode);
        TeamMember.Validate("Team Lead", false);
        TeamMember.Modify(true);

        // [THEN] the validation does nothing else (header unchanged)
        Team.Get(TeamCode);
        Assert.AreEqual(LeadCode, Team."Team Lead Salesp. Code", 'Header lead after clearing the flag');
    end;

    [Test]
    procedure TeamTablesDelegateToInjectedLogic()
    var
        Team: Record "NBC CDS Team";
        TeamMember: Record "NBC CDS Team Member";
        SpyTeamLogic: Codeunit "NBC Spy Team Logic";
        TeamCode: Code[20];
        SalespersonCode: Code[20];
    begin
        // [GIVEN] a team and a member, both with the spy logic injected
        TestLibrary.Initialize();
        SpyTeamLogic.Reset();
        TeamCode := TestLibrary.CreateTeam();
        SalespersonCode := TestLibrary.CreateSalesperson();
        TeamMember.Define(SpyTeamLogic);
        TeamMember.Init();
        TeamMember."Team Code" := TeamCode;
        TeamMember."Salesperson Code" := SalespersonCode;

        // [WHEN] the member is inserted, made lead, and the team is deleted
        TeamMember.Insert(true);
        TeamMember.Validate("Team Lead", true);
        Team.Get(TeamCode);
        Team.Define(SpyTeamLogic);
        Team.Delete(true);

        // [THEN] every trigger reached the injected logic once, and the default cascade did not run
        Assert.AreEqual(1, SpyTeamLogic.InsertMemberCallCount(), 'Insert member');
        Assert.AreEqual(1, SpyTeamLogic.TeamLeadCallCount(), 'Team lead');
        Assert.AreEqual(1, SpyTeamLogic.DeleteCallCount(), 'Delete team');
        Assert.IsTrue(TeamMember.Get(TeamCode, SalespersonCode), 'The spy replaces the default cascade delete.');
    end;

    [Test]
    procedure NewCustomerGetsCurrentUserAsOwner()
    var
        Customer: Record Customer;
        SalespersonCode: Code[20];
    begin
        // [GIVEN] Ownership enabled and the current user mapped to a salesperson
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Ownership, true);
        SalespersonCode := TestLibrary.CreateSalespersonForCurrentUser();

        // [WHEN] a customer is created
        TestLibrary.CreateCustomer(Customer);

        // [THEN] the insert subscriber stamped the salesperson as owner
        Customer.Get(Customer."No.");
        Assert.AreEqual(Customer."NBC CDS Owner Type"::Salesperson, Customer."NBC CDS Owner Type", 'Owner type');
        Assert.AreEqual(SalespersonCode, Customer."NBC CDS Owner Code", 'Owner code');
    end;

    [Test]
    procedure NewContactGetsCurrentUserAsOwner()
    var
        Contact: Record Contact;
        SalespersonCode: Code[20];
    begin
        // [GIVEN] Ownership enabled and the current user mapped to a salesperson
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Ownership, true);
        SalespersonCode := TestLibrary.CreateSalespersonForCurrentUser();

        // [WHEN] a contact is created
        Contact.Init();
        Contact."No." := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(Contact."No."));
        Contact.Insert(true);

        // [THEN] the insert subscriber stamped the salesperson as owner
        Contact.Get(Contact."No.");
        Assert.AreEqual(SalespersonCode, Contact."NBC CDS Owner Code", 'Owner code');
    end;

    [Test]
    procedure NoOwnerStampWhenOwnershipDisabled()
    var
        Customer: Record Customer;
    begin
        // [GIVEN] Ownership disabled, the user mapped to a salesperson
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Ownership, false);
        TestLibrary.CreateSalespersonForCurrentUser();

        // [WHEN] a customer is created
        TestLibrary.CreateCustomer(Customer);

        // [THEN] it stays unowned
        Customer.Get(Customer."No.");
        Assert.AreEqual('', Customer."NBC CDS Owner Code", 'Owner of a customer created while ownership is disabled');
    end;

    [Test]
    procedure NoOwnerStampForUnentitledUser()
    var
        Customer: Record Customer;
    begin
        // [GIVEN] Ownership enabled, but the user is not entitled (effective-permission check fails)
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Ownership, true);
        TestLibrary.CreateSalespersonForCurrentUser();
        TestLibrary.SetAccessGranted(false);

        // [WHEN] a customer is created
        TestLibrary.CreateCustomer(Customer);
        TestLibrary.SetAccessGranted(true);

        // [THEN] it stays unowned
        Customer.Get(Customer."No.");
        Assert.AreEqual('', Customer."NBC CDS Owner Code", 'Owner of a customer created by an unentitled user');
    end;

    [Test]
    procedure ExplicitOwnerIsNotOverwritten()
    var
        Customer: Record Customer;
        TeamCode: Code[20];
    begin
        // [GIVEN] Ownership enabled and the user mapped to a salesperson
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Ownership, true);
        TestLibrary.CreateSalespersonForCurrentUser();
        TeamCode := TestLibrary.CreateTeam();

        // [WHEN] a customer is created with an explicit team owner
        Customer.Init();
        Customer."No." := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(Customer."No."));
        Customer."NBC CDS Owner Type" := Customer."NBC CDS Owner Type"::Team;
        Customer."NBC CDS Owner Code" := TeamCode;
        Customer.Insert(true);

        // [THEN] the explicit owner is kept
        Customer.Get(Customer."No.");
        Assert.AreEqual(Customer."NBC CDS Owner Type"::Team, Customer."NBC CDS Owner Type", 'Owner type');
        Assert.AreEqual(TeamCode, Customer."NBC CDS Owner Code", 'Owner code');
    end;

    [Test]
    procedure NoOwnerStampWhenUserUnmapped()
    var
        Customer: Record Customer;
    begin
        // [GIVEN] Ownership enabled, the user has no salesperson
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Ownership, true);
        TestLibrary.SetCurrentUserSalesperson('');

        // [WHEN] a customer is created
        TestLibrary.CreateCustomer(Customer);

        // [THEN] it stays unowned
        Customer.Get(Customer."No.");
        Assert.AreEqual('', Customer."NBC CDS Owner Code", 'Owner of a customer created by an unmapped user');
    end;

    [Test]
    procedure TemporaryCustomerIsNeverStamped()
    var
        TempCustomer: Record Customer temporary;
        OwnerReactions: Codeunit "NBC CDS Owner Reactions";
    begin
        // [GIVEN] Ownership enabled, the user mapped, and a temporary customer
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Ownership, true);
        TestLibrary.CreateSalespersonForCurrentUser();
        TempCustomer."No." := 'TEMP';
        TempCustomer.Insert();

        // [WHEN] the reaction runs on it
        OwnerReactions.OnInsertCustomer(TempCustomer);

        // [THEN] buffers are left alone
        Assert.AreEqual('', TempCustomer."NBC CDS Owner Code", 'Owner of a temporary customer');
    end;

    [Test]
    procedure InsertSubscribersDelegateToInjectedReactions()
    var
        Customer: Record Customer;
        Contact: Record Contact;
        SpyOwnerReactions: Codeunit "NBC Spy Owner Reactions";
        ServiceLocator: Codeunit "NBC Service Locator";
    begin
        // [GIVEN] the spy reactions injected into the Service Locator
        TestLibrary.Initialize();
        SpyOwnerReactions.Reset();
        ServiceLocator.ImplementOwnerReactions(SpyOwnerReactions);

        // [WHEN] a customer and a contact are inserted
        TestLibrary.CreateCustomer(Customer);
        Contact.Init();
        Contact."No." := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(Contact."No."));
        Contact.Insert(true);
        TestLibrary.RestoreDefaultReactions();

        // [THEN] each subscriber delegated to the injected reactions
        Assert.IsTrue(SpyOwnerReactions.CustomerCallCount() >= 1, 'The customer insert must reach the injected reactions.');
        Assert.IsTrue(SpyOwnerReactions.ContactCallCount() >= 1, 'The contact insert must reach the injected reactions.');
    end;

    [Test]
    procedure SubscribersSkipUnentitledUsers()
    var
        Customer: Record Customer;
        SpyOwnerReactions: Codeunit "NBC Spy Owner Reactions";
        ServiceLocator: Codeunit "NBC Service Locator";
    begin
        // [GIVEN] the spy reactions injected, and an access policy that denies the user
        TestLibrary.Initialize();
        SpyOwnerReactions.Reset();
        ServiceLocator.ImplementOwnerReactions(SpyOwnerReactions);
        TestLibrary.SetAccessGranted(false);

        // [WHEN] a customer is inserted
        TestLibrary.CreateCustomer(Customer);
        TestLibrary.Initialize();

        // [THEN] the reaction never ran
        Assert.AreEqual(0, SpyOwnerReactions.CustomerCallCount(), 'An unentitled user must not reach the reactions.');
    end;

    local procedure SetTeamLead(TeamCode: Code[20]; SalespersonCode: Code[20])
    var
        TeamMember: Record "NBC CDS Team Member";
    begin
        TeamMember.Get(TeamCode, SalespersonCode);
        TeamMember.Validate("Team Lead", true);
        TeamMember.Modify(true);
    end;
}
