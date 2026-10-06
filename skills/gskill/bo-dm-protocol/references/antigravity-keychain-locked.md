# Antigravity keychain locked (maclab)

## Dialog (Thai)
- Title: **ไม่พบพวงกุญแจ**
- Body: **พวงกุญแจหาไม่พบเพื่อจัดเก็บ “antigravity”**
- Buttons: ยกเลิก · **รีเซ็ตเป็นค่าเริ่มต้น** (Bo-only — agent must not click reset without order)

## Root
- File `~/Library/Keychains/antigravity.keychain-db` may **exist** but be **locked** (unknown passphrase).
- `security show-keychain-info` / unlock with empty pass → fail (“User canceled” / bad passphrase).
- Still listed in `security list-keychains -d user` → apps try it and surface the dialog.

## Not the same as No.6 / No.8 dead
- Seats can stay ACTIVE with file oauth:  
  `~/.no6-home/.gemini/antigravity-cli/antigravity-oauth-token`  
  `~/.no8-home/.gemini/antigravity-cli/antigravity-oauth-token`
- `login.keychain-db` often already holds:
  - service `gemini` / account `antigravity`
  - `Antigravity IDE Safe Storage`

## Fix without Bo password (preferred first)
1. Backup: `security list-keychains -d user > /tmp/keychain-search-before.txt`
2. `security list-keychains -d user -s "$HOME/Library/Keychains/login.keychain-db"`
3. `security default-keychain -d user -s "$HOME/Library/Keychains/login.keychain-db"`
4. `mv antigravity.keychain-db antigravity.keychain-db.BROKEN-<ts>`
5. Verify `security find-generic-password -s gemini -a antigravity` still on login.
6. Tell Bo: if IDE still prompts after restart → one-shot **รีเซ็ตเป็นค่าเริ่มต้น** is their click; do not thrash tokens.

## Do not
- Paste keychain passwords into Discord.
- Equate keychain dialog with fleet agent brain death.
- Delete login.keychain items blindly.
