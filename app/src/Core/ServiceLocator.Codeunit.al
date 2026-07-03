namespace NBC.Core;

using NBC.CRM.Linkage;
using NBC.Dataverse.Ownership;

/// <summary>
/// App-wide, single-instance resolver for swappable service implementations.
/// Pure-proxy event subscribers reach their reaction logic through this locator, so downstream
/// apps (and tests) can substitute behaviour without editing the subscription. See the
/// polymorphic-table-logic pattern in the shared templates.
/// </summary>
codeunit 50000 "NBC Service Locator"
{
    Access = Public;
    SingleInstance = true;

    var
        IOwnerReactions: Interface "NBC CDS IOwnerReactions";
        ILinkageReactions: Interface "NBC CRM ILinkageReactions";
        IAccessPolicy: Interface "NBC IAccessPolicy";
        OwnerReactionsDefined: Boolean;
        LinkageReactionsDefined: Boolean;
        AccessPolicyDefined: Boolean;

    /// <summary>Effective-permission / licensing policy for the Unlicensed base subscribers (swappable).</summary>
    procedure AccessPolicy(): Interface "NBC IAccessPolicy"
    var
        DefaultPolicy: Codeunit "NBC Access Policy";
    begin
        if not AccessPolicyDefined then
            ImplementAccessPolicy(DefaultPolicy);
        exit(IAccessPolicy);
    end;

    /// <summary>Inject an alternative access policy (downstream apps / tests).</summary>
    procedure ImplementAccessPolicy(Implementation: Interface "NBC IAccessPolicy")
    begin
        IAccessPolicy := Implementation;
        AccessPolicyDefined := true;
    end;

    /// <summary>Owner-defaulting reactions (record insert → default owner).</summary>
    procedure OwnerReactions(): Interface "NBC CDS IOwnerReactions"
    var
        DefaultReactions: Codeunit "NBC CDS Owner Reactions";
    begin
        if not OwnerReactionsDefined then
            ImplementOwnerReactions(DefaultReactions);
        exit(IOwnerReactions);
    end;

    /// <summary>Inject an alternative owner-reactions implementation (downstream apps / tests).</summary>
    procedure ImplementOwnerReactions(Implementation: Interface "NBC CDS IOwnerReactions")
    begin
        IOwnerReactions := Implementation;
        OwnerReactionsDefined := true;
    end;

    /// <summary>Pipeline-linkage reactions (posted invoice → stamp originating opportunity).</summary>
    procedure LinkageReactions(): Interface "NBC CRM ILinkageReactions"
    var
        DefaultReactions: Codeunit "NBC CRM Linkage Reactions";
    begin
        if not LinkageReactionsDefined then
            ImplementLinkageReactions(DefaultReactions);
        exit(ILinkageReactions);
    end;

    /// <summary>Inject an alternative linkage-reactions implementation (downstream apps / tests).</summary>
    procedure ImplementLinkageReactions(Implementation: Interface "NBC CRM ILinkageReactions")
    begin
        ILinkageReactions := Implementation;
        LinkageReactionsDefined := true;
    end;
}
