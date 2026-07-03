namespace NBC.Demo;

/// <summary>
/// Demo-import API for the Activities feature. Its [ServiceEnabled] ImportDemoData action is the MCP tool; in its own
/// API group (demoActivities) so it can be routed to a dedicated MCP configuration / Copilot agent.
/// </summary>
page 50172 "NBC API Demo Activities"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'demoActivities';
    APIVersion = 'v1.0';
    EntityCaption = 'Demo Activities';
    EntitySetCaption = 'Demo Activities';
    EntityName = 'demoActivities';
    EntitySetName = 'demoActivitiesSet';
    ODataKeyFields = SystemId;
    SourceTable = "NBC Demo Data";
    Extensible = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(code; Rec."Code") { Caption = 'Code'; }
            }
        }
    }

    /// <summary>Seed CRONUS-style demo data for the Activities feature (a covered spread of activities).</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "NBC Demo Activities";
    begin
        Demo.Import();
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
