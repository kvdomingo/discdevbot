from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    DISCORD_TOKEN: str
    TEST_GUILD_ID: int


@lru_cache
def _get_settings() -> Settings:
    return Settings()


settings = _get_settings()
