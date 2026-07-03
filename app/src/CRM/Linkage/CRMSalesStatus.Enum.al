namespace NBC.CRM.Linkage;

/// <summary>
/// The CRM-facing sales lifecycle of an order, distinct from BC's release/approval Status. Mirrors the
/// Dataverse salesorder statecode (Active / Submitted / Fulfilled / Canceled). Sales-facing only — it does
/// not gate BC posting.
/// </summary>
enum 50140 "NBC CRM Sales Status"
{
    Extensible = true;
    Caption = 'CRM Sales Status';

    value(0; Active) { Caption = 'Active'; }
    value(1; Submitted) { Caption = 'Submitted'; }
    value(2; Fulfilled) { Caption = 'Fulfilled'; }
    value(3; Canceled) { Caption = 'Canceled'; }
}
