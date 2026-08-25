# Daily Planner (Flutter)

A fully offline daily planner: a task checklist and an hourly time-blocked
schedule, both with local reminder notifications. No login, no backend —
everything is stored on-device via `shared_preferences`.

## Features
- **Date strip** at the top — swipe through days, jump to today, or pick
  any date via the calendar icon
- **Tasks tab** — checklist with optional due time, priority (low/med/high),
  swipe-to-delete with undo
- **Timeline tab** — hourly grid (12 AM–11 PM) with color-coded time blocks
  by category (Work, Personal, Health, Study, Family, Sleep, Other), plus a
  live red line showing the current time when viewing today
- **Reminders** — toggle a reminder on any task (fires at its due time) or
  time block (fires when it starts); uses real scheduled local notifications,
  not just in-app alerts

## Setup

This zip contains only `lib/` and `pubspec.yaml` — no `android/`/`ios/`
folders, since those are meant to be generated locally, not shipped in a
source zip.

1. Unzip, then from inside the `daily_planner` folder, scaffold the
   platform folders around the existing Dart code:
   ```
   flutter create . --project-name daily_planner --org com.yourname
   ```
2. Install dependencies:
   ```
   flutter pub get
   ```
3. **Required for reminders to actually fire** — `flutter_local_notifications`
   needs a few manual native additions that `flutter create` doesn't add for
   you:

   **Android** — in `android/app/src/main/AndroidManifest.xml`, add these
   permissions as direct children of `<manifest>` (above `<application>`):
   ```xml
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
   <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
   <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
   ```
   And inside `<application>`, add these two receivers so reminders survive
   a phone reboot:
   ```xml
   <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
   <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
       <intent-filter>
           <action android:name="android.intent.action.BOOT_COMPLETED"/>
           <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
           <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
       </intent-filter>
   </receiver>
   ```
   Also check `android/app/build.gradle` (or `build.gradle.kts`) has
   `minSdk 21` or higher (Flutter's default template already satisfies this).

   **iOS** — no manifest editing needed; the app requests permission in code
   on first launch. If notifications don't show while the app is in the
   foreground, you may want to add a `UNUserNotificationCenter` delegate in
   `ios/Runner/AppDelegate.swift` per the
   [flutter_local_notifications iOS setup guide](https://pub.dev/packages/flutter_local_notifications) —
   the default setup covers background/terminated-app notifications fine.

4. Run the checks and launch the app:
   ```
   flutter analyze
   flutter test
   flutter run
   ```

   To produce an Android release APK after connecting a device/signing
   configuration, run:
   ```
   flutter build apk --release
   ```

   For an iOS archive, use `flutter build ipa` on macOS with Xcode installed.

## Project structure
```
lib/
  main.dart                              # Entry point; initializes notifications before runApp
  models/
    task.dart                            # Task model (title, date, optional time, priority, reminder)
    time_block.dart                      # TimeBlock model (title, date, start/end, category, reminder)
  services/
    storage_service.dart                 # SharedPreferences persistence
    notification_service.dart            # flutter_local_notifications wrapper, timezone-aware scheduling
    reminder_scheduler.dart              # Translates tasks/blocks into scheduled/cancelled notifications
  screens/
    day_screen.dart                      # Main screen: date strip, Tasks/Timeline tabs, add menu
    add_edit_task_screen.dart            # Add/edit task form
    add_edit_time_block_screen.dart      # Add/edit time block form (with delete)
  widgets/
    date_strip.dart                      # Horizontal scrollable date picker
    task_tile.dart / task_list_view.dart # Checklist rendering
    timeline_view.dart                   # Hourly grid with positioned time blocks
```

## Notes
- Reminder notification IDs are derived deterministically from each item's
  UUID (`hashCode & 0x7FFFFFFF`), so there's no separate ID bookkeeping —
  editing or deleting an item always finds and replaces/cancels the right
  notification. Collision risk is very low in practice for personal use.
- Tapping a fired notification currently just opens the app — it doesn't
  deep-link to that specific day. Wiring that up would mean handling
  `onDidReceiveNotificationResponse` and passing the target date through a
  navigator key; a reasonable next step if you want it.
- No recurring tasks/time blocks yet (e.g. "every weekday at 9am") — each
  one is a one-off tied to a specific date. That's the natural next feature
  if you want this to replace a habit tracker too.
- I couldn't compile-check this in the sandbox I built it in — no Flutter
  toolchain or pub.dev access there. I balance-checked braces/parens across
  every file, but run `flutter analyze` before trusting it fully.
