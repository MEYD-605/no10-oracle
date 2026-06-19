---
pattern: Discovering private GitHub organizations of an active session member requires checking authenticated endpoints rather than public endpoints.
date: 2026-06-19
source: rrr: MEYD-605/no10-oracle
concepts: [github-api, github-organizations, research]
---

# GitHub Organization Discovery and Private Membership Scopes

## 1. Public vs. Private organization membership
By default, GitHub hides a user's membership in organizations unless the user chooses to "publicize" it on their profile page. When querying a user's organizations via public APIs:
`GET /users/{username}/orgs`
It will only return publicly publicized organizations (such as local maker clubs).
If the user belongs to private development spaces, corporate structures, or private course networks (such as the Oracle Network organizations), these memberships will be entirely missing from the response.

### Solution: Authenticated Pivot
If you are logged into a GitHub session via an authorized user token (`gh` CLI or dynamic tokens) that shares memberships with the target user, query the authenticated user's organization endpoint:
`GET /user/orgs`
This surfaces all organizations the active session has access to, including private memberships. Through this pivot, we successfully discovered 5 hidden organizations associated with Nat Weerawan (`nazt`) and the Oracle Network:
1. `Soul-Brews-Studio` (Nat's software design studio)
2. `the-oracle-keeps-the-human-human` (Ecosystem and course organization)
3. `sila-build-with-oracle` (Sila/Chiang Mai student/agent organization)
4. `nat-build-with-oracle` (Nat's personal testing sandbox)
5. `Soulbrews-x-Third-Pint` (Collaborative workspace)

---

## 2. Parameter conventions in `gh api`
When using `gh api` to fetch list resources, avoid standard query flags like `--limit` (which are unique to `gh repo` / `gh issue` commands).
Furthermore, do not use form-field parameters (`-F` or `--field`) to specify parameters like limits or page numbers. In the GitHub CLI:
- `-F` / `-f` with key=value converts the request to a `POST` mutation by default if the endpoint supports creation (such as `POST /orgs/{org}/repos` to create a repository).
- To pass GET parameters safely, specify them directly in the URL query string or use the `--paginate` parameter to fetch all pages of results automatically.
Example:
```bash
gh api orgs/the-oracle-keeps-the-human-human/repos --paginate --jq ".[].name"
```
