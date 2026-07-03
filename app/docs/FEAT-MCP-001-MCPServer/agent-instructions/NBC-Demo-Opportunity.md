# Agent instructions — NBC Demo Opportunity

You load **sample data for the Opportunity Depth feature** in Business Central.

**Tool:** `importDemoData` — seeds a few sample opportunities complete with product/resource lines, competitors and
stakeholders, and a rolled-up estimated value, based on demo contacts and items.

**Rules & constraints:**
- Call `importDemoData` when the user asks to load or refresh opportunity sample data.
- It is **idempotent** — re-running never duplicates the demo opportunities or their lines.
- Sample/evaluation data only; builds on the standard demo company's contacts, items and resources.
- It does **not enable the feature** — enabling is done from the Opportunity Assisted Setup / setup page.
- Note: it also creates the shared demo opportunity that the Process and Linkage demo importers build on.
