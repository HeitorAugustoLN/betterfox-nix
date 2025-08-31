use crate::commands::{Command, extract::Extractor};
use anyhow::{Context, Result};
use clap::Args;
use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Args)]
pub struct GenerateCommand {
    /// The type of generation
    #[arg(value_enum)]
    pub generate_type: GenerateType,
}

#[derive(clap::ValueEnum, Clone, Debug)]
pub enum GenerateType {
    Firefox,
    Librewolf,
    Smoothfox,
}

#[derive(Deserialize, Serialize)]
struct GitHubTag {
    name: String,
}

pub struct Generator {
    generation_type: GenerateType,
    versions: Vec<String>,
}

impl Generator {
    pub async fn new(generation_type: GenerateType) -> Result<Self> {
        let client = reqwest::Client::new();
        let response = client
            .get("https://api.github.com/repos/yokoffing/Betterfox/tags")
            .header("User-Agent", "betterfox-nix")
            .send()
            .await
            .context("Failed to fetch GitHub tags")?;

        let tags: Vec<GitHubTag> = response
            .json()
            .await
            .context("Failed to parse GitHub tags response")?;

        let mut versions = vec!["main".to_string()];
        let version_regex =
            regex::Regex::new(r"^\d+\.\d+$").context("Failed to compile version regex")?;

        for tag in tags {
            if version_regex.is_match(&tag.name) {
                versions.push(tag.name);
            }
        }

        Ok(Self {
            generation_type,
            versions,
        })
    }

    fn generate_url(&self, version: &str) -> String {
        match self.generation_type {
            GenerateType::Firefox => {
                format!(
                    "https://raw.githubusercontent.com/yokoffing/Betterfox/{}/user.js",
                    version
                )
            }
            GenerateType::Librewolf => {
                format!(
                    "https://raw.githubusercontent.com/yokoffing/Betterfox/{}/librewolf.overrides.cfg",
                    version
                )
            }
            GenerateType::Smoothfox => {
                format!(
                    "https://raw.githubusercontent.com/yokoffing/Betterfox/{}/Smoothfox.js",
                    version
                )
            }
        }
    }

    fn type_str(&self) -> &'static str {
        match self.generation_type {
            GenerateType::Firefox => "firefox",
            GenerateType::Librewolf => "librewolf",
            GenerateType::Smoothfox => "smoothfox",
        }
    }

    async fn generate_versions(&self, default_nix: &mut String) -> Result<()> {
        let client = reqwest::Client::new();

        for version in &self.versions {
            println!("Generating {} {}", self.type_str(), version);

            let url = self.generate_url(version);
            let response = client
                .get(&url)
                .send()
                .await
                .with_context(|| format!("Failed to fetch {}", url))?;

            if response.status().is_success() {
                let content = response
                    .text()
                    .await
                    .with_context(|| format!("Failed to read content from {}", url))?;

                let (section_regex, subsection_regex, pref_regex) = match self.generation_type {
                    GenerateType::Librewolf => (
                        r"SECTION:\s*(\w+)",
                        r"/\*\*\s*(.+?)\s*\*\*\*/",
                        r#"defaultPref\("([^"]+)",\s*(.*?)\);"#,
                    ),
                    GenerateType::Firefox => (
                        r"SECTION:\s*(\w+)",
                        r"/\*\*\s*(.+?)\s*\*\*\*/",
                        r#"user_pref\("([^"]+)",\s*(.*?)\);"#,
                    ),
                    GenerateType::Smoothfox => (
                        r"OPTION(?:\s\w+)?:\s+(\w+(?:\s\w+)*)",
                        r"/\*\*\s*(.+?)\s*\*\*\*/",
                        r#"user_pref\("([^"]+)",\s*(.*?)\);"#,
                    ),
                };

                let mut extractor = Extractor::new(section_regex, subsection_regex, pref_regex)
                    .context("Failed to create extractor")?;
                let result = extractor
                    .extract(&content)
                    .with_context(|| format!("Failed to extract from {}", version))?;

                let type_str = self.type_str();
                let output_dir = format!("data/{}", type_str);
                fs::create_dir_all(&output_dir)
                    .with_context(|| format!("Failed to create directory {}", output_dir))?;

                let json_content = serde_json::to_string_pretty(&result)
                    .context("Failed to serialize result to JSON")?;
                let json_file = format!("{}/{}.json", output_dir, version);
                fs::write(&json_file, json_content)
                    .with_context(|| format!("Failed to write {}", json_file))?;

                default_nix.push_str(&format!(
                    "  \"{}\" = builtins.fromJSON (builtins.readFile ./{}.json);\n",
                    version, version
                ));
            } else {
                eprintln!("Failed to download {} (status: {})", url, response.status());
            }
        }

        Ok(())
    }

    pub async fn generate(&self) -> Result<()> {
        let type_str = self.type_str();
        let output_dir = format!("data/{}", type_str);
        fs::create_dir_all(&output_dir)
            .with_context(|| format!("Failed to create directory {}", output_dir))?;

        let mut default_nix = String::from("{\n");
        self.generate_versions(&mut default_nix)
            .await
            .context("Failed to generate versions")?;
        default_nix.push_str("}\n");

        let default_nix_path = format!("{}/default.nix", output_dir);
        fs::write(&default_nix_path, default_nix)
            .with_context(|| format!("Failed to write {}", default_nix_path))?;

        println!("Successfully generated configurations in {}", output_dir);
        Ok(())
    }
}

impl Command for GenerateCommand {
    async fn execute(&self) -> Result<()> {
        let generator = Generator::new(self.generate_type.clone())
            .await
            .context("Failed to initialize generator")?;
        generator
            .generate()
            .await
            .context("Failed to generate configurations")?;
        Ok(())
    }
}
