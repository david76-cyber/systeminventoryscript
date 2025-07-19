# Get-SystemInventory.ps1
# Run this script as Administrator

$ComputerName = $env:COMPUTERNAME
$OS = Get-CimInstance Win32_OperatingSystem
$CPU = Get-CimInstance Win32_Processor
$RAM = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
$Disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$IPAddresses = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"}).IPAddress

# Create a custom object
$SystemInfo = [PSCustomObject]@{
    ComputerName = $ComputerName
    OSName       = $OS.Caption
    OSVersion    = $OS.Version
    CPU          = $CPU.Name
    RAM_GB       = $RAM
    IPAddresses  = $IPAddresses -join ", "
}

# Add disk info to the object
foreach ($disk in $Disks) {
    $label = "Disk_" + $disk.DeviceID.Replace(":", "")
    $free = [math]::Round($disk.FreeSpace / 1GB, 2)
    $size = [math]::Round($disk.Size / 1GB, 2)
    $SystemInfo | Add-Member -MemberType NoteProperty -Name "$label`_Free_GB" -Value $free
    $SystemInfo | Add-Member -MemberType NoteProperty -Name "$label`_Size_GB" -Value $size
}

# Output to console
$SystemInfo | Format-List

# Optional: Export to CSV
#$SystemInfo | Export-Csv -Path "$env:USERPROFILE\Desktop\SystemInventory.csv" -NoTypeInformation
