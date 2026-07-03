namespace NBC.CRM.Linkage;

using Microsoft.Integration.Graph;
using Microsoft.Sales.Document;
using NBC.Setup;

/// <summary>
/// API page over Sales Header (Order) — mirrors Microsoft's APIV2 sales order field surface but sourced from the
/// base table directly (MS's APIV2 page binds an aggregate buffer that is not a symbol dependency here), plus the
/// CRM pipeline affix fields. A NEW page, not a pageextension (API pages can't be extended). Writes are gated by the
/// Linkage feature toggle (ApplicationArea does not reach the API/MCP path). Document totals and MS sub-parts are
/// omitted — see the feature's Known Limitations.
/// </summary>
page 50150 "NBC CRM API Sales Order"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'pipeline';
    APIVersion = 'v1.0';
    EntityCaption = 'Sales Order CRM';
    EntitySetCaption = 'Sales Orders CRM';
    EntityName = 'salesOrderCrm';
    EntitySetName = 'salesOrdersCrm';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Order));
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
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("No."));
                    end;
                }
                field(sellToCustomerNumber; Rec."Sell-to Customer No.")
                {
                    Caption = 'Sell-to Customer No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to Customer No."));
                    end;
                }
                field(sellToCustomerName; Rec."Sell-to Customer Name")
                {
                    Caption = 'Sell-to Customer Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to Customer Name"));
                    end;
                }
                field(billToCustomerNumber; Rec."Bill-to Customer No.")
                {
                    Caption = 'Bill-to Customer No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-to Customer No."));
                    end;
                }
                field(billToName; Rec."Bill-to Name")
                {
                    Caption = 'Bill-to Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-to Name"));
                    end;
                }
                field(orderDate; Rec."Order Date")
                {
                    Caption = 'Order Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Order Date"));
                    end;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Posting Date"));
                    end;
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Document Date"));
                    end;
                }
                field(requestedDeliveryDate; Rec."Requested Delivery Date")
                {
                    Caption = 'Requested Delivery Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Requested Delivery Date"));
                    end;
                }
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'External Document No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("External Document No."));
                    end;
                }
                field(yourReference; Rec."Your Reference")
                {
                    Caption = 'Your Reference';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Your Reference"));
                    end;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Currency Code"));
                    end;
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Salesperson Code"));
                    end;
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                    Editable = false;
                }
                // --- NBC CRM affix fields (pipeline linkage tableextension) ---
                field(crmOpportunityNo; Rec."NBC CRM Opportunity No.")
                {
                    Caption = 'CRM Opportunity No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("NBC CRM Opportunity No."));
                    end;
                }
                field(crmSalesStatus; Rec."NBC CRM Sales Status")
                {
                    Caption = 'CRM Sales Status';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("NBC CRM Sales Status"));
                    end;
                }
                field(crmPricingLocked; Rec."NBC CRM Pricing Locked")
                {
                    Caption = 'CRM Pricing Locked';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("NBC CRM Pricing Locked"));
                    end;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        SalesHeaderRecordRef: RecordRef;
    begin
        FeatureMgt.CheckEnabled(Enum::"NBC Feature"::Linkage);
        Rec."Document Type" := Rec."Document Type"::Order;
        Rec.Insert(true);

        SalesHeaderRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(SalesHeaderRecordRef, TempFieldSet, CurrentDateTime());
        SalesHeaderRecordRef.SetTable(Rec);

        Rec.Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"NBC Feature"::Linkage);
        Rec.Modify(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"NBC Feature"::Linkage);
        exit(true);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        TempFieldSet.DeleteAll();
    end;

    var
        TempFieldSet: Record 2000000041 temporary;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        FeatureMgt: Codeunit "NBC Feature Mgt.";

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::"Sales Header", FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::"Sales Header";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}
