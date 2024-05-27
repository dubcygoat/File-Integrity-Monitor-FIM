Import-Module PSSlack

$SlackwebhookURI = <Affix your slack webhook URI>


#Check for baseline file existence

function delete_if_exists(){
    $baselinefilepath = Test-Path -Path .\baseline.txt
    if ($baselinefilepath) {
 
 Remove-Item -Path .\baseline.txt
  
  }
}
#Call function
delete_if_exists

#Function to calculate file hash
function calculate_hash_value($filepath){
Get-FileHash -Path $filepath -Algorithm SHA256
return }


#Function to dynamically select the folder to monitor
 Function Get-Folder($initialDirectory=""){
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
 }

 # Function to write log entries
function Write-Log {
    param (
        [string]$logFilePath,
        [Parameter(Mandatory = $false)] [ValidateSet("INFO","WARNING","ERROR")] [string] $level = "WARNING",
        [Parameter(Mandatory = $true)] [string]$message
        )
     $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$level - $timestamp - $message" | Out-File -FilePath $logFilePath -Append
}

# Function to get the last modified user of a file
function Get-LastModifiedBy {
    param (
        [string]$Filepath
    )
    $acl = Get-Acl -Path $Filepath
    $lastAccessedUser = " "

    foreach ($access in $acl.Access) {
        if ($access.FileSystemRights -match "FullControl") {
            $lastAccessedUser = $access.IdentityReference.Value
            break
        }
    }

    return $lastAccessedUser
}

 #variable to store selected folder path
$a = Get-Folder

if($null -ne $a){

    #Log file path
    $logFilePath = .\log.txt
       
    # Variable to Store folder's file
    $files = Get-ChildItem -Path $a -Recurse -File


     #Calculate hash for all items in the folder
     foreach($f in $files){
     $hashes = calculate_hash_value $f.FullName
     $lastModifiedBy = Get-LastModifiedBy -a $f.FullName
    "$($hashes.Path) |$($hashes.Hash)" | Out-File -FilePath .\baseline.txt  -Append
     }

    #Create an empty dictionary to store hashes
    $load_hashes = @{}

   #load hashes from baseline.txt and store in a dictionary
   $path_hashes= Get-Content -Path .\baseline.txt 
   
   #Proper way to load hashes
    foreach ($load in $path_hashes) {
        $parts = $load.Split('|')
        $load_hashes[$parts[0].Trim()] = $parts[1].Trim()
    }

   # Monitor the folder for changes
   $files = Get-ChildItem -Path $a -Recurse -File

    # Recalculate hashes for current files and compare with baseline
    while ($true){
    Start-Sleep -Seconds 30 #Check every 30 seconds, you can change this value to your desired value

          foreach ($f in $files) {
          $hashes = calculate_hash_value $f.FullName
        if ($load_hashes.ContainsKey($hashes.Path)) {
            if ($load_hashes[$hashes.Path] -eq $hashes.Hash) {
                Write-Host "File $($hashes.Path) has not been changed or modified!" -ForegroundColor Yellow
            } else {
                $message = "File $($hashes.Path) has been modified by $($lastModifiedBy)"
                Write-Host $message -ForegroundColor Red -BackgroundColor Gray
                Write-Log -logFilePath $logFilePath -message $message
                Send-SlackMessage -Uri $SlackwebhookURI -Text  $message
            }
        } else {
            Write-Host "File $($hashes.Path) has been created!" -ForegroundColor Green
        }
    }
}
       }



