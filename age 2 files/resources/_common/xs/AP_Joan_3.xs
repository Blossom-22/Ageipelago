include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("JOAN3");
}

void main() {
  SetScenarioId(203);
  xsEnableRule("InitAP");
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20300);
}

void FindBoats() {
  AP_Check_Location(20301);
}

void SlayFastolf() {
  AP_Check_Location(20302);
}

void DestroyOneCastle() {
  AP_Check_Location(20303);
}

void DestroyTwoCastles() {
  AP_Check_Location(20304);
}

void DestroyLeftCastle() {
  AP_Check_Location(20305);
}

void DestroyCentralCastle() {
  AP_Check_Location(20306);
}

void DestroyRightCastle() {
  AP_Check_Location(20307);
}

void DestroyRearCastle() {
  AP_Check_Location(20308);
}
