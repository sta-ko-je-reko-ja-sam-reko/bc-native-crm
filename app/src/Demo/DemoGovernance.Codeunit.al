namespace NBC.Demo;

using Microsoft.Sales.Customer;

/// <summary>
/// Idempotent demo-data seeder for the CRM Governance feature (audit &amp; duplicate detection).
/// Inserts two customers with fixed No.s that deliberately share the same Name so the
/// duplicate-detection feature ("NBC Duplicate Mgt.".ShowDuplicateCustomers) has a pair to find.
/// Safe to run repeatedly — the fixed No.s Get-guard every insert, so re-running is a no-op.
/// </summary>
codeunit 50167 "NBC Demo Governance"
{
    Access = Public;

    /// <summary>Seed a demonstrable duplicate-customer scenario. Idempotent and defensive.</summary>
    procedure Import()
    begin
        InsertDuplicateCustomer('NBC-DUP-01', DuplicateNameLbl);
        InsertDuplicateCustomer('NBC-DUP-02', DuplicateNameLbl);
        CreateConfigPackage();
    end;

    /// <summary>Header-only Config. Package — Governance owns no custom tables and adds no affix fields to standard tables.</summary>
    local procedure CreateConfigPackage()
    var
        ConfigPkg: Codeunit "NBC Demo Config Package";
    begin
        ConfigPkg.StartPackage(PackageCodeTok, PackageNameLbl);
    end;

    local procedure InsertDuplicateCustomer(CustomerNo: Code[20]; CustomerName: Text[100])
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerNo) then
            exit;
        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Insert(true);
        Customer.Validate(Name, CustomerName);
        Customer.Modify(true);
    end;

    var
        DuplicateNameLbl: Label 'Contoso Trading Ltd', Locked = true;
        PackageCodeTok: Label 'NBC-GOVERNANCE', Locked = true;
        PackageNameLbl: Label 'CRM Governance';
}
