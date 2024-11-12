$uri = 'https://prices.azure.com/api/retail/prices?api-version=2023-01-01-preview&currencyCode=%27GBP%27&$filter=serviceFamily+eq+%27Compute%27+and+serviceName+eq+%27Virtual+Machines%27+and+priceType+eq+%27Consumption%27'
$Headers = @{}
$Items = @()
$Count = 0
$estTotal = 261000 # estimated total for progress bar
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
$Items | Export-CSV -Path ('AzureRetailPriceSheet_' + "$(get-date -format "yyyy_MM_dd_HH_mm")" +'.csv') -Force