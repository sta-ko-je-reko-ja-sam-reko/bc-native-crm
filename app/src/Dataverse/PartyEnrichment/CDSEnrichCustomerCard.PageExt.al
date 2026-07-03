namespace NBC.Dataverse.PartyEnrichment;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Setup;
using Microsoft.Sales.Customer;
using NBC.Setup;

/// <summary>Classification &amp; preference groups + subsidiaries action on the Customer Card, gated by the Party Enrichment feature.</summary>
pageextension 50050 "NBC CDS Enrich Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(content)
        {
            group(NBCClassification)
            {
                Caption = 'CRM Classification';
                field("NBC CDS Parent Customer No."; Rec."NBC CDS Parent Customer No.") { ApplicationArea = NBCParty; AccessByPermission = tabledata "NBC Party Setup" = R; }
                field("NBC CDS Industry Group Code"; Rec."NBC CDS Industry Group Code") { ApplicationArea = NBCParty; AccessByPermission = tabledata "NBC Party Setup" = R; }
                field("NBC CDS Annual Revenue"; Rec."NBC CDS Annual Revenue") { ApplicationArea = NBCParty; AccessByPermission = tabledata "NBC Party Setup" = R; }
                field("NBC CDS No. of Employees"; Rec."NBC CDS No. of Employees") { ApplicationArea = NBCParty; AccessByPermission = tabledata "NBC Party Setup" = R; }
            }
            group(NBCPreferences)
            {
                Caption = 'CRM Preferences';
                field("NBC CDS Contact Method"; Rec."NBC CDS Contact Method") { ApplicationArea = NBCParty; AccessByPermission = tabledata "NBC Party Setup" = R; }
                field("NBC CDS Do Not Email"; Rec."NBC CDS Do Not Email") { ApplicationArea = NBCParty; AccessByPermission = tabledata "NBC Party Setup" = R; }
                field("NBC CDS Do Not Phone"; Rec."NBC CDS Do Not Phone") { ApplicationArea = NBCParty; AccessByPermission = tabledata "NBC Party Setup" = R; }
                field("NBC CDS Do Not Bulk Email"; Rec."NBC CDS Do Not Bulk Email") { ApplicationArea = NBCParty; AccessByPermission = tabledata "NBC Party Setup" = R; }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group(NBCEnrichActions)
            {
                Caption = 'CRM';
                action(NBCSubsidiaries)
                {
                    ApplicationArea = NBCParty;
                    AccessByPermission = tabledata "NBC Party Setup" = R;
                    Caption = 'Subsidiaries';
                    Image = Hierarchy;
                    ToolTip = 'Shows the customers whose parent is this customer.';

                    trigger OnAction()
                    var
                        ChildCustomer: Record Customer;
                    begin
                        ChildCustomer.SetRange("NBC CDS Parent Customer No.", Rec."No.");
                        Page.Run(Page::"Customer List", ChildCustomer);
                    end;
                }
            }
        }
    }
}
