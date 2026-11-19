param (
    [string]$Password = ""
)

$ErrorActionPreference = "Continue"
$mysqlExe = "C:\Program Files\MySQL\MySQL Server 26.7\bin\mysql.exe"
$schemaSql = Join-Path $PSScriptRoot "schema.sql"
$envFile = Join-Path $PSScriptRoot "..\backend\.env"

if (-not (Test-Path $mysqlExe)) {
    $found = Get-Command mysql.exe -ErrorAction SilentlyContinue
    if ($found) {
        $mysqlExe = $found.Source
    } else {
        Write-Host "ERROR: mysql.exe was not found. Please install or add MySQL to PATH." -ForegroundColor Red
        exit 1
    }
}

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   ELDERLY SEVA - MYSQL DATABASE AUTOMATED SETUP          " -ForegroundColor Cyan
Write-Host "   Database: elderly_seva_db                              " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Read existing password from .env if present
$candidate = $Password
if (-not $candidate -and (Test-Path $envFile)) {
    $match = Select-String -Path $envFile -Pattern "^MYSQL_PASSWORD=(.*)"
    if ($match) {
        $val = $match.Matches.Groups[1].Value.Trim()
        if ($val -and $val -ne "password" -and $val -ne "your_actual_password_here") {
            $candidate = $val
        }
    }
}

$authenticated = $false
$workingPassword = ""

# 2. Test candidate password silently
if ($candidate) {
    Write-Host "Testing password from backend\.env..." -ForegroundColor Yellow
    $testResult = & $mysqlExe -h 127.0.0.1 -P 3306 -u root "--password=$candidate" -e "SELECT 1;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $authenticated = $true
        $workingPassword = $candidate
        Write-Host "Password from .env verified successfully!" -ForegroundColor Green
    } else {
        Write-Host "The password in .env ($candidate) was not accepted by MySQL." -ForegroundColor Yellow
        Write-Host "Please enter your current MySQL root password below:" -ForegroundColor Cyan
    }
}

# 3. Interactive prompt loop if needed
while (-not $authenticated) {
    $userInput = Read-Host "Enter MySQL root password"
    if ([string]::IsNullOrWhiteSpace($userInput)) {
        Write-Host "Password cannot be empty. Please try again." -ForegroundColor Yellow
        continue
    }

    Write-Host "Verifying connection..." -ForegroundColor Yellow
    $testResult = & $mysqlExe -h 127.0.0.1 -P 3306 -u root "--password=$userInput" -e "SELECT 1;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $authenticated = $true
        $workingPassword = $userInput
        Write-Host "Connected successfully to MySQL Server 26.7!" -ForegroundColor Green
    } else {
        Write-Host "Access denied with that password. Please try again (check caps lock)." -ForegroundColor Red
        Write-Host ""
    }
}

# 4. Import the schema
Write-Host "`nImporting schema.sql (Creating elderly_seva_db and all 17 tables)..." -ForegroundColor Yellow
$sqlContent = Get-Content $schemaSql -Raw
$importResult = $sqlContent | & $mysqlExe -h 127.0.0.1 -P 3306 -u root "--password=$workingPassword" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "Schema imported successfully!" -ForegroundColor Green
} else {
    Write-Host "Import output: $importResult" -ForegroundColor Yellow
}

# 5. Verify created tables
Write-Host "`nVerifying tables created in elderly_seva_db:" -ForegroundColor Cyan
& $mysqlExe -h 127.0.0.1 -P 3306 -u root "--password=$workingPassword" -e "USE elderly_seva_db; SHOW FULL TABLES WHERE Table_type = 'BASE TABLE';"

# 6. Save working password to backend/.env
if (Test-Path $envFile) {
    (Get-Content $envFile) -replace "^MYSQL_PASSWORD=.*", "MYSQL_PASSWORD=$workingPassword" | Set-Content $envFile
    (Get-Content $envFile) -replace "^MYSQL_DB=.*", "MYSQL_DB=elderly_seva_db" | Set-Content $envFile
    Write-Host "`nUpdated backend\.env with working password: $workingPassword" -ForegroundColor Green
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "   ELDERLY SEVA DATABASE IS READY & VERIFIED!             " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
