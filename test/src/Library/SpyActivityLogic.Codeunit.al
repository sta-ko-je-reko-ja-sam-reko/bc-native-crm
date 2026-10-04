namespace NBC.Test;

using NBC.Dataverse.Activities;

/// <summary>Spy for the activity logic seam: records delegations and leaves the record untouched.</summary>
codeunit 69095 "NBC Spy Activity Logic" implements "NBC CDS IActivity"
{
    SingleInstance = true;

    var
        InsertCalls: Integer;
        StatusCalls: Integer;

    /// <summary>Clears the call counters.</summary>
    procedure Reset()
    begin
        InsertCalls := 0;
        StatusCalls := 0;
    end;

    /// <summary>Calls of Trigger_OnInsert since the last Reset.</summary>
    /// <returns>The call count.</returns>
    procedure InsertCallCount(): Integer
    begin
        exit(InsertCalls);
    end;

    /// <summary>Calls of Validate_Status since the last Reset.</summary>
    /// <returns>The call count.</returns>
    procedure StatusCallCount(): Integer
    begin
        exit(StatusCalls);
    end;

    procedure Trigger_OnInsert(var Activity: Record "NBC CDS Activity")
    begin
        InsertCalls += 1;
    end;

    procedure Validate_Status(var Activity: Record "NBC CDS Activity")
    begin
        StatusCalls += 1;
    end;
}
