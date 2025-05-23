Start-Transcript -Path 'C:\cb_to_s1.log.txt'

# get services
$services = Get-Service

# filter cb services
$cbServices = $services | Where-Object {
    $_.Name -in ('cbdefense', 'cbdefensewsc')
}

# filter s1 services
$s1Services = $services | Where-Object {
    $_.Name -in ('SentinelAgent', 'SentinelHelperService', 'LogProcessorService', 'SentinelStaticEngine')
}

# check if carbon black is present
if ($cbServices) {
    # cb is present, uninstall it
    $params = @{
        FilePath     = 'C:\program files\confer\Uninstall.exe'
        ArgumentList = ('/uninstall ZVCKFS63')
        Wait         = $true
    }
    Start-Process @params
}

# verify carbon black removal
$cbServices = Get-Service | Where-Object {
    $_.Name -in ('cbdefense', 'cbdefensewsc')
}

if ($cbServices) {
    'Error, Carbon black is still present'
    Exit 1
} else {
    # install Sentinel 1
    # download install file
    $params = @{
        Uri     = 'https://raw.githubusercontent.com/tbrock-opti/cbToS1/refs/heads/main/SentinelOneInstaller_windows_64bit_v24_1_6_313.exe'
        Outfile = 'c:\SentinelOneInstaller_windows_64bit_v24_1_6_313.exe'
    }
    Invoke-WebRequest @params

    # run installer
    $params = @{
        FilePath     = 'msiexec.exe'
        ArgumentList = ('-t eyJ1cmwiOiAiaHR0cHM6Ly9ldXdlMy04MDEuc2VudGluZWxvbmUubmV0IiwgInNpdGVfa2V5IjogIjgwZjYyMWRhNWQ1ZTJjMTBlNDljYjMwZWNjYTMzYzcxMDQxMTVlMTZlODcyZGE2YzlmZjAzMTA4YjFmOTg5ODEifQ==', '-qn')
        Wait         = $true
    }
    Start-Process @params

    $s1Services = Get-Service | Where-Object {
        $_.Name -in ('SentinelAgent', 'SentinelHelperService', 'LogProcessorService', 'SentinelStaticEngine')
    }

    if ($s1Services) {
        # success
        Exit 0
    } else {
        # something didn't work
        Exit 1
    }
}

