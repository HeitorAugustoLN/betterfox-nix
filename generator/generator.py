import os
import re
import subprocess
import sys
from typing import TextIO

import requests


class Generator:
    def __init__(self, versions: list[str], generation_type: str):
        self.generation_type = generation_type
        self.versions = versions

    def generate_url(self, version: str) -> str:
        match self.generation_type:
            case "firefox":
                return f"https://raw.githubusercontent.com/yokoffing/Betterfox/{version}/user.js"
            case "librewolf":
                return f"https://raw.githubusercontent.com/yokoffing/Betterfox/{version}/librewolf.overrides.cfg"
            case "smoothfox":
                return f"https://raw.githubusercontent.com/yokoffing/Betterfox/{version}/Smoothfox.js"

    def generate_versions(self, default_nix: TextIO):
        for version in self.versions:
            print(f"Generating {self.generation_type} v{version}")
            url = self.generate_url(version)
            response = requests.get(url)
            if response.status_code == 200:
                content = response.text
                with open("temp.txt", "w") as file:
                    file.write(content)

                subprocess.run(
                    f"betterfox-extractor {self.generation_type} ./temp.txt > autogen/{self.generation_type}/{version}.json",
                    shell=True,
                )

                default_nix.write(
                    f'  "{version}" = builtins.fromJSON (builtins.readFile ./{version}.json);\n'
                )

                os.remove("./temp.txt")
            else:
                print(f"Failed to download {url}")

    def generate(self):
        subprocess.run(f"mkdir -p autogen/{self.generation_type}", shell=True)
        with open(f"autogen/{self.generation_type}/default.nix", "w") as default_nix:
            default_nix.write("{\n")
            self.generate_versions(default_nix)
            default_nix.write("}\n")


def main():
    if len(sys.argv) != 2:
        raise ValueError(
            f"betterfox-extractor must receive 1 argument, got: {len(sys.argv) - 1}"
        )

    tags = requests.get("https://api.github.com/repos/yokoffing/Betterfox/tags").json()
    versions = ["main"] + [tag["name"] for tag in tags if re.match(r"^\d+\.\d+$", tag["name"])]

    generation_type = sys.argv[1]
    match generation_type:
        case "firefox":
            firefox = Generator(versions, generation_type)
            firefox.generate()
        case "librewolf":
            librewolf = Generator(versions, generation_type)
            librewolf.generate()
        case "smoothfox":
            smoothfox = Generator(versions, generation_type)
            smoothfox.generate()
        case _:
            raise ValueError(
                f"{generation_type} is not a valid option. Supported options are: librewolf, firefox and smoothfox."
            )


if __name__ == "__main__":
    main()
