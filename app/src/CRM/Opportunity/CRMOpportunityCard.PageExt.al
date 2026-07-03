namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;
using NBC.Setup;

/// <summary>
/// Adds CRM depth to the Opportunity Card: owner/rating, line/competitor/stakeholder subpages,
/// the activity Timeline FactBox, and CRM actions. Gated by the Opportunity feature.
/// </summary>
pageextension 50040 "NBC CRM Opportunity Card" extends "Opportunity Card"
{
    layout
    {
        addlast(content)
        {
            group(NBCInfo)
            {
                Caption = 'CRM';
                field("NBC CDS Owner Type"; Rec."NBC CDS Owner Type") { ApplicationArea = NBCOpportunity; AccessByPermission = tabledata "NBC Opportunity Setup" = R; }
                field("NBC CDS Owner Code"; Rec."NBC CDS Owner Code") { ApplicationArea = NBCOpportunity; AccessByPermission = tabledata "NBC Opportunity Setup" = R; }
                field("NBC CRM Rating"; Rec."NBC CRM Rating") { ApplicationArea = NBCOpportunity; AccessByPermission = tabledata "NBC Opportunity Setup" = R; }
                field("NBC CRM Estimated Revenue"; Rec."NBC CRM Estimated Revenue") { ApplicationArea = NBCOpportunity; AccessByPermission = tabledata "NBC Opportunity Setup" = R; }
            }
            part(NBCLines; "NBC CRM Opp. Lines")
            {
                ApplicationArea = NBCOpportunity;
                AccessByPermission = tabledata "NBC Opportunity Setup" = R;
                Caption = 'Lines';
                SubPageLink = "Opportunity No." = field("No.");
                UpdatePropagation = Both;
            }
            part(NBCStakeholders; "NBC CRM Opp. Stakeholders")
            {
                ApplicationArea = NBCOpportunity;
                AccessByPermission = tabledata "NBC Opportunity Setup" = R;
                Caption = 'Stakeholders';
                SubPageLink = "Opportunity No." = field("No.");
            }
            part(NBCCompetitors; "NBC CRM Opp. Competitors")
            {
                ApplicationArea = NBCOpportunity;
                AccessByPermission = tabledata "NBC Opportunity Setup" = R;
                Caption = 'Competitors';
                SubPageLink = "Opportunity No." = field("No.");
            }
        }
        addfirst(factboxes)
        {
            part(NBCTimeline; "NBC CDS Timeline Part")
            {
                ApplicationArea = NBCOpportunity;
                AccessByPermission = tabledata "NBC Opportunity Setup" = R;
                Caption = 'Timeline';
                // 5092 = Database::Opportunity
                SubPageLink = "Regarding Table No." = const(5092), "Regarding System ID" = field(SystemId);
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group(NBCActions)
            {
                Caption = 'CRM';
                action(NBCAssignToMe)
                {
                    ApplicationArea = NBCOpportunity;
                    AccessByPermission = tabledata "NBC Opportunity Setup" = R;
                    Caption = 'Assign to me';
                    Image = User;
                    ToolTip = 'Assigns CRM ownership of this opportunity to your salesperson.';

                    trigger OnAction()
                    var
                        OwnerMgt: Codeunit "NBC CDS Owner Mgt.";
                        MySalesperson: Code[20];
                    begin
                        MySalesperson := OwnerMgt.GetCurrentUserSalesperson();
                        if MySalesperson = '' then
                            Error(NoSalespersonErr);
                        Rec."NBC CDS Owner Type" := Rec."NBC CDS Owner Type"::Salesperson;
                        Rec."NBC CDS Owner Code" := MySalesperson;
                        Rec.Modify(true);
                    end;
                }
                action(NBCLogWon)
                {
                    ApplicationArea = NBCOpportunity;
                    AccessByPermission = tabledata "NBC Opportunity Setup" = R;
                    Caption = 'Log won';
                    Image = Approve;
                    ToolTip = 'Logs a "won" close activity on the opportunity timeline.';

                    trigger OnAction()
                    var
                        OpportunityMgt: Codeunit "NBC CRM Opportunity Mgt.";
                    begin
                        OpportunityMgt.LogOutcomeActivity(Rec, true);
                    end;
                }
                action(NBCLogLost)
                {
                    ApplicationArea = NBCOpportunity;
                    AccessByPermission = tabledata "NBC Opportunity Setup" = R;
                    Caption = 'Log lost';
                    Image = Reject;
                    ToolTip = 'Logs a "lost" close activity on the opportunity timeline.';

                    trigger OnAction()
                    var
                        OpportunityMgt: Codeunit "NBC CRM Opportunity Mgt.";
                    begin
                        OpportunityMgt.LogOutcomeActivity(Rec, false);
                    end;
                }
            }
        }
    }

    var
        NoSalespersonErr: Label 'Your user is not linked to a salesperson in User Setup.';
}
