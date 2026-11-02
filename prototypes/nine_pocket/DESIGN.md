# Disc Engine

You're a DJ playing shows against the crowd. Draw a hand of CDs, lay out a set of 6 in the order you want, and let the effects chain together. Your set's total score has to reach the gig's target score to win the crowd over.

**Prototype:** run `nine_pocket.tscn` (F6). Venues, points, effects, targets, gear and editions are in `nine_pocket_data.gd`. Rules are in `nine_pocket.gd`: show flow in `_start_show` / `_on_pocket` / `_on_slot` / `_play` / `_start_slot` / `_finish_song` / `_confirm_dig` / `_end_show`, scoring in `_score_set` and `_apply_effect`, call-outs in `_new_call`. Shared drawing helpers are in `nine_pocket_ui.gd`. Earlier versions are in git history.

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
**Lay out the whole set, then press PLAY.** You fill all 6 slots of the changer from your hand, in any order. When you press PLAY the set resolves left to right, one song at a time, and every card's effect fires in turn. There is no hit or miss: every card always scores, and a set-wide **flow** builds up as the set plays. The gig is cleared if your total is at or above the target score after song 6, and you are booed off if it isn't. The target grows over the tour (`GIG_TARGETS`: 70, 120, 210, 380, 680, 1200; a boss gig is x1.25 as a headliner, and the "High expectations" boss another x1.3).

**Flow is a running multiplier. A song scores (points + additions) x flow x local multipliers.** Flow starts at x1 each show and persists through the set. Effects raise it after their song plays, so builders go early and your big-point songs go late, building to a finale. Scores can get very large and are shown with K and M suffixes above 100,000.
- **Points:** every album has a number set by its effect (`COND_POINTS`): a plain card 12, an effect card 4 to 8.
- **Effects** look at where the card sits in the sequence. The slot grid is a snake, so "above" means the song in the slot over it on slots 4 to 6:
  - **Plain:** no effect, 12 points. (Tube Preamp adds to these.)
  - **Set 1 / Set 2:** +10 points in slots 1 to 3 / slots 4 to 6.
  - **Odd / Even:** +8 points in slots 1, 3, 5 / slots 2, 4, 6.
  - **First / Last:** x2 in slot 1 / x3 in slot 6.
  - **After a genre or decade:** x2 if the song before it matches.
  - **Above a genre or decade:** x3 if the song above it matches (slots 4 to 6 only).
  - **Amp** (flow +1.5), **Surge** (flow x2.5): raise your flow after this song plays.
  - **Fans:** raises your flow by 1 for each song of its genre played before it, after this song plays.
  - **Anthem:** every later song of its genre gets +8 points.
  - **Copy:** repeats the effect of the song before it.
- **Additions** are added to the points and **multipliers** multiply the total, in any order: a liked genre or decade +5, the request +10 (the first song of the requested genre or decade in your set), editions (Holographic +3, Signed +5, Limited +8), gear (see Rack), a hated song x0.5 (nothing on the "Angry crowd" boss), a boss debuff on your most common genre or decade x0.5, and a boss's locked slot scores nothing for songs that don't fit.
- The lines of each song float up one by one with the running total on its slot as it plays, so you can see what fired. Nothing in the game shows what a set will score before you press PLAY: you read the cards, the slot and neighbour readout on the rack, and work it out.

**Pay:** a missed target pays $2 and ends the tour. A cleared target pays $5 ("Target cleared"), $8 at 1.5x the target ("Big applause") and $11 at 2x ("Encore!"). The meter on the rack shows your score against the target with ticks at 1.5x and 2x.

## The show
- Your binder is shuffled at the start of each show. You draw a **hand of 8** into the CD wallet (two rows of 4, `HAND`), and nothing is drawn after that: you choose which 6 of the 8 to play and in what order.
- The changer has **6 slots in a 3×2 snake** (`SETLIST`): slots 1 to 3 run left to right along the top row, then slots 4 to 6 run right to left along the bottom, so slot 4 sits under 3 and slot 6 sits under slot 1. They are played in order, one at a time. Only the open slot takes a CD:
  - Click a CD in your hand to load it into the first empty slot. Click a CD in the changer to pick it up (the slot glows gold), then click another slot to swap or move it, a hand pocket to swap it with that CD, or the same CD again to send it back to your hand. Right-click cancels. PLAY unlocks when all 6 slots are full.
  - Slots show their score only once played; the arrows between slots and the link icons between rows light up when the song's effect fired.
  - PLAY: Mixes become their genre and decade, then the set resolves left to right, 4 seconds a song. Each song floats up its lines (effect, points, additions, multipliers) with a running total, then locks showing e.g. "+168". The show ends after slot 8.
- **Discard** (3 per show): throw away 1 CD from your hand, then **choose 1 of 3** from a panel that covers only the gear rack, so the changer, your hand (the empty slot glows gold), the score panel and the venue clipboard all stay visible and hoverable. While choosing, PLAY, placing and discarding are locked CDs drawn at random from the draw pile. The other two go back into the pile. The discarded CD goes to a discard pile and can't be offered again until the draw pile runs low (fewer than 3 left), when the discard pile is shuffled back in. Discards are free; they are how you dig for the cards your sequence needs. If the pile is empty, discarding is unavailable.
- **Draw pile table:** a readout in the console strip shows (a toggle switch beside it flips between *PILE* and *PILE + HAND*, which also adds the CDs in your hand; the card tooltips follow the same setting) how many CDs of each genre and each decade are still in the draw pile (amber digits, genre-colored underline), plus the pile total and the number of Mixes. The genre and decade of the song just played glow cyan, since those are the tags that keep the flow. Hovering a CD in your hand or the changer adds "Left in the draw pile: N of its genre, M of its decade" to its tooltip.
- **Reading the slot:** the display on the rack shows the slot you have picked up, are hovering over or (while playing) are resolving: its set, odd or even, first or last, and the genre and decade of the song before it (PREV), above it (ABOVE) and after it (NEXT), so you can check an effect before you commit.
- At the start of each show the crowd shouts a **request** ("Play some 90s!"): +10 points for the first song of that genre or decade in your set.
- The clipboard holds a taped note with the venue's likes and hates, and the yellow slip with the current call.
- **Console strip** (bottom, brushed metal like the rack units), left to right: a black *View binder* button; a black *Discard* button with three amber lights for discards left (while choosing, it becomes *Discard* and *Cancel*); the **draw pile table** (see Discard); and **Sort** as five amp-style toggle switches (Genre, Decade, Points, Band) whose lights use the same amber. All console buttons share the black style.

## Boss gigs
**Every third gig is a boss** (boss and headliner mean the same thing): gigs 3 and 6, with the fork roads covering the gigs between. Beating gig 6 completes the tour. Bosses use the headliner's venue and ×1.25 targets, and carry one **challenge**, different for each boss in a run. The fork screen warns which challenge the next boss will have, a boss screen spells it out, and the crowd panel keeps a red reminder. The challenges (`BOSS_KINDS`):
- **Genre debuffed / Decade debuffed:** songs of your most common genre (or decade) score half all night.
- **Crowd request:** one of slots 2-5 only takes a chosen genre or decade; anything else scores nothing. A red tag marks the slot.
- **Angry crowd:** an extra hated genre (one of your common ones), and hated songs score nothing.
- **High expectations:** the target is 30% higher.
- **Broken equipment:** one piece of rack gear is out for the show (restored afterward).
- **Rough crowd:** each song played has a 20% chance to be destroyed for good (removed from the binder when you leave the show).
- **No time to dig:** one discard instead of three.


## Starting kits
The game opens on a title screen (Play), on a plain black background, whose music comes from one **random album** that has a song (its cover shows only on the spinning disc; the song plays from the middle, loops, and "Now playing" names it). The kit screen keeps the song and is also on plain black. Going back to the title from the kit screen keeps the song; arriving at the title after a run picks a new one. Starting a run fades the music out over 1.5 seconds (`MENU_FADE`). Then a **kit screen** with four cards. Each kit is one piece of starting gear for the rack, and every kit starts with $0. There is no Basement any more. Picking a kit opens the **deck screen** (see Deck), and picking a deck starts the run at the first fork. Winning or losing returns to the title.
- **Deck:** you pick it on a **deck screen** after the kit screen: one deck for each genre (7) and one for each decade (6). Every deck is **24 real CDs, no Mixes**, so a hand of 8 is a third of it. It has one CD of each genre (7, spread so every decade shows up at least once), `DECK_THEME` (6) more CDs of the deck's own genre or decade, and 11 basic CDs of random genres and decades. The deck is deliberately weak and simple: `START_DECK` deals 14 **plain** CDs (5 points, no effect, "place anywhere, not worth much") and 10 simple ones at 3 points (`START_POINTS`): one each of set 1, set 2, odd, even, first, last, after-genre and after-decade, and two Amps (flow +1.5). There are no Surge, Fans, Anthem, Copy or Above effects to start with. Better CDs have to be found: pickups, the shop and packs roll from `COND_WEIGHTS`, which favours flow builders and the stronger effects, at full `COND_POINTS` (a found plain CD is worth 12). Each album borrows a catalog cover and title (preferring one with the same genre and decade) and takes its genre, decade, effect and points from its slot. Mixes are no longer in the starting deck; they only come from shops and services.
- **Kits** (`KITS` in the data file):
  - **Chain Gang:** Echo Unit.
  - **Showstopper:** Make Some Noise.
  - **Genre Streak:** Gain Stage, dialed to Punk.
  - **Crowd Pleaser:** Tube Preamp.
- **Mixes** (blank CD-Rs, 3 points, no effect): at PLAY a Mix picks a random album from the whole catalog and becomes that album's genre and decade for the neighbours, crowd and gear. It resets after each show.
- Tuning knobs: `KITS`, `DECK_SIZE`, `DECK_THEME`. The kits differ only by gear for now; the decks differ only by genre or decade.

Better albums, editions and more gear come from pickups and the shop.

## The catalog and effects
**The catalog** is `album_catalog.gd`: 63 albums, 7 genres x 3 bands x 3 albums. Each album has a catalog genre and decade and a title. The game pairs the new titles with the existing cover art within each genre, in order, keeping the real band names, and the mp3s stay bound to the cover art. The catalog's sticker and payout columns are not used.

**Effects** for catalog albums are rolled once per album from a seed on its cover using `COND_WEIGHTS` (the pool for found CDs), so they never change between runs. Generated albums (shop, pickups, packs) roll the same weights fresh. Points follow `COND_POINTS`. Genre and decade parameters are random.

**Genre and decade** are one of each per album and drive the crowd, gear, effects and bosses: a venue like adds +5 points for a matching genre or decade, a hated one halves the song, the request is met by a matching song, Graphic EQ adds the genre's fader, Gain Stage and Exciter add for their dial's genre or decade, and boss genre and decade debuffs apply to matching songs. Genre has no colour anywhere. A Mix copies a random album's cover, genre and decade when it is played.

**Rules:** an album can be played any number of times in a set. The record shop, pickups and album packs generate albums with a random genre, decade and condition (`_gen_album`, using `COND_WEIGHTS`), borrowing a catalog cover; a road's theme fixes the first album's genre and decade.

**Editions** (8% of albums): Holographic +3 points, Signed +5, Limited Edition +8, Mint Condition +$1 per play.

## Rack
All 4 bays start empty. The kit gives one piece of gear; more comes from pickups and the shop.
- **Point gear:** Graphic EQ adds 3 per fader step (-3 to +6) to every song of that genre; Gain Stage +3/+6 for the dial's genre; Exciter +3/+6 for the dial's decade; Tube Preamp +4/+8/+12 for plain cards (no effect).
- **Sequence gear:** Make Some Noise makes your closing song score x2 (MK II x3); Pitch Control lets after/above decade effects accept a decade one step either side; Echo Unit makes flow gains from effects 50% bigger.

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
Left: the changer (6 slots in a 3×2 snake, each showing its score once played) with the hand in the CD wallet below it (8 CDs in two rows of 4, the same size as the discs in the changer) and the venue clipboard beside the hand. Middle: one score panel, the only place the score lives: SCORE, TARGET and FLOW readouts, the score meter, the readout for the slot you are working on (its set, odd or even, first or last, and its PREV, ABOVE and NEXT neighbours) and the PLAY SET button with a loaded count. Right: the gear rack, four tall bays. The console strip runs along the bottom (View binder, Discard, draw pile table, sort switches).

## Balance
The scoring is now a laid-out sequence (see Scoring), so the old per-venue table is gone.


Measured over 150 hands of 8 at random venues (no gear), with the basic 24-CD starting decks (all 13 decks, picked at random): picking and ordering 6 cards at random scores a median of about 58 (p10 39, p90 119); the 6 highest-point cards in hand order about 48; and a hill-climbing planner that searches for the best 6 and order scores about 119 (p10 60, p90 219). Targets (70, 120, 210, 380, 680, 1200, about 1.8x per gig) are a first pass: the first gig is clearable with the starting deck, and later gigs assume you have found better CDs and gear. The shop and pickups haven't been simulated. Tuning knobs: `GIG_TARGETS`, `HEADLINER_MULT`, `BOSS_TARGET`, `START_DECK`, `START_POINTS`, `COND_POINTS`, `COND_WEIGHTS`, `AMP_ADD`, `SURGE_MULT`, `FANS_FLOW`, `ECHO_FLOW`, `SET_BONUS`, `SIDE_BONUS`, `OPENER_MULT`, `CLOSER_MULT`, `AFTER_MULT`, `ABOVE_MULT`, `ANTHEM_ADD`, `HATE_MULT`, `LIKE`, `REQUEST`, `EQ_UNIT`, `HAND`, `SETLIST`, `DECK_SIZE`, `DECK_THEME`, `TIER_GOOD`, `TIER_GREAT`, `PAY_*`, `CDR_POINTS`, `MUSIC_SECONDS`.

## Music

Pressing PLAY starts the album's track from a random point (at least a second before the end) and lets it run 4 seconds, fading over the last 0.8. The song only finishes, and the next one can be played, once both the score readout and the 5 seconds are done. Tracks live in `music/<Genre>/<Band>/` and are matched to albums by the file name starting with "Band - Album". A Mix plays the track of the random album it picked. Length is `MUSIC_SECONDS` in the data file.

## Ring demo

`ring_demo.tscn` is a separate prototype scene; the main round is untouched. Open it in the editor and run the scene (F6). It shows a 7×6 genre × decade LED map beside a 5-slot ring changer. Click a CD in the hand to play it into the next slot. The map numbers the set's path, glows the last CD's row and column (they keep the flow) and the opener's row and column, and marks cells that would close the ring. Closing the ring (the last CD shares a genre or decade with the opener) adds +1 flow and lifts the cap to ×5. Label maker mode cycles a CD's opener/closer tags. Deal 3×3 uses a starter-style patch of the map; Deal wide spreads the hand over the whole map.

## Card tags

Each kind of information has one visual channel, and nothing else uses it.

- **Cover and condition:** the disc is the album's cover art. A strip of masking tape across the top reads "Decade-Genre" (for example "80s-Indie") in black marker; if a venue likes or hates that genre or decade, or a gear unit boosts it, that half of the label turns green, red or gold. A dark pill near the bottom of the disc names its effect (SET 2 +10, LAST x3, AFTER PUNK x2, NEXT +12, +4 PER ROCK, COPY PREV and so on). Points sit in the green badge at the top left. There are no chips under the disc and genre has no colour. A Mix shows a blank CD-R until it is played, then the cover it became with a MIX pill.
- **No situation states:** cards in your hand are never highlighted or debuffed; the card shows its effect and you decide.

The old FLOW +1 tag and the old ability icons are gone.

## Art
Drawn in code in a physical style. Optional textures in `art/textures/`: `metal_brushed`, `metal_dark`, `rubber`, `leather`, `fabric`, `wood`, `crate_wood`, `pegboard`, `cardboard`.

## Next
Shop services Burn (copy an album to a CD-R), Trade in and a Label Maker (change a CD's genre or decade); crowd mood zones; crowd fatigue (the crowd tires of a genre played too often, so keeping flow and staying fresh pull against each other); the ring from the demo in the main game (closing the set back to the opener); a marker on the open slot when a Hype Man bonus is waiting; a quiet bias so venue tastes don't land on your biggest genres; more stop types (rest stop, radio station); more flow gear and call-out types.
