import json
import os
from typing import Any

from AoE2ScenarioParser.scenarios.aoe2_de_scenario import AoE2DEScenario, TriggerManager, UnitManager

from setup_pavilion import APavilionMaker

with open("Data/VictoryPavilionLocations.json", 'r') as file:
    data: dict = json.load(file)
    
    for (file, location) in data.items():
        scenario: AoE2DEScenario = AoE2DEScenario.from_file(os.getcwd() + "/age 2 files/resources/_common/scenario/" + f"{file}.aoe2scenario")
        
        trigger_manager = scenario.trigger_manager
        
        if not any(trigger.name == "-- AP --" for trigger in trigger_manager.triggers):
            trigger_manager.add_trigger("-- AP --")
        
        
        if not any(trigger.name == "AP Ping" for trigger in trigger_manager.triggers):
            ping = trigger_manager.add_trigger("AP Ping")
            ping.looping = True
            
            ping.new_effect.script_call(message="AP_Write();")
        
        pavilion_maker: APavilionMaker = APavilionMaker(scenario, x=location["x"], y=location["y"])
        pavilion_maker.add_pavilion()
        pavilion_maker.add_victory_triggers()
        scenario.write_to_file(f"{file}.aoe2scenario")