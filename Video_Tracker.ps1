#UPDATED 9/4/2026

#Get-Process vrmonitor | select starttime
#PROGRAM ARGUMENTS: video_name student_name student_id
#param($name)
$name = $args[0]
$Student_Name = $args[1]
$ID = $args[2]

$root = Split-Path -Parent $MyInvocation.MyCommand.Path


$completion_status_code = 0

#List all videos available to watch
$File_Path = "..\..\..\360 Videos\" + $name

#UNCOMMENT --------------------------
$Files = Get-ChildItem -Path '..\..\..\360 Videos' -Name
$i = -1
foreach ($Vid in $Files) {
#    Write-Output "$i. $File"
    if ($Vid -eq $name) {
        $Video_num = $i
    }
    $i++
}

#COMMENT ---------------------
#$Video_num = 1

#START THE VIDEO TRANSCRIPTION SCRIPT
#THIS SHOULD RUN PARALLEL TO THE STEAMVR VIDEO AND RECORD THE DIALOGUE FROM THE USER
#RETURNS A 1 IF ALL DIALOGUE CHECKS WERE SUCCESSFUL AND A 0 IF NOT
$venv = Join-Path $root "speech_venv\Scripts\python.exe"
$Script_File_Path = Join-Path $root "Speech_Checker.py"
$Video_Transcription = Start-Job -ScriptBlock {
    param($jvenv, $jScript_File_Path, $jvid_name)
    & $jvenv $jScript_File_Path $jvid_name
} -ArgumentList @($venv, $Script_File_Path, $name)

#UNCOMMENT -----------------
$Time_Watched = Measure-Command {
   Start-Process -FilePath $File_Path -Wait
}
$Time_Watched = $Time_Watched.TotalMinutes

#COMMENT ----------------
#$Time_Watched = 25

$Transcription_Result = Receive-Job $Video_Transcription
Stop-Job $Video_Transcription
Remove-Job $Video_Transcription 


#UNCOMMENT -------------
#Check if the user has watched the full video
$Shell = New-Object -COMObject Shell.Application
$Folder = Split-Path (Resolve-Path -Path $File_Path)
$Folder = $Folder + '\'
$File = Split-Path $File_Path -Leaf
$Shell_Folder = $Shell.Namespace($Folder)
$Shell_File = $Shell_Folder.ParseName($File)
$Video_Length = [timespan]::Parse($Shell_Folder.GetDetailsOf($Shell_File, 27)).TotalMinutes

#COMMENT -----------
#$Video_Length = 25


if ($Time_Watched -ge ($Video_Length * 0.9)) {
    #Record time of completion
    $Completion_Date = Get-Date -UFormat "%m/%d/%Y %R"

    #Record the completion status code (2 for speech and video, 1 for just video, 0 for neither)
    if ($Transcription_Result) {
        if ($Transcription_Result[-1] -ge 0.5) {
            $completion_status_code = 2
        }
        else {
            $completion_status_code = 1
        }
    }
    else {
        $completion_status_code = 1
    }

    #LOCAL STORAGE START ----------------------
    #LOCAL STORAGE END ------------------

    #$EncryptionKeyData = Get-Content "C:\Users\svfr_\OneDrive\Documents\360 Videos\360 Videos Tracking Program\Encryption.key"
    #ALL THE ENCRYPTION STUFF
    #$EncryptionKeyData = Get-Content "..\Encryption.key"
    #$Password = ConvertTo-SecureString $ID -AsPlainText -Force
    #THE ENCRYPTED ID
    #$EP = ConvertFrom-SecureString $Password -Key $EncryptionKeyData

    #$score = [double]$Transcription_Result[-1]
    #$grade = ($score * 100).ToString() + "%"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")

    #SAVE TO LOCAL STORAGE USING NEW PYTHON SCRIPT
    # $save_script_path = Join-Path $root "Save_To_CSV.py"
    # & $venv $save_script_path $ID $video_num $completion_status_code $Completion_Date

    $body = @"
    {
    `"STUDENT ID`": `"$ID`",
    `"VIDEO NUMBER`": `"$video_num`",
    `"COMPLETION STATUS`": `"$completion_status_code`",
    `"DATE`": `"$Completion_Date`"
    }
"@

    $response = Invoke-RestMethod 'http://3.23.113.24:8000/receive_video' -Method 'POST' -Headers $headers -Body $body
    $response | ConvertTo-Json
}

#Read-Host -Prompt "Press Enter to exit"