﻿import-module au

function global:au_BeforeUpdate { Get-RemoteFiles -NoSuffix -Purge }

function global:au_GetLatest {	
	$github_repository = "leanprover/lean"
	$releases = "https://github.com/" + $github_repository + "/releases/latest"
	$regex   = "lean-(?<Version>[\d\.]+)-windows.zip$"

	$url = (Invoke-WebRequest -Uri $releases -UseBasicParsing).links | ? href -match $regex
	
	return @{
		Version = $matches.Version
		URL32 = "https://github.com" + $url.href
	}
}

function global:au_SearchReplace {
    @{
       "legal\VERIFICATION.txt"  = @{
       		"(?i)(x32: ).*"             = "`${1}$($Latest.URL32)"
            "(?i)(x64: ).*"             = "`${1}$($Latest.URL64)"
            "(?i)(checksum type:\s+).*" = "`${1}$($Latest.ChecksumType64)"
            "(?i)(checksum32:).*"       = "`${1} $($Latest.Checksum32)"
            "(?i)(checksum64:).*"       = "`${1} $($Latest.Checksum64)"
        }

        "tools\chocolateyinstall.ps1" = @{        
          "(?i)(^\s*file\s*=\s*`"[$]toolsDir\\)(.*)`""   = "`$1$($Latest.FileName32)`""
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') { # run the update only if script is not sourced
    update -ChecksumFor none
}