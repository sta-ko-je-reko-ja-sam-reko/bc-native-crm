namespace NBC.Demo;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.CRM.Opportunity;
using NBC.Dataverse.Ownership;

/// <summary>
/// Idempotent CRONUS-style seeder for the Opportunity Depth feature (FEAT-OPP-001).
/// Creates a small set of standard Opportunity records plus their CRM depth: owner + rating,
/// item/resource/comment lines (which roll up to estimated revenue), competitors and stakeholders.
/// All CRONUS references are Get-guarded; missing references cause the affected row to be skipped,
/// never an error. Re-running Import() is a no-op for rows that already exist (fixed keys + Get).
/// </summary>
codeunit 50164 "NBC Demo Opportunity"
{
    Access = Public;

    var
        FallbackUnitPrice: Decimal;
        PackageCodeTok: Label 'NBC-OPPORTUNITY', Locked = true;
        PackageNameLbl: Label 'CRM Opportunity Depth';

    /// <summary>Seed the demo opportunities and their depth. Safe to call repeatedly.</summary>
    procedure Import()
    var
        Salesperson: Record "Salesperson/Purchaser";
        Contact: Record Contact;
    begin
        FallbackUnitPrice := 100;

        // Standard Opportunity requires a Contact No. and a Salesperson Code; if neither can be
        // resolved from the demo company there is nothing meaningful to seed.
        Salesperson.SetLoadFields(Code);
        if not Salesperson.FindFirst() then
            exit;
        Contact.SetLoadFields("No.", "Company No.");
        if not Contact.FindFirst() then
            exit;

        SeedOpportunity('NBC-OPP-001', 'Enterprise CRM rollout', Enum::"NBC CRM Opportunity Rating"::Hot, Salesperson, Contact);
        SeedOpportunity('NBC-OPP-002', 'Retail expansion deal', Enum::"NBC CRM Opportunity Rating"::Warm, Salesperson, Contact);
        SeedOpportunity('NBC-OPP-003', 'Legacy replacement bid', Enum::"NBC CRM Opportunity Rating"::Cold, Salesperson, Contact);

        CreateConfigPackage();
    end;

    local procedure CreateConfigPackage()
    var
        ConfigPkg: Codeunit "NBC Demo Config Package";
        AffixFieldNos: List of [Integer];
    begin
        if not ConfigPkg.StartPackage(PackageCodeTok, PackageNameLbl) then
            exit;
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CRM Opp. Line");
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CRM Opp. Competitor");
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CRM Opp. Stakeholder");
        AffixFieldNos.Add(50040);
        AffixFieldNos.Add(50041);
        AffixFieldNos.Add(50042);
        ConfigPkg.AddExtendedTable(PackageCodeTok, Database::Opportunity, AffixFieldNos);
    end;

    local procedure SeedOpportunity(OppNo: Code[20]; Descr: Text[100]; Rating: Enum "NBC CRM Opportunity Rating"; var Salesperson: Record "Salesperson/Purchaser"; var Contact: Record Contact)
    var
        Opportunity: Record Opportunity;
    begin
        Opportunity.SetLoadFields("No.");
        if not Opportunity.Get(OppNo) then begin
            Opportunity.Init();
            Opportunity."No." := OppNo;
            Opportunity.Description := Descr;
            Opportunity."Salesperson Code" := Salesperson."Code";
            Opportunity."Contact No." := Contact."No.";
            Opportunity."Contact Company No." := Contact."Company No.";
            Opportunity."NBC CDS Owner Type" := Opportunity."NBC CDS Owner Type"::Salesperson;
            Opportunity."NBC CDS Owner Code" := Salesperson."Code";
            Opportunity."NBC CRM Rating" := Rating;
            Opportunity.Insert(true);
        end;

        AddLines(OppNo);
        AddCompetitors(OppNo);
        AddStakeholders(OppNo);
    end;

    local procedure AddLines(OppNo: Code[20])
    var
        Item: Record Item;
        Resource: Record Resource;
    begin
        // Item lines (Type::Item) — reference CRONUS items 1000 / 1100 when present.
        Item.SetLoadFields("No.");
        if Item.Get('1000') then
            AddItemLine(OppNo, 10000, Item."No.", 5);
        Item.SetLoadFields("No.");
        if Item.Get('1100') then
            AddItemLine(OppNo, 20000, Item."No.", 2);

        // Resource line (Type::Resource) — first available CRONUS resource.
        Resource.SetLoadFields("No.");
        if Resource.FindFirst() then
            AddResourceLine(OppNo, 30000, Resource."No.", 8);

        // Comment line (Type::Comment) — no item/resource, no amount.
        AddCommentLine(OppNo, 40000, 'Awaiting customer budget approval.');
    end;

    local procedure AddItemLine(OppNo: Code[20]; LineNo: Integer; ItemNo: Code[20]; Qty: Decimal)
    var
        OppLine: Record "NBC CRM Opp. Line";
    begin
        if OppLine.Get(OppNo, LineNo) then
            exit;

        OppLine.Init();
        OppLine."Opportunity No." := OppNo;
        OppLine."Line No." := LineNo;
        OppLine.Validate(Type, OppLine.Type::Item);
        OppLine.Validate("No.", ItemNo);
        if OppLine."Unit Price" = 0 then
            OppLine.Validate("Unit Price", FallbackUnitPrice);
        OppLine.Validate(Quantity, Qty);
        OppLine.Insert(true);
    end;

    local procedure AddResourceLine(OppNo: Code[20]; LineNo: Integer; ResourceNo: Code[20]; Qty: Decimal)
    var
        OppLine: Record "NBC CRM Opp. Line";
    begin
        if OppLine.Get(OppNo, LineNo) then
            exit;

        OppLine.Init();
        OppLine."Opportunity No." := OppNo;
        OppLine."Line No." := LineNo;
        OppLine.Validate(Type, OppLine.Type::Resource);
        OppLine.Validate("No.", ResourceNo);
        if OppLine."Unit Price" = 0 then
            OppLine.Validate("Unit Price", FallbackUnitPrice);
        OppLine.Validate(Quantity, Qty);
        OppLine.Insert(true);
    end;

    local procedure AddCommentLine(OppNo: Code[20]; LineNo: Integer; CommentText: Text[100])
    var
        OppLine: Record "NBC CRM Opp. Line";
    begin
        if OppLine.Get(OppNo, LineNo) then
            exit;

        OppLine.Init();
        OppLine."Opportunity No." := OppNo;
        OppLine."Line No." := LineNo;
        OppLine.Validate(Type, OppLine.Type::Comment);
        OppLine.Description := CommentText;
        OppLine.Insert(true);
    end;

    local procedure AddCompetitors(OppNo: Code[20])
    begin
        // Cover every Threat Level value.
        AddCompetitor(OppNo, 10000, 'Acme Solutions', Enum::"NBC CRM Threat Level"::Low, 'Low price', 'Poor support');
        AddCompetitor(OppNo, 20000, 'Globex Systems', Enum::"NBC CRM Threat Level"::Medium, 'Strong brand', 'Slow delivery');
        AddCompetitor(OppNo, 30000, 'Initech Software', Enum::"NBC CRM Threat Level"::High, 'Deep pockets', 'Rigid product');
    end;

    local procedure AddCompetitor(OppNo: Code[20]; LineNo: Integer; CompName: Text[100]; Threat: Enum "NBC CRM Threat Level"; Strengths: Text[250]; Weaknesses: Text[250])
    var
        Competitor: Record "NBC CRM Opp. Competitor";
    begin
        if Competitor.Get(OppNo, LineNo) then
            exit;

        Competitor.Init();
        Competitor."Opportunity No." := OppNo;
        Competitor."Line No." := LineNo;
        Competitor.Name := CompName;
        Competitor."Threat Level" := Threat;
        Competitor.Strengths := Strengths;
        Competitor.Weaknesses := Weaknesses;
        Competitor.Insert(true);
    end;

    local procedure AddStakeholders(OppNo: Code[20])
    var
        Contact: Record Contact;
        Index: Integer;
    begin
        // Assign a distinct contact to each Stakeholder Role, in role order, until either roles or
        // available contacts run out. Key is (Opportunity No., Contact No.) so each contact is used once.
        Contact.SetLoadFields("No.");
        if not Contact.FindSet() then
            exit;

        Index := 0;
        repeat
            AddStakeholder(OppNo, Contact."No.", RoleForIndex(Index));
            Index += 1;
        until (Contact.Next() = 0) or (Index > 4);
    end;

    local procedure RoleForIndex(Index: Integer): Enum "NBC CRM Stakeholder Role"
    begin
        case Index of
            0:
                exit(Enum::"NBC CRM Stakeholder Role"::"End User");
            1:
                exit(Enum::"NBC CRM Stakeholder Role"::"Decision Maker");
            2:
                exit(Enum::"NBC CRM Stakeholder Role"::Influencer);
            3:
                exit(Enum::"NBC CRM Stakeholder Role"::Champion);
            else
                exit(Enum::"NBC CRM Stakeholder Role"::Blocker);
        end;
    end;

    local procedure AddStakeholder(OppNo: Code[20]; ContactNo: Code[20]; Role: Enum "NBC CRM Stakeholder Role")
    var
        Stakeholder: Record "NBC CRM Opp. Stakeholder";
    begin
        if Stakeholder.Get(OppNo, ContactNo) then
            exit;

        Stakeholder.Init();
        Stakeholder."Opportunity No." := OppNo;
        Stakeholder."Contact No." := ContactNo;
        Stakeholder.Role := Role;
        Stakeholder.Insert(true);
    end;
}
