Param(
    [string]$projectName,
    [string]$curlPath,
    [string]$documentationApiUrl,
    [string]$documentationApiKey
)

Copy-Item $PSScriptRoot\README.md $PSScriptRoot\docs\index.md

# Generating documentation to generated_docs folder
cd docs
& ./docfx.ps1
cd ..
$docsFolder = "$PSScriptRoot/generated_docs"

# Getting version number from NuGet package
# TODO
$zipDestination = "$PSScriptRoot/docs.zip"

# Packaging the library as Zip archive
If (Test-Path $zipDestination){
	Remove-Item $zipDestination
}
# Importing the .Net 4.5 System.IO.Compression.FileSystem assembly (It contains the ZipArchive class)
Add-Type -AssemblyName "System.IO.Compression.FileSystem"
[IO.Compression.ZipFile]::CreateFromDirectory($docsFolder, $zipDestination)

# Get version from NuGet package
$nuGetPackageName = (Get-ChildItem -Path "$PSScriptRoot/src/$projectName/bin/Release" -Filter "$projectName.*.nupkg").Name
$packageVersion = $nuGetPackageName.Replace("$projectName.", "").Replace(".nupkg", "")

# Uploading documentation to WebDocu
# TODO
$curlArguments = @(("-F ""ApiKey=" + $documentationApiKey + """"),`
                    ("-F ""ProjectPackage=@\""" + $zipDestination + "\"""""),`
                    ("-F ""Version=" + $packageVersion + """"),`
                    ($documentationApiUrl))
$curlArguments

$curlProcess = Start-Process -FilePath $curlPath -ArgumentList $curlArguments -Wait -PassThru -NoNewWindow
if ($curlProcess.ExitCode -ne 0) {
    "Exiting due to curl process having returned an error, exit code: " + $curlProcess.ExitCode
    exit $curlProcess.ExitCode
}