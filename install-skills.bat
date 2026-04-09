@echo off
setlocal enabledelayedexpansion

rem === Configuration ===
set "SKILLS_SOURCE=%~dp0skills"
set "SKILLS_DEST=%USERPROFILE%\.qwen\skills"

rem === Validate source exists ===
if not exist "%SKILLS_SOURCE%" (
    echo ERROR: Skills source directory not found: %SKILLS_SOURCE%
    echo Make sure this script is run from the repo root.
    exit /b 1
)

rem === Create destination if needed ===
if not exist "%SKILLS_DEST%" (
    echo Creating skills destination: %SKILLS_DEST%
    mkdir "%SKILLS_DEST%"
)

rem === Install each skill ===
echo Installing skills...
echo Source: %SKILLS_SOURCE%
echo Destination: %SKILLS_DEST%
echo.

set "INSTALLED=0"
for /d %%G in ("%SKILLS_SOURCE%\*") do (
    set "SKILL_NAME=%%~nxG"
    echo Installing: !SKILL_NAME!

    rem Remove old version if exists
    if exist "%SKILLS_DEST%\!SKILL_NAME!" (
        rmdir /s /q "%SKILLS_DEST%\!SKILL_NAME!"
    )

    rem Copy new version
    xcopy /E /I /Q /Y "%%G" "%SKILLS_DEST%\!SKILL_NAME!" >nul
    if errorlevel 1 (
        echo  ERROR: Failed to install !SKILL_NAME!
    ) else (
        echo  OK: !SKILL_NAME! installed
        set /a INSTALLED+=1
    )
)

echo.
echo Done! Installed %INSTALLED% skill(s).
echo.
echo Remember to restart Qwen Code for changes to take effect.