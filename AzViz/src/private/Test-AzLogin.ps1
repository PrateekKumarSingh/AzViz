function Test-AzLogin {
    [CmdletBinding()]
    [OutputType([boolean])]
    [Alias()]
    Param()

    Begin {
    }
    Process {
        # Verify we are signed into an Azure account
        try {
            try{
                Import-Module Az.Accounts -Verbose:$false   
            }
            catch {}
            Write-Verbose 'Testing Azure login'
            $isLoggedIn = [bool](Get-AzContext -ErrorAction Stop)
            if(!$isLoggedIn){                
                Write-Verbose 'Not logged into Azure. Initiate login now.'
                Write-Host 'Enter your credentials in the pop-up window' -ForegroundColor Yellow
                $isLoggedIn = Connect-AzAccount
            }
        }
        catch [System.Management.Automation.PSInvalidOperationException] {
            Write-Verbose 'Not logged into Azure. Initiate login now.'
            Write-Host 'Enter your credentials in the pop-up window' -ForegroundColor Yellow
            $isLoggedIn = Connect-AzAccount
        }
        catch {
            Throw $_.Exception.Message
        }
        [bool]$isLoggedIn
    }
    End {
        
    }
}