[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$sourcePath = Join-Path $repoRoot 'plugins\feature-skills\shared\low-cost-execution-agent.md'
$targetSkills = @(
    'feature-lifecycle',
    'feature-spec',
    'feature-dev',
    'feature-review'
)
$header = '<!-- Generated from plugins/feature-skills/shared/low-cost-execution-agent.md. Do not edit this copy directly. -->'

if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
    throw "Missing protocol SSOT: $sourcePath"
}

$sourceContent = (Get-Content -LiteralPath $sourcePath -Raw).Replace("`r`n", "`n").TrimEnd() + "`n"
$generatedContent = $header + "`n`n" + $sourceContent
$utf8WithoutBom = [System.Text.UTF8Encoding]::new($false)

foreach ($skillName in $targetSkills) {
    $targetPath = Join-Path $repoRoot "plugins\feature-skills\skills\$skillName\references\low-cost-execution-agent.md"
    $targetDirectory = Split-Path -Parent $targetPath
    if (-not (Test-Path -LiteralPath $targetDirectory -PathType Container)) {
        throw "Missing skill references directory: $targetDirectory"
    }
    [System.IO.File]::WriteAllText($targetPath, $generatedContent, $utf8WithoutBom)
    Write-Output "Synchronized $targetPath"
}
