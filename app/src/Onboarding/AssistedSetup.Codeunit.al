namespace NBC.Onboarding;

using System.Environment.Configuration;
using System.Media;

/// <summary>
/// Registers each feature's setup wizard in the system Assisted Setup list (Guided Experience), so an end user can
/// run the guided setup — enable the feature and optionally load its sample data — without any agent/MCP. Subscribes
/// to OnRegisterAssistedSetup so registration re-runs; skip-safe for unentitled users.
/// </summary>
codeunit 50183 "NBC Assisted Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", OnRegisterAssistedSetup, '', true, true)]
    local procedure OnRegisterAssistedSetup()
    begin
        Register(OwnershipTitleLbl, Page::"NBC Ownership Setup Wizard");
        Register(ActivitiesTitleLbl, Page::"NBC Activities Setup Wizard");
        Register(PartyTitleLbl, Page::"NBC Party Setup Wizard");
        Register(OpportunityTitleLbl, Page::"NBC Opportunity Setup Wizard");
        Register(ProcessTitleLbl, Page::"NBC Process Setup Wizard");
        Register(RoleCenterTitleLbl, Page::"NBC Role Center Setup Wizard");
        Register(GovernanceTitleLbl, Page::"NBC Governance Setup Wizard");
        Register(CatalogTitleLbl, Page::"NBC Catalog Setup Wizard");
        Register(PricingTitleLbl, Page::"NBC Pricing Setup Wizard");
        Register(LinkageTitleLbl, Page::"NBC Linkage Setup Wizard");
    end;

    local procedure Register(Title: Text[100]; WizardPageId: Integer)
    var
        GuidedExperience: Codeunit "Guided Experience";
        DescLbl: Label 'Enable %1 and, optionally, load sample data into the current company.', Comment = '%1 = feature name';
    begin
        GuidedExperience.InsertAssistedSetup(
            Title, CopyStr(Title, 1, 50), StrSubstNo(DescLbl, Title), 5,
            ObjectType::Page, WizardPageId, "Assisted Setup Group"::ReadyForBusiness, '', "Video Category"::Uncategorized, '');
    end;

    var
        OwnershipTitleLbl: Label 'Set up CRM Ownership and Teams';
        ActivitiesTitleLbl: Label 'Set up CRM Activities and Timeline';
        PartyTitleLbl: Label 'Set up CRM Party Enrichment';
        OpportunityTitleLbl: Label 'Set up CRM Opportunity Depth';
        ProcessTitleLbl: Label 'Set up CRM Business Process Flow';
        RoleCenterTitleLbl: Label 'Set up the CRM Role Center';
        GovernanceTitleLbl: Label 'Set up CRM Governance';
        CatalogTitleLbl: Label 'Set up the CRM Product Catalog';
        PricingTitleLbl: Label 'Set up CRM Pricing Flexibility';
        LinkageTitleLbl: Label 'Set up CRM Pipeline Linkage';
}
