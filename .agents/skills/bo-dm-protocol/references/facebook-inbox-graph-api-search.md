# Facebook Page Inbox & Past Portfolio Retrieval Protocol

## Overview
When Bo or users ask to locate past clients, quotations, customer inquiries, or portfolio sample links sent via Facebook Page (e.g. Club S):

## 1. Direct Graph API Pagination Pattern
If MCP tools fail or lack deep search capabilities:
- Use Graph API v24.0 endpoint: `https://graph.facebook.com/v24.0/{PAGE_ID}/conversations?fields=id,snippet,updated_time,participants&limit=100&access_token={PAGE_TOKEN}`
- Paginate through cursors (`data.paging.next`) to cover 1,000–2,000+ past conversations without hitting rate limits.

## 2. Inspecting Full Conversation Threads
- Snippets only hold the most recent message. Inquiries (e.g. "บ้าน 3 ชั้น", "Airbnb", "3,500") often happen at the start of a conversation.
- Fetch conversation messages: `https://graph.facebook.com/v24.0/{conversation_id}/messages?fields=message,created_time,from,attachments`
- Scan for keywords and extract admin responses (e.g. Google Drive portfolio links `drive.google.com/drive/folders/...` or custom quotes).

## 3. Fast In-Memory Filtering via Python
Fetch paginated batches via Python `urllib.request`, parse JSON, and filter in-memory across sender names, snippets, and message bodies.

## 4. Local Archive Large JSON Search Pitfall (Avoiding Timeout & Stdout Floods)
When querying local offline conversation dumps (e.g. `facebook-mcp-server/data/messages_since_2025-01-19.json` ~40MB, 41,000+ messages across 1,800+ threads):
- **Never run raw shell `grep` on large single-line minified JSON files**: A single matched line dumps the entire 38MB+ payload, causing 180s command timeouts and massive log files.
- **Always use Python JSON script**:
  ```python
  import json
  path = '/Users/admin/Code/github.com/MEYD-605/facebook-mcp-server/data/messages_since_2025-01-19.json'
  with open(path, 'r', encoding='utf-8') as f:
      data = json.load(f)
  for tid, thread in data.get('threads', {}).items():
      for msg in thread.get('messages', []):
          txt = msg.get('message', '')
          if any(k in txt for k in ['กสิกร', 'สุจิตร', '9292223492']):
              print(f"[{msg.get('created_time')}] {thread.get('customer_name')}: {txt}")
  ```

## 5. Bank Account & Payment SSOT Patterns in Inbox
- **Standard Deposit Account**: SCB `929-222-3492` (นาย สุจริต มานิตยกุล / P'Mo) is the primary account sent in all automated/manual booking requests.
- **PromptPay Record**: `0949989486` (สุจิตร / Master Bo) appears in historical refund/adjustment contexts.
- **KBank Verification**: No KBank (กสิกรไทย) account exists under "สุจิตร มานิตยกุล" in the active page inbox history or quotation templates.

