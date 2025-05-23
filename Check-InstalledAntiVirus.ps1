# get services
$services = Get-Service

# filter cb services
$cbServices = $services | Where-Object {
    $_.Name -in ('cbdefense', 'cbdefensewsc')
}

# filter s1 services
$s1Services = $services | Where-Object {
    $_.Name -in ('SentinelAgent','SentinelHelperService','LogProcessorService','SentinelStaticEngine')
}

# if carbon black is present or sentinel one is not present,
# exit 1 to trigger remediation script
if ($cbServices -or -not $s1Services) {
    Exit 1
} else {

    Exit 0
}
