include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT5");
}

void main() {
  SetScenarioId(105);
  xsEnableRule("InitAP");
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10500);
}

void DefeatRomans() {
  AP_Check_Location(10501);
}

void DefeatVisigoths() {
  AP_Check_Location(10502);
}

void DefeatAlans() {
  AP_Check_Location(10503);
}

void DefeatsanityGrey() {
  AP_Check_Location(10504);
}

void DefeatsanityRed() {
  AP_Check_Location(10505);
}
