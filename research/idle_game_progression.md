# Idle Game Progression & Pacing — Design Research
*For use when balancing Florin Cards. Compiled from published game design literature, industry reports, GDC talks, and developer postmortems.*

---

## 1. The Psychology of Satisfying Idle Progression

The core appeal of idle games is not challenge — it is *anticipation* and *inevitability*. The player knows a reward is coming; the game's job is to make the wait feel intentional rather than arbitrary.

### Variable Ratio Reinforcement
The most powerful retention tool in idle games is the variable ratio reward schedule — the same mechanism behind slot machines. When the timing and magnitude of rewards is unpredictable, players check in more frequently and feel more engaged than with fixed-interval rewards. In Florin Cards, pack opening is the primary variable-ratio event: the player never knows if the next pack will contain a rare or secret card. This is the correct instinct. The key is ensuring the *gap* between pack opens is short enough in early game that players experience the variable reward frequently before becoming fatigued.

### The Psychophysics of "Number Go Up"
A critical insight from idle game design literature is that humans perceive change on a *logarithmic* scale, not a linear one. As Eric Guan's *Idle Game Design Principles* explains: "humans perceive sensory changes on exponential scales, not linear ones. The just-noticeable difference means people notice 5→6 items or 100→120 items (both ×1.2), but not 100→101." This has a direct implication for balancing: **growth must always be perceptible as a ratio, not an absolute amount.** A fl/sec rate of 0.3 jumping to 1.4 after hiring a second chore feels dramatic; the same jump from 1,000.0 to 1,000.3 feels like nothing. This is why each chore tier in Florin Cards must produce a meaningfully larger rate than the last — not just a bigger number, but a visible *multiplier* on the player's situation.

### Milestone Design and "Just One More"
Effective idle games layer micro-milestones (buy the next chore), mid-milestones (unlock a new pack tier), and macro-milestones (complete a rarity set) so a player is always within sight of *something*. The key rule: **players should never finish a session feeling they accomplished nothing.** Even a session where no pack was opened should leave the savings bar visibly closer to full than when it started.

---

## 2. Early Game Pacing — The Critical First Session

### The FTUE Window
Industry consensus, documented across multiple mobile design analyses, is that the first 60 seconds and the first 15 minutes of a game are the entire window in which D1 retention is won or lost. As one mobile design guide puts it: "Quick entry, intuitive interface, and early first 'victories' with rewards will create the desire in players to come back into the game." Players who do not feel rewarded within the first few minutes will not return tomorrow.

The recommended onboarding principle for idle games specifically is: *"Make the core loop exceedingly simple for players to repeat it and obtain rewards easily, and hide buttons at the beginning, rolling them out only when they become relevant."* Florin Cards already does this through its `total_earned` unlock gates — chores, packs, and upgrades only appear when the player can meaningfully engage with them.

### The "First Purchase" Timing
A new player should be able to make their first meaningful purchase within 30–90 seconds. For Florin Cards, this means hiring the first "Little Sibling Helper" quickly through tapping alone. At 0.1 fl per tap, reaching 5 fl requires 50 taps — at a casual rate of ~2 taps/sec, that is approximately 25 seconds. **This is well-timed.**

The problem comes next: after hiring the sibling (0.3 fl/sec), reaching 300 fl for the first Basic Pack takes approximately 17 minutes of passive income alone — far too long for a first session. Solutions used by successful games:
- **AdVenture Capitalist** starts the player with one income source already running, so there is immediately visible passive progress.
- **Cookie Clicker** prices the first upgrade so cheaply that the player experiences the full "purchase → rate increase → faster accumulation" loop within the first 60 seconds.
- **Recommended for Florin Cards**: Either reduce the first Basic Pack cost to ~100–150 fl (just for the first pack, then scale normally), or grant a 50–100 fl welcome bonus, or start the player with one sibling already hired. The goal is to get the first pack open within the first 10 minutes.

### Avoiding the Dead Zone
A dead zone is any period where the player has nothing to buy, nothing to open, and income is too slow to produce visible change in real time. The most dangerous dead zone in Florin Cards is the gap between earning the first passive income and opening the first pack. If the player cannot see the savings bar moving, they will close the app. A practical test: open the game cold with no passive income and count how many seconds before something changes on screen. That number should be under 5 seconds.

---

## 3. Mid-Game Pacing — Sustaining Momentum

### The Exponential Ladder
Idle games sustain mid-game engagement by keeping a roughly constant ratio between the player's current earnings rate and the cost of the next meaningful upgrade. The Idle Idol development team at Game Developer identified this as their core balancing principle: rather than obsessing over exact numbers, they "think about the exponent growth rather than the number itself, like 10, 1000, 1 million, 1 trillion." The *order of magnitude* is what matters; the precise coefficient is tuning.

The sweet spot across the genre is that the **next upgrade should cost roughly 3–8 minutes of current income**. Too cheap and the game rushes past its own content; too expensive and players churn before reaching the next milestone.

For Florin Cards' chore ladder (5 → 30 → 180 → 1,200 → 8,000 → 60,000 → 500,000 → 4,000,000 fl), each tier costs 6–7× more than the previous. This is a healthy ladder, *provided the total_earned unlock gates are calibrated so a new chore unlocks just before the player exhausts the novelty of the current one*. The gap between lemonade stand (unlock at 3,000) and babysitting (unlock at 20,000) is roughly a 6.5× total_earned jump — test whether this creates a mid-game plateau.

### Novelty Injection
Mid-game is where most idle games lose players — the mechanics are understood, the early rush is over, and the next big milestone feels distant. Successful games inject novelty through:
- **New mechanic reveals** at unexpected moments (the "grandmapocalypse" in Cookie Clicker recontextualises all prior progress)
- **New content gates** (Florin Cards does this correctly with pack tier unlocks and upgrade reveals)
- **Surprise events** (God Pack and Double Rare must feel genuinely surprising even to experienced players — if they trigger too often they become expected; too rarely they become forgotten)

The Silver Pack unlock at 5,000 total earned is a critical mid-game novelty injection. This moment should be celebrated visibly — a banner, a celebratory animation, or a Field Note message like "New pack tier unlocked!" rather than a silent UI change.

### The "Soft Wall"
Around the third or fourth chore tier, most players will hit a period where income growth noticeably slows. This is intentional — tension makes breakthrough rewarding. However, the wall must not be *invisible*. The Idle Idol team found that "sometimes your charts make sense mathematically, but it just makes your game feel bland." Pure mathematical balance without feel creates dead time. Players need to understand *why* growth is slow and *what* breaks the wall. Florin Cards' dupe-selling mechanic is an excellent wall-breaker: when passive income stalls, selling a batch of dupes provides a meaningful lump-sum injection.

---

## 4. Number Scaling and Exponential Curves

### Cost Multiplier Conventions
The Idle Idol postmortem on Game Developer identified that a production increase of ×1.1 per level paired with a cost increase of ×1.15 per level is a reliable baseline. Cookie Clicker uses ×1.15; AdVenture Capitalist uses ×1.07. Florin Cards uses ×1.15 to ×1.38 across chore tiers — **on the steeper end**, which means each additional copy of a chore gets expensive quickly.

The effect of steeper multipliers is that players diversify sooner (buying across all unlocked chores rather than stacking one). This is generally good for Florin Cards because it provides more meaningful "hire" decisions. However, steeper multipliers also mean early chores become economically irrelevant fast. A player who invested heavily in Sibling Helpers early will feel punished when those chores barely contribute to their total fl/sec. Consider capping how quickly early chores fall behind by giving them a slight late-game boost or showing their total contribution prominently.

### A Critical Warning: Small Multiplier Differences Compound Dramatically
The Idle Idol team specifically warned: "exponentials can get out of control really fast, so even a 0.01 difference would mean a huge difference for, say, the 20th upgrade." For Florin Cards, the difference between ×1.15 and ×1.20 per purchase means that after 20 purchases of the same chore, the 20th costs 16× the base (×1.15) vs. 38× the base (×1.20). Always model cost curves in a spreadsheet across 20–50 purchases before committing to multipliers.

### Pack Cost Scaling
Pack cost scaling of ×1.8–×2.5 per 5–20 packs opened is intentionally aggressive — packs are *meant* to get harder to open, pushing players up tiers. A useful check: Basic Pack (300 fl base, ×1.8 every 20 packs) means:
- Packs 1–20: 300 fl each
- Packs 21–40: 540 fl each
- Packs 41–60: 972 fl each
- Packs 61–80: 1,749 fl each — now more expensive than Silver Pack's base cost

This is the correct design pressure to graduate players to Silver Pack. However, test whether players feel *guided* to switch tiers or *abandoned* by a pack that has priced itself out of reason.

### The "Just Out of Reach" Feeling
The ratio between current pack savings and pack cost should ideally hover between 50–80% as a resting state during active play. If the savings bar is perpetually below 20%, the pack feels impossibly far away. If it's perpetually above 90%, opening feels effortless and the anticipation is lost. Use the chore income rates and pack costs together to check this ratio at each stage of the game.

---

## 5. Offline Earnings and Session Design

### Offline Cap Conventions
Industry standard offline earnings caps range from 2–8 hours, with 4 hours being the most common in published idle games. Florin Cards' 8-hour cap is at the generous end, appropriate for a casual title where players may not open daily. An 8-hour cap rewards daily players while not catastrophically overwhelming players who return after a longer absence.

### What Offline Earnings Actually Do
Offline earnings are not primarily an economic mechanic — they are a **re-engagement mechanic**. The moment of returning to the game and seeing accumulated earnings is a dopamine event that rewards the player for coming back. This means the *presentation* of offline earnings matters as much as the amount. Florin Cards currently shows offline earnings as a line in the Field Notes log. This is too subtle. Consider a more prominent reveal — a banner or popup on launch showing "You earned X fl while away!" — to maximise the emotional reward of the return visit.

The staggered offline caps used in games like the one Eric Guan analysed are also worth considering: different income sources having different cap lengths (e.g., tapping income is not earned offline, basic chores cap at 4 hours, advanced chores cap at 8 hours). This creates a design reason for players to check in at different intervals and rewards different play frequencies.

### Session Length and Frequency Targets
Mobile idle game benchmarks suggest:
- **Median session length**: 3–6 minutes for mid-core idle games
- **Target session frequency**: 3–5 sessions per day
- **First session target**: Player opens first pack within 10–15 minutes

Florin Cards' tap button, chore management, pack opening, Floridex browsing, and upgrade purchasing together provide roughly 5–10 minutes of active content per session — correct for the genre. The game should release the player gracefully after this window (passive income takes over) and give them a clear reason to return (pack savings bar approaching full).

---

## 6. Collectible Integration with Idle Loops

### The Collection Completion Drive
Collection mechanics tap into a distinct psychological system separate from the dopamine loop: the *completion drive* and *endowment effect*. Once a player owns some cards, the missing ones become psychologically significant. The Floridex showing greyed-out unknown cards is a powerful retention tool — players will return specifically to hunt missing cards even if the idle loop itself has plateaued. This is the Pokédex principle, and it is one of the most durable retention mechanics in games.

The 76-card collection is a well-sized target: large enough to feel like a long-term goal, small enough to feel achievable. The rarity tiering (30 common → 2 secret) creates a natural hierarchy of difficulty that keeps collection interesting at every stage.

### Gacha Design Principles — Pull Rates and Pity
Research into mobile gacha design (GameRefinery, 2022) shows that **66% of the top-grossing 100 mobile games in the US feature gacha mechanics**, and the trend toward transparency around pull rates is accelerating due to regulatory pressure in multiple markets.

Two core pity mechanisms appear in all successful gacha designs:
- **Soft pity**: Pull probability gradually increases the longer a player goes without a rare result
- **Hard pity**: A guaranteed rare is delivered after a fixed number of pulls

Florin Cards currently has neither. This is acceptable for a v1 prototype, but the absence of pity means players can theoretically open many packs without pulling a rare — which is demoralising and drives D7 churn. **Recommended: implement a soft pity counter.** After 8 packs opened without a rare-or-better appearing in a rare slot, increase the rare pool weights by 10% per additional pack until a rare is pulled, then reset. This is invisible to most players but prevents the worst-case streaks.

### Dupe Management
The GameRefinery analysis highlights **box gacha** (where pulled items are removed from the pool, increasing future rare odds) as the most player-friendly dupe solution. Florin Cards uses a currency conversion approach instead (50 dupes → 100 fl), which is a valid alternative but has a high minimum threshold.

For early players who have opened 5–10 packs, having 50 dupes is unrealistic — they may have 10–15 at most. The threshold of 50 makes the dupe counter feel inert and meaningless in the first few hours. **Consider tiered selling**: allow selling in batches of 10 (for 20 fl) as well as 50 (for 100 fl), so early players can engage with the mechanic sooner.

### "One More Pull" Psychology
The most powerful retention moment in Florin Cards is the instant before a pack opens. This moment must be:
1. **Visually distinct** — the pack reveal animation should feel ceremonial, not instant
2. **Always rewarding** — even five commons should feel like something was discovered
3. **Emotionally varied** — the God Pack and Double Rare event banners must feel meaningfully different from a Normal pull; if they appear too subtly, players miss the moment

Any UI friction at the point of opening (lag, unclear button state, no animation) blunts the reward and reduces the pull's emotional value.

---

## 7. Retention Benchmarks — D1, D7, D30

### Industry Benchmarks
Current published benchmarks (Solsten, 2024; GameAnalytics Q1 2024) show:
- **D1 retention**: Top quartile of mobile games sits at 27–33% (iOS outperforms Android at 31–33% vs. 25–27%)
- **D7 retention**: Industry average ~8%; top games reach 14–20%
- **D30 retention**: Typically 10% or less across the industry; the old rule of thumb was "10% of D1" but this has compressed

A new benchmark is emerging: D1 of 50%+ is cited as the new standard for top-performing games. D1 retention has declined year-over-year from 2023 to 2024, making onboarding quality increasingly competitive.

### What Drives Each Stage
The Solsten research identifies distinct drivers at each retention stage:

**D1** is driven entirely by "how well a game delivers moment-to-moment fun" in the first session. Poor D1 is caused by: failure to discover the fun, design blockers, poor onboarding, or mismatched player expectations from marketing.

**D7** is driven by players finding "the game's progression and social features rewarding." High D1 but low D7 typically means players feel they have "completed all available content" or that grinding feels too punishing. For Florin Cards, the key D7 question is: *has the player unlocked Silver Pack yet, and have they seen their first rare pull?* Both of these are powerful D7 anchors.

**D30** is driven by player investment — both time and emotional attachment. D30 retention is a strong predictor of long-term game health. For Florin Cards, D30 players need: collection goals with clear remaining targets, long-horizon upgrade goals (the 40M fl Secret Card Map), and the emotional peaks of pulling their first Ultra Rare and Secret Rare.

### Florin Cards Specific Milestones
Map the expected timeline for a casual player (1–2 sessions/day, moderate tapping):

| Milestone | Target Timing |
|-----------|--------------|
| First chore hired | < 1 minute |
| First Basic Pack opened | < 15 minutes |
| First rare pull seen | < 1 hour total play |
| Silver Pack unlocked | Day 1–2 |
| First holo rare pull | Day 3–5 |
| Gold Pack unlocked | Day 7–14 |
| First ultra rare | Day 14–30 |
| Legendary Pack unlocked | Day 30+ |
| First secret rare | Day 60+ |
| All 76 cards collected | Long-term goal |

If any of these milestones arrives significantly later than these targets, churn risk increases sharply at that stage.

---

## 8. Common Pitfalls in Idle Game Design

### The Dead Zone
A dead zone occurs when the player has nothing to buy, no pack to open, and income is too slow to produce visible real-time change. The worst dead zones in Florin Cards would occur:
- **Before first pack** (early game — primary risk, addressed in Section 2)
- **Between pack tiers** (after Basic Pack becomes expensive but before Silver unlocks)
- **After lemonade stand unlock before babysitting** (the 3,000 → 20,000 total_earned gap is nearly 7×)
- **After completing the card collection** (no current end-game content — acknowledge this in design)

### Exponential Sensitivity
Small differences in multipliers produce dramatically different long-term curves. The Idle Idol team's warning bears repeating: a ×0.01 difference in a cost multiplier can mean the difference between a satisfying 20th purchase and an impossible one. Always model curves in a spreadsheet, not by feel.

### The Invisible Wall
Players tolerate grinding if they understand what they are grinding *toward* and why they are stuck. An invisible wall — where income growth stalls with no clear explanation — causes churn. The UI should always make the next goal clear. Florin Cards' pack savings bars do this well for pack goals. Chore unlock gates based on `total_earned` should similarly show the player *what will unlock next* even before it is reachable (e.g., a teaser showing the locked babysitting chore at "🔒 Unlock at 20K fl earned").

### Upgrade Sprawl
Too many visible upgrade options at once creates decision paralysis. Florin Cards' `total_earned` gating of upgrades prevents this correctly. Never show an upgrade the player cannot meaningfully engage with.

### The Prestige Question
Many idle games introduce a prestige/reset mechanic in mid-game as a retention layer. Florin Cards has no prestige mechanic in v1, which is correct for a first release. Prestige is complex to balance and frequently frustrating if introduced too early or poorly explained. A lighter version — where collecting all 76 cards unlocks a cosmetic "prestige" mode (golden UI, special card borders) without resetting progress — could serve as a soft end-game goal without the balance risk of a full prestige reset.

---

## 9. Case Studies

### Cookie Clicker (Orteil, 2013)
The genre-defining idle game. Key lessons: first upgrade arrives within 15 seconds; each milestone visibly changes the game state; the mid-game "grandmapocalypse" recontextualises all prior progress without resetting it; the game never explains itself — discovery is the reward. Cookie Clicker's enduring success (still actively played 12 years later) comes from layering new mechanics as surprises, not as announced features.

### AdVenture Capitalist (Hyper Hippo, 2014)
Commercialised the idle formula for mobile. Key lessons: managers (automation unlock) are the key mid-game hook that transition players from active to passive play; milestones are celebrated with confetti and fanfare; multiple currencies create a second-order economy that gives late players new goals. One of the first games to successfully implement prestige with permanent bonuses.

### Idle Miner Tycoon (Kolibri Games, 2016)
Top-grossing mobile idle game for several years. Key lessons: strong visual feedback (miners physically moving) makes passive income *feel* active; offline earnings are front-and-centre on app open with animation; mine "themes" provide cosmetic novelty without mechanical complexity. D1 retention above 45% at peak.

### AFK Arena (Lilith Games, 2019)
Idle + gacha hybrid most relevant to Florin Cards. Key lessons: heroes collected through gacha *directly improve* idle income, creating tight loop integration; faction bonuses reward collecting *sets* of characters rather than individual ones (drives collection completion behaviour); lore creates emotional attachment to specific characters that drives pull motivation. **For Florin Cards**: consider whether completing a rarity set (all 12 Rares, all 8 Holos, etc.) should unlock a persistent fl/sec bonus. This directly integrates the collection loop with the idle loop.

### Pokémon GO (Niantic, 2016)
Collection loop case study. Key lessons: the Pokédex completion drive is one of the most powerful retention mechanics ever designed; shiny variants (directly analogous to Holo/Ultra/Secret Rares in Florin Cards) are perceived as immensely valuable even with identical gameplay function; seeing *other players'* rare pulls amplifies collection motivation (future social feature consideration).

### Merge Dragons / Merge Magic (Gram Games, 2017–2019)
Idle + collection hybrid with strong D30 retention. Key lessons: limited-time events with exclusive collectibles create FOMO-driven return sessions; completing "dragon camp" goals (analogous to completing rarity sets) provides structured D7–D30 goals; the merge mechanic creates constant small decisions without overwhelming complexity.

---

## 10. Recommendations for Florin Cards Balance

Based on the above research, the following are priority areas to address when balancing:

### Priority 1 — First Pack Timing (High Impact on D1)
Target opening the first Basic Pack within 10 minutes of first play. Options:
- Grant a 50–100 fl welcome bonus on first launch
- Reduce the first Basic Pack cost to 100–150 fl (one-time only, then normal scaling resumes)
- Start the player with one Sibling Helper already hired

### Priority 2 — Soft Pity System (High Impact on D7)
Add a soft pity counter for rare slots. After 8 consecutive pack opens without a rare-or-better result in any rare slot, increase the rare pool weights by 10% per additional pack until a rare triggers, then reset. This is the single most impactful change for preventing the demoralising dry streaks that kill D7 retention.

### Priority 3 — Dupe Sell Threshold (Medium Impact, All Stages)
The 50-dupe threshold is inaccessible to early players. Add a smaller sell option: 10 dupes → 20 fl. Keep the bulk option (50 → 100 fl) for efficiency. Show the dupe counter and threshold prominently so players feel progress toward the milestone.

### Priority 4 — Offline Earnings Visibility (Medium Impact on Re-engagement)
Elevate the offline earnings reveal. On app open after an absence of 5+ minutes, show a prominent banner or notification: "While you were away, you earned X fl!" before the player sees the main screen. This is one of the strongest psychological re-engagement hooks available.

### Priority 5 — Chore Unlock Pacing (Medium Impact on Mid-Game)
The gap between lemonade stand (unlock at 3,000 total earned) and babysitting (unlock at 20,000) may create a mid-game dead zone. Test this gap in playtest and consider adding a mid-tier visual reward (a "progress to next chore" teaser) or reducing the babysitting unlock gate to ~12,000.

### Priority 6 — God Pack Presentation (Lower Impact, High Emotional Value)
The 0.1% God Pack event should feel dramatically different from a normal pack open. Consider a full-screen animation, a unique persistent Field Note entry ("⭐ GOD PACK — [date]!"), and different card reveal pacing. This is a moment players should tell other people about.

### Priority 7 — Set Completion Bonuses (Future Feature)
Completing all cards of a rarity tier unlocking a passive fl/sec bonus (e.g., +0.5 fl/sec for completing all Commons, +2 fl/sec for all Uncommons, etc.) would directly integrate the collection loop with the idle loop — the defining design pattern of the most successful gacha+idle hybrid games.

---

## Sources

| Source | URL |
|--------|-----|
| Eric Guan, *Idle Game Design Principles* | https://ericguan.substack.com/p/idle-game-design-principles |
| *Balancing Tips: How We Managed Math on Idle Idol* — Game Developer | https://www.gamedeveloper.com/design/balancing-tips-how-we-managed-math-on-idle-idol |
| *The Complete Guide to Mobile Game Gachas* — GameRefinery | https://www.gamerefinery.com/the-complete-guide-to-mobile-game-gachas-in-2022/ |
| *Taking Games Apart: How to Design a Simple Idle Clicker* — Konrad Abe, Medium | https://allbitsequal.medium.com/taking-games-apart-how-to-design-a-simple-idle-clicker-6ca196ef90d6 |
| *The True Drivers of D1, D7, and D30 Retention* — Solsten | https://solsten.io/blog/d1-d7-d30-retention-in-gaming |
| *Mobile Gaming Benchmarks Q1 2024* — GameAnalytics | https://www.gameanalytics.com/reports/mobile-games-benchmarks-q1-2024 |
| *Mobile Game Retention Benchmarks* — MAF | https://maf.ad/en/blog/mobile-game-retention-benchmarks/ |
| *How To Increase Engagement and Monetization in Idle Games in 2025* — Gamigion | https://www.gamigion.com/idle/ |
| *Idle Clicker Games: Best Practices* — Mind Studios | https://games.themindstudios.com/post/idle-clicker-game-design-and-monetization/ |
| *FTUE & Onboarding — What's in a Name?* — Mobile Game Doctor | https://www.mobilegamedoctor.com/ftue-onboarding-whats-in-a-name |
| *Soft Landing to Conversion: Onboarding Best Practices* — GameRefinery | https://www.gamerefinery.com/soft-landing-to-conversion-introducing-onboarding-best-practices-part-3/ |
| *Gacha Game Pity Systems Explained* — Epic Games Store | https://store.epicgames.com/en-US/news/gacha-games-explained-banners-pulls-pity-systems-and-more |
| *Inherent Addiction Mechanisms in Gacha* — MDPI Information Journal | https://www.mdpi.com/2078-2489/16/10/890 |
| Thaler & Sunstein, *Nudge* (2008) — behavioural economics and reward framing | — |
| Robert Cialdini, *Influence* (1984) — commitment, consistency, scarcity | — |

---

*Document compiled April 2026. Update with playtest data as balance iterations are completed.*
