# Disc Engine

You're a DJ playing shows against the crowd. Hold a hand of CDs, play them one slot at a time, and chain them so the **flow** builds. Each song's score has to beat that slot's target score to win the crowd over.

**Prototype:** run `nine_pocket.tscn` (F6). Venues, points, flow, targets, abilities, gear and editions are in `nine_pocket_data.gd`. Rules are in `nine_pocket.gd`: show flow in `_start_show` / `_on_pocket` / `_play` / `_finish_song` / `_confirm_dig` / `_fire` / `_end_show`, scoring in `_react` and `_links`, call-outs in `_new_call`. Shared drawing helpers are in `nine_pocket_ui.gd`. Earlier versions are in git history.

Loop: **tour map** → pick a stop → show (then pay) or record shop → back to the map, until the headliner. Getting booed off ends the tour.

## Tour map
Modeled on Wildfrost: gig → a couple of rewards → gig. You start on the map (titled "Tour Map", with a legend using the real pin symbols), a worn road atlas spread on the desk (fold creases, lake and river, state lines, coffee ring, tape). Generated fresh each run in `_make_tour`:
- **Columns:** Hometown → Gig → Reward → Reward → Gig → Reward → Reward → Gig → Reward → Reward → **Headliner**. Every route plays **3 gigs plus the headliner**.
- **Gig columns** have 1–2 venues (red pins) so you can choose a crowd. Each tag shows the town, venue name and its liked (green ring) and hated (red ring) tags.
- **Reward columns** have 2–3 stops. Each pair of reward columns has exactly one **record shop**; the other stops are **pickups** (60%, cardboard box pin) or **cash** (tip jar, $ pin).
- Highways connect each stop to the nearest stop in the next column, with a 35% chance of a second road, so routes branch and cross.
- Reachable stops pulse; click to travel. Your route is drawn in red marker; HERE marks your current stop. A sticky note shows cash and gigs played (of 4). *View binder* works on the map (button or B).
- Target scores grow with gigs played; the headliner's are ×1.25 on top. Finishing the headliner: **Tour complete!** Booed off anywhere: the tour ends. Both offer *New tour*.

## Pickups and cash
Black screen, a spotlight from above, and the reward on a pool of light.
- **Pickup:** a taped cardboard box marked FRAGILE. **Click it three times** to open it (it shakes, the lid lifts and the tape tears; three dots track progress). Inside is a random album (any points, may have an ability or edition) or, 30% of the time when you have an empty rack bay, a gear unit. *Add to binder* / *Install in rack*, or *Leave it*.
- **Cash:** a tip jar full of bills. Click once to collect $4–8.

## Scoring
**Score = points × flow.** That's the whole formula.

- **Points:** every album has a number (green token, 2–6). Added on top:
  - liked tag +2, hated tag −2 (the venue's likes and hates),
  - a matching request +4,
  - abilities, editions and gear.
- **Flow (×1 to ×4):** play an album that shares a **genre or decade** with the previous one and flow goes up by 1. Anything else resets it to ×1. Some gear and requests give flow instead of points.
- If points are negative, flow doesn't multiply them.

**Target score:** each of the 5 changer slots has one: **3 · 5 · 7 · 9 · 11** at the first show, growing 15% each show after (show 5 is 5 · 8 · 11 · 14 · 18). After a song, the crowd meter moves by **score − target score**.

**Crowd meter (0–100):** starts at 50. At 0 you're booed off. At the end, 80+ is an **Encore**, 50+ is **Big applause**, and below that is polite clapping.

## The show
- Your binder is shuffled at the start of each show. You hold a **hand of 8** in the CD wallet (4×2).
- The changer's 5 slots are played in order. Only the open slot takes a CD:
  - Click a CD in your hand to load it (clicking another swaps them). Click the loaded CD to send it back, until you press **PLAY**.
  - Slots show only their target score. There's no exact preview, but CDs in your hand that would raise flow carry a blue **FLOW +1** tag.
  - PLAY: the points float up one by one, then the flow, then the score against the target. The slot locks showing "18 vs 14 · +4", and the next slot opens.
- After each song you **draw 1** from your binder.
- **Discard** (2 per show): swap 1–3 CDs in your hand for new ones. Costs 3 crowd each time.
- The show ends after slot 5, or when the crowd hits 0.
- After a song, 55% of the time (when no call is active) the crowd shouts:
  - **Request** ("Play some 90s!"): +4 points, or 30% of the time +1 flow, if one of the next 2 songs matches.
  - **Complaint** ("No more Metal!"): −3 points for each matching song in the next 3.
- The clipboard holds a taped note with the venue's likes and hates, and the yellow slip with the current call.
- **Console strip** (bottom, brushed metal like the rack units): *View binder* button, Discard section (two amber lights for discards left, *Discard and draw* button), and **Sort** as five amp-style toggle switches (Genre, Decade, Points, Ability, Band). Only one is on at a time; its jewel lamp lights and the lever flips up. Flip it again to turn sorting off.

## Starting binder
12 discs, and nothing in the rack:
- **10 basic albums:** 2–3 points each, no abilities or editions, drawn from 3 random genres (mostly 3 random decades), so short flow chains happen but aren't guaranteed. The venue may like genres you don't own yet.
- **2 blank CD-Rs** ("MIX"): 1 point, no genre or decade of their own. A CD-R counts as the genre and decade of the song before it, so it **always keeps the flow going**, and the song after it links to that same song. Played first, anything links after it. Never liked, hated, requested or boosted by EQ.

Better albums, abilities, editions and all gear come from the shop.

## Abilities, editions
**Abilities** (40% of albums): Opener (+3 points in slot 1), Closer (+3 in slot 5), Crowd-Pleaser (+2), Bandmates (+3 if the band already played tonight), Segue (always keeps the flow going).

**Editions** (8% of albums): Holographic +2 points, Signed +3, Limited Edition doubles the song's points, Remaster triggers its ability twice, Mint Condition +$1 per play.

## Rack
All 4 bays start empty; every unit is bought in the shop.
- **Points:** Graphic EQ adds each genre's fader (−1 to +3); Gain Stage +2/+3 for the dial's genre; Exciter +1/+2 for the dial's decade; Tube Preamp +2/+3/+4 for songs without an ability.
- **Flow:** Crossfader (a break drops flow by 1 instead of resetting it); Compressor (same record label also keeps the flow).
- **Triggered** (button on the unit, 2 uses per show): Fog Machine, fired before a song, gives +1 flow (MK II +2). Make Some Noise, fired between songs, gives +8 crowd (MK II +12).

## Pay and the shop
After each show: booed $2, polite clapping $5, Big applause $8, Encore $11, plus Mint Condition money.

**The B-Side** (a record shop stop in each reward stretch), restocked at random each visit. *Back on the road* returns to the map:
- **Record bin:** 2 albums in jewel cases ($3–5) plus an album pack (Sampler: pick 1 of 3 for $4, or Box Set: pick 2 of 4 for $7).
- **Gear wall:** 2 units you don't own plus a gear box (Grab Box: pick 1 of 3 for $6, or Studio Bundle: pick 2 of 3 for $11).
- **Work orders** (sometimes): bench tweak ($3), upgrade a unit ($6), or give an album an edition.
- *View binder* works in the shop too.

## View binder
The binder's pages (discs tagged IN HAND / IN CHANGER / PLAYED / DUG during a show) sit next to a tag count panel: one tile per genre, decade, ability, CD-R and edition. During a show the big number is how many are still left in your binder to draw (worth discarding for?) and the small one is how many you own. In the shop it's just the total.

## Screen
Changer (5 slots, each with its target score) top left, with a TARGET readout and PLAY on its panel. Your hand in the CD wallet is below it, with the console strip underneath. The venue clipboard is in the middle and the rack on the right, topped by a display showing CROWD, FLOW and TARGET, the crowd meter, the flow lamps (×1–×4) and the NEXT LINK tags (the last song's genre and decade, plus its label with a Compressor).

## Balance
500 simulated first shows with the starting binder: a greedy bot (plays the best-scoring CD, discards losing ones when nothing beats the target) vs. random play.

| Venue | Bot median crowd | Bot applause / encore | Random median |
|---|---|---|---|
| Basement Show | 59 | 68% / 16% | 38 |
| Biker Bar | 60 | 70% / 12% | 35 |
| Coffeehouse | 55 | 58% / 11% | 33 |
| Festival Tent | 61 | 61% / 24% | 36 |
| Record Store Day | 54 | 54% / 10% | 34 |
| Wedding Reception | 50 | 52% / 5% | 35 |

Random play isn't booed off at the first show; that pressure is meant to come from rising targets over later shows. Later shows aren't simulated yet (it needs a shopping bot). Tuning knobs: `SLOT_TARGETS`, `TARGET_GROWTH`, `BASIC_POINTS`, `START_BASIC`, `START_CDRS`, `CDR_POINTS`, `LIKE`/`DISLIKE`, `REQUEST`, `FLOW_MAX`, `ENERGY_START`, `DIG_COST`.

## Music

Pressing PLAY starts the album's track from the beginning and lets it run 5 seconds, fading over the last 0.8. The song only finishes, and the next one can be played, once both the score readout and the 5 seconds are done. Tracks live in `music/<Genre>/<Band>/` and are matched to albums by the file name starting with "Band - Album". A blank CD-R plays a random track from a genre in your hand. Length is `MUSIC_SECONDS` in the data file.

## Ring demo

`ring_demo.tscn` is a separate prototype scene; the main round is untouched. Open it in the editor and run the scene (F6). It shows a 7×6 genre × decade LED map beside a 5-slot ring changer. Click a CD in the hand to play it into the next slot. The map numbers the set's path, glows the last CD's row and column (they keep the flow) and the opener's row and column, and marks cells that would close the ring. Closing the ring (the last CD shares a genre or decade with the opener) adds +1 flow and lifts the cap to ×5. Label maker mode cycles a CD's opener/closer tags. Deal 3×3 uses a starter-style patch of the map; Deal wide spreads the hand over the whole map.

## Art
Drawn in code in a physical style. Optional textures in `art/textures/`: `metal_brushed`, `metal_dark`, `rubber`, `leather`, `fabric`, `wood`, `crate_wood`, `pegboard`, `cardboard`.

## Next
Shop services Burn (copy an album to a CD-R) and Trade in; crowd mood zones; more stop types (rest stop, radio station); more flow gear and call-out types.
