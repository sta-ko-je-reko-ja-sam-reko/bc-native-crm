namespace NBC.Onboarding;

/// <summary>The steps of a per-feature Assisted Setup wizard: overview → enable → sample-data opt-in → finish.</summary>
enum 50183 "NBC Wizard Step"
{
    Extensible = false;

    value(0; Overview) { Caption = 'Overview'; }
    value(1; Enablement) { Caption = 'Enable'; }
    value(2; SampleData) { Caption = 'Sample data'; }
    value(3; Done) { Caption = 'Finish'; }
}
