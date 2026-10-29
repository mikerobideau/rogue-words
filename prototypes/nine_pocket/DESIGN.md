# Disc Engine

A tour of 8 gigs. At each gig you load albums from your CD wallet into a 5-disc changer, press **PLAY**, and the set plays through your stereo rack. Each song adds Sound or Energy, and the set scores **total Sound × total Energy**. Beat the gig's target to get paid, then spend it at the record shop on albums and rack gear.

**Prototype:** run `nine_pocket.tscn` (F6). Tuning numbers, abilities, gear, packs and targets are in `nine_pocket_data.gd`. Rules are in `nine_pocket.gd` (scoring in `_score`; run flow in `_new_run` / `_start_gig` / `_finish_set` / `_next_gig`; shop in `_make_shop` / `_buy` / `_take_pack` / `_install`). Shared drawing helpers are in `nine_pocket_ui.gd`. Earlier versions (roguelike, logic puzzle) are in git history.

## Run
- Start: 20 random albums in your **binder**, $0, and a 4-bay rack with a Graphic EQ and a Crossfader.
- 8 gigs with fixed targets: 90, 120, 160, 210, 270, 350, 450, 580. Miss one and the tour ends.
- Clearing a gig pays $5 + (gig − 1), plus a crowd bonus of $1 per 25% over the target (max $3). Then the record shop, then the next gig.

## A gig (one set)
- The **CD wallet** (4×2 sleeves) is your hand: 8 albums drawn at random from your binder.
- Move up to 5 into the changer's slots (click or drag; dropping on a full slot swaps), then press PLAY.
- **Sort wallet**: sort by Genre, Decade, Sound, Ability or Band (click again to turn off).
- **Dig** (2 per gig, amber LEDs): pick up to 3 wallet albums to swap for others from your binder.
- Genre and decade chips show under every disc. A gold outline means your rack boosts that genre or decade.

## View binder
The **View binder (N)** button sits at the bottom left on every screen (also the B key), including over the result, pack and end screens. It opens your whole collection as a leather binder of 9-pocket pages, 18 albums per spread, in the wallet's sort order (or the order you got them). Flip with the Prev/Next buttons, the arrow keys or the mouse wheel; Esc, right-click or Close shuts it. During a gig, discs are tagged IN WALLET, IN CHANGER or DUG. Hover any disc for its tooltip. The summary card shows totals by genre, decade, base Sound, ability, and band (bands with 2+ albums in bold, for Bandmates and One Hit Wonder).

## Scoring
Songs play left to right. The set keeps two running totals: **Sound** (starts at 0) and **Energy** (starts at 1). For each song:
1. Base Sound (the green number on the disc, 2–5).
2. The disc's ability, if it triggers (×2 and +N apply to this song's Sound; Energy effects change the set's Energy).
3. Rack gear, top bay to bottom bay.
4. The song's Sound is added to the set's Sound.

After the last song: **set score = total Sound × total Energy**. The rack display shows SOUND × ENERGY = SET live; each changer slot's readout shows what that song added.

**Disc abilities**: Doubleshot (×2 Sound if same decade as previous song), One Hit Wonder (×1.1 Sound per earlier play this tour, resets when another song by the band plays), Opener (+2 Energy if first), Closer (×2 Sound if last), Crowd-Pleaser (+1 Energy), Segue (+4 Sound if the next song is the same genre), Slow Jam (+8 Sound, then −1 Energy), Deep Cut (+6 Sound if Energy ≤ 2), Bandmates (+1 Energy if another song by the band is in the set). Discs with an ability have 1 less base Sound.

**Editions** (8% of new albums; one per album; shown as a colored tag at the top right of the disc plus a look on the disc):
| Edition | Effect | Look |
|---|---|---|
| Holographic | +1 Energy | rainbow sheen |
| Signed | +4 Sound | marker signature |
| Limited Edition | ×2 Sound | gold rim |
| Remaster | its ability triggers twice | blue inner ring |
| Mint Condition | +$1 each time it's played (paid with the gig) | sparkles |
Editions apply after the disc's ability and before the rack.

**Rack gear** (4 bays; order matters, e.g. EQ's boost above a Gain Stage gets doubled). You can't own two of the same unit: the shop and gear boxes never offer one you have.
| Gear | Effect by level | Price |
|---|---|---|
| Graphic EQ | each genre's fader (−1 to +3) is added to that genre's Sound; starts as a shuffled +2, +1, +1, −1, −1, 0, 0 | $6 |
| Crossfader | +1 / +2 Energy when a song shares a genre or decade with the one before | $7 |
| Gain Stage | ×2 / ×3 Sound for the genre on the dial | $7 |
| Compressor | +1 / +2 / +3 Sound for every song | $5 |
| Exciter | +1 / +2 Energy for the decade on the dial | $6 |
| Tube Preamp | +3 / +5 / +7 Sound for songs without an ability | $5 |
Levels show as MK II / MK III on the faceplate. Dials favor genres and decades you own 3+ of. EQ cuts show as red faders, and wallet chips for a cut genre get a red outline (gold for a boost).

## Record shop
Six offers, rolled fresh each visit:
- **CD browser bin** (crate): 2 albums in jewel cases ($3, +$1 with an ability, +$1 if base Sound ≥ 4) and 1 shrink-wrapped album pack: Sampler ($4, pick 1 of 3) or Box Set ($7, pick 2 of 4).
- **Pegboard gear wall**: 2 rack units on shelves with hang tags, and 1 cardboard gear box: Grab Box ($6, keep 1 of 3) or Studio Bundle ($11, keep 2 of 3).
- **Counter**: cash register (cash, binder size, next target) and the Next gig button.
- **Work orders** (pinned to the counter, up to 2, each appears sometimes): *Edition* ($4–8, 45%): pick an album without an edition in the binder overlay to give it that edition. *Bench tweak* ($3, 50%, needs an EQ, Gain Stage or Exciter): raise one EQ fader by 1, or set a dial to any genre/decade. *Unit upgrade* ($6, 45%): take one non-EQ unit to its next level. Pay on use; right-click or Esc cancels without charge.
Buying gear (single or from a box) puts it in your hand: click a rack bay to install it. Installing over a unit replaces it. Right-click cancels (single gear isn't charged until installed; gear from a box is left behind).

## Balance notes
Gig 1 with the starting binder and rack (300 simulated runs, best of 40 / 300 random setlists after digging weak albums): median 108 / 130, 10th percentile 80 / 100, against a target of 90. Later targets assume shop upgrades and haven't been simulated.

## Art
Everything is drawn in code in a physical style (gradients, bevels, gloss, screws, LEDs, LCDs). Optional textures in `art/textures/` replace flat fills when present: `metal_brushed`, `metal_dark`, `rubber`, `leather`, `fabric`, `wood` (gig) and `crate_wood`, `pegboard`, `cardboard` (shop). png/jpg/webp; seamless, evenly lit, fairly neutral color.

## Next
A run-level simulation with a shopping bot to tune targets 2–8 and prices; selling or removing albums; more gear (repeat, tape deck, shuffle switch).
