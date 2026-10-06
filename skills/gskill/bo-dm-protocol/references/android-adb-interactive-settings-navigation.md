# Android ADB Interactive Settings & Navigation Control

## Context & Rule (Bo 2026-09-15)
When the user (Bo) connects an Android device (e.g. vivo X Fold 3 `V2303A`, OPPO Find N3) and asks the agent to open a specific Settings subpage or assist with navigation so the user can interact directly on the phone ("เปิดตัวตั้งค่าให้หน่อยดิ...เดี๋ยวกูกดเอง"):

## Critical Disciplines
1. **Single Launch, No Activity Spamming**:
   - Do NOT execute rapid successive `am start` and `am force-stop` calls across multiple candidate activities in a single turn.
   - Rapid restarts cause screen flickering, UI lag, and focus stealing while the user is actively touching or reading the screen.
2. **Launch & Yield**:
   - Find the target intent/activity (e.g. `com.android.settings/.Settings$NavigationModeSettingsActivity`, `Settings$SystemDashboardActivity`, or the top-level `android.settings.SETTINGS`).
   - Launch the intent once with `am start -n <component>` or `am start -a <action>`.
   - Verify top window via `dumpsys window | grep mCurrentFocus`.
   - Report clearly what page was opened and yield immediate control to the user.
3. **Immediate Cease on "หยุดก่อน" / Interruption**:
   - If the user says "หยุดก่อน" (Stop/Hold), immediately halt all ADB UI automation, touch injection, or activity switching.
   - Acknowledge politely and wait for explicit guidance.
