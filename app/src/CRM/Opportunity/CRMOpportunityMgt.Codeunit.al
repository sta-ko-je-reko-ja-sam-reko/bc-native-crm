namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>
/// CRM opportunity services. Logs a won/lost close activity (the Dataverse opportunityclose analog),
/// reusing the FEAT-ACT-001 activity model. The standard BC status/close flow is left intact.
/// </summary>
codeunit 50041 "NBC CRM Opportunity Mgt."
{
    Access = Public;

    /// <summary>Log a completed "opportunity won/lost" activity regarding the opportunity.</summary>
    procedure LogOutcomeActivity(Opportunity: Record Opportunity; Won: Boolean)
    var
        Activity: Record "NBC CDS Activity";
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
        WonLbl: Label 'Opportunity won';
        LostLbl: Label 'Opportunity lost';
        Subject: Text;
    begin
        if Won then
            Subject := WonLbl
        else
            Subject := LostLbl;

        ActivityMgt.InitActivityForRecord(Activity, Database::Opportunity, Opportunity.SystemId, Opportunity.Description);
        Activity."Activity Type" := Activity."Activity Type"::Note;
        Activity.Subject := CopyStr(Subject, 1, MaxStrLen(Activity.Subject));
        Activity.Insert(true);
        Activity.Validate(Status, Activity.Status::Completed);
        Activity.Modify(true);
    end;
}
