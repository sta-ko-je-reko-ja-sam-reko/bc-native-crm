namespace NBC.Test;

using Microsoft.Sales.Customer;
using NBC.Dataverse.Activities;
using System.TestLibraries.Utilities;

/// <summary>
/// Activities and timeline (FEAT-ACT-001), DB-bound: insert defaults (date, creator, owner from User Setup),
/// completion through the service, the regarding link to a real Customer, and the logic-injection seam.
/// </summary>
codeunit 69011 "NBC CDS Activity Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";

    [Test]
    procedure InsertDefaultsDateCreatorAndOwner()
    var
        Activity: Record "NBC CDS Activity";
        SalespersonCode: Code[20];
        StartTime: DateTime;
    begin
        // [GIVEN] the current user mapped to a salesperson
        TestLibrary.Initialize();
        SalespersonCode := TestLibrary.CreateSalespersonForCurrentUser();
        StartTime := CurrentDateTime();

        // [WHEN] an activity is inserted with no date, creator or owner
        Activity.Init();
        Activity.Subject := 'Follow up';
        Activity.Insert(true);

        // [THEN] the insert trigger filled them in
        Activity.Get(Activity."Entry No.");
        Assert.IsTrue(Activity."Activity Date" >= StartTime, 'Activity date');
        Assert.AreEqual(UpperCase(CopyStr(UserId(), 1, MaxStrLen(Activity."Created By"))), Activity."Created By", 'Created by');
        Assert.AreEqual(Activity."Owner Type"::Salesperson, Activity."Owner Type", 'Owner type');
        Assert.AreEqual(SalespersonCode, Activity."Owner Code", 'Owner code');
    end;

    [Test]
    procedure InsertKeepsExplicitValues()
    var
        Activity: Record "NBC CDS Activity";
        TeamCode: Code[20];
        PlannedAt: DateTime;
    begin
        // [GIVEN] the current user mapped to a salesperson, and an activity with explicit date and team owner
        TestLibrary.Initialize();
        TestLibrary.CreateSalespersonForCurrentUser();
        TeamCode := TestLibrary.CreateTeam();
        PlannedAt := CreateDateTime(20300101D, 090000T);
        Activity.Init();
        Activity."Activity Date" := PlannedAt;
        Activity."Owner Type" := Activity."Owner Type"::Team;
        Activity."Owner Code" := TeamCode;

        // [WHEN] it is inserted
        Activity.Insert(true);

        // [THEN] the explicit values are kept
        Activity.Get(Activity."Entry No.");
        Assert.AreEqual(PlannedAt, Activity."Activity Date", 'Activity date');
        Assert.AreEqual(Activity."Owner Type"::Team, Activity."Owner Type", 'Owner type');
        Assert.AreEqual(TeamCode, Activity."Owner Code", 'Owner code');
    end;

    [Test]
    procedure InsertByUnmappedUserLeavesOwnerBlank()
    var
        Activity: Record "NBC CDS Activity";
    begin
        // [GIVEN] the current user has no salesperson
        TestLibrary.Initialize();
        TestLibrary.SetCurrentUserSalesperson('');

        // [WHEN] an activity is inserted
        Activity.Init();
        Activity.Insert(true);

        // [THEN] it has no owner
        Activity.Get(Activity."Entry No.");
        Assert.AreEqual('', Activity."Owner Code", 'Owner code');
    end;

    [Test]
    procedure CompleteActivityPersistsStatusAndClosedTime()
    var
        Activity: Record "NBC CDS Activity";
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
    begin
        // [GIVEN] an open activity
        TestLibrary.Initialize();
        Activity.Init();
        Activity.Insert(true);

        // [WHEN] it is completed through the service
        ActivityMgt.CompleteActivity(Activity);

        // [THEN] status and closed date-time are stored
        Activity.Get(Activity."Entry No.");
        Assert.AreEqual(Activity.Status::Completed, Activity.Status, 'Status');
        Assert.AreNotEqual(0DT, Activity."Closed DateTime", 'Closed date-time');
    end;

    [Test]
    procedure ActivityRegardingCustomerAppearsOnItsTimeline()
    var
        Customer: Record Customer;
        OtherCustomer: Record Customer;
        Activity: Record "NBC CDS Activity";
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
        Timeline: JsonArray;
    begin
        // [GIVEN] two customers, two activities regarding the first and one regarding the second
        TestLibrary.Initialize();
        TestLibrary.CreateCustomer(Customer);
        TestLibrary.CreateCustomer(OtherCustomer);
        InsertActivityRegarding(Database::Customer, Customer.SystemId, Customer.Name);
        InsertActivityRegarding(Database::Customer, Customer.SystemId, Customer.Name);
        InsertActivityRegarding(Database::Customer, OtherCustomer.SystemId, OtherCustomer.Name);

        // [WHEN] the timeline is built for the first customer (as the timeline part filters it)
        Activity.SetRange("Regarding Table No.", Database::Customer);
        Activity.SetRange("Regarding System ID", Customer.SystemId);
        Timeline.ReadFrom(ActivityMgt.BuildTimelineJson(Activity));

        // [THEN] only its two activities are shown
        Assert.AreEqual(2, Timeline.Count(), 'Timeline entries for the customer');
    end;

    [Test]
    procedure InsertDelegatesToInjectedLogic()
    var
        Activity: Record "NBC CDS Activity";
        SpyActivityLogic: Codeunit "NBC Spy Activity Logic";
    begin
        // [GIVEN] the spy logic injected, and the current user mapped to a salesperson
        TestLibrary.Initialize();
        TestLibrary.CreateSalespersonForCurrentUser();
        SpyActivityLogic.Reset();
        Activity.Define(SpyActivityLogic);

        // [WHEN] the activity is inserted
        Activity.Init();
        Activity.Insert(true);

        // [THEN] the spy ran instead of the default insert defaults
        Assert.AreEqual(1, SpyActivityLogic.InsertCallCount(), 'Trigger_OnInsert calls');
        Activity.Get(Activity."Entry No.");
        Assert.AreEqual('', Activity."Owner Code", 'The default owner defaulting must not run.');
    end;

    local procedure InsertActivityRegarding(TableNo: Integer; RegardingId: Guid; Description: Text)
    var
        Activity: Record "NBC CDS Activity";
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
    begin
        ActivityMgt.InitActivityForRecord(Activity, TableNo, RegardingId, Description);
        Activity.Insert(true);
    end;
}
