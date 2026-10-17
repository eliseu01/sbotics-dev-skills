<#
.SYNOPSIS
    Instalador de skills do repositório sbotics-dev-skills para PowerShell.
    Suporta: Antigravity, Claude Code, OpenAI Codex, Pi, Hermes, Agents, Cursor, Copilot.
.PARAMETER Target
    Harness específico para instalação (ex: antigravity, claude, codex, etc.).
.PARAMETER All
    Instala em todos os harnesses suportados.
#>

[CmdletBinding()]
param (
    [string]$Target,
    [switch]$All
)

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SkillsSrc = Join-Path $RepoRoot "skills"

if (-not (Test-Path $SkillsSrc)) {
    Write-Error "Pasta 'skills' não encontrada em $RepoRoot."
    exit 1
}

$UserHome = [System.Environment]::GetFolderPath("UserProfile")

$HarnessParents = @{
    "antigravity" = Join-Path $UserHome ".gemini\antigravity-cli"
    "claude"      = Join-Path $UserHome ".claude"
    "codex"       = Join-Path $UserHome ".codex"
    "pi"          = Join-Path $UserHome ".pi"
    "hermes"      = Join-Path $UserHome ".hermes"
    "agents"      = Join-Path $UserHome ".agents"
    "cursor"      = Join-Path $UserHome ".cursor"
    "copilot"     = Join-Path $UserHome ".copilot"
}

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
Write-Host "   sbotics-dev-skills - Instalador de Skills (PS)    " -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

$SkillsToInstall = Get-ChildItem -Path $SkillsSrc -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }
if ($SkillsToInstall.Count -eq 0) {
    Write-Error "Nenhuma skill válida encontrada em $SkillsSrc (necessário conter SKILL.md)."
    exit 1
}

Write-Host "Skills encontradas: $(($SkillsToInstall.Name) -join ', ')" -ForegroundColor Yellow

$Targets = @()
if ($Target) {
    if ($HarnessSkillsDir.ContainsKey($Target.ToLower())) {
        $Targets += $Target.ToLower()
    } else {
        Write-Error "Harness desconhecido: '$Target'. Opções válidas: $($HarnessSkillsDir.Keys -join ', ')"
        exit 1
    }
} elseif ($All) {
    $Targets = $HarnessSkillsDir.Keys
} else {
    Write-Host "`nAuto-detectando harnesses de IA instalados..."
    foreach ($h in $HarnessParents.Keys) {
        $parentPath = $HarnessParents[$h]
        if (Test-Path $parentPath) {
            $Targets += $h
            Write-Host "  [+] Detectado: $h ($parentPath)" -ForegroundColor Green
        }
    }
    if ($Targets.Count -eq 0) {
        Write-Host "Nenhum harness detectado automaticamente. Instalando em antigravity, claude e agents..." -ForegroundColor Yellow
        $Targets = @("antigravity", "claude", "agents")
    }
}

foreach ($t in $Targets) {
    $destDir = $HarnessSkillsDir[$t]
    Write-Host "`nInstalando no harness [$t] em: $destDir" -ForegroundColor Cyan
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    foreach ($skill in $SkillsToInstall) {
        $destSkillDir = Join-Path $destDir $skill.Name
        if (Test-Path $destSkillDir) {
            Remove-Item -Path $destSkillDir -Recurse -Force
        }
        Copy-Item -Path $skill.FullName -Destination $destSkillDir -Recurse -Force
        Write-Host "  [+] Instalada: $($skill.Name)" -ForegroundColor Green
    }
}

Write-Host "`n=====================================================" -ForegroundColor Green
Write-Host "   Instalacao concluida com sucesso!                " -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Dica: Para instalar as dependencias Python necessarias, execute:"
Write-Host "  pip install -r '$RepoRoot\requirements.txt'" -ForegroundColor Yellow
