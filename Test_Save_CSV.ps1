$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$venv = Join-Path $root "speech_venv\Scripts\python.exe"

$name = $args[0]
$Student_Name = $args[1]
$ID = 2570404
$Video_num = 1
$Completion_Date = Get-Date -UFormat "%m/%d/%Y %R"
$completion_status_code = 1
$Transcription_Result = 0.33

$score = [double]$Transcription_Result[-1]
$grade = ($score * 100).ToString() + "%"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

#SAVE TO LOCAL STORAGE USING NEW PYTHON SCRIPT
$save_script_path = Join-Path $root "Save_To_CSV.py"
& $venv $save_script_path $ID $Video_num $grade $completion_status_code $Completion_Date