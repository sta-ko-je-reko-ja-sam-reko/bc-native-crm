namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>Role a contact plays on an opportunity.</summary>
enum 50042 "NBC CRM Stakeholder Role"
{
    Extensible = true;
    Caption = 'CRM Stakeholder Role';

    value(0; "End User") { Caption = 'End User'; }
    value(1; "Decision Maker") { Caption = 'Decision Maker'; }
    value(2; Influencer) { Caption = 'Influencer'; }
    value(3; Champion) { Caption = 'Champion'; }
    value(4; Blocker) { Caption = 'Blocker'; }
}
