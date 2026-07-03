namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using System.Security.User;

/// <summary>CRM ownership fields on Contact.</summary>
tableextension 50021 "NBC CDS Owner Contact" extends Contact
{
    fields
    {
        field(50020; "NBC CDS Owner Type"; Enum "NBC CDS Owner Type")
        {
            Caption = 'CRM Owner Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this record is owned by a salesperson or a team for CRM.';
        }
        field(50021; "NBC CDS Owner Code"; Code[20])
        {
            Caption = 'CRM Owner';
            DataClassification = CustomerContent;
            TableRelation = if ("NBC CDS Owner Type" = const(Salesperson)) "Salesperson/Purchaser"
                            else if ("NBC CDS Owner Type" = const(Team)) "NBC CDS Team";
            ToolTip = 'Specifies the salesperson or team that owns this record for CRM.';
        }
    }
}
