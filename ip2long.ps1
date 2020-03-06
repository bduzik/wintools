
function cidr2ip {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $cidrblock
    )
    ($ip, $prefix) = [string[]]$cidrblock.split('/')
    $prefix = [int16]$prefix
    if (($prefix -lt 1) -or ($prefix -gt 32)) {
        Write-Error -Message "Prefix is out of bounds 1-32"
    }
    return ($ip,$prefix)
}
function ip2long {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $cidrblock
    )

$ipbyte = [byte[]] $ip.Split('.')
$iplong = [long] 0
for ($i = 0; $i -lt $ipbyte.Count; $i++) {
    $iplong += [System.Math]::Pow(2, ($ipbyte.Count - ($i + 1)) * 8) * $ipbyte[$i]
}
return $iplong
}
function long2ip {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [long]
        $iplong
    )
    $ipconv = [int16[]] (0, 0, 0, 0)
    for ($i = 0; $i -lt 4; $i++) {
        $place = [long][System.Math]::Pow(2, (3 - $i) * 8)
        $ipconv[$i] = [int16][System.Math]::Floor($iplong / $place)
        if(($ipconv[$i]) -gt 255 -or ($ipconv[$i] -lt 0)){
            $ipconv[$i]
            Write-Error -Message "Octet is out of range" + $ipconv[$i]
        }
        $iplong = $iplong % $place
    }
    return $ipconv
}

($ip,$prefix) = cidr2ip("192.168.1.0/24")
$longip = ip2long($ip)
$longip += 512
$ipAddr = long2ip($longip) 
$ipAddr = $ipAddr -join '.'
$ipAddr += '/' + $prefix
$ipAddr

#for ($i = 0; $i -lt $ipbyte.Count; $i++) {
#    $ipbyte[$i]
#}
#[System.Math]::Pow(2,32)
