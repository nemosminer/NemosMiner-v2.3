using module ..\Includes\Include.psm1

$Name = "$(Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName)"
$Path = ".\Bin\$($Name)\cudaminer-x64.exe"
$Uri = "https://github.com/ghostlander/cudaminer-neoscrypt/releases/download/v1.0.1/cudaminer-neoscrypt-win-1.0.1.zip"
$DeviceEnumerator = "Type_Vendor_Index"

$AlgorithmDefinitions = [PSCustomObject[]]@(
    [PSCustomObject]@{ Algorithm = "NeoScrypt"; MinMemGB = 2; MinerSet = 0; Arguments = " --intensity 16.999" } # Cryptodredge-v25.1 is fastest
)

If ($AlgorithmDefinitions = $AlgorithmDefinitions | Where-Object MinerSet -LE $Config.MinerSet | Where-Object { $Pools.($_.Algorithm).Host }) { 

    $Devices | Where-Object Type -EQ "NVIDIA" | Select-Object Model -Unique | ForEach-Object { 

        If ($SelectedDevices = @($Devices | Where-Object Model -EQ $_.Model)) { 

            $MinerAPIPort = [UInt16]($Config.APIPort + ($SelectedDevices | Sort-Object Id | Select-Object -First 1 -ExpandProperty Id) + 1)

            $AlgorithmDefinitions | ForEach-Object {

                $MinMemGB = $_.MinMemGB

                If ($Miner_Devices = @($SelectedDevices | Where-Object { ($_.OpenCL.GlobalMemSize / 1GB) -ge $MinMemGB })) { 

                    $Miner_Name = (@($Name) + @($Miner_Devices.Model | Sort-Object -Unique | ForEach-Object { $Model = $_; "$(@($Miner_Devices | Where-Object Model -eq $Model).Count)x$Model" }) | Select-Object) -join '-'

                    # Get commands for active miner devices
                    # $_.Arguments= Get-ArgumentsPerDevice -Command $_.Arguments-ExcludeParameters @("algo") -DeviceIDs $Miner_Devices.$DeviceEnumerator

                    [PSCustomObject]@{ 
                        Name       = $Miner_Name
                        Type       = "NVIDIA"
                        DeviceName = $Miner_Devices.Name
                        Path       = $Path
                        Arguments  = ("$($_.Arguments) --url stratum+tcp://$($Pools.($_.Algorithm).Host):$($Pools.($_.Algorithm).Port) --user $($Pools.($_.Algorithm).User) --pass $($Pools.($_.Algorithm).Pass) --statsavg 2 --retries 1 --api-bind $MinerAPIPort --devices $(($Miner_Devices | Sort-Object $DeviceEnumerator | ForEach-Object { '{0:x}' -f $_.$DeviceEnumerator }) -join ',')" -replace "\s+", " ").trim()
                        Algorithm  = $_.Algorithm
                        API        = "Ccminer"
                        Port       = $MinerAPIPort
                        URI        = $Uri
                    }
                }
            }
        }
    }
}
