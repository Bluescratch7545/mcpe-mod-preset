function mcpe {
	param (
		[Parameter(Position=0, Mandatory=$true)]
		[string]$Action,

		[Parameter(Position=1)]
		[string]$PathOrName = ".",

		[Parameter(Position=2)]
		[string]$Name = "mcpe-mod-preset"
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

			git clone https://github.com/Bluescratch7545/preset $TargetPath

			Write-Host "Renaming references to $Name"

			$oldName = "mcpe-mod-preset"
			Get-ChildItem $TargetPath -Recurse -File |
				Where-Object {$_.Extension -notin ".png", ".jpg", ".zip" } |
				ForEach-Object {
					$content = Get-Content $_.FullName -Raw
					if ($content -match $oldName) {
						$content -replace $oldName, $Name | Set-Content $_.FullName
					}
				}

			Write-Host "Renaming inner folders to $Name _RP/BP"

			$innerFolders = Get-ChildItem $TargetPath -Directory

			if ($innerFolders -and $innerFolders.Count -gt 0) {
			    $first = $innerFolders[0].Name
			    $oldPrefix = ($first -split "_")[0]

			    Get-ChildItem $TargetPath -Recurse -Directory |
			        Sort-Object FullName -Descending |
 			       	ForEach-Object {
 			           	$suffix = $_.Name -replace "^$oldPrefix", ""
			            $newName = "$Name$suffix"
			            if ($newName -ne $_.Name) {
			                Rename-Item -Path $_.FullName -NewName $newName
			            }
 			       }
			}

			Write-Host "Repo cloned to: $TargetPath" -ForegroundColor Cyan
			Write-Host "Happy Modding!" -ForegroundColor Green
		}
		"delete" {
            $RootPath = $PathOrName

            if (-not (Test-Path $RootPath)) {
                Write-Host "Folder specified at $RootPath doesn't exist." -ForegroundColor Red
                return
            }

            Get-ChildItem $RootPath -Recurse -Filter manifest.json |
                ForEach-Object {
                    $relative = $_.FullName.Substring($RootPath.Length).TrimStart('\','/')
                    $depth = ($relative -split '[\\/]').Count - 1

                    if ($depth -eq 1) {
                        $folder = $_.Directory.FullName
                        Write-Host "Deleting $folder" -ForegroundColor Yellow
                        try {
                            Remove-Item $folder -Recurse -Force
							Write-Host "Deleted folder at the path: $_"
                        } catch {
                            Write-Host "Failed to delete folder at $_" -ForegroundColor Red
                        }
                    }
                }
        }

		"info" {
			Write-Host "Usage:" -ForegroundColor Yellow
			Write-Host "`mcpe new <path> [name]` to create a new mod" -ForegroundColor Green
			Write-Host "`mcpe delete <path>` to delete a folder" -ForegroundColor Green
			Write-Host "Note: <> means a mandatory string and [] means a optional string"
		}

		default {
            Write-Host "Unknown action '$Action'. Use `mcpe info` for usage instructions." -ForegroundColor Red
        }
	}
}
