# Disc Engine: gear roster (31 units)

This roster is implemented in the game. The units and their numbers are in `data/gear.json`, edited with the gear workshop (see DESIGN.md); the behavior is in `nine_pocket.gd`.

## Rack rules

- The rack has 4 bays of 2 half-slots each. A Full unit fills a bay. A Half unit takes 1 half-slot.
- Gear can be dragged and rearranged freely until PLAY is pressed.
- Chain order is left to right inside a bay, then down to the next bay. "The unit to its right" is the next unit in that order.
- A unit with a button is active gear. The button works only while you are laying out the set, and it recharges at the start of each gig.
- Scaling counters (Vintage Amp, Feedback, Piggy Bank) live on the unit for the whole run. Selling the unit loses the counter.
- Units that are random (the EQs, Octave, Sampler) roll when you get them and show the result on the unit.

## Roster

### Points

| Name | Bay | Effect |
|---|---|---|
| Overdrive | Half | +3 points per song. |
| Make Some Noise | Half | +1 point per song. |
| Genre EQ | Full | Random fader for each genre, about -1 to +3 points per song of that genre. |
| Decade EQ | Full | Random fader for each decade, same idea. |
| Tube Preamp | Full | +1 point per different genre in your hand (max +5). |
| Reverb | Half | Each song scores +1 point for each earlier song in the set that shares its genre (max +5). |
| Looper | Half | The final song scores x2 points if it shares a genre or decade with the slot 1 song. |
| Delay Pedal | Half | If two songs of the same genre are back to back, the next one scores x2 points. |

### Flow

| Name | Bay | Effect |
|---|---|---|
| Fog Machine | Half | The opener raises flow by 1 after it plays. |
| Phaser | Full | +0.5 flow if the song before has the same decade. |
| Vintage Amp | Half | Gains +0.1 flow each time a 60s song is played. The stored flow is added to the starting flow of every set, for the rest of the run. |
| Feedback | Half | Gains +0.1 flow each time a Rock song is played. Same storage as Vintage Amp. |
| Wah Pedal | Half | After every song, flow rises by 0.05 for each unit to its left in the chain. It wants to sit last. |

### Economy

| Name | Bay | Effect |
|---|---|---|
| Merch Table | Full | $5 at the end of each gig. |
| Tip Jar | Half | $2 per unused discard when the show ends. |
| T Shirt Cannon | Half | Slot 3 earns no points, but earns money equal to its base points. |
| Sampler | Half | Random pair: songs of the first genre pay $1 when they follow the second (for example Jazz after Rock). |
| Piggy Bank | Half | Holds a pot that gains $1 each gig. Selling it pays out the pot, as does the tour boss. There is no cash-out button. |

### Rules, crowd and requests

| Name | Bay | Effect |
|---|---|---|
| Octave | Full | Random pair: songs of the first genre also count as the second (for example Hip-Hop as Pop). |
| Audio Interface | Half | "The song above" also works in slots 1 to 3, where it means the mirrored slot (slot 1 looks at 6, 2 at 5, 3 at 4). |
| Noise Gate | Half | At the start of each gig, one randomly chosen hated tag is ignored. It is shown before PLAY. It does nothing when the boss has the hates ability. |
| Request Line | Half | Requests pay +20 points instead of +10. |

### Hand and discards (CD Burner, Deep Library and Sneak Peek have a button, once per gig)

| Name | Bay | Effect |
|---|---|---|
| CD Burner | Full | Copy an album onto a Mix (both must be in hand). The copy goes to the binder and the source returns to hand. |
| Deep Library | Half | Redraw your whole hand. |
| Sneak Peek | Half | Look at the next 5 songs in the draw pile. |
| Tuner | Half | +1 discard (passive). |

### Genre gear

| Name | Bay | Effect |
|---|---|---|
| Stack Amp | Half | Each Rock song scores +1 point for each other Rock song in the set. |
| Turntables | Half | After each Hip-Hop song, flow rises by 0.25. |
| Radio | Half | Each Pop song pays $1. |
| Saxophone | Half | Jazz songs count as any genre for their neighbors' conditions (the song before, above and after). |

### Chain gear

| Name | Bay | Effect |
|---|---|---|
| Splitter | Full | Duplicates the unit to its right. Any unit works. |
| Wah Pedal | Half | See Flow. |

## Splitter rules

- Numeric bonuses are added a second time, not multiplied: +3 becomes +6, x2 becomes x3, $5 becomes $10, +0.5 flow becomes +1.
- Active gear gets a second use per gig.
- Random pairs get a second pair: Octave and Sampler roll another pair, the EQs double their faders, Noise Gate ignores a second hated tag, Tuner gives +2 discards.
- Splitter next to a Splitter, or last in the chain, does nothing.
- Counters (Vintage Amp, Feedback, Piggy Bank) grow at the normal rate and pay out double.

## Counts

- 31 units: 8 Full and 23 Half. A full rack is 4 Full units or 8 Half units.
- The old Make Some Noise (closer x2), Gain Stage, Exciter, Pitch Control and Echo Unit are not in this roster.

## Provisional numbers and open items

- Wah Pedal is 0.05 per unit, not 0.1. At 0.1 with a rack of 6 units it adds about +72 raw points per set, four times Overdrive.
- Piggy Bank at $1 per gig only reaches about $3 by the tour boss, which is less than one Merch Table gig. Consider $2 per gig, or a pot that grows by one more dollar each gig.
- Make Some Noise (+1 per song) is strictly worse than Overdrive (+3 per song) at the same bay cost. Either cut it or give it a different job.
- Splitter next to Looper or Delay Pedal makes x3 on a single song. Check it with the bot.
- Deep Library recharges each gig. If you want it to be a single-use consumable, say so.
