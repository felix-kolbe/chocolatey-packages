﻿$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -parent $MyInvocation.MyCommand.Definition

# Remove zip files from previous versions
Remove-Item "$toolsDir\*.zip" -ErrorAction SilentlyContinue

$packageArgs = @{
  packageName	= $ENV:ChocolateyPackageName
  unzipLocation = "$toolsDir"
  file          = Get-Item -path $toolsDir\*.zip

  url			= 'https://www.pspad.com/files/pspad/pspad504en.zip'
  checksumType	= 'sha256'
  checksum		= 'e0ce0ddd24bb37ef265c233e918fb1aab2c6df65a5d3d462d0132ede7f929f43'
}

# prevent chocolatey from creating shims for supplementary executables
foreach ( $file in 'phpCB.exe', 'TiDy.exe' ) {
  New-Item -path $toolsDir -name "$file.ignore" -type File -force | Out-Null
}

Install-ChocolateyZipPackage @packageArgs

# Install start menu shortcut
$programs = [environment]::GetFolderPath([environment+specialfolder]::Programs)
$shortcutFilePath = Join-Path $programs "PSPad.lnk"
$targetPath = Join-Path $toolsDir "PSPad.exe"
Install-ChocolateyShortcut -shortcutFilePath "$shortcutFilePath" -targetPath "$targetPath"
