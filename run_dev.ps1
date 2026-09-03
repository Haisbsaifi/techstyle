# run_dev.ps1 — Set up the local dev environment and start TechStyle (Windows).
#
# Usage: powershell -ExecutionPolicy Bypass -File .\run_dev.ps1
#
# On first run:  creates .venv, installs dependencies, seeds the DB.
# On later runs: reuses the existing .venv and skips seeding if the DB exists.

$ErrorActionPreference = "Stop"

$VenvDir = ".venv"

# The app hardcodes the database as "/tmp/techstyle.db". Windows has no /tmp,
# so Python resolves that to <current drive>:\tmp\techstyle.db — and SQLite
# fails with "unable to open database file" if that folder is missing.
$TmpDir = Join-Path (Get-Location).Drive.Root "tmp"
$DbPath = Join-Path $TmpDir "techstyle.db"

# -- 0. Make sure the tmp folder the app expects exists ---------------
if (-not (Test-Path $TmpDir)) {
  Write-Host "--> Creating $TmpDir (the app expects /tmp to exist)..."
  New-Item -ItemType Directory -Path $TmpDir | Out-Null
}

# -- 1. Create virtual environment if it doesn't exist ----------------
if (-not (Test-Path $VenvDir)) {
  # Prefer the py launcher: on Windows a bare "python" is often the Microsoft
  # Store stub, which does nothing useful.
  if (Get-Command py -ErrorAction SilentlyContinue) {
    $PyExe = "py"; $PyArgs = @("-3")
  } elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $PyExe = "python"; $PyArgs = @()
  } else {
    Write-Host "ERROR: Python not found. Install it from https://www.python.org/downloads/"
    Write-Host "       and tick 'Add python.exe to PATH' during setup."
    exit 1
  }

  Write-Host "--> Creating virtual environment..."
  & $PyExe @PyArgs -m venv $VenvDir
}

# -- 2. Activate venv -------------------------------------------------
& (Join-Path $VenvDir "Scripts\Activate.ps1")

# -- 3. Install / update dependencies ---------------------------------
Write-Host "--> Installing dependencies..."
python -m pip install --quiet --upgrade pip
python -m pip install --quiet -r requirements.txt

# -- 4. Seed the database (only if it doesn't exist yet) --------------
if (-not (Test-Path $DbPath)) {
  Write-Host "--> Seeding database..."
  python seed_data.py
} else {
  Write-Host "--> Database already exists, skipping seed."
  Write-Host "    (Delete $DbPath and re-run to start fresh.)"
}

# -- 5. Start the development server ----------------------------------
Write-Host ""
Write-Host "==> Starting TechStyle dev server at http://localhost:5001"
Write-Host "    Press Ctrl+C to stop."
Write-Host ""
python app.py
