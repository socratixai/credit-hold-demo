# Product Roadmap

## Phase 1: MVP

Mirror the customer's current-state process flow to demonstrate the contrast between traditional and AI-assisted approaches.

### 1. Credit Hold Trigger System
- Finance team can configure credit hold rules at the customer master level
- Primary triggers: credit limit exceeded, or a threshold number of overdue unpaid invoices
- Thresholds are configurable per customer

### 2. Order Review Queue
- When new orders arrive for customers on credit hold, they appear in a review queue
- Users can see all pending orders awaiting approval or rejection

### 3. Customer Signal Screens
- Multiple detail screens per customer: order history, invoice aging, payment history, and other relevant signals
- Each screen supports CSV export (to mirror the current manual Excel aggregation workflow)

### 4. Order Approval / Release
- Ability to approve (release) or reject an order directly within the ERP application
- Demonstrates the end-to-end decision workflow

### 5. AI Agent Integration (via Supabase MCP)
- Claude connects to Supabase via MCP to query all customer data directly
- Demonstrates instant data aggregation and analysis that would otherwise require manual Excel work

## Phase 2: Post-Launch

To be determined.

> Potential direction: a custom MCP server that exposes safe, audited write actions (e.g., order release) so Claude can trigger ERP actions without direct database writes.
