# Exegol Enhanced - Installation Script for Windows
# Developed with AI assistance for optimal user experience
# Version: 1.0.0
# Requires: Windows 10/11 with Administrator privileges

#Requires -RunAsAdministrator

param(
    [switch]$SkipWSL = $false,
    [switch]$SkipDocker = $false,
    [switch]$Verbose = $false
)

# Configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Config = @{
    InstallDir = "$env:USERPROFILE\.exegol-enhanced"
    LogFile = "$env:USERPROFILE\.exegol-enhanced\install.log"
    WSLDistro = "Ubuntu-22.04"
    DockerDesktopUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
}

# Create install directory
New-Item -ItemType Directory -Force -Path $Config.InstallDir | Out-Null
New-Item -ItemType File -Force -Path $Config.LogFile | Out-Null

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp - [$Level] $Message"
    Add-Content -Path $Config.LogFile -Value $LogEntry
    
    switch ($Level) {
        "ERROR" { Write-Host "❌ [ERROR] $Message" -ForegroundColor Red }
        "WARNING" { Write-Host "⚠️  [WARNING] $Message" -ForegroundColor Yellow }
        "SUCCESS" { Write-Host "✅ [SUCCESS] $Message" -ForegroundColor Green }
        "INFO" { Write-Host "ℹ️  [INFO] $Message" -ForegroundColor Cyan }
        "STEP" { Write-Host "🔄 [STEP] $Message" -ForegroundColor Magenta }
        default { Write-Host "$Message" }
    }
}

# Banner function
function Show-Banner {
    Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                    EXEGOL ENHANCED                           ║
║              Ultimate Cybersecurity Environment             ║
║                                                              ║
║                🚀 Windows Installation Script 🚀            ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta
}

# Error handling
function Handle-Error {
    param([string]$ErrorMessage)
    Write-Log "Installation failed: $ErrorMessage" "ERROR"
    Write-Log "Check the log file: $($Config.LogFile)" "ERROR"
    Write-Log "You can run the script again or contact support" "ERROR"
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Windows version
function Test-WindowsVersion {
    Write-Log "Checking Windows version..." "STEP"
    
    $Version = [System.Environment]::OSVersion.Version
    $Build = (Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
    
    if ($Version.Major -lt 10) {
        Handle-Error "Windows 10 or later is required"
    }
    
    if ($Version.Build -lt 19041) {
        Write-Log "Windows build $($Version.Build) detected. WSL2 requires build 19041 or later" "WARNING"
    }
    
    Write-Log "Windows version check passed: $($Version.Major).$($Version.Minor) Build $($Version.Build)" "SUCCESS"
}

# Check system requirements
function Test-SystemRequirements {
    Write-Log "Checking system requirements..." "STEP"
    
    # Check available RAM (minimum 8GB for Windows + Docker)
    $TotalRAM = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    if ($TotalRAM -lt 8) {
        Write-Log "Warning: Less than 8GB RAM detected ($TotalRAM GB). Performance may be affected." "WARNING"
    }
    
    # Check available disk space (minimum 20GB)
    $FreeSpace = [math]::Round((Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace / 1GB, 2)
    if ($FreeSpace -lt 20) {
        Handle-Error "Insufficient disk space. Required: 20GB, Available: $FreeSpace GB"
    }
    
    # Check if Hyper-V is available
    $HyperV = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
    if ($HyperV.State -ne "Enabled") {
        Write-Log "Hyper-V is not enabled. This is required for Docker Desktop." "WARNING"
    }
    
    Write-Log "System requirements check passed" "SUCCESS"
}

# Enable required Windows features
function Enable-WindowsFeatures {
    Write-Log "Enabling required Windows features..." "STEP"
    
    $Features = @(
        "Microsoft-Windows-Subsystem-Linux",
        "VirtualMachinePlatform",
        "Microsoft-Hyper-V-All"
    )
    
    $RestartRequired = $false
    
    foreach ($Feature in $Features) {
        $FeatureState = Get-WindowsOptionalFeature -Online -FeatureName $Feature -ErrorAction SilentlyContinue
        
        if ($FeatureState -and $FeatureState.State -ne "Enabled") {
            Write-Log "Enabling $Feature..." "INFO"
            try {
                $Result = Enable-WindowsOptionalFeature -Online -FeatureName $Feature -All -NoRestart
                if ($Result.RestartNeeded) {
                    $RestartRequired = $true
                }
            }
            catch {
                Write-Log "Failed to enable $Feature. Continuing..." "WARNING"
            }
        }
        else {
            Write-Log "$Feature is already enabled" "INFO"
        }
    }
    
    if ($RestartRequired) {
        Write-Log "A restart is required to complete Windows features installation." "WARNING"
        Write-Log "Please restart your computer and run this script again." "WARNING"
        Read-Host "Press Enter to exit"
        exit 0
    }
    
    Write-Log "Windows features configured" "SUCCESS"
}

# Install WSL2
function Install-WSL {
    if ($SkipWSL) {
        Write-Log "Skipping WSL installation as requested" "INFO"
        return
    }
    
    Write-Log "Installing WSL2..." "STEP"
    
    # Check if WSL is already installed
    try {
        $WSLVersion = wsl --version 2>$null
        if ($WSLVersion) {
            Write-Log "WSL is already installed" "INFO"
        }
    }
    catch {
        Write-Log "Installing WSL..." "INFO"
        wsl --install --no-distribution
    }
    
    # Set WSL2 as default
    wsl --set-default-version 2
    
    # Install Ubuntu if not present
    $Distros = wsl --list --quiet
    if ($Distros -notcontains $Config.WSLDistro) {
        Write-Log "Installing $($Config.WSLDistro)..." "INFO"
        wsl --install --distribution $Config.WSLDistro
    }
    else {
        Write-Log "$($Config.WSLDistro) is already installed" "INFO"
    }
    
    Write-Log "WSL2 installation completed" "SUCCESS"
}

# Install Docker Desktop
function Install-DockerDesktop {
    if ($SkipDocker) {
        Write-Log "Skipping Docker Desktop installation as requested" "INFO"
        return
    }
    
    Write-Log "Installing Docker Desktop..." "STEP"
    
    # Check if Docker is already installed
    try {
        $DockerVersion = docker --version 2>$null
        if ($DockerVersion) {
            Write-Log "Docker Desktop is already installed: $DockerVersion" "INFO"
            return
        }
    }
    catch {
        Write-Log "Docker not found, proceeding with installation..." "INFO"
    }
    
    # Download Docker Desktop installer
    $InstallerPath = "$env:TEMP\DockerDesktopInstaller.exe"
    Write-Log "Downloading Docker Desktop..." "INFO"
    
    try {
        Invoke-WebRequest -Uri $Config.DockerDesktopUrl -OutFile $InstallerPath -UseBasicParsing
    }
    catch {
        Handle-Error "Failed to download Docker Desktop: $($_.Exception.Message)"
    }
    
    # Install Docker Desktop
    Write-Log "Installing Docker Desktop (this may take several minutes)..." "INFO"
    try {
        Start-Process -FilePath $InstallerPath -ArgumentList "install", "--quiet" -Wait
        Remove-Item $InstallerPath -Force
    }
    catch {
        Handle-Error "Failed to install Docker Desktop: $($_.Exception.Message)"
    }
    
    Write-Log "Docker Desktop installation completed" "SUCCESS"
    Write-Log "Please start Docker Desktop manually and complete the initial setup" "INFO"
}

# Install Python and pip
function Install-Python {
    Write-Log "Checking Python installation..." "STEP"
    
    try {
        $PythonVersion = python --version 2>$null
        if ($PythonVersion) {
            Write-Log "Python is already installed: $PythonVersion" "INFO"
            return
        }
    }
    catch {
        Write-Log "Python not found in PATH" "INFO"
    }
    
    # Check if Python is available in Microsoft Store
    Write-Log "Installing Python from Microsoft Store..." "INFO"
    try {
        Start-Process "ms-windows-store://pdp/?ProductId=9NRWMJP3717K" -Wait
        Write-Log "Please install Python from the Microsoft Store and run this script again" "WARNING"
        Read-Host "Press Enter after installing Python"
    }
    catch {
        Write-Log "Could not open Microsoft Store. Please install Python manually from python.org" "WARNING"
    }
}

# Install Exegol in WSL
function Install-ExegolWSL {
    Write-Log "Installing Exegol in WSL..." "STEP"
    
    # Create installation script for WSL
    $WSLScript = @"
#!/bin/bash
set -e

echo "Updating package lists..."
sudo apt update -qq

echo "Installing Python and pip..."
sudo apt install -y python3 python3-pip

echo "Installing Exegol..."
pip3 install --user exegol

echo "Adding ~/.local/bin to PATH..."
echo 'export PATH="\$HOME/.local/bin:\$PATH"' >> ~/.bashrc

echo "Exegol installation completed in WSL"
"@
    
    $ScriptPath = "$($Config.InstallDir)\install-exegol-wsl.sh"
    $WSLScript | Out-File -FilePath $ScriptPath -Encoding UTF8
    
    # Execute script in WSL
    try {
        wsl --distribution $Config.WSLDistro --exec bash -c "$(Get-Content $ScriptPath -Raw)"
        Remove-Item $ScriptPath -Force
        Write-Log "Exegol installed successfully in WSL" "SUCCESS"
    }
    catch {
        Handle-Error "Failed to install Exegol in WSL: $($_.Exception.Message)"
    }
}

# Create Windows shortcuts and configuration
function New-WindowsShortcuts {
    Write-Log "Creating Windows shortcuts..." "STEP"
    
    # Create batch files for easy access
    $BatchFiles = @{
        "exegol-start.bat" = @"
@echo off
wsl --distribution $($Config.WSLDistro) --exec bash -c "source ~/.bashrc && exegol start"
pause
"@
        "exegol-gui.bat" = @"
@echo off
wsl --distribution $($Config.WSLDistro) --exec bash -c "source ~/.bashrc && exegol start -X"
pause
"@
        "exegol-shell.bat" = @"
@echo off
wsl --distribution $($Config.WSLDistro)
"@
    }
    
    foreach ($File in $BatchFiles.Keys) {
        $FilePath = Join-Path $Config.InstallDir $File
        $BatchFiles[$File] | Out-File -FilePath $FilePath -Encoding ASCII
        Write-Log "Created $File" "INFO"
    }
    
    # Create desktop shortcuts
    $WshShell = New-Object -comObject WScript.Shell
    
    $Shortcuts = @{
        "Exegol Enhanced.lnk" = Join-Path $Config.InstallDir "exegol-start.bat"
        "Exegol Enhanced (GUI).lnk" = Join-Path $Config.InstallDir "exegol-gui.bat"
        "Exegol Enhanced (Shell).lnk" = Join-Path $Config.InstallDir "exegol-shell.bat"
    }
    
    foreach ($Shortcut in $Shortcuts.Keys) {
        $ShortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) $Shortcut
        $WshShortcut = $WshShell.CreateShortcut($ShortcutPath)
        $WshShortcut.TargetPath = $Shortcuts[$Shortcut]
        $WshShortcut.WorkingDirectory = $Config.InstallDir
        $WshShortcut.Description = "Exegol Enhanced - Ultimate Cybersecurity Environment"
        $WshShortcut.Save()
    }
    
    Write-Log "Windows shortcuts created" "SUCCESS"
}

# Create configuration files
function New-Configuration {
    Write-Log "Creating configuration files..." "STEP"
    
    # Create PowerShell profile additions
    $ProfileAddition = @"

# Exegol Enhanced Functions
function Start-Exegol { wsl --distribution $($Config.WSLDistro) --exec bash -c "source ~/.bashrc && exegol start" }
function Start-ExegolGUI { wsl --distribution $($Config.WSLDistro) --exec bash -c "source ~/.bashrc && exegol start -X" }
function Enter-ExegolShell { wsl --distribution $($Config.WSLDistro) }
function Show-ExegolLogs { Get-Content "$($Config.LogFile)" -Tail 50 }

# Aliases
Set-Alias -Name exegol -Value Start-Exegol
Set-Alias -Name exegol-gui -Value Start-ExegolGUI
Set-Alias -Name exegol-shell -Value Enter-ExegolShell
Set-Alias -Name exegol-logs -Value Show-ExegolLogs

Write-Host "Exegol Enhanced commands loaded!" -ForegroundColor Green
Write-Host "Available commands: exegol, exegol-gui, exegol-shell, exegol-logs" -ForegroundColor Cyan
"@
    
    # Add to PowerShell profile
    $ProfilePath = $PROFILE.CurrentUserAllHosts
    if (!(Test-Path $ProfilePath)) {
        New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
    }
    
    if (!(Get-Content $ProfilePath -ErrorAction SilentlyContinue | Select-String "Exegol Enhanced")) {
        Add-Content -Path $ProfilePath -Value $ProfileAddition
        Write-Log "PowerShell profile updated" "SUCCESS"
    }
    
    # Create configuration file
    $ConfigContent = @"
# Exegol Enhanced Configuration for Windows
INSTALL_DIR=$($Config.InstallDir)
WSL_DISTRO=$($Config.WSLDistro)
LOG_FILE=$($Config.LogFile)
GUI_ENABLED=true
AUTO_UPDATE=true
"@
    
    $ConfigContent | Out-File -FilePath (Join-Path $Config.InstallDir "config.conf") -Encoding UTF8
    
    Write-Log "Configuration files created" "SUCCESS"
}

# Validate installation
function Test-Installation {
    Write-Log "Validating installation..." "STEP"
    
    # Test WSL
    try {
        $WSLTest = wsl --distribution $Config.WSLDistro --exec echo "WSL OK"
        if ($WSLTest -eq "WSL OK") {
            Write-Log "WSL validation passed" "SUCCESS"
        }
    }
    catch {
        Write-Log "WSL validation failed" "ERROR"
    }
    
    # Test Docker (if running)
    try {
        $DockerTest = docker version 2>$null
        if ($DockerTest) {
            Write-Log "Docker validation passed" "SUCCESS"
        }
    }
    catch {
        Write-Log "Docker validation failed (Docker Desktop may not be running)" "WARNING"
    }
    
    # Test Exegol in WSL
    try {
        $ExegolTest = wsl --distribution $Config.WSLDistro --exec bash -c "source ~/.bashrc && exegol version" 2>$null
        if ($ExegolTest) {
            Write-Log "Exegol validation passed" "SUCCESS"
        }
    }
    catch {
        Write-Log "Exegol validation failed" "WARNING"
    }
    
    Write-Log "Installation validation completed" "SUCCESS"
}

# Main installation function
function Start-Installation {
    Show-Banner
    
    Write-Log "Starting Exegol Enhanced installation for Windows..." "INFO"
    Write-Log "This installation requires Administrator privileges and may take 15-30 minutes" "INFO"
    Write-Log "Installation log: $($Config.LogFile)" "INFO"
    Write-Host ""
    
    try {
        Test-WindowsVersion
        Test-SystemRequirements
        Enable-WindowsFeatures
        Install-WSL
        Install-DockerDesktop
        Install-Python
        Install-ExegolWSL
        New-WindowsShortcuts
        New-Configuration
        Test-Installation
        
        Write-Host ""
        Write-Log "🎉 Exegol Enhanced installation completed successfully!" "SUCCESS"
        Write-Host ""
        Write-Log "Next steps:" "INFO"
        Write-Log "1. Start Docker Desktop if not already running" "INFO"
        Write-Log "2. Open a new PowerShell window to load new commands" "INFO"
        Write-Log "3. Run: exegol install (in WSL or use exegol-shell)" "INFO"
        Write-Log "4. Start your first container: exegol start" "INFO"
        Write-Host ""
        Write-Log "Available commands in PowerShell:" "INFO"
        Write-Log "- exegol: Start Exegol container" "INFO"
        Write-Log "- exegol-gui: Start Exegol with GUI support" "INFO"
        Write-Log "- exegol-shell: Enter WSL shell" "INFO"
        Write-Log "- exegol-logs: View installation logs" "INFO"
        Write-Host ""
        Write-Log "Desktop shortcuts have been created for easy access" "INFO"
        Write-Host ""
        Write-Log "Documentation: https://github.com/[your-repo]/exegol-enhanced" "INFO"
        Write-Log "Support: Create an issue on GitHub" "INFO"
        Write-Host ""
        Write-Log "Happy hacking! 🚀" "SUCCESS"
        
    }
    catch {
        Handle-Error $_.Exception.Message
    }
}

# Run main installation
Start-Installation
