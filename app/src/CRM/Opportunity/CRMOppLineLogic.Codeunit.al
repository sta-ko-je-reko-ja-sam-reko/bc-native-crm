namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.Dataverse.Activities;
using NBC.Dataverse.Ownership;

/// <summary>Default implementation of CRM IOpportunityLine — line lookup and amount calc.</summary>
codeunit 50040 "NBC CRM Opp. Line Logic" implements "NBC CRM IOpportunityLine"
{
    Access = Public;

    procedure Validate_No(var OpportunityLine: Record "NBC CRM Opp. Line")
    var
        Item: Record Item;
        Resource: Record Resource;
    begin
        case OpportunityLine.Type of
            OpportunityLine.Type::Item:
                if Item.Get(OpportunityLine."No.") then begin
                    OpportunityLine.Description := CopyStr(Item.Description, 1, MaxStrLen(OpportunityLine.Description));
                    OpportunityLine."Unit Price" := Item."Unit Price";
                end;
            OpportunityLine.Type::Resource:
                if Resource.Get(OpportunityLine."No.") then begin
                    OpportunityLine.Description := CopyStr(Resource.Name, 1, MaxStrLen(OpportunityLine.Description));
                    OpportunityLine."Unit Price" := Resource."Unit Price";
                end;
        end;
        Validate_Amounts(OpportunityLine);
    end;

    procedure Validate_Amounts(var OpportunityLine: Record "NBC CRM Opp. Line")
    begin
        OpportunityLine."Line Amount" := Round(OpportunityLine.Quantity * OpportunityLine."Unit Price");
    end;
}
