namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>A contact playing a role on a CRM opportunity (buying-group / sales-team member).</summary>
table 50042 "NBC CRM Opp. Stakeholder"
{
    Caption = 'CRM Opportunity Stakeholder';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Opportunity No."; Code[20])
        {
            Caption = 'Opportunity No.';
            NotBlank = true;
            TableRelation = Opportunity;
            ToolTip = 'Specifies the opportunity the stakeholder is on.';
        }
        field(2; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            NotBlank = true;
            TableRelation = Contact;
            ToolTip = 'Specifies the contact who is a stakeholder.';
        }
        field(10; Role; Enum "NBC CRM Stakeholder Role")
        {
            Caption = 'Role';
            ToolTip = 'Specifies the stakeholder''s role in the deal.';
        }
        field(20; "Role Description"; Text[100])
        {
            Caption = 'Role Description';
            ToolTip = 'Specifies additional detail about the stakeholder''s role.';
        }
        field(30; "Contact Name"; Text[100])
        {
            Caption = 'Contact Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Contact.Name where("No." = field("Contact No.")));
            Editable = false;
            ToolTip = 'Specifies the name of the contact.';
        }
    }

    keys
    {
        key(PK; "Opportunity No.", "Contact No.") { Clustered = true; }
    }
}
