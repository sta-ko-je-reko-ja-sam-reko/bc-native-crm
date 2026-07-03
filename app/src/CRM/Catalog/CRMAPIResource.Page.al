namespace NBC.CRM.Catalog;

using Microsoft.Projects.Resources.Resource;

/// <summary>
/// API page over Resource. Microsoft ships no APIV2 Resources page, so this is an authored-from-scratch API
/// exposing the meaningful Resource master fields (so integrations/MCP see the whole resource) plus the CRM
/// catalog affix fields. A NEW page, not a pageextension (API pages can't be extended).
/// </summary>
page 50128 "NBC CRM API Resource"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'catalog';
    APIVersion = 'v1.0';
    EntityCaption = 'Resource CRM';
    EntitySetCaption = 'Resources CRM';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'resourceCrm';
    EntitySetName = 'resourcesCrm';
    ODataKeyFields = SystemId;
    SourceTable = Resource;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(displayName; Rec.Name) { Caption = 'Display Name'; }
                field(searchName; Rec."Search Name") { Caption = 'Search Name'; }
                field(type; Rec.Type) { Caption = 'Type'; }
                field(addressLine1; Rec.Address) { Caption = 'Address Line 1'; }
                field(addressLine2; Rec."Address 2") { Caption = 'Address Line 2'; }
                field(city; Rec.City) { Caption = 'City'; }
                field(jobTitle; Rec."Job Title") { Caption = 'Job Title'; }
                field(resourceGroupNumber; Rec."Resource Group No.") { Caption = 'Resource Group No.'; }
                field(baseUnitOfMeasureCode; Rec."Base Unit of Measure") { Caption = 'Base Unit of Measure Code'; }
                field(directUnitCost; Rec."Direct Unit Cost") { Caption = 'Direct Unit Cost'; }
                field(unitCost; Rec."Unit Cost") { Caption = 'Unit Cost'; }
                field(profitPercent; Rec."Profit %") { Caption = 'Profit %'; }
                field(unitPrice; Rec."Unit Price") { Caption = 'Unit Price'; }
                field(vendorNumber; Rec."Vendor No.") { Caption = 'Vendor No.'; }
                field(generalProductPostingGroup; Rec."Gen. Prod. Posting Group") { Caption = 'General Product Posting Group'; }
                field(blocked; Rec.Blocked) { Caption = 'Blocked'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
                // --- NBC CRM catalog affix fields ---
                field(crmCatalogStatus; Rec."NBC CRM Catalog Status") { Caption = 'CRM Catalog Status'; }
                field(crmValidFrom; Rec."NBC CRM Valid From") { Caption = 'CRM Valid From'; }
                field(crmValidTo; Rec."NBC CRM Valid To") { Caption = 'CRM Valid To'; }
                field(crmDefaultPriceList; Rec."NBC CRM Default Price List") { Caption = 'CRM Default Price List'; }
            }
        }
    }
}
