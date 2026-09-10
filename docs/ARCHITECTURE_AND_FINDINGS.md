# Ageipelago — architecture and open defects

A read-through of both halves of the mod, recording how they fit together and what is currently broken.

First reviewed at `main` / `main`; re-verified at `Ageipelago` @ `0.2.3` (`901b997`) and `Archipelago` fork @ `v0.2.3` (`3f0986c9`). Protocol `6.5`, world id `2`, world version `0.0.1`.
Fact-checked in full against both trees on 2026-09-05 — every claim below was re-derived from the code, and the verdicts of that pass are folded in. Corrections to earlier drafts are marked **[corrected]**; items found during that pass are marked **[new]**.
No code was changed in producing this document — fixes listed as resolved were made by the author.

Paths are repo-relative. `age2de/` means `worlds/age2de/` in the Archipelago fork; bare paths mean this repo.

---

## 1. The two projects

| | Ageipelago | `age2de` |
|---|---|---|
| Role | Game side | APWorld side |
| Contents | 25 `.xs`, 12 `.aoe2scenario`, 2 `.aoe2campaign`, 25 `.xlsx`, 2 `.py` | 75 non-vendored `.py`, plus vendored `AoE2ScenarioParser` (13 MB) and `ordered_set` 4.1.0 (44 KB) |
| Ships as | A copy of the AoE2:DE user folder, hand-zipped | An in-tree Archipelago world |

**[corrected]** Those Ageipelago counts are of **tracked** files (`git ls-files`). On disk you will also find `Test.xs`, `default0.xs`, `default1.aoe2scenario`, `The Siege.aoe2scenario`, `XsTesting.aoe2scenario`, `Age 2 Files.zip` and two `xs-check` binaries — all gitignored — so `find` reports 27 `.xs` and 15 `.aoe2scenario`. `age2de` has **75** non-vendored `.py`, not 78.

**[corrected]** The Archipelago fork branched from `upstream/main` at `70fc3e05` on 2026-03-12 and carries **112 commits** (106 excluding merges), **all inside `worlds/age2de`** — 297 changed files, zero outside that path, so it stays a clean apworld candidate.

Be careful with the "commits behind upstream" figure: this fork's `upstream` remote is **`agilbert1412/Archipelago`, which is itself a fork**, not `ArchipelagoMW/Archipelago`. Any drift number measured against it does not describe distance from real Archipelago. The locally-fetched `upstream/main` ref is also stale (tip 2026-06-20), so the number moves depending on when you last fetched.

## 2. Why the transport looks the way it does

AoE2:DE cannot be attached to as a process — no memory reading, no scripting hook, no connector. `communication_protocol.md` (this repo) settles on AoE2's own **XS file I/O** as the IPC: binary `.xsdat` files in `<AoE2 user dir>/profile/`, polled from both sides.

The asymmetry is an engine constraint, not a design choice: a scenario may *read* any `.xsdat`, but may only *write the one named after itself*. Hence one status file per scenario, each carrying an active flag and a ping so the client can work out which mission is running.

```
AP server ──► client (CommonClient + kvui, registered at age2de/__init__.py:292-300)
                │  writes  AP.xsdat, items.xsdat, free_items.xsdat, locations.xsdat,
                │          startup.xsdat, buildings.xsdat, messages.xsdat, ATT1..JOAN6.xsdat
                ▼
        <AoE2 user dir>/profile/        ◄── 0.5 s poll, both directions
                ▲
                │  writes <scenario>.xsdat  (active, ping, protocol, worldId,
                │          lastMessageId, 12 item ids, completed, scenarioId,
                │          30 reserved ints, then location ids)
         AoE2:DE XS ──► AP.xs AP_Write(), driven by a looping "AP Ping" trigger
```

Game→client is one file; client→game is many. `AP_Read` (`AP.xs:103-120`) reads five dispatch flags and enables the matching XS rule (`ReadItems`, `FreeItems`, `MarkServerLocations`, `ReadMessages`; a units flag is read but unused).

**[new]** There is a **sixth** int after those five: `AP_Read` ends with `completed = xsReadInt();`, and the client supplies it from `campaign_handler.active_file.current_scenario.completed` (`GameClient.py:279`). So the client can write scenario-completion state *back into the running game*, which `AP_Write` then echoes out again. This is undocumented in `communication_protocol.md` and interacts with the DataStorage bitfield below — worth knowing before touching either.

Location acknowledgement is a two-flag ledger in `ScenarioLocations.xs`: the game sets `scenarioComplete`, the client echoes the id back, and the game then sets `serverComplete` to stop resending. Scenario-completion de-duplication across restarts rides on AP **DataStorage** instead — a bitfield keyed by each scenario's `completion_bit` (0-11).

### 2a. `communication_protocol.md` is stale — do not implement from it **[new]**

Section 3 below calls the packet layouts "specified in `communication_protocol.md`, hand-implemented twice". That is no longer true. The spec is a *third, divergent* description, and a reader built from it will be misaligned. Verified against both implementations:

1. **`<SCENARIO>.xsdat` reserved block.** The spec lists `CurrentUnitBufferId` + `CurrentUnitBufferRemaining` + "x27 spaces" = 29 ints. `AP_Write` writes `for (i = 0; < 30)` (`AP.xs:47-49`) and `Age2Packet.__init__` does `XsdatFile.skip_int(fp, 30)` (`GameClient.py:88`). **Both implementations agree on 30; only the spec is wrong** — following it puts the entire location list 4 bytes out of alignment.
2. **`AP.xsdat` has an undocumented leading field.** The spec's table starts at `Ping`. Both sides write and read a **`scenarioId` int first** (`AP_Read`'s scenario check at `AP.xs:69-76`; `ping_game`'s first `write_int` at `GameClient.py:269`).
3. **`AP.xsdat` flag count.** The spec lists four (`CheckItems`, `ResetItems`, `CheckLocations`, `CheckUnitBuffer`). The implementations exchange **six** ints: items, free_items, free_locations, units, messages, completed. Neither `messages` nor `completed` appears in the spec.
4. **Name mismatch.** The spec's `AP.xsdat` table refers to `reset_items.xsdat` while its own later section documents `free_items.xsdat`. The implementations use `free_items.xsdat`.
5. **`messages.xsdat` is absent from the spec entirely**, despite being a live channel with its own count-prefixed framing (`MessageHandler.py:36`).
6. The worked example still names scenarios `C1_Attila_1`; the real stems are `AP_Attila_1`. (`.gitignore` still carries the old `C1_*` paths — vestigial.)

Also note `AP_Write` fills the reserved block with the **loop counter** (`xsWriteInt(i)` → 0, 1, 2 … 29) rather than zeros or `-1`. Harmless while the units path is unimplemented, but the two live fields the spec places there would read as `0` and `1` instead of `-1` and `0`.

## 3. The coupling between the repos

There is no structural link — no submodule, no shared package, no path config. The contract is **five** duplicated conventions, and all five must be edited in lockstep:

1. **Packet layouts** — hand-implemented twice (`AP.xs` and `age2de/client/GameClient.py`). See §2a: the spec document is a divergent third copy, not the source of truth.
2. **Filenames** — `age2de/locations/Scenarios.py:33-45` hardcodes `AP_Attila_1.xsdat`…`AP_Joan_6.xsdat` (read) and `ATT1.xsdat`…`JOAN6.xsdat` (write). `age2de/locations/Campaigns.py:14-15` hardcodes `AP Attila the Hun.xsdat` / `AP Joan of Arc.xsdat`. These are exactly this repo's scenario and campaign stems — **renaming one here silently breaks the client.**
3. **Magic pair** — `protocol = 6.5` / `worldId = 2`, in `AP.xs:13-14` and `GameClient.py:26-27`.
4. **ID ranges** — see the corrected map in Group 3 below. `Scenarios.py:14` computes `campaign.value * 100 + chapter`; `AP.xs:272` recovers the scenario from a location id.
5. **[new] Pavilion placement** — `Data/VictoryPavilionLocations.json` is keyed by the same 12 scenario stems (`AP_Attila_1` … `AP_Joan_6`). A rename breaks pavilion placement too, silently, at build time rather than run time.

## 4. What each side owns

### Ageipelago

- **`AP.xs`** (314 lines) is the bridge. **[corrected]** The full include graph — the earlier draft was missing three edges and omitted `ScenarioLocations.xs` entirely:

  ```
  AP_<Campaign>_<N>.xs
    └─ AP.xs
         ├─ ItemHandler.xs
         │    ├─ ProgressionItems.xs   (leaf)
         │    ├─ MercenaryItems.xs     (leaf)
         │    ├─ ResourceItems.xs      (leaf)
         │    └─ Buildsanity.xs
         │         ├─ AP_Headers.xs
         │         │    ├─ structs.xs            (leaf)
         │         │    └─ ScenarioLocations.xs  (leaf)
         │         └─ AP_Constants.xs            (leaf)
         └─ APavilion.xs                          (leaf)
  ```

- **[corrected]** `AP_Headers.xs` declares three `mutable void` stubs so the shared library compiles — but each per-scenario file overrides only **two** of them (`InitScenarioLocations`, `GiveScenarioItems`). The third, `AP_Check_Location`, is overridden once in the shared library at `AP.xs:124-127`.
- **No trigger variables anywhere.** `xsTriggerVariable` / `xsSetTriggerVariable` appear nowhere in any `.xs` or `.py` in this repo; all state crosses via file I/O. (Grep hits only the `xs-check` binaries and this document.)
- **`Buildsanity.xs`** infers *which* building was placed by matching the resource-cost delta against known costs while watching `cAttributeValueCurrentBuildings`. Castles and Wonders use dedicated totals instead. **This is a description of intent only — see 4.1, none of it currently runs.**
- **`structs.xs`** is vendored XsStructs v1.0.0 (MrKirby / KSneijders), 776 lines, unmodified.
- **[corrected]** **`Techsanity.xs`** (681 lines) and **`Unitsanity.xs`** (571) are orphaned — never included, entry points never called. "Staged future features" understates their state: see Group 5.
- **`Scripts/__init__.py`** + **`Scripts/setup_pavilion.py`** are the build tooling: inject the looping `AP Ping` trigger, place the AP Victory Pavilion from `Data/VictoryPavilionLocations.json`, and wire `HasVictory()` / `ShowVictory()` / tech 1180 into real victory triggers.
- **`docs/Logic Requirements/*.xlsx`** — 25 hand-authored per-campaign planning worksheets, **not build inputs**; a grep for `xlsx` / `openpyxl` / `pandas` / `read_excel` across the repo returns nothing. Only Attila and Joan are implemented.
- **`age 2 files/`** is a checked-in mirror of the live AoE2 user folder. **[corrected]** `.gitignore` excludes the transport and local state, but the entries are **path-anchored, not bare globs**: `/age 2 files/mods`, `/age 2 files/savegame`, `age 2 files/profile/Player.nfp`. Only `*.xsdat` is global. The conclusion holds — the transport is entirely transient.

### age2de

- `Age2World(CachedRuleBuilderWorld)` — built on the repo-root `rule_builder` DSL, not raw `set_rule` lambdas. **No WebWorld/tutorial, no `generate_output`** (nothing is written at generation time). **[new]** There is also **no `docs/` directory** — no `en_<Game>.md` game page, no setup guide. That is the other half of the same gap, and it blocks upstream submission.
- **103 items** — **[corrected]** the breakdown: 35 buildings, 26 scenario items, 8 mercenaries, 2 campaign unlocks, 2 progressive scenarios, 12 filler `Resources`, 12 `StartingResources`, 2 `TCResources`, **3 Ages, and 1 Victory**. The last two were missing from the earlier count. Ages exist as data but are never shuffled — `create_items` skips them outright (`__init__.py:157-158`).
- **160 locations**: 125 scenario objectives + 35 building checks.
- **Regions are missions**, chained linearly per campaign off `Menu`, plus one synthetic `Can Build` region holding the building checks. (`regions/Regions.py` is an **empty file** — dead.)
- **Logic is hand-written Python** under `logic/` and `rules/`. The `.xlsx` worksheets do not drive it.
- **6 options**: `scenarioBranching`, `shuffle_buildings`, `enabled_campaigns`, `starting_campaigns`, `goal`, `startInventoryPool`. Note `goal` has exactly one choice, so it is effectively inert.
- `campaign/ScenarioPatcher.py`, `campaign/CampaignReader.py` and `campaign/xsscript/AP.xs` are **dead code** — a superseded auto-patching path. `inject_ap` is never called, and that bundled `AP.xs` is a 34-line stale fork of the real 314-line bridge (it writes a **31**-int filler block where the live `Age2Packet` expects 30, so it cannot round-trip). Only `campaign/XsdatFile.py` is live.
- **[new]** That dead patcher is the **only** importer of the vendored `AoE2ScenarioParser`, and `ordered_set` exists only to satisfy that parser. See Group 5.
- `test/` contains `bases.py` and **no `test_*.py`**. `bases.py` is the unmodified APQuest template — its comments reference test files that do not exist.

---

# Resolved in 0.2.3

| # | What it was | Fixed by |
|---|---|---|
| 1.1 | `xsGetFileSize()` returns bytes; `AP.xs` used it as an element count | Ageipelago `901b997` — `/ 4` at `AP.xs:219` and `:264`, and at `AP.xs:139`, `ItemHandler.xs:28`, `ItemHandler.xs:40` (five sites, all consistent) |
| 1.2 | `items.xsdat` carried a count prefix that `ReadItems` never skipped | `9362e139` — count removed from `send_items`; the file is now a bare id stream. (`messages.xsdat` still prefixes a count, by design, and its XS reader expects it.) |
| 2.1 | `continue` with no `await` on an invalid ping starved the event loop | `e0f7542a` — `await short_sleep()` added |
| 2.2 | `scenario_completion_key` built while `team`/`slot` were still `None` | `986a10d7` — moved into `_handle_connected` |
| 2.3 | Class-level handler dicts meant `disconnect()` never reset state | `9989ae96` — dicts built in `__init__` |
| 2.5 | `update_packet` tested the old packet's `location_ids` | `5ad03103` — now `new_pkt.location_ids` |
| 2.6 | A clean server close bypassed `disconnect()` entirely | `9362e139` + `ce1b5710` — `connection_closed` override now covers clean closes, exceptions and failed connects |
| 2.7 | `Age2Packet.item_ids` was a shared class-level list | `c9f7f3bd` — moved into `__init__` |
| 2.9 | `sync_scenario_items` mutated a module-global list every tick | `08b3caa3` — builds a new list per call |
| 2.10 | `main()` never awaited `ctx.shutdown()` | `236f1af2` — restored at `ApClient.py:183` |
| 2.11 | `read_packet` always opened the campaign file | `3f0986c9` — new `ActiveFile` captures `read_file_name` at detection |
| 2.8 | `_handle_set_reply` acted on every notified key, so a hint `SetReply` ran the completion handler — `None & int` → `TypeError`, reported as a lost connection | `facefe98` — `if args["key"] != self.scenario_completion_key: return`. Fully closed: `_handle_connected` also sends `Set` with `"default": 0`, so the key is guaranteed to exist as an int before any `SetReply` on it arrives. |

All twelve re-verified as genuinely fixed in the current tree.

**[corrected] 2.6 is not quite a "single choke point".** `connection_closed` is the override and `CommonClient.py:906` calls it from `server_loop`'s `finally`, which is the right shape. But `main()` also awaits `ctx.game_ctx.disconnect()` directly at `ApClient.py:181`. Harmless — the second call short-circuits on the reset `user_folder` — but the claim as previously written was one call site short.

**2.4 — retracted, not a bug.** An earlier draft claimed a reconnect mid-scenario dropped two chat messages via `MessageHandler`'s reset counters. Confirmed by the author as not reproducible. One piece of it is still worth keeping: `AP.xs:15` initialises `lastMessageId = -1`, and `is_packet_up_to_date` depends on that being below any real message id. **The `-1` sentinel is load-bearing — do not normalise it to 0.**

Also worth recording for whoever reads `connection_closed` next: it is reached from `server_loop`'s `finally`, so it covers clean closes, exceptions, and connects that never succeeded. `handle_connection_loss` is *not* a viable place for this — it is only called from the `except` branches at `CommonClient.py:886-904`, and a clean close raises nothing. **But see 2.19** — awaiting the game loop from inside that `finally` has a failure mode of its own.

---

# Open defects

Numbering is stable and matches the resolved table above; gaps are resolved items. Items 2.19-2.23 and the additions to Groups 3-5 come from the 2026-09-05 fact-check.

## Group 2 — Client (`age2de/client/`)

### 2.16 Reconnect replays the item window — **by design**; `GiveResource` is the one casualty. `GameClient.py:150`, `AP.xs:216-228` **[reclassified — author intent]**

*(line corrected from `:149`. Previously filed as a client defect with "persist `acked_items` across reconnects" as the fix. That is **wrong** and contradicts the design — do not do it.)*

`disconnect()` rebuilds `ClientStatus` (`GameClient.py:150`), so `acked_items` returns to 0 while `unlocked_items` is repopulated in full from AP's `ReceivedItems` resend, and `send_items` re-sends the window from index 0.

**This is intended.** Every item must be capable of infinite resending — repopulating both `acked_items` and `unlocked_items` on reconnect is the mechanism that guarantees a save/load or a dropped connection cannot strand an item in the game. The client is behaving correctly.

The consequence is on the XS side. `ReadItems` only skips a slot when `xsArrayGetInt(itemArray, i) != -1`, and `FreeItems` has already cleared the slots the client previously acked — so re-sent items land in freed slots and are granted again. `GiveProgressionItem` sets bool flags and is idempotent, as are buildings, startup resources, scenario items and mercenaries (which re-sync wholesale every tick through their own files anyway). **`GiveResource` is not idempotent**, so the player gains resources on each reconnect.

Filler `Resources` (ids 1-12) are therefore the **sole** casualty, and this is a known accepted state.

**Fix (XS side, when the time comes):** make resource grants idempotent — have XS track which item ids it has already granted, rather than relying on the client's 12-slot sliding window to de-duplicate. That is the same change 2.17 and 2.20 want, and it is the only fix that respects the resend design. Nothing on the client should change.

### 2.17 `ack_items` over-advances the send window, losing items. `GameClient.py:204-207`

```python
for item in self.current_packet.item_ids:
    if item != -1 and self.client_status.acked_items < len(self.client_status.unlocked_items):
        self.client_status.acked_items += 1
```

One increment per occupied slot **per tick**, with no de-duplication. Cadence makes that fire repeatedly on the same items: `AP Ping` (`Scripts/__init__.py:21-25`) is a looping trigger with **no condition**, so `AP_Write()` runs every scenario tick and the ping (`xsGetGameTime()`) changes each time — meaning almost every client poll is a fresh non-`REPEAT` packet.

**[corrected]** The earlier draft said `FreeItems` "only clears slots once per second". The mechanism is different: all four dispatch rules end with `xsDisableSelf()` (`AP.xs:228, 252, 278, 314`), so they are **one-shot** — `minInterval 1 / maxInterval 1` only bounds how soon after the client re-arms a rule it may fire. Cadence is therefore *at most* once per second **and** gated on the client setting the flag, which makes the window-overrun worse, not better.

With 20 items unlocked:

1. Tick 1 — 12 slots occupied → `acked_items` 0 → 12. Correct.
2. Tick 2, before `FreeItems` has run — same 12 slots → `acked_items` 12 → 20.

Items 12-19 were never sent, but the window has passed them. `send_items` computes `20 - 20 = 0`, and `acked_items` never decreases, so **they are lost permanently**.

Buildings, startup resources, scenario items and mercenaries are re-synced wholesale every tick through their own files and self-heal. The casualties are items delivered *only* via `items.xsdat` — filler `Resources` (ids 1-12), which are exactly the non-idempotent `GiveResource` ones. (`Age` items would also be exclusive to this channel, but they are never placed in the pool, so they cannot be lost.)

**Unlike 2.16, this one is unambiguously a bug.** Infinite resending is the design; *losing* an item permanently is not. A player who is owed 20 filler resources and receives 12 has no way to recover the other 8 — no reconnect helps, because `acked_items` has already passed them and never decreases.

**Fix:** ack by item id rather than by slot count — or, better, drop the sliding window entirely and have XS track which ids it has granted. The XS-side version is the one to prefer: it fixes 2.17, removes 2.20's amplification, and makes 2.16's intended replay harmless in one change.

### 2.18 `deactivate_scenario` no longer clears the campaign file. `CampaignHandler.py:154-160`

Introduced by 2.11's fix, which is otherwise the right shape. `deactivate_scenario` previously wrote `False` over **both** the campaign and the scenario read file; it now writes only `active_file.read_file_name` — whichever detector captured it. More correct in intent, but it removes an accidental safety net.

`find_active_campaign` runs *before* `find_active_scenario` in `status_loop` (`GameClient.py:301-311`, and again in the paused re-detect at `:314-320`), so a stale active flag left in a campaign file wins detection. Nothing clears these on a fresh connect — `connect()` (`GameClient.py:134-139`) does not call `flush_files()`, since the earlier refactor dropped the flush that used to live in `_handle_connected`. `flush_files()` is now reached only from `disconnect()` and the scenario-switch branch.

Repro: play a campaign mission, kill the game without exiting cleanly, restart the client, launch a **standalone** scenario. `find_active_campaign` matches the stale campaign file, and the client reads the wrong one.

**Fix:** call `flush_files()` from `connect()` — its `campaign_handler.try_flush_from_folder()` (`CampaignHandler.py:183-191`) already deletes both scenario read/write files and every campaign read file, so this is sufficient. Or restore the two-file clear in `deactivate_scenario`.

### 2.19 `await self.game_loop` re-raises into `connection_closed`'s `finally`. `GameClient.py:145-146` **[new]**

```python
if self.game_loop != None:
    await self.game_loop
```

`asyncio` stores an exception on a failed task; awaiting it re-raises. `disconnect()` is called from `connection_closed` (`ApClient.py:135-137`), which `CommonClient.py:906` invokes inside `server_loop`'s `finally` — so the exception escapes the `finally`, and the auto-reconnect block at `CommonClient.py:907-911` never runs.

Any `status_loop` crash therefore does more than kill the status loop: it kills the server task and disables reconnect. The regression note at the end of this document anticipates a *hang* here; the raise case is the likelier one and is entirely unhandled.

**Fix:** wrap the await — `try: await asyncio.wait_for(self.game_loop, timeout=5) except Exception: logger.exception(...)`. That covers both the hang and the raise.

### 2.20 `_handle_received_items` ignores `args["index"]`. `ApClient.py:95-105` **[new]**

`CommonClient.py:1047-1060` resets `ctx.items_received = []` when `start_index == 0`, and skips appending entirely when `start_index != len(ctx.items_received)` (it requests a `Sync` instead). `Age2Context` appends unconditionally in both cases.

The *replay* this causes is fine — that is 2.16's intended behaviour. The problem is that the entries are **duplicated permanently**: a mid-session resync leaves `unlocked_items` holding two copies of every item, so `len(unlocked_items)` doubles and stays doubled. That matters for three reasons:

1. It inflates the denominator `ack_items` and `send_items` both test against, giving 2.17 more room to over-advance.
2. The same item is now sent twice inside a single 12-slot window, multiplying the resource casualty rather than merely repeating it once.
3. It grows without bound across repeated resyncs.

**Fix:** honour `args["index"]` — clear `unlocked_items` when `index == 0`, mirroring what `CommonClient` does to `items_received`. The XS-side granted-id tracking from 2.17 would make the resource symptom harmless, but the unbounded list still wants fixing on its own.

### 2.21 An empty status file reads as "active". `CampaignHandler.py:134-137` **[new]**

```python
with open(self._user_folder + scenario.data.xsdat_read_name, "rb") as fp:
    active = fp.peek(1)[:1]
    if (active != b'\x00'):
        self.active_file = ActiveFile(...)
        return
```

For a zero-length file, `fp.peek(1)[:1]` is `b''`, and `b'' != b'\x00'` is `True` — so a truncated or empty `AP_*.xsdat` is adopted as the active scenario. `read_packet` then throws, returns a default `Age2Packet`, and `status_loop` `continue`s on `ping == -1` **forever**: `active_file` stays set, so the re-detection branch at `:301` never runs again. Livelock, with no output beyond a `print(ex)`.

`find_active_campaign` has the same `b''` test but survives it, because `skip_int` then throws inside its `try`.

**Fix:** test `active == b'\x01'` (or check file size first).

### 2.22 `update_packet` commits failed reads before the sanity check. `GameClient.py:193` **[new]**

`self.current_packet = new_pkt` runs on every call — including the default `Age2Packet()` that `read_packet` returns from its `except`. The `current_ping_id == -1` guard is 140 lines later at `:333`.

A torn read therefore wipes `item_ids` and `location_ids` and resets `current_ping_id` to `-1`, so the next real packet can never be classified `REPEAT`. Torn reads are expected, not hypothetical: the client polls at 0.5 s a file the game rewrites every tick, and **neither side uses atomic writes** — every client writer opens plain `"wb"` truncate-in-place (`:198`, `:215`, `:228`, `:239`, `:268`, `BuildingHandler.py:36`, `CampaignHandler.py:174`), so XS can equally read a half-written file.

Related: `Age2Packet.__init__` reads location ids until EOF with no validation, and `status_loop:380-382` forwards them straight to `on_location_received` → `LocationChecks`, and into `ctx.checked_locations` — which is the *same set object* `CommonContext` uses. A torn read injects garbage ids into both.

### 2.23 The 60-second disconnect branch is unreachable. `GameClient.py:346-356` **[new]**

At `packet_repeat_count == 10` the code calls `deactivate_scenario()`, which sets `active_file = None`. The next iteration therefore takes the `:301` re-detection branch — and since `deactivate_scenario` just wrote `False` over the file, detection fails and `:306-307` (`await long_sleep(); continue`) runs before the counter can advance. `packet_repeat_count` is pinned at 10, so `if ctx.packet_repeat_count == 120:` and its warning are dead code.

Relatedly, `deactivate_scenario` opens the *game's own output file* with `"wb"` and truncates it after only 5 seconds of no ping — recoverable only because `AP_Write()` recreates it every tick.

### 2.12 `check_victory` fails open. `CampaignHandler.py:73-80`

*(lines corrected from `:61-68`)*

If no campaign has `must_beat` set, every iteration `continue`s and the function returns `True` → instant goal on the first tick. It works today only because `fill_slot_data` emits `"<Campaign Name>_unlocked"` (`__init__.py:281-282`) and `setup_victory_requirements` matches on key **presence**, not value — which is the correct intent (beat all *included* campaigns, not just starting ones). Any key-name drift silently wins the game.

### 2.13 `FolderHandler._user_folder` has no default. `FolderHandler.py:2`

Annotation only; `__init__` is `pass`. `MessageHandler.is_message_sending` (`:55`) is called from `try_write_to_folder:29` **outside** its `try` block, so an unset folder would raise an uncaught `AttributeError` inside `status_loop`.

**[corrected] Downgraded to latent.** No reachable path was found in this revision: `status_loop` is only ever started by `try_startup_game_connection()`, called from `connect()` *after* `update_game_user_folder()`; and `disconnect()` rebuilds the handlers strictly after `await self.game_loop` returns, with no `await` in between for the loop to observe. The missing guard is real and worth fixing, but "silently kills the `status_loop` task" is not demonstrable as written. Note that if it *did* fire, 2.19 makes the consequence worse than a dead loop.

### 2.14 `read_string` never returns. `campaign/XsdatFile.py:15-17`

Unpacks the value and discards it. Unused anywhere in the world — the definition is the only occurrence. (It also shadows the builtin `len`, harmlessly.)

### 2.15 Dead or malformed declarations

*(line numbers refreshed)*

- `CampaignHandler.py:44` — `_victory: False` is an annotation whose *type* is `False`, not an assignment. Unused.
- `ManagedScenarioItem.unlocked` (`CampaignHandler.py:15`) and `ManagedBuilding.unlocked` (`BuildingHandler.py:12`) are bare class attributes on `@dataclass`es, not fields. Assignment works (it creates an instance attribute) but `__init__`/`__repr__`/`__eq__` ignore them — two items with the same `data` compare equal regardless of unlock state.
- `Age2Context.victory: bool` (`ApClient.py:46`) declared, never used.
- `unlock_scenario` (`CampaignHandler.py:94-95`) is a `pass` stub, never called.
- `__add_campaign_to_folder`, `__add_scenario_to_age2campaign`, `__update_age2campaign_json` (`:193-199`) are stubs missing `self`.
- `args = parser.parse_args()` (`ApClient.py:171`) is assigned and never used, so `--connect` / `--password` are ignored in favour of the `main()` parameters — and `main()` is launched with no arguments from `__init__.py`, so both are always `None`. This is the leftover half of 2.10.
- `PacketStatus.ERROR` is defined and never used.

## Group 3 — Generation (`age2de/`)

### 3.1 Attila 3-6 progression and the goal are logically free. `rules/Rules.py:45-49` **[new]**

`Rules.set_rules` creates a `"Complete <scenario>"` event in each victory scenario's region granting `"<scenario>: Unlock Next Scenario"`, with **no access rule**:

```python
region.add_event("Complete " + value.scenario.scenario_name, value.scenario.scenario_name + ": Unlock Next Scenario", show_in_spoiler=False)
```

Only **8 of the 12** scenario rule classes then attach a rule to that event: `Attila1Rules.py:61`, `Attila2Rules.py:33`, and `joan_1.py` through `joan_6.py`. **`Attila3Rules`, `Attila4Rules`, `Attila5Rules` and `Attila6Rules` do not.** They set rules on the `ATT3_VICTORY`…`ATT6_VICTORY` *locations* but never on the event, so the unlock item — and therefore `GoalLogic.completed_all_campaigns()`, which requires every `": Unlock Next Scenario"` item — is obtainable with nothing but region reachability.

The entire combat logic for Attila 3-6 is bypassed for progression and for the goal. **This is the highest-impact generation bug and one of the cheapest to fix** — four missing `set_rule` calls.

### 3.2 `smart_add_starting_resources` can hang generation forever. `__init__.py:210-221` **[new]**

```python
while locations_to_fill > 0:
    ...
    if worst_case_sum > locations_to_fill:
        wood_amount = wood_amount / 2
        ...
        continue
```

The `continue` branch never decrements `locations_to_fill`. Halving floats never reaches 0, and `ceil(x/N)` for any `x > 0` is `>= 1`, so `worst_case_sum` bottoms out at **4** and never goes lower. If `locations_to_fill` is 1, 2 or 3, the condition is permanently true → **infinite loop**. (`locations_to_fill == 4` lands in the discard branch below.)

### 3.3 Every unique building is skipped. `__init__.py:105`, `locations/Civilizations.py:14-15` **[new]**

`Age2CivData` initialises both `excluded_buildings` and `included_buildings` to `[]`, and `locations/connections/CivilizationBuildings.py` only ever assigns `excluded_buildings`. So:

```python
if Buildings.BuildingOption.unique in building.building_options and not any(building in civ.included_buildings for civ in self.included_civs):
    continue # No civs with this unique building are included.
```

is **always true** for unique buildings. Every unique building (Folwark, Mule Cart, Pasture, Harbor, Caravanserai, Feitoria, Settlement, Fortified Church, Krepost, Donjon) is unconditionally skipped, making the `unique` value of `shuffle_buildings` a dead option.

### 3.4 `Logic.__init__` builds scenario logic against a partially-filled list. `logic/Logic.py:31-39` **[new]**

Each `scenario.logic(self)` calls `logic.can_build_base()` during construction, and `Logic.can_build_building` ORs over `self.scenarios` starting from `False_()`. On a clean process the **first** scenario is constructed against an empty `self.scenarios`, so its `can_build_base()` collapses to a constant `False`; each later scenario sees a different-sized prefix. Because `scenarios` is class-level (3.5), the prefix contents also depend on which slots generated earlier — so the resulting logic is order- and slot-dependent.

Related: every `ScenarioRules` subclass builds a **second, independent** `ScenarioLogic` (e.g. `Attila1Rules.py:15`). Per-location rules use that one; `Logic.can_build_building` uses the first. They are never reconciled.

### 3.5 Class-level mutables **[corrected]**

`__init__.py:54-56` declares `included_civs`, `included_campaigns` and `shuffled_buildings` as class attributes, and `__init__` does not reset them.

- `included_civs` — **leaks.** `__init__.py:91-92` appends to the class list.
- `shuffled_buildings` — **leaks.** `__init__.py:111` appends.
- `included_campaigns` — **does not leak.** It is *rebound* at `:71` and `:74` (`self.included_campaigns = ...`), which creates an instance attribute. The earlier draft was wrong on this one.

Same real pattern at `rules/ScenarioRules.py:21` (`locations` dict, shared by all 12 instances and across players) and `logic/Logic.py:29`.

Concrete consequence: with two Age2 slots, `shuffled_buildings` accumulates. `rules/BuildingRules.py:20-22` then calls `get_location(...)` for a building that has no location in slot 2 → `KeyError` → generation crash. `__init__.py:166` similarly pushes building *items* into slot 2's pool, unbalancing it.

Compounding this, `ScenarioRules.__init__:29-32` uses a bare `except:` that catches `KeyboardInterrupt`/`SystemExit` and any genuine bug, prints to stdout, and leaves a **stale entry from a previous player** in that shared dict — so a later lookup can hand another player's `Location` object to `set_rule`.

### 3.6 Remaining generation defects

- `__init__.py:70-74` — an empty `enabled_campaigns` assigns `.default`, a set of **strings** (`{"Attila the Hun"}`), while the else-branch yields `Age2CampaignData` members of a plain `Enum`; `CAMPAIGN_TO_SCENARIOS[campaign]` at `:79` then raises `KeyError`.
- `__init__.py:87` — `first_scn` is referenced inside the `except StopIteration` block that its own assignment raised from → `UnboundLocalError` masks the intended `OptionError`. Currently unreachable (every campaign has 6 scenarios, and the `KeyError` above fires first), but wrong.
- `__init__.py:222-231` — `smart_add_starting_resources`, `worst_case_sum == locations_to_fill` branch: calls `create_item` in four loops, never appends, returns an empty list. **[corrected]** The pool does *not* come up short — `__init__.py:182-187` recomputes and tops up with `create_filler()`. The real effect is that the intended `+250 Starting …` items are silently replaced by random filler.
- `logic/building_logic.py:27,30` — `if building == (A or B)` evaluates to `A`. `Age2BuildingData` is an `IntEnum` with no zero-valued member, so it short-circuits every time. **Stable never requires Barracks; Market never requires Mill.** (Archery Range→Barracks and Farm→Mill still work.)
- `logic/age_logic.py:57-58` — `has_age()` returns `True_()` unconditionally, so every age gate in the military logic is a no-op. The `Feudal`/`Castle`/`Imperial Age` items are never required by anything — and are never created either (`__init__.py:157-158`).
- `rules/AgeRules.py:23-24` — `AgeRules.set_rules` is `pass`, and is still called from `rules/Rules.py:64`. **[corrected]** `TwoBuildingsRequirement` is **not** unused — it is defined at `AgeRules.py:26-27` and drives `two_from_dark_age` / `two_from_fuedal_age` / `two_from_castle_age` in `logic/age_logic.py:25,34,42`.
- `Options.py:63,71` — `StartingCampaigns` and `EnabledCampaigns` share `display_name = "Enabled Campaigns"`.
- `rules/Rules.py:38-39` — `get_entrance` has no `return`; always `None`. Unused, but a trap.
- `rules/Rules.py:47-48, 53` — two orphaned `Location` objects. Constructing a `Location` does not register it with its region, and neither is appended to `region.locations`. `victory_loc` creates and locks an item that vanishes; the `"Victory"` one passes address `0`, which collides with the `VICTORY` item id.
- `__init__.py:82-92` — the first scenario's civ is never added to `included_civs`: `first_scn` is consumed by `next(scenarios)` before the loop that appends. It only works because chapters 2-6 share the civ.
- `items/Items.py:174` — `TOWN_CENTER_STONE` is typed `TCResources(Resource.FOOD, 100)`. Named "Stone", carries food.
- `locations/Ages.py:20` — `Age2AgeData.DARK` has `item = None`.
- Stray prints on the generation path: `__init__.py:186`, `rules/ScenarioRules.py:32`, `__init__.py:287`.

### 3.7 Corrected ID map **[corrected]**

The earlier draft's ranges were wrong in four ways. Actual map (`items/Items.py`):

| Range | Category |
|---|---|
| `0` | `VICTORY` — **not** a resource |
| `1-12` | filler `Resources` |
| `13-24` | `StartingResources` |
| `26-28` | `Age` items (omitted previously) |
| `200-234` | Buildings |
| `1000-1001` | `TCResources` |
| `1002-1023` | `ScenarioItem` |
| `3000-3001` | Progressive scenarios (omitted previously) |
| `3500-3501` | Campaign unlocks (omitted previously) |
| `4000-4003`, `4007-4010` | Mercenaries |
| `4004-4006`, `4011` | `ScenarioItem` — **not** mercenaries |

Location ids are `<campaign><chapter><NN>` as described (`ATT1_VICTORY = 10100`, `JOAN6_VICTORY = 20600`). Note `Scenarios.py:14`'s `campaign.value * 100 + chapter` computes the *scenario* value, not the location id.

## Group 4 — XS

### 4.1 `Buildsanity` is entirely dead code, and grants a free Castle check. `Buildsanity.xs:71` vs `:279-283` **[corrected — the earlier draft had this backwards]**

The earlier draft said "the attribute is declared `CastlesBuilt` and read/written as `castlesBuilt`; the castle check likely never fires." The case mismatch is real. **The effect is the exact opposite, and it disables the whole feature.**

```
:71    defineStructAttribute("Buildsanity", "CastlesBuilt", TYPE_FLOAT);
...
:279   if (castlesBuilt > structGetFloat(buildsanity, "castlesBuilt")) {
:280       structSetFloat(buildsanity, "castlesBuilt", castlesBuilt);
:281       AP_Check_Location(218);
:283       return;
```

These are XsStructs names, not engine attributes, resolved by ordinary case-sensitive XS string equality (`structs.xs:119-127`). The lookup fails, and `structGetFloat` returns **`-1.0`** on failure (`structs.xs:663-671`). `castlesBuilt` comes from `xsPlayerAttribute(1, cAttributeTotalCastlesBuilt)` and is always `>= 0.0`. So `castlesBuilt > -1.0` is **always true**, from the very first tick.

Consequences, in order:

1. `AP_Check_Location(218)` — the **Castle** location — is marked complete on the first `BuildsanityChecks` tick of every scenario, before the player builds anything. **Free check.**
2. `structSetFloat` also fails and writes nothing, so the state never latches — it re-fires every tick.
3. The `return` at `:283` short-circuits **everything below it**: the Wonder check, the `updateCosts` no-change branch, and the entire cost-delta building-inference engine. **None of the other 34 building locations can ever be checked.**

**Fix:** one capital letter at `:71` or `:279-280`. Fix 4.2 at the same time — it is currently masked by this.

### 4.2 Stray `;` discards the last gate term. `Buildsanity.xs:200-211`, `:213-224`

In both `getGatesCount` and `getPalisadeGatesCount`, a `;` terminates the initialiser after the `…VerticalId` term, leaving the `…VerticalOpenId` call as a discarded expression statement. Open vertical gates are never counted.

Latent today — both functions are only reachable past 4.1's early `return` — and goes live the moment 4.1 is fixed.

### 4.3 `FreeItems` frees the wrong slots — a cross-repo defect. `AP.xs:245-249` + `GameClient.py:239-244` **[corrected]**

The XS half is as previously described: the inner `for (j = 0; < 12)` indexes `itemArray` with `i`; `j` is never read, so the loop is a 12× repetition of an idempotent operation and degenerates to "free slot `i` iff `free_items[i] == itemArray[i]`" — a positional match, not the id search the name implies.

**The other half is in the client**, and the earlier draft missed it:

```python
def free_items(self) -> None:
    with open(self.user_folder() + "free_items.xsdat", "wb") as fp:
        for item in self.current_packet.item_ids:
            if item != -1:
                XsdatFile.write_int(fp, item)
```

The client **compacts** — it writes only non-`-1` ids. So `free_items.xsdat` holds N ≤ 12 ints with no positional correspondence to the game's 12-slot array, while XS reads exactly 12 ints regardless of the file's actual length (over-reading past EOF when N < 12). Whenever any slot is empty, the positions no longer line up, the wrong slots survive, and the corresponding items are never re-granted.

**Fix:** use `j` in the inner loop, making it the id search it was meant to be. That is correct *because* the client compacts, and needs no client change.

### 4.4 `AddLocations` off-by-one. `ScenarioLocations.xs:49-55` **[severity corrected]**

`arrayLength = idEnd - idStart` but the loop runs `<= idEnd`. For `AddLocations(10100, 10116)`: the array has valid indices `0..15`, the loop runs 17 times, and the final write is to index 16 — one past the end. Correct expression is `idEnd - idStart + 1`.

**Lower severity than implied.** Every caller discards the returned array; the authoritative registration happens inside `AddLocation`, which writes into the 200-slot `"ap-locations"` array via a separate `newLocationAddress` cursor. This is a bad write into a throwaway, not lost locations.

### 4.5 Five Attila scenarios check location ids they never register **[new]**

| file | registered | highest check | never registered |
|---|---|---|---|
| `AP_Attila_1.xs:5` | `10100, 10116` | `10120` | 10117-10120 |
| `AP_Attila_2.xs:5` | `10200, 10208` | `10214` | 10209-10214 |
| `AP_Attila_3.xs:5` | `10300, 10315` | `10318` | 10316-10318 |
| `AP_Attila_5.xs:5` | `10500, 10503` | `10505` | 10504-10505 |
| `AP_Attila_6.xs:5` | `10600, 10611` | `10612` | 10612 |

Attila 4 and all six Joan missions are consistent. Calling one of the 16 orphans (the `Defeatsanity*` functions) hits `GetLocationById` → `xsChatData("Location Not Found: %d")` → `cInvalidVector` → the missing-`return` guard in 4.6 → a silent failed write.

**Not seed-breaking:** the AP world defines no locations beyond the registered ranges either (`ATT1` stops at 10116, `ATT5` at 10503), so these are staged `Defeatsanity` calls leaking into shipped code, not unreachable AP checks. The player sees raw "Location Not Found" in chat.

### 4.6 All four `ScenarioLocations` accessors act after detecting not-found. `ScenarioLocations.xs:94-128` **[new]**

```
void SetScenarioLocationComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("SetScenarioLocationComplete: Location does not exist: %d", locationId);
    }

    structSetBool(location, "scenarioComplete", true);
}
```

The guard chats but has no `return`, so the operation runs on an invalid instance anyway. Identical shape in all four accessors. Non-fatal only because XsStructs validates and returns `false` — and it is reachable today via 4.5.

### 4.7 `ReadItems` can index past the item array. `AP.xs:220`, `:176` **[new]**

`ReadItems` loops `itemCount` times, derived from the file size, but indexes `itemArray`, which is created as exactly 12 elements (`AP.xs:176`). An `items.xsdat` longer than 48 bytes drives `xsArrayGetInt`/`xsArraySetInt` out of bounds. `FreeItems` hardcodes `< 12` and is safe.

### 4.8 Rules stay armed when their file is missing. `AP.xs:216-218, 237-239, 261-263, 286-288` **[new]**

The early `return` on a failed `xsOpenFile` skips the trailing `xsDisableSelf()`, leaving the rule armed and re-polling a missing file every second indefinitely.

### 4.9 `AddLocation` has no bound. `ScenarioLocations.xs:24-42` **[new]**

`newLocationAddress++` with no check against the 200-slot array. Fine today (~17 scenario + 35 building locations), but unguarded.

### 4.10 `ItemHandler` resource dispatch has no lower bound. `ItemHandler.xs:9` **[severity corrected]**

`if (itemId < 25) GiveResource(itemId)` — so `-1` and `0` route into the resource path. **The claimed harm does not follow:** `ResourceItems.xs:97-172` is a bare `switch(itemId)` with cases `1`-`24` and **no `default`**, so `-1` and `0` fall through silently and grant nothing. A missing guard worth tidying (`itemId > 0 && itemId < 25`), not an active defect.

### 4.11 `AP_Write` leaks a 200-element array every tick. `AP.xs:50`, `ScenarioLocations.xs:74-92` **[new]**

`FilterCompletedNotSent` creates a fresh unnamed `xsArrayCreateVector(200, cInvalidVector)` on every call and nothing frees it. `AP_Write` is driven by the unconditioned looping `AP Ping` trigger — i.e. every scenario tick. Over a mission that is tens to hundreds of thousands of never-reclaimed arrays. Same pattern at `Buildsanity.xs:32` (called from a `highFrequency` rule) and `ScenarioLocations.xs:50`.

### 4.12 The send loop does ~180 failing struct lookups per tick. `AP.xs:51-57` **[new]**

`FilterCompletedNotSent` returns an array that is always 200 long regardless of how many entries were filled (it tracks the fill count in a local `j` but does not return it), so the tail is `cInvalidVector`. `AP_Write` iterates all 200, calling `structGetInt` on each. Every failure builds two diagnostic strings (`structs.xs:333-338`, `:643`), one of which concatenates four fragments plus two float-to-string conversions — roughly 200 × 10 string allocations per tick, purely for messages nobody reads. `GetLocationById` and the filter loop itself have the same shape.

**Fix:** return the fill count, or `break` on the first `cInvalidVector`.

### 4.13 Numeric promotion on both victory-tech calls **[new, linter-derived]**

`xs-check` reports `[109] NoNumPromo` at `AP.xs:182` and `APavilion.xs:7` — both pass an `int` constant into `xsEffectAmount`'s `float amount` parameter:

```
xsEffectAmount(cModifyTech, victoryTech, cAttrSetState, cAttributeDisable);
xsEffectAmount(cModifyTech, victoryTech, cAttrSetState, cAttributeForce);
```

Per the linter, intermediate ints are not promoted, so the disable-at-init and force-at-victory on tech 1180 may not apply as intended — and 1180 is exactly the tech `AP Declare Victory` tests (`setup_pavilion.py:100`). Every other `xsEffectAmount` in `Buildsanity.xs` correctly uses `1.0`/`0.0` literals.

*Flagged as linter output rather than confirmed by reading; worth a runtime check.*

### 4.14 Corrections to earlier XS claims **[corrected]**

- `AP_Read` does **not** "hard-fail" on a protocol/worldId mismatch — it chats and returns early, leaving the rule armed to retry, and re-spams the chat log once per `ReadAP` tick.
- `AP.xs:272` recovers the scenario as `locationId / 10 / 10`, not `/ 100` — arithmetically identical for the ids in use.
- The `/ 4` byte→int fix (1.1) landed at **five** sites, not two: `AP.xs:139`, `:219`, `:264`, `ItemHandler.xs:28`, `:40`.

## Group 5 — Hygiene

- **Deleting the dead patcher drops 13 MB from the apworld. [new]** `campaign/ScenarioPatcher.py` is the **only** importer of the vendored `AoE2ScenarioParser` (13 MB), and `ordered_set` (44 KB) exists solely to satisfy that parser (`AoE2ScenarioParser/objects/support/area.py:9`). Nothing in `age2de` imports either otherwise. So finishing the existing "delete `ScenarioPatcher.py`, `CampaignReader.py` and `xsscript/AP.xs`" item also removes both vendored trees. The stale duplicate bridge is a trap for anyone editing the protocol; the 13 MB is the bigger prize.
- **`age2de` has no `docs/` directory. [new]** No `en_<Game>.md`, no setup guide. Blocks upstream submission and pairs with the missing `WebWorld`.
- `age2de/client/Age2ClientConfig.json` is vestigial — it contains `{"AGE2_USER_FOLDER": ""}` and nothing reads the file or the key. The folder comes from `Age2Settings.user_folder`.
- **[corrected]** Path building is fragile, not Windows-only. The client uses `AGE2_USER_PROFILE = "/profile/"` — POSIX separators that work on Windows too. The real smell is string concatenation instead of `os.path.join`/`pathlib`, and the genuine backslash case is in `Scripts/`.
- `Scripts/__init__.py:30` writes regenerated scenarios to the **repo root** rather than back into `age 2 files/resources/_common/scenario/`, and that output is **not** gitignored — `.gitignore` has no `*.aoe2scenario` glob, only eleven anchored paths. Running the script leaves 12 untracked multi-MB files at the repo root.
- **[new] `Scripts/__init__.py` cannot run as written.** `from setup_pavilion import APavilionMaker` is a top-level import needing `Scripts/` on `sys.path`, while `Data/VictoryPavilionLocations.json` and `os.getcwd() + "/age 2 files/..."` are relative to the repo root — contradictory working directories. It is also all module-level code in a package `__init__.py`, so importing the package runs the whole build, and the loop variable `file` shadows the `with open(...) as file` handle.
- **[new] `APavilionMaker.add_pavilion` can bind to the wrong unit.** If `get_units_in_area` finds anything near the configured coordinates it reuses `pavilion_space[0]` — *any* unit, not necessarily a pavilion — and renames it "APavilion". `_add_color_rotation` also chains triggers by assuming `trigger_id + 1`, which breaks if creation order changes.
- **[corrected] `Techsanity.xs` has never compiled.** `xs-check` fails to lex it: `const int ri-hul'cheJavelineers = 485;` (`:314`) has an apostrophe, and **every** identifier in the file contains `-`, which XS lexes as subtraction (`const int feudal-age = 101;`, `void InitTechsanityAge-Ups() {`). It also has four declare/use name typos (`ri-aznauri-cavalry`/`ri-avnauri-cavalry`, `ri-tusk-swords`/`ri-tusl-swords`, `ri-eupseong`/`ri-eupesong`, `ri-shinkichon`/`ri-shinkichan`). Enabling it needs a full rename pass, not a wiring change.
- **[corrected] `Unitsanity.xs` lexes but cannot resolve** — it calls `new`, `defineStruct`, `structSet*` with no `include "structs.xs"`. It has no rule, no master `InitUnitsanity()`, `disableUnit` is never called, and `InitUnitsanityEconomy` mixes `cAttributeDisable` and `cAttributeSet` on adjacent lines.
- **[corrected] Version skew is three-way**, and the earlier attribution was wrong. "0.2.0" comes from `fill_slot_data` hardcoding `version_public 0 / version_major 2 / version_minor 0` (`__init__.py:276-279`), not from a branch name. So: `archipelago.json` says `world_version 0.0.1` / `minimum_ap_version 0.6.5`, slot_data says 0.2.0, and the git tag/branch is 0.2.3. Pick one scheme. **[new]** The client reads none of those slot_data keys, and the `world_id` emitted there is a time-based per-slot value unrelated to the protocol `worldId = 2`.
- **[new]** `fill_slot_data` never emits the `goal` option, so the client's `check_victory` hardcodes "complete every included campaign". Harmless while `Goal` has one option; it diverges silently the moment a second is added.
- The Archipelago fork's drift from upstream — see the caveat in §1 about which `upstream` this measures.
- **No `test_*.py` anywhere.** 1.1, 1.2 and 2.5 were all the kind of defect a single round-trip `.xsdat` encode/decode test would have caught before shipping.

---

## Verified correct — do not "fix"

Checked while reading, and sound as written:

- `find_active_campaign`'s `skip_int(fp, 18)` (`CampaignHandler.py:119`) lands exactly on `scenario_id`. Re-derived: active 0, ping 1, protocol 2, worldId 3, lastMessageId 4, item ids 5-16, completed 17, **scenarioId 18**.
- Both implementations agree on the **30**-int reserved block (`AP.xs:47-49`, `GameClient.py:88`). Only the spec document disagrees — see §2a.
- `Age2ScenarioData.id` and `Age2CampaignData.id` both exist.
- `Items.ID_TO_ITEM` and `item.type_data` both exist.
- `write_bool` / `read_bool` agree on 4-byte padded booleans, which is what makes the XS side's `xsReadInt` on the dispatch flags work.
- `AP.xs:15`'s `lastMessageId = -1` sentinel — see the retraction note for 2.4.
- `MessageHandler`'s ack handshake — investigated as 2.4 and confirmed sound. Its count prefix in `messages.xsdat` is deliberate and matches its XS reader; do not "fix" it to match 1.2.
- `setup_victory_requirements` matching on key presence rather than value is the correct intent — see 2.12.

## Open questions

- **Does `continue` skip the increment in an XS `for` loop?** Several rules use `continue` inside `for (i = 0; < n)` — `AP.xs` `FreeItems:243` and `MarkServerLocations:270`, and `ItemHandler.xs`. If it skips the increment, those are infinite loops inside a `minInterval 1` rule. Evidence gathered, none conclusive:
  - The canonical XS reference documents **only** `while` and `for`, and never mentions `continue` or `break` as keywords at all. It does say the `for` loop "takes care of increasing the value of `a` every time" and that "you cannot modify `a` inside the for loop" — the increment belongs to the construct rather than the body, which *suggests* `continue` cannot skip it.
  - The UGC guide's `bugs/Language Syntax.md` catalogues four `for`-loop quirks; this is not among them.
  - `xs-check` accepts the pattern, and vendored expert code (`structs.xs:100-117`, `printBuffer`) uses it.

  So the code depends on an **undocumented** keyword that both the linter and expert code accept. Settling it needs a runtime test.

## Suggested order of work

1.1-1.2, 2.1-2.3, 2.5-2.8 and 2.9-2.11 all landed in 0.2.3. What remains, in order:

1. **4.1 — the `CastlesBuilt` capital letter.** One character. Restores the entire Buildsanity feature (34 building locations that currently cannot be checked) and stops a free Castle check on tick one. Fix 4.2 in the same commit, since it is masked by this and goes live immediately after.
2. **3.1 — the four missing Attila 3-6 event rules.** Four `set_rule` calls. Restores progression logic and the goal gate for half the implemented content.
3. **3.2 — the generation hang.** A seed that never finishes generating is the worst failure mode in the list.
4. **2.17 — the ack cursor over-advancing.** The one genuine defect in the item pipeline: it *loses* items permanently, which no amount of resending recovers. Note the framing: **2.16's replay is intended and must be preserved**, so the fix has to make replay safe rather than suppress it. Moving granted-id bookkeeping into XS does exactly that, and simultaneously removes 2.16's resource double-grant and 2.20's amplification. Fix 2.20's `index` handling alongside it so `unlocked_items` stops growing without bound.
5. **2.18** — regression from 2.11's fix; a stale campaign flag now beats standalone-scenario detection. One line either way.
6. **2.19 + 2.21 + 2.13** — the paths that can kill a task, hang the client, or disable reconnect.
7. **2.12** — `check_victory` fail-open; cheap, and the failure mode is "seed instantly won".
8. **Group 3 remainder** — the `enabled_campaigns: []` `KeyError`, the `(A or B)` prerequisite bug and 3.3 are the ones players would actually hit.
9. **Group 4 remainder** — 4.3 and 4.5 first; 4.11/4.12 if missions slow down late.
10. **Group 5** — hygiene, cheapest first. Deleting the dead patcher (and with it 13 MB of vendored code) is the biggest single win; the round-trip `.xsdat` test is the highest-leverage new work now that the framing convention is settled.

Note the shape of the two regressions so far: 2.6's first attempt was dead code behind a `return`, and 2.11's fix silently narrowed `deactivate_scenario`. Both were in disconnect/detection paths with no test coverage — which is the argument for the round-trip test being worth more than its size suggests.

## How to verify

- **XS static check:** run `xs-check` over `age 2 files/resources/_common/xs/`. All twelve entry points currently analyse with zero errors — only `[102] DiscardedFn` (4.2) and two `[109] NoNumPromo` (4.13). `Techsanity.xs` fails to lex; that is expected, see Group 5.
- **Generation:** roll a seed with `enabled_campaigns: []` to reproduce the `KeyError`; roll a two-Age2-slot multiworld to reproduce the class-attribute leaks. For 3.1, check whether an Attila 3-6 unlock item appears in logic with no combat requirements.
- **Protocol:** add a Python round-trip test that writes each `.xsdat` with the client writers and asserts the byte layout the XS readers expect. Assert **30** reserved ints, not the spec's 29.
- **End-to-end:** launch the client, `/set_user_folder` at the numeric profile directory, then start Attila 1 **both** from the campaign and as a standalone scenario — the second path exercises 2.11/2.18. Drop and restore the server connection mid-scenario to exercise 2.16; check the player's resource totals before and after, since that is the observable symptom. For 4.1, check whether the Castle location fires before you build a Castle.
- **Regression watch for 0.2.3:** the fixes for 2.1/2.3/2.6 all changed disconnect behaviour, and `connection_closed` now awaits `game_loop` on every path. See 2.19 — the raise case is live today, and an `asyncio.wait_for(self.game_loop, timeout=5)` in `Age2GameContext.disconnect` would turn both that and the hang case back into visible errors.
