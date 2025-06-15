import discord
from discord import app_commands
import ollama
import re

TOKEN = "DISCORD BOT TOKEN"
MODEL = "deepseek-r1:8b"

intents = discord.Intents.default()
client = discord.Client(intents=intents)
tree = app_commands.CommandTree(client)

conversation = {"role": "user", "content": "These are your previous replies. Take them into account when answering last prompt: "}

def query_ollama(prompt):
    temp = conversation.copy()
    temp["content"] += prompt
    response = ollama.chat(model=MODEL, messages=[temp])
    result = re.sub(r"<think>.*?</think>", "", response["message"]["content"], flags=re.DOTALL).strip()
    conversation["content"] += result
    conversation["content"] += " "
    return result

@tree.command(name="setup", description="Create a fictional esports tournament for specified game")
async def setup_tournament(interaction: discord.Interaction, game: str):
    await interaction.response.defer(thinking=True)
    prompt = (
        f"Create a real, but fictional {game} esports tournament. Give a name and short backstory for the event, as well as prize in EUR. Keep it short, under 2000 characters. Dont output character number."
    )
    result = query_ollama(prompt)
    await interaction.followup.send(result[:2000])

@tree.command(name="rules", description="Define rules and match format")
async def tournament_rules(interaction: discord.Interaction):
    await interaction.response.defer(thinking=True)
    prompt = (
        "Define the match format (BO3, BO5) and depending on the game include map pool or not. Add sufficient number of teams and provide their names. Build brackets from those teams. Keep it short, under 2000 characters. Dont output character number."
    )
    result = query_ollama(prompt)
    await interaction.followup.send(result[:2000])

@tree.command(name="progress", description="Progress previously created torunaments")
async def tournament_teams(interaction: discord.Interaction):
    await interaction.response.defer(thinking=True)
    prompt = (
        f"Progress each current torunament with one stage. Describe every stage of currently created tournaments (winners, losers, current brackets). Keep it short, under 2000 characters. Dont output character number."
    )
    result = query_ollama(prompt)
    await interaction.followup.send(result[:2000])

@client.event
async def on_ready():
    await tree.sync()
    print(f"Bot connected as {client.user}")

client.run(TOKEN)