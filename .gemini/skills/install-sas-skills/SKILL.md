---
name: install-sas-skills
description: Install or update all skills from this repository to the local machine by running the install-sas-skills.ps1 script. Use when the user asks to install skills, update skills, sync skills, or deploy skills.
---

# Install Skills

## Skill Goal

This skill installs or updates all skills from this repository to the user's personal skills directory (`~/.gemini/skills/`) by running the `install-sas-skills.ps1` PowerShell script. It ensures skills on the machine are in sync with the latest versions in this repo.

**This skill is local to this repository only.** It must not be installed to the machine like other skills, because running it outside this repo context would install skills from an arbitrary or unexpected directory.

## Instructions

1. **Validate the environment:**
   - Verify the current working directory is the repo root by checking for `install-sas-skills.ps1` in the current directory.
   - If the script is not found, display an error and exit: "install-sas-skills.ps1 not found. Run this skill from the semantic-agent-skills repository root."
   - Verify PowerShell is available by running `powershell -Command "Write-Host OK"`. If it fails, display: "PowerShell is required to install skills but is not available on this system."

2. **Run the install script:**
   - Execute: `powershell -ExecutionPolicy Bypass -File .\install-sas-skills.ps1`
   - Use `-ExecutionPolicy Bypass` to avoid execution policy restrictions without changing system settings.
   - Wait for the script to complete and capture its output.

3. **Report the result:**
   - Summarize the output: how many skills were installed/updated.
   - Remind the user: "Remember to restart Gemini CLI for changes to take effect."

## Edge Cases

- **Script already run recently:** The script overwrites existing versions — safe to run again. Report which skills were reinstalled.
- **New skills added since last install:** These will be installed as well. Report them separately if possible.
- **Skills removed from repo:** The script does not delete skills from the machine that no longer exist in the repo. If the user asks for a clean slate, suggest manually deleting `~/.gemini/skills/` and re-running the install.
- **Not run from repo root:** The script uses `$PSScriptRoot` to resolve paths, so it works when invoked as `.\install-skills.ps1` from the repo root. The skill must validate this before running.

## Examples

User: "install the skills"
→ Run `powershell -ExecutionPolicy Bypass -File .\install-skills.ps1`, report results, remind to restart Gemini CLI

User: "update skills to latest"
→ Same flow

User: "deploy skills to my machine"
→ Same flow

