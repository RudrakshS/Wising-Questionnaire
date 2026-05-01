"""
WISING TAX ENGINE — app/config.py
pydantic-settings based configuration.
"""
from __future__ import annotations
from typing import List
from pydantic_settings import BaseSettings
from pydantic import Field


class Settings(BaseSettings):
    database_url: str = Field(
        default="postgresql://postgres:wising%40123@localhost:5432/wising_tax",
        alias="DATABASE_URL",
    )
    # Comma-separated origins — override in production with Vercel URL
    cors_origins_raw: str = Field(
        default="http://localhost:3000,http://127.0.0.1:3000",
        alias="CORS_ORIGINS",
    )
    schema_dir: str = Field(default="/specs", alias="SCHEMA_DIR")
    debug: bool = Field(default=False, alias="DEBUG")
    log_level: str = Field(default="INFO", alias="LOG_LEVEL")

    @property
    def cors_origins(self) -> List[str]:
        return [o.strip() for o in self.cors_origins_raw.split(",") if o.strip()]

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8", "populate_by_name": True}


settings = Settings()

