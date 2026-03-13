# Sortly — Product Knowledge

## Overview

**App name:** Sortly (working title; alt: "Swipe Clean")
**Platform:** iOS + Android (Flutter)
**One-liner:** Tinder for your camera roll — swipe to delete, keep, or favorite, until your gallery is clean.
**Tone:** Satisfying, not stressful. Feels like a game you want to open daily, not a chore.

---

## Core interaction — the swipe card

The entire app revolves around one screen: a full-screen photo card stack.

| Gesture | Action | Color | Icon |
|---|---|---|---|
| Swipe left | Delete | Red `#E53935` | Trash |
| Swipe right | Keep | Green `#43A047` | Checkmark |
| Swipe up | Favorite | Amber/gold `#FFB300` | Star |

### Card physics (critical)
- Card rotates slightly as it drags (tilt follows drag direction)
- Colored overlay + action label appears as directional intent becomes clear
- Snaps back to center if released in the neutral zone
- Feels physical — this is the most important UX element in the app
- 2–3 cards visible underneath (subtle stack depth effect)

### Tap buttons
Three tap buttons below the card mirror the three swipe gestures — for users who prefer tapping over swiping.

---

## Screens (priority order)

### 1. Swipe screen
The main loop. Everything else is secondary.
- Full-screen photo card stack
- Action indicator overlays (label + tint) that appear during drag
- Session progress bar — thin, at very top (e.g. "12 / 30 today")
- Swipe count label ("12 of 30 today")
- Undo button — always accessible
- Three tap-action buttons below the card

### 2. Session complete screen
Triggered when daily swipe goal is hit or all photos are sorted.
- Satisfying, celebratory animation
- Storage freed: "You freed 340 MB" — primary metric
- Stats: photos deleted vs kept
- Streak count
- Share button
- "Keep going" option (extend session)

### 3. Onboarding (3 steps)
1. **Gallery scan** — live progress bar while scanning, hook stat: "847 photos to review, 2.1 GB to free"
2. **Preference pills** — "What matters to you?" (e.g., clear space, organize, find duplicates)
3. **Interactive swipe tutorial** — sample cards, teaches the three gestures

### 4. Home / Dashboard
- Streak counter (flame icon + number) — prominent
- Total storage freed (always in MB/GB)
- Quick-start button
- "AI found 40 new photos" nudge card (re-engagement)

### 5. Paywall / Pro screen
- Free vs Pro feature comparison
- Clean, minimal layout
- Price + primary CTA button

### 6. Settings
- Session length preference (how many swipes per day)
- Notifications toggle
- Trash bin access (view photos staged for deletion)
- Privacy note: "Photos never leave your device"

---

## Visual style

### Theme
**Dark-first.** Background `#0F0F0F` (near-black / deep charcoal) so photos pop as the hero. Minimal chrome — almost nothing competes with the photo.

### Color palette
| Purpose | Color | Hex |
|---|---|---|
| Background | Near-black | `#0F0F0F` |
| Delete action | Red | `#E53935` |
| Keep action | Green | `#43A047` |
| Favorite action | Amber/gold | `#FFB300` |

### Typography
Clean sans-serif. SF Pro feel on iOS. No decorative fonts.

### Cards
- Rounded corners
- Subtle drop shadow
- Stack depth: 2–3 cards visible under the active card

### Micro-animations
Non-negotiable. The experience lives or dies on how the swipe feels. Invest heavily in:
- Card drag physics (rotation, tilt, spring snap-back)
- Overlay fade-in on directional intent
- Session complete celebration
- Streak milestone animations

---

## Key UI patterns

### Session progress bar
- Thin bar at very top of screen
- Shows today's swipe progress (e.g. 12/30)
- Not intrusive — almost flush with status bar

### Streak indicator
- Flame icon + number
- Prominent on home screen
- Primary retention mechanic

### Storage freed
- Always displayed in MB or GB
- Primary satisfaction metric — show it everywhere it makes sense

### Group swipe mode
- Occasional variation: 2×3 grid of similar photos (duplicates, bursts)
- "Pick the best one" — one tap eliminates the rest
- Keeps the session fresh

### Undo toast
- Appears 5 seconds after each swipe
- Single tap to undo last action
- Auto-dismisses after 5 seconds

---

## Business model

**Free tier:** Core swipe functionality, limited daily swipes
**Pro tier:** Unlimited swipes, AI-assisted grouping, advanced stats, custom session goals

---

## Privacy constraints (hard rules)

- Photos never leave the device — no server upload, no cloud analysis
- Deletion stages to OS trash (recoverable for ~30 days on iOS) — not immediate permanent deletion
- This must be communicated clearly in Settings and onboarding

---

## Primary metrics / success signals

1. **Storage freed** (MB/GB) — shown constantly, the core "win" feeling
2. **Daily streak** — retention mechanic
3. **Photos sorted per session** — engagement depth
4. **Pro conversion rate** — revenue

---

## Competitive context

Positioned as the "Tinder for camera roll" — the swipe mechanic is the differentiator. Other gallery cleaners feel like chores (file managers, bulk selectors). Sortly should feel like a game.
