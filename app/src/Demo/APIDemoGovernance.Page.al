namespace NBC.Demo;

/// <summary>
/// Demo-import API for the Governance feature. Its [ServiceEnabled] ImportDemoData action is the MCP tool; in its
/// own API group (demoGovernance) so it can be routed to a dedicated MCP configuration / Copilot agent.
/// </summary>
page 50177 "NBC API Demo Governance"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'demoGovernance';
    APIVersion = 'v1.0';
    EntityCaption = 'Demo Governance';
    EntitySetCaption = 'Demo Governance';
    EntityName = 'demoGovernance';
    EntitySetName = 'demoGovernanceSet';
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

    /// <summary>Seed CRONUS-style demo data for Governance (duplicate customers for the detection feature to find).</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "NBC Demo Governance";
    begin
        Demo.Import();
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
