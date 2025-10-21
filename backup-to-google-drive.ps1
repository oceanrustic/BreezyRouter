# BreezyRouter Backup Script to Google Drive
# PowerShell script to backup your project

# Configuration
$projectPath = "C:\Users\artof\BreezyRouter"
$googleDrivePath = "G:\My Drive\Backups\BreezyRouter"  # Adjust this path!
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$backupPath = "$googleDrivePath\BreezyRouter_$timestamp"

# Create backup directory if it doesn't exist
if (-Not (Test-Path $googleDrivePath)) {
    New-Item -ItemType Directory -Path $googleDrivePath -Force
    Write-Host "Created backup directory: $googleDrivePath" -ForegroundColor Green
}

# Create timestamped backup folder
New-Item -ItemType Directory -Path $backupPath -Force

# Copy files (excluding node_modules, .sfdx, logs)
Write-Host "Starting backup to: $backupPath" -ForegroundColor Cyan

$excludeDirs = @(".sfdx", ".sf", "node_modules", "logs", ".vscode", "coverage")
$excludeExtensions = @("*.log", "*.tmp")

# Use robocopy for efficient copying (Windows built-in)
$robocopyArgs = @(
    $projectPath,
    $backupPath,
    "/MIR",  # Mirror directory
    "/XD", $excludeDirs -join " ",  # Exclude directories
    "/XF", $excludeExtensions -join " ",  # Exclude files
    "/R:2",  # Retry 2 times
    "/W:5",  # Wait 5 seconds between retries
    "/NFL",  # No file list
    "/NDL",  # No directory list
    "/NP"    # No progress
)

robocopy $projectPath $backupPath /MIR /XD .sfdx .sf node_modules logs .vscode coverage /XF *.log *.tmp /R:2 /W:5

if ($LASTEXITCODE -le 7) {
    Write-Host "`nBackup completed successfully!" -ForegroundColor Green
    Write-Host "Location: $backupPath" -ForegroundColor Yellow
    
    # Optional: Keep only last 5 backups (delete older ones)
    $backups = Get-ChildItem -Path $googleDrivePath -Directory | 
               Where-Object { $_.Name -like "BreezyRouter_*" } | 
               Sort-Object Name -Descending
    
    if ($backups.Count -gt 5) {
        $backups | Select-Object -Skip 5 | ForEach-Object {
            Write-Host "Removing old backup: $($_.Name)" -ForegroundColor Gray
            Remove-Item $_.FullName -Recurse -Force
        }
    }
} else {
    Write-Host "`nBackup encountered errors. Exit code: $LASTEXITCODE" -ForegroundColor Red
}

Write-Host "`nPress any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

