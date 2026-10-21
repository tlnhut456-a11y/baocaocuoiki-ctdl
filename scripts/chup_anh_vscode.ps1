# Chup 9 anh minh chung A01-A09 trong cua so VS Code.
# Chay script nay TRONG terminal cua VS Code, tai thu muc goc cua bai:
#   powershell -ExecutionPolicy Bypass -File .\scripts\chup_anh_vscode.ps1
# Moi lenh chay xong thi chup lai cua so VS Code, luu thanh raw_A01.png ... raw_A09.png
# (anh goc ca cua so; phan cat ve vung terminal lam sau).

param(
    [string]$ThuMucAnh = ""
)

Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class VSChup {
    public delegate bool EnumProc(IntPtr h, IntPtr l);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr l);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
}
"@

$goc = Split-Path -Parent $PSScriptRoot
Set-Location $goc
if ([string]::IsNullOrWhiteSpace($ThuMucAnh)) {
    $ThuMucAnh = Join-Path $goc "docs\anh_ket_qua"
}
if (-not (Test-Path $ThuMucAnh)) {
    New-Item -ItemType Directory -Force -Path $ThuMucAnh | Out-Null
}

function Tim-CuaSoVSCode {
    $script:tot = [IntPtr]::Zero
    $script:dienTich = 0
    $cb = [VSChup+EnumProc]{
        param($h, $l)
        if ([VSChup]::IsWindowVisible($h)) {
            $sb = New-Object System.Text.StringBuilder 400
            [VSChup]::GetWindowText($h, $sb, 400) | Out-Null
            if ($sb.ToString() -like "*Visual Studio Code*") {
                $r = New-Object VSChup+RECT
                [VSChup]::GetWindowRect($h, [ref]$r) | Out-Null
                $s = ($r.Right - $r.Left) * ($r.Bottom - $r.Top)
                if ($s -gt $script:dienTich) {
                    $script:dienTich = $s
                    $script:tot = $h
                }
            }
        }
        return $true
    }
    [VSChup]::EnumWindows($cb, [IntPtr]::Zero) | Out-Null
    return $script:tot
}

function Chup($hwnd, $ten) {
    [VSChup]::SetForegroundWindow($hwnd) | Out-Null
    Start-Sleep -Milliseconds 400
    $r = New-Object VSChup+RECT
    [VSChup]::GetWindowRect($hwnd, [ref]$r) | Out-Null
    $w = $r.Right - $r.Left
    $h = $r.Bottom - $r.Top
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($r.Left, $r.Top, 0, 0, $bmp.Size)
    $dich = Join-Path $ThuMucAnh $ten
    $bmp.Save($dich, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host ("  -> da luu " + $ten + " (" + $w + "x" + $h + ")")
}

$cuaSo = Tim-CuaSoVSCode
if ($cuaSo -eq [IntPtr]::Zero) {
    Write-Host "Khong tim thay cua so VS Code. Hay chay script trong terminal cua VS Code."
    exit 1
}

$x30 = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCD"
$y30 = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCE"

$ca = @(
    @{ Lenh = "julia main.jl vd1"; Ten = "raw_A01.png" },
    @{ Lenh = "julia main.jl vd2"; Ten = "raw_A02.png" },
    @{ Lenh = "julia main.jl chay SUNDAY SATURDAY"; Ten = "raw_A03.png" },
    @{ Lenh = "julia main.jl chay kitten sitting"; Ten = "raw_A04.png" },
    @{ Lenh = "julia main.jl chay A B"; Ten = "raw_A05.png" },
    @{ Lenh = "julia main.jl chay AAAA AA"; Ten = "raw_A06.png" },
    @{ Lenh = "julia main.jl chay $x30 $y30"; Ten = "raw_A07.png" },
    @{ Lenh = "julia main.jl chay ABC A1"; Ten = "raw_A08.png" },
    @{ Lenh = "julia test/kiem_thu.jl"; Ten = "raw_A09.png" }
)

foreach ($m in $ca) {
    Clear-Host
    Write-Host ("PS " + $goc + "> ") -NoNewline
    Write-Host $m.Lenh
    Invoke-Expression $m.Lenh
    Start-Sleep -Milliseconds 800
    Chup $cuaSo $m.Ten
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "XONG: da chup 9 anh goc raw_A01..raw_A09 vao docs\anh_ket_qua"
