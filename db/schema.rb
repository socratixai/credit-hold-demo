# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_09_132116) do
  create_schema "extensions"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "public.credit_hold_rules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.string "rule_type", null: false
    t.decimal "threshold_value", precision: 10, scale: 2
    t.datetime "updated_at", null: false
  end

  create_table "public.crm_accounts", force: :cascade do |t|
    t.string "account_potential"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.decimal "estimated_annual_value", precision: 10, scale: 2
    t.text "notes"
    t.bigint "relationship_owner_id"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_crm_accounts_on_customer_id"
    t.index ["relationship_owner_id"], name: "index_crm_accounts_on_relationship_owner_id"
  end

  create_table "public.customer_credit_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "credit_hold_flag", default: false, null: false
    t.decimal "credit_limit", precision: 10, scale: 2, default: "0.0"
    t.string "currency_code", default: "USD"
    t.bigint "customer_id", null: false
    t.integer "payment_terms_days", default: 30
    t.date "review_date"
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["customer_id"], name: "index_customer_credit_profiles_on_customer_id"
    t.index ["updated_by_id"], name: "index_customer_credit_profiles_on_updated_by_id"
  end

  create_table "public.customer_interactions", force: :cascade do |t|
    t.bigint "actor_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.date "interaction_date", null: false
    t.string "interaction_type", null: false
    t.string "sentiment"
    t.text "summary"
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_customer_interactions_on_actor_id"
    t.index ["customer_id"], name: "index_customer_interactions_on_customer_id"
  end

  create_table "public.customers", force: :cascade do |t|
    t.string "billing_city"
    t.string "billing_country"
    t.string "billing_street"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "segment"
    t.string "tax_id"
    t.datetime "updated_at", null: false
  end

  create_table "public.invoices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency_code", default: "USD"
    t.date "due_date", null: false
    t.date "invoice_date", null: false
    t.decimal "paid_amount", precision: 10, scale: 2, default: "0.0"
    t.bigint "sales_order_id", null: false
    t.string "status", default: "open", null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.index ["sales_order_id", "status"], name: "index_invoices_on_sales_order_id_and_status"
    t.index ["sales_order_id"], name: "index_invoices_on_sales_order_id"
  end

  create_table "public.order_credit_hold_events", force: :cascade do |t|
    t.bigint "actor_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "credit_snapshot", default: {}
    t.datetime "event_date", null: false
    t.string "event_type", null: false
    t.text "override_reason"
    t.bigint "sales_order_id", null: false
    t.bigint "triggered_by_rule_id"
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_order_credit_hold_events_on_actor_id"
    t.index ["sales_order_id"], name: "index_order_credit_hold_events_on_sales_order_id"
    t.index ["triggered_by_rule_id"], name: "index_order_credit_hold_events_on_triggered_by_rule_id"
  end

  create_table "public.products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency_code"
    t.string "name"
    t.string "sku"
    t.decimal "unit_price"
    t.datetime "updated_at", null: false
  end

  create_table "public.sales_order_lines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.bigint "sales_order_id", null: false
    t.decimal "unit_price"
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_sales_order_lines_on_product_id"
    t.index ["sales_order_id"], name: "index_sales_order_lines_on_sales_order_id"
  end

  create_table "public.sales_orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency_code", default: "USD"
    t.bigint "customer_id", null: false
    t.date "order_date", null: false
    t.string "status", default: "draft", null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "status"], name: "index_sales_orders_on_customer_id_and_status"
    t.index ["customer_id"], name: "index_sales_orders_on_customer_id"
  end

  create_table "public.users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "role"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "public.crm_accounts", "public.customers"
  add_foreign_key "public.crm_accounts", "public.users", column: "relationship_owner_id"
  add_foreign_key "public.customer_credit_profiles", "public.customers"
  add_foreign_key "public.customer_credit_profiles", "public.users", column: "updated_by_id"
  add_foreign_key "public.customer_interactions", "public.customers"
  add_foreign_key "public.customer_interactions", "public.users", column: "actor_id"
  add_foreign_key "public.invoices", "public.sales_orders"
  add_foreign_key "public.order_credit_hold_events", "public.credit_hold_rules", column: "triggered_by_rule_id"
  add_foreign_key "public.order_credit_hold_events", "public.sales_orders"
  add_foreign_key "public.order_credit_hold_events", "public.users", column: "actor_id"
  add_foreign_key "public.sales_order_lines", "public.products"
  add_foreign_key "public.sales_order_lines", "public.sales_orders"
  add_foreign_key "public.sales_orders", "public.customers"

end
