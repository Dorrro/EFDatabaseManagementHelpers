#
# DatabaseManagementHelpers.ps1
# To install or update please type in the Package Manager Console the following commands
# Import-Module (Join-Path (Split-Path -Path (Get-Project).FileName) DatabaseManagementHelpers.ps1) -Force
#

#
#	Usage:
#	AddMigration Example-Name
#
function AddMigration($name)
{
	Add-Migration $name

	# we'll no longer forget about updating the database!!! :)
	Update-Database
}

#
#	Usage:
#	RevertMigration
#
function RevertMigration()
{
	# get all the migration files in the Migration folder
	$migrations = (Get-ChildItem -Path (Join-Path (Split-Path -Path (Get-Project).FileName) Migrations) `
		| where {$_.Extension -eq ".cs"} `
		| where {$_.BaseName -notmatch "\.Designer$"} `
		| where {$_.BaseName -match "^\d+_"} `
		| sort CreationTime -Descending )
	
	$migrationsNames = $migrations | select BaseName

	# select the previous migration based on the creation time
	$migrationName = $migrationsNames[1].BaseName.ToString()

	Update-Database -TargetMigration:$migrationName

	# I do return the migration here in order to reuse it in the Update-Migration function
	return $migrations
}

#
#	Usage:
#	UpdateMigration
#
function UpdateMigration()
{
	$migrations = RevertMigration
	
	# the migration which we want to update is the most recent one
	$sourceMigrationFileBaseName = $migrations[0].BaseName

	# in order to properly remove the most recent migration we need to remove it from the project and not only from the file system
	$migrationsFolderFiles = (Get-Project).ProjectItems `
		| where { $_.Name -match "^Migrations$" }

	# there's only one Migration folder, therefor we cannot access it via index but directly through object properties
	$migrationInProjectFile = (($migrationsFolderFiles).ProjectItems `
		| where { $_.Name -match $sourceMigrationFileBaseName } )

	# removing migration file from project
	$migrationInProjectFile.Remove()

	# the migrations variable is lacking the *.Designer.cs and *.resx files. we need to relist the Migration folder files
	$filesToDelete = (Get-ChildItem -Path (Join-Path (Split-Path -Path (Get-Project).FileName) Migrations) `
		| where {$_.Name -match $sourceMigrationFileBaseName } `
		| sort CreationTime -Descending )

	$filesToDelete | ForEach-Object {
		Remove-Item $_.FullName
	}

	$targetMigrationName = $migrations[0].BaseName.Split("_")[1]

	Add-Migration $targetMigrationName
}
