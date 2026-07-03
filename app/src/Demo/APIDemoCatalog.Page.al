namespace NBC.Demo;

/// <summary>
/// Demo-import API for the Product Sales Catalog feature. Its [ServiceEnabled] ImportDemoData action is the MCP tool;
/// in its own API group (demoCatalog) so it can be routed to a dedicated MCP configuration / Copilot agent.
/// </summary>
page 50178 "NBC API Demo Catalog"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'demoCatalog';
    APIVersion = 'v1.0';
    EntityCaption = 'Demo Catalog';
    EntitySetCaption = 'Demo Catalog';
    EntityName = 'demoCatalog';
    EntitySetName = 'demoCatalogSet';
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

    /// <summary>Seed CRONUS-style demo data for the Product Sales Catalog (bundles, relations, item/resource facets).</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "NBC Demo Catalog";
    begin
        Demo.Import();
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
