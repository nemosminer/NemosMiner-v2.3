if (!(IsLoaded(".\Includes\include.ps1"))) { . .\Includes\include.ps1; RegisterLoaded(".\Includes\include.ps1") }
$Path = ".\Bin\CPU-XMRigcc250\xmrigDaemon.exe"
$Uri = "https://github.com/Minerx117/miner-binaries/releases/download/2.5.0/xmrigcc.zip"
$Commands = [PSCustomObject]@{
    "randomxmonero"      = " -a rx/0 --nicehash" #RandomX
    "randomarq"          = " -a rx/arq --nicehash" #Randomarq
    "randomx"            = " -a rx/0 --nicehash" #RandomX
    "randomsfx"          = " -a rx/sfx --nicehash" #RandomX
    "cryptonightv7"      = " -a cn/1 --nicehash" #cryptonightv7
    "cryptonight_heavy"  = " -a cn-heavy/0 --nicehash" #cryptonight_heavyx
    "cryptonight_heavyx" = " -a cn/double --nicehash" #cryptonight_heavyx
    "cryptonight_saber"  = " -a cn-heavy/0 --nicehash" #cryptonightGPU
    "cryptonight_fast"   = " -a cn/half --nicehash" #cryptonightFast
    "cryptonight_haven"  = " -a cn-heavy/xhv --nicehash" #cryptonightFast
    "cryptonight_upx"    = " -a cryptonight-extremelite --nicehash" #cryptonightupx
}
$ThreadCount = $Variables.ProcessorCount - 1
$Port = $Variables.CPUMinerAPITCPPort
$Name = "$(Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName)"
$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object { $Algo = Get-Algorithm $_; $_ } | Where-Object { $Pools.$Algo.Host } | ForEach-Object {
    [PSCustomObject]@{
        Type      = "CPU"
        Path      = $Path
        Arguments = "-t $($ThreadCount) -o stratum+tcp://$($Pools.$Algo.Host):$($Pools.$Algo.Port) -u $($Pools.$Algo.User) -p $($Pools.$Algo.Pass)$($Commands.$_) --keepalive --http-enabled --http-port=$($Variables.CPUMinerAPITCPPort) --donate-level 0"
        HashRates = [PSCustomObject]@{ $Algo = $Stats."$($Name)_$($Algo)_HashRate".Day } #Recompiled 0% fee
        API       = "XMRig"
        Port      = $Variables.CPUMinerAPITCPPort
        Wrap      = $false
        URI       = $Uri    
        User      = $Pools.$Algo.User
    }
}
