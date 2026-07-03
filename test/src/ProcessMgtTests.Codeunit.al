namespace NBC.Test;

using NBC.CRM.Process;

/// <summary>Unit tests for CRM Process Mgt. — pure stage-state classification (no DB).</summary>
codeunit 50903 "NBC CRM Process Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure ComputeStageState_ClassifiesRelativeToCurrent()
    var
        ProcessMgt: Codeunit "NBC CRM Process Mgt.";
    begin
        // current stage = 20
        AssertState(ProcessMgt.ComputeStageState(10, 20), 'done', 'earlier stage');
        AssertState(ProcessMgt.ComputeStageState(20, 20), 'current', 'current stage');
        AssertState(ProcessMgt.ComputeStageState(30, 20), 'todo', 'later stage');
    end;

    [Test]
    procedure ComputeStageState_NotStartedIsAllTodo()
    var
        ProcessMgt: Codeunit "NBC CRM Process Mgt.";
    begin
        // current stage = 0 (not started) → every stage is todo
        AssertState(ProcessMgt.ComputeStageState(10, 0), 'todo', 'not started');
    end;

    local procedure AssertState(Actual: Text; Expected: Text; Context: Text)
    begin
        if Actual <> Expected then
            Error('%1: expected ''%2'' but got ''%3''.', Context, Expected, Actual);
    end;
}
