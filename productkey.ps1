function DecodeProdKey {
    Param(
        [parameter(Mandatory=$true)]
        [Byte[]] 
        $ProdID
    )
    # Key starts at 0x34 (52) and ends a 0x42 (66)
    Set-Variable KeyOffset -Option Constant -value 52 # Decimal of 34 Hex Offset
    Set-Variable KeyLength -Option Constant -value 14 # KeyOffset + Keylength = 66 or 0x42
    Set-Variable Chars -Option Constant -Value ("BCDFGHJKMPQRTVWXY2346789" -split '')
    # The following magic is adapted from Ed Scherer's work http://www.ed.scherer.name/Tools/MicrosoftDigitalProductIDDecoder.html
    For ($i=28; $i -ge 0; $i--) {
        $cur = 0
        For ($x=$KeyLength; $x -ge 0; $x--){
            $cur = $cur -shl 8  
            $cur = $cur -bxor $ProdID[$x + $KeyOffset] 
            $ProdId[$x + $KeyOffset] = [math]::Floor($cur / 24)
            $cur = $cur % 24    
        }
        $cur++
        $KeyOutput = $Chars[$cur] + $KeyOutput
   
        If ((( $i % 6) -eq 0) -and (($i-1) -ne -1)) {
            $i--
            $KeyOutput = "-" + $KeyOutput
        }
    }
    return $KeyOutput
}

#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\Current Version
$WinDigitalProductID = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "DigitalProductId").DigitalProductId
#$WinDigitalProductID | Format-Hex
$WinProdKey = DecodeProdKey($WinDigitalProductID)

#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Registration
$IEDigitalProductID = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Registration" -Name "DigitalProductId").DigitalProductId
#$IEDigitalProductID | Format-Hex
$IEProdKey = DecodeProdKey($IEDigitalProductID)
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup($WinProdKey + "`n" + $IEProdKey,0,"Windows Product Key (Ctrl-c to Copy)",0x1)
