namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>A competitor on a CRM opportunity.</summary>
table 50041 "NBC CRM Opp. Competitor"
{
    Caption = 'CRM Opportunity Competitor';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Opportunity No."; Code[20])
        {
            Caption = 'Opportunity No.';
            NotBlank = true;
            TableRelation = Opportunity;
            ToolTip = 'Specifies the opportunity the competitor is on.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies the line number.';
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the competitor name.';
        }
        field(20; "Threat Level"; Enum "NBC CRM Threat Level")
        {
            Caption = 'Threat Level';
            ToolTip = 'Specifies how strong a threat the competitor is.';
        }
        field(30; Strengths; Text[250])
        {
            Caption = 'Strengths';
            ToolTip = 'Specifies the competitor''s strengths.';
        }
        field(40; Weaknesses; Text[250])
        {
            Caption = 'Weaknesses';
            ToolTip = 'Specifies the competitor''s weaknesses.';
        }
    }

    keys
    {
        key(PK; "Opportunity No.", "Line No.") { Clustered = true; }
    }
}
