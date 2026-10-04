namespace NBC.Test;

using NBC.Setup;
using System.Environment.Configuration;
using System.TestLibraries.Utilities;

/// <summary>
/// Feature setup and toggle (FEAT-SETUP-001): the per-feature Enabled flag read through NBC Feature Mgt., the
/// effective-permission guard in front of each setup read, the CheckEnabled write guard used by the API pages, and
/// the experience-tier subscriber that turns each feature's application area on or off.
/// </summary>
codeunit 69017 "NBC Feature Setup Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";
        FeatureMgt: Codeunit "NBC Feature Mgt.";
        FeatureWhileEnabledTok: Label '%1 while only %2 is enabled', Locked = true;
        NotEnabledTok: Label 'The %1 feature is not enabled.', Locked = true;

    [Test]
    procedure FeatureWithoutSetupRecordIsDisabled()
    var
        Feature: Enum "NBC Feature";
        Ordinal: Integer;
    begin
        // [GIVEN] no feature setup record exists
        TestLibrary.Initialize();
        TestLibrary.DeleteAllFeatureSetups();

        // [WHEN] each feature is checked  [THEN] it is disabled
        foreach Ordinal in Enum::"NBC Feature".Ordinals() do begin
            Feature := Enum::"NBC Feature".FromInteger(Ordinal);
            Assert.IsFalse(FeatureMgt.IsEnabled(Feature), Format(Feature));
        end;
    end;

    [Test]
    procedure EnablingOneFeatureLeavesTheOthersDisabled()
    var
        Feature: Enum "NBC Feature";
        Enabled: Enum "NBC Feature";
        Ordinal: Integer;
        EnabledOrdinal: Integer;
    begin
        TestLibrary.Initialize();
        foreach EnabledOrdinal in Enum::"NBC Feature".Ordinals() do begin
            // [GIVEN] only one feature is enabled
            Enabled := Enum::"NBC Feature".FromInteger(EnabledOrdinal);
            TestLibrary.DeleteAllFeatureSetups();
            TestLibrary.SetFeatureEnabled(Enabled, true);

            // [THEN] exactly that feature reports enabled
            foreach Ordinal in Enum::"NBC Feature".Ordinals() do begin
                Feature := Enum::"NBC Feature".FromInteger(Ordinal);
                Assert.AreEqual(Feature = Enabled, FeatureMgt.IsEnabled(Feature), StrSubstNo(FeatureWhileEnabledTok, Feature, Enabled));
            end;
        end;
    end;

    [Test]
    procedure SetupRecordWithEnabledFalseIsDisabled()
    var
        Feature: Enum "NBC Feature";
        Ordinal: Integer;
    begin
        // [GIVEN] every setup record exists but Enabled = false
        TestLibrary.Initialize();
        foreach Ordinal in Enum::"NBC Feature".Ordinals() do begin
            Feature := Enum::"NBC Feature".FromInteger(Ordinal);
            TestLibrary.SetFeatureEnabled(Feature, false);

            // [THEN] the feature is disabled
            Assert.IsFalse(FeatureMgt.IsEnabled(Feature), Format(Feature));
        end;
    end;

    [Test]
    procedure EnabledFeatureWithoutReadPermissionIsDisabled()
    var
        Feature: Enum "NBC Feature";
        Ordinal: Integer;
    begin
        // [GIVEN] every feature enabled
        TestLibrary.Initialize();
        foreach Ordinal in Enum::"NBC Feature".Ordinals() do
            TestLibrary.SetFeatureEnabled(Enum::"NBC Feature".FromInteger(Ordinal), true);

        // [GIVEN] a user without effective read permission on the setup tables (another tier / plan)
        TestLibrary.SetAccessGranted(false);

        // [THEN] every feature reads as disabled instead of raising a permission error
        foreach Ordinal in Enum::"NBC Feature".Ordinals() do begin
            Feature := Enum::"NBC Feature".FromInteger(Ordinal);
            Assert.IsFalse(FeatureMgt.IsEnabled(Feature), Format(Feature));
        end;
        TestLibrary.SetAccessGranted(true);
    end;

    [Test]
    procedure CheckEnabledPassesForEnabledFeature()
    begin
        // [GIVEN] Pricing enabled
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Pricing, true);

        // [WHEN] the write guard runs  [THEN] no error
        FeatureMgt.CheckEnabled(Enum::"NBC Feature"::Pricing);
    end;

    [Test]
    procedure CheckEnabledBlocksDisabledFeatureNamingIt()
    var
        Feature: Enum "NBC Feature";
        Ordinal: Integer;
    begin
        TestLibrary.Initialize();
        foreach Ordinal in Enum::"NBC Feature".Ordinals() do begin
            // [GIVEN] the feature disabled
            Feature := Enum::"NBC Feature".FromInteger(Ordinal);
            TestLibrary.SetFeatureEnabled(Feature, false);

            // [WHEN] the API write guard runs
            asserterror FeatureMgt.CheckEnabled(Feature);

            // [THEN] it errors and names the feature
            Assert.ExpectedError(StrSubstNo(NotEnabledTok, Format(Feature)));
        end;
    end;

    [Test]
    procedure ExperienceTierMirrorsTheEnabledFlags()
    var
        TempApplicationAreaSetup: Record "Application Area Setup" temporary;
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        // [GIVEN] Ownership, Pricing and Linkage enabled; everything else disabled
        TestLibrary.Initialize();
        TestLibrary.DeleteAllFeatureSetups();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Ownership, true);
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Pricing, true);
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Linkage, true);
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Catalog, false);

        // [WHEN] the essential experience application areas are computed
        ApplicationAreaMgmtFacade.GetEssentialExperienceAppAreas(TempApplicationAreaSetup);

        // [THEN] each CRM application area follows its feature flag
        Assert.IsTrue(TempApplicationAreaSetup."NBC Ownership", 'Ownership area');
        Assert.IsTrue(TempApplicationAreaSetup."NBC Pricing", 'Pricing area');
        Assert.IsTrue(TempApplicationAreaSetup."NBC Linkage", 'Linkage area');
        Assert.IsFalse(TempApplicationAreaSetup."NBC Catalog", 'Catalog area');
        Assert.IsFalse(TempApplicationAreaSetup."NBC Activities", 'Activities area');
        Assert.IsFalse(TempApplicationAreaSetup."NBC Party", 'Party area');
        Assert.IsFalse(TempApplicationAreaSetup."NBC Opportunity", 'Opportunity area');
        Assert.IsFalse(TempApplicationAreaSetup."NBC Process", 'Process area');
        Assert.IsFalse(TempApplicationAreaSetup."NBC Role Center", 'Role Center area');
        Assert.IsFalse(TempApplicationAreaSetup."NBC Governance", 'Governance area');
    end;

    [Test]
    procedure ExperienceTierHidesAreasForUserWithoutAccess()
    var
        TempApplicationAreaSetup: Record "Application Area Setup" temporary;
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        // [GIVEN] Opportunity enabled, but the user is not entitled to read its setup
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Opportunity, true);
        TestLibrary.SetAccessGranted(false);

        // [WHEN] the application areas are computed
        ApplicationAreaMgmtFacade.GetEssentialExperienceAppAreas(TempApplicationAreaSetup);
        TestLibrary.SetAccessGranted(true);

        // [THEN] the area stays off
        Assert.IsFalse(TempApplicationAreaSetup."NBC Opportunity", 'Opportunity area must stay off for an unentitled user.');
    end;
}
