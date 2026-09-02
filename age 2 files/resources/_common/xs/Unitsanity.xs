vector unitsanity = cInvalidVector;

vector disableUnit(string name = "", int id = -1, float cost = 0.0, int locationId = -1) {
    vector unit = new("Unit");
    structSetString(unit, "name", name);
    structSetInt(unit, "id", id);
    structSetInt(unit, "playerCount", xsGetObjectCount(1, structGetInt(unit, "id")));
    structSetFloat(unit, "resourceCost", cost);
    structSetInt(unit, "locationId", locationId);
    xsEffectAmount(cSetAttribute, id, cDisabledFlag, 1.0, 1);
    return (unit);
}

void InitUnitsanityStructs() {
    defineStruct("Unit");
    defineStructAttribute("Unit", "name", TYPE_STRING);
    defineStructAttribute("Unit", "id", TYPE_INT);
    defineStructAttribute("Unit", "playerCount", TYPE_INT);
    defineStructAttribute("Unit", "resourceCost", TYPE_FLOAT);
    defineStructAttribute("Unit", "locationId", TYPE_INT);

    defineStruct("Unitsanity");
    defineStructAttribute("Unitsanity", "units", TYPE_STRUCT_ARRAY);
    defineStructAttribute("Unitsanity", "currentUnitTotalCost", TYPE_FLOAT);

    unitsanity = new("Unitsanity");
    int units = xsArrayCreateVector(50, cInvalidVector, "p1-units");
    structSetInt(unitsanity, "units", units);
}

// Town Center
const int villager = 83;

// Market
const int trade_cart = 128;



// Archery Range
const int archer = 4;
const int crossbowman = 24;
const int arbalester = 492;
const int skirmisher = 7;
const int elite_skirmisher = 6;
const int imperial_skirmisher = 1155;
const int cavalry_archer = 39;
const int heavy_cavalry_archer = 474;
const int hand_cannoneer = 5;
const int slinger = 185;
const int grenadier = 1911;
const int genitour = 1010;
const int elite_genitour = 1012;
const int elephant_archer = 873;
const int elite_elephant_archer = 875;
const int xianbeiRaider = 1952;
const int bolasRider = 2569;
const int eliteBolasRider = 2571;

// Barracks
const int militia = 74;
const int man_at_arms = 75;
const int long_swordsman = 77;
const int two_handed_swordsman = 473;
const int champion = 567;
const int legionary = 1793;
const int spearman = 93;
const int pikeman = 358;
const int halberdier = 359;
const int eagle_warrior = 751;
const int heavy_eagle_warrior = 753;
const int elite_eagle_warrior = 752;
const int champiScout = 2550;
const int champiRunner = 2588;
const int champiWarrior = 2552;
const int eliteChampiWarrior = 2554;
const int fireLancer = 1901;
const int eliteFireLancer = 1903;
const int condottiero = 882;
const int huskarlBarracks = 759;
const int eliteHuskarlBarracks = 761;
const int town_center_flemish_pikeman = 1699;
const int jianSwordsman = 1794;
const int templeGuard = 2586;
const int eliteTempleGuard = 2587;
const int ibirapemaWarrior = 2582;
const int eliteIbirapemaWarrior = 2584;
const int warDog = 2612;
const int eliteWarDog = 2613;

// Stable
const int scout_cavalry = 448;
const int light_cavalry = 546;
const int hussar = 441;
const int winged_hussar = 1707;
const int knight = 38;
const int cavalier = 283;
const int paladin = 569;
const int savar = 1814;
const int camel_scout = 1755;
const int camel_rider = 329;
const int heavy_camel_rider = 330;
const int imperial_camel_rider = 207;
const int battle_elephant = 1132;
const int elite_battle_elephant = 1134;
const int steppe_lancer = 1370;
const int elite_steppe_lancer = 1372;
const int hei_guang_cavalry = 1944;
const int heavy_hei_guang_cavalry = 1946;
const int shrivamsha_rider = 1751;
const int elite_shrivamsha_rider = 1753;
const int stable_tarkan = 886;
const int stable_elite_tarkan = 887;
const int xolotlWarrior = 1570;

// Siege Workshop
const int feudal_battering_ram = 1258;
const int battering_ram = 35;
const int capped_ram = 422;
const int siege_ram = 548;
const int armored_elephant = 1744;
const int siege_elephant = 1746;
const int mangonel = 280;
const int onager = 550;
const int siege_onager = 588;
const int rocketCart = 1904;
const int heavyRocketCart = 1907;
const int scorpion = 279;
const int heavy_scorpion = 542;
const int warChariot = 1962;
const int bombard_cannon = 36;
const int houfnice = 1709;
const int tractionTrebuchet = 1942;
const int mountedTrebuchet = 1923;
const int siegeTower = 1105;

// Monastery
const int monk = 125;               // also disable with Economy
const int missionary = 775;
const int warrior_priest = 1811;    // also disable with Economy

// Krepost
const int krepost_konnik = 1254;
const int elite_krepost_konnik = 1255;

// Donjon
const int donjon_serjeant = 1660;
const int elite_donjon_serjeant = 1661;
const int spearmanDonjon = 1786;
const int pikemanDonjon = 1787;
const int halberdierDonjon = 1788;

// Castle
const int trebuchet = 331;
const int petard = 440;
const int composite_bowman = 1800;
const int elite_composite_bowman = 1802;
const int jaguar_warrior = 725;
const int elite_jaguar_warrior = 726;
const int ratha = 1759;
const int elite_ratha = 1761;
const int camel_archer = 1007;
const int elite_camel_archer = 1009;
const int longbowman = 8;
const int elite_longbowman = 530;
const int hussite_wagon = 1704;
const int elite_hussite_wagon = 1706;
const int konnik = 1225;
const int elite_konnik = 1227;
const int coustillier = 1655;
const int elite_coustillier = 1657;
const int arambai = 1126;
const int elite_arambai = 1128;
const int cataphract = 40;
const int elite_cataphract = 553;
const int woad_raider = 232;
const int elite_woad_raider = 534;
const int chu_ko_nu = 73;
const int elite_chu_ko_nu = 559;
const int kipchak = 1231;
const int elite_kipchak = 1233;
const int urumi_swordsman = 1735;
const int elite_urumi_swordsman = 1737;
const int shotel_warrior = 1016;
const int elite_shotel_warrior = 1018;
const int throwing_axeman = 281;
const int elite_throwing_axeman = 531;
const int monaspa = 1803;
const int elite_monaspa = 1805;
const int huskarl = 41;
const int elite_huskarl = 555;
const int chakram_thrower = 1741;
const int elite_chakram_thrower =1743 ;
const int ghulam = 1747;
const int elite_ghulam = 1749;
const int tarkan = 755;
const int elite_tarkan = 757;
const int kamayuk = 879;
const int elite_kamayuk = 881;
const int genoese_crossbowman = 866;
const int elite_genoese_crossbowman = 868;
const int samurai = 291;
const int elite_samurai = 560;
const int iron_pagoda = 1908;
const int elite_iron_pagoda = 1910;
const int liao_dao = 1920;
const int elite_liao_dao = 1922;
const int ballista_elephant = 1120;
const int elite_ballista_elephant = 1122;
const int war_wagon = 827;
const int elite_war_wagon = 829;
const int leitis = 1234;
const int elite_leitis = 1236;
const int magyar_huszar = 869;
const int elite_magyar_huszar = 871;
const int karambit_warrior = 1123;
const int elite_karambit_warrior = 1125;
const int gbeto = 1213;
const int elite_gbeto = 1215;
const int plumed_archer = 763;
const int elite_plumed_archer = 765;
const int mangudai = 11;
const int elite_mangudai = 561;
const int war_elephant = 239;
const int elite_war_elephant = 558;
const int obuch = 1701;
const int elite_obuch = 1703;
const int organ_gun = 1001;
const int elite_organ_gun = 1003;
const int centurion = 1790;
const int elite_centurion = 1792;
const int mameluke = 282;
const int elite_mameluke = 556;
const int white_feather_guard = 1959;
const int elite_white_feather_guard = 1961;
const int serjeant = 1658;
const int elite_serjeant = 1659;
const int boyar = 876;
const int elite_boyar = 878;
const int conquistador = 771;
const int elite_conquistador = 773;
const int keshik = 1228;
const int elite_keshik = 1230;
const int flaming_camel = 1263;
const int teutonic_knight = 25;
const int elite_teutonic_knight = 554;
const int janissary = 46;
const int elite_janissary = 557;
const int rattan_archer = 1129;
const int elite_rattan_archer = 1131;
const int berserk = 692;
const int elite_berserk = 694;
const int tiger_cavalry = 1949;
const int elite_tiger_cavalry = 1951;
const int fire_archer = 1968;
const int elite_fire_archer = 1970;
const int qizilbashWarrior = 1817;
const int eliteQizilbashWarrior = 1829;
const int blackwoodArcher = 2579;
const int eliteBlackwoodArcher = 2581;
const int kona = 2566;
const int eliteKona = 2568;
const int guechaWarrior = 2562;
const int eliteGuechaWarrior = 2564;


// Dock
const int fishing_ship = 13;      // also disable with Economy
const int trade_cog = 17;         // also disable with Economy
const int transport_ship = 545;
const int galley = 539;
const int war_galley = 21;
const int galleon = 442;
const int fire_galley = 1103;
const int fire_ship = 529;
const int fast_fire_ship = 532;
const int dragonShip = 1302;
const int demo_raft = 1104;
const int demolition_ship = 527;
const int heavy_demolition_ship = 528;
const int cannon_galleon = 420;
const int elite_cannon_galleon = 691;
const int dromon = 1795;
const int louChuan = 1948;
const int thirisadai = 1750;
const int turtle_ship = 831;
const int elite_turtle_ship = 832;
const int caravel = 1004;
const int elite_caravel = 1006;
const int longboat = 250;
const int elite_longboat = 533;
const int hulk = 2626;
const int warHulk = 2627;
const int carrack = 2628;
const int catapultGalleon = 2633;



void InitUnitsanityEconomy() {
    xsEffectAmount(cEnableObject, villager, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, trade_cart, cAttributeSet, 0.0, 1);
}

void InitUnitsanityArchery() {
    xsEffectAmount(cSetAttribute, archer, cDisabledFlag, 1.0, 1);
    xsEffectAmount(cSetAttribute, crossbowman, cDisabledFlag, 1.0, 1);
    xsEffectAmount(cSetAttribute, arbalester, cDisabledFlag, 1.0, 1);

    xsEffectAmount(cEnableObject, skirmisher, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_skirmisher, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, imperial_skirmisher, cAttributeDisable, 0.0, 1);

    xsEffectAmount(cEnableObject, cavalry_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, heavy_cavalry_archer, cAttributeDisable, 0.0, 1);

    xsEffectAmount(cEnableObject, hand_cannoneer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, slinger, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, grenadier, cAttributeDisable, 0.0, 1);

    xsEffectAmount(cEnableObject, genitour, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_genitour, cAttributeDisable, 0.0, 1);

    xsEffectAmount(cEnableObject, elephant_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_elephant_archer, cAttributeDisable, 0.0, 1);

    xsEffectAmount(cEnableObject, xianbeiRaider, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, bolasRider, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, eliteBolasRider, cAttributeDisable, 0.0, 1);
}

void InitUnitsanityBarracks() {
    xsEffectAmount(cEnableObject, militia, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, man_at_arms, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, long_swordsman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, two_handed_swordsman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, champion, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, legionary, cAttributeDisable, 0.0, 1);
    
    xsEffectAmount(cEnableObject, spearman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, pikeman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, halberdier, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, eagle_warrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, heavy_eagle_warrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_eagle_warrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, fireLancer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, eliteFireLancer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, condottiero, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, huskarlBarracks, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, eliteHuskarlBarracks, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, town_center_flemish_pikeman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, jianSwordsman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, templeGuard, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, eliteTempleGuard, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, ibirapemaWarrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, eliteIbirapemaWarrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, warDog, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, eliteWarDog, cAttributeDisable, 0.0, 1);
}

void InitUnitsanityStable() {
    xsEffectAmount(cEnableObject, scout_cavalry, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, light_cavalry, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, hussar, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, winged_hussar, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, knight, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, cavalier, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, paladin, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, savar, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, camel_scout, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, camel_rider, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, heavy_camel_rider, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, imperial_camel_rider, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, battle_elephant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_battle_elephant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, steppe_lancer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_steppe_lancer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, hei_guang_cavalry, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, heavy_hei_guang_cavalry, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, shrivamsha_rider, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_shrivamsha_rider, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, stable_tarkan, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, stable_elite_tarkan, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, xolotlWarrior, cAttributeDisable, 0.0, 1);
}

void InitUnitsanitySiegeWorkshop() {
    xsEffectAmount(cEnableObject, feudal_battering_ram, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, battering_ram, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, capped_ram, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, siege_ram, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, armored_elephant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, siege_elephant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, mangonel, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, onager, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, siege_onager, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, rocketCart, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, heavyRocketCart, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, scorpion, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, heavy_scorpion, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, warChariot, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, bombard_cannon, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, houfnice, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, tractionTrebuchet, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, mountedTrebuchet, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, siegeTower, cAttributeDisable, 0.0, 1);
}

void InitUnitsanityMonastery() {
    xsEffectAmount(cEnableObject, monk, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, missionary, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, warrior_priest, cAttributeDisable, 0.0, 1);
}

void InitUnitsanityKrepost() {
    xsEffectAmount(cEnableObject, krepost_konnik, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_krepost_konnik, cAttributeDisable, 0.0, 1);
}

void InitUnitsanityDonjon() {
    xsEffectAmount(cEnableObject, donjon_serjeant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_donjon_serjeant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, spearmanDonjon, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, pikemanDonjon, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, halberdierDonjon, cAttributeDisable, 0.0, 1);
}

void InitUnitsanityCastle() {
    xsEffectAmount(cEnableObject, trebuchet, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, petard, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, composite_bowman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_composite_bowman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, jaguar_warrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_jaguar_warrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, ratha, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_ratha, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, camel_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_camel_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, longbowman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_longbowman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, hussite_wagon, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_hussite_wagon, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, konnik, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_konnik, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, coustillier, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_coustillier, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, arambai, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_arambai, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, cataphract, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_cataphract, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, woad_raider, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_woad_raider, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, chu_ko_nu, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_chu_ko_nu, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, kipchak, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_kipchak, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, urumi_swordsman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_urumi_swordsman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, shotel_warrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_shotel_warrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, throwing_axeman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_throwing_axeman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, monaspa, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_monaspa, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, huskarl, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_huskarl, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, chakram_thrower, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_chakram_thrower, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, ghulam, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_ghulam, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, tarkan, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_tarkan, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, kamayuk, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_kamayuk, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elephant_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_elephant_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, genoese_crossbowman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_genoese_crossbowman, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, samurai, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_samurai, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, iron_pagoda, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_iron_pagoda, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, liao_dao, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_liao_dao, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, ballista_elephant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_ballista_elephant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, war_wagon, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_war_wagon, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, leitis, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_leitis, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, magyar_huszar, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_magyar_huszar, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, karambit_warrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_karambit_warrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, gbeto, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_gbeto, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, plumed_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_plumed_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, mangudai, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_mangudai, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, war_elephant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_war_elephant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, obuch, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_obuch, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, organ_gun, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_organ_gun, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, centurion, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_centurion, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, mameluke, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_mameluke, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, white_feather_guard, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_white_feather_guard, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, serjeant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_serjeant, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, boyar, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_boyar, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, conquistador, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_conquistador, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, keshik, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_keshik, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, flaming_camel, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, teutonic_knight, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_teutonic_knight, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, janissary, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_janissary, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, rattan_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_rattan_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, berserk, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_berserk, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, tiger_cavalry, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_tiger_cavalry, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, fire_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_fire_archer, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, qizilbashWarrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, eliteQizilbashWarrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, blackwoodArcher, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, eliteBlackwoodArcher, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, kona, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, eliteKona, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, guechaWarrior, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, eliteGuechaWarrior, cAttributeDisable, 0.0, 1);
}

void InitUnitsanityDock() {
    xsEffectAmount(cEnableObject, fishing_ship, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, trade_cog, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, transport_ship, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, galley, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, war_galley, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, galleon, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, fire_galley, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, fire_ship, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, fast_fire_ship, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, dragonShip, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, demo_raft, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, demolition_ship, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, heavy_demolition_ship, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, cannon_galleon, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_cannon_galleon, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, dromon, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, louChuan, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, thirisadai, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, turtle_ship, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_turtle_ship, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, caravel, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_caravel, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, longboat, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, elite_longboat, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, hulk, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, warHulk, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, carrack, cAttributeDisable, 0.0, 1);
    xsEffectAmount(cEnableObject, catapultGalleon, cAttributeDisable, 0.0, 1);
}
