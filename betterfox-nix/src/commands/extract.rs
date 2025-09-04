use crate::commands::Command;
use anyhow::{Context, Result};
use clap::Args;
use regex::Regex;
use serde_json::{Map, Value};
use std::collections::HashMap;
use std::fs;

#[derive(Args)]
pub struct ExtractCommand {
    /// The type of extraction
    #[arg(value_enum)]
    pub extract_type: ExtractType,
    /// Path to the preference file
    pub file_path: String,
}

#[derive(clap::ValueEnum, Clone)]
pub enum ExtractType {
    Firefox,
    Smoothfox,
}

pub struct Extractor {
    section_regex: Regex,
    subsection_regex: Regex,
    pref_regex: Regex,
    sections: HashMap<String, Value>,
    current_section: Option<String>,
    current_subsection: Option<String>,
}

impl Extractor {
    pub fn new(section_regex: &str, subsection_regex: &str, pref_regex: &str) -> Result<Self> {
        Ok(Self {
            section_regex: Regex::new(section_regex).context("Failed to compile section regex")?,
            subsection_regex: Regex::new(subsection_regex)
                .context("Failed to compile subsection regex")?,
            pref_regex: Regex::new(pref_regex).context("Failed to compile preference regex")?,
            sections: HashMap::new(),
            current_section: None,
            current_subsection: None,
        })
    }

    fn format_name(&self, name: &str) -> String {
        name.to_lowercase()
            .replace(' ', "-")
            .replace('/', "with")
            .replace('&', "and")
            .replace('+', "plus")
            .chars()
            .filter(|c| c.is_alphanumeric() || *c == '_' || *c == '-')
            .collect()
    }

    fn ensure_current_section(&mut self) {
        if self.current_section.is_none() {
            self.start_new_section("default");
        }
    }

    fn ensure_subsection(&mut self) {
        if self.current_subsection.is_none() {
            self.start_new_subsection("default");
        }
    }

    fn start_new_section(&mut self, name: &str) {
        let formatted_name = self.format_name(name);
        self.current_section = Some(formatted_name.clone());

        if formatted_name != "smoothfox" {
            let mut meta = Map::new();
            meta.insert("title".to_string(), Value::String(name.to_string()));

            let mut section = Map::new();
            section.insert("meta".to_string(), Value::Object(meta));

            self.sections.insert(formatted_name, Value::Object(section));
        }

        self.current_subsection = None;
    }

    fn start_new_subsection(&mut self, name: &str) {
        self.ensure_current_section();

        let formatted_name = self.format_name(name);
        self.current_subsection = Some(formatted_name.clone());

        let mut meta = Map::new();
        meta.insert("title".to_string(), Value::String(name.to_string()));

        let mut subsection = Map::new();
        subsection.insert("meta".to_string(), Value::Object(meta));
        subsection.insert("settings".to_string(), Value::Array(vec![]));

        if let Some(ref section_name) = self.current_section
            && let Some(Value::Object(section)) = self.sections.get_mut(section_name)
        {
            section.insert(formatted_name, Value::Object(subsection));
        }
    }

    fn parse_value(&self, value: &str) -> Value {
        serde_json::from_str(value).unwrap_or_else(|_| Value::String(value.to_string()))
    }

    pub fn extract(&mut self, content: &str) -> Result<Value> {
        for line in content.lines() {
            let line = line.trim();

            if let Some(captures) = self.section_regex.captures(line) {
                if let Some(section_name) = captures.get(1) {
                    self.start_new_section(section_name.as_str());
                }
                continue;
            }

            if let Some(captures) = self.subsection_regex.captures(line) {
                if let Some(subsection_name) = captures.get(1) {
                    self.start_new_subsection(subsection_name.as_str());
                }
                continue;
            }

            if let Some(captures) = self.pref_regex.captures(line) {
                if line.contains("Nightly") {
                    continue;
                }

                self.ensure_subsection();

                if let (Some(pref_name), Some(pref_value_raw)) = (captures.get(1), captures.get(2))
                {
                    let pref_value = self.parse_value(pref_value_raw.as_str());

                    let mut setting = Map::new();
                    setting.insert("enabled".to_string(), Value::Bool(true));
                    setting.insert(
                        "name".to_string(),
                        Value::String(pref_name.as_str().to_string()),
                    );
                    setting.insert("value".to_string(), pref_value);

                    if let Some(ref section_name) = self.current_section
                        && let Some(ref subsection_name) = self.current_subsection
                        && let Some(Value::Object(section)) = self.sections.get_mut(section_name)
                        && let Some(Value::Object(subsection)) = section.get_mut(subsection_name)
                        && let Some(Value::Array(settings)) = subsection.get_mut("settings")
                    {
                        settings.push(Value::Object(setting));
                    }
                }
            }
        }

        Ok(Value::Object(self.sections.clone().into_iter().collect()))
    }
}

impl Command for ExtractCommand {
    async fn execute(&self) -> Result<()> {
        let content = fs::read_to_string(&self.file_path)
            .with_context(|| format!("Failed to read file: {}", self.file_path))?;

        let (section_regex, subsection_regex, pref_regex) = match self.extract_type {
            ExtractType::Firefox => (
                r"SECTION:\s*(\w+)",
                r"/\*\*\s*(.+?)\s*\*\*\*/",
                r#"user_pref\("([^"]+)",\s*(.*?)\);"#,
            ),
            ExtractType::Smoothfox => (
                r"OPTION(?:\s\w+)?:\s+(\w+(?:\s\w+)*)",
                r"/\*\*\s*(.+?)\s*\*\*\*/",
                r#"user_pref\("([^"]+)",\s*(.*?)\);"#,
            ),
        };

        let mut extractor = Extractor::new(section_regex, subsection_regex, pref_regex)
            .context("Failed to create extractor")?;
        let result = extractor
            .extract(&content)
            .context("Failed to extract preferences")?;

        let json_output =
            serde_json::to_string_pretty(&result).context("Failed to serialize result to JSON")?;

        println!("{}", json_output);
        Ok(())
    }
}
