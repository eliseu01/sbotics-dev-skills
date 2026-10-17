<#
.SYNOPSIS
    Desinstalador de skills do repositório sbotics-dev-skills para PowerShell.
.PARAMETER Target
    Harness específico de onde remover as skills.
#>

[CmdletBinding()]
param (
    [string]$Target
)

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SkillsSrc = Join-Path $RepoRoot "skills"
$UserHome = [System.Environment]::GetFolderPath("UserProfile")

$HarnessSkillsDir = @{
    "antigravity" = Join-Path $UserHome ".gemini\antigravity-cli\skills"
    "claude"      = Join-Path $UserHome ".claude\skills"
    "codex"       = Join-Path $UserHome ".codex\skills"
    "pi"          = Join-Path $UserHome ".pi\skills"
    "hermes"      = Join-Path $UserHome ".hermes\skills"
    "agents"      = Join-Path $UserHome ".agents\skills"
    "cursor"      = Join-Path $UserHome ".cursor\skills"
    "copilot"     = Join-Path $UserHome ".copilot\skills"
}

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "   sbotics-dev-skills - Desinstalador de Skills (PS) " -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

$SkillsToRemove = @()
if (Test-Path $SkillsSrc) {
    $SkillsToRemove = (Get-ChildItem -Path $SkillsSrc -Directory).Name
}
if ($SkillsToRemove.Count -eq 0) {
    $SkillsToRemove = @("sbotics-robots", "sbotics-arenas", "sbotics-code")
}

Write-Host "Skills alvo para remoção: $($SkillsToRemove -join ', ')" -ForegroundColor Yellow

$Targets = if ($Target) {
    if ($HarnessSkillsDir.ContainsKey($Target.ToLower())) {
        @($Target.ToLower())
    } else {
        Write-Error "Harness desconhecido: '$Target'."
        exit 1
    }
} else {
    $HarnessSkillsDir.Keys
}

$RemovedCount = 0

foreach ($t in $Targets) {
    $destDir = $HarnessSkillsDir[$t]
    if (Test-Path $destDir) {
        foreach ($skillName in $SkillsToRemove) {
            $targetSkillDir = Join-Path $destDir $skillName
            if (Test-Path $targetSkillDir) {
                Remove-Item -Path $targetSkillDir -Recurse -Force
                Write-Host "  [+] Removido: $skillName de [$t]" -ForegroundColor Green
                $RemovedCount++
            }
        }
    }
}

if ($RemovedCount -gt 0) {
    Write-Host "`n=====================================================" -ForegroundColor Green
    Write-Host "   Desinstalacao concluida com sucesso!              " -ForegroundColor Green
    Write-Host "=====================================================" -ForegroundColor Green
} else {
    Write-Host "`nNenhuma skill encontrada instalada para remocao." -ForegroundColor Yellow
}
