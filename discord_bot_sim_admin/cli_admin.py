import asyncio
import urllib.parse
import urllib.request
import json
import os
import sys
from typing import List

CONFIG_FILE = 'config.json'

if not os.path.exists(CONFIG_FILE):
    print(f"Error: Please create a '{CONFIG_FILE}' file based on the template.", file=sys.stderr)
    sys.exit(1)

def load_simhosts() -> List[dict]:
    try:
        with open(CONFIG_FILE, 'r') as f:
            current_config = json.load(f)
        return current_config.get("simhosts", [])
    except Exception as e:
        print(f"Error reading configuration file: {e}", file=sys.stderr)
        return []

def submit_information_to_single_url(name, url, parameters):
    try:
        encoded_params = urllib.parse.urlencode(parameters).encode("utf-8")
        req = urllib.request.Request(url, data=encoded_params)
        with urllib.request.urlopen(req, timeout=20) as response:
            return f"**[{name}]**:\n{response.read().decode('utf-8')}"
    except Exception as e:
        return f"**[{name}]**: Error -> {str(e)}"

async def execute_command(parameters, target_sim: str):
    loop = asyncio.get_running_loop()
    tasks = []
    simhosts = load_simhosts()
    
    target_sim_lower = target_sim.lower()
    
    for host in simhosts:
        name = host.get("name", "Unknown Sim")
        url = host.get("url")
        if not url:
            continue
        if target_sim_lower == "all" or target_sim_lower == name.lower():
            tasks.append(loop.run_in_executor(None, submit_information_to_single_url, name, url, parameters))
            
    if not tasks:
        return "Sim configuration not found."
    results = await asyncio.gather(*tasks)
    return "\n".join(results)

async def handle_command_logic(action_key: str, input_uuid: str, sim: str):
    cleaned_uuid = input_uuid.strip().lower()
    
    protected_list = []
    try:
        with open(CONFIG_FILE, 'r') as f:
            current_config = json.load(f)
            raw_protected = current_config.get("protected_uuids", [])
            protected_list = [str(uid).strip().lower() for uid in raw_protected]
    except Exception as e:
        print(f"Error checking protected list: {e}", file=sys.stderr)

    punishment_actions = ['banned', 'unpass']
    
    if cleaned_uuid in protected_list and action_key in punishment_actions:
        action_key = 'blocked'
    
    parameters = {action_key: cleaned_uuid}
    combined_responses = await execute_command(parameters, sim)
    
    print("\n" + "="*40)
    print(combined_responses)
    print("="*40 + "\n")

def get_sim_input() -> str:
    simhosts = load_simhosts()
    sim_names = [host.get("name", "Unknown Sim") for host in simhosts if host.get("url")]
    
    print("\nAvailable Sims:")
    print("  [0] ALL")
    for idx, name in enumerate(sim_names, start=1):
        print(f"  [{idx}] {name}")
        
    while True:
        sim_choice = input("\nSelect Sim (Enter number or exact name): ").strip()
        if sim_choice == '0' or sim_choice.lower() == 'all':
            return "ALL"
            
        if sim_choice.isdigit():
            idx = int(sim_choice) - 1
            if 0 <= idx < len(sim_names):
                return sim_names[idx]
        
        for name in sim_names:
            if sim_choice.lower() == name.lower():
                return name
                
        print("Invalid selection. Please try again.")

async def main_menu():
    commands = [
        {"name": "Sim Info", "key": "scan_sim", "needs_uuid": False},
        {"name": "Avatar Info", "key": "scan_avatar", "needs_uuid": True},
        {"name": "Unpass", "key": "unpass", "needs_uuid": True},
        {"name": "Pass", "key": "pass", "needs_uuid": True},
        {"name": "Unbanned", "key": "unbanned", "needs_uuid": True},
        {"name": "Banned", "key": "banned", "needs_uuid": True}
    ]

    while True:
        print("\n=== SIM CONSOLE ===")
        for idx, cmd in enumerate(commands, start=1):
            print(f" [{idx}] {cmd['name']}")
        print(" [0] Exit")
        print("=" * 34)
        
        choice = input("Select an option: ").strip()
        
        if choice == '0':
            print("Exiting application.")
            break
            
        if choice.isdigit():
            cmd_idx = int(choice) - 1
            if 0 <= cmd_idx < len(commands):
                selected_cmd = commands[cmd_idx]
                
                target_sim = get_sim_input()
                
                target_uuid = "none"
                if selected_cmd["needs_uuid"]:
                    while True:
                        target_uuid = input("Enter Target UUID: ").strip()
                        if target_uuid:
                            break
                        print("UUID cannot be blank.")
                
                print(f"\nProcessing command '{selected_cmd['name']}'...")
                await handle_command_logic(selected_cmd["key"], target_uuid, target_sim)
                
                input("\nPress Enter to return to the main menu...")
                continue
                
        print("Invalid selection. Please choose a valid menu number.")

if __name__ == '__main__':
    try:
        asyncio.run(main_menu())
    except KeyboardInterrupt:
        print("\n\nOperation cancelled. Exiting program.")
        sys.exit(0)
