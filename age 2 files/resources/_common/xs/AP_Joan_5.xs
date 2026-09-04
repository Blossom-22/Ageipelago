include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(20500, 20514);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("JOAN5");
}

void main() {
  SetScenarioId(205);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20500);
}

void Refugee1() {
  AP_Check_Location(20501);
}

void Refugee2() {
  AP_Check_Location(20502);
}

void Refugee3() {
  AP_Check_Location(20503);
}

void Refugee4() {
  AP_Check_Location(20504);
}

void Refugee5() {
  AP_Check_Location(20505);
}

void Refugee6() {
  AP_Check_Location(20506);
}

void Refugee7() {
  AP_Check_Location(20507);
}

void Refugee8() {
  AP_Check_Location(20508);
}

void Refugee9() {
  AP_Check_Location(20509);
}

void Refugee10() {
  AP_Check_Location(20510);
}

void Loyalists() {
  AP_Check_Location(20511);
}

void KingsTroop() {
  AP_Check_Location(20512);
}

void EscortJoan() {
  AP_Check_Location(20513);
}

void Escort6Refugees() {
  AP_Check_Location(20514);
}

void DefeatsanityRed() {
AP_Check_Location(10117);
}

void DefeatsanityPurple() {
AP_Check_Location(10117);
}

void DefeatsanityYellow() {
AP_Check_Location(10117);
}

void DefeatsanityCyan() {
AP_Check_Location(10117);
}
