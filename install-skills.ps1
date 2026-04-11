# Install Skills Script (PowerShell)
# Run from repo root: .\install-skills.ps1

$ErrorActionPreference = "Stop"

$SkillsSource = Join-Path $PSScriptRoot "skills"
$SkillsDest = Join-Path $env:USERPROFILE ".qwen\skills"

# Validate source exists
if (-not (Test-Path $SkillsSource)) {
    Write-Error "Skills source directory not found: $SkillsSource`nMake sure this script is run from the repo root."
    exit 1
}

# Create destination if needed
if (-not (Test-Path $SkillsDest)) {
    Write-Host "Creating skills destination: $SkillsDest" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $SkillsDest -Force | Out-Null
}

Write-Host "Installing skills..." -ForegroundColor Cyan
Write-Host "Source: $SkillsSource" -ForegroundColor Gray
Write-Host "Destination: $SkillsDest" -ForegroundColor Gray
Write-Host ""

$installed = 0

# Skills that must NOT be installed to the machine (repo-local only)
$excludedSkills = @("sas-install-skills")

Get-ChildItem -Path $SkillsSource -Directory | ForEach-Object {
    $skillName = $_.Name
    $sourcePath = $_.FullName
    $destPath = Join-Path $SkillsDest $skillName

    # Skip repo-local skills
    if ($excludedSkills -contains $skillName) {
        Write-Host "Skipping (repo-local): $skillName" -ForegroundColor DarkGray
        return
    }

    Write-Host "Installing: $skillName" -NoNewline

    try {
        # Remove old version if exists
        if (Test-Path $destPath) {
            Remove-Item -Path $destPath -Recurse -Force
        }

        # Copy new version
        Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
        Write-Host " OK" -ForegroundColor Green
        $installed++
    }
    catch {
        Write-Host " ERROR: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done! Installed $installed skill(s)." -ForegroundColor Green
Write-Host ""
Write-Host "Remember to restart Qwen Code for changes to take effect." -ForegroundColor Yellow