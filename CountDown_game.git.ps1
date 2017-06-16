# I'm not doing this manually...
$cons = @()
$vowel = @()
$alpha = @('aaeeiou', 'bdccddfghjkllmmnnppqrrsssttvxz')

$vowel += $alpha[0].ToCharArray()
$cons += $alpha[1].ToCharArray()

# Functions
function numInput() {
    Write-Host "Choose how many big and small numbers you'd like. MAX 6"
    $inputBig = Read-Host -Prompt "Big _> "
    $inputSmall = Read-Host -Prompt "Small _> "

    $inputBig
    $inputSmall
}

function letInput() {
    $letters = @()
    Clear-Host
    while ($letters.Length -lt 9) {

        $type = Read-Host -Prompt "Vowel or Cons? _> "
        Clear-Host
        if ($type -eq 'v' -or $type -eq 'vowel') {
            [string]$temp = Get-Random -InputObject $vowel -Count 1
            $letters += $temp.ToUpper()
            Write-Host "## $letters ##"
        }
        elseif ($type -eq 'c' -or $type -eq 'cons') {
            [string]$temp = Get-Random -InputObject $cons -Count 1
            $letters += $temp.ToUpper()
            Write-Host "## $letters ##"
        }
        else {Write-Host "## Invalid ##"}
    }    
    
    $letters
}

function Numbers() {
    $Big = @(25, 50, 75, 100)
    $Small = @(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

    $givenNumbers = @()

    [int]$inputBig, [int]$inputSmall = numInput
   
    if ($inputBig + $inputSmall -eq 6) {
        Clear-Host
        # Getting random Big and Small numbers using numInput 
        $givenNumbers += Get-Random -InputObject $Big -Count $inputBig
        $givenNumbers += Get-Random -InputObject $Small -Count $inputSmall

        Write-Host "`nYour numbers are: $givenNumbers"

        #Sleep for 3 seconds (Time to write down numbers)
        Write-Host "Generating Target Number..." -ForegroundColor Red
        Start-Sleep(3)

        # Gets target number between 125 - 1000
        $targetNum = Get-Random -Maximum 100 -Minimum 1
        Write-Host "The Target Number is: $targetNum"

        # 30 second timer with a big of a progress bar because it was boring...
        Write-Host "`nYour time starts now."
        foreach ($_ in 1..3) {Write-Host "|" -BackgroundColor Blue -ForegroundColor Black -NoNewLine; Start-Sleep(1)}
        Write-Host "`nTimes up!" -BackgroundColor Red -ForegroundColor Black

        $answer = Get-UserInput

        # Checking string for letters. It should only ever have numbers and operators. 
        foreach ($char in $answer) {
            if ($char -match "[a-z]") {
                Write-Host "Invalid Input. No Letters.`n" -ForegroundColor Red
            }
            else {CheckNumbers -answer $answer -targetNum $targetNum}
        }
    }

    else {Write-Host "Invalid. Total of 6 numbers (2 Big 4 Small)"; Numbers}
    
}

function Letters() {
    $letters = letInput
    $letters = New-Object System.Collections.ArrayList(, $letters)

    Write-Host "Your letter are: " -NoNewline
    Write-Host $letters

    Start-Sleep(3)
    
    Write-Host "`nYour time starts now."
    foreach ($_ in 1..3) {Write-Host "|" -BackgroundColor Blue -ForegroundColor Black -NoNewLine; Start-Sleep(1)}
    Write-Host "`nTimes up!" -BackgroundColor Red -ForegroundColor Black

    $answer = Get-UserInput
    $check = @()

    foreach ($letter in $answer.ToCharArray()) {
        if ($letter -in $letters) {
            [string]$letString = $letter
            $letters.Remove($letString.ToUpper())
            $check += $letter
        }
        else {Write-Host "Invalid. You either used a letter that wasn't there or the same letter twice."}
    }

    if ($check.Length -eq $answer.ToCharArray().Length) {
        Write-Host "Checking Answer..." -ForegroundColor Red
        $temp = CheckSpelling -str $answer
        
        if ($temp.flaggedTokens.count -eq 0) {

            $error, $pass = CheckWord -str $answer

            if ($pass.count -gt 0) {
                Write-Host "Good work! Valid word" -ForegroundColor Green
                Write-Host "`n$($answer.ToUpper())`n$pass`n"
                
                $script:points += $(Get-Letters -word $answer)
                Write-Host "You got $(Get-Letters -word $answer) point for $answer" -ForegroundColor Green
            }
            else {Write-Host "Bad luck. $answer is not a valid English word."}
        }

        elseif ($temp.flaggedTokens.suggestions[0].score[0]) {
            Write-Host "DEBUG: Score = $($temp.flaggedTokens.suggestions[0].score)"
            Write-Host "Invalid word. Did you mean '$($temp.flaggedTokens.suggestions[0].suggestion)'?" -ForegroundColor Red
        }
        
        
    }

}

function CheckNumbers () {
    param(
        [string]$answer,
        [int]$targetNum
    )

    $maxPoints = 10

    $check = Invoke-Expression $answer

    if ($check -gt $targetNum -and $check -ne $targetNum) {
        $gap = $check - $targetNum
    }
    elseif ($targetNum -gt $check) {
        $gap = $targetNum - $check
    }
    elseif ($targetNum -eq $check) {
        $gap = 0 
    }

    if ($gap -eq 0) {
        $script:points += 10
        Write-Host "`nYou got $check! Perfect!" -ForegroundColor Green
        Write-Host "You get 10 points!`n" -ForegroundColor Green
    }
    elseif ($maxPoints -gt $gap) {
        $script:points += ($maxPoints - $gap)
        Write-Host "`nYou got $check. $gap away from the target number." -ForegroundColor Green
        Write-Host "You got $($maxPoints -$gap) points that round!`n" -ForegroundColor Green
    }
    else {Write-Host "`nYou got $check. $gap away from the target number.`nYou got 0 points. Bad luck`n" -ForegroundColor Green} 
}

function CheckSpelling () {
    Param([string]$str)
    $data = Invoke-RestMethod "https://api.cognitive.microsoft.com/bing/v5.0/spellcheck?text=$str&count=3&mkt=en-us" -Headers @{ "Ocp-Apim-Subscription-Key" = "< INSERT YOUR OWN API KEY >" }

    $data
}

function CheckWord () {
    # Using Oxford API to see if word is real or not
    param([string]$str)

    try {
        $data = Invoke-RestMethod "https://od-api.oxforddictionaries.com/api/v1/entries/en/$str" -Headers @{"app_id" = "< INSERT YOUR OWN APP ID >"; "app_key" = " < INSERT YOUR OWN API KEY >}
    }
    catch {
        $checkwordError = $_.Exception.Response.StatusCode.value__
    }
    $checkwordError
    $data.results.lexicalEntries.entries.senses.definitions


}

function Get-UserInput() {
    $answer = Read-Host -Prompt "Enter answer _>  "
    $answer
}

function Get-Letters() {
    param([string]$word)

    $tempPoints = 0

    foreach ($letter in $word.ToCharArray()) {
        $tempPoints += 1
    }

    if ($tempPoints -eq 9) {
        $script:points += $tempPoints * 2
    }

    $tempPoints
}
 function FuckYouGen () {
     Write-Host "I Fucking told you not too"
 }
# Main Start

# Placeholders
$points = 0
$running = 1

while ($running -ne 0) {
    Write-Host 

        Write-Host @"
1. Numbers
2. Letters
3. Full Game (3 Rounds of each) NA
q. Quit`n
"@

    $input = Read-Host -Prompt "_> "

    switch ($input) {
        1 { Numbers }
        2 { Letters }
        3 { FuckYouGen }
        'q' { Write-Host "You got $points points. Bye."; $running = 0 }
    }
}
