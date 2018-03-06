# The background
I'm working on a project which uses the Entity Framework. It started with migrations. Most of the time right after running the `Add-Migration <name>` command I've been starting debugging the solution and when the DB connection established the exeption occured. So what I've been doing was to stop debugging, running the `Update-Database` command and again, start debugging. I was patient for a very long time, but it seems I'm done. :) So here it is. In the `DatabaseManagementHelpers.ps1` file you will find the most frustraiting commands I've encountered in my work with EF.

# How to install
* Download the file
* Add it to the project in which you keep your Migrations
* Open the Package Manager Console and select your project from the previous step as the default one
* Run the following command: ```Import-Module (Join-Path (Split-Path -Path (Get-Project).FileName) DatabaseManagementHelpers.ps1) -Force```
* That's all

# How it works
It is project based, so as long as you want to run any of the functions you have to select your project in which you store Migrations as a default in Package Manager Console. It also assumes that you are using the default setting for migration file names - `<timestamp>_<migration-name>`. It might change in the future updates. 

# Available commands
### AddMigration \<name>
Description: Runs the Add-Migration \<name> following by the Update-Database

Usage: `AddMigration MyNewSuperMigration`

### RevertMigration
Description: Runs the `Update-Database -TargetMigration:<previous_migration>`. It does not delete any migration files

Usage: `RevertMigration`

### UpdateMigration
Description: It simply updates the most recent migration by reverting it, deleting associated files and adding the new migration with the same name

Usage: `UpdateMigration`

# Summary
I hope that someone will find it useful as I do. Feel free to use, modify or whathever you want to do with it. 
