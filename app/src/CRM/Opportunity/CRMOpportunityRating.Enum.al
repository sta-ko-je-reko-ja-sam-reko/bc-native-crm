namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>Qualitative rating of an opportunity.</summary>
enum 50040 "NBC CRM Opportunity Rating"
{
    Extensible = true;
    Caption = 'CRM Opportunity Rating';

    value(0; Warm) { Caption = 'Warm'; }
    value(1; Hot) { Caption = 'Hot'; }
    value(2; Cold) { Caption = 'Cold'; }
}
