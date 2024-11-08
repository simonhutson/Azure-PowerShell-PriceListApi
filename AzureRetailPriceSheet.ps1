$uri = "https://prices.azure.com/api/retail/prices?currencyCode='GBP'"  # optionally add "?currencyCode='USD'"
$Headers = @{}
$Items = @()
$Count = 0
$estTotal = 327900		# estimated total
Do
{
	$pct = [math]::min([Math]::Truncate($Count / $estTotal * 100), 99)
	write-progress -Activity "Reading Azure Retail Price Sheet" -Status "$($Count + 1) to $($Count + 100)" -Id 1 -PercentComplete $pct
	$r = Invoke-WebRequest -Method 'Get' -uri $uri -Header $Headers -UseBasicParsing # -Verbose
	$c = $r.Content | ConvertFrom-Json
	$Items += $c.Items
	$Count += $c.Count
	$uri = $c.NextPageLink
} While ($c.NextPageLink)
write-progress -Activity "Reading Azure Retail Price Sheet" -Status "Done" -Id 1 -PercentComplete 100 -Completed

# Export to CSV
$Items | Export-CSV -Path ("$(get-date -format "Retail_yyyy_mm")" +'.csv') -Force 