namespace NBC.Demo;

/// <summary>
/// Demo-import API for the Ownership feature. Its [ServiceEnabled] ImportDemoData action is the MCP tool that seeds
/// CRONUS-style ownership sample data. In its own API group (demoOwnership) so it can be bound to a dedicated MCP
/// configuration / Copilot agent, separate from the functional APIs.
/// </summary>
page 50171 "NBC API Demo Ownership"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'demoOwnership';
    APIVersion = 'v1.0';
    EntityCaption = 'Demo Ownership';
    EntitySetCaption = 'Demo Ownership';
    EntityName = 'demoOwnership';
    EntitySetName = 'demoOwnershipSet';
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

    /// <summary>Seed CRONUS-style demo data for the Ownership feature (teams, members, record owners).</summary>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        Demo: Codeunit "NBC Demo Ownership";
    begin
        Demo.Import();
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
