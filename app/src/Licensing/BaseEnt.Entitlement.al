#if APPSOURCE
namespace NBC.Licensing;

using NBC.Setup;

/// <summary>
/// Unlicensed entitlement — grants the base-subscriber codeunits to EVERY user regardless of plan, so the
/// subscriptions on MS BaseApp publishers (which fire for all users) never raise a licensing error. The
/// subscriber bodies themselves check effective permission before doing any product work. Compiled only in
/// the AppSource build (APPSOURCE); a PTE extension can't contain an entitlement (PTE0013) — in a PTE build
/// the admin assigns "NBC Base Subscribers" to all users instead.
/// </summary>
entitlement "NBC Base Ent"
{
    Type = Unlicensed;

    ObjectEntitlements = "NBC Base Subscribers";
}
#endif
