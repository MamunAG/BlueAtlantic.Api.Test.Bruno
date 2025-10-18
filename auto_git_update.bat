@echo off
:: ======================================================
:: Auto Git Sync Script (Stage + Commit + Pull + Push)
:: Works inside project root where .git exists
:: Author: Abdullah Al Mamun
:: ======================================================
:: Remove log file tracking
git rm --cached git_auto_sync_log.txt >nul 2>&1

:: === CONFIGURATION ===
set "BRANCH=main"
set "LOG_FILE=%~dp0git_auto_sync_log.txt"
set "COMMIT_MESSAGE=Auto-sync on %date% %time%"

:: === START LOGGING ===
echo. >> "%LOG_FILE%"
echo ================================================== >> "%LOG_FILE%"
echo ==================================================

echo [%date% %time%] Starting Git auto-sync... >> "%LOG_FILE%"
echo [%date% %time%] Starting Git auto-sync...


:: === CHECK GIT AVAILABILITY ===
git --version >nul 2>&1
if errorlevel 1 (
    echo [%date% %time%] ❌ ERROR: Git is not installed or not in PATH! >> "%LOG_FILE%"
    echo [%date% %time%] ❌ ERROR: Git is not installed or not in PATH!

    exit /b 1
)

:: === MOVE TO SCRIPT DIRECTORY (PROJECT ROOT) ===
cd /d "%~dp0"
if errorlevel 1 (
    echo [%date% %time%] ❌ ERROR: Failed to access project directory! >> "%LOG_FILE%"
    echo [%date% %time%] ❌ ERROR: Failed to access project directory!
    exit /b 1
)

:: === ENSURE .GIT EXISTS ===
if not exist ".git" (
    echo [%date% %time%] ❌ ERROR: No .git directory found! >> "%LOG_FILE%"
    echo [%date% %time%] ❌ ERROR: No .git directory found!
    exit /b 1
)

:: === STAGE CHANGES ===
echo [%date% %time%] Checking for modified/untracked files... >> "%LOG_FILE%"
echo [%date% %time%] Checking for modified/untracked files...
git add -A >> "%LOG_FILE%" 2>&1

:: === COMMIT CHANGES (IF ANY) ===
git diff --cached --quiet
if errorlevel 1 (
    echo [%date% %time%] Local changes detected. Creating commit... >> "%LOG_FILE%"
    echo [%date% %time%] Local changes detected. Creating commit...
    git commit -m "%COMMIT_MESSAGE%" >> "%LOG_FILE%" 2>&1
) else (
    echo [%date% %time%] No local changes to commit. >> "%LOG_FILE%"
    echo [%date% %time%] No local changes to commit.
)

:: === FETCH AND REBASE (SYNC FROM REMOTE) ===
echo [%date% %time%] Pulling latest from remote branch '%BRANCH%' with rebase... >> "%LOG_FILE%"
echo [%date% %time%] Pulling latest from remote branch '%BRANCH%' with rebase...

git fetch origin %BRANCH% >> "%LOG_FILE%" 2>&1
git rebase origin/%BRANCH% >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [%date% %time%] ⚠️ WARNING: Rebase failed or conflicts detected! >> "%LOG_FILE%"
    echo [%date% %time%] You may need to resolve conflicts manually. >> "%LOG_FILE%"

    echo [%date% %time%] ⚠️ WARNING: Rebase failed or conflicts detected!
    echo [%date% %time%] You may need to resolve conflicts manually.

    exit /b 1
)

:: === PUSH CHANGES BACK TO REMOTE ===
echo [%date% %time%] Pushing local commits to remote... >> "%LOG_FILE%"
echo [%date% %time%] Pushing local commits to remote...

git push origin %BRANCH% >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [%date% %time%] ❌ ERROR: Git push failed! >> "%LOG_FILE%"
    echo [%date% %time%] ❌ ERROR: Git push failed!

    exit /b 1
)

:: === DONE ===
echo [%date% %time%] ✅ Git sync completed successfully! >> "%LOG_FILE%"
echo [%date% %time%] ✅ Git sync completed successfully!
echo ================================================== >> "%LOG_FILE%"
echo ================================================== >>
echo. >> "%LOG_FILE%"
exit /b 0
