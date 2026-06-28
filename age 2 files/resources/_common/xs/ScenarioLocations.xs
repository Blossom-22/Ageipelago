include "structs.xs";

vector locationList = cInvalidVector;

vector GetLocationById(int id = -1) {
    if (id == -1) {
        xsChatData("ContainsName: No Array Set");
        return (cInvalidVector);
    }

    int locations = structGetInt(locationList, "locations");
    int arraySize = xsArrayGetSize(locations);

    for (i = 0; < arraySize) {
        vector location = xsArrayGetVector(locations, i);
        int locationId = structGetInt(location, "id");
        if (locationId == id) {
            return (location);
        }
    }

    xsChatData("Location Not Found: %d", id);
    return (cInvalidVector);
}

vector AddLocation(string locationName = "", int id = -1, bool scenarioComplete = false, bool serverComplete = false) {
    vector location = new("Location");
    structSetString(location, "name", locationName);
    structSetInt(location, "id", id);
    structSetBool(location, "scenarioComplete", scenarioComplete);
    structSetBool(location, "serverComplete", serverComplete);
    return (location);
}

void InitLocations() {
    defineStruct("Location");
    defineStructAttribute("Location", "name", TYPE_STRING);
    defineStructAttribute("Location", "id", TYPE_INT);
    defineStructAttribute("Location", "scenarioComplete", TYPE_BOOL);
    defineStructAttribute("Location", "serverComplete", TYPE_BOOL);

    defineStruct("LocationList");
    defineStructAttribute("LocationList", "locations", TYPE_STRUCT_ARRAY);

    locationList = new("LocationList");
    int locations = xsArrayCreateVector(200, cInvalidVector, "ap-locations");
    structSetInt(locationList, "buildings", locations);
}

int FilterCompletedNotSent() {
    int locations = structGetInt(locationList, "locations");
    int arraySize = xsArrayGetSize(locations);
    
    int filteredArray = xsArrayCreateVector(arraySize, cInvalidVector);

    int j = 0;
    for (i = 0; < arraySize) {
        vector location = xsArrayGetVector(locations, i);
        bool scenarioComplete = structGetBool(location, "scenarioComplete");
        bool serverComplete = structGetBool(location, "serverComplete");
        if (scenarioComplete == true && serverComplete == false) {
            xsArraySetVector(filteredArray, j, location);
            j = j + 1;
        }
    }

    return (filteredArray);
}

void SetScenarioComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("SetScenarioComplete: Location does not exist: %d", locationId);
    }

    structSetBool(location, "scenarioComplete", true);
}

bool IsScenarioComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("IsScenarioComplete: Location does not exist: %d", locationId);
    }

    return (structGetBool(location, "scenarioComplete"));
}

void SetServerComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("SetServerComplete: Location does not exist: %d", locationId);
    }

    structSetBool(location, "serverComplete", true);
}

bool IsServerComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("IsServerComplete: Location does not exist: %d", locationId);
    }

    return (structGetBool(location, "serverComplete"));
}