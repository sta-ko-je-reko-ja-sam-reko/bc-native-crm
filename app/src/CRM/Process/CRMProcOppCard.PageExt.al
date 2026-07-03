namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;
using NBC.Setup;

/// <summary>Places the CRM process-flow stage bar at the top of the Opportunity Card, gated by the Process feature.</summary>
pageextension 50060 "NBC CRM Proc. Opp. Card" extends "Opportunity Card"
{
    layout
    {
        addfirst(content)
        {
            part(NBCProcessBar; "NBC CRM Process Bar Part")
            {
                ApplicationArea = NBCProcess;
                AccessByPermission = tabledata "NBC Process Setup" = R;
                Caption = 'Process';
                // 5092 = Database::Opportunity
                SubPageLink = "Table No." = const(5092), "Record System ID" = field(SystemId);
            }
        }
    }
}
