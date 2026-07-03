namespace NBC.CRM.RoleCenter;

using NBC.Dataverse.Activities;

/// <summary>Activity cue tiles for the CRM Role Center.</summary>
page 50071 "NBC CRM Activity Cues"
{
    PageType = CardPart;
    ApplicationArea = NBCRoleCenter;
    SourceTable = "NBC CRM Cue";
    Caption = 'Activities';

    layout
    {
        area(Content)
        {
            cuegroup(Activities)
            {
                Caption = 'My activities';

                field("My Open Activities"; Rec."My Open Activities")
                {
                    ApplicationArea = NBCRoleCenter;
                    DrillDownPageId = "NBC CDS Activities";
                }
                field("Overdue Activities"; Rec."Overdue Activities")
                {
                    ApplicationArea = NBCRoleCenter;
                    StyleExpr = OverdueStyle;
                    DrillDownPageId = "NBC CDS Activities";
                }
            }
        }
    }

    var
        OverdueStyle: Text;

    trigger OnOpenPage()
    var
        CueMgt: Codeunit "NBC CRM Cue Mgt.";
    begin
        CueMgt.PrepareCue(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec."Overdue Activities" > 0 then
            OverdueStyle := 'Unfavorable'
        else
            OverdueStyle := 'Favorable';
    end;
}
