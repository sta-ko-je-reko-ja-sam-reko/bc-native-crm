# Dataverse/D365 Sales **Opportunity** vs BC **Opportunity** (Relationship Management) — platform gap analysis

Platform-to-platform comparison of the Dataverse/Dynamics 365 Sales **`opportunity`** entity (table model +
model-driven forms + platform features) against BC's **Opportunity** (Relationship Management: table 5092
"Opportunity", Opportunity Card/List, Opportunity Entry, Sales Cycle / Sales Cycle Stage). Purpose: decide
which Opportunity capabilities `native-bc-crm` should natively replicate. Sync pair
**"Opportunity ↔ CRM Opportunity"** — see [architecture.md](../architecture.md) §2 default-mappings table
(CRM/D365 Sales connector).

> This compares the **real Dataverse Opportunity entity**, not the `CRM Opportunity` proxy table in BaseApp. The
> proxy only exposes the subset of opportunity attributes BC's sync couples (estimated value, close date, state),
> not the full pipeline model described below.

---

## 0. The framing asymmetry (read this first)

Both entities model **a potential sale**. But they sit at opposite ends of the maturity spectrum:

- **Dataverse `opportunity` is the centerpiece of D365 Sales** — a full pipeline object with **line items,
  pricing, a sales team, stakeholders, competitors, a guided Business Process Flow, won/lost closure with reason,
  quote/order/invoice generation, forecasting and predictive scoring**. It is the anchor around which the whole
  Sales app is built.
- **BC Opportunity is a lightweight Relationship Management record** — a header attached to a
  **Contact / Salesperson / Campaign**, moved through a configurable **Sales Cycle** of **stages**, carrying an
  **estimated value, chances-of-success and close date**. It has no line items, no team, no competitors.

| Concept | Dataverse | BC |
|---|---|---|
| The deal record | `opportunity` | **Opportunity** (table 5092) |
| Staged progression | Business Process Flow stages/steps | **Sales Cycle Stage** (via Sales Cycle) |
| Per-stage snapshot | (BPF stage transitions / audit) | **Opportunity Entry** (one row per stage change) |
| What's being sold | `opportunityproduct` line items | *(none)* |
| Convert to a sellable doc | Generate Quote / Order / Invoice | **Create Sales Quote** from opportunity |

So most "gaps" below exist because the Dataverse opportunity is a **thick pipeline object** while the BC
opportunity is a **thin RM tracking record**. This is the widest gap of any sync pair in §2 — note the few
places BC genuinely holds its own (§4) before assuming everything must be rebuilt.

---

## 1. Data model — attributes/capabilities Opportunity has that BC lacks

### Line items — the single biggest gap
- **`opportunityproduct`** (Opportunity Products / Line Items): each opportunity carries N product lines with
  **catalog products *or* write-in products**, quantity, unit, **per-line pricing** (price per unit, manual
  discount, tax, extended amount), and price-list (`pricelevelid`) driven pricing.
- BC's Opportunity has **no line items at all** — only a single header-level **Estimated Value**. There is no
  concept of "what products are in this deal" until a Sales Quote is created.

### Estimation, scoring & qualification fields
- `estimatedvalue` (**system-calculated** from product lines *or* **user-entered**), `estimatedclosedate`,
  `closeprobability`, `opportunityratingcode` (Hot/Warm/Cold), `budgetamount` / `budgetstatus`,
  `purchaseprocess` (Individual/Committee/Unknown), `purchasetimeframe`, `need`, `salesstage`,
  `stepname`, `timeline`.
- BC has a narrower set: **Estimated Value**, **Calculated Current Value**, **Chances of Success %**
  (from the sales cycle stage), **Estimated Close Date**, **Probability %** — no rating, budget, purchase
  process/timeframe, or need.

### Related entities that hang off the opportunity (all absent in BC)
- **Stakeholders** (`opportunity` ↔ `contact` via connection roles) — the buying-side people.
- **Sales team** (`opportunity` ↔ `systemuser`/`team`) — internal team beyond the single owner.
- **Competitors** (`opportunitycompetitors` N:N to the `competitor` entity) — who you're up against per deal.
- BC ties an opportunity to exactly **one Contact, one Salesperson, one Campaign, one Segment** — no
  multi-stakeholder, no team, no competitor tracking.

### Closure model
- Closing sets `statecode` to **Won** or **Lost** and creates an **`opportunityclose`** activity capturing
  actual revenue, close date and description; **status reasons** record *why* (e.g. Lost = price, competition,
  no decision).
- BC has **Activate / Close** actions and a **Close Opportunity Code** (won/lost/…) but **no close activity
  record** and no structured multi-reason taxonomy — closure is a status flip plus a reason code.

### Document generation
- From the opportunity you can **generate a Quote → Order → Invoice**, carrying the product lines forward.
- BC can **Create Sales Quote** from an opportunity (see §4) — but because there are no opportunity lines, the
  quote starts effectively empty of lines.

### Record-level currency & ownership
- `transactioncurrencyid` + `exchangerate` **per record**; `ownerid` / `owningteam` / `owningbusinessunit` with
  full **row-level security**. BC opportunity has a **Salesperson Code** (assignment, not ownership) and no
  per-record currency or row-level security.
- `statecode` / `statuscode` = Open / Won / Lost lifecycle with configurable status reasons; `originatingleadid`
  links the qualifying Lead.

---

## 2. Forms — what the Opportunity form has that BC pages don't

| Dataverse Opportunity main form | BC Opportunity Card / List |
|---|---|
| **Business Process Flow bar** — the *Lead-to-Opportunity Sales Process* rendered on the form with **stages and required steps** (Qualify → Develop → Propose → Close) | Sales-cycle **stages** exist as data, but there is **no on-form guided BPF bar** with per-step requirements |
| **Timeline control** — unified stream of emails, calls, appointments, tasks, notes | No unified timeline; **To-dos** (Tasks) and Interaction Log entries are separate lists on the related Contact |
| **Product line sub-grid** (Opportunity Products) with inline add/price | No line grid — single **Estimated Value** field only |
| **Stakeholders / Sales Team / Competitors sub-grids** | None |
| **Quotes / Orders / Invoices** related sub-grids generated from the deal | Related **Sales Quotes** only, via action (no order/invoice roll-up on the opportunity) |
| **Close as Won / Close as Lost** dialog capturing reason + actual revenue | **Close Opportunity** action with a close code; no revenue-capture dialog |
| **Embedded pipeline charts / forecast widgets** on views | Opportunity **statistics** and matrix pages, but no forecast widgets |
| **Business Rules** (no-code show/hide/require) + role-based forms | Logic is AL (OnValidate/events); one AL page |

---

## 3. Platform capabilities behind the Opportunity (BC handles differently or not at all)

- **Forecasting** — D365 Sales forecast grids roll opportunities up by owner/territory/product into a pipeline
  forecast with best-case/committed columns. BC has **no forecasting engine** for opportunities (only static
  estimated value and opportunity statistics).
- **Sales Insights / predictive opportunity scoring** — ML-driven opportunity score, relationship analytics,
  next-best-action, deal risk. BC has none.
- **Business Process Flows as a platform feature** — multi-entity guided processes with enforced steps, branching
  and stage security. BC's Sales Cycle is data-driven stages only, not an enforced process engine.
- **Activities as first-class entities** (email/appointment/phone call/task) with server-side Exchange sync,
  plus the **`opportunityclose`** activity. BC's To-dos are RM tasks with no Exchange server-side sync of the
  same kind.
- **Connections** with connection roles — arbitrary typed relationships (stakeholder, referral, influencer).
  Closest BC concept: Contact business relations (much narrower, not per-opportunity).
- **Row-level security / sharing / teams / field-level security**, **per-field audit history**, **duplicate
  detection**, **saved & personal views / Advanced Find**, **Power Automate flows** — all platform-level around
  the opportunity. BC = object-level permission sets + configurable Change Log.

---

## 4. Where BC already has an equivalent (don't rebuild these)

- **Sales Cycles & Sales Cycle Stages** — configurable, ordered stages each with a **completion / chances-of-
  success %** and allowed activities. This is a genuine (if lighter) analogue of the BPF stage list.
- **Opportunity Entry** — one row per stage change, giving a **stage-progression history** and enabling
  **opportunity statistics** (value by stage, by salesperson, by period) and the opportunities matrix.
- **Estimated Value + Calculated Current Value** (value × stage chances-of-success) and **Estimated Close Date**.
- **Links to Contact, Salesperson, Campaign, Segment** — the RM anchoring model.
- **To-dos (Tasks)** attached to the opportunity/contact for follow-up.
- **Activate / Close** actions with a close (won/lost) code.
- **Create Sales Quote** from an opportunity — the conversion hook into the ERP sales document flow.

> But note the hard stops: **no product/line items, no stakeholders, no competitors, no sales team, no BPF engine,
> no won/lost close activity or reason taxonomy, no forecasting, no unified timeline.**

---

## 5. Net gaps a BC-native CRM would close vs Opportunity

1. **Opportunity product lines** (catalog + write-in, per-line pricing → system-calculated estimated value).
2. **Stakeholders / competitors / sales team** as related records on the deal.
3. **BPF-style guided stages** with enforced steps (layer onto Sales Cycle / Sales Cycle Stage).
4. **Won/Lost closure with structured reasons + a close activity** capturing actual revenue.
5. **Pipeline forecasting** (roll-ups by owner/territory/product; best-case/committed).
6. **Unified activity timeline** on the opportunity record.

> Design note: BC already owns the **stage** (Sales Cycle) and **history** (Opportunity Entry) primitives — build
> the gaps *on top of* Relationship Management rather than replacing it. Line items and won/lost reasons are the
> highest-value additions; forecasting and predictive scoring are the heaviest lifts. Reuse the **Create Sales
> Quote** hook for conversion instead of inventing a parallel document flow.
