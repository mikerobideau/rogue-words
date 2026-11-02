# Disc Engine

You're a DJ playing shows against the crowd. Hold a hand of CDs, play them one slot at a time, and chain them so the **flow** builds. Each song's score has to beat that slot's target score to win the crowd over.

**Prototype:** run `nine_pocket.tscn` (F6). Venues, points, flow, targets, gear and editions are in `nine_pocket_data.gd`. Rules are in `nine_pocket.gd`: show flow in `_start_show` / `_on_pocket` / `_play` / `_finish_song` / `_confirm_dig` / `_fire` / `_end_show`, scoring in `_react` and `_links`, call-outs in `_new_call`. Shared drawing helpers are in `nine_pocket_ui.gd`. Earlier versions are in git history.

Loop: **fork in the road** (the old tour map is kept behind a flag) → pick a road → two reward stops and a gig → pay and the record shop → next fork, until the headliner. Getting booed off ends the tour.

## Fork in the road
The map is switched off by `USE_FORK` in the data file (set it false to bring the map and `_make_tour` back; their code is intact). The tour is now six gigs: two forks, a boss, two forks, a boss (see Boss gigs and fatigue). Each fork is followed by its road's three stops. A run starts at the first fork after you pick a kit.

- **A fork** is two road signs side by side on a dusk highway. Click a sign to take that road.
- **A road** has a **theme** (a genre or a decade, e.g. "Blues Road", "80s Road", with a town it heads toward) and three stops in order: two reward stops, then a gig. You must play all three. The two roads in a fork have different themes (usually one genre and one decade).
- **Reward stops** come from `ROAD_COMBOS`: pickup+pickup, pickup+shop, shop+pickup or tip jar+pickup. Every road has at least one pickup, a tip jar is always first (so cash never comes twice in a row), and the two roads in a fork don't share a combo. Pickups are stamped with the road's theme (one option always matches); a shop road guarantees an album from the theme on the shelf, and the sign shows its genre and decade.
- **The gig** is a random venue (the two roads never share one) changed so it **likes the road's theme** and never hates it. The sign shows one liked and one hated tag; hover the gig row for the full likes and hates.
- Gear pity, target growth and pay work as before. Gig number rises with each gig played, so the final boss is gig 6.

## Tour map
Modeled on Wildfrost: gig → a couple of rewards → gig. You start on the map (titled "Tour Map", with a legend using the real pin symbols), a worn road atlas spread on the desk (fold creases, lake and river, state lines, coffee ring, tape). Generated fresh each run in `_make_tour`:
- **Columns:** **Hometown** (the start) → Gig → Reward → Reward → Gig → Reward → Reward → Gig → Reward → Reward → **Headliner**. Every route plays **3 gigs plus the headliner**.
- **Gig columns** have 1–2 venues (red pins) so you can choose a crowd. On the map a gig shows its name, town and a **hint**: one liked tag (green, "+ Punk") and one hated tag (red, "- Blues"); the rest stay hidden until you hover.
- **Reward columns** have 2–3 stops, and each pair is built so the build can never stall on luck. One column of the pair holds the **record shop** plus possibly one **cash** stop (50%), with any other stop a **pickup**. The other column is **all pickups**. So every route between two gigs passes at least one pickup (a free CD or gear), and cash can never appear twice in a row. Checked over 3,000 generated tours: 0 routes without a pickup and 0 with back-to-back cash.
- Highways connect each stop to the nearest stop in the next column, with a 35% chance of a second road, so routes branch and cross.
- Reachable stops pulse; click to travel. Your route is drawn in red marker; HERE marks your current stop. A sticky note shows cash and gigs played (of 4). *View binder* works on the map (button or B).
- Target scores grow with gigs played; the headliner's are ×1.25 on top. Finishing the headliner: **Tour complete!** Booed off anywhere: the tour ends. Both return to the main menu.

Stops show only their icon and a name written in marker beside it (venues and the headliner also get the town in red). Hovering a gig or headliner pops up its card with every like and hate spelled out in full ("LIKES · +3 crowd each" and "HATES · -3 crowd each"), so the cards never cover other stops.

The other stops reveal one thing each, and it is always true: a **pickup** shows either a genre (colored label, name written under it) or a decade on its box, and one of its three choices matches; a **record shop** reads "Has Metal 00s" (an album of that genre and decade is in stock) or "Has Compressor" (that gear is in stock, unless you already own it, in which case it shows the album hint instead).

## Pickups and cash
Black screen, a spotlight from above, and the reward on a pool of light.
- **Pickup:** a taped cardboard box marked FRAGILE. **Click it three times** to open it (it shakes, the lid lifts and the tape tears; three dots track progress). Inside are **three choices, and you take one**: usually three albums of different genres (any points, maybe with an edition), but when you have an empty rack bay one of the three is a gear unit 30% of the time, and always after two pickups in a row without gear (a pity counter that resets each run). Each choice has its own *Take this CD* / *Install this* button, or *Leave them*. On the map each pickup box carries a **stamp**: either a genre (a colored label with its short code, the full name written under it) or a decade, and **one of the three choices always matches** it, so you can route toward what the next crowd likes.
- **Cash:** a tip jar full of bills. Click once to collect $4–8.

## Scoring
One number matters: the **audience score**. It starts at 20 (`ENERGY_START`), you lose at 0, and it is capped at 60.

**Every song's result is one sum: flow + stars + extras - cooling.**
- **Cooling:** after every song the audience cools (`COOLING`: 3, 4, 5, 5, 6, 6 by gig; a boss adds 1 for being a headliner, and the "High expectations" boss another 1).
- **Hit or miss:** every album has **one condition** printed on it. If it holds where you play it, the song is a **hit**: flow goes up by 1 (it starts each show at 0) and the song pays its new flow, plus its stars and any extras. If not, it is a **miss**: it pays nothing and flow resets to 0 (Crossfader halves it instead, Compressor lets the first miss each show keep it). Conditions come in risk tiers:
  - **Safe (0 to 1 star):** **Anywhere** (always hits, 0 stars: a setup card), **Set 1** (tracks 1 to 4), **Set 2** (tracks 5 to 8), **A-side** (odd tracks), **B-side** (even tracks).
  - **Risky (2 to 3 stars):** **Opener** (track 1, 2 stars), **Closer** (track 8, 3 stars), **After a genre or decade** (the song just before it, 2 stars), **Above a genre or decade** (the song above it in the snake, tracks 5 to 8 only, 3 stars).
  - **Very risky (6 stars): Between two tags**, such as "PUNK · ROCK": the song before it must match the first tag and the song after it the second (each a genre or decade, with Pitch Control widening decades). It only works on tracks 2 to 7. It pays nothing on its own turn; when the next song is placed it pays the flow (counted as a hit) plus 6 stars. If the next song doesn't match it counts as a miss one song late and the flow resets. A gold NEEDS tag sits on the disc and on the rack display until it resolves.
  A Mix always hits. Compressor, Crossfader and Pitch Control are described under Rack.
- **Stars (0 to 6):** the only number on an album, set by its condition (see the tiers above). Editions add +1 (Holographic), +2 (Signed) or +3 (Limited) on a hit. A card with 4 or more stars shows one star and a number.
- **Extras, hit or miss:** a venue's liked tag a song matches is **+2**, a hated one **-2**; a matching request is **+4**; a boss's genre or decade debuff is **-2**. Hit-only extras come from gear.
- Nothing in the game tells you what a song will score. Cards in your hand glow cyan when their condition holds in the open slot, and the tooltip says it hits or misses there, but you work out the audience change yourself from flow, stars, gear and the venue.

**Audience score (0-60):** starts at 20. At 0 you're booed off. At the end, 42+ is an **Encore**, 26+ is **Big applause**, and below that is polite clapping.

## The show
- Your binder is shuffled at the start of each show. You hold a **hand of 8** in the CD wallet (two rows of 4) (`HAND`) and it refills from the draw pile after every song.
- The changer has **8 slots in a 2×4 snake** (`SETLIST`): slots 1 to 4 run left to right along the top row, then slots 5 to 8 run right to left along the bottom, so slot 5 sits under 4 and slot 8 sits under slot 1. They are played in order, one at a time. Only the open slot takes a CD:
  - Click a CD in your hand to load it (clicking another swaps them). Click the loaded CD to send it back, until you press **PLAY**.
  - Slots show the cooling (-N) until played, then the audience change. CDs in your hand that would hit glow cyan (ones that would miss look debuffed).
  - PLAY: the lines of the sum float up one by one (condition, flow, stars, extras, cooling), then the audience change. The slot locks showing "+4", and the next slot opens.
- After each song you **draw 1** from your binder.
- **Discard** (3 per show): throw away 1 CD from your hand, then **choose 1 of 3** CDs drawn at random from the draw pile. The other two go back into the pile. The discarded CD goes to a discard pile and can't be offered again until the draw pile runs low (fewer than 3 left), when the discard pile is shuffled back in. Each discard costs 3 crowd, and each offered CD shows whether it would keep or break the flow. If the pile is empty, discarding is unavailable.
- **Draw pile table:** a readout in the console strip shows (a toggle switch beside it flips between *PILE* and *PILE + HAND*, which also adds the CDs in your hand; the card tooltips follow the same setting) how many CDs of each genre and each decade are still in the draw pile (amber digits, genre-colored underline), plus the pile total and the number of Mixes. The genre and decade of the song just played glow cyan, since those are the tags that keep the flow. Hovering a CD in your hand or the changer adds "Left in the draw pile: N of its genre, M of its decade" to its tooltip.
- The show ends after slot 8, or when the audience score hits 0.
- **Reading the slot:** the display on the rack under FLOW says THIS SLOT and lists the open slot's set, side and opener or closer, plus the genre and decade of the song before it (AFTER) and, on tracks 5 to 8, the song above it (ABOVE). Cards in your hand that meet their condition in this slot glow cyan; ones that don't look debuffed. The arrows between discs turn cyan or red for songs that kept or broke the flow, and the link icons between the rows light up for songs whose condition looked at the song above.
- After a song, 55% of the time (when no request is active) the crowd shouts a **request** ("Play some 90s!"): +4 audience score if one of the next 2 songs matches. There are no complaints any more.
- The clipboard holds a taped note with the venue's likes and hates, and the yellow slip with the current call.
- **Console strip** (bottom, brushed metal like the rack units), left to right: a black *View binder* button; a black *Discard* button with three amber lights for discards left (while choosing, it becomes *Discard* and *Cancel*); the **draw pile table** (see Discard); and **Sort** as five amp-style toggle switches (Genre, Decade, Points, Band) whose lights use the same amber. All console buttons share the black style.

## Boss gigs
**Every third gig is a boss** (boss and headliner mean the same thing): gigs 3 and 6, with the fork roads covering the gigs between. Beating gig 6 completes the tour. Bosses use the headliner's venue and ×1.25 targets, and carry one **challenge**, different for each boss in a run. The fork screen warns which challenge the next boss will have, a boss screen spells it out, and the crowd panel keeps a red reminder. The challenges (`BOSS_KINDS`):
- **Genre debuffed / Decade debuffed:** your most common genre (or decade) costs 2 audience score a song all night.
- **Crowd request:** one of slots 2-4 only takes a chosen genre or decade; anything else counts as a miss. A red tag marks the slot and the cards read as debuffed.
- **Angry crowd:** an extra hated genre (one of your common ones) and hates cost double.
- **High expectations:** the audience cools 1 faster every song.
- **Broken equipment:** one piece of rack gear is out for the show (restored afterward).
- **Rough crowd:** each song played has a 20% chance to be destroyed for good (removed from the binder when you leave the show).
- **No time to dig:** one discard instead of three.


## Starting kits
The game opens on a title screen (Play), on a plain black background, whose music comes from one **random album** that has a song (its cover shows only on the spinning disc; the song plays from the middle, loops, and "Now playing" names it). The kit screen keeps the song and is also on plain black. Going back to the title from the kit screen keeps the song; arriving at the title after a run picks a new one. Starting a run fades the music out over 1.5 seconds (`MENU_FADE`). Then a **kit screen** with four cards. Each kit is a 14-CD starting binder plus one piece of gear in the rack, and every kit starts with $0. There is no Basement any more. Picking a kit starts the run at the first fork. Winning or losing returns to the title.
- **Deck:** one album for every genre and decade (7 genres x 6 decades = 42) plus 2 Mixes (CD-Rs), no editions at the start. Conditions are dealt from `COND_DECK`: 5 Anywhere, 2 each of set 1, set 2, A-side, B-side, opener and closer, 7 after-genre, 5 after-decade, 5 above-genre, 5 above-decade and 3 Between, shuffled across the grid each run. Each album borrows a catalog cover and title (preferring one with the same genre and decade) and takes the genre, decade, condition and stars of its slot in the grid.
- **Kits** (`KITS` in the data file):
  - **Flow Crew:** Crossfader.
  - **Showstopper:** Make Some Noise.
  - **Genre Streak:** Gain Stage, dialed to Punk.
  - **Crowd Pleaser:** Tube Preamp.
- **Mixes** (blank CD-Rs, no stars): when played, a Mix always hits, then picks a random album from the whole catalog and becomes that album's genre and decade for the crowd and gear, with the result shown on its label. It resets after each show.
- Tuning knobs: `KITS`, `START_CDRS`. The kits differ only by gear for now.

Better albums, editions and more gear come from pickups and the shop.

## The catalog and conditions
**The catalog** is `album_catalog.gd`: 63 albums, 7 genres x 3 bands x 3 albums. Each album has a catalog genre and decade and a title. The game pairs the new titles with the existing cover art within each genre, in order, keeping the real band names, and the mp3s stay bound to the cover art. The catalog's sticker and payout columns are not used.

**Conditions** for catalog albums are rolled once per album from a seed on its cover using `COND_WEIGHTS` (Anywhere 10, sets and sides 5 each, opener and closer 3 each, after-genre 14, after-decade 12, above-genre 11, above-decade 10, Between 6), so they never change between runs. Generated albums (shop, pickups, packs) roll the same weights fresh. Stars follow `COND_STARS`. Genre and decade parameters are random; a Between card rolls two different tags (60% genre, 40% decade).

**Genre and decade** are one of each per album and drive the crowd, gear, requests and bosses: a venue like pays +3 crowd for a matching genre or decade (hates -5), a request is met by a matching song, Graphic EQ adds the genre's fader, Gain Stage and Exciter pay for their dial's genre or decade, and boss genre and decade debuffs apply to matching songs. Genre has no colour anywhere. Fatigue (three songs in a row of one genre or decade), a boss's slot lock and kit leans use the same genre and decade. A Mix copies a random album's cover, genre and decade when it is played.

**Rules:** an album can be played any number of times in a set. The record shop, pickups and album packs generate albums with a random genre, decade and condition (`_gen_album`, using `COND_WEIGHTS`), borrowing a catalog cover; a road's theme fixes the first album's genre and decade.

**Editions** (8% of albums): Holographic +1 on a hit, Signed +2, Limited Edition +3, Mint Condition +$1 per play.

## Rack
All 4 bays start empty. The kit gives one piece of gear; more comes from pickups and the shop.
- **Hit bonuses:** Graphic EQ adds each genre's fader (-1 to +2) to that genre's hits; Gain Stage +1/+2 for the dial's genre; Exciter +1/+2 for the dial's decade; Tube Preamp +1/+2/+3 for songs with no stars; Echo Unit doubles a hit on the closing song.
- **Flow:** Crossfader (a miss halves the flow instead of resetting it); Compressor (the first miss each show keeps the flow); Pitch Control (decade conditions after/above accept one decade either side).
- **Triggered** (button on the unit, 2 uses per show): Fog Machine, fired before a song, gives +1 flow (MK II +2). Make Some Noise, fired between songs, gives +4 audience score (MK II +6).

## Pay and the shop
After each show: booed $2, polite clapping $5, Big applause $8, Encore $11, plus Mint Condition money.

**The B-Side** (a record shop stop in each reward stretch), restocked at random each visit. *Back on the road* returns to the map:
- **Record bin:** 2 albums in jewel cases ($3–5), one of them matching the map's hint if it was an album hint, plus an album pack (Sampler: pick 1 of 3 for $4, or Box Set: pick 2 of 4 for $7).
- **Gear wall:** 2 units you don't own (one is the hinted unit if the map's hint was gear and you don't own it yet) plus a gear box (Grab Box: pick 1 of 3 for $6, or Studio Bundle: pick 2 of 3 for $11).
- **Work orders** (sometimes): bench tweak ($3), upgrade a unit ($6), or give an album an edition.
- *View binder* works in the shop too.

## View binder
The binder shows only its pages (discs tagged IN HAND / IN CHANGER / PLAYED / DUG during a show), centered, with a Close button at the top right. The tag count panel is gone; the draw pile table in the console strip covers what's left to draw.

## Screen
Changer (8 slots in a 2×4 snake, each showing the cooling or its result) top left, with a COOLING readout and PLAY on its panel. Your hand in the CD wallet is below it, with the console strip underneath. The venue clipboard is in the middle and the rack on the right, topped by a display showing AUDIENCE, FLOW and TARGET, the crowd meter, the flow lamps (×1–×4) and the NEXT LINK tags (the last song's genre and decade, plus its label with a Compressor).

## Balance
The scoring changed to cooling and flow (see Scoring), so the old per-venue table is gone.


Measured over 80 shows per row at a plain venue (no boss extras) with two full-information bots. The "greedy" bot plays the card with the best result now; the "look" bot also looks one song ahead (it can plan a sandwich). Greedy ends at 38 / 30 / 20 / 15 audience score on gigs 1, 2, 4 and 6 (cooling 3 / 4 / 5 / 6), surviving 100% to 85%; the look bot ends 1 to 5 points higher at the harder gigs and picks a different card on about 20% of turns, so planning pays. Random play gets about 2 hits a show and dies by gig 5. The bots don't use gear or the shop. Tuning knobs: `COOLING`, `COOL_HEADLINER`, `COOL_BOSS`, `COND_WEIGHTS`, `COND_DECK`, `COND_STARS`, `ENERGY_START`, `ENERGY_MAX`, `APPLAUSE`, `ENCORE`, `LIKE`, `DISLIKE`, `REQUEST`, `START_CDRS`, `CDR_STARS`, `FLOW_MAX`, `MUSIC_SECONDS`.

## Music

Pressing PLAY starts the album's track from a random point (at least a second before the end) and lets it run 5 seconds, fading over the last 0.8. The song only finishes, and the next one can be played, once both the score readout and the 5 seconds are done. Tracks live in `music/<Genre>/<Band>/` and are matched to albums by the file name starting with "Band - Album". A Mix plays the track of the random album it picked. Length is `MUSIC_SECONDS` in the data file.

## Ring demo

`ring_demo.tscn` is a separate prototype scene; the main round is untouched. Open it in the editor and run the scene (F6). It shows a 7×6 genre × decade LED map beside a 5-slot ring changer. Click a CD in the hand to play it into the next slot. The map numbers the set's path, glows the last CD's row and column (they keep the flow) and the opener's row and column, and marks cells that would close the ring. Closing the ring (the last CD shares a genre or decade with the opener) adds +1 flow and lifts the cap to ×5. Label maker mode cycles a CD's opener/closer tags. Deal 3×3 uses a starter-style patch of the map; Deal wide spreads the hand over the whole map.

## Card tags

Each kind of information has one visual channel, and nothing else uses it.

- **Cover and condition:** the disc is the album's cover art. A strip of masking tape across the top reads "Decade-Genre" (for example "80s-Indie") in black marker; if a venue likes or hates that genre or decade, or a gear unit boosts it, that half of the label turns green, red or gold. A dark pill near the bottom of the disc names its flow condition (SET 1, A-SIDE, CLOSER, AFTER PUNK, ABOVE 90S and so on). Points sit in the green badge at the top left. There are no chips under the disc and genre has no colour. A Mix shows a blank CD-R until it is played, then the cover it became with a MIX pill.
- **Situation** is a single state per hand card, drawn only during a show after the first song: a cyan glow when it keeps the flow (the console's NEXT LINK chips and the draw pile table show the one or two decades that link), debuffed when it breaks the flow, nothing otherwise. A debuffed CD has washed-out art, a red edge, a red down-arrow badge in its bottom-left corner and a dimmed plate. Hovering it clears the wash and keeps the badge, and the tooltip says it breaks (or keeps) the flow. Unplayed Mixes show no state, since their genre and decade are unknown. If a closes-the-ring state is ever added it goes first in the priority order, ahead of keeps and breaks.

The old FLOW +1 tag and the old ability icons are gone.

## Art
Drawn in code in a physical style. Optional textures in `art/textures/`: `metal_brushed`, `metal_dark`, `rubber`, `leather`, `fabric`, `wood`, `crate_wood`, `pegboard`, `cardboard`.

## Next
Shop services Burn (copy an album to a CD-R), Trade in and a Label Maker (change a CD's genre or decade); crowd mood zones; crowd fatigue (the crowd tires of a genre played too often, so keeping flow and staying fresh pull against each other); the ring from the demo in the main game (closing the set back to the opener); a marker on the open slot when a Hype Man bonus is waiting; a quiet bias so venue tastes don't land on your biggest genres; more stop types (rest stop, radio station); more flow gear and call-out types.
