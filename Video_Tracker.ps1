#UPDATED 6/28/2026

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
    # $Csv_Path = Join-Path $root "powershell_test_output.csv"

    # #Check if CSV file exists, if not create it and add the video names as headers
    # if (-not (Test-Path $Csv_Path)) {
    #     $videoFiles = Get-ChildItem -Path '..\..\..\360 Videos' -Name

    #     $headers = @(
    #         'STUDENT NAME'
    #         'STUDENT ID'
    #     ) + ($videoFiles | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) })

    #     $headers -join ',' | Out-File -FilePath $Csv_Path -Encoding utf8
    # }

    # #If the user has watched the full video, log it to the csv file
    # $Csv = @(Import-Csv $Csv_Path)
    # $Student_Exists = $false
    # #Write-Output $row.'STUDENT NAME'
    # #Write-Output $Student_Name
    # $File_Name = $Files[$($Video-1)] -replace '\..*'
    # $File_Name = $Files[$($Video-1)].Substring(0, $($Files[$($Video-1)].Length) - 4)
    # $File_Name = $Files[$name].Substring(0, $($Files[$name].Length) - 4)
    # $File_Name = $name.Substring(0, $name.Length-4)
    # #Write-Output $File_Name
    # $existingRow = $Csv | Where-Object { $_.'STUDENT ID'.ToString().Trim() -eq $ID.ToString().Trim() } | Select-Object -First 1

    # #If student already exists in the file, log the video they watched as '1' for completed
    # # foreach($row in $Csv) {
    # #    if ($row.'STUDENT ID' -eq $ID) {
    # #        $Student_Exists = $true
    # #        $row.$($File_Name) = $completion_status_code
    # #        #Write-Output $row
    # #    }
    # # }

    # if ($existingRow) {
    #     $existingRow.$File_Name = $completion_status_code
    #     $Csv | Export-Csv -Path $Csv_Path -NoTypeInformation -Encoding UTF8
    # }

    # else {
    #     $headerLine = Get-Content $Csv_Path -TotalCount 1 -ErrorAction SilentlyContinue
    #     if ($headerLine) {
    #         $propNames = $headerLine -split ',' | ForEach-Object { $_.Trim() }
    #     }
    #     else {
    #         $propNames = @('STUDENT NAME', 'STUDENT ID') + (Get-ChildItem -Path '..\..\..\360 Videos' -Name | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) })
    #     }

    #     $new = [ordered]@{}
    #     foreach ($prop in $propNames) { $new[$prop] = 0 }

    #     $new['STUDENT NAME'] = $Student_Name
    #     $new['STUDENT ID'] = $ID
    #     $new[$File_Name] = $completion_status_code

    #     [pscustomobject]$new | Export-Csv -Path $Csv_Path -NoTypeInformation -Append -Encoding UTF8
    # }
    #If the student does not exist yet, add their entry into the CSV file
    # if (-not $Student_Exists) {
            #    $New_Row = $Csv[1]
            #    #Create a clone of the header row and set each column to a value of '0'
            #    foreach ($col in $Csv[1].PSObject.Properties) {
            #        #Add-Content C:\Users\svfr_\OneDrive\Documents\powershell_test_output.csv "$Student_Name, $ID"
            #        $New_Row.$($col.Name) = 0
            #    }
            #    $New_Row.'STUDENT NAME' = $Student_Name
            #    $New_Row.'STUDENT ID' = $ID
            #    $New_Row.$($File_Name) = $completion_status_code
            #    #Write-Output $New_Row
            #    $New_Row | Export-csv -path $Csv_Path -Append
    
    #   Read header names from the file (robust even when rows exist)
    #     $headerLine = Get-Content $Csv_Path -TotalCount 1 -ErrorAction SilentlyContinue
    #     if ($headerLine) {
    #         $propNames = $headerLine -split ',' | ForEach-Object { $_.Trim() }
    #     }
    #     else {
    #         $propNames = @(
    #             'STUDENT NAME'
    #             'STUDENT ID'
    #         ) + (Get-ChildItem -Path '..\..\..\360 Videos' -Name | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) })
    #     }

    #     # Build new row: initialize all columns to 0
    #     $new = [ordered]@{}
    #     foreach ($prop in $propNames) { $new[$prop] = 0 }

    #     # Set student info and current video
    #     $new['STUDENT NAME'] = $Student_Name
    #     $new['STUDENT ID']   = $ID
    #     $new[$File_Name]     = $completion_status_code

    #     # Convert to PSObject and append
    #     $newObj = New-Object PSObject -Property $new
    #     $newObj | Export-Csv -Path $Csv_Path -NoTypeInformation -Append -Encoding UTF8
    # }
    # else {
    #    $Csv | Export-csv -Path $Csv_Path -NoTypeInformation
    # }
    
    #LOCAL STORAGE END ------------------

    #$EncryptionKeyData = Get-Content "C:\Users\svfr_\OneDrive\Documents\360 Videos\360 Videos Tracking Program\Encryption.key"
    #ALL THE ENCRYPTION STUFF
    #$EncryptionKeyData = Get-Content "..\Encryption.key"
    #$Password = ConvertTo-SecureString $ID -AsPlainText -Force
    #THE ENCRYPTED ID
    #$EP = ConvertFrom-SecureString $Password -Key $EncryptionKeyData

    $score = [double]$Transcription_Result[-1]
    $grade = ($score * 100).ToString() + "%"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")

    #SAVE TO LOCAL STORAGE USING NEW PYTHON SCRIPT
    $save_script_path = Join-Path $root "Save_To_CSV.py"
    & $venv $save_script_path $ID $video_num $grade $completion_status_code $Completion_Date

    $body = @"
    {
    `"id`": `"$ID`",
    `"videoNumber`": `"$video_num`",
    `"status`": `"$completion_status_code`",
    `"date`": `"$Completion_Date`",
    `"grade`": `"$grade`"
    }
"@

    $response = Invoke-RestMethod 'http://150.136.241.0:5000/uploadVideoResults' -Method 'POST' -Headers $headers -Body $body
    $response | ConvertTo-Json
}


#Remove-Job $Video_Transcription

#Read-Host -Prompt "Press Enter to exit"
#Remove all variables at the end of the process
#Remove-Variable Quit
#Remove-Variable Student_Name
#Remove-Variable ID
#Remove-Variable i
#Remove-Variable Video
#Remove-Variable Valid_Selection
#Remove-Variable Files
#Remove-Variable File
#Remove-Variable File_Path
#Remove-Variable Shell
#Remove-Variable Folder
#Remove-Variable Shell_Folder
#Remove-Variable Shell_File
#Remove-Variable Video_Length
#Remove-Variable Time_Watched
#Remove-Variable Csv
#Remove-Variable Student_Exists
#Remove-Variable row
#Remove-Variable File_Name
#Remove-Variable New_Row