include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT6");
}

void main() {
  SetScenarioId(106);
  xsEnableRule("InitAP");
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10600);
}

void DefeatPatavium() {
  AP_Check_Location(10601);
}

void DefeatMediolanum() {
  AP_Check_Location(10602);
}

void DefeatAquileia() {
  AP_Check_Location(10603);
}

void DefeatVerona() {
  AP_Check_Location(10604);
}

void DefeatTheItalians() {
  AP_Check_Location(10605);
}

void MeetThePope() {
  AP_Check_Location(10606);
}

void DestroyPurpleWonder() {
  AP_Check_Location(10607);
}

void DestroyGreenWonder() {
  AP_Check_Location(10608);
}

void DestroyRedWonder() {
  AP_Check_Location(10609);
}

void DestroyOrangeWonder() {
  AP_Check_Location(10610);
}

void DestroyPurpleWonder2() {
  AP_Check_Location(10611);
}

void DefeatsanityBlue() {
  AP_Check_Location(10612);
}
