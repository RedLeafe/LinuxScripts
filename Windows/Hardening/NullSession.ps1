$Error.Clear()
$ErrorActionPreference = "SilentlyContinue"

Write-Output "`n############Null Sessions############`n"

reg add HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters /v RestrictNullSessAccess /t REG_DWORD /d 1 /f | Out-Null

$Shares = @(Get-WmiObject -Query "SELECT * FROM Win32_Share" | Select-Object -ExpandProperty Name | Where-Object { $_ -ne "ADMIN$" -and $_ -ne "C$" -and $_ -ne "IPC$" })
$NullShares = @()
foreach ($Share in $Shares) {
    $NullShares += $Share + "\0"
}

# For some reason this hangs if shares is empty
if ($Shares.Count -gt 0) {
reg add HKLM\System\CurrentControlSet\Services\LanmanServer\Parameters /v NullSessionShares /t REG_MULTI_SZ /d "$NullShares" /f | Out-Null
}

reg add HKLM\System\CurrentControlSet\Services\LanmanServer\Parameters /v NullSessionPipes /t REG_MULTI_SZ /d "MS-IPAMM2\0MS-NCNBI\0MS-WSUSAR\0BITS-samr\0" /f | Out-Null
Write-Output "$Env:ComputerName [INFO] Configured Shares"

if ($Error[0]) {
    Write-Output "`n#########################"
    Write-Output "#        ERRORS         #"
    Write-Output "#########################`n"


    foreach ($err in $error) {
        Write-Output $err
    }
}