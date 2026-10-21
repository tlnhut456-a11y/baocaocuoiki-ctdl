# Chay mot luot toan bo bai DT056.
# Dung: powershell -ExecutionPolicy Bypass -File .\chay.ps1

$ErrorActionPreference = "Stop"
$goc = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $goc

$julia = Get-Command julia -ErrorAction SilentlyContinue
if (-not $julia) {
    Write-Host "Khong tim thay julia trong PATH. Cai Julia 1.13.1 roi chay lai."
    exit 1
}

Write-Host "=== PHIEN BAN ==="
julia --version
Write-Host ""

Write-Host "=== VI DU 1 ==="
julia --startup-file=no main.jl vd1
Write-Host ""

Write-Host "=== VI DU 2 ==="
julia --startup-file=no main.jl vd2
Write-Host ""

Write-Host "=== NAM CA PHIEU ==="
julia --startup-file=no main.jl phieu
Write-Host ""

Write-Host "=== BO KIEM THU ==="
julia --startup-file=no test/kiem_thu.jl
Write-Host ""

Write-Host "=== KHAO SAT BA QUY MO ==="
julia --startup-file=no scripts/thong_ke.jl

Write-Host ""
Write-Host "XONG_TOAN_BO_DT056"
