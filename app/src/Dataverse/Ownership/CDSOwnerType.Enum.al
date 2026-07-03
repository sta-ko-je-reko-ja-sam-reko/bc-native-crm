namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using System.Security.User;

/// <summary>
/// The kind of principal that owns a CRM record — mirrors the Dataverse polymorphic owner
/// (a systemuser or a team). Here: a BC Salesperson/Purchaser or a CRM Team.
/// </summary>
enum 50020 "NBC CDS Owner Type"
{
    Extensible = true;
    Caption = 'CRM Owner Type';

    value(0; Salesperson)
    {
        Caption = 'Salesperson';
    }
    value(1; Team)
    {
        Caption = 'Team';
    }
}
