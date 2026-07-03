namespace NBC.CRM.Catalog;

using Microsoft.Inventory.Item;
using NBC.Setup;

/// <summary>CRM catalog group (lifecycle, sell window) + Related Products action on the Item Card, gated by the Catalog feature.</summary>
pageextension 50090 "NBC CRM Catalog Item Card" extends "Item Card"
{
    layout
    {
        addlast(content)
        {
            group(NBCCatalog)
            {
                Caption = 'CRM Catalog';
                field("NBC CRM Catalog Status"; Rec."NBC CRM Catalog Status") { ApplicationArea = NBCCatalog; AccessByPermission = tabledata "NBC Catalog Setup" = R; }
                field("NBC CRM Valid From"; Rec."NBC CRM Valid From") { ApplicationArea = NBCCatalog; AccessByPermission = tabledata "NBC Catalog Setup" = R; }
                field("NBC CRM Valid To"; Rec."NBC CRM Valid To") { ApplicationArea = NBCCatalog; AccessByPermission = tabledata "NBC Catalog Setup" = R; }
                field("NBC CRM Default Price List"; Rec."NBC CRM Default Price List") { ApplicationArea = NBCCatalog; AccessByPermission = tabledata "NBC Catalog Setup" = R; }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group(NBCCatalogActions)
            {
                Caption = 'CRM';
                action(NBCPublish)
                {
                    ApplicationArea = NBCCatalog;
                    AccessByPermission = tabledata "NBC Catalog Setup" = R;
                    Caption = 'Publish';
                    Image = Approve;
                    ToolTip = 'Marks the item as active and sellable.';

                    trigger OnAction()
                    var
                        CatalogMgt: Codeunit "NBC CRM Catalog Mgt.";
                    begin
                        CatalogMgt.PublishItem(Rec);
                    end;
                }
                action(NBCRetire)
                {
                    ApplicationArea = NBCCatalog;
                    AccessByPermission = tabledata "NBC Catalog Setup" = R;
                    Caption = 'Retire';
                    Image = Reject;
                    ToolTip = 'Withdraws the item from selling.';

                    trigger OnAction()
                    var
                        CatalogMgt: Codeunit "NBC CRM Catalog Mgt.";
                    begin
                        CatalogMgt.RetireItem(Rec);
                    end;
                }
                action(NBCRelatedProducts)
                {
                    ApplicationArea = NBCCatalog;
                    AccessByPermission = tabledata "NBC Catalog Setup" = R;
                    Caption = 'Related Products';
                    Image = Relationship;
                    ToolTip = 'Shows the cross-sell, up-sell, accessory and substitute products for this item.';

                    trigger OnAction()
                    var
                        BundleMgt: Codeunit "NBC CRM Bundle Mgt.";
                    begin
                        BundleMgt.ShowRelatedProductsForItem(Rec);
                    end;
                }
            }
        }
    }
}
