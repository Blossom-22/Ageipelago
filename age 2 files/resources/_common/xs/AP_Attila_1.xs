include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT1");
}

void main() {
  SetScenarioId(101);
  xsEnableRule("InitAP");
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10100);
}

void UniteTheHuns() {
  AP_Check_Location(10101);
}

void FreeVillagers() {
  AP_Check_Location(10102);
}

void ResolveScoutAny() {
  AP_Check_Location(10103);
}

void CaptureHorsesCamp() {
  AP_Check_Location(10104);
}

void CaptureHorseRuins() {
  AP_Check_Location(10105);
}

void CaptureHorsesLumber() {
  AP_Check_Location(10106);
}

void CaptureHorsesBehindBase() {
  AP_Check_Location(10107);
}

void CaptureHorsesWest() {
  AP_Check_Location(10108);
}

void CaptureHorsesRoman() {
  AP_Check_Location(10109);
}

void KillTheBoar() {
  AP_Check_Location(10110);
}

void BetrayBleda() {
  AP_Check_Location(10111);
}

void BlowBledaOff() {
  AP_Check_Location(10112);
}

void FreeScout() {
  AP_Check_Location(10113);
}

void KillScout() {
  AP_Check_Location(10114);
}

void GiveHorses() {
  AP_Check_Location(10115);
}

void DefeatFirstPlayer() {
  AP_Check_Location(10116);
}

void DefeatsanityBlue() {
AP_Check_Location(10117);
}

void DefeatsanityRed() {
AP_Check_Location(10118);
}

void DefeatsanityGreen() {
AP_Check_Location(10119);
}

void DefeatsanityPurple() {
AP_Check_Location(10120);
}
