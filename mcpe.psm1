function mcpe {
	param (
		[Parameter(Position=0, Mandatory=$true)]
		[string]$Action,

		[Parameter(Position=1)]
		[string]$PathOrName = ".",

		[Parameter(Position=2)]
		[string]$Name = "mcpe-mod-preset",

		[Parameter()]
		[ValidateSet("default","full")]
		[string]$DeleteOption = "default",

		[Parameter()]
		[ValidateSet("mcpack","mcaddon")]
		[string]$BuildType = "mcaddon",

		
		[Parameter()]
		[ValidateSet("underscore", "dash")]
		[string]$SuffixStyle = "underscore"
	)

	switch ($Action.ToLower()) {
		"new" {
			if ($PathOrName -match "[:\\/]") {
				$Path = $PathOrName
			} else {
				$Path = "."
				$Name = $PathOrName
			}

			if (-not (Test-Path $Path)) {
				Write-Host "The path specified doesnt exist. Creating path: $Path"
				New-Item -ItemType Directory -Path $Path | Out-Null
			}

			$TargetPath = Join-Path $Path $Name

			if (Test-Path $TargetPath) {
				Write-Error "Target folder $TargetPath already exists!"
				return
			}

			Write-Host "Copying the repositiory of https://github.com/Bluescratch7545/preset to $TargetPath"

			Start-Sleep -Milliseconds 500
			git clone https://github.com/Bluescratch7545/preset $TargetPath

			Write-Host "Repo cloned to: $TargetPath" -ForegroundColor Cyan

			Start-Sleep -Seconds 2
			Write-Host "Renaming references to $Name"

			Start-Sleep -Seconds 2
			$oldName = "mcpe-mod-preset"
			Get-ChildItem $TargetPath -Recurse -File |
				Where-Object {$_.Extension -notin ".png", ".jpg", ".zip" } |
				ForEach-Object {
					$content = Get-Content $_.FullName -Raw
					if ($content -match $oldName) {
						$content -replace $oldName, $Name | Set-Content $_.FullName
					}
				}
			Start-Sleep -Milliseconds 500
			Write-Host "References Renamed to $Name!"

			Start-Sleep -Seconds 2
			Write-Host "Renaming inner folders to $Name _RP/BP or -rp/bp"

			if ($SuffixStyle -eq "dash") {
				$bpSuffix = "-bp"
				$rpSuffix = "-rp"
			}
			else {
				$bpSuffix = "_BP"
				$rpSuffix = "_RP"
			}

			Get-ChildItem $TargetPath -Directory |
				ForEach-Object {
					if ($_.Name -match '(?i)bp$') {
						Rename-Item $_.FullName "$Name$bpSuffix"
					}
					if ($_.Name -match '(?i)rp$') {
						Rename-Item $_.FullName "$Name$rpSuffix"
					}
				}

			Start-Sleep -Seconds 2
			Write-Host "Inner Folders Renamed to $Name$bpSuffix & $Name$rpSuffix!"

			Start-Sleep -Seconds 2
			Write-Host "Removing .git folder..."

			Start-Sleep -Milliseconds 500
			Remove-Item (Join-Path $TargetPath ".git") -Recurse -Force
			Write-Host "Complete"

			Start-Sleep -Milliseconds 500
			Write-Host "Removing README.md..."

			Start-Sleep -Milliseconds 500
			Remove-Item (Join-Path $TargetPath "README.md") -Recurse -Force
			Write-Host "Complete"

			Start-Sleep -Milliseconds 500
			Write-Host "Replacing UUIDs with new UUID v4..."

			Start-Sleep -Milliseconds 500
			Get-ChildItem $TargetPath -Recurse -File |
				Where-Object { $_.Extension -notin ".png", "jpg", ".zip" } |
				ForEach-Object {
					$content = Get-Content $_.FullName -Raw
					if ($content -match "<REPLACE WITH YOUR NEW UUID V4>") {
						$newContent = [regex]::Replace($content, "<REPLACE WITH YOUR NEW UUID V4>", { param($m) [guid]::NewGuid().ToString() })
						Set-Content $_.FullName $newContent
					}
				}
			Write-Host "UUIDs replaced succesfully"

			Start-Sleep -Seconds 1
			Write-Host "Moving to $TargetPath..."

			Start-Sleep -Seconds 2
			Set-Location $TargetPath
			Write-Host "Complete!"

			Start-Sleep -Seconds 1
			Write-Host "Opening VSCode..."
			
			Start-Sleep -Seconds 2
			if (Get-Command code -ErrorAction SilentlyContinue) {
    			code .
			} else {
			    Write-Host "VSCode not found, skipping launch." -ForegroundColor Yellow
			}

			Start-Sleep -Milliseconds 500
			Write-Host "Happy Modding!" -ForegroundColor Green
		}
		"delete" {
            $RootPath = $PathOrName

    		if (-not (Test-Path $RootPath)) {
    		    Write-Host "Folder specified at $RootPath doesn't exist." -ForegroundColor Red
    		    return
    		}
    		$manifestDirs = Get-ChildItem $RootPath -Recurse -Filter manifest.json -ErrorAction SilentlyContinue |
    		    Select-Object -ExpandProperty Directory -Unique

    		if (-not $manifestDirs) {
    		    Write-Host "No MCPE mods found in $RootPath" -ForegroundColor Yellow
    		    return
    		}

    		if ($DeleteOption -eq "full") {
        		Write-Host "⚠️  FULL DELETE MODE" -ForegroundColor Red
        		Write-Host "This will permanently delete the entire MCPE mod folder:" -ForegroundColor Yellow
        		Write-Host "  $RootPath" -ForegroundColor Cyan
        		Write-Host ""
        		$confirm = Read-Host "Type YES to continue"

				if ($confirm -ne "YES") {
        			Write-Host "Aborted." -ForegroundColor Yellow
            		return
				}

				Write-Host "Deleting entire folder: $RootPath" -ForegroundColor Red
        		Remove-Item $RootPath -Recurse -Force
        		Write-Host "Done." -ForegroundColor Green
        		return
    		}

    		$manifestDirs |
    			ForEach-Object {
        			Write-Host "Deleting $($_.FullName)" -ForegroundColor Yellow
        			Remove-Item $_.FullName -Recurse -Force
					Write-Host "Deleted $($_.FullName)"
    			}
		}

		"build" {
			$DestPath = $PathOrName

			if (-not (Test-Path $DestPath)) {
				Write-Host "Cannot find destination path: $DestPath" -ForegroundColor Yellow
				return
			}

			$mods = Get-ChildItem $DestPath -Directory |
				Where-Object {
					($_.Name -match '_(BP|RP)$') -and (Test-Path (Join-Path $_.FullName 'manifest.json'))
				}

			if (-not $mods) {
				Write-Host "No BP/RP mods found!" -ForegroundColor Yellow
				return 
			}

			if ($BuildType -eq "mcaddon") {
				$addonName = Split-Path $DestPath -Leaf
				$zipPath = Join-Path $DestPath "$addonName.zip"
				$mcaddonPath = Join-Path $DestPath "$addonName.mcaddon"

				if (Test-Path $zipPath) { Remove-Item $zipPath }
				if (Test-Path $mcaddonPath) { Remove-Item $mcaddonPath }

				Write-Host "Building $addonName.mcaddon..." -ForegroundColor Cyan

				Compress-Archive -Path ($mods.FullName) -DestinationPath $zipPath
				Rename-Item $zipPath $mcaddonPath

				Write-Host ".MCADDON Build Complete at:" -ForegroundColor Green
				Write-Host "$mcaddonPath!" -ForegroundColor Green
				return
			}

			foreach ($mod in $mods) {
				$zipPath = "$($mod.FullName).zip"
				$mcpackPath = "$($mod.FullName).mcpack"

				if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
        		if (Test-Path $mcpackPath) { Remove-Item $mcpackPath -Force }

				Write-Host "Building: $($mod.FullName).mcpack..." -ForegroundColor Cyan

				Compress-Archive -Path "$($mod.FullName)\*" -DestinationPath $zipPath
				Rename-Item $zipPath $mcpackPath
			}
			Write-Host ".MCPACK Build Complete at:"
			Write-Host "$mcpackPath"
		}

		"info" {
			Write-Host "Usage:" -ForegroundColor Yellow
			Write-Host "`mcpe new <path> [name]` to create a new mod" -ForegroundColor Green
			Write-Host "`mcpe delete <path>` to delete the inner folders of a project, or `mcpe delete <path> -DeleteOption full to delete the whole folder" -ForegroundColor Green
			Write-Host "`mcpe uninstall` to uninstall the program"
			Write-Host "`mcpe build <destination path> -BuildType [buildtype (mcpack/mcaddon)]"
			Write-Host "Note: <> means a mandatory string and [] means a optional string" -ForegroundColor Cyan
		}

		"uninstall" {
			$modulePath = Join-Path $HOME "Documents/WindowsPowerShell/Modules/mcpe"

			Write-Host "Uninstall?"
			Write-Host "Are you sure you want to uninstall the mcpe mod preset pwshl command?"
			Write-Host ""
			$confirmUninstall = Read-Host "Type YES to continue"

			if ($confirmUninstall -ne "YES") {
				Write-Host "Uninstallation aborted"
				return
			}

			Write-Host "Uninstalling..."
			if (Test-Path $modulePath) {
    			Remove-Item $modulePath -Recurse -Force
    			Write-Host "Successfully uninstalled."
			} else {
    			Write-Host "mcpe module not found."
			}
		}

		default {
            Write-Host "Unknown action '$Action'. Use `mcpe info` for usage instructions." -ForegroundColor Red
        }
	}
}
