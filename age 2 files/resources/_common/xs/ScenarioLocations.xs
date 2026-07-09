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

vector AddLocation(int id = -1, bool scenarioComplete = false, bool serverComplete = false) {
    vector location = new("Location");
    structSetInt(location, "id", id);
    structSetBool(location, "scenarioComplete", scenarioComplete);
    structSetBool(location, "serverComplete", serverComplete);
    return (location);
}

int AddLocations(int idStart = -1, int idEnd = -1, bool scenarioComplete = false, bool serverComplete = false) {
    if (idStart == -1 || idEnd == -1 || idStart > idEnd) {
        xsChatData("Invalid start and end id for AddLocations: idStart = " + idStart + ", idEnd = " + idEnd);
        return (-1);
    }

    int arrayLength = idEnd - idStart;
    int array = xsArrayCreateVector(arrayLength, cInvalidVector);

    for (i = idStart; < idEnd) {
        vector location = AddLocation(i, scenarioComplete, serverComplete);
        xsArraySetVector(array, i - idStart, location);
    }

    return (array);
}

void InitLocations() {
    defineStruct("Location");
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

void SetScenarioLocationComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("SetScenarioLocationComplete: Location does not exist: %d", locationId);
    }

    structSetBool(location, "scenarioComplete", true);
}

bool IsScenarioLocationComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("IsScenarioLocationComplete: Location does not exist: %d", locationId);
    }

    return (structGetBool(location, "scenarioComplete"));
}

void SetServerLocationComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("SetServerLocationComplete: Location does not exist: %d", locationId);
    }

    structSetBool(location, "serverComplete", true);
}

bool IsServerLocationComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("IsServerLocationComplete: Location does not exist: %d", locationId);
    }

    return (structGetBool(location, "serverComplete"));
}