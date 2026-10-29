# Nine Pocket — CD binder roguelike

Collect CDs into one 3×3 binder sheet that you keep all run. Each round a judge scores it as **Sound × Mult**; miss the target and the run ends. Where a disc sits matters as much as what it is.

**Prototype:** run `nine_pocket.tscn` (F6). Tuning numbers, judge rules, ability weights, jobs, editions, sleeves and bundles are in `nine_pocket_data.gd`. Rules are in `nine_pocket.gd` (scoring in `_score` / `_fire`, judges in `_make_judge`, abilities in `_make_ability`, workshop in `_make_orders` / `_apply_job`). Shared drawing helpers are in `nine_pocket_ui.gd`. Right-click or Esc cancels a selection, sleeve or job.

## Run
- 7 rounds. Start with $30 and an empty sheet. Each round has three screens in order: **Store → Pressing plant → Judge**. Pass to get the clear reward; fail and the run ends.
- Every screen is a place seen from the front. Your binder stands upright on the right. Minor UI sits in the corners: the wallet (cash + round pips) top left, flyers for tonight's judge and the next judge top right (hover for the rules, click for details), and the next-step button bottom right of the scene.

## Discs and tags
- Each disc is a real album from `art/album_photos` (Genre > Band > Album, files named `Band - Album - original.jpg`). Run `godot --headless --path <repo> -s res://prototypes/nine_pocket/tools/make_covers.gd` after changing photos; it center-crops 384px covers into `art/covers/` and writes `catalog.json`.
- Tags: genre (7), decade (60s–10s), label (4), rarity (Common/Uncommon/Rare), condition (Worn/Good/Mint), runtime. Genre, band, title and cover come from the art; each band has a fixed decade and label until the pressing plant changes them.
- Tags are printed in a strip under every binder pocket and store slot. Tags that match tonight's judge are outlined green (Sound rule) or purple (Mult rule).
- Hover any disc for a sectioned tooltip: title and band, tags, its ability (with a colored Sound/Mult chip), edition, which of tonight's rules it matches and where it needs to sit, and label/runtime/sell price.

## Scoring
- Discs activate in slot order 1 to 9. Each activation adds, in order: base Sound by rarity (2/4/6), its edition, the judge's rules, any row/column boosts from other discs, then its own ability. Mult starts at 1. Score = Sound × Mult (each at least 1).
- **Judges** have one Sound rule and one Mult rule. Each rule names a tag and a place: anywhere, corners, edges, center, a row or column, or "next to another album with this tag". The name comes from the rules' tags (e.g. "The Picky Millennial": Uncommon+ for Sound, 00s for Mult).
- **Abilities** are mostly about placement: same genre/decade/label in its row, column, neighbors or diagonals; neighbors with a tag; corner/center/edge slot; neighbors one decade apart; different genres in its row; whole row or column matching; ×2 Mult if all neighbors match; boosting the rest of its row or column; retriggering the disc to its left, above it, or all neighbors. A few give cash, a free bundle when placed, or extra cash / a Rare album when sold. Retriggered discs don't retrigger anything themselves.
- Neighbors are rows and columns only (diagonals only where an ability says so).

## Store
- A 4×3 display bin: 8 single albums in jewel cases (buy price = sell price × 2, +$2 if it has an ability), and 4 box sets (one of each tier plus a random fourth). Restock the singles for $2, +$1 each time. Organize the bin by price, genre, decade, label, rarity or condition.
- Bought discs go into the first open pocket. If the sheet is full, sell a disc first (select it, then its Sell tag).
- Box sets (Bargain Bin $6, Estate Sale $12, Box Set $20) give 4–5 discs plus cash; keep what fits, the rest sell automatically.
- 2 sleeves hang beside the bin. A sleeve goes on one pocket for this round only: Echo (activates twice), Amplifier (+2 to its ability's number), Polish (counts as Mint), Grader (one rarity higher), Wildcard (every genre), Gold ($2 per activation).

## Pressing plant
- 5 work orders per round, each usable once. Pick an order, then a disc in your binder (discs that can take it glow green).
- Remix (change genre to X, $4), Remaster (±1 decade, $3), Relabel (move to label X, $3), Re-press (+1 condition, $4).
- Editions are permanent and one per disc: Signed (+6 Sound, $8), Picture Disc (+2 Mult, $9), Platinum (×2 Mult, $14). An edition adds $2 to the sell price.

## Binder
- One 3×3 sheet for the whole run. Move discs freely in the Store and Pressing plant (click a disc, then a pocket). Sell any disc for $1/$3/$6 by rarity + condition (0/1/2) + edition.

## Targets and economy
- Targets self-calibrate at run start: median score of 200 random, unarranged full sheets under that judge × the round factor (0.5, 0.8, 1.1, 1.4, 1.8, 2.2, 2.7), minimum 4.
- Cash: clear reward ($6 + $1 per round), selling, box set cash, cash abilities, Gold sleeves.

## Open for tuning
Round factors vs. a persistent, arranged sheet; job prices and order mix; ability numbers; whether the pressing plant should also post a side request (bonus goal) each round.
