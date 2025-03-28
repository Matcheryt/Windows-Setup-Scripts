#######################################
# Windows Server Initial Setup Script #
#######################################

# ---------------- VARIABLES ---------------- #
#
# -------------- NETWORK --------------
#
$netInterfaceName = "Ethernet0"
# ------- IPV4
$enableIpv4 = $true
$netInterfaceIpv4 = ""
$netInterfaceGatewayv4 = ""
$netInterfaceNetMaskv4 = ""
$netInterfaceDnsv4 = ""
# ------- IPV6
$enableIpv6 = $false
$netInterfaceIpv6 = "" 
$netInterfaceGatewayv6 = ""
$netInterfaceDnsv6 = ""
#
# -------------- GENERAL --------------
#
$hostname = "TESTE"
$timezone = "GMT Standard Time" 
#
# -------------- DOMAIN ---------------
#
$domain = "ciseg.local.lan"
$domainAdminUser = "Administrator"
$joinToDomain = $false
#
# -------------- END VARIABLES -------------- #

# Keep track of steps failed during runtime
$failureCount = 0

#region DISCLAIMER
Write-Host @"

!!!!! WARNING !!!!!
This script changes system settings, and can potentially break things.
Ensure you have a snapshot/backup before running this.
"@ -ForegroundColor Black -BackgroundColor Yellow

do {
    $disclaimerInput = Read-Host "Do you want to continue? (Y/n)"
} until ($disclaimerInput.ToUpper() -in "Y", "N")

if ($disclaimerInput -eq "N") {
    Exit
}

cls
#endregion

#region USER_INPUTS
while ($True) {

    Write-Host @"

    ================= Windows Server Setup Script =================                     
                                                                          
       1.  Network Interface Name    $($netInterfaceName)                   
       2.  Enable IPv4?              $($enableIpv4)                         
       3.  IPv4                      $($netInterfaceIpv4)                   
       4.  IPv4 Gateway              $($netInterfaceGatewayv4)              
       5.  IPv4 Net Mask             $($netInterfaceNetMaskv4)              
       6.  IPV4 DNS Servers          $($netInterfaceDnsv4)                  
       7.  Enable IPv6?              $($enableIpv6)                         
       8.  IPv6                      $($netInterfaceIpv6)                   
       9.  IPv6 Gateway              $($netInterfaceGatewayv6)              
       10. IPv6 DNS Servers          $($netInterfaceDnsv6)                  
       11. Hostname                  $($hostname)                           
       12. Time Zone                 $($timezone)                           
       13. Domain                    $($domain)                             
       14. Domain Admin User         $($domainAdminUser)                    
       15. Join to Domain?           $($joinToDomain)                       

"@

$option = Read-Host "Select an option to change or type 'start' to run the script with the options above" 

if ($option.ToUpper() -eq "START"){
    
    # Verify everything is filled correctly before starting

    # IPv4
    if ($enableIpv4 -eq $true){
        if (($netInterfaceName -eq "") -or
            ($netInterfaceIpv4 -eq "") -or 
            ($netInterfaceGatewayv4 -eq "") -or
            ($netInterfaceNetMaskv4 -eq "") -or
            ($netInterfaceDnsv4 -eq "")){
                Write-Warning "IPv4 settings are missing. Script will not start."
                return
            }
    }

    # IPv6
    if ($enableIpv6 -eq $true){
        if (($netInterfaceName -eq "") -or
            ($netInterfaceIpv6 -eq "") -or 
            ($netInterfaceGatewayv6 -eq "") -or
            ($netInterfaceDnsv6 -eq "")){
                Write-Warning "IPv6 settings are missing. Script will not start."
                return
            }
    }

    # Domain
    if ($joinToDomain -eq $true){
        if (($domain -eq "") -or
            ($domainAdminUser -eq "") -or
            ($hostname -eq "")){
                Write-Warning "Domain settings are missing. Script will not start."
                return
            }
    }

    break
}

switch ($option){
    "1"     { 
        Write-Host "Available Network Interfaces:"
        (Get-NetAdapter | Select-Object Name, InterfaceDescription, Status) | Out-Host
        do {
            $netInterfaceName = Read-Host "New Network Interface Name"
            $netAdapter = Get-NetAdapter | ? {$_.Name -eq $netInterfaceName}
        } while ($netAdapter -eq $null)
    }
    "2"     { 
        $response = Read-Host "Enable IPv4? (Y/n)"
        if ($response.ToUpper() -eq "Y"){
            $enableIpv4 = $true
        } 
        elseif ($response.ToUpper() -eq "N") {
            $enableIpv4 = $false
        }
    }
    "3"     { 
        $pattern = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
        do {
            $netInterfaceIpv4 = Read-Host "New IPv4 Address"
        } while ($netInterfaceIpv4 -notmatch $pattern)  
    }
    "4"     { 
        $pattern = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
        do {
            $netInterfaceGatewayv4 = Read-Host "New IPv4 Gateway" 
        } while ($netInterfaceGatewayv4 -notmatch $pattern)  
    }
    "5"     { $netInterfaceNetMaskv4 = Read-Host "New IPv4 Net Mask (ex: 24)"}
    "6"     { $netInterfaceDnsv4 = Read-Host "New IPv4 DNS Servers separated by commas" }
    "7"     { 
        $response = Read-Host "Enable IPv6? (Y/n)"
        if ($response.ToUpper() -eq "Y"){
            $enableIpv6 = $true
        } 
        elseif ($response.ToUpper() -eq "N") {
            $enableIpv6 = $false
        }        
    }
    "8"     { $netInterfaceIpv6 = Read-Host "New IPv6 Address" }
    "9"     { $netInterfaceGatewayv6 = Read-Host "New IPv6 Gateway"}
    "10"    { $netInterfaceDnsv6 = Read-Host "New IPv6 DNS Servers separated by commas" }
    "11"    {
        $pattern = '(?i)(?=.{1,15}$)^(([a-z\d]|[a-z\d][a-z\d\-]*[a-z\d])\.)*([a-z\d]|[a-z\d][a-z\d\-]*[a-z\d])$' 
        do {
            $hostname = Read-Host "New Hostname (max. 15 characters)" 
        } while ($hostname -notmatch $pattern)
    }
    "12"    { 
        do{
            $timezone = Read-Host "New Time Zone" 
            $lookupTimezone = Get-TimeZone -ListAvailable | ? {$_.Id -eq $timezone}
        } while ($lookupTimezone -eq $null)
    }
    "13"    { $domain = Read-Host "New Domain" }
    "14"    { $domainAdminUser = Read-Host "New Domain Admin User"}
    "15"    { 
        $response = Read-Host "Join computer do domain? (Y/n)"
        if ($response.ToUpper() -eq "Y"){
            $joinToDomain = $true
        } 
        elseif ($response.ToUpper() -eq "N") {
            $joinToDomain = $false
        }        
    }
    default { }
}

cls

}
#endregion

#region NETWORK
Write-Host "`r`nStep: Network Settings"

$netAdapter = Get-NetAdapter | ? {$_.Name -eq $netInterfaceName}

if ($netAdapter -eq $null) {

    Write-Warning "Could not change network settings. Check interface name."
    $failureCount = $failureCount + 1
} 
else {
    try {
        # IPv4
        if ($enableIpv4 -eq $false) {
            Disable-NetAdapterBinding -Name $netInterfaceName -ComponentID ms_tcpip
        }     
        else {
            # Make sure IPv4 is enabled on the interface
            Enable-NetAdapterBinding -Name $netInterfaceName -ComponentID ms_tcpip

            # Clear existing configuration on the network interface
            if (($netAdapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
                $netAdapter | Remove-NetIPAddress -AddressFamily "IPv4" -Confirm:$false
            }

            if (($netAdapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
                $netAdapter | Remove-NetRoute -AddressFamily "IPv4" -Confirm:$false
            }

            # Configure the IP address and default gateway
            $netAdapter | New-NetIPAddress `
            -AddressFamily "IPv4" `
            -IPAddress $netInterfaceIpv4 `
            -PrefixLength $netInterfaceNetMaskv4 `
            -DefaultGateway $netInterfaceGatewayv4  

            # Configure the DNS servers
            $netAdapter | Set-DnsClientServerAddress -ServerAddresses $netInterfaceDnsv4
        }

        # IPv6
        if ($enableIpv6 -eq $false){
            Disable-NetAdapterBinding -Name $netInterfaceName -ComponentID ms_tcpip6
        } 
        else {
            Enable-NetAdapterBinding -Name $netInterfaceName -ComponentID ms_tcpip6      
        }

        Write-Host "Successfully changed Network Settings." -ForegroundColor Green
    }
    catch {
        Write-Warning "Could not change network settings. Check interface name."
        $failureCount = $failureCount + 1
    }
}
#endregion NETWORK

#region HOSTNAME_AND_DOMAIN_JOIN
Write-Host "`r`nStep: Hostname and Domain Join"

try{
    if ($joinToDomain -eq $true) {
        Add-Computer -DomainName $domain -NewName $hostname -Credential $domain\$domainAdminUser -ErrorAction Stop
        Write-Host "Successfully joined $($domain) with new computer name $($hostname)." -ForegroundColor Green
    } 
    else {
        Rename-Computer -NewName $hostname -ErrorAction Stop
        Write-Host "Successfully changed computer name to $($hostname)." -ForegroundColor Green
    }
}
catch {
     Write-Warning -Message $("Error while performing step.`r`nError: "+ $_.Exception.Message)
     $failureCount = $failureCount + 1
}
#endregion

#region TIMEZONE
Write-Host "`r`nStep: Time Zone"

try {
    Set-TimeZone -Id $timezone
    Write-Host "Successfully changed Time Zone to  $($timezone)." -ForegroundColor Green
}
catch {
     Write-Warning -Message $("Error changing Time Zone.`r`nError: "+ $_.Exception.Message)
     $failureCount = $failureCount + 1
}
#endregion

# If there has been any failure during runtime, then DO NOT restart automatically
if ($failureCount -gt 0){
    Write-Warning "`r`nThe script has failed to change some settings, so it will not restart the computer automatically."
} 
else {
    Write-Host "`r`nRebooting in 10 seconds... CTRL+C to cancel reboot"
    Sleep 10
    Restart-Computer
}