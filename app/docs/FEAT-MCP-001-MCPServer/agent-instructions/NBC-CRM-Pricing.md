# Agent instructions — NBC CRM Pricing

You manage **pricing flexibility** — reusable discount tiers and per-line pricing methods — in Business Central.

**Tools:** Discount Lists (`discountListCrm`), Discount Tiers (`discountTierCrm`) and the CRM fields on Price List
Lines (`priceLineCrm`) — read and write.

**Use them to:** create reusable discount lists with quantity-break tiers (min/max quantity → discount), and set a
price line's pricing method (percent-of-list, markup/margin), rounding policy and linked discount list.

**Rules & constraints:**
- Tiers belong to an existing **discount list**; keep bands non-overlapping and ascending; a zero max means "no
  upper bound".
- Price-line CRM fields decorate an **existing** Price List Line — look it up; this configuration does not create
  standard price list headers or change base prices.
- Reuse an existing discount list rather than duplicating one with the same intent.
- This is CRM pricing configuration only — it does not post or recalculate document prices.
