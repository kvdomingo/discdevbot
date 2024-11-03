from discord import Client, Intents, Interaction, Object
from discord.app_commands import CommandTree
from loguru import logger

from discdevbot.settings import settings

TEST_GUILD = Object(id=settings.TEST_GUILD_ID)


class DiscDevBotClient(Client):
    def __init__(self, *, intents: Intents):
        super().__init__(intents=intents)
        self.tree = CommandTree(self)

    async def setup_hook(self):
        self.tree.copy_global_to(guild=TEST_GUILD)
        await self.tree.sync(guild=TEST_GUILD)


intents = Intents.default()
bot = DiscDevBotClient(intents=intents)


@bot.event
async def on_ready():
    logger.info(f"Logged in as {bot.user} (ID: {bot.user.id})")


@bot.tree.command()
async def ping(interaction: Interaction):
    """Get bot latency"""
    await interaction.response.send_message(f"Pong! ({bot.latency * 1000:.2f} ms)")


bot.run(settings.DISCORD_TOKEN)
