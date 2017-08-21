param (
    [string]$vm_name
)

$adapter = Get-NetAdapter -physical | where status -eq 'up'
$switch_name = (Get-VMSwitch | ? { $_.NetAdapterInterfaceDescription -eq  $adapter.InterfaceDescription }).name

try {
  GET-VM -name $vm_name | GET-VMNetworkAdapter | Connect-VMNetworkAdapter -Switchname $switch_name
}
catch {

}


Write-host $switch_name
