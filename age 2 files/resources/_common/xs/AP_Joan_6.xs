include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("JOAN6");
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(20600, 20604);
}

void main() {
  SetScenarioId(206);
  xsEnableRule("InitAP");
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20600);
}

void LaHire() {
  AP_Check_Location(20601);
}

void FrenchArmy() {
  AP_Check_Location(20602);
}

void FrenchArtillery() {
  AP_Check_Location(20603);
}

void BurgundianTown() {
  AP_Check_Location(20604);
}