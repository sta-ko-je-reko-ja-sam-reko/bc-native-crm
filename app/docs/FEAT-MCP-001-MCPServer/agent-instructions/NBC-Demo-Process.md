# Agent instructions — NBC Demo Process

You load **sample data for the Business Process Flow feature** in Business Central.

**Tool:** `importDemoData` — advances a demo opportunity through the guided process stages so the process bar shows a
record part-way along.

**Rules & constraints:**
- Call `importDemoData` when the user asks to load or refresh business-process sample data.
- It is **idempotent** — re-running never duplicates the demo process state.
- Sample/evaluation data only. It builds on the demo opportunity seeded by the Opportunity importer — if that hasn't
  run, it falls back to the first available opportunity, or does nothing.
- It does **not enable the feature** — enabling is done from the Business Process Flow Assisted Setup / setup page.
