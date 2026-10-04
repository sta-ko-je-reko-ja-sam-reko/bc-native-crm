namespace NBC.Test;

using NBC.Core;
using NBC.Setup;
using System.TestLibraries.Utilities;

/// <summary>
/// Core service resolution: the single-instance Service Locator hands out the injected implementation, and the
/// default access policy answers effective-permission checks for the (permission-disabled) test user.
/// </summary>
codeunit 69021 "NBC Service Locator Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";

    [Test]
    procedure InjectedAccessPolicyIsResolved()
    var
        ServiceLocator: Codeunit "NBC Service Locator";
    begin
        // [GIVEN] a denying access policy injected
        TestLibrary.SetAccessGranted(false);

        // [WHEN] the locator resolves the policy  [THEN] the fake answers
        Assert.IsFalse(ServiceLocator.AccessPolicy().HasEffectiveRead(Database::"NBC Ownership Setup"), 'Denying fake must answer read.');
        Assert.IsFalse(ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"NBC Service Locator"), 'Denying fake must answer execute.');

        // [WHEN] a granting policy is injected  [THEN] the new one replaces it
        TestLibrary.SetAccessGranted(true);
        Assert.IsTrue(ServiceLocator.AccessPolicy().HasEffectiveRead(Database::"NBC Ownership Setup"), 'Granting fake must answer read.');
    end;

    [Test]
    procedure InjectionIsSharedAcrossLocatorInstances()
    var
        ServiceLocator: Codeunit "NBC Service Locator";
        OtherServiceLocator: Codeunit "NBC Service Locator";
        FakeAccessPolicy: Codeunit "NBC Fake Access Policy";
    begin
        // [GIVEN] a policy injected through one locator variable
        FakeAccessPolicy.SetGrant(false);
        ServiceLocator.ImplementAccessPolicy(FakeAccessPolicy);

        // [THEN] another variable sees the same implementation (SingleInstance)
        Assert.IsFalse(OtherServiceLocator.AccessPolicy().HasEffectiveExecute(0), 'The locator must be single instance.');
        TestLibrary.Initialize();
    end;

    [Test]
    procedure DefaultAccessPolicyGrantsTheTestUser()
    var
        ServiceLocator: Codeunit "NBC Service Locator";
    begin
        // [GIVEN] the app's own effective-permission policy
        TestLibrary.RestoreDefaultAccessPolicy();

        // [WHEN] checking objects the test user (SUPER in the dev container) can use
        // [THEN] both checks pass, and repeated (cached) checks agree
        Assert.IsTrue(ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"NBC Service Locator"), 'Execute on the locator.');
        Assert.IsTrue(ServiceLocator.AccessPolicy().HasEffectiveExecute(Codeunit::"NBC Service Locator"), 'Cached execute on the locator.');
        Assert.IsTrue(ServiceLocator.AccessPolicy().HasEffectiveRead(Database::"NBC Ownership Setup"), 'Read on a setup table.');
        TestLibrary.Initialize();
    end;
}
