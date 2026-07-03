namespace NBC.Demo;

using System.IO;

/// <summary>
/// Builds a standard RapidStart Configuration Package for a feature, via the base <c>Config. Package Management</c>
/// (codeunit 8611). Called from a demo seeder's <c>Import()</c>, so a feature's package is created ONLY when the end
/// user opts to import that feature's demo data (Assisted Setup opt-in or the MCP importDemoData tool). One package
/// per feature; own tables get all (non-flow) fields, extended standard tables are narrowed to the primary key + the
/// feature's affix fields. The feature <c>Setup</c> table is NEVER added — feature setup is prepopulated via Assisted
/// Setup / manual entry / MCP, not RapidStart.
/// </summary>
codeunit 50182 "NBC Demo Config Package"
{
    Access = Public;

    /// <summary>Create the package header if missing. Returns true when it was newly created (the caller then adds tables); false when it already exists (idempotent — nothing to do).</summary>
    procedure StartPackage(PackageCode: Code[20]; PackageName: Text[50]): Boolean
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        ConfigPackage.SetLoadFields(Code);
        if ConfigPackage.Get(PackageCode) then
            exit(false);
        ConfigPackageMgt.InsertPackage(ConfigPackage, PackageCode, PackageName, true);
        exit(true);
    end;

    /// <summary>Add one of the feature's OWN tables — its normal fields are included by default (FlowFields/system excluded).</summary>
    procedure AddOwnTable(PackageCode: Code[20]; TableId: Integer)
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        ConfigPackageMgt.InsertPackageTable(ConfigPackageTable, PackageCode, TableId);
    end;

    /// <summary>Add an EXTENDED standard table, narrowing the included fields to the primary key + the given affix fields.</summary>
    procedure AddExtendedTable(PackageCode: Code[20]; TableId: Integer; AffixFieldNos: List of [Integer])
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        ConfigPackageMgt.InsertPackageTable(ConfigPackageTable, PackageCode, TableId);

        ConfigPackageField.SetLoadFields("Field ID", "Primary Key", "Include Field");
        ConfigPackageField.SetRange("Package Code", PackageCode);
        ConfigPackageField.SetRange("Table ID", TableId);
        if ConfigPackageField.FindSet(true) then
            repeat
                ConfigPackageField."Include Field" := ConfigPackageField."Primary Key" or AffixFieldNos.Contains(ConfigPackageField."Field ID");
                ConfigPackageField.Modify();
            until ConfigPackageField.Next() = 0;
    end;
}
