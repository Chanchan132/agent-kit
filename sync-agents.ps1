<#
.SYNOPSIS
    One-click Agent Kit synchronizer for Antigravity (~/.gemini), Codex (~/.codex), Claude Code (~/.claude), and Project workspaces.

.DESCRIPTION
    Synchronizes global engineering habits (AGENTS.md / GEMINI.md / CLAUDE.md), 33 skills (10 standalone + 23 plugin skills),
    plugins, and MCP configurations from this single-source-of-truth repository into your local agent environments or a target project workspace.

.PARAMETER Mode
    'Copy' (default, safe standalone copies) or 'Junction' (Windows directory junctions pointing to agent-kit).

.PARAMETER Project
    Optional path to a project workspace to initialize with AGENTS.md, GEMINI.md, and .agents/skills.

.PARAMETER IncludeClaude
    Force creation/sync of ~/.claude even if Claude Code is not yet installed.
#>
param(
    [ValidateSet("Copy", "Junction")]
    [string]$Mode = "Copy",

    [string]$Project = "",

    [switch]$IncludeClaude
)

$ErrorActionPreference = "Stop"
$KitRoot = $PSScriptRoot
$SkillsSource = Join-Path $KitRoot "skills"
$PluginsSource = Join-Path $KitRoot "plugins"
$GlobalRuleSource = Join-Path $KitRoot "rules\AGENTS.global.md"
$ProjectRuleTemplate = Join-Path $KitRoot "rules\AGENTS.project-template.md"
$GeminiProjectTemplate = Join-Path $KitRoot "rules\GEMINI.project-template.md"

function Sync-DirectoryItems {
    param(
        [string]$SourceDir,
        [string]$TargetRoot,
        [string]$SyncMode
    )
    if (-not (Test-Path $SourceDir)) { return 0 }
    if (-not (Test-Path $TargetRoot)) {
        New-Item -ItemType Directory -Path $TargetRoot -Force | Out-Null
    }

    $dirs = Get-ChildItem -Path $SourceDir -Directory
    foreach ($d in $dirs) {
        $dest = Join-Path $TargetRoot $d.Name
        if ($SyncMode -eq "Junction") {
            if (Test-Path $dest) {
                $item = Get-Item $dest -Force
                if ($item.LinkType -eq "Junction") {
                    cmd /c rmdir "$dest" | Out-Null
                } else {
                    Remove-Item -Path $dest -Recurse -Force
                }
            }
            New-Item -ItemType Junction -Path $dest -Target $d.FullName | Out-Null
        } else {
            if (Test-Path $dest) {
                $item = Get-Item $dest -Force
                if ($item.LinkType -eq "Junction") {
                    cmd /c rmdir "$dest" | Out-Null
                }
            }
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
            Copy-Item -Path (Join-Path $d.FullName "*") -Destination $dest -Recurse -Force
            Get-ChildItem -Path $dest -Directory -Recurse -Filter "__pycache__" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
        }
    }
    return $dirs.Count
}

function Sync-AllFlattenedSkills {
    param(
        [string]$TargetRoot,
        [string]$SyncMode
    )
    $count = Sync-DirectoryItems -SourceDir $SkillsSource -TargetRoot $TargetRoot -SyncMode $SyncMode
    if (Test-Path $PluginsSource) {
        foreach ($plugin in (Get-ChildItem -Path $PluginsSource -Directory)) {
            $pluginSkills = Join-Path $plugin.FullName "skills"
            if (Test-Path $pluginSkills) {
                $count += Sync-DirectoryItems -SourceDir $pluginSkills -TargetRoot $TargetRoot -SyncMode $SyncMode
            }
        }
    }
    return $count
}

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  Agent Kit Synchronizer ($Mode Mode)" -ForegroundColor Cyan
Write-Host "  Source: $KitRoot" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

# 1. Project Scaffolding Mode (if -Project is specified)
if ($Project -ne "") {
    $ProjectPath = Resolve-Path $Project -ErrorAction SilentlyContinue
    if (-not $ProjectPath) {
        New-Item -ItemType Directory -Path $Project -Force | Out-Null
        $ProjectPath = Resolve-Path $Project
    }
    $ProjectRoot = $ProjectPath.Path
    Write-Host "`n[Project] Initializing agent harness in: $ProjectRoot" -ForegroundColor Green

    $projAgentsMd = Join-Path $ProjectRoot "AGENTS.md"
    if (-not (Test-Path $projAgentsMd)) {
        Copy-Item -Path $ProjectRuleTemplate -Destination $projAgentsMd
        Write-Host "  + Created AGENTS.md (from template)"
    } else {
        Write-Host "  = Skipped AGENTS.md (already exists)"
    }

    $projGeminiMd = Join-Path $ProjectRoot "GEMINI.md"
    if (-not (Test-Path $projGeminiMd)) {
        Copy-Item -Path $GeminiProjectTemplate -Destination $projGeminiMd
        Write-Host "  + Created GEMINI.md (from template)"
    } else {
        Write-Host "  = Skipped GEMINI.md (already exists)"
    }

    $projSkillsDir = Join-Path $ProjectRoot ".agents\skills"
    $total = Sync-AllFlattenedSkills -TargetRoot $projSkillsDir -SyncMode $Mode
    Write-Host "  + Synced $total skills to .agents\skills ($Mode)"
    Write-Host "`nDone! Project workspace is ready." -ForegroundColor Green
    exit 0
}

# 2. Sync to Antigravity (~/.gemini)
# Note: Antigravity loads plugins natively from ~/.gemini/config/plugins, so we keep standalone skills in skills/ and plugin bundles in plugins/ to avoid duplicate skill collisions.
$GeminiRoot = Join-Path $env:USERPROFILE ".gemini"
$GeminiConfig = Join-Path $GeminiRoot "config"
Write-Host "`n[1/3] Syncing to Google Antigravity ($GeminiConfig)..." -ForegroundColor Green

New-Item -ItemType Directory -Path (Join-Path $GeminiConfig "rules") -Force | Out-Null
Copy-Item -Path $GlobalRuleSource -Destination (Join-Path $GeminiConfig "rules\AGENTS.md") -Force
Copy-Item -Path $GlobalRuleSource -Destination (Join-Path $GeminiRoot "GEMINI.md") -Force
Write-Host "  + Updated global rules (rules\AGENTS.md & ~/.gemini/GEMINI.md)"

$standaloneCount = Sync-DirectoryItems -SourceDir $SkillsSource -TargetRoot (Join-Path $GeminiConfig "skills") -SyncMode $Mode
Write-Host "  + Synced $standaloneCount standalone skills to ~/.gemini/config/skills"

$pluginCount = Sync-DirectoryItems -SourceDir $PluginsSource -TargetRoot (Join-Path $GeminiConfig "plugins") -SyncMode "Copy"
Write-Host "  + Synced $pluginCount plugins (23 bundled skills + rules + MCP) to ~/.gemini/config/plugins"

$GeminiMcpPath = Join-Path $GeminiConfig "mcp_config.json"
if (-not (Test-Path $GeminiMcpPath)) {
    Copy-Item -Path (Join-Path $KitRoot "mcp\mcp_config.common.json") -Destination $GeminiMcpPath
    Write-Host "  + Created ~/.gemini/config/mcp_config.json with codegraph MCP"
}

# 3. Sync to OpenAI Codex (~/.codex)
# Codex reads flat ~/.codex/skills/<name>/SKILL.md, so we flatten both standalone skills + plugin skills into ~/.codex/skills.
$CodexRoot = Join-Path $env:USERPROFILE ".codex"
Write-Host "`n[2/3] Syncing to OpenAI Codex ($CodexRoot)..." -ForegroundColor Green

New-Item -ItemType Directory -Path $CodexRoot -Force | Out-Null
Copy-Item -Path $GlobalRuleSource -Destination (Join-Path $CodexRoot "AGENTS.md") -Force
Write-Host "  + Updated global rule (~/.codex/AGENTS.md)"

$codexCount = Sync-AllFlattenedSkills -TargetRoot (Join-Path $CodexRoot "skills") -SyncMode $Mode
Write-Host "  + Synced $codexCount total skills (standalone + plugin skills) to ~/.codex/skills"

$CodexConfigPath = Join-Path $CodexRoot "config.toml"
if (Test-Path $CodexConfigPath) {
    $tomlContent = Get-Content -Path $CodexConfigPath -Raw
    if ($tomlContent -notmatch "\[mcp_servers\.codegraph\]") {
        $codegraphToml = @"

[mcp_servers.codegraph]
command = "codegraph"
args = ["serve", "--mcp"]
"@
        Add-Content -Path $CodexConfigPath -Value $codegraphToml
        Write-Host "  + Added [mcp_servers.codegraph] to ~/.codex/config.toml"
    } else {
        Write-Host "  = [mcp_servers.codegraph] already present in ~/.codex/config.toml"
    }
}

# 4. Sync to Claude Code (~/.claude) if present or requested
$ClaudeRoot = Join-Path $env:USERPROFILE ".claude"
if ((Test-Path $ClaudeRoot) -or $IncludeClaude) {
    Write-Host "`n[3/3] Syncing to Claude Code ($ClaudeRoot)..." -ForegroundColor Green
    New-Item -ItemType Directory -Path $ClaudeRoot -Force | Out-Null
    Copy-Item -Path $GlobalRuleSource -Destination (Join-Path $ClaudeRoot "CLAUDE.md") -Force
    $claudeCount = Sync-AllFlattenedSkills -TargetRoot (Join-Path $ClaudeRoot "skills") -SyncMode $Mode
    Write-Host "  + Updated ~/.claude/CLAUDE.md and synced $claudeCount skills to ~/.claude/skills"
} else {
    Write-Host "`n[3/3] Claude Code (~/.claude) not detected (use -IncludeClaude to pre-populate)." -ForegroundColor DarkGray
}

Write-Host "`nAll agent environments are now synchronized!" -ForegroundColor Cyan
