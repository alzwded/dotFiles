$TIMEOUT = 300

Add-Type -AssemblyName System.Speech;
$self = [System.Diagnostics.Process]::GetCurrentProcess().ID;
$a = New-Object System.Speech.Synthesis.SpeechSynthesizer;
$a.SelectVoiceByHints('female');
$a.Rate = 5;
$a.Volume = 70;

$m = Get-Module -ListAvailable -Name ThreadJob
if($m) {
    Write-Host "Using ThreadJob"
    # Needs Install-Module ThreadJob
    Import-Module ThreadJob
    $shared = [hashtable]::Synchronized(@{
        Value = Get-Date
    })
    $watchdog = Start-ThreadJob -ScriptBlock {
        while($true) {
            $now = Get-Date;
            $shared = $Using:shared;
            $old = $Using:shared;
            #Write-Error $now $old.Value
            if($now -gt $old.Value.AddSeconds($Using:TIMEOUT)) {
                Stop-Process -ID $Using:self
            }
            Start-Sleep -Seconds 1
        }
    }
    While($true) {
        $text = Read-Host;
        $shared.Value = Get-Date;
        $a.Speak($text);
        #Receive-Job $watchdog
    }
} else {
    Write-Host "Using BackgroundJob"
    While($true) {
        $j = Start-Job -ScriptBlock {
            Start-Sleep -Seconds $Using:TIMEOUT
            Stop-Process -ID $Using:self
        }
        $text = Read-Host;
        Stop-Job $j
        $a.Speak($text);
    }
}
