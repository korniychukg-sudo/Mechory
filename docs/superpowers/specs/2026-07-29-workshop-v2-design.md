# Gears Inside v2 — "The Workshop" design

Date: 2026-07-29. Approved direction: full v2 ("Полный v2 «Мастерская»").

## Goal

Turn the app from a beautiful reference into a place the user *lives in*: a living
workshop with a real sandbox tool, a spectacular collection reward, and genuinely
practical everyday value. Version stays 1.0 (build 1).

## What ships

### 1. Living Workshop home (Workshop tab rework)

- **BenchSceneView** — a single Canvas + TimelineView hero scene (~260pt tall):
  wooden workbench, pegboard back wall, a window whose sky follows the real
  clock (dawn/day/dusk/night gradients, sun/moon disc, stars at night), an oil
  lamp that glows warm after dark, drifting dust motes. Mounted on the bench, a
  framed panel runs the **Mechanism of the Day live** (its normal `draw` at
  reduced scale, continuous phase).
- **Today at the bench** — three daily goals (open the daily mechanism, finish
  one Bench challenge, play one quiz round). Completing all three the same day
  grants +10 XP bonus and a small celebration. Stored per-day.
- Existing stat strip, continue card and wings shelf stay below; cards get a
  staggered fade/slide entrance and pressed-scale button style.

### 2. Test Bench — gear playground + challenges (new tab "Bench")

- **Pegboard sandbox.** Grid of holes (7 columns, adaptive rows, spacing `h`).
  A fixed **motor gear** spins at ω = 1 (speed slider 0.3–2×, direction toggle).
  The user picks a gear from a palette — Small 8t (r=1h), Medium 12t (r=1.5h),
  Large 16t (r=2h), Grand 24t (r=3h) — and taps a free hole to mount it; tap a
  mounted gear to remove it. 
- **Mesh solver** (`BenchModels.swift`): two gears mesh when
  `|distance − (r1+r2)| ≤ 0.18h`. BFS from the motor assigns each connected
  gear `ω = −ω_parent · t_parent/t_child` and alternating direction. If a gear
  is reachable via two paths with inconsistent ω (mismatch > 1%) the whole
  train **jams**: everything freezes, gears shudder (small angular jitter),
  a red flash + haptic warning, "Jammed!" chip. Jams are logged (fun badge).
  Unconnected gears simply don't spin.
- **Rendering:** one Canvas + TimelineView; per-gear angle = accumulated
  ω · elapsed. Gears reuse the MechKit gear-path generator with the metal
  palette (motor = gold, output = ruby ring marker).
- **12 challenges** (`BenchChallenges.swift`): each pins the motor and one or
  two **output shafts** (special marked holes with a dial). Win condition
  checks the gear mounted on the output hole: target ratio (e.g. ×2 faster,
  exactly ÷3, same speed same direction, reverse, ≥×6 slower, reach a far
  corner, drive two outputs at once, ratio ÷4 using ≤3 gears, etc.), evaluated
  live from the solver. Completion: banner + confetti + XP (+15 each), stored.
  Challenge list screen shows progress; sandbox is always available as "Free
  play".
- Sandbox layout is persisted (placements survive relaunch).

### 3. Model Hall (replaces Progress tab; named "Hall")

- **The wall.** A parametric brass-and-wood pegboard wall (no PNG needed) with
  16 mounting plates in a 2-column grid (3 on iPad-width via adaptive columns).
  Every **mastered** mechanism renders as a **live mini-model** — its real
  `draw` function at small scale, slow continuous phase — on a wooden plinth
  with an engraved name plate. Unmastered slots show a dashed silhouette hook,
  a "?" plate and the wing tint. Tap any plate → its MechanismView.
- Perf: a single TimelineView at 30 fps drives one Canvas per visible cell;
  phases are staggered per cell so the wall shimmers rather than marching in
  sync. (16 small scenes proved fine on sim; if a device struggles the
  minimumInterval throttles further.)
- Below the wall: the existing rank ring card, stats grid, visit calendar and
  badge grid move here unchanged (Progress screen content is absorbed).

### 4. Repair Corner (practical value)

- `RepairContent.swift`: **10 illustrated fix-it guides** tied to mechanisms:
  stuck zipper (graphite/candle wax), zipper that won't stay up (plier squeeze),
  squeaky hinge, sticky pin lock (graphite, never oil), skipping bike chain,
  pendulum clock running fast/slow (bob height), wobbly door handle (grub
  screw), retractable pen that won't click (spring re-seat), tangled blind
  cords (block & tackle logic), watch/music-box overwinding care.
- Each guide: symptom line, "why it happens" (with a link chip to the related
  mechanism), 4–6 numbered fix steps, prevention tips, "call a pro when…" note.
- `RepairView.swift`: list + detail; entry points: a card in Library's Reading
  Nook and a quick card on Workshop home. Reading a guide grants XP (+8, once).

### 5. Navigation rework

Tabs v2: **Workshop · Library · Bench · Hall · More** (wrench glyph for Bench,
medal stays on Hall). The old Learn tab folds into Library as a **Reading
Nook** section at the top: four feature cards — Field Guides, Repair Corner,
Workshop Quiz, Dictionary — each pushing the existing (or new) screens.

### 6. Progression additions

- New badges (total 28): First Contraption (first challenge), Rigger (6
  challenges), Master Rigger (all 12), Beautiful Jam (cause a jam), Handy
  (first repair guide), Fixer of Things (all 10), Good Day (first perfect
  daily-goals day), Golden Week (7 perfect days).
- Store additions (tolerant decoding, same pattern): `challengesDone:
  Set<String>`, `jamsCaused: Int`, `repairsRead: Set<String>`, `perfectDays:
  Set<String>`, `benchLayout: [BenchPlacement]`, `dailyGoalLog: [String:
  Set<String>]`. XP: challenge +15, repair +8, perfect day +10.

### 7. Style pass

- Fix the vertical flip in poster motifs (`gen.swift` renders in CG bottom-up
  coordinates): flip the context for motif drawing, keep text upright.
  Regenerate all posters/banners; add 10 `repair_*.png` covers (motif + tool
  accent) for Repair Corner.
- `.cogAppear(index:)` staggered entrance modifier used on home/hall/bench
  lists; pressed-scale card button style; tab switch cross-fade.

## Architecture

New files: `BenchModels.swift`, `BenchChallenges.swift`, `BenchView.swift`,
`ModelHallView.swift`, `BenchSceneView.swift`, `RepairContent.swift`,
`RepairView.swift` (7). Edited: Root/Workshop/Library/Store/Models/Theme,
`CogProgressView` content reused inside ModelHall, gen.swift + Art regen,
pbxproj (+7 entries). All iOS 15.6-safe (Canvas/TimelineView/NavigationView
only), custom components only, English-only, offline.

## Error handling & edge cases

- Solver: motor removal impossible (fixed); ratio floats compared with 1%
  tolerance; jam never crashes — it just freezes ω at 0 with jitter.
- Bench persistence decodes tolerantly; invalid stored placements (out of
  bounds after grid change) are dropped on load.
- Hall with zero mastered mechanisms shows a friendly "the wall awaits your
  first model" empty state over the same wall art.
- Daily goals reset naturally by date key; timezone changes only affect the
  key, never crash.

## Testing

Compile clean (Debug sim + Release device), code review of solver math
(hand-checked ratio tables), on-sim verification with seeded state: home
scene day/night (env hook forces hour), bench sandbox + one completed
challenge, hall wall with 5 mastered models, repair corner. Screenshots
refreshed (01–08).
