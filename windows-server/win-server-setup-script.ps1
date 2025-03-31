#######################################
# Windows Server Initial Setup Script #
#######################################

# ---------------- VARIABLES ---------------- #
#
# Keep track of steps failed during runtime
$failureCount = 0
# Warning message to show on the menu, if there is any
$warningMessage = $null
#
# -------------- NETWORK --------------
#
$netInterfaceName = "Ethernet0"
# ------- IPV4
$enableIpv4 = $true
$netInterfaceIpv4 = ""
$netInterfaceGatewayv4 = ""
$netInterfaceNetMaskv4 = "24"
$netInterfaceDnsv4 = "1.1.1.1,1.0.0.1"
# ------- IPV6
$enableIpv6 = $false
$netInterfaceIpv6 = "" 
$netInterfaceGatewayv6 = ""
$netInterfaceDnsv6 = ""
#
# -------------- GENERAL --------------
#
$hostname = $env:computername
$timezone = "GMT Standard Time" 
#
# -------------- DOMAIN ---------------
#
$domain = $env:USERDNSDOMAIN
$domainAdminUser = "Administrator"
$joinToDomain = $false
#
# -------------- END VARIABLES -------------- #

function Write-Success([string]$message) {
    Write-Host $message -ForegroundColor Green
}

#region DISCLAIMER
Write-Host @"

!!!!! WARNING !!!!!
This script changes system settings, and can potentially break things.
Ensure you have a snapshot/backup before running this.
"@ -ForegroundColor Yellow -BackgroundColor Black

do {
    $disclaimerInput = Read-Host "Do you want to continue? (Y/n)"
} until ($disclaimerInput -in "Y", "N")

if ($disclaimerInput -eq "N") {
    Exit
}

Clear-Host
#endregion

#region USER_INPUTS
while ($True) {

    Clear-Host

    Write-Host @"

    ================= Windows Server Setup Script =================                     
                                                                          
       1.  Network Interface Name    $($netInterfaceName)                   
       2.  Enable IPv4?              $($enableIpv4)                         
       3.  IPv4                      $($netInterfaceIpv4)                   
       4.  IPv4 Gateway              $($netInterfaceGatewayv4)              
       5.  IPv4 Net Mask (CIDR)      $($netInterfaceNetMaskv4)              
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

    if ($null -ne $warningMessage) {
        Write-Warning "$($warningMessage)"
        Write-Host "" # Just for extra blank space. If I add a newline on the warning above, the background of the warning shifts down as well, so it needs to be like this.
    }

    $option = Read-Host "Select an option to change or type 'start' to run the script with the options above" 

    if ($option -eq "start") {
        
        # Verify everything is filled correctly before starting

        # IPv4
        if ($enableIpv4 -eq $true) {
            if (($netInterfaceName -eq "") -or
                ($netInterfaceIpv4 -eq "") -or 
                ($netInterfaceGatewayv4 -eq "") -or
                ($netInterfaceNetMaskv4 -eq "") -or
                ($netInterfaceDnsv4 -eq "")) {
                $warningMessage = "IPv4 settings are missing. Script will not start."
                continue
            }
        }

        # IPv6
        if ($enableIpv6 -eq $true) {
            if (($netInterfaceName -eq "") -or
                ($netInterfaceIpv6 -eq "") -or 
                ($netInterfaceGatewayv6 -eq "") -or
                ($netInterfaceDnsv6 -eq "")) {
                $warningMessage = "IPv6 settings are missing. Script will not start."
                continue
            }
        }

        # Domain
        if ($joinToDomain -eq $true) {
            if (($domain -eq "") -or
                ($domainAdminUser -eq "") -or
                ($hostname -eq "")) {
                $warningMessage = "Domain settings are missing. Script will not start."
                continue
            }
        }

        break
    }

    switch ($option) {
        "1" { 
            Write-Host "Available Network Interfaces:"
            (Get-NetAdapter | Select-Object Name, InterfaceDescription, Status) | Out-Host
            do {
                $netInterfaceName = Read-Host "New Network Interface Name"
                $netAdapter = Get-NetAdapter | Where-Object { $_.Name -eq $netInterfaceName }
            } while ($null -eq $netAdapter)

            # Get current IP configuration for the specified interface
            $currentIpConfiguration = Get-NetIPConfiguration | Where-Object { $_.InterfaceAlias -eq $netInterfaceName }

            # IPv4 configuration
            $netInterfaceIpv4 = $currentIpConfiguration.IPv4Address.IPAddress
            $netInterfaceNetMaskv4 = $currentIpConfiguration.IPv4Address.PrefixLength
            $netInterfaceGatewayv4 = $currentIpConfiguration.Ipv4DefaultGateway.NextHop
            $netInterfaceDnsv4 = ($currentIpConfiguration.DNSServer | Where-Object { $_.AddressFamily -eq 2 }).ServerAddresses -join ","

            # IPv6 configuration
            $netInterfaceIpv6 = $currentIpConfiguration.IPv6Address.IPAddress
            #$netInterfaceIpv6Prefix = $currentIpConfiguration.IPv6Address.PrefixLength
            $netInterfaceDnsv6 = ($currentIpConfiguration.DNSServer | Where-Object { $_.AddressFamily -eq 23 }).ServerAddresses -join ","
        }
        "2" { 
            $response = Read-Host "Enable IPv4? (Y/n)"
            if ($response -eq "Y") {
                $enableIpv4 = $true
            } 
            elseif ($response -eq "N") {
                $enableIpv4 = $false
            }
        }
        "3" { 
            $pattern = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
            do {
                $netInterfaceIpv4 = Read-Host "New IPv4 Address"
            } while ($netInterfaceIpv4 -notmatch $pattern)  
        }
        "4" { 
            $pattern = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
            do {
                $netInterfaceGatewayv4 = Read-Host "New IPv4 Gateway" 
            } while ($netInterfaceGatewayv4 -notmatch $pattern)  
        }
        "5" { $netInterfaceNetMaskv4 = Read-Host "New IPv4 Net Mask in CIDR format (ex: 24)" }
        "6" { 
            $pattern = '((25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)(,\n|,?$))'
            do {
                $netInterfaceDnsv4 = Read-Host "New IPv4 DNS Servers separated by commas (ex: 1.1.1.1,1.0.0.1)" 
            } while ($netInterfaceDnsv4 -notmatch $pattern)
        }
        "7" { 
            $response = Read-Host "Enable IPv6? (Y/n)"
            if ($response -eq "Y") {
                $enableIpv6 = $true
            } 
            elseif ($response -eq "N") {
                $enableIpv6 = $false
            }        
        }
        "8" { $netInterfaceIpv6 = Read-Host "New IPv6 Address" }
        "9" { $netInterfaceGatewayv6 = Read-Host "New IPv6 Gateway" }
        "10" { $netInterfaceDnsv6 = Read-Host "New IPv6 DNS Servers separated by commas" }
        "11" {
            $pattern = '(?i)(?=.{1,15}$)^(([a-z\d]|[a-z\d][a-z\d\-]*[a-z\d])\.)*([a-z\d]|[a-z\d][a-z\d\-]*[a-z\d])$' 
            do {
                $hostname = Read-Host "New Hostname (max. 15 characters)" 
            } while ($hostname -notmatch $pattern)
        }
        "12" { 
            do {
                $timezone = Read-Host "New Time Zone" 
                $lookupTimezone = Get-TimeZone -ListAvailable | Where-Object { $_.Id -eq $timezone }
            } while ($null -eq $lookupTimezone)
        }
        "13" { $domain = Read-Host "New Domain" }
        "14" { $domainAdminUser = Read-Host "New Domain Admin User" }
        "15" { 
            $response = Read-Host "Join computer do domain? (Y/n)"
            if ($response -eq "Y") {
                $joinToDomain = $true
            } 
            elseif ($response -eq "N") {
                $joinToDomain = $false
            }        
        }
        default { }
    }

    $warningMessage = $null
}
#endregion

#region NETWORK
Write-Host "`r`nStep: Network Settings"

$netAdapter = Get-NetAdapter | Where-Object { $_.Name -eq $netInterfaceName }

if ($null -eq $netAdapter) {

    Write-Warning "Could not change network settings. Check interface name."
    $failureCount = $failureCount + 1
} 
else {
    try {
        # IPv4
        if ($enableIpv4 -eq $false) {
            Disable-NetAdapterBinding -Name $netInterfaceName -ComponentID ms_tcpip
            Write-Success "Successfully disabled IPv4." 
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

            Write-Success "Successfully changed IPv4 settings."
        }

        # IPv6
        if ($enableIpv6 -eq $false) {
            Disable-NetAdapterBinding -Name $netInterfaceName -ComponentID ms_tcpip6
            Write-Success "Successfully disabled IPv6." 
        } 
        else {
            Enable-NetAdapterBinding -Name $netInterfaceName -ComponentID ms_tcpip6      
            Write-Success "Successfully changed IPv6 settings." 
        }

    }
    catch {
        Write-Warning "Could not change network settings. Check interface name."
        $failureCount = $failureCount + 1
    }
}
#endregion NETWORK

#region HOSTNAME_AND_DOMAIN_JOIN
Write-Host "`r`nStep: Hostname and Domain Join"

try {
    if ($hostname -eq "") {
        Write-Host "Hostname was not specified, skipping step..."
    } 
    elseif ($hostname -eq $env:computername) {
        if ($joinToDomain -eq $true) {
            Add-Computer -DomainName $domain -Credential $domain\$domainAdminUser -ErrorAction Stop
            Write-Success "Successfully joined '$($domain)'." 
        }
        else {
            Write-Host "Computer hostname is already '$($hostname)', skipping step..."
        }
    }
    else {
        if ($joinToDomain -eq $true) {
            Add-Computer -DomainName $domain -NewName $hostname -Credential $domain\$domainAdminUser -ErrorAction Stop
            Write-Success "Successfully joined '$($domain)' with new computer name '$($hostname)'."
        }
        else {
            Rename-Computer -NewName $hostname -ErrorAction Stop
            Write-Success "Successfully changed computer name to '$($hostname)'."
        }
    }
}
catch {
    Write-Warning -Message $("Error while performing step.`r`nError: " + $_.Exception.Message)
    $failureCount = $failureCount + 1
}
#endregion

#region TIMEZONE
Write-Host "`r`nStep: Time Zone"

try {
    Set-TimeZone -Id $timezone
    Write-Success "Successfully changed Time Zone to '$($timezone)'."
}
catch {
    Write-Warning -Message $("Error changing Time Zone.`r`nError: " + $_.Exception.Message)
    $failureCount = $failureCount + 1
}
#endregion

# If there has been any failure during runtime, then DO NOT restart automatically
if ($failureCount -gt 0) {
    Write-Warning "`r`nThe script has failed to change some settings, so it will not restart the computer automatically."
} 
else {
    Write-Host "`r`nRebooting in 10 seconds... CTRL+C to cancel reboot"
    Start-Sleep 10
    Restart-Computer
}