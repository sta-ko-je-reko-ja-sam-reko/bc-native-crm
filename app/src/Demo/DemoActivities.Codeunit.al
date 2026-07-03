namespace NBC.Demo;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Activities;

/// <summary>
/// Idempotent CRONUS-style demo seeder for the CRM Activities feature. Seeds a spread of
/// NBC CDS Activity rows regarding standard CRONUS customers and a contact,
/// covering every enum value of Activity Type / Status / Priority / Direction at least once.
/// Re-running is safe: each row is guarded by its distinctive demo Subject.
/// </summary>
codeunit 50162 "NBC Demo Activities"
{
    Access = Public;

    /// <summary>Seed demo activities. Guarded per row, so it can be run repeatedly.</summary>
    procedure Import()
    var
        Customer: Record Customer;
        Contact: Record Contact;
    begin
        // Regarding customer 10000: Task (Open/High/blank) + Phone Call (Completed/Normal/Incoming)
        Customer.SetLoadFields(Name);
        if Customer.Get('10000') then begin
            SeedActivity(
                Database::Customer, Customer.SystemId, Customer.Name,
                Enum::"NBC CDS Activity Type"::Task,
                'DEMO: Follow up on outstanding balance',
                Enum::"NBC CDS Activity Priority"::High,
                Enum::"NBC CDS Activity Direction"::" ",
                Enum::"NBC CDS Activity Status"::Open);
            SeedActivity(
                Database::Customer, Customer.SystemId, Customer.Name,
                Enum::"NBC CDS Activity Type"::"Phone Call",
                'DEMO: Inbound call about delivery date',
                Enum::"NBC CDS Activity Priority"::Normal,
                Enum::"NBC CDS Activity Direction"::Incoming,
                Enum::"NBC CDS Activity Status"::Completed);
        end;

        // Regarding customer 20000: Appointment (Open/Low/Outgoing) + Note (Canceled/Normal/blank)
        Customer.SetLoadFields(Name);
        if Customer.Get('20000') then begin
            SeedActivity(
                Database::Customer, Customer.SystemId, Customer.Name,
                Enum::"NBC CDS Activity Type"::Appointment,
                'DEMO: On-site review meeting',
                Enum::"NBC CDS Activity Priority"::Low,
                Enum::"NBC CDS Activity Direction"::Outgoing,
                Enum::"NBC CDS Activity Status"::Open);
            SeedActivity(
                Database::Customer, Customer.SystemId, Customer.Name,
                Enum::"NBC CDS Activity Type"::Note,
                'DEMO: Customer prefers quarterly statements',
                Enum::"NBC CDS Activity Priority"::Normal,
                Enum::"NBC CDS Activity Direction"::" ",
                Enum::"NBC CDS Activity Status"::Canceled);
        end;

        // Regarding a contact: Email (Completed/High/Outgoing) + Phone Call (Open/Low/Incoming)
        if TryGetDemoContact(Contact) then begin
            SeedActivity(
                Database::Contact, Contact.SystemId, Contact.Name,
                Enum::"NBC CDS Activity Type"::Email,
                'DEMO: Sent product brochure',
                Enum::"NBC CDS Activity Priority"::High,
                Enum::"NBC CDS Activity Direction"::Outgoing,
                Enum::"NBC CDS Activity Status"::Completed);
            SeedActivity(
                Database::Contact, Contact.SystemId, Contact.Name,
                Enum::"NBC CDS Activity Type"::"Phone Call",
                'DEMO: Contact requested a callback',
                Enum::"NBC CDS Activity Priority"::Low,
                Enum::"NBC CDS Activity Direction"::Incoming,
                Enum::"NBC CDS Activity Status"::Open);
        end;

        CreateConfigPackage();
    end;

    /// <summary>Register a RapidStart config package exposing the Activities table for demo export/import.</summary>
    local procedure CreateConfigPackage()
    var
        ConfigPkg: Codeunit "NBC Demo Config Package";
    begin
        if not ConfigPkg.StartPackage(PackageCodeTok, PackageNameLbl) then
            exit;
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CDS Activity");
    end;

    /// <summary>Insert one demo activity, unless a row with the same Subject already exists.</summary>
    local procedure SeedActivity(RegardingTableNo: Integer; RegardingSystemId: Guid; RegardingDescription: Text; ActivityType: Enum "NBC CDS Activity Type"; Subject: Text[100]; Priority: Enum "NBC CDS Activity Priority"; Direction: Enum "NBC CDS Activity Direction"; Status: Enum "NBC CDS Activity Status")
    var
        Activity: Record "NBC CDS Activity";
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
    begin
        Activity.SetRange(Subject, Subject);
        if not Activity.IsEmpty() then
            exit;
        Clear(Activity);

        ActivityMgt.InitActivityForRecord(Activity, RegardingTableNo, RegardingSystemId, RegardingDescription);
        Activity."Activity Type" := ActivityType;
        Activity.Subject := Subject;
        Activity.Priority := Priority;
        Activity.Direction := Direction;
        Activity.Validate(Status, Status);
        Activity.Insert(true);
    end;

    /// <summary>Defensively resolve a CRONUS contact to regard demo activities against.</summary>
    local procedure TryGetDemoContact(var Contact: Record Contact): Boolean
    begin
        Contact.SetLoadFields(Name);
        if Contact.Get('CT000001') then
            exit(true);
        Contact.SetRange(Type, Contact.Type::Person);
        Contact.SetLoadFields(Name);
        if Contact.FindFirst() then
            exit(true);
        Contact.Reset();
        Contact.SetLoadFields(Name);
        exit(Contact.FindFirst());
    end;

    var
        PackageCodeTok: Label 'NBC-ACTIVITIES', Locked = true;
        PackageNameLbl: Label 'CRM Activities and Timeline';
}
