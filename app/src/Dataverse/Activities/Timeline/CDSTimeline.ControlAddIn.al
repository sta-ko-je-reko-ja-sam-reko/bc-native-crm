namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>
/// JavaScript control add-in that renders a CRM activity timeline (icon per type, newest first).
/// AL pushes the activities as JSON via Render(); the control raises ActivityClicked on click.
/// Used where a native BC page cannot render the required visual (project decision framework).
/// </summary>
controladdin "NBC CDS Timeline"
{
    RequestedHeight = 350;
    MinimumHeight = 150;
    MaximumHeight = 1200;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = 'src/Dataverse/Activities/Timeline/timeline.js';
    StyleSheets = 'src/Dataverse/Activities/Timeline/timeline.css';

    /// <summary>Render the timeline from a JSON array of activities.</summary>
    procedure Render(ActivitiesJson: Text);

    /// <summary>Raised once the control has loaded and is ready to receive data.</summary>
    event ControlReady();

    /// <summary>Raised when the user clicks an activity; passes its entry number as text.</summary>
    event ActivityClicked(ActivityId: Text);
}
