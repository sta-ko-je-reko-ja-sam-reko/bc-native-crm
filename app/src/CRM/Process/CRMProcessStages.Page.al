namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;

/// <summary>Stages of a CRM process (ListPart on the Process Card).</summary>
page 50062 "NBC CRM Process Stages"
{
    PageType = ListPart;
    ApplicationArea = NBCProcess;
    SourceTable = "NBC CRM Process Stage";
    Caption = 'CRM Process Stages';
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Stage No."; Rec."Stage No.") { }
                field(Name; Rec.Name) { }
            }
        }
    }
}
