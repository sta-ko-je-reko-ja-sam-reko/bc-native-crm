namespace NBC.Dataverse.Activities;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>
/// CRM activity service: initialize an activity for a regarded record, complete it, and build the
/// timeline JSON consumed by the CRM Timeline control add-in.
/// </summary>
codeunit 50030 "NBC CDS Activity Mgt."
{
    Access = Public;

    /// <summary>Prepare (not yet inserted) an activity regarding the given record.</summary>
    procedure InitActivityForRecord(var Activity: Record "NBC CDS Activity"; RegardingTableNo: Integer; RegardingSystemId: Guid; RegardingDescription: Text)
    begin
        Activity.Init();
        Activity."Activity Type" := Activity."Activity Type"::Task;
        Activity."Regarding Table No." := RegardingTableNo;
        Activity."Regarding System ID" := RegardingSystemId;
        Activity."Regarding Description" := CopyStr(RegardingDescription, 1, MaxStrLen(Activity."Regarding Description"));
        Activity."Activity Date" := CurrentDateTime();
    end;

    /// <summary>Mark an activity completed.</summary>
    procedure CompleteActivity(var Activity: Record "NBC CDS Activity")
    begin
        Activity.Validate(Status, Activity.Status::Completed);
        Activity.Modify(true);
    end;

    /// <summary>Build the timeline JSON for a (filtered) activity set, newest first.</summary>
    procedure BuildTimelineJson(var Activity: Record "NBC CDS Activity"): Text
    var
        Activities: JsonArray;
        ActivityObj: JsonObject;
        ResultText: Text;
    begin
        Activity.SetCurrentKey("Activity Date");
        Activity.Ascending(false);
        if Activity.FindSet() then
            repeat
                Clear(ActivityObj);
                ActivityObj.Add('id', Format(Activity."Entry No."));
                ActivityObj.Add('type', Format(Activity."Activity Type"));
                ActivityObj.Add('subject', Activity.Subject);
                ActivityObj.Add('description', CopyStr(Activity.Description, 1, 250));
                ActivityObj.Add('date', FormatDateTime(Activity."Activity Date"));
                ActivityObj.Add('owner', Activity."Owner Code");
                ActivityObj.Add('status', Format(Activity.Status));
                Activities.Add(ActivityObj);
            until Activity.Next() = 0;
        Activities.WriteTo(ResultText);
        exit(ResultText);
    end;

    local procedure FormatDateTime(Value: DateTime): Text
    begin
        if Value = 0DT then
            exit('');
        exit(Format(Value, 0, '<Day,2>.<Month,2>.<Year4> <Hours24,2>:<Minutes,2>'));
    end;
}
