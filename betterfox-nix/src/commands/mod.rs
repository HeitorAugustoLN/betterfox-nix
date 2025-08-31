mod extract;
mod generate;

use crate::commands::{extract::ExtractCommand, generate::GenerateCommand};
use anyhow::Result;
use clap::Subcommand;

#[derive(Subcommand)]
pub enum Commands {
    /// Extract preferences from configuration files
    Extract(ExtractCommand),
    /// Generate configurations for all versions
    Generate(GenerateCommand),
}

impl Commands {
    pub async fn execute(&self) -> Result<()> {
        match self {
            Commands::Extract(cmd) => cmd.execute().await,
            Commands::Generate(cmd) => cmd.execute().await,
        }
    }
}

pub trait Command {
    async fn execute(&self) -> Result<()>;
}
