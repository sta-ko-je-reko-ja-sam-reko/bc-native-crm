namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;

/// <summary>
/// CRM business-process-flow service: resolve the active process for a table, track and advance a
/// record's stage (lazy state creation), and build the JSON the process-bar control add-in renders.
/// </summary>
codeunit 50060 "NBC CRM Process Mgt."
{
    Access = Public;

    /// <summary>The active process for a table, if any.</summary>
    procedure FindActiveProcess(TableNo: Integer; var Process: Record "NBC CRM Process"): Boolean
    begin
        Process.SetRange("Table No.", TableNo);
        Process.SetRange(Active, true);
        exit(Process.FindFirst());
    end;

    /// <summary>Get the record's state, creating it at the first stage if the table has an active process.</summary>
    procedure GetOrCreateState(TableNo: Integer; RecId: Guid; var State: Record "NBC CRM Process State"): Boolean
    var
        Process: Record "NBC CRM Process";
    begin
        if State.Get(TableNo, RecId) then
            exit(true);
        if not FindActiveProcess(TableNo, Process) then
            exit(false);
        State.Init();
        State."Table No." := TableNo;
        State."Record System ID" := RecId;
        State."Process Code" := Process.Code;
        State."Current Stage No." := FirstStageNo(Process.Code);
        State."Started DateTime" := CurrentDateTime();
        State.Insert(true);
        exit(true);
    end;

    procedure FirstStageNo(ProcessCode: Code[20]): Integer
    var
        Stage: Record "NBC CRM Process Stage";
    begin
        Stage.SetRange("Process Code", ProcessCode);
        if Stage.FindFirst() then
            exit(Stage."Stage No.");
        exit(0);
    end;

    procedure NextStageNo(ProcessCode: Code[20]; CurrentStageNo: Integer): Integer
    var
        Stage: Record "NBC CRM Process Stage";
    begin
        Stage.SetRange("Process Code", ProcessCode);
        Stage.SetFilter("Stage No.", '>%1', CurrentStageNo);
        if Stage.FindFirst() then
            exit(Stage."Stage No.");
        exit(0);
    end;

    /// <summary>Advance the record to the next stage; the final advance completes the process.</summary>
    procedure AdvanceStage(TableNo: Integer; RecId: Guid)
    var
        State: Record "NBC CRM Process State";
        NextNo: Integer;
    begin
        if not GetOrCreateState(TableNo, RecId, State) then
            exit;
        NextNo := NextStageNo(State."Process Code", State."Current Stage No.");
        if NextNo = 0 then begin
            if State."Completed DateTime" = 0DT then
                State."Completed DateTime" := CurrentDateTime();
        end else
            State."Current Stage No." := NextNo;
        State.Modify(true);
        OnAfterAdvanceStage(State);
    end;

    /// <summary>Jump the record to a specific stage.</summary>
    procedure SetStage(TableNo: Integer; RecId: Guid; StageNo: Integer)
    var
        State: Record "NBC CRM Process State";
    begin
        if not GetOrCreateState(TableNo, RecId, State) then
            exit;
        State."Current Stage No." := StageNo;
        if State."Completed DateTime" <> 0DT then
            Clear(State."Completed DateTime");
        State.Modify(true);
        OnAfterAdvanceStage(State);
    end;

    /// <summary>Definition + current stage of the record's active process, as JSON for the control add-in.</summary>
    procedure GetProcessJson(TableNo: Integer; RecId: Guid): Text
    var
        Process: Record "NBC CRM Process";
        Stage: Record "NBC CRM Process Stage";
        State: Record "NBC CRM Process State";
        Root: JsonObject;
        Stages: JsonArray;
        StageObj: JsonObject;
        CurrentStageNo: Integer;
        ResultText: Text;
    begin
        if not FindActiveProcess(TableNo, Process) then
            exit('{}');
        if State.Get(TableNo, RecId) then
            CurrentStageNo := State."Current Stage No.";

        Root.Add('code', Process.Code);
        Root.Add('name', Process.Name);
        Root.Add('currentStageNo', CurrentStageNo);

        Stage.SetRange("Process Code", Process.Code);
        if Stage.FindSet() then
            repeat
                Clear(StageObj);
                StageObj.Add('no', Stage."Stage No.");
                StageObj.Add('name', Stage.Name);
                StageObj.Add('state', ComputeStageState(Stage."Stage No.", CurrentStageNo));
                Stages.Add(StageObj);
            until Stage.Next() = 0;
        Root.Add('stages', Stages);
        Root.WriteTo(ResultText);
        exit(ResultText);
    end;

    /// <summary>Pure: classify a stage relative to the current stage (done / current / todo).</summary>
    procedure ComputeStageState(StageNo: Integer; CurrentStageNo: Integer): Text
    begin
        if (CurrentStageNo = 0) or (StageNo > CurrentStageNo) then
            exit('todo');
        if StageNo = CurrentStageNo then
            exit('current');
        exit('done');
    end;

    /// <summary>Seed the default Lead-to-Opportunity process (idempotent — safe on install/upgrade).</summary>
    procedure EnsureDefaultOpportunityProcess()
    var
        Process: Record "NBC CRM Process";
    begin
        if Process.Get('OPP-SALES') then
            exit;
        Process.Init();
        Process.Code := 'OPP-SALES';
        Process.Name := 'Lead to Opportunity';
        Process."Table No." := Database::Opportunity;
        Process.Active := true;
        Process.Insert();
        InsertStage('OPP-SALES', 10, 'Qualify');
        InsertStage('OPP-SALES', 20, 'Develop');
        InsertStage('OPP-SALES', 30, 'Propose');
        InsertStage('OPP-SALES', 40, 'Close');
    end;

    local procedure InsertStage(ProcessCode: Code[20]; StageNo: Integer; StageName: Text)
    var
        Stage: Record "NBC CRM Process Stage";
    begin
        Stage.Init();
        Stage."Process Code" := ProcessCode;
        Stage."Stage No." := StageNo;
        Stage.Name := CopyStr(StageName, 1, MaxStrLen(Stage.Name));
        Stage.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAdvanceStage(var ProcessState: Record "NBC CRM Process State")
    begin
    end;
}
