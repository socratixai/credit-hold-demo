# Credit Hold Demo — Seed Data
# Idempotent: uses find_or_create_by! on natural keys

puts "Seeding users..."

alice = User.find_or_create_by!(email: "alice.chen@erpdemo.com") do |u|
  u.name = "Alice Chen"
  u.role = "credit_manager"
end

bob = User.find_or_create_by!(email: "bob.torres@erpdemo.com") do |u|
  u.name = "Bob Torres"
  u.role = "sales_rep"
end

carol = User.find_or_create_by!(email: "carol.webb@erpdemo.com") do |u|
  u.name = "Carol Webb"
  u.role = "admin"
end

puts "Seeding credit hold rules..."

rule_overdue_amount = CreditHoldRule.find_or_create_by!(name: "Overdue Balance Threshold") do |r|
  r.rule_type = "overdue_amount"
  r.threshold_value = 5_000.00
  r.is_active = true
end

rule_utilization = CreditHoldRule.find_or_create_by!(name: "Credit Utilization") do |r|
  r.rule_type = "credit_utilization_pct"
  r.threshold_value = 90.0
  r.is_active = true
end

rule_days = CreditHoldRule.find_or_create_by!(name: "Overdue Days") do |r|
  r.rule_type = "overdue_days"
  r.threshold_value = 60
  r.is_active = true
end

puts "Seeding products..."

products = [
  { sku: "PROD-001", name: "Enterprise License (Annual)", unit_price: 12_000.00 },
  { sku: "PROD-002", name: "Professional Services (Day Rate)", unit_price: 1_800.00 },
  { sku: "PROD-003", name: "Hardware Kit", unit_price: 3_400.00 },
  { sku: "PROD-004", name: "Support & Maintenance (Annual)", unit_price: 2_500.00 },
  { sku: "PROD-005", name: "Training Package", unit_price: 950.00 }
].map do |attrs|
  Product.find_or_create_by!(sku: attrs[:sku]) do |p|
    p.name = attrs[:name]
    p.unit_price = attrs[:unit_price]
    p.currency_code = "USD"
  end
end

enterprise_license, pro_services, hardware, support, training = products

puts "Seeding customers..."

# --- Customer 1: Acme Corp — ON HOLD (credit limit exceeded) ---
acme = Customer.find_or_create_by!(name: "Acme Corp") do |c|
  c.tax_id = "US-12-3456789"
  c.segment = "enterprise"
  c.billing_street = "800 Industrial Blvd"
  c.billing_city = "Chicago"
  c.billing_country = "US"
end

CustomerCreditProfile.find_or_create_by!(customer: acme) do |p|
  p.credit_limit = 50_000.00
  p.credit_hold_flag = true
  p.payment_terms_days = 30
  p.currency_code = "USD"
  p.review_date = Date.today + 30
  p.updated_by = alice
end

CrmAccount.find_or_create_by!(customer: acme) do |a|
  a.account_potential = "high"
  a.estimated_annual_value = 85_000.00
  a.relationship_owner = bob
  a.notes = "Long-standing enterprise client. Expansion planned for Q3. Hold triggered by credit limit breach — seasonal cash flow issue per last call."
end

# Acme orders: fulfilled, fulfilled, pending_credit_check (the new one blocked)
acme_order1 = SalesOrder.find_or_create_by!(customer: acme, order_date: 60.days.ago.to_date) do |o|
  o.status = "fulfilled"
  o.total_amount = 24_000.00
  o.currency_code = "USD"
end
SalesOrderLine.find_or_create_by!(sales_order: acme_order1, product: enterprise_license) { |l| l.quantity = 2; l.unit_price = 12_000.00 }
Invoice.find_or_create_by!(sales_order: acme_order1) do |i|
  i.invoice_date = 58.days.ago.to_date
  i.due_date = 28.days.ago.to_date
  i.total_amount = 24_000.00
  i.paid_amount = 0
  i.status = "overdue"
  i.currency_code = "USD"
end

acme_order2 = SalesOrder.find_or_create_by!(customer: acme, order_date: 45.days.ago.to_date) do |o|
  o.status = "fulfilled"
  o.total_amount = 18_500.00
  o.currency_code = "USD"
end
SalesOrderLine.find_or_create_by!(sales_order: acme_order2, product: pro_services) { |l| l.quantity = 5; l.unit_price = 1_800.00 }
SalesOrderLine.find_or_create_by!(sales_order: acme_order2, product: support) { |l| l.quantity = 4; l.unit_price = 2_500.00 }
Invoice.find_or_create_by!(sales_order: acme_order2) do |i|
  i.invoice_date = 43.days.ago.to_date
  i.due_date = 13.days.ago.to_date
  i.total_amount = 18_500.00
  i.paid_amount = 18_500.00
  i.status = "paid"
  i.currency_code = "USD"
end

acme_order3 = SalesOrder.find_or_create_by!(customer: acme, order_date: 3.days.ago.to_date) do |o|
  o.status = "pending_credit_check"
  o.total_amount = 15_200.00
  o.currency_code = "USD"
end
SalesOrderLine.find_or_create_by!(sales_order: acme_order3, product: hardware) { |l| l.quantity = 4; l.unit_price = 3_400.00 }
SalesOrderLine.find_or_create_by!(sales_order: acme_order3, product: training) { |l| l.quantity = 2; l.unit_price = 950.00 }

OrderCreditHoldEvent.find_or_create_by!(sales_order: acme_order3, event_type: "placed_on_hold") do |e|
  e.triggered_by_rule = rule_utilization
  e.event_date = 3.days.ago
  e.actor = alice
  e.credit_snapshot = {
    credit_limit: 50_000.00,
    open_invoices_total: 24_000.00,
    pending_orders_total: 15_200.00,
    total_exposure: 39_200.00,
    utilization_pct: 78.4,
    rule_triggered: "credit_utilization_pct > 90% threshold not breached, but overdue invoice exceeded $5k threshold"
  }
end

CustomerInteraction.find_or_create_by!(customer: acme, interaction_date: 10.days.ago.to_date, interaction_type: "call") do |i|
  i.actor = bob
  i.summary = "Spoke with CFO. They acknowledge the overdue invoice — payment expected within 2 weeks due to delayed receivables from their own customers."
  i.sentiment = "neutral"
end
CustomerInteraction.find_or_create_by!(customer: acme, interaction_date: 2.days.ago.to_date, interaction_type: "email") do |i|
  i.actor = alice
  i.summary = "Sent formal credit hold notification. Awaiting signed payment commitment."
  i.sentiment = "neutral"
end

# --- Customer 2: Globex LLC — ON HOLD (overdue invoices) ---
globex = Customer.find_or_create_by!(name: "Globex LLC") do |c|
  c.tax_id = "US-98-7654321"
  c.segment = "sme"
  c.billing_street = "42 Commerce Park"
  c.billing_city = "Dallas"
  c.billing_country = "US"
end

CustomerCreditProfile.find_or_create_by!(customer: globex) do |p|
  p.credit_limit = 15_000.00
  p.credit_hold_flag = true
  p.payment_terms_days = 30
  p.currency_code = "USD"
  p.review_date = Date.today + 14
  p.updated_by = alice
end

CrmAccount.find_or_create_by!(customer: globex) do |a|
  a.account_potential = "medium"
  a.estimated_annual_value = 22_000.00
  a.relationship_owner = bob
  a.notes = "Growing SME. Second late payment this year. Strategic value moderate — worth working with but needs payment discipline."
end

globex_order1 = SalesOrder.find_or_create_by!(customer: globex, order_date: 75.days.ago.to_date) do |o|
  o.status = "fulfilled"
  o.total_amount = 6_800.00
  o.currency_code = "USD"
end
SalesOrderLine.find_or_create_by!(sales_order: globex_order1, product: enterprise_license) { |l| l.quantity = 1; l.unit_price = 6_800.00 }
Invoice.find_or_create_by!(sales_order: globex_order1) do |i|
  i.invoice_date = 73.days.ago.to_date
  i.due_date = 43.days.ago.to_date
  i.total_amount = 6_800.00
  i.paid_amount = 0
  i.status = "overdue"
  i.currency_code = "USD"
end

globex_order2 = SalesOrder.find_or_create_by!(customer: globex, order_date: 5.days.ago.to_date) do |o|
  o.status = "pending_credit_check"
  o.total_amount = 4_750.00
  o.currency_code = "USD"
end
SalesOrderLine.find_or_create_by!(sales_order: globex_order2, product: support) { |l| l.quantity = 1; l.unit_price = 2_500.00 }
SalesOrderLine.find_or_create_by!(sales_order: globex_order2, product: training) { |l| l.quantity = 2; l.unit_price = 950.00 }
SalesOrderLine.find_or_create_by!(sales_order: globex_order2, product: pro_services) { |l| l.quantity = 1; l.unit_price = 350.00 }

OrderCreditHoldEvent.find_or_create_by!(sales_order: globex_order2, event_type: "placed_on_hold") do |e|
  e.triggered_by_rule = rule_overdue_amount
  e.event_date = 5.days.ago
  e.actor = alice
  e.credit_snapshot = {
    credit_limit: 15_000.00,
    open_invoices_total: 6_800.00,
    pending_orders_total: 4_750.00,
    total_exposure: 11_550.00,
    overdue_invoice_count: 1,
    oldest_overdue_days: 43,
    rule_triggered: "overdue_amount $6,800 exceeds $5,000 threshold"
  }
end

CustomerInteraction.find_or_create_by!(customer: globex, interaction_date: 15.days.ago.to_date, interaction_type: "visit") do |i|
  i.actor = bob
  i.summary = "On-site visit. Operations expanding — new warehouse opened. Finance team is understaffed and payments are falling behind."
  i.sentiment = "positive"
end
CustomerInteraction.find_or_create_by!(customer: globex, interaction_date: 3.days.ago.to_date, interaction_type: "call") do |i|
  i.actor = alice
  i.summary = "Called about overdue invoice INV-75d. Promised payment by end of week. New order flagged for credit hold pending payment."
  i.sentiment = "neutral"
end

# --- Customer 3: Initech Ltd — Good standing ---
initech = Customer.find_or_create_by!(name: "Initech Ltd") do |c|
  c.tax_id = "US-55-1122334"
  c.segment = "enterprise"
  c.billing_street = "1 Corporate Plaza"
  c.billing_city = "Atlanta"
  c.billing_country = "US"
end

CustomerCreditProfile.find_or_create_by!(customer: initech) do |p|
  p.credit_limit = 75_000.00
  p.credit_hold_flag = false
  p.payment_terms_days = 45
  p.currency_code = "USD"
  p.updated_by = carol
end

CrmAccount.find_or_create_by!(customer: initech) do |a|
  a.account_potential = "high"
  a.estimated_annual_value = 120_000.00
  a.relationship_owner = bob
  a.notes = "Reliable enterprise client. Always pays on time. Evaluating expansion to 3 additional sites."
end

initech_order1 = SalesOrder.find_or_create_by!(customer: initech, order_date: 30.days.ago.to_date) do |o|
  o.status = "fulfilled"
  o.total_amount = 36_000.00
  o.currency_code = "USD"
end
SalesOrderLine.find_or_create_by!(sales_order: initech_order1, product: enterprise_license) { |l| l.quantity = 3; l.unit_price = 12_000.00 }
Invoice.find_or_create_by!(sales_order: initech_order1) do |i|
  i.invoice_date = 28.days.ago.to_date
  i.due_date = 17.days.from_now.to_date
  i.total_amount = 36_000.00
  i.paid_amount = 36_000.00
  i.status = "paid"
  i.currency_code = "USD"
end

initech_order2 = SalesOrder.find_or_create_by!(customer: initech, order_date: Date.today) do |o|
  o.status = "approved"
  o.total_amount = 9_900.00
  o.currency_code = "USD"
end
SalesOrderLine.find_or_create_by!(sales_order: initech_order2, product: support) { |l| l.quantity = 2; l.unit_price = 2_500.00 }
SalesOrderLine.find_or_create_by!(sales_order: initech_order2, product: training) { |l| l.quantity = 5; l.unit_price = 950.00 }

CustomerInteraction.find_or_create_by!(customer: initech, interaction_date: 7.days.ago.to_date, interaction_type: "meeting") do |i|
  i.actor = bob
  i.summary = "Quarterly business review. Satisfied with product. Confirmed renewal and exploring site expansion."
  i.sentiment = "positive"
end

# --- Customer 4: Hooli Inc — Good standing, strategic ---
hooli = Customer.find_or_create_by!(name: "Hooli Inc") do |c|
  c.tax_id = "US-77-9988776"
  c.segment = "strategic"
  c.billing_street = "500 Innovation Drive"
  c.billing_city = "San Francisco"
  c.billing_country = "US"
end

CustomerCreditProfile.find_or_create_by!(customer: hooli) do |p|
  p.credit_limit = 200_000.00
  p.credit_hold_flag = false
  p.payment_terms_days = 60
  p.currency_code = "USD"
  p.updated_by = carol
end

CrmAccount.find_or_create_by!(customer: hooli) do |a|
  a.account_potential = "strategic"
  a.estimated_annual_value = 450_000.00
  a.relationship_owner = bob
  a.notes = "Top-tier strategic account. Multi-year contract. Executive relationship managed at VP level."
end

hooli_order1 = SalesOrder.find_or_create_by!(customer: hooli, order_date: 90.days.ago.to_date) do |o|
  o.status = "fulfilled"
  o.total_amount = 96_000.00
  o.currency_code = "USD"
end
SalesOrderLine.find_or_create_by!(sales_order: hooli_order1, product: enterprise_license) { |l| l.quantity = 8; l.unit_price = 12_000.00 }
Invoice.find_or_create_by!(sales_order: hooli_order1) do |i|
  i.invoice_date = 88.days.ago.to_date
  i.due_date = 28.days.ago.to_date
  i.total_amount = 96_000.00
  i.paid_amount = 96_000.00
  i.status = "paid"
  i.currency_code = "USD"
end

CustomerInteraction.find_or_create_by!(customer: hooli, interaction_date: 5.days.ago.to_date, interaction_type: "meeting") do |i|
  i.actor = bob
  i.summary = "Annual executive review with VP of Finance and CTO. Discussed roadmap for next year rollout across APAC offices."
  i.sentiment = "positive"
end

# --- Customer 5: Pied Piper Co — Good standing, SME ---
pied_piper = Customer.find_or_create_by!(name: "Pied Piper Co") do |c|
  c.tax_id = "US-33-4455667"
  c.segment = "sme"
  c.billing_street = "77 Startup Lane"
  c.billing_city = "Palo Alto"
  c.billing_country = "US"
end

CustomerCreditProfile.find_or_create_by!(customer: pied_piper) do |p|
  p.credit_limit = 10_000.00
  p.credit_hold_flag = false
  p.payment_terms_days = 30
  p.currency_code = "USD"
  p.updated_by = carol
end

CrmAccount.find_or_create_by!(customer: pied_piper) do |a|
  a.account_potential = "medium"
  a.estimated_annual_value = 18_000.00
  a.relationship_owner = bob
  a.notes = "Fast-growing startup. Watch credit exposure as they scale. Good payment history so far."
end

pied_piper_order1 = SalesOrder.find_or_create_by!(customer: pied_piper, order_date: 20.days.ago.to_date) do |o|
  o.status = "fulfilled"
  o.total_amount = 3_850.00
  o.currency_code = "USD"
end
SalesOrderLine.find_or_create_by!(sales_order: pied_piper_order1, product: support) { |l| l.quantity = 1; l.unit_price = 2_500.00 }
SalesOrderLine.find_or_create_by!(sales_order: pied_piper_order1, product: training) { |l| l.quantity = 1; l.unit_price = 950.00 }
SalesOrderLine.find_or_create_by!(sales_order: pied_piper_order1, product: pro_services) { |l| l.quantity = 1; l.unit_price = 400.00 }
Invoice.find_or_create_by!(sales_order: pied_piper_order1) do |i|
  i.invoice_date = 18.days.ago.to_date
  i.due_date = 12.days.from_now.to_date
  i.total_amount = 3_850.00
  i.paid_amount = 3_850.00
  i.status = "paid"
  i.currency_code = "USD"
end

CustomerInteraction.find_or_create_by!(customer: pied_piper, interaction_date: 12.days.ago.to_date, interaction_type: "call") do |i|
  i.actor = bob
  i.summary = "Introductory check-in. Happy with onboarding. May need additional licenses as team grows."
  i.sentiment = "positive"
end

puts ""
puts "Seed complete:"
puts "  Users:                    #{User.count}"
puts "  Customers:                #{Customer.count}"
puts "  Credit Hold Rules:        #{CreditHoldRule.count}"
puts "  Products:                 #{Product.count}"
puts "  Sales Orders:             #{SalesOrder.count}"
puts "  Sales Order Lines:        #{SalesOrderLine.count}"
puts "  Invoices:                 #{Invoice.count}"
puts "  Order Credit Hold Events: #{OrderCreditHoldEvent.count}"
puts "  CRM Accounts:             #{CrmAccount.count}"
puts "  Customer Interactions:    #{CustomerInteraction.count}"
puts ""
puts "Customers on hold: #{CustomerCreditProfile.where(credit_hold_flag: true).count}"
puts "Orders pending credit check: #{SalesOrder.where(status: 'pending_credit_check').count}"
