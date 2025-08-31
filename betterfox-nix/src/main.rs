mod commands;

use anyhow::Result;
use clap::Parser;
use commands::Commands;

#[derive(Parser)]
#[command(name = "betterfox-nix")]
#[command(about = "CLI for betterfox-nix")]
#[command(version)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();
    cli.command.execute().await
}
