namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;

/// <summary>Card for a CRM process and its stages.</summary>
page 50061 "NBC CRM Process Card"
{
    PageType = Card;
    ApplicationArea = NBCProcess;
    UsageCategory = None;
    SourceTable = "NBC CRM Process";
    Caption = 'CRM Process';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec."Code") { }
                field(Name; Rec.Name) { }
                field("Table No."; Rec."Table No.") { }
                field(Active; Rec.Active) { }
            }
            part(Stages; "NBC CRM Process Stages")
            {
                ApplicationArea = NBCProcess;
                Caption = 'Stages';
                SubPageLink = "Process Code" = field("Code");
                UpdatePropagation = Both;
            }
        }
    }
}
