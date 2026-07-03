namespace NBC.Dataverse.Ownership;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Core;
using System.Security.User;

/// <summary>Swappable trigger/validation logic for CRM Team and CRM Team Member.</summary>
interface "NBC CDS ITeam"
{
    /// <summary>Runs when a team is deleted (cascade its members).</summary>
    procedure Trigger_OnDeleteTeam(var Team: Record "NBC CDS Team");

    /// <summary>Runs when a team member is inserted.</summary>
    procedure Trigger_OnInsertMember(var TeamMember: Record "NBC CDS Team Member");

    /// <summary>Validates the Team Lead flag (single lead per team; reflect on the header).</summary>
    procedure Validate_TeamLead(var TeamMember: Record "NBC CDS Team Member"; xTeamMember: Record "NBC CDS Team Member");
}
