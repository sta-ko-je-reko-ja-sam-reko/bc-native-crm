namespace NBC.Test;

using NBC.CRM.Catalog;

/// <summary>Spy for the bundle-line logic seam: records delegations without calculating anything.</summary>
codeunit 69097 "NBC Spy Bundle Logic" implements "NBC CRM IBundle"
{
    SingleInstance = true;

    var
        NoCalls: Integer;
        AmountCalls: Integer;

    /// <summary>Clears the call counters.</summary>
    procedure Reset()
    begin
        NoCalls := 0;
        AmountCalls := 0;
    end;

    /// <summary>Calls of Validate_No since the last Reset.</summary>
    /// <returns>The call count.</returns>
    procedure NoCallCount(): Integer
    begin
        exit(NoCalls);
    end;

    /// <summary>Calls of Validate_Amounts since the last Reset.</summary>
    /// <returns>The call count.</returns>
    procedure AmountCallCount(): Integer
    begin
        exit(AmountCalls);
    end;

    procedure Validate_No(var BundleLine: Record "NBC CRM Bundle Line")
    begin
        NoCalls += 1;
    end;

    procedure Validate_Amounts(var BundleLine: Record "NBC CRM Bundle Line")
    begin
        AmountCalls += 1;
    end;
}
