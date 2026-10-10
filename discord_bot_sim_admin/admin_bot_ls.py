import discord
import asyncio
import urllib.parse
import urllib.request
import json
import os
from discord import app_commands
from typing import List

CONFIG_FILE = 'config.json'

if not os.path.exists(CONFIG_FILE):
    raise FileNotFoundError(f"Please create a '{CONFIG_FILE}' file based on the template.")

def load_simhosts() -> List[dict]:
    try:
        with open(CONFIG_FILE, 'r') as f:
            current_config = json.load(f)
        return current_config.get("simhosts", [])
    except Exception as e:
        print(f"Error reading configuration file: {e}")
        return []

with open(CONFIG_FILE, 'r') as f:
    initial_config = json.load(f)

TOKEN = initial_config.get("token", "test")
GUILD_ID = initial_config.get("guild_id", 0)

class AClient(discord.Client):
    def __init__(self):
        super().__init__(intents=discord.Intents.default())

    async def setup_hook(self):
        await tree.sync(guild=discord.Object(id=GUILD_ID))
        print("Application commands synced.")

    async def on_ready(self):
        print(f"Online and ready as {self.user}.")

client = AClient()
tree = app_commands.CommandTree(client)

async def sim_autocomplete(interaction: discord.Interaction, current: str) -> List[app_commands.Choice[str]]:
    choices = [app_commands.Choice(name="All Sims", value="ALL")]
    search_term = current.lower()
    simhosts = load_simhosts()
    for host in simhosts:
        name = host.get("name", "Unknown Sim")
        if search_term in name.lower():
            choices.append(app_commands.Choice(name=name, value=name))
    try:
        return choices[:25]
    except discord.errors.NotFound:
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
    for host in simhosts:
        name = host.get("name", "Unknown Sim")
        url = host.get("url")
        if not url:
            continue
        if target_sim == "ALL" or target_sim == name:
            tasks.append(loop.run_in_executor(None, submit_information_to_single_url, name, url, parameters))
    if not tasks:
        return "sim configuration not found."
    results = await asyncio.gather(*tasks)
    return "\n".join(results)

async def handle_command_logic(interaction: discord.Interaction, action_key: str, input_uuid: str, sim: str):
    await interaction.response.defer() 
    
    admin_user = interaction.user
    admin_log_str = f"**Executed By**: {admin_user.mention} ({admin_user.name})"
    
    cleaned_uuid = input_uuid.strip().lower()
    
    protected_list = []
    try:
        with open(CONFIG_FILE, 'r') as f:
            current_config = json.load(f)
            raw_protected = current_config.get("protected_uuids", [])
            protected_list = [str(uid).strip().lower() for uid in raw_protected]
    except Exception as e:
        print(f"Error checking protected list: {e}")

    punishment_actions = ['banned','unpass']
    
    if cleaned_uuid in protected_list and action_key in punishment_actions:
        action_key = 'blocked'
    
    parameters = {action_key: cleaned_uuid}
    combined_responses = await execute_command(parameters, sim)
    
    final_output = f"{admin_log_str}\n{combined_responses}"
    
    if len(final_output) > 2000:
        final_output = final_output[:1995] + "..."
        
    await interaction.followup.send(final_output)
    
    if action_key == 'scan_uuid':
        print(f"[Terminal Log] [Analyzer] Command used by: {admin_user.name} | Scanned Target UUID: {cleaned_uuid} on Sim: {sim}")
    else:
        print(f"[Terminal Log] [{action_key.upper()}] Command used by: {admin_user.name} | Target: {cleaned_uuid} | Response:\n{combined_responses}")

@tree.command(guild=discord.Object(id=GUILD_ID), name='sim_info', description='Scan sim.')
@app_commands.autocomplete(sim=sim_autocomplete)
async def cmd_sim_info(interaction: discord.Interaction, sim: str):
    await handle_command_logic(interaction, 'scan_sim', 'none', sim)

@tree.command(guild=discord.Object(id=GUILD_ID), name='avatar_info', description='Scan avatar inventory.')
@app_commands.autocomplete(sim=sim_autocomplete)
async def cmd_avatar_info(interaction: discord.Interaction, input_uuid: str, sim: str):
    await handle_command_logic(interaction, 'scan_avatar', input_uuid, sim)

@tree.command(guild=discord.Object(id=GUILD_ID), name='unpass', description='input_uuid')
@app_commands.autocomplete(sim=sim_autocomplete)
async def cmd_estate_unpass(interaction: discord.Interaction, input_uuid: str, sim: str):
    await handle_command_logic(interaction, 'unpass', input_uuid, sim)

@tree.command(guild=discord.Object(id=GUILD_ID), name='pass', description='input_uuid')
@app_commands.autocomplete(sim=sim_autocomplete)
async def cmd_estate_pass(interaction: discord.Interaction, input_uuid: str, sim: str):
    await handle_command_logic(interaction, 'pass', input_uuid, sim)

@tree.command(guild=discord.Object(id=GUILD_ID), name='unbanned', description='input_uuid')
@app_commands.autocomplete(sim=sim_autocomplete)
async def cmd_estate_unbanned(interaction: discord.Interaction, input_uuid: str, sim: str):
    await handle_command_logic(interaction, 'unbanned', input_uuid, sim)

@tree.command(guild=discord.Object(id=GUILD_ID), name='banned', description='input_uuid')
@app_commands.autocomplete(sim=sim_autocomplete)
async def cmd_estate_banned(interaction: discord.Interaction, input_uuid: str, sim: str):
    await handle_command_logic(interaction, 'banned', input_uuid, sim)

client.run(TOKEN)
