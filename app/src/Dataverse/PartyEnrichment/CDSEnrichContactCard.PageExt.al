namespace NBC.Dataverse.PartyEnrichment;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Setup;
using Microsoft.Sales.Customer;
using NBC.Setup;

/// <summary>CRM preference group on the Contact Card, gated by the Party Enrichment feature.</summary>
pageextension 50051 "NBC CDS Enrich Contact Card" extends "Contact Card"
{
    layout
    {
        addlast(content)
        {
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
}
