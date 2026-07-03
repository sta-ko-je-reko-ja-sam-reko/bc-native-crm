namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>Line type on a CRM opportunity line.</summary>
enum 50041 "NBC CRM Opp. Line Type"
{
    Extensible = true;
    Caption = 'CRM Opp. Line Type';

    value(0; Comment) { Caption = 'Comment'; }
    value(1; Item) { Caption = 'Item'; }
    value(2; Resource) { Caption = 'Resource'; }
}
