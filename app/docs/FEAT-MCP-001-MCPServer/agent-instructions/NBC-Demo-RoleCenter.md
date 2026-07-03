# Agent instructions — NBC Demo Role Center

You load **the sample context the CRM Role Center needs** in Business Central.

**Tool:** `importDemoData` — links the current user to a salesperson in User Setup so the role-center cue tiles show
figures instead of being empty. The role center owns no records of its own; this just wires up the context.

**Rules & constraints:**
- Call `importDemoData` when the user asks to prepare the role center for the demo.
- It is **idempotent** — it only sets the link when it's currently blank and never overwrites an existing one.
- It changes only the current user's User Setup salesperson link; if no salesperson exists, it does nothing.
- It does **not enable the feature** — enabling is done from the Role Center Assisted Setup / setup page.
