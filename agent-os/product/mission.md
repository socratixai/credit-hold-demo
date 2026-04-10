# Product Mission

## Problem

Managing credit holds in a traditional ERP is slow and manual. When a customer is placed on credit hold, new orders must be reviewed against multiple signals — payment history, order history, outstanding invoices — by navigating across many separate ERP screens, exporting data to Excel, aggregating it manually, and then making a judgment call. This process is time-consuming and error-prone.

## Target Users

Finance executives and business stakeholders evaluating a modern approach to credit hold management. This is a sales/pitch demo showcasing what's possible.

## Solution

A mock ERP application that demonstrates two contrasting experiences side by side:

1. **Traditional flow** — the manual, multi-screen ERP workflow for reviewing credit holds and approving orders.
2. **AI-powered flow** — Claude (or any AI with MCP) connects directly to the Supabase database and performs in seconds what normally takes hours: querying customer signals, aggregating data, and surfacing a recommendation.

The key differentiator is that AI operates *outside* the ERP via MCP connections to the database layer — no custom integrations required — making it immediately applicable to real-world ERP environments.
