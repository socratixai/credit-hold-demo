# Tech Stack

## Frontend

Ruby on Rails (server-rendered views via ERB/Hotwire), leveraging fluentui webcomponents from Microsoft

## Backend

Ruby on Rails

## Database

Supabase (PostgreSQL)

- Chosen specifically to enable MCP connectivity with Claude
- Claude can query and analyze data directly via the Supabase MCP server
- Enables the core demo: AI-powered analysis without custom ERP integrations

## AI Integration

- **Claude** (via Anthropic API or Claude Code) connected to Supabase via MCP
- Future: custom MCP server to expose safe, audited write actions (e.g., order release) — keeping destructive operations controlled rather than allowing direct DB writes

## Hosting

To be determined.
