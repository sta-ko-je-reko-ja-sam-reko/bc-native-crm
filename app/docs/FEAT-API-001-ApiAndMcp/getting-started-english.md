# FEAT-API-001 - Connect and Automate

Make your CRM data available to other apps, to Power Platform flows, and to AI assistants such as Copilot — so the
information you keep in Business Central can be read and updated from outside it. This is an administrator task.

## What is available

Every part of the CRM — teams, activities, opportunities and their details, processes, product bundles and
relationships, discount lists, and the CRM information on your customers, contacts and items — is available through
Business Central's standard connections, grouped by area (for example *ownership*, *opportunity*, *catalog*,
*pricing*).

## Let another app or flow use the data

1. Work with your partner or administrator to connect the other system to Business Central using its standard
   connection settings.
2. Point it at the CRM area you need. Each record can be read and, where appropriate, created or updated.

## Turn on the AI (Copilot) tools

1. As an administrator, open the **Model Context Protocol (MCP) Server Configurations** from the search icon.
2. Set up a configuration that exposes the CRM areas you want an assistant to use, then activate it. (Your
   implementation team can pre-create one configuration per CRM area for you.)
3. Once active, an assistant such as Copilot can read and update those CRM records on request.

> Keep access aligned with permissions — a user or assistant only sees the CRM areas their permissions allow.
