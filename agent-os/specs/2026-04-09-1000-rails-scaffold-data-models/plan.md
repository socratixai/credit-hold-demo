# Plan: Rails Scaffold + Data Models — Credit Hold Demo

## Context

Greenfield Rails 8 app for a mock ERP credit-hold demo. The repo exists but has no application code yet — only agent-os docs. This phase creates the Rails application, wires up Supabase as the PostgreSQL backend (critical for later MCP/Claude integration), defines the full ERP-accurate data model, and populates realistic seed data.

Tech stack: Rails 8, Ruby 3.3+, Supabase (PostgreSQL), ERB/Hotwire, FluentUI web components (CDN, UI phase).

---

## Task 1: Save Spec Documentation

Create `agent-os/specs/2026-04-09-1000-rails-scaffold-data-models/` with:
- `plan.md` — this full plan
- `shape.md` — shaping notes and decisions
- `standards.md` — "No standards defined yet"
- `references.md` — ERP reference links from shaping conversation

---

## Task 2: Create Rails Application

```bash
rails new . --database=postgresql --skip-test --asset-pipeline=propshaft
```

Add to `Gemfile`:
```ruby
gem "dotenv-rails", groups: [:development, :test]
```

---

## Task 3: Configure Supabase Connection

Create `.env` (gitignored):
```
DATABASE_URL=postgres://...  # user will fill in credentials
```

Update `config/database.yml`:
```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  url: <%= ENV["DATABASE_URL"] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
test:
  <<: *default
production:
  <<: *default
```

---

## Task 4: Generate Data Models and Migrations

### Cluster 1: Core Customer

**User** (needed for actor_id references across hold events and CRM)
```
rails g model User name:string email:string role:string
```
- role enum: `credit_manager`, `sales_rep`, `admin`

**Customer**
```
rails g model Customer name:string tax_id:string segment:string \
  billing_street:string billing_city:string billing_country:string
```
- segment enum: `sme`, `enterprise`, `strategic`

**CustomerCreditProfile**
```
rails g model CustomerCreditProfile customer:references \
  credit_limit:decimal{10,2} credit_hold_flag:boolean \
  payment_terms_days:integer currency_code:string \
  review_date:date updated_by:references{polymorphic}
```
- `updated_by` → FK to User (rename in migration to `updated_by_id`)
- Defaults: `credit_hold_flag: false`, `payment_terms_days: 30`, `currency_code: "USD"`

---

### Cluster 2: Order & Invoice

**Product** (needed for SalesOrderLine)
```
rails g model Product name:string sku:string unit_price:decimal{10,2} \
  currency_code:string
```

**SalesOrder**
```
rails g model SalesOrder customer:references order_date:date \
  status:string total_amount:decimal{10,2} currency_code:string
```
- status enum: `draft`, `pending_credit_check`, `approved`, `on_hold`, `released`, `fulfilled`
- Add index on `[customer_id, status]`

**SalesOrderLine**
```
rails g model SalesOrderLine sales_order:references product:references \
  quantity:integer unit_price:decimal{10,2}
```

**Invoice**
```
rails g model Invoice sales_order:references invoice_date:date due_date:date \
  total_amount:decimal{10,2} paid_amount:decimal{10,2} \
  status:string currency_code:string
```
- status enum: `open`, `partially_paid`, `paid`, `overdue`, `disputed`
- Add index on `[sales_order_id, status]`

---

### Cluster 3: Credit Hold Events

**CreditHoldRule**
```
rails g model CreditHoldRule name:string rule_type:string \
  threshold_value:decimal{10,2} is_active:boolean
```
- rule_type enum: `overdue_amount`, `credit_utilization_pct`, `overdue_days`, `manual`
- Default: `is_active: true`

**OrderCreditHoldEvent**
```
rails g model OrderCreditHoldEvent sales_order:references \
  triggered_by_rule:references event_type:string event_date:datetime \
  actor:references override_reason:text credit_snapshot:jsonb
```
- `triggered_by_rule_id` → FK to CreditHoldRule, nullable
- `actor_id` → FK to User
- event_type enum: `placed_on_hold`, `released`, `overridden`
- `credit_snapshot` stores jsonb snapshot of exposure at decision time

---

### Cluster 4: CRM

**CRMAccount**
```
rails g model CRMAccount customer:references \
  account_potential:string estimated_annual_value:decimal{10,2} \
  relationship_owner:references notes:text
```
- `relationship_owner_id` → FK to User
- account_potential enum: `low`, `medium`, `high`, `strategic`

**CustomerInteraction**
```
rails g model CustomerInteraction customer:references interaction_type:string \
  interaction_date:date actor:references summary:text sentiment:string
```
- `actor_id` → FK to User
- interaction_type enum: `visit`, `call`, `email`, `meeting`, `complaint`
- sentiment enum: `positive`, `neutral`, `negative`

---

### Model associations & validations

Add to each model after generation:
- `Customer`: `has_one :customer_credit_profile`, `has_many :sales_orders`, `has_many :customer_interactions`, `has_one :crm_account`
- `CustomerCreditProfile`: `belongs_to :customer`, `belongs_to :updated_by, class_name: "User"`
- `SalesOrder`: `belongs_to :customer`, `has_many :sales_order_lines`, `has_many :order_credit_hold_events`
- `Invoice`: `belongs_to :sales_order`
- `OrderCreditHoldEvent`: `belongs_to :sales_order`, `belongs_to :triggered_by_rule, class_name: "CreditHoldRule", optional: true`, `belongs_to :actor, class_name: "User"`
- `CRMAccount`: `belongs_to :customer`, `belongs_to :relationship_owner, class_name: "User"`
- `CustomerInteraction`: `belongs_to :customer`, `belongs_to :actor, class_name: "User"`

---

## Task 5: Seed Demo Data

`db/seeds.rb` — create a realistic ERP scenario:

**Users (3):**
- Alice Chen — credit_manager
- Bob Torres — sales_rep
- Carol Webb — admin

**Credit Hold Rules (3):**
- "Overdue Balance Threshold" — overdue_amount > $5,000
- "Credit Utilization" — credit_utilization_pct > 90%
- "Overdue Days" — overdue_days > 60

**Customers (5):**
1. Acme Corp — Enterprise, $50k limit → ON HOLD (credit limit exceeded)
2. Globex LLC — SME, $15k limit → ON HOLD (overdue invoices)
3. Initech Ltd — Enterprise, $75k limit → good standing
4. Hooli Inc — Strategic, $200k limit → good standing
5. Pied Piper Co — SME, $10k limit → good standing

For each customer:
- `CustomerCreditProfile` with matching credit limits
- `CRMAccount` with account potential and relationship owner
- `Product` entries (5 shared products)
- `SalesOrders` (3–5 per customer) with `SalesOrderLines`
- `Invoices` per order (mix of paid, overdue, open)
- `CustomerInteractions` (2–3 per customer)

For Acme Corp and Globex (held customers):
- 1–2 orders in `pending_credit_check` status (the review queue)
- `OrderCreditHoldEvents` showing the hold was placed automatically by a rule
- `credit_snapshot` with realistic exposure numbers

---

## Task 6: Verify

```bash
rails db:create db:migrate db:seed
rails runner "
  puts \"Users: #{User.count}\"
  puts \"Customers: #{Customer.count}\"
  puts \"Orders: #{SalesOrder.count}\"
  puts \"Invoices: #{Invoice.count}\"
  puts \"Hold Events: #{OrderCreditHoldEvent.count}\"
"
```

Confirm records appear in Supabase dashboard table viewer.
