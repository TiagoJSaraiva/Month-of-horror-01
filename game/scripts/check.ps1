<#
.SYNOPSIS
  Pipeline de verificação: versão do Godot, formatação, lint, parse e testes.
  Para na primeira etapa que falhar e retorna exit code 1.

.PARAMETER Fast
  Roda só os testes unitários (test/unit), pulando os testes de cena.

.PARAMETER Fix
  Aplica gdformat nos scripts do projeto antes de verificar.

.EXAMPLE
  .\scripts\check.ps1              # completo: antes de concluir uma tarefa
  .\scripts\check.ps1 -Fix -Fast   # formata e roda o check rápido
#>
param([switch]$Fast, [switch]$Fix)

$ErrorActionPreference = "Continue"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $root

function Invoke-Step([string]$Name, [scriptblock]$Action) {
    Write-Host "`n== $Name ==" -ForegroundColor Cyan
    $global:LASTEXITCODE = 0
    & $Action
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FALHOU: $Name" -ForegroundColor Red
        exit 1
    }
    Write-Host "OK: $Name" -ForegroundColor Green
}

# Scripts do projeto, sem addons de terceiros e sem o cache do Godot
$gdFiles = @(Get-ChildItem -Path $root -Recurse -Filter *.gd |
    Where-Object { $_.FullName -notmatch '\\(addons|\.godot)\\' } |
    ForEach-Object { $_.FullName })

# 1. Versão do Godot (também valida o GODOT_PATH)
Invoke-Step "Versão do Godot" {
    & (Join-Path $PSScriptRoot "check-godot-version.ps1")
}

# 2. gdtoolkit instalado. Sem esta etapa, um gdformat ou gdlint ausente passaria como OK:
#    o PowerShell não altera o $LASTEXITCODE quando o comando não existe.
Invoke-Step "gdtoolkit (gdformat e gdlint)" {
    foreach ($tool in @("gdformat", "gdlint")) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            Write-Host "$tool não encontrado. Instale o gdtoolkit (pip install `"gdtoolkit==4.*`") e confira se a pasta Scripts do Python está no PATH." -ForegroundColor Yellow
            $global:LASTEXITCODE = 1
        }
    }
}

# 3. Formatação e 4. lint (gdtoolkit)
if ($gdFiles.Count -gt 0) {
    if ($Fix) {
        Invoke-Step "Aplicar formatação (gdformat)" { gdformat $gdFiles }
    }
    Invoke-Step "Formatação (gdformat --check)" { gdformat --check $gdFiles }
    Invoke-Step "Lint (gdlint)" { gdlint $gdFiles }
} else {
    Write-Host "`n(sem scripts .gd do projeto: formatação e lint pulados)" -ForegroundColor DarkGray
}

# 5. Parse de todos os scripts: importa o projeto em modo headless e procura erros na saída.
#    O Godot nem sempre retorna exit code != 0 com erro de script, por isso a busca no texto.
#    Não amplie o regex para "ERROR" genérico: há ruído conhecido (Remote Debugger).
Invoke-Step "Parse dos scripts (Godot headless)" {
    $output = & $env:GODOT_PATH --headless --path $root --import 2>&1 | Out-String
    if ([string]::IsNullOrWhiteSpace($output)) {
        Write-Host "Saída vazia: o Godot não devolveu nada ao terminal." -ForegroundColor Yellow
        $global:LASTEXITCODE = 1
    } elseif ($output -match 'SCRIPT ERROR|Parse Error|Failed to load script') {
        Write-Host $output
        $global:LASTEXITCODE = 1
    } else {
        $global:LASTEXITCODE = 0
    }
}

# 6. Testes (gdUnit4). O runtest.cmd lê o executável do Godot em GODOT_BIN.
$testDir = if ($Fast) { "test/unit" } else { "test" }
if (Test-Path (Join-Path $root $testDir)) {
    Invoke-Step "Testes gdUnit4 ($testDir)" {
        $env:GODOT_BIN = $env:GODOT_PATH
        & (Join-Path $root "addons\gdUnit4\runtest.cmd") -a "res://$testDir"
    }
} else {
    Write-Host "`nFALHOU: pasta $testDir não existe" -ForegroundColor Red
    exit 1
}

Write-Host "`nCHECK OK" -ForegroundColor Green
exit 0
