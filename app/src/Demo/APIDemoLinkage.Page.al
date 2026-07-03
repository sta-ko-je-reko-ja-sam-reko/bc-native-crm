namespace NBC.Demo;

/// <summary>
/// Demo-import API for the Transaction Pipeline Linkage feature. Its [ServiceEnabled] ImportDemoData action is the
/// MCP tool; in its own API group (demoLinkage) so it can be routed to a dedicated MCP configuration / Copilot agent.
/// </summary>
page 50180 "NBC API Demo Linkage"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'demoLinkage';
    APIVersion = 'v1.0';
    EntityCaption = 'Demo Linkage';
    EntitySetCaption = 'Demo Linkage';
    EntityName = 'demoLinkage';
    EntitySetName = 'demoLinkageSet';
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

    /// <summary>Seed CRONUS-style demo data for Pipeline Linkage (orders linked to a demo opportunity).</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "NBC Demo Linkage";
    begin
        Demo.Import();
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
