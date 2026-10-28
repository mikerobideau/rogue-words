# Nine Pocket — CD binder roguelike

Collect CDs into a binder of 3×3 sleeve sheets. Each round a judge scores the current sheet; miss the target and the run ends.

**Prototype:** run `nine_pocket.tscn` (F6). Tuning numbers, ability weights, sleeves, bundles and name lists are in `nine_pocket_data.gd`. Rules are in `nine_pocket.gd` (abilities in `_make_ability` / `_fire`). Shared drawing helpers are in `nine_pocket_ui.gd`. Right-click or Esc cancels a selection, sleeve placement or trade.

## Run
- 7 rounds, 7 judges drawn from 28 (one per pair of the 8 categories). Start with $30 and an empty binder.
- Each round gets a fresh sheet and three screens in order: **Store → Trade → Judge**. You can't go back to an earlier screen. Pass to get the clear reward and a new sheet; fail and the run ends.
- **Preview judge & trader** (on the Store and Trade screens) shows this round's judge (categories, target, which of your discs feed it), the next judge, and the trader's wants and offers.

## Store screen
- 5 new arrivals (buy price = sell price × 2, +$2 if the disc has an ability), 2 bundles, 2 sleeves. Reroll the arrivals for $2, +$1 each time.
- Bought discs go straight into the first open slot on the current sheet.
- **Bundles** (Bargain Bin $6, Estate Sale $12, Box Set $20) give 4–5 discs plus a cash bonus. Keep what fits; the rest sell automatically (and fire their "Sold" abilities).
- **Sleeves** go on one slot of the current sheet and last for that sheet only: Echo (activates twice), Amplifier (+2 to the ability's numbers), Polish (counts as Mint), Grader (one rarity higher), Wildcard (every genre), Gold Sleeve ($2 per activation).

## Trade screen
- 7 offers. Each costs discs that meet 1–2 conditions taken from the trader's two "wants" (genre, decade, label, Good+/Mint, Uncommon+/Rare). One disc that meets both conditions pays for both.
- Pay with discs from any sheet; discs taken from locked sheets leave permanent holes. The new disc needs an open slot on the current sheet.

## Judge screen
- Shows the judge, the current sheet and the scoreboard. Nothing is scored until you click **Judge!**
- Every disc activates in slot order, 1 to 9, and its ability adds to (or doubles) a category, Balatro-joker style. Each step is animated on the sheet. Score = judge's category A × category B (each at least 1). There are no built-in category rules: categories only grow through abilities.

## Binder
- Move discs freely on the current sheet (click a disc, then a slot) on the Store and Trade screens. Use < > to view locked sheets.
- Sell any disc at any time for a fixed price: $1 / $3 / $6 by rarity, + condition (Worn 0, Good 1, Mint 2).

## Discs
Each disc is a real album from `art/album_photos` (Genre > Band > Album, files named `Band - Album - original.jpg`). The genre (7), band, title and cover come from the art; each band has a fixed decade (60s–10s) and label (4). Rarity, condition (Worn/Good/Mint) and runtime (28–79 min) are rolled for each copy. Every disc has one ability; rarer discs roll stronger kinds and bigger numbers.

After adding or changing photos, run `godot --headless --path <repo> -s res://prototypes/nine_pocket/tools/make_covers.gd`. It center-crops each photo to a 384px square in `art/covers/` and rewrites `art/covers/catalog.json`.

| When | Kinds |
|---|---|
| Activated | +N category · +N per matching disc in its row/column/neighbors/sheet/binder · +N per distinct decade/genre/label on the sheet · +N per neighbor with the same decade/genre/label · +N per neighbor one decade apart · +N per 20 min of runtime · +N in a corner/center/edge slot · +N if Mint · +1 per Mint in binder, −1 per Worn · retrigger the disc to the left · retrigger all neighbors · double a category · gain $N |
| Placed | gain $N · get a free Bargain Bin bundle |
| Sold | gain $N extra · create a random Rare album |

Retriggered discs don't retrigger anything themselves.

## Targets and economy
- Targets self-calibrate at the start of each run: for each drawn judge, the median score of 200 random full sheets where 25% of discs are re-aimed at that judge's categories, × the round factor (0.4, 0.6, 0.85, 1.1, 1.4, 1.7, 2.0), minimum 4.
- Cash: disc abilities, bundle bonuses, selling, and the clear reward ($6 + $1 per round).

## Open for tuning
Store and trader offer counts, refreshes, starting cash, round factors, ability weights and numbers, disc prices vs. income.
