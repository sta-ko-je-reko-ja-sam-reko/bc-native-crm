namespace NBC.Test;

using Microsoft.CRM.Opportunity;
using NBC.CRM.Process;
using System.TestLibraries.Utilities;

/// <summary>
/// Business process flow (FEAT-BPF-001), DB-bound: active-process resolution per table, lazy state creation at the
/// first stage, advancing / jumping / completing, the JSON the process bar renders, the default Lead-to-Opportunity
/// seed and the OnAfterAdvanceStage integration event. Uses a table number no real process is bound to.
/// </summary>
codeunit 69013 "NBC CRM Process Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";
        ProcessMgt: Codeunit "NBC CRM Process Mgt.";
        AdvanceEvents: Integer;

    [Test]
    procedure ActiveProcessIsFoundForItsTableOnly()
    var
        Process: Record "NBC CRM Process";
        ActiveCode: Code[20];
        TableNo: Integer;
    begin
        // [GIVEN] an inactive and an active process for the test table
        TableNo := Initialize();
        TestLibrary.CreateProcess(TableNo, false, Stages(10, 20, 0));
        ActiveCode := TestLibrary.CreateProcess(TableNo, true, Stages(10, 20, 0));

        // [THEN] the active one is resolved; another table has none
        Assert.IsTrue(ProcessMgt.FindActiveProcess(TableNo, Process), 'Active process');
        Assert.AreEqual(ActiveCode, Process.Code, 'Resolved process');
        Clear(Process);
        Assert.IsFalse(ProcessMgt.FindActiveProcess(TableNo + 1, Process), 'Process of an unbound table');
    end;

    [Test]
    procedure InactiveProcessIsIgnored()
    var
        Process: Record "NBC CRM Process";
        State: Record "NBC CRM Process State";
        TableNo: Integer;
    begin
        // [GIVEN] only an inactive process for the table
        TableNo := Initialize();
        TestLibrary.CreateProcess(TableNo, false, Stages(10, 20, 0));

        // [THEN] no active process and no state can be created
        Assert.IsFalse(ProcessMgt.FindActiveProcess(TableNo, Process), 'Inactive process must be ignored.');
        Assert.IsFalse(ProcessMgt.GetOrCreateState(TableNo, CreateGuid(), State), 'No state without an active process.');
    end;

    [Test]
    procedure StateIsCreatedLazilyAtFirstStage()
    var
        State: Record "NBC CRM Process State";
        ProcessCode: Code[20];
        RecId: Guid;
        TableNo: Integer;
    begin
        // [GIVEN] an active process with stages 30, 10, 20 (inserted out of order)
        TableNo := Initialize();
        ProcessCode := TestLibrary.CreateProcess(TableNo, true, Stages(30, 10, 20));
        RecId := CreateGuid();

        // [WHEN] the state of a record is requested for the first time
        Assert.IsTrue(ProcessMgt.GetOrCreateState(TableNo, RecId, State), 'GetOrCreateState');

        // [THEN] it is stored, started now, at the lowest stage
        Assert.IsTrue(State.Get(TableNo, RecId), 'The state must be stored.');
        Assert.AreEqual(ProcessCode, State."Process Code", 'Process code');
        Assert.AreEqual(10, State."Current Stage No.", 'First stage');
        Assert.AreNotEqual(0DT, State."Started DateTime", 'Started date-time');
    end;

    [Test]
    procedure ExistingStateIsReturnedUnchanged()
    var
        State: Record "NBC CRM Process State";
        RecId: Guid;
        TableNo: Integer;
    begin
        // [GIVEN] a record already at stage 20
        TableNo := Initialize();
        TestLibrary.CreateProcess(TableNo, true, Stages(10, 20, 30));
        RecId := CreateGuid();
        ProcessMgt.SetStage(TableNo, RecId, 20);

        // [WHEN] the state is requested again
        Clear(State);
        ProcessMgt.GetOrCreateState(TableNo, RecId, State);

        // [THEN] the existing state is returned, not reset
        Assert.AreEqual(20, State."Current Stage No.", 'Stage of an existing state');
        State.SetRange("Table No.", TableNo);
        Assert.RecordCount(State, 1);
    end;

    [Test]
    procedure FirstAndNextStageNumbers()
    var
        ProcessCode: Code[20];
        TableNo: Integer;
    begin
        // [GIVEN] a process with stages 10, 20, 40
        TableNo := Initialize();
        ProcessCode := TestLibrary.CreateProcess(TableNo, true, Stages(10, 20, 40));

        // [THEN] first = 10, next after 10 = 20, next after 20 = 40, after the last = 0
        Assert.AreEqual(10, ProcessMgt.FirstStageNo(ProcessCode), 'First stage');
        Assert.AreEqual(20, ProcessMgt.NextStageNo(ProcessCode, 10), 'Next after 10');
        Assert.AreEqual(40, ProcessMgt.NextStageNo(ProcessCode, 20), 'Next after 20');
        Assert.AreEqual(0, ProcessMgt.NextStageNo(ProcessCode, 40), 'Next after the last stage');
        Assert.AreEqual(0, ProcessMgt.FirstStageNo('NBC-NO-SUCH'), 'First stage of an unknown process');
    end;

    [Test]
    procedure AdvanceMovesThroughStagesAndCompletes()
    var
        State: Record "NBC CRM Process State";
        RecId: Guid;
        TableNo: Integer;
    begin
        // [GIVEN] a record in a three-stage process
        TableNo := Initialize();
        TestLibrary.CreateProcess(TableNo, true, Stages(10, 20, 30));
        RecId := CreateGuid();

        // [WHEN] it is advanced three times (the first advance creates the state at stage 10 and moves on)
        ProcessMgt.AdvanceStage(TableNo, RecId);
        State.Get(TableNo, RecId);
        Assert.AreEqual(20, State."Current Stage No.", 'After the first advance');
        Assert.AreEqual(0DT, State."Completed DateTime", 'Not completed yet');
        ProcessMgt.AdvanceStage(TableNo, RecId);
        State.Get(TableNo, RecId);
        Assert.AreEqual(30, State."Current Stage No.", 'After the second advance');
        ProcessMgt.AdvanceStage(TableNo, RecId);

        // [THEN] the final advance keeps the last stage and completes the process
        State.Get(TableNo, RecId);
        Assert.AreEqual(30, State."Current Stage No.", 'Stage after completion');
        Assert.AreNotEqual(0DT, State."Completed DateTime", 'Completed date-time');
    end;

    [Test]
    procedure AdvancingCompletedProcessKeepsCompletionTime()
    var
        State: Record "NBC CRM Process State";
        RecId: Guid;
        TableNo: Integer;
        CompletedAt: DateTime;
    begin
        // [GIVEN] a record that completed its process at a known time
        TableNo := Initialize();
        TestLibrary.CreateProcess(TableNo, true, Stages(10, 0, 0));
        RecId := CreateGuid();
        ProcessMgt.AdvanceStage(TableNo, RecId);
        CompletedAt := CreateDateTime(20240101D, 120000T);
        State.Get(TableNo, RecId);
        State."Completed DateTime" := CompletedAt;
        State.Modify();

        // [WHEN] it is advanced again
        ProcessMgt.AdvanceStage(TableNo, RecId);

        // [THEN] the completion time does not move
        State.Get(TableNo, RecId);
        Assert.AreEqual(CompletedAt, State."Completed DateTime", 'Completion time');
    end;

    [Test]
    procedure SetStageJumpsAndReopensCompletedProcess()
    var
        State: Record "NBC CRM Process State";
        RecId: Guid;
        TableNo: Integer;
    begin
        // [GIVEN] a completed two-stage process
        TableNo := Initialize();
        TestLibrary.CreateProcess(TableNo, true, Stages(10, 20, 0));
        RecId := CreateGuid();
        ProcessMgt.AdvanceStage(TableNo, RecId);
        ProcessMgt.AdvanceStage(TableNo, RecId);
        State.Get(TableNo, RecId);
        Assert.AreNotEqual(0DT, State."Completed DateTime", 'Precondition: completed');

        // [WHEN] the record is set back to stage 10
        ProcessMgt.SetStage(TableNo, RecId, 10);

        // [THEN] it is at stage 10 and no longer completed
        State.Get(TableNo, RecId);
        Assert.AreEqual(10, State."Current Stage No.", 'Stage');
        Assert.AreEqual(0DT, State."Completed DateTime", 'Completed date-time after reopening');
    end;

    [Test]
    procedure AdvanceWithoutActiveProcessDoesNothing()
    var
        State: Record "NBC CRM Process State";
        TableNo: Integer;
    begin
        // [GIVEN] no process for the table
        TableNo := Initialize();

        // [WHEN] a record is advanced or set
        ProcessMgt.AdvanceStage(TableNo, CreateGuid());
        ProcessMgt.SetStage(TableNo, CreateGuid(), 20);

        // [THEN] no state is created
        State.SetRange("Table No.", TableNo);
        Assert.RecordIsEmpty(State);
    end;

    [Test]
    procedure ProcessJsonDescribesStagesRelativeToCurrent()
    var
        Root: JsonObject;
        Token: JsonToken;
        StagesArray: JsonArray;
        ProcessCode: Code[20];
        RecId: Guid;
        TableNo: Integer;
    begin
        // [GIVEN] a record at stage 20 of a 10/20/30 process
        TableNo := Initialize();
        ProcessCode := TestLibrary.CreateProcess(TableNo, true, Stages(10, 20, 30));
        RecId := CreateGuid();
        ProcessMgt.SetStage(TableNo, RecId, 20);

        // [WHEN] the process bar JSON is built
        Assert.IsTrue(Root.ReadFrom(ProcessMgt.GetProcessJson(TableNo, RecId)), 'Valid JSON');

        // [THEN] it names the process, the current stage and each stage's state in order
        Root.Get('code', Token);
        Assert.AreEqual(ProcessCode, Token.AsValue().AsText(), 'code');
        Root.Get('currentStageNo', Token);
        Assert.AreEqual(20, Token.AsValue().AsInteger(), 'currentStageNo');
        Root.Get('stages', Token);
        StagesArray := Token.AsArray();
        Assert.AreEqual(3, StagesArray.Count(), 'Number of stages');
        Assert.AreEqual('done', StageState(StagesArray, 0), 'Stage 10');
        Assert.AreEqual('current', StageState(StagesArray, 1), 'Stage 20');
        Assert.AreEqual('todo', StageState(StagesArray, 2), 'Stage 30');
    end;

    [Test]
    procedure ProcessJsonForRecordWithoutStateIsAllTodo()
    var
        Root: JsonObject;
        Token: JsonToken;
        TableNo: Integer;
    begin
        // [GIVEN] an active process and a record that never started it
        TableNo := Initialize();
        TestLibrary.CreateProcess(TableNo, true, Stages(10, 20, 0));

        // [WHEN] the JSON is built
        Root.ReadFrom(ProcessMgt.GetProcessJson(TableNo, CreateGuid()));

        // [THEN] current stage is 0 and every stage is todo (no state is created by reading)
        Root.Get('currentStageNo', Token);
        Assert.AreEqual(0, Token.AsValue().AsInteger(), 'currentStageNo');
        Root.Get('stages', Token);
        Assert.AreEqual('todo', StageState(Token.AsArray(), 0), 'First stage');
    end;

    [Test]
    procedure ProcessJsonWithoutActiveProcessIsEmptyObject()
    var
        TableNo: Integer;
    begin
        // [GIVEN] no process for the table  [THEN] the control add-in gets an empty object
        TableNo := Initialize();
        Assert.AreEqual('{}', ProcessMgt.GetProcessJson(TableNo, CreateGuid()), 'JSON without a process');
    end;

    [Test]
    procedure DefaultOpportunityProcessIsSeededOnce()
    var
        Process: Record "NBC CRM Process";
        Stage: Record "NBC CRM Process Stage";
    begin
        // [GIVEN] no default process
        Initialize();
        if Process.Get('OPP-SALES') then begin
            Stage.SetRange("Process Code", 'OPP-SALES');
            Stage.DeleteAll();
            Process.Delete();
        end;

        // [WHEN] the default is ensured twice (install + upgrade)
        ProcessMgt.EnsureDefaultOpportunityProcess();
        ProcessMgt.EnsureDefaultOpportunityProcess();

        // [THEN] one active Opportunity process with the four standard stages exists
        Process.Get('OPP-SALES');
        Assert.AreEqual(Database::Opportunity, Process."Table No.", 'Table');
        Assert.IsTrue(Process.Active, 'Active');
        Stage.SetRange("Process Code", 'OPP-SALES');
        Assert.RecordCount(Stage, 4);
        Stage.FindFirst();
        Assert.AreEqual('Qualify', Stage.Name, 'First stage name');
        Stage.FindLast();
        Assert.AreEqual('Close', Stage.Name, 'Last stage name');
    end;

    [Test]
    procedure OpportunityFollowsTheDefaultProcess()
    var
        Opportunity: Record Opportunity;
        State: Record "NBC CRM Process State";
    begin
        // [GIVEN] the default process and an opportunity
        Initialize();
        ProcessMgt.EnsureDefaultOpportunityProcess();
        Opportunity.Get(TestLibrary.CreateOpportunity(''));

        // [WHEN] the opportunity is advanced once
        ProcessMgt.AdvanceStage(Database::Opportunity, Opportunity.SystemId);

        // [THEN] it moved from Qualify (10) to Develop (20)
        State.Get(Database::Opportunity, Opportunity.SystemId);
        Assert.AreEqual(20, State."Current Stage No.", 'Opportunity stage');
    end;

    [Test]
    procedure AdvanceAndSetRaiseIntegrationEvent()
    var
        Subscriber: Codeunit "NBC CRM Process Integration";
        RecId: Guid;
        TableNo: Integer;
    begin
        // [GIVEN] a bound subscriber and an active process
        TableNo := Initialize();
        TestLibrary.CreateProcess(TableNo, true, Stages(10, 20, 0));
        RecId := CreateGuid();
        BindSubscription(Subscriber);

        // [WHEN] the record is advanced and then set
        ProcessMgt.AdvanceStage(TableNo, RecId);
        ProcessMgt.SetStage(TableNo, RecId, 10);
        UnbindSubscription(Subscriber);

        // [THEN] OnAfterAdvanceStage fired for each
        Assert.AreEqual(2, Subscriber.AdvanceEventCount(), 'OnAfterAdvanceStage events');
    end;

    /// <summary>Number of OnAfterAdvanceStage events this (bound) instance received.</summary>
    /// <returns>The event count.</returns>
    procedure AdvanceEventCount(): Integer
    begin
        exit(AdvanceEvents);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NBC CRM Process Mgt.", OnAfterAdvanceStage, '', false, false)]
    local procedure CountOnAfterAdvanceStage(var ProcessState: Record "NBC CRM Process State")
    begin
        AdvanceEvents += 1;
    end;

    local procedure Initialize(): Integer
    begin
        TestLibrary.Initialize();
        TestLibrary.DeleteProcessesForTable(TestLibrary.ProcessTestTableNo());
        TestLibrary.DeleteProcessesForTable(TestLibrary.ProcessTestTableNo() + 1);
        exit(TestLibrary.ProcessTestTableNo());
    end;

    local procedure Stages(First: Integer; Second: Integer; Third: Integer) Result: List of [Integer]
    begin
        if First <> 0 then
            Result.Add(First);
        if Second <> 0 then
            Result.Add(Second);
        if Third <> 0 then
            Result.Add(Third);
    end;

    local procedure StageState(StagesArray: JsonArray; Index: Integer): Text
    var
        StageToken: JsonToken;
        StateToken: JsonToken;
    begin
        StagesArray.Get(Index, StageToken);
        StageToken.AsObject().Get('state', StateToken);
        exit(StateToken.AsValue().AsText());
    end;
}
