# Copyright 2026 VB contributors. SPDX-License-Identifier: Apache-2.0
param([string]$PartsDirectory,[string]$Destination,[switch]$VerifyOnly)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$manifest=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'parts.json') -Raw | ConvertFrom-Json
if($manifest.format -ne 'vb-split-kit/1' -or $manifest.partBytes -ne 24000000){throw 'Unrecognized part manifest.'}
if($manifest.archiveName -notmatch '^[A-Za-z0-9_-][A-Za-z0-9._-]*\.zip$' -or $manifest.kitRoot -notmatch '^VB-JA21-[0-9.]+-Kit$'){throw 'Invalid archive identity.'}
if(!$PartsDirectory){
 $PartsDirectory=$PSScriptRoot
 if(!(Test-Path -LiteralPath (Join-Path $PartsDirectory $manifest.parts[0].file))){$parent=Split-Path -Parent $PSScriptRoot;if(Test-Path -LiteralPath (Join-Path $parent $manifest.parts[0].file)){$PartsDirectory=$parent}}
}
$PartsDirectory=[IO.Path]::GetFullPath($PartsDirectory)
if(!$Destination){$Destination=$PartsDirectory}
$Destination=[IO.Path]::GetFullPath($Destination)
if(!(Test-Path -LiteralPath $Destination -PathType Container)){throw 'Choose an existing destination folder.'}
function Hash([string]$file){
 $hashStream=[IO.File]::OpenRead($file)
 $algorithm=[Security.Cryptography.SHA256]::Create()
 try{return [BitConverter]::ToString($algorithm.ComputeHash($hashStream)).Replace('-','').ToLowerInvariant()}
 finally{$hashStream.Dispose();$algorithm.Dispose()}
}
$total=[long]0;$index=0
if($manifest.parts.Count -lt 1 -or $manifest.parts.Count -gt 999){throw 'Invalid part count.'}
foreach($part in $manifest.parts){
 $index++;$expected=$manifest.archiveName+'.'+$index.ToString('000')
 if($part.file -cne $expected -or $part.sha256 -notmatch '^[0-9a-f]{64}$' -or $part.bytes -le 0 -or $part.bytes -gt 24000000){throw 'Invalid part entry.'}
 if($index -lt $manifest.parts.Count -and $part.bytes -ne 24000000){throw 'Incomplete part layout.'}
 $file=Join-Path $PartsDirectory $part.file
 Write-Host ('Checking part '+$index+' of '+$manifest.parts.Count+'...')
 if(!(Test-Path -LiteralPath $file -PathType Leaf)){throw ('Missing '+$part.file+'. Download all parts into the same folder.')}
 if((Get-Item -LiteralPath $file).Length -ne $part.bytes -or (Hash $file) -ne $part.sha256){throw ('Part '+$index+' is incomplete or changed. Download that part again.')}
 $total+=[long]$part.bytes
}
if($total -ne $manifest.archiveBytes -or $manifest.archiveSha256 -notmatch '^[0-9a-f]{64}$'){throw 'Archive size or hash is invalid.'}
if($VerifyOnly){Write-Host 'All parts verified.';exit 0}
$archive=Join-Path $Destination $manifest.archiveName
if(Test-Path -LiteralPath $archive){if((Hash $archive) -ne $manifest.archiveSha256){throw 'A different ZIP already exists at the destination. Use another folder.'}}
else {
 $temporary=Join-Path $Destination ('.vb-join-'+[guid]::NewGuid().ToString('N')+'.tmp')
 Write-Host 'Reassembling the ZIP...'
 $stream=[IO.File]::Open($temporary,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
 try {foreach($part in $manifest.parts){$partStream=[IO.File]::OpenRead((Join-Path $PartsDirectory $part.file));try{$partStream.CopyTo($stream)}finally{$partStream.Dispose()}}} finally {$stream.Dispose()}
 if((Hash $temporary) -ne $manifest.archiveSha256){throw ('ZIP verification failed. Partial file retained at '+$temporary)}
 [IO.File]::Move($temporary,$archive)
}
$ready=Join-Path $Destination ($manifest.kitRoot+'-Ready')
if(Test-Path -LiteralPath $ready){Write-Host ('Verified ZIP is ready. Existing extracted folder was kept: '+$ready);exit 0}
$unpack=Join-Path $Destination ('.vb-unpack-'+[guid]::NewGuid().ToString('N'))
$zip=[IO.Compression.ZipFile]::OpenRead($archive)
try {
 if($zip.Entries.Count -gt 100000){throw 'Archive has too many entries.'}
 $expanded=[long]0;$names=New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
 foreach($entry in $zip.Entries){
  $name=$entry.FullName
  $segments=$name.Split('/')
  if($name.Contains('\') -or $name.Contains(':') -or !$name.StartsWith($manifest.kitRoot+'/',[StringComparison]::Ordinal) -or ($segments -contains '..') -or ($segments -contains '.')){throw 'Unsafe archive path.'}
  foreach($segment in $name.TrimEnd('/').Split('/')){if(!$segment -or $segment -match '[\x00-\x1f]' -or $segment.EndsWith('.') -or $segment.EndsWith(' ')){throw 'Unsafe path segment.'}}
  if((($entry.ExternalAttributes -shr 16) -band 0xF000) -eq 0xA000){throw 'Linked archive entries are not supported.'}
  $resolved=[IO.Path]::GetFullPath((Join-Path $unpack $name))
  if(!$resolved.StartsWith($unpack+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase) -or !$names.Add($resolved)){throw 'Duplicate or escaping archive path.'}
  $expanded+=$entry.Length
  if($expanded -gt 1500000000){throw 'Archive exceeds the supported expanded size.'}
 }
} finally {$zip.Dispose()}
$drive=New-Object IO.DriveInfo ([IO.Path]::GetPathRoot($Destination))
if($drive.AvailableFreeSpace -lt ($expanded+100000000)){throw 'Not enough free space to extract the kit.'}
Write-Host 'Extracting the verified kit...'
[IO.Compression.ZipFile]::ExtractToDirectory($archive,$unpack)
# Both resolved paths are direct children of the selected destination.
$unpackParent=Split-Path -Parent ([IO.Path]::GetFullPath($unpack));$readyParent=Split-Path -Parent ([IO.Path]::GetFullPath($ready))
if(![string]::Equals($unpackParent,$Destination,[StringComparison]::OrdinalIgnoreCase) -or ![string]::Equals($readyParent,$Destination,[StringComparison]::OrdinalIgnoreCase)){throw 'Destination check failed.'}
[IO.Directory]::Move($unpack,$ready)
Write-Host ''
Write-Host ('Ready: '+(Join-Path $ready $manifest.kitRoot))
Write-Host 'Open that folder, then double-click Run VB.cmd or Compile VB.cmd.'
