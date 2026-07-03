# FEAT-PRC-001 - Pricing Flexibility

Go beyond fixed prices: let a price be worked out from the list price or the cost, round it to a tidy figure, and
reuse volume-discount tiers across many products.

## Price a line by a method instead of a fixed amount

1. Open a **Price List** and go to its **Lines**.
2. On a line, set the **CRM Pricing Method**:
   - *Percent of List* — a percentage of the product's list price.
   - *Percent Markup on Cost* — the cost plus a percentage.
   - *Percent Margin on Cost* — a price that achieves a target margin over cost.
3. Enter the **CRM Pricing %**.
4. Optionally set a **CRM Rounding Policy** (up, down or to nearest) and a **CRM Rounding Precision** (for example
   1 to end on whole amounts).
5. Choose **Recalculate CRM price**. The **Unit Price** is worked out and rounded for you.

## Reuse volume-discount tiers

1. Choose the search icon, enter **CRM Discount Lists**, and open it.
2. Create a discount list, choose whether it is a **Percentage** or an **Amount**, and add **Tiers** — each with a
   quantity band and a value.
3. On a price list line, set the **CRM Discount List** to reuse those tiers when selling larger quantities.

## Control how quantities are sold

1. On a price list line, set **CRM Quantity Selling** to *Whole* or *Whole and Fractional* to signal how the item
   should be sold.
