include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(10400, 10407);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("ATT4");
}

void main() {
  SetScenarioId(104);
  InitAP()
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10400);
}

void DefeatBurgundyAll() {
  AP_Check_Location(10401);
}

void DefeatMetz() {
  AP_Check_Location(10402);
}

void DefeatOrleans() {
  AP_Check_Location(10403);
}

void DefeatRomanArmy() {
  AP_Check_Location(10404);
}

void TributeBurgundyAll() {
  AP_Check_Location(10405);
}

void CastleBurgundyAll() {
  AP_Check_Location(10406);
}

void DefeatOrAllyBurgundyAny() {
  AP_Check_Location(10407);
}
