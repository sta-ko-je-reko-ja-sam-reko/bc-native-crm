namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>CRM depth on the standard Opportunity: owner, rating, and line-driven estimated revenue.</summary>
tableextension 50040 "NBC CRM Opportunity" extends Opportunity
{
    fields
    {
        field(50040; "NBC CDS Owner Type"; Enum "NBC CDS Owner Type")
        {
            Caption = 'CRM Owner Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the opportunity is owned by a salesperson or a team.';
        }
        field(50041; "NBC CDS Owner Code"; Code[20])
        {
            Caption = 'CRM Owner';
            DataClassification = CustomerContent;
            TableRelation = if ("NBC CDS Owner Type" = const(Salesperson)) "Salesperson/Purchaser"
                            else if ("NBC CDS Owner Type" = const(Team)) "NBC CDS Team";
            ToolTip = 'Specifies the salesperson or team that owns the opportunity.';
        }
        field(50042; "NBC CRM Rating"; Enum "NBC CRM Opportunity Rating")
        {
            Caption = 'CRM Rating';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the qualitative rating of the opportunity.';
        }
        field(50043; "NBC CRM Estimated Revenue"; Decimal)
        {
            Caption = 'CRM Estimated Revenue';
            FieldClass = FlowField;
            CalcFormula = sum("NBC CRM Opp. Line"."Line Amount" where("Opportunity No." = field("No.")));
            Editable = false;
            AutoFormatType = 1;
            ToolTip = 'Specifies the estimated revenue rolled up from the opportunity lines.';
        }
    }
}
