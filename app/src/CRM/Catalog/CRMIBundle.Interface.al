namespace NBC.CRM.Catalog;

/// <summary>Swappable validation logic for a CRM bundle line.</summary>
interface "NBC CRM IBundle"
{
    /// <summary>Validates No. — pulls description and price from the item/resource.</summary>
    procedure Validate_No(var BundleLine: Record "NBC CRM Bundle Line");

    /// <summary>Recalculates the component amount from quantity and unit price.</summary>
    procedure Validate_Amounts(var BundleLine: Record "NBC CRM Bundle Line");
}
