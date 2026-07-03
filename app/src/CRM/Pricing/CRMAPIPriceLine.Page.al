namespace NBC.CRM.Pricing;

using Microsoft.Pricing.PriceList;

/// <summary>
/// API page over the standard Price List Line. Microsoft ships no APIV2 page for it, so this is authored from
/// scratch — the meaningful price-line fields (so integrations/MCP see the whole line) plus the CRM pricing-
/// flexibility affix fields. A NEW page, not a pageextension (API pages can't be extended).
/// </summary>
page 50129 "NBC CRM API Price Line"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'pricing';
    APIVersion = 'v1.0';
    EntityCaption = 'Price List Line CRM';
    EntitySetCaption = 'Price List Lines CRM';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'priceListLineCrm';
    EntitySetName = 'priceListLinesCrm';
    ODataKeyFields = SystemId;
    SourceTable = "Price List Line";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(priceListCode; Rec."Price List Code") { Caption = 'Price List Code'; }
                field(lineNumber; Rec."Line No.") { Caption = 'Line No.'; }
                field(sourceType; Rec."Source Type") { Caption = 'Assign-to Type'; }
                field(sourceNumber; Rec."Source No.") { Caption = 'Assign-to No.'; }
                field(assetType; Rec."Asset Type") { Caption = 'Product Type'; }
                field(assetNumber; Rec."Asset No.") { Caption = 'Product No.'; }
                field(currencyCode; Rec."Currency Code") { Caption = 'Currency Code'; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(minimumQuantity; Rec."Minimum Quantity") { Caption = 'Minimum Quantity'; }
                field(amountType; Rec."Amount Type") { Caption = 'Defines'; }
                field(unitPrice; Rec."Unit Price") { Caption = 'Unit Price'; }
                field(costFactor; Rec."Cost Factor") { Caption = 'Cost Factor'; }
                field(unitCost; Rec."Unit Cost") { Caption = 'Unit Cost'; }
                field(lineDiscountPercent; Rec."Line Discount %") { Caption = 'Line Discount %'; }
                field(priceIncludesVat; Rec."Price Includes VAT") { Caption = 'Price Includes VAT'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
                // --- NBC CRM pricing-flexibility affix fields ---
                field(crmPricingMethod; Rec."NBC CRM Pricing Method") { Caption = 'CRM Pricing Method'; }
                field(crmPricingPercent; Rec."NBC CRM Pricing %") { Caption = 'CRM Pricing %'; }
                field(crmDiscountList; Rec."NBC CRM Discount List") { Caption = 'CRM Discount List'; }
                field(crmRoundingPolicy; Rec."NBC CRM Rounding Policy") { Caption = 'CRM Rounding Policy'; }
                field(crmRoundingPrecision; Rec."NBC CRM Rounding Precision") { Caption = 'CRM Rounding Precision'; }
                field(crmQuantitySelling; Rec."NBC CRM Qty. Selling") { Caption = 'CRM Quantity Selling'; }
            }
        }
    }
}
