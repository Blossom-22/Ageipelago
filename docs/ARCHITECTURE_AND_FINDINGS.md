# Ageipelago — architecture and open defects

A read-through of both halves of the mod, recording how they fit together and what is currently broken.

First reviewed at `main` / `main`; re-verified at `Ageipelago` @ `0.2.3` (`901b997`) and `Archipelago` fork @ `v0.2.3` (`3f0986c9`). Protocol `6.5`, world id `2`, world version `0.0.1`.
No code was changed in producing this document — fixes listed as resolved were made by the author.

Paths are repo-relative. `age2de/` means `worlds/age2de/` in the Archipelago fork; bare paths mean this repo.

---

## 1. The two projects

| | Ageipelago | `age2de` |
|---|---|---|
| Role | Game side | APWorld side |
| Contents | 25 `.xs`, 12 `.aoe2scenario`, 2 `.aoe2campaign`, 25 `.xlsx`, 2 `.py` | 78 non-vendored `.py`, plus vendored `AoE2ScenarioParser` (~12 MB) and `ordered_set` 4.1.0 |
| Ships as | A copy of the AoE2:DE user folder, hand-zipped | An in-tree Archipelago world |

The Archipelago fork branched from upstream on 2026-03-12 and carries 102 commits, **all inside `worlds/age2de`** — no core patches, so it stays a clean apworld candidate. Upstream is 172 commits ahead as of 2026-08-31.

## 2. Why the transport looks the way it does

AoE2:DE cannot be attached to as a process — no memory reading, no scripting hook, no connector. `communication_protocol.md` (this repo) settles on AoE2's own **XS file I/O** as the IPC: binary `.xsdat` files in `<AoE2 user dir>/profile/`, polled from both sides.

The asymmetry is an engine constraint, not a design choice: a scenario may *read* any `.xsdat`, but may only *write the one named after itself*. Hence one status file per scenario, each carrying an active flag and a ping so the client can work out which mission is running.

```
AP server ──► client (CommonClient + kvui, registered at age2de/__init__.py:284-296)
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

Game→client is one file; client→game is many. `AP_Read` reads five dispatch booleans and enables the matching XS rule (`ReadItems`, `FreeItems`, `MarkServerLocations`, `ReadMessages`; a units flag is read but unused).

Location acknowledgement is a two-flag ledger in `ScenarioLocations.xs`: the game sets `scenarioComplete`, the client echoes the id back, and the game then sets `serverComplete` to stop resending. Scenario-completion de-duplication across restarts rides on AP **DataStorage** instead — a bitfield keyed by each scenario's `completion_bit` (0-11).

## 3. The coupling between the repos

There is no structural link — no submodule, no shared package, no path config. The contract is four duplicated conventions, and all four must be edited in lockstep:

1. **Packet layouts** — specified in `communication_protocol.md`, hand-implemented twice (`AP.xs` and `age2de/client/GameClient.py`).
2. **Filenames** — `age2de/locations/Scenarios.py:33-45` hardcodes `AP_Attila_1.xsdat`…`AP_Joan_6.xsdat` (read) and `ATT1.xsdat`…`JOAN6.xsdat` (write). `age2de/locations/Campaigns.py:14-15` hardcodes `AP Attila the Hun.xsdat` / `AP Joan of Arc.xsdat`. These are exactly this repo's scenario and campaign stems — **renaming one here silently breaks the client.**
3. **Magic pair** — `protocol = 6.5` / `worldId = 2`, in `AP.xs:13-14` and `GameClient.py:26-27`. `AP_Read` hard-fails on mismatch.
4. **ID ranges** — 0-24 resources, 200-234 buildings, 1000-1023 progression, 4000-4011 mercenaries, locations as `<campaign><chapter><NN>`. `Scenarios.py:14` computes `campaign.value * 100 + chapter`; `AP.xs:272` divides a location id by 100 to recover the scenario.

## 4. What each side owns

### Ageipelago

- **`AP.xs`** (314 lines) is the bridge. Include graph:
  `AP_<Campaign>_<N>.xs → AP.xs → ItemHandler.xs → {Progression,Mercenary,Resource}Items.xs, Buildsanity.xs → AP_Headers.xs → structs.xs`.
  `AP_Headers.xs` declares `mutable void` stubs so the shared library compiles, and each per-scenario file overrides them.
- **No trigger variables anywhere.** `xsTriggerVariable` / `xsSetTriggerVariable` appear nowhere in the repo; all state crosses via file I/O.
- **`Buildsanity.xs`** infers *which* building was placed by matching the resource-cost delta against known costs while watching `cAttributeValueCurrentBuildings`. Castles and Wonders use dedicated totals instead.
- **`structs.xs`** is vendored XsStructs v1.0.0 (MrKirby / KSneijders).
- **`Techsanity.xs`** (681 lines) and **`Unitsanity.xs`** (571) are orphaned — never included, entry points never called. Staged future features.
- **`Scripts/__init__.py`** + **`Scripts/setup_pavilion.py`** are the build tooling: inject the looping `AP Ping` trigger, place the AP Victory Pavilion from `Data/VictoryPavilionLocations.json`, and wire `HasVictory()` / `ShowVictory()` / tech 1180 into real victory triggers.
- **`docs/Logic Requirements/*.xlsx`** — 25 hand-authored per-campaign planning worksheets, **not build inputs**; nothing reads them. Only Attila and Joan are implemented.
- **`age 2 files/`** is a checked-in mirror of the live AoE2 user folder. `.gitignore` excludes `mods/`, `savegame/`, `Player.nfp`, and all `*.xsdat`, confirming the transport is entirely transient.

### age2de

- `Age2World(CachedRuleBuilderWorld)` — built on the repo-root `rule_builder` DSL, not raw `set_rule` lambdas. **No WebWorld/tutorial, no `generate_output`** (nothing is written at generation time).
- **103 items**: 35 buildings, 26 scenario items, 8 mercenaries, 2 campaign unlocks, 2 progressive scenarios, filler and starting resources, TC resources. Ages exist as data but are never shuffled.
- **160 locations**: 125 scenario objectives + 35 building checks.
- **Regions are missions**, chained linearly per campaign off `Menu`, plus one synthetic `Can Build` region holding the building checks.
- **Logic is hand-written Python** under `logic/` and `rules/`. The `.xlsx` worksheets do not drive it.
- **6 options**: `scenarioBranching`, `shuffle_buildings`, `enabled_campaigns`, `starting_campaigns`, `goal`, `startInventoryPool`.
- `campaign/ScenarioPatcher.py`, `campaign/CampaignReader.py` and `campaign/xsscript/AP.xs` are **dead code** — a superseded auto-patching path. `inject_ap` is never called, and that bundled `AP.xs` is a 34-line stale fork of the real bridge. Only `campaign/XsdatFile.py` is live.
- `test/` contains `bases.py` and **no `test_*.py`**.

---

# Resolved in 0.2.3

| # | What it was | Fixed by |
|---|---|---|
| 1.1 | `xsGetFileSize()` returns bytes; `AP.xs` used it as an element count | Ageipelago `901b997` — `/ 4` at `AP.xs:219` and `:264` |
| 1.2 | `items.xsdat` carried a count prefix that `ReadItems` never skipped | `9362e139` — count removed from `send_items`; the file is now a bare id stream |
| 2.1 | `continue` with no `await` on an invalid ping starved the event loop | `e0f7542a` — `await short_sleep()` added |
| 2.2 | `scenario_completion_key` built while `team`/`slot` were still `None` | `986a10d7` — moved into `_handle_connected` |
| 2.3 | Class-level handler dicts meant `disconnect()` never reset state | `9989ae96` — dicts built in `__init__` |
| 2.5 | `update_packet` tested the old packet's `location_ids` | `5ad03103` — now `new_pkt.location_ids` |
| 2.6 | A clean server close bypassed `disconnect()` entirely | `9362e139` + `ce1b5710` — `connection_closed` override is now the single choke point |
| 2.7 | `Age2Packet.item_ids` was a shared class-level list | `c9f7f3bd` — moved into `__init__` |
| 2.9 | `sync_scenario_items` mutated a module-global list every tick | `08b3caa3` — builds a new list per call |
| 2.10 | `main()` never awaited `ctx.shutdown()` | `236f1af2` — restored at `ApClient.py:183` |
| 2.11 | `read_packet` always opened the campaign file | `3f0986c9` — new `ActiveFile` captures `read_file_name` at detection |

**2.4 — retracted, not a bug.** An earlier draft claimed a reconnect mid-scenario dropped two chat messages via `MessageHandler`'s reset counters. Confirmed by the author as not reproducible. One piece of it is still worth keeping: `AP.xs:15` initialises `lastMessageId = -1`, and `is_packet_up_to_date` depends on that being below any real message id. **The `-1` sentinel is load-bearing — do not normalise it to 0.**

Also worth recording for whoever reads `connection_closed` next: it is reached from `server_loop`'s `finally`, so it covers clean closes, exceptions, and connects that never succeeded. `handle_connection_loss` is *not* a viable place for this — it is only called from the `except` branches at `CommonClient.py:886-904`, and a clean close raises nothing.

---

# Open defects

Numbering is stable and matches the resolved table above; gaps are resolved items.

## Group 2 — Client (`age2de/client/`)

### 2.16 Reconnect re-grants resources. `GameClient.py:149`, `AP.xs:216-228`

Surfaced by 2.6's fix now working on every path. `disconnect()` rebuilds `ClientStatus`, so `acked_items` returns to 0 while `unlocked_items` is repopulated in full from AP's `ReceivedItems` resend. `send_items` therefore re-sends the window from index 0.

XS `ReadItems` only skips a slot when `xsArrayGetInt(itemArray, i) != -1`, and `FreeItems` has already cleared the slots the client previously acked — so re-sent items land in freed slots and are granted a second time. `GiveProgressionItem` sets bool flags and is idempotent; **`GiveResource` is not**, so the player gains resources on each reconnect.

**Fix:** persist `acked_items` across reconnects, or (better) have XS track granted item ids instead of the current 12-slot sliding window.

### 2.17 `ack_items` over-advances the send window, losing items. `GameClient.py:203-206`

```python
for item in self.current_packet.item_ids:
    if item != -1 and self.client_status.acked_items < len(self.client_status.unlocked_items):
        self.client_status.acked_items += 1
```

One increment per occupied slot **per tick**, with no de-duplication. Cadence makes that fire repeatedly on the same items: `AP Ping` (`Scripts/__init__.py:22-25`) is a looping trigger with **no condition**, so `AP_Write()` runs every scenario tick and the ping (`xsGetGameTime()`) changes each time — meaning almost every client poll is a fresh non-`REPEAT` packet. `FreeItems` (`AP.xs:231-234`) only clears slots once per second. So the game reports the same occupied slots across several consecutive packets.

With 20 items unlocked:

1. Tick 1 — 12 slots occupied → `acked_items` 0 → 12. Correct.
2. Tick 2, before `FreeItems` has run — same 12 slots → `acked_items` 12 → 20.

Items 12-19 were never sent, but the window has passed them. `send_items` computes `20 - 20 = 0`, and `acked_items` never decreases, so **they are lost permanently**.

Buildings, startup resources, scenario items and mercenaries are re-synced wholesale every tick through their own files and self-heal. The casualties are items delivered *only* via `items.xsdat` — filler `Resources` (ids 1-12), which are exactly the non-idempotent `GiveResource` ones.

**Fix:** ack by item id rather than by slot count — or drop the sliding window entirely and have XS track which ids it has granted. That also resolves 2.16, which is the same mechanism failing in the opposite direction (replaying the window instead of skipping it).

### 2.18 `deactivate_scenario` no longer clears the campaign file. `CampaignHandler.py:154-160`

Introduced by 2.11's fix, which is otherwise the right shape. `deactivate_scenario` previously wrote `False` over **both** the campaign and the scenario read file; it now writes only `active_file.read_file_name`. More correct in intent, but it removes an accidental safety net.

`find_active_campaign` runs *before* `find_active_scenario` in `status_loop` (`GameClient.py:301-311`), so a stale active flag left in a campaign file wins detection. Nothing clears these on a fresh connect — `connect()` does not call `flush_files()`, since the earlier refactor dropped the flush that used to live in `_handle_connected`.

Repro: play a campaign mission, kill the game without exiting cleanly, restart the client, launch a **standalone** scenario. `find_active_campaign` matches the stale campaign file, and the client reads the wrong one.

**Fix:** either call `flush_files()` from `connect()`, or have `deactivate_scenario` clear both filenames as it used to.

### 2.12 `check_victory` fails open. `CampaignHandler.py:61-68`

If no campaign has `must_beat` set, every iteration `continue`s and the function returns `True` → instant goal on the first tick. It works today only because `fill_slot_data` emits `"<Campaign Name>_unlocked"`; any key-name drift silently wins the game.

### 2.13 `FolderHandler._user_folder` has no default. `FolderHandler.py:2`

Annotation only. If the folder is never set, `MessageHandler.is_message_sending` (`:55`) is called from `try_write_to_folder:29` **outside** its `try` block → uncaught `AttributeError` silently kills the `status_loop` task.

### 2.14 `read_string` never returns. `campaign/XsdatFile.py:15-17`

Unpacks the value and discards it. Currently unused on the read path.

### 2.15 Dead or malformed declarations

- `CampaignHandler.py:36` — `_victory: False` is an annotation whose *type* is `False`, not an assignment. Unused.
- `ManagedScenarioItem.unlocked` (`CampaignHandler.py:15`) and `ManagedBuilding.unlocked` (`BuildingHandler.py:12`) are bare class attributes on `@dataclass`es, not fields.
- `Age2Context.victory: bool` (`ApClient.py:46`) declared, never used.
- `unlock_scenario` (`CampaignHandler.py:82-83`) is a `pass` stub.
- `__add_campaign_to_folder`, `__add_scenario_to_age2campaign`, `__update_age2campaign_json` (`:187-194`) are stubs missing `self`.
- `args = parser.parse_args()` (`ApClient.py:171`) is assigned and never used, so `--connect` / `--password` are ignored in favour of the `main()` parameters. This is the leftover half of 2.10; the `shutdown()` half is fixed.

## Group 3 — Generation (`age2de/`)

- `__init__.py:54-56` — `included_civs` / `included_campaigns` / `shuffled_buildings` are class-level mutables mutated per player; `included_civs.append` at `:91` leaks across slots in a multi-Age2 multiworld. Same pattern at `rules/ScenarioRules.py:21` and `logic/Logic.py:29`.
- `__init__.py:70-71` — an empty `enabled_campaigns` assigns `.default`, a set of **strings**, while the else-branch yields `Age2CampaignData`; `CAMPAIGN_TO_SCENARIOS[campaign]` at `:79` then raises `KeyError`.
- `__init__.py:87` — `first_scn` is referenced inside the `except StopIteration` block that its own assignment raised from → `UnboundLocalError` masks the intended `OptionError`.
- `__init__.py:222-229` — `smart_add_starting_resources`, `worst_case_sum == locations_to_fill` branch: calls `create_item` in four loops, never appends, returns an empty list. The item pool comes up short by exactly that count.
- `logic/building_logic.py:27,30` — `if building == (A or B)` evaluates to `A`. **Stable never requires Barracks; Market never requires Mill.**
- `logic/age_logic.py:57-58` — `has_age()` returns `True_()` unconditionally, so every age gate in the military logic is a no-op.
- `rules/AgeRules.py:23-24` — `AgeRules.set_rules` is `pass`; no age rules are applied and `TwoBuildingsRequirement` is unused.
- `Options.py:63,71` — `StartingCampaigns` and `EnabledCampaigns` share `display_name = "Enabled Campaigns"`.
- `__init__.py:186` — stray `print(needed_number_of_filler_items)`.

## Group 4 — XS

- `AP.xs:245-249` — the `FreeItems` inner loop indexes `itemArray` with `i` instead of `j`; `j` is unused and the free logic is wrong.
- `ScenarioLocations.xs:49-55` — `arrayLength = idEnd - idStart` but the loop runs `<= idEnd`, writing index `arrayLength` (out of bounds).
- `Buildsanity.xs:71` vs `:279-280` — the attribute is declared `"CastlesBuilt"` and read/written as `"castlesBuilt"`; the castle check likely never fires.
- `Buildsanity.xs:200-210`, `:213-223` — a stray `;` before the final term discards the gate-count computation.
- `ItemHandler.xs:9` — `if (itemId < 25) GiveResource(itemId)` has no lower bound, so `-1` and `0` route into the resource path. Compounds 1.1, where over-reads yield zeros.

## Group 5 — Hygiene

- Delete or finish `age2de/campaign/ScenarioPatcher.py`, `CampaignReader.py` and `xsscript/AP.xs`. The stale duplicate bridge is a trap for anyone editing the protocol.
- `age2de/client/Age2ClientConfig.json` is vestigial; nothing reads `AGE2_USER_FOLDER`.
- Windows-only path building throughout (`user_folder + "/profile/" + name`, `f"{outFolder}\\{...}"`).
- `Scripts/__init__.py:30` writes regenerated scenarios to the **repo root** rather than back into `age 2 files/resources/_common/scenario/`, and that output is not gitignored.
- Version skew: `archipelago.json` says `world_version 0.0.1` / `minimum_ap_version 0.6.5`, the mod ships 0.3.0, and the AP branch was named 0.2.0. Pick one scheme.
- The Archipelago fork is 172 upstream commits behind (branched 2026-03-12).
- **No `test_*.py` anywhere.** 1.1, 1.2 and 2.5 were all the kind of defect a single round-trip `.xsdat` encode/decode test would have caught before shipping.

---

## Verified correct — do not "fix"

Checked while reading, and sound as written:

- `find_active_campaign`'s `skip_int(fp, 18)` (`CampaignHandler.py:107`) lands exactly on `scenario_id`.
- `Age2ScenarioData.id` and `Age2CampaignData.id` both exist.
- `Items.ID_TO_ITEM` and `item.type_data` both exist.
- `write_bool` / `read_bool` agree on 4-byte padded booleans, which is what makes the XS side's `xsReadInt` on the dispatch flags work.
- `AP.xs:15`'s `lastMessageId = -1` sentinel — see the retraction note for 2.4.
- `MessageHandler`'s ack handshake — investigated as 2.4 and confirmed sound.

## Suggested order of work

1.1-1.2, 2.1-2.3, 2.5-2.7 and 2.9-2.11 all landed in 0.2.3. What remains, in order:

1. **2.17 + 2.16 together** — the item sliding window fails in both directions: 2.17 skips items and loses them permanently, 2.16 replays them and double-grants resources. Acking by item id, or moving the granted-id bookkeeping into XS, fixes both at once. Highest-value work left.
2. **2.18** — regression from 2.11's fix; a stale campaign flag now beats standalone-scenario detection. One line either way.
3. **2.8 + 2.13** — the two remaining paths that can kill a task with an uncaught exception.
4. **2.12** — `check_victory` fail-open; cheap, and the failure mode is "seed instantly won".
5. **Group 3** — generation bugs. The `enabled_campaigns: []` `KeyError` and the `(A or B)` prerequisite bug are the ones players would actually hit.
6. **Group 4** — remaining XS bugs.
7. **Group 5** — hygiene, cheapest first. The round-trip `.xsdat` test is the highest-leverage item here now that the framing convention is settled.

Note the shape of the two regressions so far: 2.6's first attempt was dead code behind a `return`, and 2.11's fix silently narrowed `deactivate_scenario`. Both were in disconnect/detection paths with no test coverage — which is the argument for Group 5's round-trip test being worth more than its size suggests.

## How to verify

- **XS static check:** run `xs-check` over `age 2 files/resources/_common/xs/`.
- **Generation:** roll a seed with `enabled_campaigns: []` to reproduce the `KeyError`; roll a two-Age2-slot multiworld to reproduce the class-attribute leaks.
- **Protocol:** add a Python round-trip test that writes each `.xsdat` with the client writers and asserts the byte layout the XS readers expect.
- **End-to-end:** launch the client, `/set_user_folder` at the numeric profile directory, then start Attila 1 **both** from the campaign and as a standalone scenario — the second path exercises 2.11. Drop and restore the server connection mid-scenario to exercise 2.16; check the player's resource totals before and after, since that is the observable symptom.
- **Regression watch for 0.2.3:** the fixes for 2.1/2.3/2.6 all changed disconnect behaviour, and `connection_closed` now awaits `game_loop` on every path. If a future change reintroduces a non-yielding loop in `status_loop`, that await will hang and the client will stop reconnecting rather than fail loudly. An `asyncio.wait_for(self.game_loop, timeout=5)` in `Age2GameContext.disconnect` would turn that class of bug back into a visible error.
