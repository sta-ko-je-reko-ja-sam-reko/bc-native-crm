namespace NBC.CRM.Linkage;

using Microsoft.Sales.History;

/// <summary>
/// Read-only API page over the posted Sales Invoice Header — mirrors Microsoft's APIV2 sales invoice field surface
/// (sourced from the base table directly) plus the CRM pipeline affix field. The posted document is immutable, so
/// the page is read-only: no insert/modify/delete and no feature write-guard (reads stay open per the toggle
/// pattern). A NEW page, not a pageextension. Document totals and MS sub-parts are omitted — see Known Limitations.
/// </summary>
page 50151 "NBC CRM API Sales Invoice"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'pipeline';
    APIVersion = 'v1.0';
    EntityCaption = 'Sales Invoice CRM';
    EntitySetCaption = 'Sales Invoices CRM';
    EntityName = 'salesInvoiceCrm';
    EntitySetName = 'salesInvoicesCrm';
    ChangeTrackingAllowed = true;
    ODataKeyFields = SystemId;
    SourceTable = "Sales Invoice Header";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(orderNumber; Rec."Order No.")
                {
                    Caption = 'Order No.';
                }
                field(sellToCustomerNumber; Rec."Sell-to Customer No.")
                {
                    Caption = 'Sell-to Customer No.';
                }
                field(billToCustomerNumber; Rec."Bill-to Customer No.")
                {
                    Caption = 'Bill-to Customer No.';
                }
                field(billToName; Rec."Bill-to Name")
                {
                    Caption = 'Bill-to Name';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code';
                }
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                }
                field(yourReference; Rec."Your Reference")
                {
                    Caption = 'Your Reference';
                }
                // --- NBC CRM affix field (pipeline linkage tableextension) ---
                field(crmOpportunityNo; Rec."NBC CRM Opportunity No.")
                {
                    Caption = 'CRM Opportunity No.';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
            }
        }
    }
}
