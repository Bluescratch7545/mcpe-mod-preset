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

			git clone https://github.com/Bluescratch7545/mcpe-mod-preset $TargetPath
			Write-Host "Repo cloned to: $TargetPath" -ForegroundColor Cyan
			Write-Host "Happy Modding!" -ForegroundColor Green
		}
		"delete" {
			$FolderToDelete = $PathOrName

			if (-not (Test-Path $FolderToDelete)) {
				Write-Host "Folder specified at $FolderToDelete doesnt exist. Please check the spelling or if you want to create a new mod do `"mcpe new <path> [name (optional)]`""
				return
			}

			try {
				Remove-Item -Path $FolderToDelete -Recurse -Force
				Write-Host "Folder deleted at $FolderToDelete" -ForegroundColor Green
			} catch {
				Write-Host "Failed to delete folder at $_" -ForegroundColor Red
			}
		}

		"info" {
			Write-Host "Usage:" -ForegroundColor Yellow
			Write-Host "`"mcpe new <path> [name]`" to create a new mod" -ForegroundColor Green
			Write-Host "`"mcpe delete <path>`" to delete a folder" -ForegroundColor Green
			Write-Information "Note: <> means a mandatory string and () means a optional string"
		}
	}
}
