namespace NBC.Demo;

/// <summary>
/// Demo-import API for the Opportunity Depth feature. Its [ServiceEnabled] ImportDemoData action is the MCP tool; in
/// its own API group (demoOpportunity) so it can be routed to a dedicated MCP configuration / Copilot agent.
/// </summary>
page 50174 "NBC API Demo Opportunity"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'demoOpportunity';
    APIVersion = 'v1.0';
    EntityCaption = 'Demo Opportunity';
    EntitySetCaption = 'Demo Opportunity';
    EntityName = 'demoOpportunity';
    EntitySetName = 'demoOpportunitySet';
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

    /// <summary>Seed CRONUS-style demo data for Opportunity Depth (opportunities, lines, competitors, stakeholders).</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "NBC Demo Opportunity";
    begin
        Demo.Import();
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
