namespace NBC.Setup;

/// <summary>Administration setup for Business Process Flow — turn the feature on or off.</summary>
page 50134 "NBC Process Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NBC Process Setup";
    Caption = 'Business Process Setup';
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
