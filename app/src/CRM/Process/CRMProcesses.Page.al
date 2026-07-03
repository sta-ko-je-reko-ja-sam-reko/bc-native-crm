namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;

/// <summary>List of CRM processes.</summary>
page 50060 "NBC CRM Processes"
{
    PageType = List;
    ApplicationArea = NBCProcess;
    UsageCategory = Administration;
    SourceTable = "NBC CRM Process";
    CardPageId = "NBC CRM Process Card";
    Caption = 'CRM Processes';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code") { }
                field(Name; Rec.Name) { }
                field("Table No."; Rec."Table No.") { }
                field(Active; Rec.Active) { }
            }
        }
    }
}
