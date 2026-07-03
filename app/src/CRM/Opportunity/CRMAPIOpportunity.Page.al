namespace NBC.CRM.Opportunity;

using Microsoft.CRM.Opportunity;

/// <summary>
/// API page over the standard Opportunity — a full clone of Microsoft's APIV2 Opportunities page (so
/// integrations/MCP see the whole entity) plus the CRM affix fields. A NEW page, not a pageextension, because
/// API pages cannot be extended. Published under our own APIPublisher/APIGroup/APIVersion.
/// </summary>
page 50126 "NBC CRM API Opportunity"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'opportunity';
    APIVersion = 'v1.0';
    EntityCaption = 'CRM Opportunity';
    EntitySetCaption = 'CRM Opportunities';
    DelayedInsert = true;
    EntityName = 'opportunity';
    EntitySetName = 'opportunities';
    SourceTable = Opportunity;
    Extensible = false;
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("No."));
                    end;
                }
                field(contactNumber; Rec."Contact No.")
                {
                    Caption = 'Contact No.';

                    trigger OnValidate()
                    begin
                        if (Rec.Status = Rec.Status::Won) or (Rec.Status = Rec.Status::Lost) then
                            Error(ContactNoCannotBeChangedWonLostErr);

                        RegisterFieldSet(Rec.FieldNo("Contact No."));
                    end;
                }
                field(contactName; Rec."Contact Name")
                {
                    Caption = 'Contact Name';
                    Editable = false;
                }
                field(contactCompanyName; Rec."Contact Company Name")
                {
                    Caption = 'Contact Company Name';
                    Editable = false;
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code';

                    trigger OnValidate()
                    begin
                        if (Rec.Status = Rec.Status::Won) or (Rec.Status = Rec.Status::Lost) then
                            Error(SalespersonCodeCannotBeChangedErr);

                        RegisterFieldSet(Rec.FieldNo("Salesperson Code"));
                    end;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Description));
                    end;
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                    Editable = false;
                }
                field(closed; Rec.Closed)
                {
                    Caption = 'Closed';
                    Editable = false;
                }
                field(creationDate; Rec."Creation Date")
                {
                    Caption = 'Creation Date';
                    Editable = false;
                }
                field(dateClosed; Rec."Date Closed")
                {
                    Caption = 'Date Closed';
                    Editable = false;
                }
                field(calculatedCurrentValue; Rec."Calcd. Current Value (LCY)")
                {
                    Caption = 'Calculated Current Value (LCY)';
                    Editable = false;
                }
                field(chancesOfSuccessPrc; Rec."Chances of Success %")
                {
                    Caption = 'Chances of Success %';
                    Editable = false;
                }
                field(completedPrc; Rec."Completed %")
                {
                    Caption = 'Completed %';
                    Editable = false;
                }
                field(estimatedClosingDate; Rec."Estimated Closing Date")
                {
                    Caption = 'Estimated Closing Date';
                    Editable = false;
                }
                field(estimatedValue; Rec."Estimated Value (LCY)")
                {
                    Caption = 'Estimated Value (LCY)';
                    Editable = false;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Creation Date';
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                // --- NBC CRM affix fields (from the "NBC CRM Opportunity" tableextension) ---
                field(crmOwnerType; Rec."NBC CDS Owner Type")
                {
                    Caption = 'CRM Owner Type';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("NBC CDS Owner Type"));
                    end;
                }
                field(crmOwnerCode; Rec."NBC CDS Owner Code")
                {
                    Caption = 'CRM Owner';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("NBC CDS Owner Code"));
                    end;
                }
                field(crmRating; Rec."NBC CRM Rating")
                {
                    Caption = 'CRM Rating';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("NBC CRM Rating"));
                    end;
                }
                field(crmEstimatedRevenue; Rec."NBC CRM Estimated Revenue")
                {
                    Caption = 'CRM Estimated Revenue';
                    Editable = false;
                }
            }
        }
    }

    var
        TempFieldSet: Record 2000000041 temporary;
        SalespersonCodeCannotBeChangedErr: Label 'The "salespersonCode" of a Won or Lost Opportunity cannot be changed', Comment = 'salespersonCode is a field name and should not be translated';
        ContactNoCannotBeChangedWonLostErr: Label 'The "contactNumber of a Won or Lost Opportunity cannot be changed', Comment = 'contactNumber is a field name and should not be translated';

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Opportunity, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Opportunity;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}
