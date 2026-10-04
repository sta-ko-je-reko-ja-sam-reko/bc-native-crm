namespace NBC.Test;

using Microsoft.CRM.Opportunity;
using NBC.CRM.RoleCenter;
using NBC.Dataverse.Activities;
using System.TestLibraries.Utilities;

/// <summary>
/// CRM Role Center (FEAT-RC-001), DB-bound: the cue singleton is created on demand and its FlowFilters scope the
/// activity and opportunity cues to the current user's salesperson, with overdue = open and due before today.
/// </summary>
codeunit 69019 "NBC CRM Cue Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";

    [Test]
    procedure PrepareCueCreatesSingletonOnce()
    var
        Cue: Record "NBC CRM Cue";
        CueMgt: Codeunit "NBC CRM Cue Mgt.";
    begin
        // [GIVEN] no cue record
        TestLibrary.Initialize();
        Cue.DeleteAll();

        // [WHEN] the role center prepares the cue twice
        CueMgt.PrepareCue(Cue);
        CueMgt.PrepareCue(Cue);

        // [THEN] exactly one cue record exists
        Cue.Reset();
        Assert.RecordCount(Cue, 1);
    end;

    [Test]
    procedure CuesCountOnlyTheCurrentUsersWork()
    var
        Cue: Record "NBC CRM Cue";
        Baseline: Record "NBC CRM Cue";
        CueMgt: Codeunit "NBC CRM Cue Mgt.";
        MySalesperson: Code[20];
        Colleague: Code[20];
    begin
        // [GIVEN] the current user's salesperson and a colleague
        TestLibrary.Initialize();
        MySalesperson := TestLibrary.CreateSalespersonForCurrentUser();
        Colleague := TestLibrary.CreateSalesperson();
        CueMgt.PrepareCue(Baseline);
        Baseline.CalcFields("My Open Activities", "Overdue Activities", "My Opportunities", "Opportunities In Progress");

        // [GIVEN] for me: an open activity due in the future, an overdue open one, a completed overdue one, two opportunities
        InsertActivity(MySalesperson, CalcDate('<+5D>', Today()), false);
        InsertActivity(MySalesperson, CalcDate('<-3D>', Today()), false);
        InsertActivity(MySalesperson, CalcDate('<-3D>', Today()), true);
        TestLibrary.CreateOpportunity(MySalesperson);
        SetInProgress(TestLibrary.CreateOpportunity(MySalesperson));
        // [GIVEN] for the colleague: an overdue open activity and an opportunity
        InsertActivity(Colleague, CalcDate('<-3D>', Today()), false);
        TestLibrary.CreateOpportunity(Colleague);

        // [WHEN] the cue is prepared and calculated
        CueMgt.PrepareCue(Cue);
        Cue.CalcFields("My Open Activities", "Overdue Activities", "My Opportunities", "Opportunities In Progress");

        // [THEN] only my records count: 2 open, 1 overdue, 2 opportunities, 1 in progress
        Assert.AreEqual(Baseline."My Open Activities" + 2, Cue."My Open Activities", 'My open activities');
        Assert.AreEqual(Baseline."Overdue Activities" + 1, Cue."Overdue Activities", 'Overdue activities');
        Assert.AreEqual(Baseline."My Opportunities" + 2, Cue."My Opportunities", 'My opportunities');
        Assert.AreEqual(Baseline."Opportunities In Progress" + 1, Cue."Opportunities In Progress", 'Opportunities in progress');
    end;

    [Test]
    procedure ActivityDueTodayIsNotOverdue()
    var
        Cue: Record "NBC CRM Cue";
        CueMgt: Codeunit "NBC CRM Cue Mgt.";
        MySalesperson: Code[20];
    begin
        // [GIVEN] my only activity is open and due today
        TestLibrary.Initialize();
        MySalesperson := TestLibrary.CreateSalespersonForCurrentUser();
        InsertActivity(MySalesperson, Today(), false);

        // [WHEN] the cue is calculated
        CueMgt.PrepareCue(Cue);
        Cue.CalcFields("My Open Activities", "Overdue Activities");

        // [THEN] it is open but not overdue
        Assert.AreEqual(1, Cue."My Open Activities", 'My open activities');
        Assert.AreEqual(0, Cue."Overdue Activities", 'Overdue activities');
    end;

    local procedure InsertActivity(OwnerCode: Code[20]; DueDate: Date; Completed: Boolean)
    var
        Activity: Record "NBC CDS Activity";
    begin
        Activity.Init();
        Activity."Owner Type" := Activity."Owner Type"::Salesperson;
        Activity."Owner Code" := OwnerCode;
        Activity."Due Date" := DueDate;
        if Completed then
            Activity.Status := Activity.Status::Completed;
        Activity.Insert(true);
    end;

    local procedure SetInProgress(OpportunityNo: Code[20])
    var
        Opportunity: Record Opportunity;
    begin
        Opportunity.Get(OpportunityNo);
        Opportunity.Status := Opportunity.Status::"In Progress";
        Opportunity.Modify();
    end;
}
