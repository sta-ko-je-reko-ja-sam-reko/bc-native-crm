namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>Swappable validation logic for CRM Opportunity Line.</summary>
interface "NBC CRM IOpportunityLine"
{
    /// <summary>Validates No. — pulls description and price from the item/resource.</summary>
    procedure Validate_No(var OpportunityLine: Record "NBC CRM Opp. Line");

    /// <summary>Recalculates the line amount from quantity and unit price.</summary>
    procedure Validate_Amounts(var OpportunityLine: Record "NBC CRM Opp. Line");
}
