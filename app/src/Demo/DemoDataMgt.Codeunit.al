namespace NBC.Demo;

/// <summary>
/// Master demo-data runner: seeds every feature's CRONUS-style sample data in dependency order (owners and
/// enrichment before opportunities; opportunities before process and linkage). Each feature seeder is idempotent,
/// so SeedAll is safe to re-run. Called by an admin / assisted setup; the per-feature import APIs call their own
/// seeder directly for agent-scoped seeding.
/// </summary>
codeunit 50181 "NBC Demo Data Mgt."
{
    Access = Public;

    /// <summary>Run every feature's demo seeder in dependency order.</summary>
    procedure SeedAll()
    var
        DemoOwnership: Codeunit "NBC Demo Ownership";
        DemoParty: Codeunit "NBC Demo Party";
        DemoCatalog: Codeunit "NBC Demo Catalog";
        DemoPricing: Codeunit "NBC Demo Pricing";
        DemoOpportunity: Codeunit "NBC Demo Opportunity";
        DemoProcess: Codeunit "NBC Demo Process";
        DemoActivities: Codeunit "NBC Demo Activities";
        DemoGovernance: Codeunit "NBC Demo Governance";
        DemoRoleCenter: Codeunit "NBC Demo Role Center";
        DemoLinkage: Codeunit "NBC Demo Linkage";
    begin
        DemoOwnership.Import();
        DemoParty.Import();
        DemoCatalog.Import();
        DemoPricing.Import();
        DemoOpportunity.Import();
        DemoProcess.Import();
        DemoActivities.Import();
        DemoGovernance.Import();
        DemoRoleCenter.Import();
        DemoLinkage.Import();
    end;
}
