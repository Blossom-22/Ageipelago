# Communication Protocol

Age of Empires II: Definitive Edition does not have a known way of reliably attaching to the game process and reading and writing data. Due to this, I long believed that there would be no way for communication to occur between AoE2 and AP.

However, thanks to the help of discord users @phaneros and @Epid, I was able to find a method to interact between the game client and AP using AoE2's built-in xs-scripts. The following is the client-game communication protocol, inspired loosely by phaneros' work [here for Warcraft III.](https://github.com/MatthewMarinets/war3-ap-maps/blob/main/doc/communication_protocol.md)

## .xsdat Formatting

`.xsdat` files can be injected by the client and read using xsScripts in the game.

.xsdat files are formatted as follows, and all reads are assumed to be the correct typing:

An `integer` is read FIFO into four bytes. So `222225` would be stored by AoE2 as `0x11 0x64 0x03 0x00`, and would be read back as `0x00 0x03 0x64 0x11`.

A `float` is stored into four bytes as well. I will deal with floats if I ever _need_ to.

The same goes for `Vectors`, which are stored in 12 bytes, 4 for each component (X,Y,Z).

A `string` is stored with 4 bytes, FIFO, for the length, and the string is located immediately after, read left to right for the length in the first 4 bytes.

## Client -> Game

A scenario can read an arbitrary number of `.xsdat` files from the `$USER\Games\Age of Empires 2 DE\$STEAM_PROFILE\profile` folder using `xsScript`. This allows different files to be used for different purposes on the client side, with each scenario sharing methods for common access.

For example, the client can load into a file such as `AP.xsdat` a current ping value and an update flag, stored as an integer.

In another file, such as `Items.AP`, the client could update an integer from a list of integers associated with an item. The game can then read that integer and process the item.

## Game -> Client

Unfortunately, each scenario writes to one location, and one location only: the file in `$USER\Games\Age of Empires 2 DE\$STEAM_PROFILE\profile` with the same name as the given scenario. If the given scenario is `C1_Attila_1.age2campaign`, the only place that scenario will write when being played is the file `C1_Attila_1.xsdat`. Fortunately, the workaround to this is not too unbearable. We simply create an `.xsdat` file for each unlocked scenario, and write a scenario active flag and a current ping to the first few bytes.

When no scenario is opened, the Client will scan each `.xsdat` file, looking for an active flag. Once an active flag is found, the client connects to the selected scenario. As long as the current ping is updated, the Client recognises that the scenario is running.

If the scenario becomes inactive due to the game closing or an extended pause, the Client sets the active flag to false, and begins checking that `.xsdat` file every second for a couple minutes, while also occasionally checking each other unlocked scenario in case the user has changed scenarios.

## Game -> Game

Each scenario can also read from its own file. I'm not sure what the use cases for this might be. There may be reasons the game will want to check its own state before unlocking certain things.

## Save and Load

The client/game handshake must be reestablished upon loading.

Items from the last save must be re-sent from the client. Many items, such as techs, are simply flags that are read by the game, but most filler items will need to be loaded upon client reconnection.

## Packets

### <SCENARIO_NAME>.xsdat

Game -> Client

Each scenario has a unique .xsdat file.

|Name|Type|Purpose|
|---|---|---|
|Active|bool|Whether the current scenario is running (0 or 1)|
|Ping|int|Updated each rule tick while scenario is running and unpaused|
|Protocol|float|What AP version is expected by the game|
|WorldId|int|The ID of the AP World being played|
|LatestMessageId|int|The ID of the latest played message, assumes all previously sent messages have been played in order|
|ItemId1-ItemId12|int*12|The most recent item packet Ids received by the game|
|ScenarioCompleted|bool|Returns scenario global variable completed, which is 1 if the scenario has been completed|
|ScenarioId|int|The id of the scenario, used when the player is playing a campaign|
|CurrentUnitBufferId|int|The latest unit buffer, set to -1 if no buffer has been received|
|CurrentUnitBufferRemaining|int|How many units are left from the current item to spawn|
|x27 spaces|undetermined|Reserved for future use|
|Locations (L)|int*L|All locations checked that have not been confirmed by AP client|

### AP.xsdat

Client -> Game

Sent from the client to the game to confirm that the client is still connected and with instructions for the game to check certain files.

|Name|Type|Purpose|
|---|---|---|
|Ping|int|Updated each rule tick while scenario is running and unpaused|
|Protocol|float|What AP version is expected by the game|
|WorldId|int|The ID of the AP World being played|
|CheckItems|int|If 1, the game reads the `items.xsdat` file|
|ResetItems|int|If 1, the game reads the `reset_items.xsdat` file|
|CheckLocations|int|If 1, the game reads the `locations.xsdat` file|
|CheckUnitBuffer|int|If 1, the game reads the `units.xsdat` file. This will only be 1 if the client knows that `CurrentUnitBufferRemaining` is 0|

### items.xsdat

Client -> Game

The game reads these items one at a time. Each item here will have a corresponding xsScript waiting for the itemId based on the type of item. If itemId1 is a tech, it will unlock that respective tech for the player that corresponds to that itemId.

|Name|Type|Purpose|
|---|---|---|
|ItemId1|int|Id for the first item|
|ItemId2|int|Id for the second item|
|...|...|...|
|ItemId12|int|Id for the 12th item|

### free_items.xsdat

Client -> Game

the client echoes back the items that have been successfully received by the game. The game frees item slots in its local cache, allowing new items to be loaded into the game and activated.

|Name|Type|Purpose|
|ItemId1|int|Id for the first item|
|ItemId2|int|Id for the second item|
|...|...|...|
|ItemId12|int|Id for the 12th item|

### locations.xsdat

Client -> Game

The game reads a location file that echoes back the locations sent in past packets from the <SCENARIO_NAME>.xsdat packet. These locations are freed from the game's memory so that they will not continue to be sent in future packets.

|Locations (L)|int*L|All locations checked that have not been confirmed by AP client|

### units.xsdat NOT IMPLEMENTED

Client -> Game

Unit item handling in AoE2 is tricky, but essentially, units will be loaded into the game by spawning at a predetermined "safe" location via a "buffer". For example, if an item contains 1 Militia and 1 Scout, such as the transport troop from the Joan mission **Seige of Paris**,  Units.xsdat will be a queue-loaded buffer of unit ids, read one-by-one until the in-game unit buffer reaches zero. So the game will read 2 units, first the Militia and then the Scout, and the units will be spawned in until each unit has been spawned. The client will wait to receive a 0 in CurrentUnitBufferRemaining before loading the next buffer item into the `units.xsdat` file.

On reconnections, the client will update this packet with the remaining units in a given buffer item, based on the amount remaining in `<SCENARIO_NAME>.xsdat`.

When a buffer item update is received, the game will first check if CurrentUnitBufferRemaining is 0. If it is 0, It will first read the units.xsdat file, assign NumberOfUnits to CurrentUnitBufferRemaining, and will then perform a looping check where spwans and moves the units one at a time based on the unit id until CurrentUnitBufferRemaining is 0.

Buffer item messages are always received, but the units will spawn in as the client's unit queue sends loadNextBufferItem pings.

|Name|Type|Purpose|
|---|---|---|
|CurrentBufferItemId|int|Tells the game what the current buffer item is, reflected back int `<SCENARIO_NAME>.xsdat`|
|NumberOfUnits|int|Tells the game how many units are in this item|
|UnitIds|int*NumberOfUnits|The ids of the units to be spawned in order|

### <SCENARIO_SHORTHAND>.xsdat

Client -> Game

Each Scenario has a shorthand file containing found items to be sent at level start, as well as a completion status for the scenario.

|Name|Type|Purpose|
|Completed|bool|If completed is true (1), set global variable completed = true|
|ItemIds (I)|int * I|Id of item to unlock on level start|
