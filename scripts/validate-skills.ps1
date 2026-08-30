[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$marketplacePath = Join-Path $repoRoot '.agents\plugins\marketplace.json'
$errors = [System.Collections.Generic.List[string]]::new()
$skillNames = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)

function Add-ValidationError {
    param([Parameter(Mandatory)][string] $Message)
    $script:errors.Add($Message)
}

function Read-JsonObject {
    param([Parameter(Mandatory)][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Add-ValidationError "Missing JSON file: $Path"
        return $null
    }

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        Add-ValidationError "Invalid JSON in ${Path}: $($_.Exception.Message)"
        return $null
    }
}

function Get-RequiredString {
    param(
        [Parameter(Mandatory)] $Object,
        [Parameter(Mandatory)][string] $Property,
        [Parameter(Mandatory)][string] $Context
    )

    $member = $Object.PSObject.Properties[$Property]
    if ($null -eq $member -or $member.Value -isnot [string] -or [string]::IsNullOrWhiteSpace($member.Value)) {
        Add-ValidationError "$Context requires a non-empty '$Property' string."
        return $null
    }
    return $member.Value
}

function Resolve-ContainedPath {
    param(
        [Parameter(Mandatory)][string] $BasePath,
        [Parameter(Mandatory)][string] $RelativePath,
        [Parameter(Mandatory)][string] $Context
    )

    if (-not $RelativePath.StartsWith('./', [System.StringComparison]::Ordinal)) {
        Add-ValidationError "$Context must start with './': $RelativePath"
        return $null
    }

    $candidate = [System.IO.Path]::GetFullPath(
        (Join-Path $BasePath $RelativePath.Substring(2))
    )
    $basePrefix = [System.IO.Path]::GetFullPath($BasePath).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar

    if (-not $candidate.StartsWith($basePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        Add-ValidationError "$Context escapes its root: $RelativePath"
        return $null
    }
    return $candidate
}

function Get-FrontmatterScalar {
    param(
        [Parameter(Mandatory)][string] $Frontmatter,
        [Parameter(Mandatory)][string] $Key
    )

    $escapedKey = [Regex]::Escape($Key)
    $match = [Regex]::Match(
        $Frontmatter,
        "(?m)^\s*$escapedKey\s*:\s*(?<value>.+?)\s*$"
    )
    if (-not $match.Success) {
        return $null
    }

    $value = $match.Groups['value'].Value.Trim()
    if ($value -in @('|', '>')) {
        return $null
    }
    if ($value.Length -ge 2) {
        $first = $value[0]
        $last = $value[$value.Length - 1]
        if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
            $value = $value.Substring(1, $value.Length - 2).Trim()
        }
    }
    return $value
}

function Test-SkillDirectory {
    param([Parameter(Mandatory)][System.IO.DirectoryInfo] $Directory)

    $skillFile = Join-Path $Directory.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
        Add-ValidationError "Skill directory is missing SKILL.md: $($Directory.FullName)"
        return
    }

    $content = Get-Content -LiteralPath $skillFile -Raw
    $frontmatterMatch = [Regex]::Match(
        $content,
        '\A---\r?\n(?<frontmatter>.*?)\r?\n---(?:\r?\n|\z)',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    if (-not $frontmatterMatch.Success) {
        Add-ValidationError "SKILL.md requires YAML frontmatter: $skillFile"
        return
    }

    $frontmatter = $frontmatterMatch.Groups['frontmatter'].Value
    $name = Get-FrontmatterScalar -Frontmatter $frontmatter -Key 'name'
    $description = Get-FrontmatterScalar -Frontmatter $frontmatter -Key 'description'

    if ([string]::IsNullOrWhiteSpace($name)) {
        Add-ValidationError "SKILL.md requires a scalar 'name': $skillFile"
    }
    else {
        if ($name -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$' -or $name.Length -gt 64) {
            Add-ValidationError "Invalid skill name '$name' in $skillFile"
        }
        if ($name -cne $Directory.Name) {
            Add-ValidationError "Skill name '$name' must match directory '$($Directory.Name)'."
        }
        if (-not $script:skillNames.Add($name)) {
            Add-ValidationError "Duplicate skill name: $name"
        }
    }

    if ([string]::IsNullOrWhiteSpace($description)) {
        Add-ValidationError "SKILL.md requires a scalar 'description': $skillFile"
    }
    if ($content.Contains('[TODO:', [System.StringComparison]::OrdinalIgnoreCase)) {
        Add-ValidationError "Unfinished scaffold placeholder in $skillFile"
    }
}

$marketplace = Read-JsonObject -Path $marketplacePath
if ($null -ne $marketplace) {
    $marketplaceName = Get-RequiredString -Object $marketplace -Property 'name' -Context 'Marketplace'
    if ($null -ne $marketplaceName -and $marketplaceName -notmatch '^[A-Za-z0-9_-]+$') {
        Add-ValidationError "Invalid marketplace name: $marketplaceName"
    }

    $pluginsMember = $marketplace.PSObject.Properties['plugins']
    if ($null -eq $pluginsMember -or $pluginsMember.Value -isnot [Array] -or $pluginsMember.Value.Count -eq 0) {
        Add-ValidationError 'Marketplace requires a non-empty plugins array.'
    }
    else {
        $pluginNames = [System.Collections.Generic.HashSet[string]]::new(
            [System.StringComparer]::OrdinalIgnoreCase
        )
        foreach ($entry in $pluginsMember.Value) {
            $entryName = Get-RequiredString -Object $entry -Property 'name' -Context 'Marketplace plugin entry'
            if ($null -eq $entryName) {
                continue
            }
            if ($entryName -notmatch '^[A-Za-z0-9_-]+(?:\.[A-Za-z0-9_-]+)*$') {
                Add-ValidationError "Invalid plugin name: $entryName"
            }
            if (-not $pluginNames.Add($entryName)) {
                Add-ValidationError "Duplicate marketplace plugin: $entryName"
            }

            if ($null -eq $entry.source -or $entry.source.source -ne 'local') {
                Add-ValidationError "Plugin '$entryName' must use a local marketplace source."
                continue
            }
            $sourcePath = Get-RequiredString -Object $entry.source -Property 'path' -Context "Plugin '$entryName' source"
            if ($null -eq $sourcePath) {
                continue
            }
            $expectedSourcePath = "./plugins/$entryName"
            if ($sourcePath.Replace('\', '/') -cne $expectedSourcePath) {
                Add-ValidationError "Plugin '$entryName' source must be '$expectedSourcePath'."
            }

            if ($null -eq $entry.policy -or $entry.policy.installation -notin @('NOT_AVAILABLE', 'AVAILABLE', 'INSTALLED_BY_DEFAULT')) {
                Add-ValidationError "Plugin '$entryName' has an invalid installation policy."
            }
            if ($null -eq $entry.policy -or $entry.policy.authentication -notin @('ON_INSTALL', 'ON_USE')) {
                Add-ValidationError "Plugin '$entryName' has an invalid authentication policy."
            }
            if ([string]::IsNullOrWhiteSpace([string] $entry.category)) {
                Add-ValidationError "Plugin '$entryName' requires a category."
            }

            $pluginRoot = Resolve-ContainedPath -BasePath $repoRoot -RelativePath $sourcePath -Context "Plugin '$entryName' source"
            if ($null -eq $pluginRoot -or -not (Test-Path -LiteralPath $pluginRoot -PathType Container)) {
                Add-ValidationError "Plugin directory does not exist: $pluginRoot"
                continue
            }

            $manifestPath = Join-Path $pluginRoot '.codex-plugin\plugin.json'
            $manifest = Read-JsonObject -Path $manifestPath
            if ($null -eq $manifest) {
                continue
            }

            $manifestName = Get-RequiredString -Object $manifest -Property 'name' -Context $manifestPath
            $version = Get-RequiredString -Object $manifest -Property 'version' -Context $manifestPath
            [void] (Get-RequiredString -Object $manifest -Property 'description' -Context $manifestPath)
            if ($manifestName -cne $entryName) {
                Add-ValidationError "Manifest name '$manifestName' must match marketplace entry '$entryName'."
            }
            $semverPattern = '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[A-Za-z-][0-9A-Za-z-]*)(?:\.(?:0|[1-9]\d*|\d*[A-Za-z-][0-9A-Za-z-]*))*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$'
            if ($null -ne $version -and $version -notmatch $semverPattern) {
                Add-ValidationError "Plugin '$entryName' has invalid semantic version '$version'."
            }
            if ($null -eq $manifest.author -or [string]::IsNullOrWhiteSpace([string] $manifest.author.name)) {
                Add-ValidationError "Plugin '$entryName' requires author.name."
            }

            $skillsPathValue = Get-RequiredString -Object $manifest -Property 'skills' -Context $manifestPath
            if ($null -eq $skillsPathValue) {
                continue
            }
            $skillsRoot = Resolve-ContainedPath -BasePath $pluginRoot -RelativePath $skillsPathValue -Context "Plugin '$entryName' skills"
            if ($null -eq $skillsRoot -or -not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
                Add-ValidationError "Skills directory does not exist: $skillsRoot"
                continue
            }

            Get-ChildItem -LiteralPath $skillsRoot -Directory | ForEach-Object {
                Test-SkillDirectory -Directory $_
            }

            $manifestText = Get-Content -LiteralPath $manifestPath -Raw
            if ($manifestText.Contains('[TODO:', [System.StringComparison]::OrdinalIgnoreCase)) {
                Add-ValidationError "Unfinished scaffold placeholder in $manifestPath"
            }
        }
    }
}

$lowCostProtocolSource = Join-Path $repoRoot 'plugins\feature-skills\shared\low-cost-execution-agent.md'
$lowCostProtocolTargets = @(
    'feature-lifecycle',
    'feature-spec',
    'feature-dev',
    'feature-review'
)
$generatedProtocolHeader = '<!-- Generated from plugins/feature-skills/shared/low-cost-execution-agent.md. Do not edit this copy directly. -->'

if (-not (Test-Path -LiteralPath $lowCostProtocolSource -PathType Leaf)) {
    Add-ValidationError "Missing low-cost execution protocol SSOT: $lowCostProtocolSource"
}
else {
    $sourceContent = (Get-Content -LiteralPath $lowCostProtocolSource -Raw).Replace("`r`n", "`n").TrimEnd() + "`n"
    $expectedGeneratedContent = $generatedProtocolHeader + "`n`n" + $sourceContent

    foreach ($skillName in $lowCostProtocolTargets) {
        $skillRoot = Join-Path $repoRoot "plugins\feature-skills\skills\$skillName"
        $generatedPath = Join-Path $skillRoot 'references\low-cost-execution-agent.md'
        if (-not (Test-Path -LiteralPath $generatedPath -PathType Leaf)) {
            Add-ValidationError "Skill '$skillName' is missing its generated low-cost execution protocol: $generatedPath"
            continue
        }

        $actualGeneratedContent = (Get-Content -LiteralPath $generatedPath -Raw).Replace("`r`n", "`n")
        if ($actualGeneratedContent -cne $expectedGeneratedContent) {
            Add-ValidationError "Skill '$skillName' low-cost execution protocol is out of sync with the SSOT."
        }

        $skillFile = Join-Path $skillRoot 'SKILL.md'
        $skillContent = Get-Content -LiteralPath $skillFile -Raw
        if (-not $skillContent.Contains('(references/low-cost-execution-agent.md)', [System.StringComparison]::Ordinal)) {
            Add-ValidationError "Skill '$skillName' must route its first low-cost delegation to references/low-cost-execution-agent.md."
        }
    }
}

if ($errors.Count -gt 0) {
    Write-Error ("Validation failed:`n- " + ($errors -join "`n- "))
    exit 1
}

Write-Output "Validated marketplace, plugins, and $($skillNames.Count) skill(s)."
