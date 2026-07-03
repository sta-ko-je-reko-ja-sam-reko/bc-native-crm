namespace NBC.Test;

using NBC.Dataverse.Activities;

/// <summary>
/// Unit tests for CRM Activity Mgt. — focuses on the pure record→JSON timeline builder using
/// temporary records (no physical data / posting).
/// </summary>
codeunit 50901 "NBC CDS Activity Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure BuildTimelineJson_OrdersNewestFirstWithFields()
    var
        TempActivity: Record "NBC CDS Activity" temporary;
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
        Activities: JsonArray;
        FirstToken: JsonToken;
        FirstObject: JsonObject;
        SubjectToken: JsonToken;
        JsonText: Text;
    begin
        // [GIVEN] two activities, older then newer
        AddTempActivity(TempActivity, 1, 'Older call', CreateDateTime(20250101D, 080000T));
        AddTempActivity(TempActivity, 2, 'Newer task', CreateDateTime(20250201D, 080000T));

        // [WHEN] building the timeline JSON
        JsonText := ActivityMgt.BuildTimelineJson(TempActivity);

        // [THEN] it is a 2-element array, newest first
        if not Activities.ReadFrom(JsonText) then
            Error('Result is not valid JSON: %1', JsonText);
        if Activities.Count() <> 2 then
            Error('Expected 2 activities, got %1.', Activities.Count());

        Activities.Get(0, FirstToken);
        FirstObject := FirstToken.AsObject();
        FirstObject.Get('subject', SubjectToken);
        if SubjectToken.AsValue().AsText() <> 'Newer task' then
            Error('Expected newest activity first, got ''%1''.', SubjectToken.AsValue().AsText());
    end;

    [Test]
    procedure BuildTimelineJson_EmptySetReturnsEmptyArray()
    var
        TempActivity: Record "NBC CDS Activity" temporary;
        ActivityMgt: Codeunit "NBC CDS Activity Mgt.";
        JsonText: Text;
    begin
        // [GIVEN] no activities  [WHEN] building JSON  [THEN] an empty array
        JsonText := ActivityMgt.BuildTimelineJson(TempActivity);
        if JsonText <> '[]' then
            Error('Expected ''[]'' for an empty set, got ''%1''.', JsonText);
    end;

    local procedure AddTempActivity(var TempActivity: Record "NBC CDS Activity" temporary; EntryNo: Integer; Subject: Text; ActivityDate: DateTime)
    begin
        TempActivity.Init();
        TempActivity."Entry No." := EntryNo;
        TempActivity.Subject := CopyStr(Subject, 1, MaxStrLen(TempActivity.Subject));
        TempActivity."Activity Date" := ActivityDate;
        TempActivity.Insert();
    end;
}
