token = 'XXXX'
guild_id = 0000

import discord, asyncio
import urllib.parse
import urllib.request

enter_url = input("enter simhost url : ")

from discord import app_commands

class aclient(discord.Client):
    def __init__(self):
        super().__init__(intents = discord.Intents.default())
        self.synced = False

    async def on_ready(self):
        await self.wait_until_ready()
        if not self.synced:
            await tree.sync(guild = discord.Object(id=guild_id))
            self.synced = True
        print(f"online.")

def submitInformation(url,parameters):
    encodedParams = urllib.parse.urlencode(parameters).encode("utf-8")
    req = urllib.request.Request(url)
    net = urllib.request.urlopen(req,encodedParams)
    return(net.read())

client = aclient()
tree = app_commands.CommandTree(client)

@tree.command(guild = discord.Object(id=guild_id), name = 'say', description='sayanything')
async def first_command(interaction, say_anything:str):
    parameters = {'say':say_anything}
    info = submitInformation(enter_url,parameters)
    await interaction.response.send_message(info)
    print(info)

client.run(token)
