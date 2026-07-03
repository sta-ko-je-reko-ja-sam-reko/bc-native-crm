namespace NBC.Demo;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>
/// Idempotent demo-data seeder for the CRM Ownership feature (FEAT-OWN-001): CRONUS-style CRM teams,
/// their salesperson membership, and sample record ownership stamped on standard Customer/Contact master data.
/// Every reference to standard CRONUS master data is Get-guarded, so the seeder skips gracefully
/// (never errors) on a non-CRONUS company. Safe to run repeatedly — fixed keys guard every insert.
/// </summary>
codeunit 50161 "NBC Demo Ownership"
{
    Access = Public;

    /// <summary>Seed sample CRM teams, team members and record ownership. Idempotent and defensive.</summary>
    procedure Import()
    begin
        SeedTeams();
        SeedTeamMembers();
        SeedCustomerOwners();
        SeedContactOwners();
        CreateConfigPackage();
    end;

    local procedure SeedTeams()
    begin
        InsertTeam('SALES-EU', 'European Sales Team', 'Owns EU accounts and opportunities.', 'JR');
        InsertTeam('SALES-US', 'North American Sales Team', 'Owns US accounts and opportunities.', 'PS');
    end;

    local procedure SeedTeamMembers()
    begin
        InsertTeamMember('SALES-EU', 'JR', true);
        InsertTeamMember('SALES-EU', 'RL', false);
        InsertTeamMember('SALES-US', 'PS', true);
        InsertTeamMember('SALES-US', 'RL', false);
    end;

    local procedure SeedCustomerOwners()
    begin
        StampCustomerOwner('10000', "NBC CDS Owner Type"::Salesperson, 'JR');
        StampCustomerOwner('20000', "NBC CDS Owner Type"::Team, 'SALES-EU');
        StampCustomerOwner('30000', "NBC CDS Owner Type"::Team, 'SALES-US');
    end;

    local procedure SeedContactOwners()
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields("Primary Contact No.");
        if Customer.Get('10000') then
            StampContactOwner(Customer."Primary Contact No.", "NBC CDS Owner Type"::Salesperson, 'JR');
        Customer.SetLoadFields("Primary Contact No.");
        if Customer.Get('20000') then
            StampContactOwner(Customer."Primary Contact No.", "NBC CDS Owner Type"::Team, 'SALES-EU');
    end;

    local procedure InsertTeam(TeamCode: Code[20]; TeamName: Text[100]; TeamDescription: Text[250]; TeamLeadSalesperson: Code[20])
    var
        Team: Record "NBC CDS Team";
    begin
        if Team.Get(TeamCode) then
            exit;
        Team.Init();
        Team.Validate(Code, TeamCode);
        Team.Validate(Name, TeamName);
        Team.Validate(Description, TeamDescription);
        if SalespersonExists(TeamLeadSalesperson) then
            Team.Validate("Team Lead Salesp. Code", TeamLeadSalesperson);
        Team.Insert(true);
    end;

    local procedure InsertTeamMember(TeamCode: Code[20]; SalespersonCode: Code[20]; IsTeamLead: Boolean)
    var
        TeamMember: Record "NBC CDS Team Member";
        Team: Record "NBC CDS Team";
    begin
        Team.SetLoadFields(Code);
        if not Team.Get(TeamCode) then
            exit;
        if not SalespersonExists(SalespersonCode) then
            exit;
        if TeamMember.Get(TeamCode, SalespersonCode) then
            exit;
        TeamMember.Init();
        TeamMember.Validate("Team Code", TeamCode);
        TeamMember.Validate("Salesperson Code", SalespersonCode);
        TeamMember.Validate("Team Lead", IsTeamLead);
        TeamMember.Insert(true);
    end;

    local procedure StampCustomerOwner(CustomerNo: Code[20]; OwnerType: Enum "NBC CDS Owner Type"; OwnerCode: Code[20])
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then
            exit;
        if not OwnerCodeExists(OwnerType, OwnerCode) then
            exit;
        Customer.Validate("NBC CDS Owner Type", OwnerType);
        Customer.Validate("NBC CDS Owner Code", OwnerCode);
        Customer.Modify(true);
    end;

    local procedure StampContactOwner(ContactNo: Code[20]; OwnerType: Enum "NBC CDS Owner Type"; OwnerCode: Code[20])
    var
        Contact: Record Contact;
    begin
        if ContactNo = '' then
            exit;
        if not Contact.Get(ContactNo) then
            exit;
        if not OwnerCodeExists(OwnerType, OwnerCode) then
            exit;
        Contact.Validate("NBC CDS Owner Type", OwnerType);
        Contact.Validate("NBC CDS Owner Code", OwnerCode);
        Contact.Modify(true);
    end;

    local procedure OwnerCodeExists(OwnerType: Enum "NBC CDS Owner Type"; OwnerCode: Code[20]): Boolean
    var
        Team: Record "NBC CDS Team";
    begin
        case OwnerType of
            OwnerType::Salesperson:
                exit(SalespersonExists(OwnerCode));
            OwnerType::Team:
                begin
                    Team.SetLoadFields(Code);
                    exit(Team.Get(OwnerCode));
                end;
        end;
        exit(false);
    end;

    local procedure SalespersonExists(SalespersonCode: Code[20]): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if SalespersonCode = '' then
            exit(false);
        Salesperson.SetLoadFields(Code);
        exit(Salesperson.Get(SalespersonCode));
    end;

    local procedure CreateConfigPackage()
    var
        ConfigPkg: Codeunit "NBC Demo Config Package";
        AffixFieldNos: List of [Integer];
    begin
        if not ConfigPkg.StartPackage(PackageCodeTok, PackageNameLbl) then
            exit;
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CDS Team");
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CDS Team Member");
        AffixFieldNos.Add(50020);
        AffixFieldNos.Add(50021);
        ConfigPkg.AddExtendedTable(PackageCodeTok, Database::Customer, AffixFieldNos);
        Clear(AffixFieldNos);
        AffixFieldNos.Add(50020);
        AffixFieldNos.Add(50021);
        ConfigPkg.AddExtendedTable(PackageCodeTok, Database::Contact, AffixFieldNos);
    end;

    var
        PackageCodeTok: Label 'NBC-OWNERSHIP', Locked = true;
        PackageNameLbl: Label 'CRM Ownership and Teams';
}
