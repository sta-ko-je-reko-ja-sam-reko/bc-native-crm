namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>Default implementation of CRM IActivity — activity trigger/validation logic.</summary>
codeunit 50031 "NBC CDS Activity Logic" implements "NBC CDS IActivity"
{
    Access = Public;

    procedure Trigger_OnInsert(var Activity: Record "NBC CDS Activity")
    var
        OwnerMgt: Codeunit "NBC CDS Owner Mgt.";
        OwnerType: Enum "NBC CDS Owner Type";
        OwnerCode: Code[20];
    begin
        if Activity."Activity Date" = 0DT then
            Activity."Activity Date" := CurrentDateTime();
        if Activity."Created By" = '' then
            Activity."Created By" := CopyStr(UserId(), 1, MaxStrLen(Activity."Created By"));
        if Activity."Owner Code" = '' then
            if OwnerMgt.GetDefaultOwner(OwnerType, OwnerCode) then begin
                Activity."Owner Type" := OwnerType;
                Activity."Owner Code" := OwnerCode;
            end;
    end;

    procedure Validate_Status(var Activity: Record "NBC CDS Activity")
    begin
        case Activity.Status of
            Activity.Status::Completed,
            Activity.Status::Canceled:
                if Activity."Closed DateTime" = 0DT then
                    Activity."Closed DateTime" := CurrentDateTime();
            Activity.Status::Open:
                Clear(Activity."Closed DateTime");
        end;
    end;
}
