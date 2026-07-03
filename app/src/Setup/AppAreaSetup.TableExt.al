namespace NBC.Setup;

using System.Environment.Configuration;

/// <summary>
/// Registers one application area per CRM feature. The field name (spaces removed) is the ApplicationArea
/// tag used on that feature's pages; the area is switched on/off from the feature setup's Enabled flag by
/// the <see cref="NBC App Area Subscriber"/>.
/// </summary>
tableextension 50130 "NBC App Area Setup" extends "Application Area Setup"
{
    fields
    {
        field(50130; "NBC Ownership"; Boolean) { DataClassification = SystemMetadata; }
        field(50131; "NBC Activities"; Boolean) { DataClassification = SystemMetadata; }
        field(50132; "NBC Party"; Boolean) { DataClassification = SystemMetadata; }
        field(50133; "NBC Opportunity"; Boolean) { DataClassification = SystemMetadata; }
        field(50134; "NBC Process"; Boolean) { DataClassification = SystemMetadata; }
        field(50135; "NBC Role Center"; Boolean) { DataClassification = SystemMetadata; }
        field(50136; "NBC Governance"; Boolean) { DataClassification = SystemMetadata; }
        field(50137; "NBC Catalog"; Boolean) { DataClassification = SystemMetadata; }
        field(50138; "NBC Pricing"; Boolean) { DataClassification = SystemMetadata; }
        field(50139; "NBC Linkage"; Boolean) { DataClassification = SystemMetadata; }
    }
}
