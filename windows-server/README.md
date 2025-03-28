# Win Server configuration via Powershell

- [Win Server configuration via Powershell](#win-server-configuration-via-powershell)
  - [How to configure variables](#how-to-configure-variables)
    - [Network](#network)
    - [General](#general)
    - [Domain And AD](#domain-and-ad)

## How to configure variables

The following variables need to be configured before running the script.

```powershell
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
```

### Network

Usually, the name of the network interface is `Ethernet0`, at least on VM's created on VMWare.

The rest of the network configuration is self-explanatory.  

>**Note:** If the `$enableIpv4` or `$enableIpv6` is set to **false**, it will disable the respective component on the network interface. 

### General

`$hostname` - Hostname of the computer. Dependent on the `$joinToDomain` option (read below).  
`$timezone` - The time zone that the computer will use. You can get a list of the available time zones by executing the command `Get-TimeZone -ListAvailable` in Powershell.

### Domain And AD

`$domain` - The domain that the computer will be joined to  
`$domainAdminUser` - The username of the domain administrator, with permission to join computers to the domain  
`$joinToDomain` - Specifies if the computer will be joined to the domain or not. If this is **false**, the name of the computer is simply changed to the value of the hostname variable above. In case this is set to **true**, then it joins the domain with the specified hostname, so you don't need to change the hostname before joining the computer to the domain.