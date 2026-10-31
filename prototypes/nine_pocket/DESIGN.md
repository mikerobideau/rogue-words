# Disc Engine

You're a DJ playing shows against the crowd. Hold a hand of CDs, play them one slot at a time, and chain them so the **flow** builds. Each song's score has to beat that slot's target score to win the crowd over.

**Prototype:** run `nine_pocket.tscn` (F6). Venues, points, flow, targets, abilities, gear and editions are in `nine_pocket_data.gd`. Rules are in `nine_pocket.gd`: show flow in `_start_show` / `_on_pocket` / `_play` / `_finish_song` / `_confirm_dig` / `_fire` / `_end_show`, scoring in `_react` and `_links`, call-outs in `_new_call`. Shared drawing helpers are in `nine_pocket_ui.gd`. Earlier versions are in git history.

Loop: **tour map** → pick a stop → show (then pay) or record shop → back to the map, until the headliner. Getting booed off ends the tour.

## Tour map
Modeled on Wildfrost: gig → a couple of rewards → gig. You start on the map (titled "Tour Map", with a legend using the real pin symbols), a worn road atlas spread on the desk (fold creases, lake and river, state lines, coffee ring, tape). Generated fresh each run in `_make_tour`:
- **Columns:** **Basement** (your hometown and the only start; click it to open it) → Gig → Reward → Reward → Gig → Reward → Reward → Gig → Reward → Reward → **Headliner**. Every route plays **3 gigs plus the headliner**.
- **Gig columns** have 1–2 venues (red pins) so you can choose a crowd. On the map a gig shows its name, town and a **hint**: one liked tag (green, "+ Punk") and one hated tag (red, "- Blues"); the rest stay hidden until you hover.
- **Reward columns** have 2–3 stops, and each pair is built so the build can never stall on luck. One column of the pair holds the **record shop** plus possibly one **cash** stop (50%), with any other stop a **pickup**. The other column is **all pickups**. So every route between two gigs passes at least one pickup (a free CD or gear), and cash can never appear twice in a row. Checked over 3,000 generated tours: 0 routes without a pickup and 0 with back-to-back cash.
- Highways connect each stop to the nearest stop in the next column, with a 35% chance of a second road, so routes branch and cross.
- Reachable stops pulse; click to travel. Your route is drawn in red marker; HERE marks your current stop. A sticky note shows cash and gigs played (of 4). *View binder* works on the map (button or B).
- Target scores grow with gigs played; the headliner's are ×1.25 on top. Finishing the headliner: **Tour complete!** Booed off anywhere: the tour ends. Both offer *New tour*.

Stops show only their icon and a name written in marker beside it (venues and the headliner also get the town in red). Hovering a gig or headliner pops up its card with every like and hate spelled out in full ("LIKES · +3 crowd each" and "HATES · -3 crowd each"), so the cards never cover other stops.

The other stops reveal one thing each, and it is always true: a **pickup** shows either a genre (colored label, name written under it) or a decade on its box, and one of its three choices matches; a **record shop** reads "Has Metal 00s" (an album of that genre and decade is in stock) or "Has Compressor" (that gear is in stock, unless you already own it, in which case it shows the album hint instead).

## Pickups and cash
Black screen, a spotlight from above, and the reward on a pool of light.
- **Pickup:** a taped cardboard box marked FRAGILE. **Click it three times** to open it (it shakes, the lid lifts and the tape tears; three dots track progress). Inside are **three choices, and you take one**: usually three albums of different genres (any points, may have an ability or edition), but when you have an empty rack bay one of the three is a gear unit 30% of the time, and always after two pickups in a row without gear (a pity counter that resets each run). Each choice has its own *Take this CD* / *Install this* button, or *Leave them*. On the map each pickup box carries a **stamp**: either a genre (a colored label with its short code, the full name written under it) or a decade, and **one of the three choices always matches** it, so you can route toward what the next crowd likes.
- **Cash:** a tip jar full of bills. Click once to collect $4–8.

## Scoring
**Score = points × flow.** That's the whole formula.

- **Points:** every album has a number (green token, 2–6). Added on top:
  - a matching request +4,
  - abilities, editions and gear.
- **Flow (×1 to ×4):** play an album that shares a **genre or decade** with the previous one and flow goes up by 1. Anything else resets it to ×1. Some gear and requests give flow instead of points.
- If points are negative, flow doesn't multiply them.
- **The crowd's tastes are flat crowd changes, not points.** Each liked tag a song matches is **+3 crowd** and each hated tag **−3 crowd**, added after the score is compared with the target, so flow never multiplies them. A song matching a liked genre and a liked decade is +6; a hated one is −3. This bounds how much a mismatched venue can hurt you.

**Target score:** each of the 5 changer slots has one: **3 · 5 · 7 · 9 · 11** at the first show, growing 15% each show after (show 5 is 5 · 8 · 11 · 14 · 18). After a song, the crowd meter moves by **score − target score**.

**Crowd meter (0–100):** starts at 50. At 0 you're booed off. At the end, 80+ is an **Encore**, 50+ is **Big applause**, and below that is polite clapping.

## The show
- Your binder is shuffled at the start of each show. You hold a **hand of 8** in the CD wallet (4×2).
- The changer's 5 slots are played in order. Only the open slot takes a CD:
  - Click a CD in your hand to load it (clicking another swaps them). Click the loaded CD to send it back, until you press **PLAY**.
  - Slots show only their target score. There's no exact preview, but CDs in your hand that would keep the flow glow cyan and ones that would break it look debuffed (see Card tags).
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
14 discs and an empty rack, then the Basement adds 3 more CDs and one piece of gear before your first gig:
- **12 basic albums**, balanced on purpose so no venue can punish the opening hand. Exactly **2 per decade**, and genres within one of each other (five genres twice, two genres once, never a missing genre). Chosen at random within that rule, so runs still differ. 2–3 points each, no abilities or editions.
- **2 blank CD-Rs** ("MIX"): 1 point. When played, a Mix picks a random album from the whole catalog and becomes that album's genre and decade for the rest of the show. Its genre and decade plate appears under it like any CD, its music is that album's track, and likes, hates, requests, bans, EQ, Gain and Exciter all apply to it. Whether it keeps the flow is the normal rule against the song before it, so it can break the flow, and the next song links against the Mix's new genre and decade. In your hand it reads "MIX · RANDOM ALBUM" with no flow glow or debuff, since the result is unknown. Mixes go back to blank when you return to the map.
- **The Basement** (the map's first stop and your hometown in one, a small house icon with cellar windows; it appears only at the start of a run, never after a headliner): click the stop on the map, then click the box three times to open it. It holds **3 CDs, each with a different ability and a different genre** (2–6 points before the ability's cost, no editions), then **one random piece of gear** to install. No choice to skip; the rack is empty so it always fits.

Better albums, more abilities, editions and more gear come from pickups and the shop.

## Abilities, editions
**Abilities** (40% of albums, each one of the 13 below chosen evenly): Opener (+3 points in slot 1), Closer (+3 in slot 5), Crowd-Pleaser (+2), Bandmates (+3 if the band already played tonight), Segue (always keeps the flow going).

Set-wide abilities read the whole show, not just the song before:
- **Fan Club** +1 point for each song already played. **Warm-Up** +4 if three or more songs already played. **Genre Run** +2 for each earlier song of the same genre. **Callback** +3 if a song of this decade played earlier but not right before. **Deep Cut** +3 if no earlier song shares its genre (so it always fires as an opener). **Collector** +2 if you still hold another disc of this genre.
- **Hype Man** and **Opening Act** pass their bonus forward: when a later song scores, it checks the discs before it. Hype Man gives the song played right after it +3 if it shares its genre or decade (a Mix played next counts by its resolved genre and decade). Opening Act gives +1 to every later song of its genre; several stack. Remaster doubles either.
- Earlier songs include Mixes for counting (Fan Club, Warm-Up), and a played Mix counts as its resolved genre and decade for the others.

**Editions** (8% of albums): Holographic +2 points, Signed +3, Limited Edition doubles the song's points, Remaster triggers its ability twice, Mint Condition +$1 per play.

## Rack
All 4 bays start empty. Gear comes from the Basement, pickups and the shop.
- **Points:** Graphic EQ adds each genre's fader (−1 to +3); Gain Stage +2/+3 for the dial's genre; Exciter +1/+2 for the dial's decade; Tube Preamp +2/+3/+4 for songs without an ability.
- **Flow:** Crossfader (a break drops flow by 1 instead of resetting it); Compressor (same record label also keeps the flow).
- **Triggered** (button on the unit, 2 uses per show): Fog Machine, fired before a song, gives +1 flow (MK II +2). Make Some Noise, fired between songs, gives +8 crowd (MK II +12).

## Pay and the shop
After each show: booed $2, polite clapping $5, Big applause $8, Encore $11, plus Mint Condition money.

**The B-Side** (a record shop stop in each reward stretch), restocked at random each visit. *Back on the road* returns to the map:
- **Record bin:** 2 albums in jewel cases ($3–5), one of them matching the map's hint if it was an album hint, plus an album pack (Sampler: pick 1 of 3 for $4, or Box Set: pick 2 of 4 for $7).
- **Gear wall:** 2 units you don't own (one is the hinted unit if the map's hint was gear and you don't own it yet) plus a gear box (Grab Box: pick 1 of 3 for $6, or Studio Bundle: pick 2 of 3 for $11).
- **Work orders** (sometimes): bench tweak ($3), upgrade a unit ($6), or give an album an edition.
- *View binder* works in the shop too.

## View binder
The binder's pages (discs tagged IN HAND / IN CHANGER / PLAYED / DUG during a show) sit next to a tag count panel: one tile per genre, decade, ability, CD-R and edition. During a show the big number is how many are still left in your binder to draw (worth discarding for?) and the small one is how many you own. In the shop it's just the total.

## Screen
Changer (5 slots, each with its target score) top left, with a TARGET readout and PLAY on its panel. Your hand in the CD wallet is below it, with the console strip underneath. The venue clipboard is in the middle and the rack on the right, topped by a display showing CROWD, FLOW and TARGET, the crowd meter, the flow lamps (×1–×4) and the NEXT LINK tags (the last song's genre and decade, plus its label with a Compressor).

## Balance
**Out of date.** These numbers were measured on an older starting binder (three genres, no abilities) and the earlier scoring, before the balanced binder, the Basement, flat crowd tastes, Mixes that resolve to a real genre and decade, and the new abilities. Re-run the sim before trusting them. Originally, 500 simulated first shows with the starting binder: a greedy bot (plays the best-scoring CD, discards losing ones when nothing beats the target) vs. random play.

| Venue | Bot median crowd | Bot applause / encore | Random median |
|---|---|---|---|
| Basement Show | 59 | 68% / 16% | 38 |
| Biker Bar | 60 | 70% / 12% | 35 |
| Coffeehouse | 55 | 58% / 11% | 33 |
| Festival Tent | 61 | 61% / 24% | 36 |
| Record Store Day | 54 | 54% / 10% | 34 |
| Wedding Reception | 50 | 52% / 5% | 35 |

Random play isn't booed off at the first show; that pressure is meant to come from rising targets over later shows. Later shows aren't simulated yet (it needs a shopping bot). Tuning knobs: `SLOT_TARGETS`, `TARGET_GROWTH`, `BASIC_POINTS`, `START_BASIC`, `START_CDRS`, `CDR_POINTS`, `LIKE`/`DISLIKE` (flat crowd), `REQUEST`, `FLOW_MAX`, `ENERGY_START`, `DIG_COST`, `BASEMENT_CARDS`, `PICKUP_CHOICES`, `PICKUP_GEAR_CHANCE`, `PICKUP_GEAR_PITY`, `CASH_CHANCE`, `MUSIC_SECONDS`.

## Music

Pressing PLAY starts the album's track from a random point (at least a second before the end) and lets it run 5 seconds, fading over the last 0.8. The song only finishes, and the next one can be played, once both the score readout and the 5 seconds are done. Tracks live in `music/<Genre>/<Band>/` and are matched to albums by the file name starting with "Band - Album". A Mix plays the track of the random album it picked. Length is `MUSIC_SECONDS` in the data file.

## Ring demo

`ring_demo.tscn` is a separate prototype scene; the main round is untouched. Open it in the editor and run the scene (F6). It shows a 7×6 genre × decade LED map beside a 5-slot ring changer. Click a CD in the hand to play it into the next slot. The map numbers the set's path, glows the last CD's row and column (they keep the flow) and the opener's row and column, and marks cells that would close the ring. Closing the ring (the last CD shares a genre or decade with the opener) adds +1 flow and lifts the cap to ×5. Label maker mode cycles a CD's opener/closer tags. Deal 3×3 uses a starter-style patch of the map; Deal wide spreads the hand over the whole map.

## Card tags

Each kind of information has one visual channel, and nothing else uses it.

- **Genre** is the color of the plate under the disc, with the genre written on the left of the plate (the short code when the full name does not fit).
- **Decade** is the large numeral on that plate. A venue like or hate, or a gear boost, on the genre rings the plate. One on the decade underlines the numeral.
- **Band** is written in black marker on a curved strip of masking tape across the top of the CD, so it reads on any cover. Each disc gets a slight tilt. Long names shrink to fit. Blank CD-Rs have none.
- **Ability** is one icon in the disc's bottom-right corner (opener and closer are play-from-start and play-to-end, crowd is a small group, bandmates is a guitar pick, segue is linked rings). The wording shows on hover. The points badge stays top-left and the edition badge top-right.
- **Situation** is a single state per hand card, drawn only during a show after the first song: a cyan glow when it keeps the flow, debuffed when it breaks the flow, nothing otherwise. A debuffed CD has washed-out art, a red edge, a red down-arrow badge in its bottom-left corner and a dimmed plate. Hovering it clears the wash and keeps the badge, and the tooltip says it breaks (or keeps) the flow. Unplayed Mixes show no state, since their genre and decade are unknown. If a closes-the-ring state is ever added it goes first in the priority order, ahead of keeps and breaks.

The old FLOW +1 tag and the ability name and bonus pills on the disc are gone.

## Art
Drawn in code in a physical style. Optional textures in `art/textures/`: `metal_brushed`, `metal_dark`, `rubber`, `leather`, `fabric`, `wood`, `crate_wood`, `pegboard`, `cardboard`.

## Next
Shop services Burn (copy an album to a CD-R), Trade in and a Label Maker (change a CD's genre or decade); crowd mood zones; crowd fatigue (the crowd tires of a genre played too often, so keeping flow and staying fresh pull against each other); the ring from the demo in the main game (closing the set back to the opener); a marker on the open slot when a Hype Man bonus is waiting; a quiet bias so venue tastes don't land on your biggest genres; more stop types (rest stop, radio station); more flow gear and call-out types.
