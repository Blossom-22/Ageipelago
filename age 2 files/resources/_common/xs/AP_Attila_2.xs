include "./AP.xs";


void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT2");
}

void main() {
  SetScenarioId(102);
  xsEnableRule("InitAP");
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10200);
}

void RedTC() {
  AP_Check_Location(10201);
}

void GreenLumber() {
  AP_Check_Location(10202);
}

void PurpleVils() {
  AP_Check_Location(10203);
}

void GreyMining() {
  AP_Check_Location(10204);
}

void CyanTC() {
  AP_Check_Location(10205);
}

void ScythianVils() {
  AP_Check_Location(10206);
}

void BuildTC() {
  AP_Check_Location(10207);
}

void BeatTheRomans() {
  AP_Check_Location(10208);
}

void DefeatsanityRed() {
  AP_Check_Location(10209);
}

void DefeatsanityGreen() {
  AP_Check_Location(10210);
}

void DefeatsanityPurple() {
  AP_Check_Location(10211);
}

void DefeatsanityGrey() {
  AP_Check_Location(10212);
}

void DefeatsanityCyan() {
  AP_Check_Location(10213);
}

void DefeatsanityOrange() {
  AP_Check_Location(10214);
}
