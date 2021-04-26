function Write-CustomHost {
    [CmdletBinding()]
    param (
        [String] $String,
        # [datetime] $StartTime = [datetime]::Now,
        [string] $StartChar = [char]9654,
        [int] $Indentation = 1,
        [System.ConsoleColor] $Color = "White",
        [switch] $AddTime
    )
    
    begin {
        $3spaces = "   "
        $Indent = $3spaces*$Indentation
        $TimeDelta = [datetime]::Now - $StartTime

        if($TimeDelta.TotalSeconds -ge 60){
            $Duration = "{0}m {1}s" -f $TimeDelta.Minutes, $TimeDelta.Seconds
        } 
        elseif($TimeDelta.TotalSeconds -lt 60 -and $TimeDelta.TotalSeconds -gt 1){
            $Duration = "{0:n2}s" -f $TimeDelta.TotalSeconds
        }
        elseif($TimeDelta.TotalSeconds -le 1){
            $Duration = "{0}ms" -f [int]$TimeDelta.TotalMilliseconds
        }

    }
    
    process {
        Write-Host $Indent $StartChar $String -ForegroundColor $Color -NoNewline
        if($AddTime){
            Write-Host " ${Duration}" -ForegroundColor DarkGray
        }
        else{
            Write-Host ""
        }
    }
    
    end {
        
    }
}


# Write-CustomHost -String "Hello World!" -Indentation 1
# Write-CustomHost -String "Hello World!" -Indentation 2
# Write-CustomHost -String "Hello World!" -Indentation 3