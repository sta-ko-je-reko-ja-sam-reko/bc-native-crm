namespace NBC.Demo;

/// <summary>
/// Demo-import API for the Party Enrichment feature. Its [ServiceEnabled] ImportDemoData action is the MCP tool; in
/// its own API group (demoParty) so it can be routed to a dedicated MCP configuration / Copilot agent.
/// </summary>
page 50173 "NBC API Demo Party"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'demoParty';
    APIVersion = 'v1.0';
    EntityCaption = 'Demo Party';
    EntitySetCaption = 'Demo Party';
    EntityName = 'demoParty';
    EntitySetName = 'demoPartySet';
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

    /// <summary>Seed CRONUS-style demo data for Party Enrichment (firmographics, preferences, hierarchy).</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "NBC Demo Party";
    begin
        Demo.Import();
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
