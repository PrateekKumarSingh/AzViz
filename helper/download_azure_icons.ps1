$url = 'https://download.microsoft.com/download/1/7/1/171DA19A-5477-4F50-B354-4ABAF28502A6/Microsoft_Cloud_AI_Azure_Service_Icon_Set_2019_09_11.zip'
$temp_file = "$env:TEMP\icons.zip"


# download the Azure Icon Set
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($URL, $temp_file)
if (-not(Test-Path $temp_file)) { Write-Error "Unable to download the file from URL: $URL" }

# UnZip the file 
Expand-Archive $temp_file -Verbose