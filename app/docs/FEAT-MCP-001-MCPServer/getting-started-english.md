# FEAT-MCP-001 - MCP Server

Connect AI assistants — like a **GitHub Copilot** agent — to your CRM, so they can read and update CRM records or
load sample data on your behalf, safely and within clear limits.

## Prepare the connectors in Business Central

1. Make sure the **MCP server** is turned on for your environment (an administrator enables it in the environment's
   feature settings).
2. Have an administrator run the **CRM MCP setup** once. It creates a set of ready-made **MCP configurations** —
   one per CRM area (ownership, activities, opportunities, process, catalog, pricing, customers & contacts) and one
   per **sample-data importer**. Running it again is safe.
3. Open the **MCP Configurations** list to review them. Each configuration is a **scoped tool set** — an agent
   connected to it can use only those tools.

## Connect a GitHub Copilot agent

1. Open the configuration you want an agent to use and choose **Generate connection string**.
2. In **GitHub Copilot**, create an agent and connect it to that configuration using the connection string.
3. One agent connects to **one** configuration — so create a separate agent per area you want to automate.

## Give the agent its instructions

1. In the project, open the **agent-instructions** folder for this feature and find the file whose name matches the
   configuration (for example the *Catalog* file for the *NBC CRM Catalog* configuration).
2. **Copy the whole file into that agent's instructions** in GitHub Copilot. This tells the agent what it manages,
   which tools it has, when to use them, and the rules to follow (for example: look records up rather than invent
   them; never post documents; sample-data imports don't switch a feature on).
3. Repeat per agent — each configuration has its own instructions file.

## Load sample data through an agent (optional)

- Connect an agent to one of the **sample-data** configurations and paste its instructions. Ask the agent to
  **import the sample data** for that area — it's safe to run more than once and never creates duplicates. It loads
  example records only; it does **not** turn the feature on (do that from the feature's setup guide).

## Keep instructions current

- Whenever a configuration's tools change — or a new configuration is added — update (or add) the matching
  instructions file and re-paste it into the connected agent, so the agent's guidance never drifts from what it can
  actually do.
