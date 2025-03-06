# Define a function to list folders and files
function Get-FolderStructure {
    param (
        [string]$Path,
        [string]$Indent = ''
    )

    # Get directories in the current path (ignores hidden folders)
    $directories = Get-ChildItem -Path $Path -Directory -Force | Where-Object { $_.Name -notlike '.*' }

    foreach ($dir in $directories) {
        # Print the directory name
        Write-Output "$Indent/$($dir.Name)"

        # Get files in the current directory (ignores hidden files)
        $files = Get-ChildItem -Path $dir.FullName -File -Force | Where-Object { $_.Name -notlike '.*' }
        foreach ($file in $files) {
            # Print the file names under the directory
            Write-Output "$Indent  - $($file.Name)"
        }

        # Recursively check subdirectories
        Get-FolderStructure -Path $dir.FullName -Indent "$Indent  "
    }
}

# Set the current directory as base path
$basePath = Get-Location

# Start gathering the folder structure
$structure = Get-FolderStructure -Path $basePath

# Define the output file path
$outputFile = "$basePath\structure.txt"

# Save the output to a txt file
$structure | Out-File -FilePath $outputFile

Write-Host "Directory structure saved to $outputFile"
