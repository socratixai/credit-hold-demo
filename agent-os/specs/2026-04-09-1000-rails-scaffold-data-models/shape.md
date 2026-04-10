# Rails Scaffold + Data Models — Shaping Notes

## Scope

Bootstrap the credit-hold demo as a Rails 8 app backed by Supabase (PostgreSQL). This phase covers only the application scaffold, database configuration, data model generation, and seed data. No UI screens are built yet.

## Decisions

- **Rails 8 + Propshaft** — lighter asset pipeline; FluentUI web components will be loaded via CDN in the UI phase, no JS bundler needed now
- **Skip tests** — demo app, shipping fast; minitest skipped
- **Supabase (not local Postgres)** — required from day one so Claude can connect via MCP later; user already has credentials
- **`dotenv-rails`** — credentials stored in `.env`, never committed
- **No Address table** — billing address embedded on Customer (street, city, country) for demo simplicity
- **User model (no auth)** — needed as actor_id on hold events and CRM interactions; no Devise or session management yet
- **Product model** — needed for SalesOrderLine; simple sku + unit_price
- **`credit_snapshot: jsonb`** on OrderCreditHoldEvent — event-sourcing pattern to preserve the exact exposure numbers at decision time, even after invoices are later paid

## Data Model Clusters

1. **Customer cluster** — Customer, CustomerCreditProfile, User
2. **Order & Invoice cluster** — SalesOrder, SalesOrderLine, Invoice, Product
3. **Credit Hold Event cluster** — CreditHoldRule, OrderCreditHoldEvent
4. **CRM cluster** — CRMAccount, CustomerInteraction

## Context

- **Visuals:** None
- **References:** Dynamics 365 credit management, Fitrix ERP credit policy, Deskera dunning logic
- **Product alignment:** Phase 1 MVP foundation — Supabase backend is non-negotiable for MCP/Claude integration

## Standards Applied

None defined yet (standards/index.yml is empty).
