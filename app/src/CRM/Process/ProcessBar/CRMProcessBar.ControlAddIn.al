namespace NBC.CRM.Process;

using Microsoft.CRM.Opportunity;

/// <summary>
/// JavaScript control add-in rendering a business-process-flow stage bar (chevrons + Advance).
/// AL pushes the process JSON via Render(); the control raises StageClicked / AdvanceClicked.
/// </summary>
controladdin "NBC CRM Process Bar"
{
    RequestedHeight = 60;
    MinimumHeight = 44;
    MaximumHeight = 120;
    VerticalStretch = false;
    HorizontalStretch = true;

    Scripts = 'src/CRM/Process/ProcessBar/processbar.js';
    StyleSheets = 'src/CRM/Process/ProcessBar/processbar.css';

    /// <summary>Render the stage bar from process JSON.</summary>
    procedure Render(ProcessJson: Text);

    /// <summary>Raised once the control is ready.</summary>
    event ControlReady();

    /// <summary>Raised when a stage chevron is clicked; passes its stage number as text.</summary>
    event StageClicked(StageNo: Text);

    /// <summary>Raised when the Advance button is clicked.</summary>
    event AdvanceClicked();
}
