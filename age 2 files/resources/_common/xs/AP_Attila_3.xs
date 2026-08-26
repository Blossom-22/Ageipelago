include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT3");
}

void main() {
  SetScenarioId(103);
  xsEnableRule("InitAP");
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10300);
}

void GreenDock1() {
  AP_Check_Location(10301);
}

void GreenDock2() {
  AP_Check_Location(10302);
}

void FindGold() {
  AP_Check_Location(10303);
}

void GreenTC() {
  AP_Check_Location(10304);
}

void BlueDockNorth() {
  AP_Check_Location(10305);
}

void BlueDocksSouth() {
  AP_Check_Location(10306);
}

void BuildCastle() {
  AP_Check_Location(10307);
}

void RedTradeCarts() {
  AP_Check_Location(10308);
}

void RedTC() {
  AP_Check_Location(10309);
}

void BlueCogs() {
  AP_Check_Location(10310);
}

void RedDock() {
  AP_Check_Location(10311);
}

void RedMarket() {
  AP_Check_Location(10312);
}

void ThreatenWonder() {
  AP_Check_Location(10313);
}

void DestroyWonder() {
  AP_Check_Location(10314);
}

void BlueMonastery() {
    AP_Check_Location(10315);
}

void DefeatsanityBlue() {
    AP_Check_Location(10316);
}

void DefeatsanityGreen() {
    AP_Check_Location(10317);
}

void DefeatsanityRed() {
    AP_Check_Location(10318);
}
