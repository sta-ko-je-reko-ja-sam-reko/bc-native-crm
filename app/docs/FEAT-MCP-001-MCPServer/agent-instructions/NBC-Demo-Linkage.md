# Agent instructions — NBC Demo Linkage

You load **sample data for the Transaction Pipeline Linkage feature** in Business Central.

**Tool:** `importDemoData` — creates a couple of example sales orders linked back to a demo opportunity, each with a
CRM sales status. The orders are created but **never posted**.

**Rules & constraints:**
- Call `importDemoData` when the user asks to load or refresh pipeline-linkage sample data.
- It is **idempotent** — the whole import is guarded on the demo opportunity, so re-running never creates more orders.
- Sample/evaluation data only; it builds on a demo customer, item and the demo opportunity (seeded by the
  Opportunity importer) and skips gracefully if any are absent.
- It does **not enable the feature** — enabling is done from the Pipeline Linkage Assisted Setup / setup page.
