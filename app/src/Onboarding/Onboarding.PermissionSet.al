namespace NBC.Onboarding;

/// <summary>Permissions for the per-feature Assisted Setup wizards and their Guided Experience registration.</summary>
permissionset 50184 "NBC Onboarding"
{
    Caption = 'CRM Onboarding';
    Assignable = true;

    Permissions =
        codeunit "NBC Assisted Setup" = X,
        page "NBC Ownership Setup Wizard" = X,
        page "NBC Activities Setup Wizard" = X,
        page "NBC Party Setup Wizard" = X,
        page "NBC Opportunity Setup Wizard" = X,
        page "NBC Process Setup Wizard" = X,
        page "NBC Role Center Setup Wizard" = X,
        page "NBC Governance Setup Wizard" = X,
        page "NBC Catalog Setup Wizard" = X,
        page "NBC Pricing Setup Wizard" = X,
        page "NBC Linkage Setup Wizard" = X;
}
