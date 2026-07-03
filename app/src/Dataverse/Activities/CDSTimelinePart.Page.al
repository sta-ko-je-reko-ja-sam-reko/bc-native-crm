namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>
/// FactBox host for the CRM Timeline control add-in. Bound to CRM Activity and filtered to the host
/// record by SubPageLink (Regarding Table No. + Regarding System ID), so it follows the current
/// record without needing a page trigger on the host card.
/// </summary>
page 50032 "NBC CDS Timeline Part"
{
    PageType = CardPart;
    ApplicationArea = NBCActivities;
    SourceTable = "NBC CDS Activity";
    Caption = 'Timeline';

    layout
    {
        area(Content)
        {
            usercontrol(TimelineControl; "NBC CDS Timeline")
            {
                ApplicationArea = NBCActivities;

                trigger ControlReady()
                begin
                    IsReady := true;
                    RenderTimeline();
                end;

                trigger ActivityClicked(ActivityId: Text)
                var
                    Activity: Record "NBC CDS Activity";
                    EntryNo: Integer;
                begin
                    if Evaluate(EntryNo, ActivityId) then
                        if Activity.Get(EntryNo) then
                            Page.Run(Page::"NBC CDS Activity Card", Activity);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RenderTimeline();
    end;

    var
        IsReady: Boolean;

    local procedure RenderTimeline()
    var
        Activity: Record "NBC CDS Activity";
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
    begin
        if not IsReady then
            exit;
        Activity.CopyFilters(Rec);
        CurrPage.TimelineControl.Render(ActivityMgt.BuildTimelineJson(Activity));
    end;
}
