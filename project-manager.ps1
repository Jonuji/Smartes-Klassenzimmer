# ============================================
# Smartes Klassenzimmer - Project Manager
# ============================================

# Farbschema
$script:Colors = @{
    Primary = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Accent = "Cyan"
    Header = "White"
}

# Projekt-Konfiguration
$script:Config = @{
    BackendRepo = "https://github.com/Jonuji/Smartes-Klassenzimmer-Backend.git"
    FrontendRepo = "https://github.com/Jonuji/Smartes-Klassenzimmer-Frontend.git"
    BackendDir = "Smartes-Klassenzimmer-Backend"
    FrontendDir = "Smartes-Klassenzimmer-Frontend"
    Teams = @("main", "dev", "team-alpha", "team-beta", "team-gamma")
}

# ============================================
# Helper Functions
# ============================================

function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "SMARTES KLASSENZIMMER" -ForegroundColor $Colors.Header -NoNewline
    Write-Host " - " -ForegroundColor $Colors.Info -NoNewline
    Write-Host "PROJECT MANAGER" -ForegroundColor $Colors.Accent
    Write-Host "========================================" -ForegroundColor $Colors.Accent
    Write-Host ""
}

function Show-ProgressBar {
    param(
        [string]$Activity,
        [int]$PercentComplete,
        [string]$Status = ""
    )
    
    $barLength = 50
    $completed = [math]::Floor($barLength * $PercentComplete / 100)
    $remaining = $barLength - $completed
    
    $bar = "#" * $completed + "." * $remaining
    
    Write-Host "`r$Activity [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host $bar -NoNewline -ForegroundColor $Colors.Primary
    Write-Host "] $PercentComplete% " -NoNewline -ForegroundColor $Colors.Info
    if ($Status) {
        Write-Host $Status -NoNewline -ForegroundColor $Colors.Warning
    }
}

function Test-Prerequisites {
    Write-Host "Ueberpruefe Systemvoraussetzungen..." -ForegroundColor $Colors.Info
    Write-Host ""
    
    # Git pruefen
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host "[OK] Git gefunden" -ForegroundColor $Colors.Info
    } else {
        Write-Host "[FEHLER] Git nicht gefunden!" -ForegroundColor $Colors.Error
        Write-Host "  Bitte installieren Sie Git von: https://git-scm.com/download/win" -ForegroundColor $Colors.Info
        return $false
    }
    
    # Node.js pruefen
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        $nodeVersion = node --version
        Write-Host "[OK] Node.js gefunden ($nodeVersion)" -ForegroundColor $Colors.Info
    } else {
        Write-Host "[FEHLER] Node.js nicht gefunden!" -ForegroundColor $Colors.Error
        Write-Host "  Bitte installieren Sie Node.js von: https://nodejs.org/" -ForegroundColor $Colors.Info
        return $false
    }
    
    Write-Host ""
    return $true
}

function Select-Branch {
    param(
        [string]$ProjectName,
        [string]$RepoUrl
    )
    
    Write-Host ""
    Write-Host "Branch Auswahl: " -ForegroundColor $Colors.Info -NoNewline
    Write-Host $ProjectName -ForegroundColor $Colors.Accent
    Write-Host ""
    Write-Host "Lade verfuegbare Branches..." -ForegroundColor $Colors.Info
    
    # Branches von Remote Repository abrufen
    $branches = @()
    try {
        $remoteBranches = git ls-remote --heads $RepoUrl 2>&1
        if ($LASTEXITCODE -eq 0) {
            $branches = $remoteBranches | ForEach-Object {
                if ($_ -match 'refs/heads/(.+)$') {
                    $matches[1]
                }
            } | Sort-Object
        }
    } catch {
        Write-Host "Fehler beim Abrufen der Branches. Verwende Standard-Branches..." -ForegroundColor $Colors.Info
    }
    
    # Fallback auf Standard-Branches falls Abruf fehlschlaegt
    if ($branches.Count -eq 0) {
        $branches = $Config.Teams
    }
    
    Write-Host ""
    
    for ($i = 0; $i -lt $branches.Count; $i++) {
        Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
        Write-Host "$($i + 1)" -NoNewline -ForegroundColor $Colors.Accent
        Write-Host "] " -NoNewline -ForegroundColor $Colors.Info
        Write-Host $branches[$i] -ForegroundColor $Colors.Info
    }
    
    Write-Host ""
    Write-Host "Waehlen Sie einen Branch [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "1-$($branches.Count)" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "]: " -NoNewline -ForegroundColor $Colors.Info
    
    $selection = Read-Host
    
    if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $branches.Count) {
        return $branches[[int]$selection - 1]
    } else {
        Write-Host "Ungueltige Auswahl. Verwende 'main'..." -ForegroundColor $Colors.Info
        return "main"
    }
}

# ============================================
# Main Functions
# ============================================

function Clone-Repositories {
    param([bool]$InstallDeps = $false)
    
    Show-Header
    Write-Host "REPOSITORIES KLONEN" -ForegroundColor $Colors.Accent
    Write-Host ""
    
    if (-not (Test-Prerequisites)) {
        Pause-WithMessage
        return
    }
    
    # Branch Auswahl
    $backendBranch = Select-Branch -ProjectName "Backend" -RepoUrl $Config.BackendRepo
    $frontendBranch = Select-Branch -ProjectName "Frontend" -RepoUrl $Config.FrontendRepo
    
    Write-Host ""
    
    # Backend klonen
    Write-Host "Klone Backend Repository..." -ForegroundColor $Colors.Info
    if (Test-Path $Config.BackendDir) {
        Write-Host "Backend Ordner existiert bereits. Ueberspringe..." -ForegroundColor $Colors.Info
    } else {
        git clone -b $backendBranch $Config.BackendRepo 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Backend geklont (" -NoNewline -ForegroundColor $Colors.Success
            Write-Host $backendBranch -NoNewline -ForegroundColor $Colors.Accent
            Write-Host ")" -ForegroundColor $Colors.Success
        } else {
            Write-Host "[FEHLER] Fehler beim Klonen des Backends!" -ForegroundColor $Colors.Error
            Pause-WithMessage
            return
        }
    }
    
    Write-Host ""
    
    # Frontend klonen
    Write-Host "Klone Frontend Repository..." -ForegroundColor $Colors.Info
    if (Test-Path $Config.FrontendDir) {
        Write-Host "Frontend Ordner existiert bereits. Ueberspringe..." -ForegroundColor $Colors.Info
    } else {
        git clone -b $frontendBranch $Config.FrontendRepo 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Frontend geklont (" -NoNewline -ForegroundColor $Colors.Success
            Write-Host $frontendBranch -NoNewline -ForegroundColor $Colors.Accent
            Write-Host ")" -ForegroundColor $Colors.Success
        } else {
            Write-Host "[FEHLER] Fehler beim Klonen des Frontends!" -ForegroundColor $Colors.Error
            Pause-WithMessage
            return
        }
    }
    
    Write-Host ""
    
    if ($InstallDeps) {
        Write-Host "----------------------------------------" -ForegroundColor $Colors.Accent
        Write-Host ""
        Install-Dependencies -SkipHeader $true
    } else {
        Write-Host "[OK] Klonen abgeschlossen!" -ForegroundColor $Colors.Success
    }
    
    # VSCode Konfiguration erstellen
    Write-Host ""
    Write-Host "Erstelle VSCode Konfiguration..." -ForegroundColor $Colors.Info
    Create-VSCodeConfig
    
    Pause-WithMessage
}

function Install-Dependencies {
    param([bool]$SkipHeader = $false)
    
    if (-not $SkipHeader) {
        Show-Header
        Write-Host "ABHAENGIGKEITEN INSTALLIEREN" -ForegroundColor $Colors.Accent
        Write-Host ""
    }
    
    if (-not (Test-Path $Config.BackendDir) -or -not (Test-Path $Config.FrontendDir)) {
        Write-Host "[FEHLER] Projektordner nicht gefunden!" -ForegroundColor $Colors.Error
        Write-Host "Bitte fuehren Sie zuerst 'Clone Repositories' aus." -ForegroundColor $Colors.Info
        Pause-WithMessage
        return
    }
    
    # Backend Dependencies
    Write-Host "Installiere Backend Dependencies..." -ForegroundColor $Colors.Info
    
    Push-Location $Config.BackendDir
    npm install 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Backend Dependencies installiert" -ForegroundColor $Colors.Success
    } else {
        Write-Host "[FEHLER] Fehler bei Backend Dependencies" -ForegroundColor $Colors.Error
        Pop-Location
        Pause-WithMessage
        return
    }
    
    Pop-Location
    
    Write-Host ""
    
    # Frontend Dependencies
    Write-Host "Installiere Frontend Dependencies..." -ForegroundColor $Colors.Info
    
    Push-Location $Config.FrontendDir
    npm install 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Frontend Dependencies installiert" -ForegroundColor $Colors.Success
    } else {
        Write-Host "[FEHLER] Fehler bei Frontend Dependencies" -ForegroundColor $Colors.Error
        Pop-Location
        Pause-WithMessage
        return
    }
    
    Pop-Location
    
    Write-Host ""
    Write-Host "[OK] Installation abgeschlossen" -ForegroundColor $Colors.Success
    Write-Host ""
    
    if (-not $SkipHeader) {
        Pause-WithMessage
    }
}

function Start-Projects {
    Show-Header
    Write-Host "PROJEKTE STARTEN" -ForegroundColor $Colors.Accent
    Write-Host ""
    
    if (-not (Test-Path $Config.BackendDir) -or -not (Test-Path $Config.FrontendDir)) {
        Write-Host "[FEHLER] Projektordner nicht gefunden!" -ForegroundColor $Colors.Error
        Write-Host "Bitte fuehren Sie zuerst 'Clone Repositories' aus." -ForegroundColor $Colors.Info
        Pause-WithMessage
        return
    }
    
    Write-Host "Backend:  " -NoNewline -ForegroundColor $Colors.Info
    Write-Host "http://localhost:3000" -ForegroundColor $Colors.Accent
    Write-Host "Frontend: " -NoNewline -ForegroundColor $Colors.Info
    Write-Host "http://localhost:5173" -ForegroundColor $Colors.Accent
    Write-Host ""
    Write-Host "Druecken Sie Strg+C in den Fenstern zum Beenden." -ForegroundColor $Colors.Info
    Write-Host ""
    
    # Backend starten
    Write-Host "Starte Backend..." -ForegroundColor $Colors.Info
    $backendPath = Join-Path $PWD $Config.BackendDir
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; `$host.UI.RawUI.WindowTitle = 'Backend Server'; Write-Host 'Backend Server' -ForegroundColor Green; Write-Host ''; npm run start:dev"
    
    Start-Sleep -Seconds 1
    
    # Frontend starten
    Write-Host "Starte Frontend..." -ForegroundColor $Colors.Info
    $frontendPath = Join-Path $PWD $Config.FrontendDir
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$frontendPath'; `$host.UI.RawUI.WindowTitle = 'Frontend Server'; Write-Host 'Frontend Server' -ForegroundColor Green; Write-Host ''; npm run dev"
    
    Write-Host ""
    Write-Host "[OK] Beide Projekte gestartet" -ForegroundColor $Colors.Success
    Write-Host ""
    
    Pause-WithMessage
}

function Fetch-And-Pull {
    Show-Header
    Write-Host "FETCH & PULL VON REMOTE" -ForegroundColor $Colors.Accent
    Write-Host ""
    
    if (-not (Test-Path $Config.BackendDir) -or -not (Test-Path $Config.FrontendDir)) {
        Write-Host "[FEHLER] Projektordner nicht gefunden!" -ForegroundColor $Colors.Error
        Write-Host "Bitte fuehren Sie zuerst 'Clone Repositories' aus." -ForegroundColor $Colors.Info
        Pause-WithMessage
        return
    }
    
    # Backend aktualisieren
    Write-Host "Backend aktualisieren..." -ForegroundColor $Colors.Info
    Push-Location $Config.BackendDir
    
    $currentBranch = git branch --show-current
    Write-Host "Aktueller Branch: " -NoNewline -ForegroundColor $Colors.Info
    Write-Host $currentBranch -ForegroundColor $Colors.Accent
    Write-Host ""
    
    # Fetch
    Write-Host "Hole Updates von Remote..." -ForegroundColor $Colors.Info
    git fetch origin 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Fetch erfolgreich" -ForegroundColor $Colors.Success
        
        # Prüfe ob Updates verfügbar sind
        $behind = git rev-list HEAD..origin/$currentBranch --count 2>$null
        if ($behind -and $behind -gt 0) {
            Write-Host ""
            Write-Host "Es sind " -NoNewline -ForegroundColor $Colors.Info
            Write-Host "$behind Commit(s)" -NoNewline -ForegroundColor $Colors.Accent
            Write-Host " zum Pullen verfuegbar." -ForegroundColor $Colors.Info
            Write-Host ""
            Write-Host "Moechten Sie pullen? (j/n): " -NoNewline -ForegroundColor $Colors.Warning
            $response = Read-Host
            
            if ($response -eq 'j' -or $response -eq 'J') {
                git pull origin $currentBranch 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[OK] Backend aktualisiert" -ForegroundColor $Colors.Success
                } else {
                    Write-Host "[FEHLER] Pull fehlgeschlagen" -ForegroundColor $Colors.Error
                }
            } else {
                Write-Host "Pull uebersprungen" -ForegroundColor $Colors.Info
            }
        } else {
            Write-Host "[OK] Backend ist bereits aktuell" -ForegroundColor $Colors.Success
        }
    } else {
        Write-Host "[FEHLER] Fetch fehlgeschlagen" -ForegroundColor $Colors.Error
    }
    
    Pop-Location
    
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor $Colors.Accent
    Write-Host ""
    
    # Frontend aktualisieren
    Write-Host "Frontend aktualisieren..." -ForegroundColor $Colors.Info
    Push-Location $Config.FrontendDir
    
    $currentBranch = git branch --show-current
    Write-Host "Aktueller Branch: " -NoNewline -ForegroundColor $Colors.Info
    Write-Host $currentBranch -ForegroundColor $Colors.Accent
    Write-Host ""
    
    Write-Host "Hole Updates von Remote..." -ForegroundColor $Colors.Info
    git fetch origin 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Fetch erfolgreich" -ForegroundColor $Colors.Success
        
        $behind = git rev-list HEAD..origin/$currentBranch --count 2>$null
        if ($behind -and $behind -gt 0) {
            Write-Host ""
            Write-Host "Es sind " -NoNewline -ForegroundColor $Colors.Info
            Write-Host "$behind Commit(s)" -NoNewline -ForegroundColor $Colors.Accent
            Write-Host " zum Pullen verfuegbar." -ForegroundColor $Colors.Info
            Write-Host ""
            Write-Host "Moechten Sie pullen? (j/n): " -NoNewline -ForegroundColor $Colors.Warning
            $response = Read-Host
            
            if ($response -eq 'j' -or $response -eq 'J') {
                git pull origin $currentBranch 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[OK] Frontend aktualisiert" -ForegroundColor $Colors.Success
                } else {
                    Write-Host "[FEHLER] Pull fehlgeschlagen" -ForegroundColor $Colors.Error
                }
            } else {
                Write-Host "Pull uebersprungen" -ForegroundColor $Colors.Info
            }
        } else {
            Write-Host "[OK] Frontend ist bereits aktuell" -ForegroundColor $Colors.Success
        }
    } else {
        Write-Host "[FEHLER] Fetch fehlgeschlagen" -ForegroundColor $Colors.Error
    }
    
    Pop-Location
    
    Write-Host ""
    Pause-WithMessage
}

function Create-PullRequest {
    Show-Header
    Write-Host "PULL REQUEST ERSTELLEN" -ForegroundColor $Colors.Accent
    Write-Host ""
    
    if (-not (Test-Path $Config.BackendDir) -or -not (Test-Path $Config.FrontendDir)) {
        Write-Host "[FEHLER] Projektordner nicht gefunden!" -ForegroundColor $Colors.Error
        Pause-WithMessage
        return
    }
    
    Write-Host "Waehlen Sie das Projekt:" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "1" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "] Backend" -ForegroundColor $Colors.Info
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "2" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "] Frontend" -ForegroundColor $Colors.Info
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "3" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "] Beide" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "Auswahl [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "1-3" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "]: " -NoNewline -ForegroundColor $Colors.Info
    $projectChoice = Read-Host
    
    $projects = @()
    switch ($projectChoice) {
        "1" { $projects = @(@{Name="Backend"; Dir=$Config.BackendDir; Repo="Smartes-Klassenzimmer-Backend"}) }
        "2" { $projects = @(@{Name="Frontend"; Dir=$Config.FrontendDir; Repo="Smartes-Klassenzimmer-Frontend"}) }
        "3" { 
            $projects = @(
                @{Name="Backend"; Dir=$Config.BackendDir; Repo="Smartes-Klassenzimmer-Backend"},
                @{Name="Frontend"; Dir=$Config.FrontendDir; Repo="Smartes-Klassenzimmer-Frontend"}
            )
        }
        default {
            Write-Host "[FEHLER] Ungueltige Auswahl" -ForegroundColor $Colors.Error
            Pause-WithMessage
            return
        }
    }
    
    Write-Host ""
    
    foreach ($project in $projects) {
        Write-Host "========================================" -ForegroundColor $Colors.Accent
        Write-Host $project.Name -ForegroundColor $Colors.Accent
        Write-Host "========================================" -ForegroundColor $Colors.Accent
        Write-Host ""
        
        Push-Location $project.Dir
        
        $currentBranch = git branch --show-current
        Write-Host "Aktueller Branch: " -NoNewline -ForegroundColor $Colors.Info
        Write-Host $currentBranch -ForegroundColor $Colors.Accent
        Write-Host ""
        
        if ($currentBranch -eq "dev") {
            Write-Host "[INFO] Sie sind bereits auf dem dev Branch." -ForegroundColor $Colors.Warning
            Write-Host "Pull Request nicht noetig." -ForegroundColor $Colors.Info
            Pop-Location
            Write-Host ""
            continue
        }
        
        # Prüfe ob Branch gepusht ist
        $remoteExists = git ls-remote --heads origin $currentBranch 2>$null
        if (-not $remoteExists) {
            Write-Host "[WARNUNG] Branch ist noch nicht auf Remote!" -ForegroundColor $Colors.Warning
            Write-Host "Pushen Sie zuerst Ihren Branch: git push -u origin $currentBranch" -ForegroundColor $Colors.Info
            Pop-Location
            Write-Host ""
            continue
        }
        
        # GitHub CLI verfügbar?
        if (Get-Command gh -ErrorAction SilentlyContinue) {
            Write-Host "Erstelle Pull Request von " -NoNewline -ForegroundColor $Colors.Info
            Write-Host $currentBranch -NoNewline -ForegroundColor $Colors.Accent
            Write-Host " -> " -NoNewline -ForegroundColor $Colors.Info
            Write-Host "dev" -ForegroundColor $Colors.Accent
            Write-Host ""
            Write-Host "PR-Titel eingeben: " -NoNewline -ForegroundColor $Colors.Info
            $prTitle = Read-Host
            Write-Host "PR-Beschreibung (optional, Enter zum Ueberspringen): " -NoNewline -ForegroundColor $Colors.Info
            $prBody = Read-Host
            
            Write-Host ""
            Write-Host "Erstelle Pull Request..." -ForegroundColor $Colors.Info
            
            if ($prBody) {
                gh pr create --base dev --head $currentBranch --title "$prTitle" --body "$prBody" 2>&1 | Out-Null
            } else {
                gh pr create --base dev --head $currentBranch --title "$prTitle" 2>&1 | Out-Null
            }
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[OK] Pull Request erstellt!" -ForegroundColor $Colors.Success
                $prUrl = gh pr view --json url -q .url 2>$null
                if ($prUrl) {
                    Write-Host "URL: " -NoNewline -ForegroundColor $Colors.Info
                    Write-Host $prUrl -ForegroundColor $Colors.Accent
                }
            } else {
                Write-Host "[FEHLER] Pull Request konnte nicht erstellt werden" -ForegroundColor $Colors.Error
            }
        } else {
            Write-Host "[INFO] GitHub CLI (gh) ist nicht installiert." -ForegroundColor $Colors.Warning
            Write-Host ""
            Write-Host "Oeffne Browser fuer manuelles Erstellen des Pull Requests:" -ForegroundColor $Colors.Info
            $prUrl = "https://github.com/Jonuji/$($project.Repo)/compare/dev...$currentBranch"
            Write-Host $prUrl -ForegroundColor $Colors.Accent
            Write-Host ""
            Write-Host "Browser oeffnen? (j/n): " -NoNewline -ForegroundColor $Colors.Warning
            $openBrowser = Read-Host
            
            if ($openBrowser -eq 'j' -or $openBrowser -eq 'J') {
                Start-Process $prUrl
                Write-Host "[OK] Browser geoeffnet" -ForegroundColor $Colors.Success
            }
        }
        
        Pop-Location
        Write-Host ""
    }
    
    Pause-WithMessage
}

function Switch-Branch {
    Show-Header
    Write-Host "BRANCH WECHSELN" -ForegroundColor $Colors.Accent
    Write-Host ""
    
    if (-not (Test-Path $Config.BackendDir) -or -not (Test-Path $Config.FrontendDir)) {
        Write-Host "[FEHLER] Projektordner nicht gefunden!" -ForegroundColor $Colors.Error
        Pause-WithMessage
        return
    }
    
    # Backend Branch wechseln - Lade Remote Branches
    Write-Host "Backend - Lade Remote Branches..." -ForegroundColor $Colors.Info
    Push-Location $Config.BackendDir
    
    # Fetch um aktuelle Branches zu holen
    git fetch origin 2>&1 | Out-Null
    
    # Hole alle Remote Branches
    $backendBranches = git branch -r | ForEach-Object { 
        $branch = $_.Trim()
        if ($branch -match 'origin/(.+)' -and $matches[1] -notmatch 'HEAD') {
            $matches[1]
        }
    } | Sort-Object -Unique
    
    $currentBranch = git branch --show-current
    Pop-Location
    
    Write-Host ""
    Write-Host "Branch Auswahl: " -ForegroundColor $Colors.Info -NoNewline
    Write-Host "Backend" -ForegroundColor $Colors.Accent
    Write-Host "Aktuell: " -NoNewline -ForegroundColor $Colors.Info
    Write-Host $currentBranch -ForegroundColor $Colors.Accent
    Write-Host ""
    
    for ($i = 0; $i -lt $backendBranches.Count; $i++) {
        Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
        Write-Host "$($i + 1)" -NoNewline -ForegroundColor $Colors.Accent
        Write-Host "] " -NoNewline -ForegroundColor $Colors.Info
        if ($backendBranches[$i] -eq $currentBranch) {
            Write-Host "$($backendBranches[$i]) (aktuell)" -ForegroundColor $Colors.Success
        } else {
            Write-Host $backendBranches[$i] -ForegroundColor $Colors.Info
        }
    }
    
    Write-Host ""
    Write-Host "Waehlen Sie einen Branch [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "1-$($backendBranches.Count)" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "]: " -NoNewline -ForegroundColor $Colors.Info
    $selection = Read-Host
    
    if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $backendBranches.Count) {
        $backendBranch = $backendBranches[[int]$selection - 1]
    } else {
        Write-Host "Ungueltige Auswahl. Abbruch..." -ForegroundColor $Colors.Error
        Pause-WithMessage
        return
    }
    
    if ($backendBranch -eq $currentBranch) {
        Write-Host ""
        Write-Host "[INFO] Bereits auf Branch '" -NoNewline -ForegroundColor $Colors.Info
        Write-Host $backendBranch -NoNewline -ForegroundColor $Colors.Accent
        Write-Host "'" -ForegroundColor $Colors.Info
    } else {
        Write-Host ""
        Write-Host "Wechsle Backend Branch..." -ForegroundColor $Colors.Info
        Push-Location $Config.BackendDir
        git checkout $backendBranch 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Backend jetzt auf '" -NoNewline -ForegroundColor $Colors.Success
            Write-Host $backendBranch -NoNewline -ForegroundColor $Colors.Accent
            Write-Host "'" -ForegroundColor $Colors.Success
            
            # Frage ob gepullt werden soll
            Write-Host ""
            Write-Host "Moechten Sie die neuesten Updates pullen? (j/n): " -NoNewline -ForegroundColor $Colors.Warning
            $pullResponse = Read-Host
            
            if ($pullResponse -eq 'j' -or $pullResponse -eq 'J') {
                Write-Host "Pulling..." -ForegroundColor $Colors.Info
                git pull origin $backendBranch 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[OK] Backend aktualisiert" -ForegroundColor $Colors.Success
                } else {
                    Write-Host "[FEHLER] Pull fehlgeschlagen" -ForegroundColor $Colors.Error
                }
            }
        } else {
            Write-Host "[FEHLER] Branch-Wechsel fehlgeschlagen" -ForegroundColor $Colors.Error
        }
        Pop-Location
    }
    
    Write-Host ""
    
    # Frontend Branch wechseln - Lade Remote Branches
    Write-Host "Frontend - Lade Remote Branches..." -ForegroundColor $Colors.Info
    Push-Location $Config.FrontendDir
    
    git fetch origin 2>&1 | Out-Null
    
    $frontendBranches = git branch -r | ForEach-Object { 
        $branch = $_.Trim()
        if ($branch -match 'origin/(.+)' -and $matches[1] -notmatch 'HEAD') {
            $matches[1]
        }
    } | Sort-Object -Unique
    
    $currentBranch = git branch --show-current
    Pop-Location
    
    Write-Host ""
    Write-Host "Branch Auswahl: " -ForegroundColor $Colors.Info -NoNewline
    Write-Host "Frontend" -ForegroundColor $Colors.Accent
    Write-Host "Aktuell: " -NoNewline -ForegroundColor $Colors.Info
    Write-Host $currentBranch -ForegroundColor $Colors.Accent
    Write-Host ""
    
    for ($i = 0; $i -lt $frontendBranches.Count; $i++) {
        Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
        Write-Host "$($i + 1)" -NoNewline -ForegroundColor $Colors.Accent
        Write-Host "] " -NoNewline -ForegroundColor $Colors.Info
        if ($frontendBranches[$i] -eq $currentBranch) {
            Write-Host "$($frontendBranches[$i]) (aktuell)" -ForegroundColor $Colors.Success
        } else {
            Write-Host $frontendBranches[$i] -ForegroundColor $Colors.Info
        }
    }
    
    Write-Host ""
    Write-Host "Waehlen Sie einen Branch [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "1-$($frontendBranches.Count)" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "]: " -NoNewline -ForegroundColor $Colors.Info
    $selection = Read-Host
    
    if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $frontendBranches.Count) {
        $frontendBranch = $frontendBranches[[int]$selection - 1]
    } else {
        Write-Host "Ungueltige Auswahl. Abbruch..." -ForegroundColor $Colors.Error
        Pause-WithMessage
        return
    }
    
    if ($frontendBranch -eq $currentBranch) {
        Write-Host ""
        Write-Host "[INFO] Bereits auf Branch '" -NoNewline -ForegroundColor $Colors.Info
        Write-Host $frontendBranch -NoNewline -ForegroundColor $Colors.Accent
        Write-Host "'" -ForegroundColor $Colors.Info
    } else {
        Write-Host ""
        Write-Host "Wechsle Frontend Branch..." -ForegroundColor $Colors.Info
        Push-Location $Config.FrontendDir
        git checkout $frontendBranch 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Frontend jetzt auf '" -NoNewline -ForegroundColor $Colors.Success
            Write-Host $frontendBranch -NoNewline -ForegroundColor $Colors.Accent
            Write-Host "'" -ForegroundColor $Colors.Success
            
            Write-Host ""
            Write-Host "Moechten Sie die neuesten Updates pullen? (j/n): " -NoNewline -ForegroundColor $Colors.Warning
            $pullResponse = Read-Host
            
            if ($pullResponse -eq 'j' -or $pullResponse -eq 'J') {
                Write-Host "Pulling..." -ForegroundColor $Colors.Info
                git pull origin $frontendBranch 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[OK] Frontend aktualisiert" -ForegroundColor $Colors.Success
                } else {
                    Write-Host "[FEHLER] Pull fehlgeschlagen" -ForegroundColor $Colors.Error
                }
            }
        } else {
            Write-Host "[FEHLER] Branch-Wechsel fehlgeschlagen" -ForegroundColor $Colors.Error
        }
        Pop-Location
    }
    
    Write-Host ""
    Write-Host "[OK] Branch-Wechsel abgeschlossen!" -ForegroundColor $Colors.Success
    Write-Host ""
    
    Pause-WithMessage
}

function Show-ProjectStatus {
    Show-Header
    Write-Host "PROJEKT STATUS" -ForegroundColor $Colors.Accent
    Write-Host ""
    
    if (-not (Test-Path $Config.BackendDir)) {
        Write-Host "Backend: " -NoNewline -ForegroundColor $Colors.Info
        Write-Host "[X] Nicht geklont" -ForegroundColor $Colors.Error
    } else {
        Push-Location $Config.BackendDir
        $branch = git branch --show-current
        $status = git status --porcelain
        $changeCount = ($status | Measure-Object).Count
        
        Write-Host "Backend: " -NoNewline -ForegroundColor $Colors.Info
        Write-Host "[OK] Geklont" -ForegroundColor $Colors.Success
        Write-Host "  Branch: " -NoNewline -ForegroundColor $Colors.Info
        Write-Host $branch -ForegroundColor $Colors.Accent
        Write-Host "  Aenderungen: " -NoNewline -ForegroundColor $Colors.Info
        if ($changeCount -eq 0) {
            Write-Host "Keine" -ForegroundColor $Colors.Success
        } else {
            Write-Host "$changeCount Datei(en)" -ForegroundColor $Colors.Warning
        }
        Pop-Location
    }
    
    Write-Host ""
    
    if (-not (Test-Path $Config.FrontendDir)) {
        Write-Host "Frontend: " -NoNewline -ForegroundColor $Colors.Info
        Write-Host "[X] Nicht geklont" -ForegroundColor $Colors.Error
    } else {
        Push-Location $Config.FrontendDir
        $branch = git branch --show-current
        $status = git status --porcelain
        $changeCount = ($status | Measure-Object).Count
        
        Write-Host "Frontend: " -NoNewline -ForegroundColor $Colors.Info
        Write-Host "[OK] Geklont" -ForegroundColor $Colors.Success
        Write-Host "  Branch: " -NoNewline -ForegroundColor $Colors.Info
        Write-Host $branch -ForegroundColor $Colors.Accent
        Write-Host "  Aenderungen: " -NoNewline -ForegroundColor $Colors.Info
        if ($changeCount -eq 0) {
            Write-Host "Keine" -ForegroundColor $Colors.Success
        } else {
            Write-Host "$changeCount Datei(en)" -ForegroundColor $Colors.Warning
        }
        Pop-Location
    }
    
    Write-Host ""
    Pause-WithMessage
}

function Pause-WithMessage {
    Write-Host ""
    Write-Host "Druecken Sie eine beliebige Taste zum Fortfahren..." -ForegroundColor $Colors.Info
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Create-VSCodeConfig {
    # Root VSCode Config
    $rootVSCodeDir = ".vscode"
    
    if (-not (Test-Path $rootVSCodeDir)) {
        New-Item -ItemType Directory -Path $rootVSCodeDir -Force | Out-Null
    }
    
    # Extensions
    $extensionsJson = @"
{
  "recommendations": [
    "svelte.svelte-vscode",
    "fill-labs.dependi",
    "pinage404.git-extension-pack"
  ]
}
"@
    $extensionsPath = Join-Path $rootVSCodeDir "extensions.json"
    Set-Content -Path $extensionsPath -Value $extensionsJson -Encoding UTF8
    
    Write-Host "[OK] VSCode Konfiguration erstellt" -ForegroundColor $Colors.Success
    
    # MCP Server Config
    $mcpJson = @"
{
  "servers": {
    "svelte": {
      "url": "https://mcp.svelte.dev/mcp"
    }
  }
}
"@
    $mcpPath = Join-Path $rootVSCodeDir "mcp.json"
    Set-Content -Path $mcpPath -Value $mcpJson -Encoding UTF8
    
    Write-Host "[OK] MCP Konfiguration erstellt" -ForegroundColor $Colors.Success
    
    # AGENTS.md im Root erstellen
    $agentsMd = @"
# AI Agent Guidelines

## Projekt-Struktur

Dieses Projekt besteht aus zwei Teilen:
- **Frontend:** Svelte 5 (in Smartes-Klassenzimmer-Frontend/)
- **Backend:** NestJS (in Smartes-Klassenzimmer-Backend/)

---

## Frontend - Svelte 5

### Framework Version

**WICHTIG:** Das Frontend verwendet **Svelte 5**!

- Verwende KEINE Svelte 4 Syntax
- Nutze Svelte 5 Runes (`$state`, `$derived`, `$effect`, etc.)
- Verwende die neue Svelte 5 Component API

### MCP Server

Fuer Svelte-bezogene Fragen und Code:
- Nutze den **Svelte MCP Server** unter https://mcp.svelte.dev/mcp
- Der MCP Server bietet offizielle Svelte 5 Dokumentation
- Bei Unsicherheiten zur Svelte 5 Syntax: MCP Server konsultieren

### Svelte 5 Best Practices

- Verwende Runes fuer reaktive State
- Nutze `$props()` statt export let
- Verwende `$bindable()` fuer Two-Way-Binding
- Snippets statt Slots (wo sinnvoll)

### Beispiel (Svelte 5):

```
<script>
  let { value = `$bindable(0), max = 100 } = `$props();
  
  let percentage = `$derived((value / max) * 100);
  
  `$effect(() => {
    console.log('Value changed:', value);
  });
</script>

<div class="progress" style="width: {percentage}%"></div>
```

### Ressourcen

- [Svelte 5 Docs](https://svelte.dev/docs/svelte/overview)
- [Svelte 5 Migration Guide](https://svelte.dev/docs/svelte/v5-migration-guide)

---

## Backend - NestJS

### Framework

Das Backend nutzt **NestJS** mit TypeScript.

**WICHTIG:** Keine Svelte-Syntax im Backend!

### NestJS Best Practices

- Verwende Dependency Injection
- Folge der modularen Architektur
- DTOs fuer Validierung
- Guards fuer Authentication/Authorization
- Interceptors fuer Logging/Transformation
- Pipes fuer Validierung

### Projekt-Struktur

```
src/
  modules/
    users/
      users.controller.ts
      users.service.ts
      users.module.ts
      dto/
      entities/
  common/
    guards/
    interceptors/
    decorators/
  main.ts
```

### Beispiel (NestJS Controller):

```
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @UseGuards(AuthGuard)
  findAll() {
    return this.usersService.findAll();
  }

  @Post()
  @UsePipes(ValidationPipe)
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }
}
```

### Ressourcen

- [NestJS Documentation](https://docs.nestjs.com/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [NestJS Best Practices](https://docs.nestjs.com/fundamentals)

---

## Wichtige Regeln

1. **Frontend (Svelte 5):**
   - Nutze Svelte MCP Server
   - Verwende IMMER Svelte 5 Syntax
   - Keine Svelte 4 Features

2. **Backend (NestJS):**
   - Verwende NICHT den Svelte MCP Server
   - Keine Svelte-Syntax
   - Halte dich an NestJS Conventions

3. **Allgemein:**
   - Schreibe sauberen, wartbaren Code
   - Folge den Projekt-Standards
   - Dokumentiere komplexe Logik
"@
    $agentsPath = "AGENTS.md"
    Set-Content -Path $agentsPath -Value $agentsMd -Encoding UTF8
    
    Write-Host "[OK] AGENTS.md erstellt" -ForegroundColor $Colors.Success
}

# ============================================
# Main Menu
# ============================================

function Show-Menu {
    Show-Header
    
    Write-Host "Optionen:" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "1" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "] Repositories klonen" -ForegroundColor $Colors.Info
    
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "2" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "] Repositories klonen & Dependencies installieren" -ForegroundColor $Colors.Info
    
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "3" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "] Dependencies installieren" -ForegroundColor $Colors.Info
    
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "4" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "] Projekte starten" -ForegroundColor $Colors.Info
    
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "5" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "] Fetch & Pull von Remote" -ForegroundColor $Colors.Info
    
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "6" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "] Pull Request zu dev erstellen" -ForegroundColor $Colors.Info
    
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "7" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "] Branch wechseln" -ForegroundColor $Colors.Info
    
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "8" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "] Projekt Status anzeigen" -ForegroundColor $Colors.Info
    
    Write-Host "  [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "0" -NoNewline -ForegroundColor $Colors.Error
    Write-Host "] Beenden" -ForegroundColor $Colors.Info
    
    Write-Host ""
    Write-Host "Auswahl [" -NoNewline -ForegroundColor $Colors.Info
    Write-Host "0-8" -NoNewline -ForegroundColor $Colors.Accent
    Write-Host "]: " -NoNewline -ForegroundColor $Colors.Info
}

# ============================================
# Main Program Loop
# ============================================

while ($true) {
    Show-Menu
    $choice = Read-Host
    
    switch ($choice) {
        "1" { Clone-Repositories -InstallDeps $false }
        "2" { Clone-Repositories -InstallDeps $true }
        "3" { Install-Dependencies }
        "4" { Start-Projects }
        "5" { Fetch-And-Pull }
        "6" { Create-PullRequest }
        "7" { Switch-Branch }
        "8" { Show-ProjectStatus }
        "0" {
            Show-Header
            Write-Host "Auf Wiedersehen!" -ForegroundColor $Colors.Info
            Write-Host ""
            exit
        }
        default {
            Show-Header
            Write-Host "[FEHLER] Ungueltige Auswahl!" -ForegroundColor $Colors.Error
            Start-Sleep -Seconds 2
        }
    }
}
