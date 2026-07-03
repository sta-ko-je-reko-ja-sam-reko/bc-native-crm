# Dataverse **`systemuser`** vs BC **Salesperson/Purchaser** — platform gap analysis

Platform-to-platform comparison of the Dataverse **`systemuser`** entity (table model + platform role) against
BC's **Salesperson/Purchaser** table (table **13**, *Salespersons/Purchasers* page). This is the sync pair
**Salesperson/Purchaser ↔ CRM Systemuser** from [architecture.md](architecture.md) §2 (CDS base connector,
**Dataverse → BC** only). Purpose: decide which systemuser capabilities `native-bc-crm` should natively replicate.

> This compares the **real Dataverse systemuser entity**, not the `CRM Systemuser` proxy table in BaseApp. The
> proxy exposes only the handful of attributes the salesperson mapping cares about (name, email, phone —
> see [architecture.md](architecture.md) §2 default-mappings table). The sync is **one-way into BC**: BC never
> creates or writes a systemuser.

---

## 0. The framing asymmetry (read this first)

**`systemuser` is a security principal — an identity that logs in and owns records.** It is an Entra ID user with
a license, security roles, team memberships, a business unit, a place in the org hierarchy, queues, a calendar,
and a territory. In Dataverse **every record is owned** by a systemuser (or team); ownership *is* the security model.

**BC "Salesperson/Purchaser" is not a principal — it is an attribution master record.** Code + Name + commission %
+ email/phone + Dimensions. It does **not** log in, holds **no** permissions, and **owns nothing**. BC's login
identity is a *separate* object entirely: the **User** (table `2000000120`) + **User Setup** (table 91) +
**Access Control** / permission sets (object-level).

So the honest mapping is:

| Dataverse | ≈ | BC |
|---|---|---|
| `systemuser` (attribution slice: name, email, phone, title) | ↔ | **Salesperson/Purchaser** (table 13) |
| `systemuser` (identity + security slice: login, roles, teams, BU, hierarchy) | ↔ | **User** (2000000120) + **User Setup** (91) + permission sets |

**The CDS sync maps only the attribution slice.** One `systemuser` splits into two unrelated BC objects, and the
sync touches only the lightweight one. Every "gap" below is really "the security/identity half that lives on the
BC User, or nowhere."

---

## 1. Data model — what `systemuser` has that BC Salesperson lacks

BC **Salesperson/Purchaser** (table 13) is deliberately thin: `Code` (PK), `Name`, `Commission %`, `Phone No.`,
`E-Mail`, `Job Title`, `Privacy Blocked`, `Global Dimension 1/2 Code` (+ full `Salesperson/Purchaser Dimensions`),
`Image`, activity/next-task FactBox fields, and the CRM coupling. That is the whole record.

### Identity & authentication (entirely absent on Salesperson)
- `domainname` (UPN), `azureactivedirectoryobjectid`, `applicationid` (for application/service users) — the actual
  **login identity**. Salesperson has no login; BC login lives on **User** (`User Security ID`, `Authentication Email`,
  `Windows Security ID`).
- `isdisabled`, `accessmode`, `islicensed`, `caltype`, `invitestatuscode`, `setupuser`, `isintegrationuser` —
  license/enablement state. BC's equivalent is `User.State` + `User.License Type`, **not** on Salesperson.

### Ownership & row-level security (the biggest structural gap)
- A `systemuser` is an **owner** — `ownerid` on every Dataverse record points at a user or team. BC has **no
  per-record ownership** at all; a Salesperson code is an attribute you *stamp* on documents, not a security boundary.
- `businessunitid` — every systemuser belongs to exactly one **Business Unit**, the root of the ownership tree.
  BC has no business-unit partitioning of data (BC uses **Companies**, a coarser, fully separate database boundary).

### Organizational structure & security scoping
- `parentsystemuserid` — **manager hierarchy**, which drives *Manager Hierarchy* / *Position Hierarchy* security
  (a manager can see subordinates' records). Salesperson has no manager link and BC has no hierarchy security.
- `positionid` — a **Position** in the position hierarchy (independent of the manager chain). No BC equivalent.
- `territoryid` — sales **Territory**. BC has no territory concept on Salesperson (closest is Dimensions).

### Access rights (live on the systemuser, nowhere near Salesperson)
- **Security roles** (`systemuserroles_association` N:N to `role`) — the privilege set. BC's analogue is
  **permission sets** assigned via **Access Control** to the **User**, and it is **object-level** (table/object
  read/insert/modify/delete), never per-record.
- **Field-level security profiles** — column-level secured-field access. BC has no field-level security.
- **Team memberships** (`teammembership_association`) — owner teams / access teams for sharing. **BC has no team
  concept.** (Note: the CDS connector *does* maintain a Dataverse-side **Team**/Business-Unit coupling for
  ownership plumbing — see [architecture.md](architecture.md) §2 — but that never lands as BC data.)

### Work distribution & collaboration
- **Queues** and queue membership (case/activity routing). No BC equivalent.
- `calendarid` → **working hours / service calendar** (used by scheduling and SLAs). BC has base calendars for
  *inventory/shipment* planning, but nothing tied to a salesperson's availability.

### Contact & profile detail
- Rich profile: `title`, multiple phone slots, `address1_*` composite address, `mobilealertemail`,
  `homephone`, `preferredphonecode`, `incoming/outgoingemaildeliverymethod`. Salesperson carries only
  `Phone No.`, `E-Mail`, `Job Title`.

### Sales performance
- **Sales Insights** goals/quotas, activity rollups, and relationship analytics attributed to the user. BC's
  Salesperson only aggregates **commission %** and ledger-attributed statistics — no quota/goal model.

---

## 2. Where BC differs by design (and is fine as-is)

- **Salesperson is intentionally lightweight.** Its job is *attribution + commission + Dimensions* on documents
  and ledger entries — a reporting/analytics key, not an actor. Loading it with identity fields would be wrong.
- **BC security is object-level, on the User, not per-record.** Permission sets grant object rights; there is no
  ownership, sharing, BU, team, or hierarchy scoping to replicate on the master record. This is a genuine
  architectural difference, not a missing field.
- **Salesperson ↔ User is a loose, optional link.** `User Setup."Salespers./Purch. Code"` (table 91) is the only
  bridge between the attribution record and the login identity, and it is optional — many salespersons have no BC
  user, and many BC users have no salesperson code.

---

## 3. Net gaps a BC-native CRM would close vs systemuser

Proportionate to the entity — most of what `systemuser` carries is BC *platform* concern (users, licensing,
permission sets) that a CRM app should **not** rebuild. The CRM-relevant gaps are:

1. **Record ownership + a team model** — the single most important gap. CRM-style row-level security (owner user/
   team, sharing, "my records" views) has *no* BC primitive; a BC-native CRM that wants it must introduce an
   ownership field + team table itself, layered over BC's object-level permission sets.
2. **Manager / position hierarchy** on the CRM party record (for pipeline roll-up and hierarchy-scoped visibility).
3. **Territory** as a first-class attribute (today only expressible via Dimensions).
4. **Working hours / availability** on the rep, if scheduling or SLA features are in scope.

> Design note: don't try to make **Salesperson/Purchaser** a security principal — that fights BC's model. Keep
> Salesperson as attribution, keep login/permissions on the BC **User**, and if CRM security is required, add a
> *new* ownership + team layer rather than overloading table 13. Reuse `User Setup."Salespers./Purch. Code"` as the
> bridge between the acting user and the attribution record.
