$URL = 'https://download.microsoft.com/download/1/7/1/171DA19A-5477-4F50-B354-4ABAF28502A6/Microsoft_Cloud_AI_Azure_Service_Icon_Set_2019_09_11.zip'

# UnZip the file 
Add-Type -Assembly "System.IO.Compression.Filesystem"
[System.IO.Compression.ZipFile]::ExtractToDirectory('C:\Data\Compressed.zip', 'C:\Data\two')

# download the Azure Icon Set
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($URL, $LocalFilePath)
if (-not(Test-Path $LocalFilePath)) { Write-Error "Unable to download the file from URL: $URL" }

