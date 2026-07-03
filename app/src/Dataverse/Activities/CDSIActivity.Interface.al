namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>Swappable trigger/validation logic for CRM Activity.</summary>
interface "NBC CDS IActivity"
{
    /// <summary>Runs on insert (default owner, activity date, created-by).</summary>
    procedure Trigger_OnInsert(var Activity: Record "NBC CDS Activity");

    /// <summary>Validates the Status field (stamp closed date-time on completion).</summary>
    procedure Validate_Status(var Activity: Record "NBC CDS Activity");
}
