namespace NBC.Setup;

/// <summary>Administration setup for Activities and Timeline — turn the feature on or off.</summary>
page 50131 "NBC Activity Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NBC Activity Setup";
    Caption = 'Activity Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Enabled; Rec.Enabled) { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        OpeningEnabled := Rec.Enabled;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        FeatureMgt: Codeunit "NBC Feature Mgt.";
    begin
        if Rec.Get() and (Rec.Enabled <> OpeningEnabled) then
            FeatureMgt.ApplyExperienceChange(Rec.Enabled);
        exit(true);
    end;

    var
        OpeningEnabled: Boolean;
}
