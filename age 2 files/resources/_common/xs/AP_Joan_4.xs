include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(20400, 20405);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("JOAN4");
}

void main() {
  SetScenarioId(204);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20400);
}

void DefeatEnglishGuards() {
  AP_Check_Location(20401);
}

void ReachBase() {
  AP_Check_Location(20402);
}

void DestroyTroyesTC() {
  AP_Check_Location(20403);
}

void DestroyChalonsTC() {
  AP_Check_Location(20404);
}

void DestroyRheimsTC() {
  AP_Check_Location(20405);
}

void DefeatsanityRed() {
AP_Check_Location(10117);
}

void DefeatsanityGreen() {
AP_Check_Location(10117);
}

void DefeatsanityOrange() {
AP_Check_Location(10117);
}

void DefeatsanityYellow() {
AP_Check_Location(10117);
}
