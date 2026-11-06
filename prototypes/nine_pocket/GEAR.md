# Disc Engine: gear roster (34 units)

The numbers and text live in `data/gear.json`, edited with the gear workshop. All units are Half bays (one of 6 half-slots in the rack). A Splitter adds one copy of the unit to its right. An Audio Interface adds one copy of the unit on each side of it. Copies add together, so a unit between a Splitter and an Audio Interface counts three times.

Special units (behavior in code): Deep Library, Sneak Peek, Noise Gate (buttons, once per gig), Octave, Saxophone, Splitter, Audio Interface, T Shirt Cannon, Vintage Amp, Big Bass, Piggy Bank. Everything else is a rule you can tune in the workshop.

| Name | Effect (N = the unit's amount) |
|---|---|
| Genre EQ | +N point for every {rn} CDs of the song's genre in your deck (max +{cap}). |
| Decade EQ | If {rn}+ songs are all from different decades, each scores +N points. |
| CD Burner | Your first song gets +N base points for the rest of the run. |
| Looper | If the last song shares a genre or decade with the first, flow xN. |
| Overdrive | The Cools Off crowd move never heals the crowd. |
| Tube Preamp | +N point per song for each different genre in your play (max +{cap}). |
| Phaser | +N flow when a song's decade is later than the song before it. |
| Tuner | +N discard each gig. |
| Mini Amp | +N point per song for each genre you hold {rn}+ CDs of in hand (max +{cap}). |
| Fog Machine | Hecklers can no longer block a slot. |
| Delay Pedal | When a song shares its genre with the song {rn} back, its card effect triggers again. |
| Merch Table | $N each turn you play all four slots. |
| Tip Jar | $N per unused discard when the show ends. |
| T Shirt Cannon | Slot 3 earns no points, but earns money equal to its base points. |
| Octave | Songs of one genre also count as another. |
| Reverb | +N points per song for each empty slot in your play (max {cap}). |
| Audio Interface | Units on either side of it count double, like a Splitter. |
| Noise Gate | Once per gig: cancel this turn's crowd move. |
| Request Line | A Demand move never heals the crowd. Meeting it pays +N points. |
| Vintage Amp | Gains +{store} flow each time a {decade} song is played. Adds to your starting flow. |
| Big Bass | Gains +{store} flow each time a {genre} song is played. Adds to your starting flow. |
| Piggy Bank | The pot gains ${cash} each gig, plus $1 per turn left on a win. Sell it to cash out. |
| Deep Library | Once per gig: redraw your whole hand. |
| Sneak Peek | Once per gig: look at the next {count} songs in your binder. |
| Turntables | After each {aparam} song this gig, flow rises by N. |
| Radio | Each {aparam} song pays $N. |
| Saxophone | Jazz songs count as any genre for their neighbors' conditions. |
| Splitter | Duplicates the unit to its right. |
| Wah Pedal | After every song, flow rises by N for each unit to its left. |
| Blues Drive | {aparam} songs next to a {rparam} song score +N points. |
| Chorus | {aparam} songs next to a {rparam} song score +N points. |
| Funky Groove | +N flow after a {aparam} song next to a {rparam} song. |
| Showtune | {aparam} songs next to a {rparam} song pay $N. |
| Shred | Every {rn} {aparam} songs in a row, the last one scores xN. |
| Flanger | Rainbow: if 3+ songs are all different genres, every song's card effect triggers again. |
| Ping-Pong Delay | Zigzag: if 3+ songs are played and no neighbors share a genre, each song raises flow by 0.5. |
| Mirror Ball | Mirror: if 3+ songs' genres read the same backwards, flow x1.5 on the closing song. |
| Talk Box | Sandwich: a song between two songs of one other genre triggers its card effect again. |
| Metronome | Ladder: if 3+ songs each rise a decade, every song scores +5 points. |
| Slapback Echo | When the song before shares a song's decade, its card effect triggers again. |
| Encore Pedal | If the closing song shares a genre or decade with the opener, its card effect triggers again. |

## Hand-shape gear

Shapes are only defined by gear, not by the game. Each is a condition the workshop can set on any rule:

- Rainbow: all genres differ (Flanger, Tube Preamp, Decade EQ for decades)
- Loop: closing song matches the opener (Looper, Encore Pedal)
- Echo: a song matches the song N back (Delay Pedal)
- Zigzag: no neighbors share a genre (Ping-Pong Delay)
- Mirror: genres read the same backwards, like Rock Pop Pop Rock (Mirror Ball, stacks with Looper)
- Sandwich: a song between two of another genre (Talk Box)
- Ladder: each decade later than the last (Metronome, Phaser)
- Neighbors: same decade (Slapback Echo), or a genre beside another genre (Blues Drive, Chorus, Funky Groove, Showtune)

## Open items

- Sneak Peek only looks at the next 3 CDs. Taking one into your hand needs a pick screen.
- Piggy Bank pays out only when sold (there are no bosses now).
- Flow numbers (Turntables, Wah Pedal, Phaser, Funky Groove) need tuning against the end-of-turn multiply.
- A Pop and Hip-Hop pair gear is still missing from the cross-genre set (Blues Drive, Chorus, Funky Groove, Showtune).
