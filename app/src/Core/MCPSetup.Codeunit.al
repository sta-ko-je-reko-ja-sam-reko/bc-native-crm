namespace NBC.Core;

using NBC.CRM.Catalog;
using NBC.CRM.Opportunity;
using NBC.CRM.Pricing;
using NBC.CRM.Process;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;
using NBC.Dataverse.PartyEnrichment;
using NBC.Demo;
using System.MCP;

/// <summary>
/// Demo-data seeder that exposes the CRM API pages as MCP (Copilot) tools — one MCP configuration per
/// module group. Uses the public facade codeunit 8350 "MCP Config" (never writes the MCP tables directly).
/// NOT auto-run — an admin invokes SeedModuleConfigurations (intended to sit behind an Assisted Setup).
/// </summary>
codeunit 50110 "NBC MCP Setup"
{
    Access = Public;

    /// <summary>Create and activate one MCP configuration per CRM module, each exposing its API pages.</summary>
    procedure SeedModuleConfigurations()
    begin
        SeedOwnership();
        SeedActivities();
        SeedOpportunity();
        SeedProcess();
        SeedCatalog();
        SeedPricing();
        SeedParty();
    end;

    local procedure SeedOwnership()
    var
        ConfigId: Guid;
    begin
        ConfigId := NewConfig('NBC CRM Ownership', 'CRM teams and team membership.');
        AddReadWriteTool(ConfigId, Page::"NBC CDS API Team");
        AddReadWriteTool(ConfigId, Page::"NBC CDS API Team Member");
        Activate(ConfigId);
    end;

    local procedure SeedActivities()
    var
        ConfigId: Guid;
    begin
        ConfigId := NewConfig('NBC CRM Activities', 'Unified CRM activity timeline.');
        AddReadWriteTool(ConfigId, Page::"NBC CDS API Activity");
        Activate(ConfigId);
    end;

    local procedure SeedOpportunity()
    var
        ConfigId: Guid;
    begin
        ConfigId := NewConfig('NBC CRM Opportunity', 'CRM opportunity depth: lines, competitors, stakeholders.');
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Opportunity");
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Opp. Line");
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Opp. Competitor");
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Opp. Stakeholder");
        Activate(ConfigId);
    end;

    local procedure SeedProcess()
    var
        ConfigId: Guid;
    begin
        ConfigId := NewConfig('NBC CRM Process', 'Guided business-process-flow stages and state.');
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Process");
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Process Stage");
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Process State");
        Activate(ConfigId);
    end;

    local procedure SeedCatalog()
    var
        ConfigId: Guid;
    begin
        ConfigId := NewConfig('NBC CRM Catalog', 'Product sales catalog: bundles, relations, item/resource CRM.');
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Bundle");
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Bundle Line");
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Product Rel.");
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Item");
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Resource");
        Activate(ConfigId);
    end;

    local procedure SeedPricing()
    var
        ConfigId: Guid;
    begin
        ConfigId := NewConfig('NBC CRM Pricing', 'Pricing flexibility: discount lists, tiers, price-line CRM.');
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Discount List");
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Discount Tier");
        AddReadWriteTool(ConfigId, Page::"NBC CRM API Price Line");
        Activate(ConfigId);
    end;

    local procedure SeedParty()
    var
        ConfigId: Guid;
    begin
        ConfigId := NewConfig('NBC CRM Party', 'CRM data on Customer and Contact (ownership, enrichment).');
        AddReadWriteTool(ConfigId, Page::"NBC CDS API Customer");
        AddReadWriteTool(ConfigId, Page::"NBC CDS API Contact");
        Activate(ConfigId);
    end;

    /// <summary>
    /// Create one **demo-import** MCP configuration per feature, each exposing ONLY that feature's ImportDemoData
    /// tool (its own demo&lt;Feature&gt; API group). Kept separate from the functional module configurations so each demo
    /// importer can be attached to a different Copilot agent. Run by an admin, distinct from SeedModuleConfigurations.
    /// </summary>
    procedure SeedDemoConfigurations()
    begin
        AddDemoConfig('NBC Demo Ownership', 'Seed CRONUS-style ownership demo data.', Page::"NBC API Demo Ownership");
        AddDemoConfig('NBC Demo Activities', 'Seed CRONUS-style activity demo data.', Page::"NBC API Demo Activities");
        AddDemoConfig('NBC Demo Party', 'Seed CRONUS-style party enrichment demo data.', Page::"NBC API Demo Party");
        AddDemoConfig('NBC Demo Opportunity', 'Seed CRONUS-style opportunity demo data.', Page::"NBC API Demo Opportunity");
        AddDemoConfig('NBC Demo Process', 'Seed CRONUS-style business-process demo data.', Page::"NBC API Demo Process");
        AddDemoConfig('NBC Demo Role Center', 'Seed the role-center demo context.', Page::"NBC API Demo Role Center");
        AddDemoConfig('NBC Demo Governance', 'Seed CRONUS-style governance demo data.', Page::"NBC API Demo Governance");
        AddDemoConfig('NBC Demo Catalog', 'Seed CRONUS-style catalog demo data.', Page::"NBC API Demo Catalog");
        AddDemoConfig('NBC Demo Pricing', 'Seed CRONUS-style pricing demo data.', Page::"NBC API Demo Pricing");
        AddDemoConfig('NBC Demo Linkage', 'Seed CRONUS-style pipeline-linkage demo data.', Page::"NBC API Demo Linkage");
    end;

    local procedure AddDemoConfig(Name: Text[100]; Description: Text[250]; APIPageId: Integer)
    var
        MCPConfig: Codeunit "MCP Config";
        ConfigId: Guid;
        ToolId: Guid;
    begin
        ConfigId := MCPConfig.CreateConfiguration(Name, Description);
        ToolId := MCPConfig.CreateAPITool(ConfigId, APIPageId);
        MCPConfig.AllowRead(ToolId, true);
        MCPConfig.ActivateConfiguration(ConfigId, true);
    end;

    local procedure NewConfig(Name: Text[100]; Description: Text[250]): Guid
    var
        MCPConfig: Codeunit "MCP Config";
        ConfigId: Guid;
    begin
        ConfigId := MCPConfig.CreateConfiguration(Name, Description);
        MCPConfig.AllowCreateUpdateDeleteTools(ConfigId, true);
        exit(ConfigId);
    end;

    local procedure AddReadWriteTool(ConfigId: Guid; APIPageId: Integer)
    var
        MCPConfig: Codeunit "MCP Config";
        ToolId: Guid;
    begin
        ToolId := MCPConfig.CreateAPITool(ConfigId, APIPageId);
        MCPConfig.AllowRead(ToolId, true);
        MCPConfig.AllowCreate(ToolId, true);
        MCPConfig.AllowModify(ToolId, true);
    end;

    local procedure Activate(ConfigId: Guid)
    var
        MCPConfig: Codeunit "MCP Config";
    begin
        MCPConfig.ActivateConfiguration(ConfigId, true);
    end;
}
