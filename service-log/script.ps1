# Define the paths to the log files
$logPaths = @("C:/Users/yohan/OneDrive/Desktop/mavn/service-log/service-1/log.txt", "C:/Users/yohan/OneDrive/Desktop/mavn/service-log/service-2/log.txt", "C:/Users/yohan/OneDrive/Desktop/mavn/service-log/service-3/log.txt")

# Define the keywords to look for in the logs
$keywords = @("ERROR", "WARNING", "CRITICAL")

# Define the output file for the daily summary report
$outputFile = "C:/Users/yohan/OneDrive/Desktop/mavn/service-log/summaryLog.txt"

# Initialize an array to hold the aggregated logs
$aggregatedLogs = @()

# Aggregate logs from multiple sources
foreach ($path in $logPaths) {
    $logs = Get-ChildItem -Path $path -Recurse | Select-String -Pattern $keywords
    $aggregatedLogs += $logs
}

# Initialize a hash table to hold correlated events
$correlatedEvents = @{}

# Correlate related events across services
foreach ($log in $aggregatedLogs) {
    $timestamp = [datetime]::ParseExact($log.Line.Substring(0, 19), "yyyy-MM-dd HH:mm:ss", $null)
    $service = $log.Path.Split("\")[-2]
    $message = $log.Line.Substring(20)
    
    if (-not $correlatedEvents.ContainsKey($timestamp)) {
        $correlatedEvents[$timestamp] = @()
    }
    
    $correlatedEvents[$timestamp] += @{
        Service = $service
        Message = $message
    }
}

# Generate a daily summary report highlighting the most significant issues
$report = @()

$report += "Daily Summary Report - $(Get-Date -Format 'yyyy-MM-dd')"
$report += "========================================"
$report += ""

foreach ($timestamp in $correlatedEvents.Keys | Sort-Object) {
    $report += "Timestamp: $timestamp"
    foreach ($event in $correlatedEvents[$timestamp]) {
        $report += "Service: $($event.Service)"
        $report += "Message: $($event.Message)"
        $report += ""
    }
    $report += "----------------------------------------"
}

# Save the report to the output file
$report | Out-File -FilePath $outputFile -Encoding utf8

Write-Output "Daily summary report generated at $outputFile"
