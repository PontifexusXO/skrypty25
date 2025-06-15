import discord
from discord import app_commands
import ollama
import re

TOKEN = "DISCORD BOT TOKEN"
MODEL = "deepseek-r1:14b"

intents = discord.Intents.default()
client = discord.Client(intents=intents)
tree = app_commands.CommandTree(client)

conversation = {"role": "user", "content": "Output only pure answers, being shorter than 2000 characters each. Take these previous replies into context when answering the last prompt: "}

def query_ollama(prompt):
    conversation["content"] += prompt
    response = ollama.chat(model=MODEL, messages=[conversation])
    result = re.sub(r"<think>.*?</think>", "", response["message"]["content"], flags=re.DOTALL).strip()
    conversation["content"] += "<- this prompt gave this result: "
    conversation["content"] += result
    conversation["content"] += " "
    return result

@tree.command(name="setup", description="Create a fictional esports tournament for specified game")
async def setup_tournament(interaction: discord.Interaction, game: str):
    await interaction.response.defer(thinking=True)
    prompt = (
        f"Create a real {game} esports tournament. Give it a name and short backstory, as well as prize in EUR. Keep the output short."
    )
    result = query_ollama(prompt)
    await interaction.followup.send(result[:2000])

@tree.command(name="rules", description="Define rules and match format of created tournament")
async def tournament_rules(interaction: discord.Interaction, team_count: int):
    await interaction.response.defer(thinking=True)
    prompt = (
        f"Define the match format (BO3 or BO5). Add {team_count} teams. Provide their names. Build brackets for those teams. Keep the output short."
    )
    result = query_ollama(prompt)
    await interaction.followup.send(result[:2000])

@tree.command(name="progress", description="Progress created torunament")
async def tournament_teams(interaction: discord.Interaction):
    await interaction.response.defer(thinking=True)
    prompt = (
        "Progress current tournament with one stage. After that, describe current stage (winners, losers, current brackets). Keep the output short."
    )
    result = query_ollama(prompt)
    await interaction.followup.send(result[:2000])

@tree.command(name="list", description="List all current games in tournament")
async def tournament_teams(interaction: discord.Interaction):
    await interaction.response.defer(thinking=True)
    prompt = (
        "List all current (or soon to be played) games in the tournament. Keep the output short."
    )
    result = query_ollama(prompt)
    await interaction.followup.send(result[:2000])

@tree.command(name="add_player", description="Adds specified player to specified team")
async def tournament_teams(interaction: discord.Interaction, player: str, team: str):
    await interaction.response.defer(thinking=True)
    prompt = (
        f"Add player {player} to team {team} and remember them. Output should say, what player was added, to what team and his number in his team."
    )
    result = query_ollama(prompt)
    await interaction.followup.send(result[:2000])

@tree.command(name="tournament", description="List all info about current tournament")
async def tournament_teams(interaction: discord.Interaction):
    await interaction.response.defer(thinking=True)
    prompt = (
        "List every team, state of previous and current games, and every player taking part in this tournament."
    )
    result = query_ollama(prompt)
    await interaction.followup.send(result[:2000])

@client.event
async def on_ready():
    await tree.sync()
    print(f"Bot connected as {client.user}")

client.run(TOKEN)