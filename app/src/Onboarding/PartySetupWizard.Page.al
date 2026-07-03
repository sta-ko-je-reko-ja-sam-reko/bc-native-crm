namespace NBC.Onboarding;

using NBC.Demo;
using NBC.Setup;

/// <summary>
/// Assisted Setup wizard for the Ownership and Teams feature: overview → enable → optional sample-data import →
/// finish. The sample-data step is the end-user (non-MCP) path to demo data — on finish it calls the same idempotent
/// seeder the ImportDemoData API exposes to agents. ApplicationArea = All so the wizard is reachable while the
/// feature is still disabled (bootstrap).
/// </summary>
page 50186 "NBC Party Setup Wizard"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    Caption = 'Party Enrichment — Setup';
    SourceTable = "NBC Party Setup";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(StepOverview)
            {
                Visible = Step = Step::Overview;
                ShowCaption = false;
                field(OverviewText; OverviewLbl) { ApplicationArea = All; Editable = false; MultiLine = true; ShowCaption = false; }
            }
            group(StepEnablement)
            {
                Visible = Step = Step::Enablement;
                ShowCaption = false;
                field(EnableText; EnableLbl) { ApplicationArea = All; Editable = false; MultiLine = true; ShowCaption = false; }
                field(Enabled; Rec.Enabled) { ApplicationArea = All; }
            }
            group(StepSampleData)
            {
                Visible = Step = Step::SampleData;
                ShowCaption = false;
                field(ImportSample; ImportSampleData)
                {
                    ApplicationArea = All;
                    Caption = 'Import sample data for this feature';
                    ToolTip = 'Specifies whether ready-made sample records for this feature are added to the current company when you finish.';
                }
                field(SampleText; SampleLbl) { ApplicationArea = All; Editable = false; MultiLine = true; ShowCaption = false; }
            }
            group(StepDone)
            {
                Visible = Step = Step::Done;
                ShowCaption = false;
                field(DoneText; DoneLbl) { ApplicationArea = All; Editable = false; MultiLine = true; ShowCaption = false; }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(BackAction)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Image = PreviousRecord;
                InFooterBar = true;
                Enabled = BackEnabled;

                trigger OnAction()
                begin
                    ChangeStep(-1);
                end;
            }
            action(NextAction)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Image = NextRecord;
                InFooterBar = true;
                Enabled = NextEnabled;

                trigger OnAction()
                begin
                    ChangeStep(1);
                end;
            }
            action(FinishAction)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Image = Approve;
                InFooterBar = true;
                Enabled = FinishEnabled;

                trigger OnAction()
                begin
                    Finish();
                end;
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
        Step := Step::Overview;
        UpdateControls();
    end;

    var
        Step: Enum "NBC Wizard Step";
        ImportSampleData: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        FinishEnabled: Boolean;
        OverviewLbl: Label 'Party Enrichment gives your customers and contacts richer detail — industry, size, revenue, contact preferences and a parent-subsidiary hierarchy — so you can profile and segment the parties you work with. This guide enables the feature and, optionally, loads sample data.';
        EnableLbl: Label 'Turn the feature on. Enabling it shows the enrichment fields, the related pages and the related actions. The session restarts when you finish so the change takes effect.';
        SampleLbl: Label 'Importing sample data adds ready-made example records for this feature to the CURRENT company so you can explore and test it right away — example enrichment on several demo customers and contacts — industry, annual revenue, number of employees, preferred contact method and consent flags, plus a parent-subsidiary link between two customers. It is safe: the data uses fixed sample IDs and importing never creates duplicates, so you can run it again with no harm. It builds on the standard demo company''s customers and salespeople; on an empty company it simply loads what it can. This is example data for evaluation — review it before relying on it in a company you use for real work. Leave this off if you only want to enable the feature.';
        DoneLbl: Label 'You are ready. Choose Finish to apply your choices. The session will then restart so the feature becomes active.';

    local procedure ChangeStep(Delta: Integer)
    var
        NewStep: Integer;
    begin
        NewStep := Step.AsInteger() + Delta;
        if NewStep < Step::Overview.AsInteger() then
            NewStep := Step::Overview.AsInteger();
        if NewStep > Step::Done.AsInteger() then
            NewStep := Step::Done.AsInteger();
        Step := Enum::"NBC Wizard Step".FromInteger(NewStep);
        UpdateControls();
    end;

    local procedure UpdateControls()
    begin
        BackEnabled := Step <> Step::Overview;
        NextEnabled := Step <> Step::Done;
        FinishEnabled := Step = Step::Done;
    end;

    local procedure Finish()
    var
        FeatureMgt: Codeunit "NBC Feature Mgt.";
        DemoParty: Codeunit "NBC Demo Party";
    begin
        Rec.Enabled := true;
        Rec.Modify(true);
        if ImportSampleData then
            DemoParty.Import();
        FeatureMgt.ApplyExperienceChange(true);
    end;
}
