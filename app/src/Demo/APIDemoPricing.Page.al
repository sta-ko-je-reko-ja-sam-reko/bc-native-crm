namespace NBC.Demo;

/// <summary>
/// Demo-import API for the Pricing Flexibility feature. Its [ServiceEnabled] ImportDemoData action is the MCP tool;
/// in its own API group (demoPricing) so it can be routed to a dedicated MCP configuration / Copilot agent.
/// </summary>
page 50179 "NBC API Demo Pricing"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'demoPricing';
    APIVersion = 'v1.0';
    EntityCaption = 'Demo Pricing';
    EntitySetCaption = 'Demo Pricing';
    EntityName = 'demoPricing';
    EntitySetName = 'demoPricingSet';
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

    /// <summary>Seed CRONUS-style demo data for Pricing Flexibility (discount lists and tiers).</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "NBC Demo Pricing";
    begin
        Demo.Import();
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
