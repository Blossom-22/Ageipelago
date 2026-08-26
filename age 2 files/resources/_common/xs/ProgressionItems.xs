//General Items
void TOWN_CENTER_WOOD() {
    xsEffectAmount(cModResource, cAttributeWood, cAttributeAdd, 275.0);
}

void TOWN_CENTER_STONE() {
    xsEffectAmount(cModResource, cAttributeStone, cAttributeAdd, 100.0);
}

// Scenario-specific items

//Attila 1
bool bledasCamp = false;
void ATTILA_1_BLEDAS_CAMP() {
    bledasCamp = true;
}

bool HAS_BLEDAS_CAMP() {
    return (bledasCamp);
}

bool attilasCamp = false;
void ATTILA_1_ATTILAS_CAMP() {
    attilasCamp = true;
}

bool HAS_ATTILAS_CAMP() {
    return (attilasCamp);
}

//Attila 2
bool attila2Villagers = false;
void ATTILA_2_VILLAGERS_TRIGGER() {
    attila2Villagers = true;
}

bool HAS_ATTILA_2_VILLAGERS() {
    return (attila2Villagers);
}

//Attila 3
bool attila3RedGold = false;
void ATTILA_3_RED_GOLD() {
    attila3RedGold = true;
}

bool HAS_ATTILA_3_RED_GOLD() {
    return (attila3RedGold);
}

bool attila3GreenGold = false;
void ATTILA_3_GREEN_GOLD() {
    attila3GreenGold = true;
}

bool HAS_ATTILA_3_GREEN_GOLD() {
    return (attila3GreenGold);
}

//Joan 1
bool joan1Transports = false;
void Joan1Transports() {
    joan1Transports = true;
}

bool HasJoan1Transports() {
    return (joan1Transports);
}

//Joan 2
bool joan2Carts = false;
void Joan2Carts() {
    joan2Carts = true;
}

bool HasJoan2Carts() {
    return (joan2Carts);
}

bool joan2Orleans = false;
void Joan2Orleans() {
    joan2Orleans = true;
}

bool HasJoan2Orleans() {
    return (joan2Orleans);
}

bool joan2Dock = false;
void Joan2Dock() {
    joan2Dock = true;
}

bool HasJoan2Dock() {
    return (joan2Dock);
}

// Joan 3
bool joan3Boats = false;
void Joan3Boats() {
    joan3Boats = true;
}

bool HasJoan3Boats() {
    return (joan3Boats);
}

// Joan 4
bool joan4Base = false;
void Joan4Base() {
    joan4Base = true;
}

bool HasJoan4Base() {
    return (joan4Base);
}

// Joan 5
bool joan5Refugee1 = false;
void Joan5Refugee1() {
    joan5Refugee1 = true;
}

bool HasJoan5Refugee1() {
    return (joan5Refugee1);
}

bool joan5Refugee2 = false;
void Joan5Refugee2() {
    joan5Refugee2 = true;
}

bool HasJoan5Refugee2() {
    return (joan5Refugee2);
}

bool joan5Refugee3 = false;
void Joan5Refugee3() {
    joan5Refugee3 = true;
}

bool HasJoan5Refugee3() {
    return (joan5Refugee3);
}

bool joan5Refugee4 = false;
void Joan5Refugee4() {
    joan5Refugee4 = true;
}

bool HasJoan5Refugee4() {
    return (joan5Refugee4);
}

bool joan5Refugee5 = false;
void Joan5Refugee5() {
    joan5Refugee5 = true;
}

bool HasJoan5Refugee5() {
    return (joan5Refugee5);
}

bool joan5Refugee6 = false;
void Joan5Refugee6() {
    joan5Refugee6 = true;
}

bool HasJoan5Refugee6() {
    return (joan5Refugee6);
}

bool joan5Refugee7 = false;
void Joan5Refugee7() {
    joan5Refugee7 = true;
}

bool HasJoan5Refugee7() {
    return (joan5Refugee7);
}

bool joan5Refugee8 = false;
void Joan5Refugee8() {
    joan5Refugee8 = true;
}

bool HasJoan5Refugee8() {
    return (joan5Refugee8);
}

bool joan5Refugee9 = false;
void Joan5Refugee9() {
    joan5Refugee9 = true;
}

bool HasJoan5Refugee9() {
    return (joan5Refugee9);
}

bool joan5Refugee10 = false;
void Joan5Refugee10() {
    joan5Refugee10 = true;
}

bool HasJoan5Refugee10() {
    return (joan5Refugee10);
}

// Joan 6
bool joan6Army = false;
void Joan6Army() {
    joan6Army = true;
}

bool HasJoan6Army() {
    return (joan6Army);
}

void GiveProgressionItem(int itemId = -1) {
    switch(itemId) {
        case 1000: {
            TOWN_CENTER_WOOD();
        }
        case 1001: {
            TOWN_CENTER_STONE();
        }
        case 1002: {
            ATTILA_1_BLEDAS_CAMP();
        }
        case 1003: {
            ATTILA_1_ATTILAS_CAMP();
        }
        case 1004: {
            ATTILA_2_VILLAGERS_TRIGGER();
        }
        case 1005: {
            ATTILA_3_RED_GOLD();
        }
        case 1006: {
            ATTILA_3_GREEN_GOLD();
        }
        case 1007: {
            Joan1Transports();
        }
        case 1008: {
            Joan2Orleans();
        }
        case 1009: {
            Joan2Carts();
        }
        case 1010: {
            Joan2Dock();
        }
        case 1011: {
            Joan3Boats();
        }
        case 1012: {
            Joan4Base();
        }
        case 1013: {
            Joan5Refugee1();
        }
        case 1014: {
            Joan5Refugee2();
        }
        case 1015: {
            Joan5Refugee3();
        }
        case 1016: {
            Joan5Refugee4();
        }
        case 1017: {
            Joan5Refugee5();
        }
        case 1018: {
            Joan5Refugee6();
        }
        case 1019: {
            Joan5Refugee7();
        }
        case 1020: {
            Joan5Refugee8();
        }
        case 1021: {
            Joan5Refugee9();
        }
        case 1022: {
            Joan5Refugee10();
        }
        case 1023: {
            Joan6Army();
        }
    }
}