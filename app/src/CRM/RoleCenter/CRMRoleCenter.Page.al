namespace NBC.CRM.RoleCenter;

using Microsoft.CRM.Opportunity;
using NBC.CRM.Process;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;
using NBC.Governance;

/// <summary>Home page (Role Center) for the native CRM.</summary>
page 50070 "NBC CRM Role Center"
{
    PageType = RoleCenter;
    Caption = 'CRM Manager';

    layout
    {
        area(RoleCenter)
        {
            part(ActivityCuesPart; "NBC CRM Activity Cues")
            {
                ApplicationArea = NBCRoleCenter;
            }
            part(SalesCuesPart; "NBC CRM Sales Cues")
            {
                ApplicationArea = NBCRoleCenter;
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(NavCrm)
            {
                Caption = 'CRM';
                action(NavTeams)
                {
                    ApplicationArea = NBCOwnership;
                    Caption = 'Teams';
                    Image = Users;
                    ToolTip = 'Opens the CRM teams.';
                    RunObject = page "NBC CDS Teams";
                }
                action(NavActivities)
                {
                    ApplicationArea = NBCActivities;
                    Caption = 'Activities';
                    Image = Log;
                    ToolTip = 'Opens all CRM activities.';
                    RunObject = page "NBC CDS Activities";
                }
                action(NavOpportunities)
                {
                    ApplicationArea = NBCOpportunity;
                    Caption = 'Opportunities';
                    Image = Opportunity;
                    ToolTip = 'Opens the opportunities.';
                    RunObject = page "Opportunity List";
                }
                action(NavProcesses)
                {
                    ApplicationArea = NBCProcess;
                    Caption = 'Processes';
                    Image = Flow;
                    ToolTip = 'Opens the CRM business processes.';
                    RunObject = page "NBC CRM Processes";
                }
            }
        }
        area(Creation)
        {
            action(NewActivity)
            {
                ApplicationArea = NBCActivities;
                Caption = 'New activity';
                Image = Add;
                ToolTip = 'Creates a new CRM activity.';
                RunObject = page "NBC CDS Activity Card";
                RunPageMode = Create;
            }
        }
        area(Processing)
        {
            group(Governance)
            {
                Caption = 'Governance';
                action(EnableAudit)
                {
                    ApplicationArea = NBCGovernance;
                    Caption = 'Enable CRM audit logging';
                    Image = Log;
                    ToolTip = 'Turns on Change Log tracking for the CRM tables.';
                    RunObject = codeunit "NBC Audit Mgt.";
                }
                action(FindDuplicateCustomers)
                {
                    ApplicationArea = NBCGovernance;
                    Caption = 'Find duplicate customers';
                    Image = ItemSubstitution;
                    ToolTip = 'Lists customers that share the same name.';
                    RunObject = codeunit "NBC Duplicate Mgt.";
                }
            }
        }
    }
}
