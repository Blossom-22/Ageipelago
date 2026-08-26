include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("JOAN2");
}

void main() {
  SetScenarioId(202);
  xsEnableRule("InitAP");
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20200);
}

void ReachBlois() {
  AP_Check_Location(20201);
}

void FindDock() {
  AP_Check_Location(20202);
}

void DefeatBurgundyBlois() {
  AP_Check_Location(20203);
}

void ConquerBridge() {
  AP_Check_Location(20204);
}

void BringJoanToOrleans() {
  AP_Check_Location(20205);
}

void BringCartsToOrleans() {
  AP_Check_Location(20206);
}

void FindFarmingVillage() {
  AP_Check_Location(20207);
}

void NortheastCastle() {
  AP_Check_Location(20208);
}

void NorthwestCastle() {
  AP_Check_Location(20209);
}

void SoutheastCastle() {
  AP_Check_Location(20210);
}

void SouthwestCastle() {
  AP_Check_Location(20211);
}