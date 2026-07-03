namespace NBC.Demo;

/// <summary>
/// Demo-import API for the Role Center feature. Its [ServiceEnabled] ImportDemoData action is the MCP tool; in its
/// own API group (demoRoleCenter) so it can be routed to a dedicated MCP configuration / Copilot agent.
/// </summary>
page 50176 "NBC API Demo Role Center"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'demoRoleCenter';
    APIVersion = 'v1.0';
    EntityCaption = 'Demo Role Center';
    EntitySetCaption = 'Demo Role Center';
    EntityName = 'demoRoleCenter';
    EntitySetName = 'demoRoleCenterSet';
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

    /// <summary>Seed the context the Role Center needs (link the current user to a salesperson so cues populate).</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "NBC Demo Role Center";
    begin
        Demo.Import();
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
