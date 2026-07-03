namespace NBC.Demo;

using Microsoft.CRM.Opportunity;
using NBC.CRM.Process;

/// <summary>
/// Idempotent CRONUS-style demo seeder for the Business Process Flow feature. The app's install codeunit
/// (NBC CRM Process Install -> NBC CRM Process Mgt.) already seeds the default "OPP-SALES" process and its
/// four stages (Qualify / Develop / Propose / Close), so this seeder does NOT redefine the stage model.
/// It COMPLEMENTS the install by creating a demonstrable NBC CRM Process State on the demo opportunity
/// (No. NBC-OPP-001, seeded by NBC Demo Opportunity, which runs before this in NBC Demo Data Mgt.) and
/// advancing it a couple of stages so the process bar shows a record mid-flow.
///
/// Re-running is safe: the state is guarded on its natural key (table no. + record SystemId), and the
/// referenced opportunity is defensively Get-guarded (falling back to the first opportunity in the company,
/// and exiting quietly when none exists).
/// </summary>
codeunit 50165 "NBC Demo Process"
{
    Access = Public;

    /// <summary>Seed a demo process state on the demo opportunity and advance it mid-flow. Idempotent.</summary>
    procedure Import()
    var
        Opportunity: Record Opportunity;
        State: Record "NBC CRM Process State";
        ProcessMgt: Codeunit "NBC CRM Process Mgt.";
    begin
        // Complement the install seed: make sure the default Opportunity process/stages exist even when
        // this runs outside the install trigger (e.g. a test harness). EnsureDefaultOpportunityProcess is
        // itself idempotent, so this never duplicates the OPP-SALES stage definitions.
        ProcessMgt.EnsureDefaultOpportunityProcess();

        // Defensive: we need a real opportunity record (for its SystemId) to attach a process state to.
        if not ResolveDemoOpportunity(Opportunity) then
            exit;

        // Idempotency: the state's natural key is (table no., record SystemId). If it already exists,
        // a prior run has seeded it — do nothing.
        State.SetLoadFields("Table No.", "Record System ID");
        if State.Get(Database::Opportunity, Opportunity.SystemId) then
            exit;

        // Create the state at the first stage (Qualify); returns false when the table has no active process.
        if not ProcessMgt.GetOrCreateState(Database::Opportunity, Opportunity.SystemId, State) then
            exit;

        // Advance a couple of stages so the demo record sits mid-flow: Qualify -> Develop -> Propose.
        ProcessMgt.AdvanceStage(Database::Opportunity, Opportunity.SystemId);
        ProcessMgt.AdvanceStage(Database::Opportunity, Opportunity.SystemId);

        CreateConfigPackage();
    end;

    /// <summary>Register a RapidStart config package covering the process tables for this feature.</summary>
    local procedure CreateConfigPackage()
    var
        ConfigPkg: Codeunit "NBC Demo Config Package";
    begin
        if not ConfigPkg.StartPackage(PackageCodeTok, PackageNameLbl) then
            exit;
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CRM Process");
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CRM Process Stage");
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CRM Process State");
    end;

    /// <summary>Resolve the demo opportunity: prefer the fixed demo No., else the first one in the company.</summary>
    local procedure ResolveDemoOpportunity(var Opportunity: Record Opportunity): Boolean
    begin
        Opportunity.SetLoadFields("No.");
        if Opportunity.Get(DemoOpportunityNo()) then
            exit(true);
        Opportunity.SetLoadFields("No.");
        exit(Opportunity.FindFirst());
    end;

    local procedure DemoOpportunityNo(): Code[20]
    begin
        exit('NBC-OPP-001');
    end;

    var
        PackageCodeTok: Label 'NBC-PROCESS', Locked = true;
        PackageNameLbl: Label 'CRM Business Process Flow';
}
