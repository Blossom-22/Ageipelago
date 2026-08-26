include "./ItemHandler.xs";
include "./APavilion.xs";

int itemArray = -1;
int locationArray = -1;

int clientPing = -1;
int lastPing = -1;
int pingRepeatCount = 0;

int completed = 0;
int scenarioId = 0;

float protocol = 6.5;
int worldId = 2;
int lastMessageId = -1;

bool CheckScenario() {
    bool opened = xsOpenFile("AP");
    if (opened == false) {
        return (false);
    }
    int receivedScenarioId = xsReadInt();
    if (receivedScenarioId != scenarioId) {
        xsCloseFile();
        return (false);
    }
    xsCloseFile();
    return (true);
}

void AP_Write()
{
    bool created = xsCreateFile(false);
    if (created == false) {
        return;
    }
    xsWriteInt(1);
    xsWriteInt(xsGetGameTime());
    xsWriteFloat(protocol);
    xsWriteInt(worldId); 
    xsWriteInt(lastMessageId);
    for (i = 0; < 12) {
        xsWriteInt(xsArrayGetInt(itemArray, i));
    }
    xsWriteInt(completed);
    xsWriteInt(scenarioId);
    for (i = 0; < 30) {
    xsWriteInt(i);
    }
    for (i = 0; < xsArrayGetSize(locationArray)) {
        xsWriteInt(xsArrayGetInt(locationArray, i));
    }
    xsCloseFile();
}

void AP_Read()
{
    bool opened = xsOpenFile("AP");
    if (opened == false) {
        return;
    }

    // Check Scenario
    int receivedScenarioId = xsReadInt();
    if (receivedScenarioId != scenarioId) {
        xsChatData("<RED>Wrong Scenario ID from Client: " + receivedScenarioId);
        xsChatData("<RED>Expected Scenario Id: " + scenarioId);
        xsCloseFile();
        return;
    }

    // Update Ping
    lastPing = clientPing;
    clientPing = xsReadInt();
    if (clientPing == lastPing) {
        xsCloseFile();
        return;
    }

    // Check World Protocol
    float check_protocol = xsReadFloat();
    if (check_protocol != protocol) {
        xsChatData("<RED>Unexpected AP World Protocol from Client: " + check_protocol);
        xsChatData("<RED>Expected Protocol: " + protocol);
        xsCloseFile();
        return;
    }
    
    // Check World Id
    int check_worldId = xsReadInt();
    if (check_worldId != worldId) {
        xsChatData("<RED>Unexpected AP World ID from Client: %d", check_worldId);
        xsChatData("<RED>Expected World ID: %d", worldId);
        xsCloseFile();
        return;
    }

    int items = xsReadInt();
    if (items == 1) {
        xsEnableRule("ReadItems");
    }
    int free_items = xsReadInt();
    if (free_items == 1) {
        xsEnableRule("FreeItems");
    }
    int free_locations = xsReadInt();
    if (free_locations == 1) {
        xsEnableRule("FreeLocations");
    }
    int units = xsReadInt();
    int messages = xsReadInt();
    if (messages == 1) {
        xsEnableRule("ReadMessages");
    }
    completed = xsReadInt();
    xsCloseFile();
}

void AP_Check_Location(int locationId = -1)
{
    int locationSize = xsArrayGetSize(locationArray);
    xsArrayResizeInt(locationArray, locationSize + 1);
    xsArraySetInt(locationArray, locationSize, locationId);
}

void SetScenarioId(int id = 0) {
    scenarioId = id;
}

void ScenarioSpecificInit(string filename = "") {
    bool openFile = xsOpenFile(filename);
    if (openFile == false) {
        xsCloseFile();
        return;
    }
    int itemCount = xsGetFileSize() / 4;
    completed = xsReadInt();
    for (i = 1; < itemCount) {
        int itemId = xsReadInt();
        GiveItem(itemId);
    }
    xsCloseFile();
}

void GiveVictory() {
    completed = 1;
    AP_Write();
}

bool HasVictory() {
    return (completed == 1);
}

rule ReadAP
    inactive
    minInterval 2
    maxInterval 4
{
    AP_Read();
    if (clientPing > lastPing) {
        pingRepeatCount = 0;
    }
    else {
        pingRepeatCount++;
    }

    if (pingRepeatCount >= 5) {
        xsChatData("<RED>AP Client disconnected. Cannot send locations or receive items until connection is reestablised.");
    }
}

rule InitAP
    inactive
    minInterval 1
    maxInterval 1
{
    if (scenarioId == -1) {
        xsChatData("Scenario Id is not defined. Please set the Scenario Id before initializing this scenario.");
        return;
    }
    xsChatData("Waiting for Client Connection");
    if (CheckScenario() == false) {
        return;
    }

    xsChatData("Client Connected!");

    itemArray = xsArrayCreateInt(12, -1, "Item Array");
    locationArray = xsArrayCreateInt(0, -1, "Location Array");
    GiveStartupItems();
    
    xsEffectAmount(cModifyTech, victoryTech, cAttrSetState, cAttributeDisable);
    
    InitBuildsanity();
    GiveStartupBuildings();
    InitScenarioSpecific();
    xsEnableRule("ReadAP");
    xsDisableSelf();
}

rule ReadItems
    inactive
    minInterval 1
    maxInterval 1
{
    bool opened = xsOpenFile("items");
    if (opened == false) {
        return;
    }
    int itemCount = xsGetFileSize();
    for (i = 0; < itemCount) {
        int itemId = xsReadInt();
        if (xsArrayGetInt(itemArray, i) == -1) {
            GiveItem(itemId);
            xsArraySetInt(itemArray, i, itemId);
        }
    }
    xsCloseFile();
    xsDisableSelf();
}

rule FreeItems
    inactive
    minInterval 1
    maxInterval 1
{
    bool opened = xsOpenFile("free_items");
    if (opened == false) {
        return;
    }
    for (i = 0; < 12) {
        int itemId = xsReadInt();
        if (itemId == -1) {
            continue;
        }
        for (j = 0; < 12) {
            if (xsArrayGetInt(itemArray, i) == itemId) {
                xsArraySetInt(itemArray, i, -1);
            }
        }
    }
    xsCloseFile();
    xsDisableSelf();
}

rule FreeLocations
    inactive
    minInterval 1
    maxInterval 1
{
    bool opened = xsOpenFile("locations");
    if (opened == false) {
        return;
    }
    int locationCount = xsGetFileSize();
    for (i = 0; < locationCount) {
        int locationId = xsReadInt();
        int arraySize = xsArrayGetSize(locationArray);
        for (j = 0; < arraySize - 1) {
            if (xsArrayGetInt(locationArray, j) == locationId) {
                int nextLocation = xsArrayGetInt(locationArray, j + 1);
                xsArraySetInt(locationArray, j, nextLocation);
                xsArraySetInt(locationArray, j + 1, locationId);
            }
        }
        xsArrayResizeInt(locationArray, arraySize - 1);
    }
    xsCloseFile();
    xsDisableSelf();
}

rule ReadMessages
    inactive
    minInterval 1
    maxInterval 1
{
    bool opened = xsOpenFile("messages");
    if (opened == false) {
        return;
    }
    int messageCount = xsReadInt();
    int fileLength = xsGetFileSize();
    for (i = 0; < messageCount) {
        int nextMessageId = xsReadInt();

        // IMPORTANT: Use this for hunting down messages that crash AoE2! Comment out xsChatData(message);
        // Do not remove these lines unless you want to fix things the hard way!
        // int filePosition = xsGetFilePosition();
        // xsChatData("Message Id: " + nextMessageId);
        // xsChatData("Position: " + filePosition);
        // int stringLength = xsReadInt();
        // if (stringLength > fileLength - filePosition) {
        //     xsChatData("String is too long: " + stringLength);
        //     return;
        // }
        // bool backToMessageLength = xsSetFilePosition(filePosition);

        string message = xsReadString();
        if (lastMessageId <  nextMessageId) {
            lastMessageId = nextMessageId;
            xsChatData(message);
        }
    }
    xsCloseFile();
    xsDisableSelf();
}