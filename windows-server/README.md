# Win Server Setup via Powershell

- [Win Server Setup via Powershell](#win-server-setup-via-powershell)
  - [Purpose](#purpose)
  - [Variable configuration](#variable-configuration)
    - [Network](#network)
    - [General](#general)
    - [Domain](#domain)
  - [Running the script](#running-the-script)
    - [With internet](#with-internet)
    - [No internet](#no-internet)

## Purpose

This script simplifies the first configurations after doing a fresh Windows Server installation.  

## Variable configuration

You can configure the following variables before running the script by editing the file directly, or by running the script and changing them via the interactive menu.

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

> [!WARNING] 
> IPv6 is not fully implemented yet. Currently only the enable function is working.

Be sure to set the correct network interface name before starting execution. The interactive menu on the script will guide you through choosing the correct one.  
The rest of the network configuration is self-explanatory.  

The setting `$enableIpv4` and `$enableIpv6`, will either enable or disable the respective component on the network interface, depending on what their value is set to.

### General

`$hostname` - Hostname of the computer. Dependent on the `$joinToDomain` option (read below).  
`$timezone` - The time zone that the computer will use. You can get a list of the available time zones by executing the command `Get-TimeZone -ListAvailable` in Powershell.

### Domain

`$domain` - The domain that the computer will be joined to  
`$domainAdminUser` - The username of the domain administrator, with permission to join computers to the domain  
`$joinToDomain` - Specifies if the computer will be joined to the domain or not. If this is **false**, the name of the computer is simply changed to the value of the hostname variable above. In case this is set to **true**, then it joins the domain with the specified hostname, so you don't need to change the hostname before joining the computer to the domain.

## Running the script

### With internet

If you have an internet connection, you can simply run the following command in a Powershell window, and the script will be automatically downloaded and executed.

```
irm telmoduarte.me/win-server-setup | iex
```

### No internet

In the case of no internet connectivity, download the script from the repository and copy it to the machine you want to execute it in.  
After that, you can execute it easily with the following command:

```
./win-server-setup-script.ps1
```