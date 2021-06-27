function Remove-SpecialChars {
    param(
        [string]$String,
        [string]$SpecialChars = "()[]{}&."
    )

    $String -replace $($SpecialChars.ToCharArray().ForEach( { [regex]::Escape($_) }) -join "|"), ""
}