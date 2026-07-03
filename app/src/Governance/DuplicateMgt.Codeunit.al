namespace NBC.Governance;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;

/// <summary>Finds Customers/Contacts that share the same name (BC has no native customer dedup).</summary>
codeunit 50081 "NBC Duplicate Mgt."
{
    Access = Public;

    trigger OnRun()
    begin
        ShowDuplicateCustomers();
    end;

    /// <summary>Mark and show customers that share a name with another customer.</summary>
    procedure ShowDuplicateCustomers()
    var
        Customer: Record Customer;
        Counts: Dictionary of [Text, Integer];
        HasDuplicates: Boolean;
        NoDuplicatesMsg: Label 'No customers share the same name.';
    begin
        if Customer.FindSet() then
            repeat
                if Customer.Name <> '' then
                    if Counts.ContainsKey(Customer.Name) then
                        Counts.Set(Customer.Name, Counts.Get(Customer.Name) + 1)
                    else
                        Counts.Add(Customer.Name, 1);
            until Customer.Next() = 0;

        Customer.Reset();
        if Customer.FindSet() then
            repeat
                if (Customer.Name <> '') and (Counts.Get(Customer.Name) > 1) then begin
                    Customer.Mark(true);
                    HasDuplicates := true;
                end;
            until Customer.Next() = 0;

        if not HasDuplicates then begin
            Message(NoDuplicatesMsg);
            exit;
        end;
        Customer.MarkedOnly(true);
        Page.Run(Page::"Customer List", Customer);
    end;

    /// <summary>Mark and show contacts that share a name with another contact.</summary>
    procedure ShowDuplicateContacts()
    var
        Contact: Record Contact;
        Counts: Dictionary of [Text, Integer];
        HasDuplicates: Boolean;
        NoDuplicatesMsg: Label 'No contacts share the same name.';
    begin
        if Contact.FindSet() then
            repeat
                if Contact.Name <> '' then
                    if Counts.ContainsKey(Contact.Name) then
                        Counts.Set(Contact.Name, Counts.Get(Contact.Name) + 1)
                    else
                        Counts.Add(Contact.Name, 1);
            until Contact.Next() = 0;

        Contact.Reset();
        if Contact.FindSet() then
            repeat
                if (Contact.Name <> '') and (Counts.Get(Contact.Name) > 1) then begin
                    Contact.Mark(true);
                    HasDuplicates := true;
                end;
            until Contact.Next() = 0;

        if not HasDuplicates then begin
            Message(NoDuplicatesMsg);
            exit;
        end;
        Contact.MarkedOnly(true);
        Page.Run(Page::"Contact List", Contact);
    end;
}
