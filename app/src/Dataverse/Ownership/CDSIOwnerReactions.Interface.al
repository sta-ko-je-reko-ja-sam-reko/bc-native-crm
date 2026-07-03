namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using System.Security.User;

/// <summary>
/// Swappable reactions that stamp a default CRM owner when an ownable record is created.
/// Resolved through the CRM Service Locator so subscribers stay pure proxies.
/// </summary>
interface "NBC CDS IOwnerReactions"
{
    /// <summary>Stamp the default owner on a newly inserted Customer.</summary>
    procedure OnInsertCustomer(var Customer: Record Customer);

    /// <summary>Stamp the default owner on a newly inserted Contact.</summary>
    procedure OnInsertContact(var Contact: Record Contact);
}
