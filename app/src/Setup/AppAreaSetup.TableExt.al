namespace NBC.Setup;

using System.Environment.Configuration;

/// <summary>
/// Registers one application area per CRM feature. The field name (spaces removed) is the ApplicationArea
/// tag used on that feature's pages; the area is switched on/off from the feature setup's Enabled flag by
/// the <see cref="NBC App Area Subscriber"/>.
/// </summary>
tableextension 65130 "NBC App Area Setup" extends "Application Area Setup"
{
    fields
    {
        field(65130; "NBC Ownership"; Boolean) { DataClassification = SystemMetadata; }
        field(65131; "NBC Activities"; Boolean) { DataClassification = SystemMetadata; }
        field(65132; "NBC Party"; Boolean) { DataClassification = SystemMetadata; }
        field(65133; "NBC Opportunity"; Boolean) { DataClassification = SystemMetadata; }
        field(65134; "NBC Process"; Boolean) { DataClassification = SystemMetadata; }
        field(65135; "NBC Role Center"; Boolean) { DataClassification = SystemMetadata; }
        field(65136; "NBC Governance"; Boolean) { DataClassification = SystemMetadata; }
        field(65137; "NBC Catalog"; Boolean) { DataClassification = SystemMetadata; }
        field(65138; "NBC Pricing"; Boolean) { DataClassification = SystemMetadata; }
        field(65139; "NBC Linkage"; Boolean) { DataClassification = SystemMetadata; }
    }
}
