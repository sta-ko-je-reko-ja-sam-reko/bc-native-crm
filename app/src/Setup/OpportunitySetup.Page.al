namespace NBC.Setup;

/// <summary>Administration setup for Opportunity Depth — turn the feature on or off.</summary>
page 50133 "NBC Opportunity Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NBC Opportunity Setup";
    Caption = 'Opportunity Setup';
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
