import re
import sys
import json

class Extractor:
    def __init__(self, section_regex, subsection_regex, pref_regex, pref_file):
        self.section_regex = section_regex
        self.subsection_regex = subsection_regex
        self.pref_regex = pref_regex
        self.pref_file = pref_file

        self.sections = {}
        self.current_section = None
        self.current_subsection = None

    def format_name(self, name: str) -> str:
        name = (
            name.lower()
            .replace(" ", "-")
            .replace("/", "with")
            .replace("&", "and")
            .replace("+", "plus")
        )
        return re.sub(r"[^a-z0-9_-]", "", name)

    def ensure_current_section(self):
        if self.current_section is None:
            self.start_new_section("default")

    def ensure_subsection(self):
        if self.current_subsection is None:
            self.start_new_subsection("default")

    def start_new_section(self, name: str):
        self.current_section = self.format_name(name)
        if self.current_section != "smoothfox":
            self.sections[self.current_section] = {"meta": {"title": name}}
        self.current_subsection = None

    def start_new_subsection(self, name: str):
        self.ensure_current_section()
        name = self.format_name(name)
        self.current_subsection = {"meta": {"title": name}, "settings": []}
        self.sections[self.current_section][name] = self.current_subsection

    def parse_value(self, value):
        try:
            return json.loads(value)
        except ValueError:
            return value

    def extract(self) -> dict:
        with open(self.pref_file, "r") as file:
            for line in file:
                line = line.strip()

                section_match = re.compile(self.section_regex).search(line)
                if section_match:
                    self.start_new_section(section_match.group(1))
                    continue

                subsection_match = re.compile(self.subsection_regex).match(line)
                if subsection_match:
                    self.start_new_subsection(subsection_match.group(1))
                    continue

                pref_match = re.compile(self.pref_regex).match(line)
                if pref_match:
                    if "Nightly" in line:
                        continue

                    self.ensure_subsection()
                    pref_name, pref_value_raw = pref_match.groups()
                    pref_value = self.parse_value(pref_value_raw)
                    self.current_subsection["settings"].append(
                        {"name": pref_name, "value": pref_value}
                    )
        return self.sections


def main():
    if len(sys.argv) != 2:
        raise ValueError(
            f"betterfox-extractor must receive 1 argument, got: {len(sys.argv) - 1}"
        )

    extractType = sys.argv[1]
    if extractType == "librewolf":
        section = r"SECTION:\s*(\w+)"
        subsection = r"/\*\*\s*(.+?)\s*\*\*\*/"
        pref = r'defaultPref\("([^"]+)",\s*(.*?)\);'

        librewolf = Extractor(section, subsection, pref, "librewolf.overrides.cfg")
        sections = librewolf.extract()
        json_output = json.dumps(sections, indent=2)
        print(json_output)
    elif extractType == "firefox":
        section = r"SECTION:\s*(\w+)"
        subsection = r"/\*\*\s*(.+?)\s*\*\*\*/"
        pref = r'user_pref\("([^"]+)",\s*(.*?)\);'

        firefox = Extractor(section, subsection, pref, "user.js")
        sections = firefox.extract()
        json_output = json.dumps(sections, indent=2)
        print(json_output)
    elif extractType == "smoothfox":
        section = r"OPTION:\s+(\w+(?:\s\w+)*)"
        subsection = r"/\*\*\s*(.+?)\s*\*\*\*/"
        pref = r'user_pref\("([^"]+)",\s*(.*?)\);'

        smoothfox = Extractor(section, subsection, pref, "Smoothfox.js")
        sections = smoothfox.extract()
        json_output = json.dumps(sections, indent=2)
        print(json_output)
    else:
        raise ValueError(
            f"{extractType} is not a valid option. Supported options are: librewolf, firefox and smoothfox."
        )


if __name__ == "__main__":
    main()
