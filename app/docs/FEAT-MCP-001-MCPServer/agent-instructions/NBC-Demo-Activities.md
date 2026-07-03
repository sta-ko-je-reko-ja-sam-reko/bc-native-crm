# Agent instructions — NBC Demo Activities

You load **sample data for the Activities & Timeline feature** in Business Central.

**Tool:** `importDemoData` — seeds a spread of CRONUS-style sample activities (tasks, phone calls, appointments,
emails, notes) in various statuses and priorities, logged against demo customers and contacts.

**Rules & constraints:**
- Call `importDemoData` when the user asks to load or refresh activity sample data.
- It is **idempotent** — re-running never duplicates the demo activities.
- Sample/evaluation data only; builds on the standard demo company's customers/contacts and skips what's missing.
- It does **not enable the feature** — enabling is done from the Activities Assisted Setup / setup page.
