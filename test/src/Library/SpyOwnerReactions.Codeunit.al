namespace NBC.Test;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using NBC.Dataverse.Ownership;

/// <summary>Spy for the owner reactions: counts how often the subscribers delegate to it.</summary>
codeunit 69092 "NBC Spy Owner Reactions" implements "NBC CDS IOwnerReactions"
{
    SingleInstance = true;

    var
        CustomerCalls: Integer;
        ContactCalls: Integer;

    /// <summary>Clears the call counters.</summary>
    procedure Reset()
    begin
        CustomerCalls := 0;
        ContactCalls := 0;
    end;

    /// <summary>How often OnInsertCustomer ran since the last Reset.</summary>
    /// <returns>The call count.</returns>
    procedure CustomerCallCount(): Integer
    begin
        exit(CustomerCalls);
    end;

    /// <summary>How often OnInsertContact ran since the last Reset.</summary>
    /// <returns>The call count.</returns>
    procedure ContactCallCount(): Integer
    begin
        exit(ContactCalls);
    end;

    procedure OnInsertCustomer(var Customer: Record Customer)
    begin
        CustomerCalls += 1;
    end;

    procedure OnInsertContact(var Contact: Record Contact)
    begin
        ContactCalls += 1;
    end;
}
