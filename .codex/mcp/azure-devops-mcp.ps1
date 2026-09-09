Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Find-CodexNode {
  $binRoot = Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\bin'
  if (-not (Test-Path -LiteralPath $binRoot)) {
    throw "Codex runtime directory was not found at '$binRoot'."
  }

  $node = Get-ChildItem -LiteralPath $binRoot -Recurse -Filter node.exe -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1 -ExpandProperty FullName

  if (-not $node) {
    throw 'Could not locate the bundled Codex node.exe runtime.'
  }

  return $node
}

$defaultOrg = 'AR-corp'
$defaultProject = 'SheDrive'
$org = $env:AZURE_DEVOPS_ORG
if ([string]::IsNullOrWhiteSpace($org)) {
  $org = $defaultOrg
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$entry = Join-Path $scriptRoot 'vendor\azure-devops-mcp\node_modules\@azure-devops\mcp\dist\index.js'
if (-not (Test-Path -LiteralPath $entry)) {
  throw "Azure DevOps MCP package entrypoint was not found at '$entry'."
}

if ($env:AZURE_DEVOPS_PROJECT) {
  $env:ado_mcp_project = $env:AZURE_DEVOPS_PROJECT
} else {
  $env:ado_mcp_project = $defaultProject
}

if ($env:AZURE_DEVOPS_TEAM) {
  $env:ado_mcp_team = $env:AZURE_DEVOPS_TEAM
}

$node = Find-CodexNode
$launchArgs = @(
  $entry,
  $org,
  '-d', 'core',
  '-d', 'work',
  '-d', 'work-items'
)

# Prefer PAT auth when a credential file is present. The server's default
# authenticator calls MSAL acquireTokenInteractive, which hands the sign-in URL to
# the system default browser -- on a machine with multiple Chrome profiles that
# lands in the wrong profile and fails with AADSTS70007.
# The file holds base64(":<pat>"); dist/index.js decodes it and strips the part
# before the first colon.
$patFile = Join-Path $env:USERPROFILE '.ado-mcp-pat'
if ([string]::IsNullOrWhiteSpace($env:PERSONAL_ACCESS_TOKEN) -and (Test-Path -LiteralPath $patFile)) {
  $env:PERSONAL_ACCESS_TOKEN = (Get-Content -LiteralPath $patFile -Raw).Trim()
}

$auth = $env:AZURE_DEVOPS_MCP_AUTH
if ([string]::IsNullOrWhiteSpace($auth) -and -not [string]::IsNullOrWhiteSpace($env:PERSONAL_ACCESS_TOKEN)) {
  $auth = 'pat'
}
if (-not [string]::IsNullOrWhiteSpace($auth)) {
  $launchArgs += @('--authentication', $auth)
}

if ($args.Count -gt 0) {
  $launchArgs += $args
}

& $node @launchArgs
