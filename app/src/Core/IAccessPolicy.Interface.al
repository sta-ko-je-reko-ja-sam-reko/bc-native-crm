namespace NBC.Core;

/// <summary>
/// The licensing / effective-permission check used by the base-app (Unlicensed) subscriber proxies. Both this
/// interface and its default implementation are granted through the Unlicensed base entitlement, so every user can
/// resolve and run it WITHOUT instantiating any licensed product object — the check is always by object id via
/// Microsoft objects only. Resolved (and swappable) through the <see cref="NBC Service Locator"/>, so a customer or
/// downstream app can substitute a different access policy without touching the subscribers.
/// </summary>
interface "NBC IAccessPolicy"
{
    /// <summary>True when the current user has effective Execute permission on the given codeunit (checked by id).</summary>
    procedure HasEffectiveExecute(CodeunitId: Integer): Boolean;

    /// <summary>True when the current user has effective Read permission on the given table (checked by id).</summary>
    procedure HasEffectiveRead(TableId: Integer): Boolean;
}
