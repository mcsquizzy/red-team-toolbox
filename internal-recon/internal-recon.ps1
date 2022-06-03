# Internal Reconnaissance

####################
# Global Variables #
####################


#$myUSERFILE = "${hostname}_user_info.txt"


######################
# System Information #
######################

function system_info {

Write-Output "" #newline
Write-Output "System information"
Write-Output ""
Write-Output "User: " $(whoami)
Write-Output "Home Path: " $(echo $HOME)
Write-Output "Hostname: " $(hostname)

#Write-Output "Windows Version:"
#$winversion = Get-ComputerInfo | select WindowsProductName, WindowsVersion
#Get-ComputerInfo | select WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer

#Start-Sleep -Seconds 6

# all variables
Write-Output "All variables:"
Get-Variable

# Processor Information, System Type
Write-Output ""
Write-Output "Processor information, System Type:"
Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property SystemType

# Listing BIOS settings
Write-Output "BIOS settings:"
Get-CimInstance -ClassName Win32_BIOS

#Write-Host "Welcome to the script of fetching computer Information"
#Write-host "The BIOS Details are as follows"
#Get-CimInstance -ClassName Win32_BIOS

# List installed hotfixes
Write-Output ""
Write-Output "Installed hotfixes:"
Get-CimInstance -ClassName Win32_QuickFixEngineering

}


#######################
# Network Information #
#######################

function network_info {

Write-Output "" #newline
Write-Output "Network information"

# get ipv4 addresses
Write-Output "All IPv4 addresses:"
Get-NetIPAddress -AddressFamily IPV4

}


####################
# User Information #
####################

function user_info {

Write-Output "" #newline
Write-Output "User information"

# all users
Write-Output "All users on the system:"
$users = Get-LocalUser
foreach ($user in $users) {
    Write-Output "$user"
}

}


########################
# Processes / Services #
########################

function services_info {

Write-Output "" #newline
Write-Output "Information about processes and services"

#Write-Host "All running processes:"

Write-Output "Status of the running services are as follows:"
Get-CimInstance -ClassName Win32_Service | Format-Table -Property Status,Name,DisplayName -AutoSize -Wrap

}


####################
# Execution Policy #
####################

#powershell.exe -ExecutionPolicy Bypass


#############
# Run parts #
#############

system_info | Tee-Object -FilePath ".\system_info.txt"
network_info | Tee-Object -FilePath ".\network_info.txt"
user_info | Tee-Object -FilePath ".\user_info.txt"
services_info | Tee-Object -FilePath ".\services_info.txt"

Write-Output ""
Write-Output "Internal Recon complete"
Write-Output ""
