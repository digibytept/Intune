Param
  (
    [parameter(Mandatory=$false)]
    [String[]]
    $param
  )


$installuri = "https://raw.githubusercontent.com/digibytept/Intune/main/Winget-Program/Template-applist.txt"


##Create a folder to store the lists
$AppList = "C:\ProgramData\AppList"
If (Test-Path $AppList) {
    Write-Output "$AppList exists. Skipping."
}
Else {
    Write-Output "The folder '$AppList' doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path "$AppList" -ItemType Directory
    Write-Output "The folder $AppList was successfully created."
}

$templateFilePath = "C:\ProgramData\AppList\install-apps.txt"


##Download the list
Invoke-WebRequest `
-Uri $installuri `
-OutFile $templateFilePath `
-UseBasicParsing `
-Headers @{"Cache-Control"="no-cache"}


##Find Winget Path

$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
    if ($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    }

$config

##Navigate to the Winget Path
cd $wingetpath

##Loop through app list
$apps = get-content $templateFilePath | select-object -skip 1

##Install each app
foreach ($app in $apps) {
Start-Transcript -Path "$Applist\Log\$app-install.log" -Append -Force

write-host "Installing $app"
.\winget.exe install --exact --id $app --silent --accept-package-agreements --accept-source-agreements $param

Stop-Transcript
}



##Delete the .old file to replace it with the new one
$oldpath = "C:\ProgramData\AppList\install-apps-old.txt"
If (Test-Path $oldpath) {
    remove-item $oldpath -Force
}

##Rename new to old
rename-item $templateFilePath $oldpath