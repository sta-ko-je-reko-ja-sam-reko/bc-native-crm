namespace NBC.Demo;

using Microsoft.CRM.BusinessRelation;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Setup;
using Microsoft.Sales.Customer;
using NBC.Dataverse.PartyEnrichment;

/// <summary>
/// Idempotent CRONUS-style seeder for the Party Enrichment feature. Enriches a handful of standard demo
/// customers ('10000'..'40000') and their primary contacts with firmographic, hierarchy and consent data:
/// industry group, annual revenue, no. of employees, the full range of the preferred-contact-method enum,
/// a mix of the do-not consent flags, and a parent -> subsidiary account hierarchy.
/// The enrichment writes only to already-present records — every CRONUS reference is Get-guarded, so a
/// missing demo record is skipped rather than created, and re-running simply re-sets the same values.
/// </summary>
codeunit 50163 "NBC Demo Party"
{
    Access = Public;

    var
        RetailIndustryLbl: Label 'RETAIL', Locked = true;
        ManufIndustryLbl: Label 'MANUF', Locked = true;
        ServiceIndustryLbl: Label 'SERVICE', Locked = true;
        PackageCodeTok: Label 'NBC-PARTY', Locked = true;
        PackageNameLbl: Label 'CRM Party Enrichment';

    /// <summary>Seeds Party Enrichment demo data. Safe to run repeatedly.</summary>
    procedure Import()
    begin
        EnsureIndustryGroups();

        // Parent account: retail, prefers Email, excluded from bulk email.
        EnrichCustomer('10000', RetailIndustryLbl, 25000000, 120, Enum::"NBC CDS Pref. Contact Method"::Email, false, false, true, '');
        // Subsidiary of 10000: manufacturing, prefers Phone, no phone consent flag but do-not-email set.
        EnrichCustomer('20000', ManufIndustryLbl, 8000000, 45, Enum::"NBC CDS Pref. Contact Method"::Phone, true, false, false, '10000');
        // Parent account: services, prefers Mail, opted out of e-mail and phone entirely.
        EnrichCustomer('30000', ServiceIndustryLbl, 15000000, 80, Enum::"NBC CDS Pref. Contact Method"::Mail, true, true, true, '');
        // Subsidiary of 30000: retail, no channel preference (Any), fully contactable.
        EnrichCustomer('40000', RetailIndustryLbl, 3000000, 20, Enum::"NBC CDS Pref. Contact Method"::Any, false, false, false, '30000');

        // Enrich the primary contact behind each customer, mirroring the preferred method with a consent mix.
        EnrichPrimaryContact('10000', Enum::"NBC CDS Pref. Contact Method"::Email, false, true, false);
        EnrichPrimaryContact('20000', Enum::"NBC CDS Pref. Contact Method"::Phone, false, false, false);
        EnrichPrimaryContact('30000', Enum::"NBC CDS Pref. Contact Method"::Mail, true, false, true);
        EnrichPrimaryContact('40000', Enum::"NBC CDS Pref. Contact Method"::Any, false, false, false);

        CreateConfigPackage();
    end;

    local procedure CreateConfigPackage()
    var
        ConfigPkg: Codeunit "NBC Demo Config Package";
        AffixFieldNos: List of [Integer];
    begin
        if not ConfigPkg.StartPackage(PackageCodeTok, PackageNameLbl) then
            exit;

        AffixFieldNos.Add(50050);
        AffixFieldNos.Add(50051);
        AffixFieldNos.Add(50052);
        AffixFieldNos.Add(50053);
        AffixFieldNos.Add(50054);
        AffixFieldNos.Add(50055);
        AffixFieldNos.Add(50056);
        AffixFieldNos.Add(50057);
        ConfigPkg.AddExtendedTable(PackageCodeTok, Database::Customer, AffixFieldNos);

        Clear(AffixFieldNos);
        AffixFieldNos.Add(50054);
        AffixFieldNos.Add(50055);
        AffixFieldNos.Add(50056);
        AffixFieldNos.Add(50057);
        ConfigPkg.AddExtendedTable(PackageCodeTok, Database::Contact, AffixFieldNos);
    end;

    local procedure EnrichCustomer(CustomerNo: Code[20]; IndustryCode: Code[10]; AnnualRevenue: Decimal; NoOfEmployees: Integer; PrefMethod: Enum "NBC CDS Pref. Contact Method"; DoNotEmail: Boolean; DoNotPhone: Boolean; DoNotBulkEmail: Boolean; ParentCustomerNo: Code[20])
    var
        Customer: Record Customer;
        IndustryGroup: Record "Industry Group";
    begin
        if not Customer.Get(CustomerNo) then
            exit;

        IndustryGroup.SetLoadFields(Code);
        if IndustryGroup.Get(IndustryCode) then
            Customer.Validate("NBC CDS Industry Group Code", IndustryGroup.Code);
        Customer."NBC CDS Annual Revenue" := AnnualRevenue;
        Customer."NBC CDS No. of Employees" := NoOfEmployees;
        Customer."NBC CDS Contact Method" := PrefMethod;
        Customer."NBC CDS Do Not Email" := DoNotEmail;
        Customer."NBC CDS Do Not Phone" := DoNotPhone;
        Customer."NBC CDS Do Not Bulk Email" := DoNotBulkEmail;

        // Only wire up the hierarchy when the parent is itself a present demo customer (avoid a dangling ref).
        if (ParentCustomerNo <> '') and ParentCustomerExists(ParentCustomerNo) then
            Customer.Validate("NBC CDS Parent Customer No.", ParentCustomerNo)
        else
            Customer."NBC CDS Parent Customer No." := '';

        Customer.Modify(true);
    end;

    local procedure EnrichPrimaryContact(CustomerNo: Code[20]; PrefMethod: Enum "NBC CDS Pref. Contact Method"; DoNotEmail: Boolean; DoNotPhone: Boolean; DoNotBulkEmail: Boolean)
    var
        Contact: Record Contact;
    begin
        Contact.SetLoadFields("NBC CDS Contact Method", "NBC CDS Do Not Email", "NBC CDS Do Not Phone", "NBC CDS Do Not Bulk Email");
        if not GetCustomerContact(CustomerNo, Contact) then
            exit;

        Contact."NBC CDS Contact Method" := PrefMethod;
        Contact."NBC CDS Do Not Email" := DoNotEmail;
        Contact."NBC CDS Do Not Phone" := DoNotPhone;
        Contact."NBC CDS Do Not Bulk Email" := DoNotBulkEmail;
        Contact.Modify(true);
    end;

    local procedure GetCustomerContact(CustomerNo: Code[20]; var Contact: Record Contact): Boolean
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetRange("No.", CustomerNo);
        ContactBusinessRelation.SetLoadFields("Contact No.");
        if not ContactBusinessRelation.FindFirst() then
            exit(false);
        exit(Contact.Get(ContactBusinessRelation."Contact No."));
    end;

    local procedure ParentCustomerExists(ParentCustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields("No.");
        exit(Customer.Get(ParentCustomerNo));
    end;

    local procedure EnsureIndustryGroups()
    begin
        EnsureIndustryGroup(RetailIndustryLbl, 'Retail');
        EnsureIndustryGroup(ManufIndustryLbl, 'Manufacturing');
        EnsureIndustryGroup(ServiceIndustryLbl, 'Services');
    end;

    local procedure EnsureIndustryGroup(IndustryCode: Code[10]; Description: Text[50])
    var
        IndustryGroup: Record "Industry Group";
    begin
        IndustryGroup.SetLoadFields(Code);
        if IndustryGroup.Get(IndustryCode) then
            exit;
        IndustryGroup.Init();
        IndustryGroup.Code := IndustryCode;
        IndustryGroup.Description := Description;
        IndustryGroup.Insert(true);
    end;
}
