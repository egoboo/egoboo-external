# @brief Script that packages all extenal dependencies (transitive) into a single zip file.
# @detail The script expects the parameters
# - configuration (which must be 'Release' or 'Debug') and
# - the parameter platform (which must be 'x86' or 'x64).
# - a non-empty suffix.
# The resulting zip file contains all required files and is named 'egoboo-exernal-${configuration}-${platform}.zip'.
# @author Michael Heilmann

# Define parameter variables.
param([string]$configuration, [string]$platform, [string]$suffix)

# Validate parameter variables.
if (!$PSBoundParameters.ContainsKey('configuration')) {
	Write-Host 'configuration not specified!'
}
if (!$PSBoundParameters.ContainsKey('platform')) {
	Write-Host 'platform not specified!'
}
if (!$PSBoundParameters.ContainsKey('suffix')) {
	Write-Host 'suffix not specified!'
}

# Log the parameter variable values.
Write-Host "Creating distribution for"
Write-Host "- configuration = " $configuration
Write-Host "- platform      = " $platform
Write-Host "- suffix        = " $suffix

# Ensure the distribution directory exists and is empty.
$distributionDirectory = ".\distribution\${configuration}\${platform}"
If (Test-Path ${distributionDirectory}){
	Remove-Item -Recurse ${distributionDirectory}
}
new-item -Force -ItemType Directory -path $distributionDirectory

# Assemble list of files to distribute.

# If the platform name has to be modified for SDL.
$platformSdl = "${platform}"

$files = @()

# Add he files of SDL mixer.
$files += ".\SDL2_mixer-2.0.0\VisualC\external\lib\${platformSdl}\libFLAC-8.dll"
$files += ".\SDL2_mixer-2.0.0\VisualC\external\lib\${platformSdl}\libFLAC-8.dll"
# libmikmod-2.dll is missing in platform 'x86'.
if ($platform -eq 'x64') {
	$files += ".\SDL2_mixer-2.0.0\VisualC\external\lib\${platformSdl}\libmikmod-2.dll"
}
$files += ".\SDL2_mixer-2.0.0\VisualC\external\lib\${platformSdl}\libogg-0.dll"
$files += ".\SDL2_mixer-2.0.0\VisualC\external\lib\${platformSdl}\libvorbis-0.dll"
$files += ".\SDL2_mixer-2.0.0\VisualC\external\lib\${platformSdl}\libvorbisfile-3.dll"
$files += ".\SDL2_mixer-2.0.0\VisualC\external\lib\${platformSdl}\smpeg2.dll"

# Add files of SDL image.
$files += ".\SDL2_image-2.0.0\VisualC\external\lib\${platformSdl}\libjpeg-9.dll"
$files += ".\SDL2_image-2.0.0\VisualC\external\lib\${platformSdl}\libpng16-16.dll"
$files += ".\SDL2_image-2.0.0\VisualC\external\lib\${platformSdl}\libtiff-5.dll"
$files += ".\SDL2_image-2.0.0\VisualC\external\lib\${platformSdl}\libwebp-4.dll"

# Add files of SDL ttf.
$files += ".\SDL2_ttf-2.0.12\VisualC\external\lib\${platformSdl}\libfreetype-6.dll"
$files += ".\SDL2_ttf-2.0.12\VisualC\external\lib\${platformSdl}\zlib1.dll"

# Do copy files to distribution directory.
foreach ($file in $files) {
	Copy-Item -Path ${file} -Destination ${distributionDirectory}
}

# Create a zip file with the contents of the distribution directory.
$zipFile = "egoboo-external-$($configuration.ToLower())-${platform}-${suffix}.zip"

# Delete any existing zip file of the same name.
If (Test-Path ${zipFile}){
	Remove-Item ${zipFile}
}

# Create the zip file.
Compress-Archive -Path .\distribution\${configuration}\${platform}\* -DestinationPath ${zipFile}
