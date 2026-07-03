namespace NBC.Setup;

using NBC.Core;
using System.Environment;
using System.Environment.Configuration;

/// <summary>
/// Shared feature facade: reads each feature setup's Enabled flag and applies an enable/disable change by
/// recomputing the application areas and restarting the session. SingleInstance. Reachable by every user
/// (granted via the Unlicensed base-subscriber entitlement) so the app-area subscriber can call it at
/// sign-in; each setup read is guarded by the user's EFFECTIVE read permission (checked by object id via the
/// MS Effective Permissions Mgt., never by instantiating our own — possibly unlicensed — table), so a user
/// who owns only some tiers gets "false" for the rest instead of a permission error.
/// </summary>
codeunit 50120 "NBC Feature Mgt."
{
    Access = Public;
    SingleInstance = true;

    /// <summary>True when the given feature's setup is readable by the user and its Enabled flag is set.</summary>
    procedure IsEnabled(Feature: Enum "NBC Feature"): Boolean
    var
        OwnershipSetup: Record "NBC Ownership Setup";
        ActivitySetup: Record "NBC Activity Setup";
        PartySetup: Record "NBC Party Setup";
        OpportunitySetup: Record "NBC Opportunity Setup";
        ProcessSetup: Record "NBC Process Setup";
        RoleCenterSetup: Record "NBC Role Center Setup";
        GovernanceSetup: Record "NBC Governance Setup";
        CatalogSetup: Record "NBC Catalog Setup";
        PricingSetup: Record "NBC Pricing Setup";
        LinkageSetup: Record "NBC Linkage Setup";
    begin
        case Feature of
            Feature::Ownership:
                if HasEffectiveRead(Database::"NBC Ownership Setup") and OwnershipSetup.Get() then
                    exit(OwnershipSetup.Enabled);
            Feature::Activities:
                if HasEffectiveRead(Database::"NBC Activity Setup") and ActivitySetup.Get() then
                    exit(ActivitySetup.Enabled);
            Feature::Party:
                if HasEffectiveRead(Database::"NBC Party Setup") and PartySetup.Get() then
                    exit(PartySetup.Enabled);
            Feature::Opportunity:
                if HasEffectiveRead(Database::"NBC Opportunity Setup") and OpportunitySetup.Get() then
                    exit(OpportunitySetup.Enabled);
            Feature::Process:
                if HasEffectiveRead(Database::"NBC Process Setup") and ProcessSetup.Get() then
                    exit(ProcessSetup.Enabled);
            Feature::RoleCenter:
                if HasEffectiveRead(Database::"NBC Role Center Setup") and RoleCenterSetup.Get() then
                    exit(RoleCenterSetup.Enabled);
            Feature::Governance:
                if HasEffectiveRead(Database::"NBC Governance Setup") and GovernanceSetup.Get() then
                    exit(GovernanceSetup.Enabled);
            Feature::Catalog:
                if HasEffectiveRead(Database::"NBC Catalog Setup") and CatalogSetup.Get() then
                    exit(CatalogSetup.Enabled);
            Feature::Pricing:
                if HasEffectiveRead(Database::"NBC Pricing Setup") and PricingSetup.Get() then
                    exit(PricingSetup.Enabled);
            Feature::Linkage:
                if HasEffectiveRead(Database::"NBC Linkage Setup") and LinkageSetup.Get() then
                    exit(LinkageSetup.Enabled);
        end;
        exit(false);
    end;

    /// <summary>Errors when the feature is disabled — call from API write triggers so the toggle also gates the API/MCP path.</summary>
    procedure CheckEnabled(Feature: Enum "NBC Feature")
    var
        DisabledErr: Label 'The %1 feature is not enabled. An administrator can turn it on in its setup page.', Comment = '%1 = feature name';
    begin
        if not IsEnabled(Feature) then
            Error(DisabledErr, Format(Feature));
    end;

    /// <summary>Recompute the application areas from the setups and restart the session so the change takes effect.</summary>
    procedure ApplyExperienceChange(NowEnabled: Boolean)
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        SessionSetting: SessionSettings;
        RestartDialog: Dialog;
        Countdown: Integer;
        EnableRestartMsg: Label 'The session will restart in #1 second(s) because a CRM feature has been enabled.', Comment = '#1 = seconds remaining';
        DisableRestartMsg: Label 'The session will restart in #1 second(s) because a CRM feature has been disabled.', Comment = '#1 = seconds remaining';
    begin
        ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
        if NowEnabled then
            RestartDialog.Open(EnableRestartMsg)
        else
            RestartDialog.Open(DisableRestartMsg);
        for Countdown := 5 downto 1 do begin
            RestartDialog.Update(1, Countdown);
            Sleep(1000);
        end;
        RestartDialog.Close();
        SessionSetting.Init();
        SessionSetting.RequestSessionUpdate(true);
    end;

    /// <summary>The current user's effective read permission on a table — delegated to the swappable access policy.</summary>
    local procedure HasEffectiveRead(TableId: Integer): Boolean
    var
        ServiceLocator: Codeunit "NBC Service Locator";
    begin
        exit(ServiceLocator.AccessPolicy().HasEffectiveRead(TableId));
    end;
}
