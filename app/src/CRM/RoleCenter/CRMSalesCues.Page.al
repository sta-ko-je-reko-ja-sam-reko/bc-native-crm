namespace NBC.CRM.RoleCenter;

using Microsoft.CRM.Opportunity;

/// <summary>Opportunity cue tiles for the CRM Role Center.</summary>
page 50072 "NBC CRM Sales Cues"
{
    PageType = CardPart;
    ApplicationArea = NBCRoleCenter;
    SourceTable = "NBC CRM Cue";
    Caption = 'Sales';

    layout
    {
        area(Content)
        {
            cuegroup(Sales)
            {
                Caption = 'My pipeline';

                field("My Opportunities"; Rec."My Opportunities")
                {
                    ApplicationArea = NBCRoleCenter;
                    DrillDownPageId = "Opportunity List";
                }
                field("Opportunities In Progress"; Rec."Opportunities In Progress")
                {
                    ApplicationArea = NBCRoleCenter;
                    DrillDownPageId = "Opportunity List";
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CueMgt: Codeunit "NBC CRM Cue Mgt.";
    begin
        CueMgt.PrepareCue(Rec);
    end;
}
