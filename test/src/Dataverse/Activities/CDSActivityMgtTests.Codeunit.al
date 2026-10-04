namespace NBC.Test;

using NBC.Dataverse.Activities;
using System.TestLibraries.Utilities;

/// <summary>
/// Unit tests for the activity model (FEAT-ACT-001): the record-to-JSON timeline builder, activity
/// initialisation for a regarded record and the status validation — all on in-memory or temporary records.
/// </summary>
codeunit 69001 "NBC CDS Activity Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure BuildTimelineJson_OrdersNewestFirstWithFields()
    var
        TempActivity: Record "NBC CDS Activity" temporary;
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
        Activities: JsonArray;
        FirstToken: JsonToken;
        FirstObject: JsonObject;
        SubjectToken: JsonToken;
        JsonText: Text;
    begin
        // [GIVEN] two activities, older then newer
        AddTempActivity(TempActivity, 1, 'Older call', CreateDateTime(20250101D, 080000T));
        AddTempActivity(TempActivity, 2, 'Newer task', CreateDateTime(20250201D, 080000T));

        // [WHEN] building the timeline JSON
        JsonText := ActivityMgt.BuildTimelineJson(TempActivity);

        // [THEN] it is a 2-element array, newest first
        Assert.IsTrue(Activities.ReadFrom(JsonText), 'Result is not valid JSON.');
        Assert.AreEqual(2, Activities.Count(), 'Number of timeline entries');
        Activities.Get(0, FirstToken);
        FirstObject := FirstToken.AsObject();
        FirstObject.Get('subject', SubjectToken);
        Assert.AreEqual('Newer task', SubjectToken.AsValue().AsText(), 'Newest activity must come first.');
    end;

    [Test]
    procedure BuildTimelineJson_EmptySetReturnsEmptyArray()
    var
        TempActivity: Record "NBC CDS Activity" temporary;
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
    begin
        // [GIVEN] no activities  [WHEN] building JSON  [THEN] an empty array
        Assert.AreEqual('[]', ActivityMgt.BuildTimelineJson(TempActivity), 'Timeline of an empty set');
    end;

    [Test]
    procedure BuildTimelineJson_MapsEveryField()
    var
        TempActivity: Record "NBC CDS Activity" temporary;
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
        Activities: JsonArray;
        Token: JsonToken;
        Entry: JsonObject;
    begin
        // [GIVEN] a completed phone call owned by a salesperson
        AddTempActivity(TempActivity, 7, 'Call back', CreateDateTime(20250315D, 143000T));
        TempActivity."Activity Type" := TempActivity."Activity Type"::"Phone Call";
        TempActivity.Description := 'Discuss renewal';
        TempActivity."Owner Code" := 'SP01';
        TempActivity.Status := TempActivity.Status::Completed;
        TempActivity.Modify();

        // [WHEN] building the timeline JSON
        Activities.ReadFrom(ActivityMgt.BuildTimelineJson(TempActivity));
        Activities.Get(0, Token);
        Entry := Token.AsObject();

        // [THEN] every field the timeline control renders is present and formatted
        Assert.AreEqual('7', GetText(Entry, 'id'), 'id');
        Assert.AreEqual(Format(TempActivity."Activity Type"::"Phone Call"), GetText(Entry, 'type'), 'type');
        Assert.AreEqual('Call back', GetText(Entry, 'subject'), 'subject');
        Assert.AreEqual('Discuss renewal', GetText(Entry, 'description'), 'description');
        Assert.AreEqual('15.03.2025 14:30', GetText(Entry, 'date'), 'date');
        Assert.AreEqual('SP01', GetText(Entry, 'owner'), 'owner');
        Assert.AreEqual(Format(TempActivity.Status::Completed), GetText(Entry, 'status'), 'status');
    end;

    [Test]
    procedure BuildTimelineJson_TruncatesDescriptionAndBlanksMissingDate()
    var
        TempActivity: Record "NBC CDS Activity" temporary;
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
        Activities: JsonArray;
        Token: JsonToken;
        Entry: JsonObject;
    begin
        // [GIVEN] an undated activity with a 600-character description
        AddTempActivity(TempActivity, 1, 'Long note', 0DT);
        TempActivity.Description := CopyStr(PadStr('', 600, 'x'), 1, MaxStrLen(TempActivity.Description));
        TempActivity.Modify();

        // [WHEN] building the timeline JSON
        Activities.ReadFrom(ActivityMgt.BuildTimelineJson(TempActivity));
        Activities.Get(0, Token);
        Entry := Token.AsObject();

        // [THEN] the description is cut to 250 characters and the date is blank
        Assert.AreEqual(250, StrLen(GetText(Entry, 'description')), 'Description length');
        Assert.AreEqual('', GetText(Entry, 'date'), 'Date of an undated activity');
    end;

    [Test]
    procedure BuildTimelineJson_RespectsCallerFilter()
    var
        TempActivity: Record "NBC CDS Activity" temporary;
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
        Activities: JsonArray;
        RegardingId: Guid;
    begin
        // [GIVEN] three activities, two regarding the same record
        RegardingId := CreateGuid();
        AddTempActivity(TempActivity, 1, 'A', CreateDateTime(20250101D, 080000T));
        TempActivity."Regarding System ID" := RegardingId;
        TempActivity.Modify();
        AddTempActivity(TempActivity, 2, 'B', CreateDateTime(20250102D, 080000T));
        TempActivity."Regarding System ID" := RegardingId;
        TempActivity.Modify();
        AddTempActivity(TempActivity, 3, 'C', CreateDateTime(20250103D, 080000T));

        // [WHEN] building the timeline for that record only
        TempActivity.SetRange("Regarding System ID", RegardingId);
        Activities.ReadFrom(ActivityMgt.BuildTimelineJson(TempActivity));

        // [THEN] only its two activities are on the timeline
        Assert.AreEqual(2, Activities.Count(), 'Timeline entries for the regarded record');
    end;

    [Test]
    procedure InitActivityForRecord_PreparesRegardingTask()
    var
        Activity: Record "NBC CDS Activity";
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
        RegardingId: Guid;
        StartTime: DateTime;
    begin
        // [GIVEN] a record to regard
        RegardingId := CreateGuid();
        StartTime := CurrentDateTime();

        // [WHEN] initialising an activity for it
        ActivityMgt.InitActivityForRecord(Activity, Database::"NBC CDS Activity", RegardingId, PadStr('', 150, 'r'));

        // [THEN] it is a not-yet-inserted task regarding the record, dated now, with the description cut to fit
        Assert.AreEqual(Activity."Activity Type"::Task, Activity."Activity Type", 'Activity type');
        Assert.AreEqual(Database::"NBC CDS Activity", Activity."Regarding Table No.", 'Regarding table');
        Assert.AreEqual(RegardingId, Activity."Regarding System ID", 'Regarding record');
        Assert.AreEqual(MaxStrLen(Activity."Regarding Description"), StrLen(Activity."Regarding Description"), 'Regarding description length');
        Assert.IsTrue(Activity."Activity Date" >= StartTime, 'Activity date must be now.');
        Assert.AreEqual(0, Activity."Entry No.", 'The activity must not be inserted yet.');
    end;

    [Test]
    procedure CompletingActivityStampsClosedDateTime()
    var
        Activity: Record "NBC CDS Activity";
    begin
        // [GIVEN] an open activity (in memory)
        Activity.Status := Activity.Status::Open;

        // [WHEN] it is completed
        Activity.Validate(Status, Activity.Status::Completed);

        // [THEN] the closed date-time is stamped
        Assert.AreNotEqual(0DT, Activity."Closed DateTime", 'Closed date-time on completion');
    end;

    [Test]
    procedure CancelingActivityStampsClosedDateTime()
    var
        Activity: Record "NBC CDS Activity";
    begin
        // [WHEN] an open activity is canceled  [THEN] the closed date-time is stamped
        Activity.Validate(Status, Activity.Status::Canceled);
        Assert.AreNotEqual(0DT, Activity."Closed DateTime", 'Closed date-time on cancel');
    end;

    [Test]
    procedure ClosingAgainKeepsOriginalClosedDateTime()
    var
        Activity: Record "NBC CDS Activity";
        ClosedAt: DateTime;
    begin
        // [GIVEN] an activity closed at a known time
        ClosedAt := CreateDateTime(20240101D, 100000T);
        Activity."Closed DateTime" := ClosedAt;

        // [WHEN] it is completed (again)
        Activity.Validate(Status, Activity.Status::Completed);

        // [THEN] the original closed time is kept
        Assert.AreEqual(ClosedAt, Activity."Closed DateTime", 'Closed date-time must not move.');
    end;

    [Test]
    procedure ReopeningActivityClearsClosedDateTime()
    var
        Activity: Record "NBC CDS Activity";
    begin
        // [GIVEN] a completed activity
        Activity.Validate(Status, Activity.Status::Completed);

        // [WHEN] it is reopened
        Activity.Validate(Status, Activity.Status::Open);

        // [THEN] the closed date-time is cleared
        Assert.AreEqual(0DT, Activity."Closed DateTime", 'Closed date-time after reopening');
    end;

    [Test]
    procedure StatusValidationDelegatesToInjectedLogic()
    var
        Activity: Record "NBC CDS Activity";
        SpyActivityLogic: Codeunit "NBC Spy Activity Logic";
    begin
        // [GIVEN] the spy logic injected into an activity
        SpyActivityLogic.Reset();
        Activity.Define(SpyActivityLogic);

        // [WHEN] the status is validated
        Activity.Validate(Status, Activity.Status::Completed);

        // [THEN] the spy ran instead of the default (no closed date-time stamped)
        Assert.AreEqual(1, SpyActivityLogic.StatusCallCount(), 'Validate_Status calls');
        Assert.AreEqual(0DT, Activity."Closed DateTime", 'The default logic must not run.');
    end;

    local procedure AddTempActivity(var TempActivity: Record "NBC CDS Activity" temporary; EntryNo: Integer; Subject: Text; ActivityDate: DateTime)
    begin
        TempActivity.Init();
        TempActivity."Entry No." := EntryNo;
        TempActivity.Subject := CopyStr(Subject, 1, MaxStrLen(TempActivity.Subject));
        TempActivity."Activity Date" := ActivityDate;
        TempActivity.Insert();
    end;

    local procedure GetText(Entry: JsonObject; KeyName: Text): Text
    var
        Token: JsonToken;
    begin
        Entry.Get(KeyName, Token);
        exit(Token.AsValue().AsText());
    end;
}
