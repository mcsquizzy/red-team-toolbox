# Internal Reconnaissance

####################
# Global Variables #
####################

#$hostname = hostname
#$myUSERFILE = "${hostname}_user_info.txt"


######################
# System Information #
######################

function system_info {

Write-Output "" #newline
Write-Output "System information"
Write-Output ""

Write-Output "User: $(whoami)"
Write-Output "Home Path: $(echo $HOME)"
Write-Output "Hostname: $(hostname)"
Write-Output ""

# Windows version
# Todo

# all variables
Write-Output ""
Write-Output "All variables:"
Get-Variable
Write-Output ""

# Processor Information, System Type
Write-Output ""
Write-Output "Processor information, System Type:"
Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property SystemType

# Listing BIOS settings
Write-Output ""
Write-Output "BIOS settings:"
Get-CimInstance -ClassName Win32_BIOS

# List installed hotfixes
$hotfixes = Get-CimInstance -ClassName Win32_QuickFixEngineering
Write-Output ""
Write-Output "Installed hotfixes:"
Write-Output $hotfixes

}


#######################
# Network Information #
#######################

function network_info {

Write-Output "" #newline
Write-Output "Network information"
Write-Output ""

# get ipv4 addresses
$ipaddresses = Get-NetIPAddress -AddressFamily IPV4
Write-Output ""
Write-Output "All IPv4 addresses:" "$ipaddresses"
Write-Output ""

}


####################
# User Information #
####################

function user_info {

Write-Output "" #newline
Write-Output "User information"
Write-Output ""

# all users
Write-Output ""
Write-Output "All users on the system:"
Write-Output ""
$users = Get-LocalUser
foreach ($user in $users) {
    Write-Output "$user"
}
Write-Output ""

}


########################
# Processes / Services #
########################

function services_info {

Write-Output "" #newline
Write-Output "Information about processes and services"
Write-Output ""

Write-Output ""
Write-Output "All running services:"
Get-Service | where{$_.Status -eq "Running"}

}


####################
# Execution Policy #
####################

#powershell.exe -ExecutionPolicy Bypass


#############
# Run parts #
#############

system_info | Tee-Object -FilePath ".\$(hostname)_system_info.txt"
network_info | Tee-Object -FilePath ".\$(hostname)_network_info.txt"
user_info | Tee-Object -FilePath ".\$(hostname)_user_info.txt"
services_info | Tee-Object -FilePath ".\$(hostname)_services_info.txt"


Write-Output ""
Write-Output "Internal Recon complete"
Write-Output ""
