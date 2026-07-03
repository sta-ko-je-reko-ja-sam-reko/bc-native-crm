namespace NBC.Demo;

/// <summary>
/// Demo-import API for the Business Process Flow feature. Its [ServiceEnabled] ImportDemoData action is the MCP tool;
/// in its own API group (demoProcess) so it can be routed to a dedicated MCP configuration / Copilot agent.
/// </summary>
page 50175 "NBC API Demo Process"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'demoProcess';
    APIVersion = 'v1.0';
    EntityCaption = 'Demo Process';
    EntitySetCaption = 'Demo Process';
    EntityName = 'demoProcess';
    EntitySetName = 'demoProcessSet';
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

    /// <summary>Seed CRONUS-style demo data for the Business Process Flow feature.</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "NBC Demo Process";
    begin
        Demo.Import();
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
