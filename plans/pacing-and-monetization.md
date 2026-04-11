# Plan: Pacing, Balance & Monetization Redesign

*Research sources: Kongregate "Math of Idle Games" series, Eric Guan "Idle Game Design Principles", Kolibri Games "Economy in F2P Mobile Games", Yango Ads rewarded video research, GameDeveloper Idle Idol postmortem, GameAnalytics 2024 benchmarks.*

---

## 1. Problem Analysis — Why the Game Is Too Fast

### Root Cause

The game has two compounding problems that together make it finish in hours instead of months.

**Problem A — Income rates are too high relative to pack costs.**

With the Carwash running (800 fl/sec), the Legendary Pack costs 150,000 fl — that is **187 seconds** (3 minutes) of income. At that point a player opens Legendary Packs every 3 minutes and has seen the full card pool within a single session.

**Problem B — All pack savings pools accumulate simultaneously from Day 1.**

Currently `add_florins()` credits every pack's savings pool on every tick, regardless of whether that pack is unlocked. This means when Silver Pack unlocks at 5,000 total earned, the savings pool already contains thousands of fl — the player gets their first Silver Pack instantly, bypassing the intended saving wait entirely.

### The Numbers

| Chore | fl/sec | Pack | Cost | Time to open (at this chore) |
|-------|--------|------|------|-------------------------------|
| Carwash | 800 | Legendary | 150,000 | **3.1 min** |
| Babysit | 220 | Gold | 15,000 | **68 sec** |
| Lemonade | 60 | Silver | 2,500 | **42 sec** |
| Dog | 5 | Basic | 300 | **60 sec** |

Every tier of pack is trivially fast once the corresponding income tier is reached.

### Overnight Problem

A player who sleeps with Babysit running (220 fl/sec) earns `220 × 28,800 = 6,336,000 fl` overnight — enough for **42 Legendary Packs** before breakfast. This destroys any sense of progression or anticipation.

### Target Timelines (industry benchmark for casual idle games)

| Milestone | Target |
|-----------|--------|
| First Basic Pack | 10–15 min (session 1) |
| First Silver Pack | Day 2–4 |
| First Gold Pack | Day 10–18 |
| First Legendary Pack | Day 35–50 |
| First Legendary card | Day 50–70 |
| Full 76-card collection | 6+ months |

---

## 2. Economy Redesign

### Fix A — Reduce Mid/Late Chore Income Rates

Early chores (Sibling, Bins, Dog) stay the same — they are correctly paced for the first session. Mid and late chores need significant reductions so they don't make packs trivially cheap.

| Chore | Current fl/sec | New fl/sec | Reduction |
|-------|---------------|------------|-----------|
| Little Sibling Helper | 0.3 | **0.3** | None (early game correct) |
| Take Out the Bins | 1.1 | **1.1** | None |
| Walk the Dog | 5.0 | **5.0** | None |
| Mow the Lawn | 18 | **8.0** | −56% |
| Lemonade Stand | 60 | **20.0** | −67% |
| Babysitting Round | 220 | **60.0** | −73% |
| Neighbourhood Car Wash | 800 | **150.0** | −81% |
| Car Boot Sale Empire | 3,200 | **500.0** | −84% |

**Rationale:** Each tier is now ~3–4× better than the last (research confirms this is the correct perceptible growth ratio). Late chores are dramatically weaker in absolute terms, making pack costs meaningful even at endgame.

### Fix A2 — Increase Mid/Late Chore Base Costs Proportionally

To maintain appropriate "payback time" (how long before a chore pays for itself), costs should also increase for mid/late chores.

| Chore | Current base_cost | New base_cost |
|-------|------------------|--------------|
| Sibling | 5 | **5** |
| Bins | 30 | **30** |
| Dog | 180 | **200** |
| Lawn | 1,200 | **2,000** |
| Lemonade | 8,000 | **18,000** |
| Babysit | 60,000 | **150,000** |
| Car Wash | 500,000 | **1,500,000** |
| Car Boot | 4,000,000 | **15,000,000** |

Resulting payback times:
- Sibling: 17 sec — satisfying instant reward
- Bins: 27 sec — still very fast
- Dog: 40 sec — quick enough
- Lawn: 250 sec (~4 min) — first "wait" moment
- Lemonade: 900 sec (~15 min) — meaningful decision
- Babysit: 2,500 sec (~42 min) — significant milestone
- Car Wash: 10,000 sec (~2.8h) — late-game investment
- Car Boot: 30,000 sec (~8.3h) — endgame, overnight payback

### Fix A3 — Recalibrate Chore Unlock Gates

| Chore | Current unlock | New unlock |
|-------|---------------|------------|
| Sibling | 0 | 0 |
| Bins | 10 | 10 |
| Dog | 80 | 100 |
| Lawn | 500 | 800 |
| Lemonade | 3,000 | 6,000 |
| Babysit | 20,000 | 50,000 |
| Car Wash | 150,000 | 500,000 |
| Car Boot | 1,500,000 | 5,000,000 |

### Fix B — Pack Savings Only Accumulate After Unlock

**This is the most important code fix.** In `GameState.add_florins()`, change the savings loop so that a pack's savings pool only receives income once `total_earned >= pack.unlock_at`. This ensures players genuinely *wait and save* before opening each tier.

```gdscript
# In GameState.add_florins():
for i in range(pack_state.size()):
    if total_earned >= CardDatabase.PACKS[i]["unlock_at"]:
        pack_state[i]["savings"] += amount
```

### Fix C — Dramatically Increase Pack Costs

With savings now gating properly, pack costs can be set to match the intended grind:

| Pack | Current base_cost | New base_cost | New scale_factor | New scale_every | New unlock_at |
|------|-----------------|--------------|-----------------|----------------|--------------|
| Basic | 300 | **300** | 1.8 | 20 | 0 |
| Silver | 2,500 | **80,000** | 2.0 | 15 | **30,000** |
| Gold | 15,000 | **600,000** | 2.2 | 10 | **400,000** |
| Legendary | 150,000 | **8,000,000** | 2.5 | 5 | **4,000,000** |

**Rationale:**

- **Basic Pack** stays cheap — early game should feel candy-like. Players should open many.
- **Silver Pack at 80,000 fl** — at early-mid income (~5–10 fl/sec), this takes one to three overnight saves. First Silver Pack unlocks around Day 3–5.
- **Gold Pack at 600,000 fl** — at mid income (~30–60 fl/sec), this takes a few overnight sessions. First Gold Pack around Day 12–18.
- **Legendary Pack at 8,000,000 fl** — at late income (~150–300 fl/sec), this takes 1–2 nights per pack. First Legendary Pack around Day 40–55.

### Fix D — Upgrade Cost Rebalancing

Upgrades need to scale with the new economy.

| Upgrade | Current cost | New cost | Current unlock | New unlock |
|---------|-------------|----------|---------------|------------|
| Lucky Bag | 600 | **4,000** | 200 | 1,500 |
| Foil Sleeve | 3,000 | **25,000** | 1,000 | 8,000 |
| Magnifying Glass | 15,000 | **150,000** | 6,000 | 50,000 |
| Price Guide Book | 100,000 | **1,000,000** | 40,000 | 350,000 |
| Special Order | 700,000 | **8,000,000** | 250,000 | 3,000,000 |
| Golden Wrapper | 5,000,000 | **60,000,000** | 1,800,000 | 25,000,000 |
| Secret Card Map | 40,000,000 | **500,000,000** | 12,000,000 | 200,000,000 |

---

## 3. Milestone Multipliers (New Feature)

Industry standard (AdVenture Capitalist, Idle Miner Tycoon): when you own 10, 25, or 50 of a chore, a multiplier kicks in making it produce significantly more. This creates exciting "breakpoint" moments that reward continued investment and prevent early chores from becoming irrelevant.

**Proposed multipliers:**
- Own 10 of a chore → **×2 production bonus** (visible "10 owned!" celebration)
- Own 25 of a chore → **×5 production bonus** (cumulative with ×2 = ×10 total)
- Own 50 of a chore → **×25 production bonus** (cumulative = ×250 total)

**Implementation:** In `GameState.get_fl_per_sec()`, multiply each chore's contribution by its milestone bonus:

```gdscript
func _chore_milestone_mult(count: int) -> float:
    var mult = 1.0
    if count >= 10: mult *= 2.0
    if count >= 25: mult *= 5.0
    if count >= 50: mult *= 25.0
    return mult
```

Show a celebratory field note and brief banner when milestones are hit. These moments give players a reason to keep hiring the same chore rather than abandoning it for newer ones.

---

## 4. Modelled Progression (Sanity Check)

With the new numbers applied, rough income rates at each stage:

| Stage | Income | Overnight earnings | What you can open |
|-------|--------|-------------------|-------------------|
| D1 end | ~3 fl/sec | ~86,000 fl | Many Basic Packs |
| D3 | ~10 fl/sec | ~288,000 fl | ~3-4 Silver Packs/night |
| D7 | ~30 fl/sec | ~864,000 fl | ~10 Silver or 1.4 Gold/night |
| D14 | ~80 fl/sec | ~2,300,000 fl | ~3.8 Gold/night |
| D30 | ~200 fl/sec | ~5,760,000 fl | ~9.6 Gold or 0.72 Legendary/night |
| D60 | ~600 fl/sec | ~17,280,000 fl | ~2.2 Legendary/night |
| D90+ | ~1,500 fl/sec | ~43,200,000 fl | ~5.4 Legendary/night |

This gives the Legendary Pack stage genuinely months of play before the 76-card collection can be completed. At 2.2 Legendary Packs/night at D60, with 72% chance of a Rare in the rare slot, pulling a Legendary (1% base) takes significant grinding — exactly as intended.

---

## 5. Premium Currency — Gems

### Design Principles

- Gems are a **convenience currency**, never a pay-to-win advantage
- Pull rates are **never directly purchasable** — all players have equal card odds
- F2P players earn enough gems through play to feel included in the system
- No feature is gated behind gems — everything can be earned with time

### What Gems Can Buy

| Item | Gem cost | Description |
|------|----------|-------------|
| 2× Income Boost (30 min) | 50 gems | Doubles all fl/sec for 30 minutes |
| 2× Income Boost (2h) | 150 gems | Same but longer duration |
| Skip 4 hours of saving | 100 gems | Adds 4h × current fl/sec to a chosen pack's savings pool |
| Shiny Card Style | 200 gems | Cosmetic: applies a shiny border to a specific card in your collection |
| Extra Dupe Conversion | 75 gems | Convert 5 dupes → 20 fl (immediate, outside normal thresholds) |
| Collection Slot Unlock | — | *Future feature* |

Gems explicitly **do not** buy: packs directly, pull rate boosts, guaranteed rare slots.

### Free Gem Sources (F2P Path)

| Source | Gems | Cadence |
|--------|------|---------|
| Daily login bonus | 5 gems | Daily |
| 7-day login streak | 25 bonus gems | Weekly |
| First pack of each tier opened (4 milestones) | 50 gems each | One-time |
| Complete a rarity set (6 milestones) | 100 gems each | One-time |
| Watching a rewarded ad | 5 gems | Up to 3×/day |
| Achievement: "Open 100 packs" | 100 gems | One-time |
| Achievement: "Hire every chore type" | 75 gems | One-time |

A consistent daily F2P player earns roughly **40–60 gems/day** (5 login + 15 from ads + occasional achievements). That is enough for one 2× boost every day, or a cosmetic every 3–5 days — meaningful engagement without making premium feel mandatory.

### Gem Pricing (IAP Tiers)

| Pack | Price | Gems | Value per £ |
|------|-------|------|------------|
| Starter | £1.99 | 100 | 50 gems/£ |
| Small | £4.99 | 300 | 60 gems/£ |
| Medium | £9.99 | 700 | 70 gems/£ |
| Large | £19.99 | 1,600 | 80 gems/£ |
| Mega | £49.99 | 5,000 | 100 gems/£ |

Better value at higher tiers incentivises larger purchases while keeping entry accessible.

### Monthly Pass (£2.99/month)

- 20 gems immediately on purchase
- **10 gems per day** for 30 days (300 total over the month, vs £4.99 for 300 outright)
- Exclusive cosmetic: gold card border on all cards in your collection
- "Pass Holder" badge on collection screen

This is the single most important monetisation feature. It creates **predictable monthly revenue**, locks in retained players, and provides daily login incentive. Industry data shows monthly passes generate 2–3× more revenue per engaged player than equivalent one-off purchases.

### Starter Pack (one-time, shown on Day 1–3 only)

- £2.99 — **200 gems + 2× income boost active for 24h + cosmetic "Founder" card border**
- Only shown during the first 72 hours after install (urgency + novelty window)
- Never shown again after that window

---

## 6. Opt-In Rewarded Ads

No forced ads. Ever. All ads are player-initiated in exchange for a clear, described reward. Industry data: rewarded ads achieve 90%+ completion rates and are the highest-revenue ad format in mobile idle games ($11–20 eCPM in UK/US markets).

### Ad Placement Opportunities (shown as buttons in relevant sections)

| Placement | Reward | Limit | Cooldown |
|-----------|--------|-------|---------|
| "Watch an ad — 2× income for 30 min" | 2× fl/sec for 30 minutes | 3×/day | 30 min |
| "Watch an ad — pack boost" | Instantly add 10% of current pack cost to savings | 1×/day per pack | 24h |
| "Watch an ad — earn 5 gems" | 5 gems added | 3×/day | 30 min |

**Placement rules:**
- The 2× income button appears in the chore section, below the hire help list — only when the player is NOT currently boosted
- The pack boost button appears on each pack card, below the savings bar — only when savings < 50% of cost (player is waiting, this is the natural decision moment)
- The gems button appears in a future "Gem Store" screen

**Never show:**
- Interstitial ads (full-screen forced ads between actions)
- Banner ads during gameplay
- Ads that interrupt pack opening, card viewing, or any active moment

**Technical:** Use Unity Ads, Google AdMob, or ironSource — all support rewarded placements with inventory management. Frequency cap at platform level as backup to in-game limits.

---

## 7. Retention Mechanics to Implement

### Daily Login Bonus
Simple 7-day rotating reward visible on app open:
- Day 1: 10 fl
- Day 2: 5 gems
- Day 3: 50 fl bonus to Basic Pack savings
- Day 4: 10 gems
- Day 5: 1× free Basic Pack open
- Day 6: 15 gems
- Day 7: 25 gems + streak bonus

Resets on Day 8 (keeps the "just one more day" feeling perpetual).

### Push Notifications (future)
- "Your pack savings are full!" — when savings ≥ pack cost (strongest re-engagement trigger)
- "Your offline earnings are waiting!" — after 4h away
- "Daily reward ready" — if not logged in by noon

### Seasonal Events (future)
Themed card variants or boosted pull rates for 2-week windows (Christmas, Easter, etc.) — these create FOMO-driven return visits and spikes in both ad views and IAP conversions.

---

## 8. Implementation Order

Implement in this order. Each step makes the game more fun without requiring the next:

1. **Fix pack savings accumulation** (`GameState.add_florins()`) — highest impact, one-line change
2. **Rebalance chore fl/sec and costs** (`CardDatabase.gd`) — core pacing fix
3. **Rebalance pack costs and unlock gates** (`CardDatabase.gd`) — prevents endgame rushing
4. **Rebalance upgrade costs** (`CardDatabase.gd`) — consistent with new economy
5. **Milestone multipliers** (`GameState.gd`, `Main.gd`) — adds excitement bumps
6. **Daily login bonus** (`GameState.gd`, `Main.gd`, `SaveManager.gd`) — D7 retention
7. **Gems currency** (new systems throughout) — monetisation foundation
8. **Rewarded ads** (new ad placement buttons) — revenue layer
9. **Monthly pass / IAP** (storefront screen) — primary revenue
10. **Push notifications** — re-engagement at scale
11. **Seasonal events** — long-term live ops

---

## 9. What NOT to Change

- **Pity system** — already implemented, keep it
- **Variation system** (Normal/Shiny/Full Art) — correct, adds collection depth
- **76-card pool size** — right size for a 6-month goal
- **Dupe selling** — keep tiered system (10 and 50 dupes)
- **Card types** — visual differentiation complete
- **Offline cap at 8h** — appropriate for casual mobile, matches industry standard

---

## 10. Revenue Model Summary

| Stream | Type | Effort | Revenue potential |
|--------|------|--------|------------------|
| Rewarded ads | F2P revenue | Low | £0.08–0.15 per active DAU/day |
| Monthly pass (£2.99) | Subscription | Medium | Best LTV per payer |
| Starter pack (£2.99) | One-time IAP | Low | High conversion in FTUE window |
| Gem packs | One-time IAP | Low | Whales and occasional spenders |
| "No ads" purchase | One-time IAP | Low | Small segment, high satisfaction |

**Note on "No Ads" purchase:** Even though ads are opt-in only, offering a £4.99 "No Ads" purchase removes ad buttons from the UI entirely and grants 50 gems as a bonus. This monetises players who find any ad presence distasteful even if optional.

---

## Sources

- [The Math of Idle Games, Part I — Kongregate/Game Developer](https://blog.kongregate.com/the-math-of-idle-games-part-i/)
- [Idle Game Design Principles — Eric Guan](https://ericguan.substack.com/p/idle-game-design-principles)
- [Balancing Tips: Idle Idol — Game Developer](https://www.gamedeveloper.com/design/balancing-tips-how-we-managed-math-on-idle-idol)
- [Economy in F2P Mobile Games — Kolibri Games](https://www.kolibrigames.com/blog/economy-in-free-to-play-mobile-games-part-2/)
- [Rewarded Video Ads for Mobile Apps — Yango Ads](https://yango-ads.com/blog/rewarded-video-ads-for-mobile-apps)
- [Mobile Game Monetization 2024 — Tenjin](https://tenjin.com/blog/mobile-game-monetization-how-genre-impacts-growth/)
- [Types of Game Currencies in F2P — Game Developer](https://www.gamedeveloper.com/business/types-of-game-currencies-in-mobile-free-to-play)
- [Crafting Compelling Idle Games — DesignTheGame](https://www.designthegame.com/learning/tutorial/crafting-compelling-idle-games)
- [How to Make an Idle Game — GameAnalytics/Adjust](https://www.adjust.com/blog/how-to-make-an-idle-game/)
