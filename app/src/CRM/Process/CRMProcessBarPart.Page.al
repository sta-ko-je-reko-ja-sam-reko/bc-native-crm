namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;

/// <summary>
/// Host for the CRM Process Bar control add-in. Bound to CRM Process State and filtered to the host
/// record by SubPageLink; reads the host identity from the applied filter range (so it works even
/// before a state row exists) and renders / drives the process bar.
/// </summary>
page 50063 "NBC CRM Process Bar Part"
{
    PageType = CardPart;
    ApplicationArea = NBCProcess;
    SourceTable = "NBC CRM Process State";
    Caption = 'Process';

    layout
    {
        area(Content)
        {
            usercontrol(ProcessBar; "NBC CRM Process Bar")
            {
                ApplicationArea = NBCProcess;

                trigger ControlReady()
                begin
                    IsReady := true;
                    RenderBar();
                end;

                trigger StageClicked(StageNo: Text)
                var
                    ProcessMgt: Codeunit "NBC CRM Process Mgt.";
                    StageNoInt: Integer;
                begin
                    if Evaluate(StageNoInt, StageNo) then begin
                        ProcessMgt.SetStage(HostTableNo(), HostRecId(), StageNoInt);
                        RenderBar();
                    end;
                end;

                trigger AdvanceClicked()
                var
                    ProcessMgt: Codeunit "NBC CRM Process Mgt.";
                begin
                    ProcessMgt.AdvanceStage(HostTableNo(), HostRecId());
                    RenderBar();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RenderBar();
    end;

    var
        IsReady: Boolean;

    local procedure RenderBar()
    var
        ProcessMgt: Codeunit "NBC CRM Process Mgt.";
    begin
        if not IsReady then
            exit;
        CurrPage.ProcessBar.Render(ProcessMgt.GetProcessJson(HostTableNo(), HostRecId()));
    end;

    local procedure HostTableNo(): Integer
    begin
        if Rec.GetFilter("Table No.") <> '' then
            exit(Rec.GetRangeMin("Table No."));
        exit(0);
    end;

    local procedure HostRecId(): Guid
    begin
        if Rec.GetFilter("Record System ID") <> '' then
            exit(Rec.GetRangeMin("Record System ID"));
    end;
}
