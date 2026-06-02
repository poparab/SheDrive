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

function Ensure-NpmCli {
  param(
    [Parameter(Mandatory = $true)]
    [string]$VendorRoot
  )

  $npmRoot = Join-Path $VendorRoot 'npm'
  $npmCli = Join-Path $npmRoot 'package\bin\npm-cli.js'
  if (Test-Path -LiteralPath $npmCli) {
    return $npmCli
  }

  $npmInfo = Invoke-RestMethod -Uri 'https://registry.npmjs.org/npm/latest'
  $tarballPath = Join-Path $VendorRoot ("npm-{0}.tgz" -f $npmInfo.version)

  if (Test-Path -LiteralPath $npmRoot) {
    Remove-Item -LiteralPath $npmRoot -Recurse -Force
  }

  New-Item -ItemType Directory -Path $npmRoot -Force | Out-Null
  Invoke-WebRequest -Uri $npmInfo.dist.tarball -OutFile $tarballPath
  tar -xf $tarballPath -C $npmRoot
  Remove-Item -LiteralPath $tarballPath -Force

  if (-not (Test-Path -LiteralPath $npmCli)) {
    throw "Failed to prepare npm CLI at '$npmCli'."
  }

  return $npmCli
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$vendorRoot = Join-Path $scriptRoot 'vendor'
$adoRoot = Join-Path $vendorRoot 'azure-devops-mcp'
$wrapperPath = Join-Path $scriptRoot 'azure-devops-mcp.ps1'
$configPath = Join-Path $env:USERPROFILE '.codex\config.toml'

New-Item -ItemType Directory -Path $vendorRoot -Force | Out-Null
New-Item -ItemType Directory -Path $adoRoot -Force | Out-Null

$node = Find-CodexNode
$npmCli = Ensure-NpmCli -VendorRoot $vendorRoot

& $node $npmCli install --ignore-scripts --no-save --prefix $adoRoot --registry 'https://registry.npmjs.org/' '@azure-devops/mcp'
if ($LASTEXITCODE -ne 0) {
  throw "npm install failed with exit code $LASTEXITCODE."
}

$escapedWrapperPath = $wrapperPath.Replace('\', '\\')
$configBlock = @"
[mcp_servers.azure-devops-backlog]
command = "powershell.exe"
args = ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "$escapedWrapperPath"]
startup_timeout_sec = 120
"@

$configText = if (Test-Path -LiteralPath $configPath) {
  Get-Content -LiteralPath $configPath -Raw
} else {
  ''
}

if ($configText -notmatch '(?m)^\[mcp_servers\.azure-devops-backlog\]\s*$') {
  if ($configText.Length -gt 0 -and -not $configText.EndsWith("`r`n")) {
    $configText += "`r`n"
  }

  $configText += "`r`n$configBlock`r`n"
  Set-Content -LiteralPath $configPath -Value $configText -NoNewline
}
