$version     = '%build.version%-B%build.date%'
$packageName = 'haskell-dev-ide-head'
$url         = '%deploy.url.32bit%'
$url64       = '%deploy.url.64bit%'

$binRoot         = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageFullName = Join-Path $binRoot ($packageName + '-' + $version)
$is64 = (Get-OSArchitectureWidth 64)  -and $env:chocolateyForceX86 -ne 'true'

Install-ChocolateyZipPackage `
  -PackageName $packageName `
  -UnzipLocation $packageFullName `
  -Url $url -ChecksumType sha256 -Checksum %deploy.sha256.32bit% `
  -Url64bit $url64 -ChecksumType64 sha256 -Checksum64 %deploy.sha256.64bit%

$cabal = "cabal.exe"

  function Find-Entry {
    param( [string] $app )
    Get-Command -ErrorAction SilentlyContinue $app `
      | Select-Object -first 1 `
      | ForEach-Object { Split-Path $_.Path -Parent }
}

Function Execute-Command {
  param( [string] $commandTitle
       , [string] $commandPath
       , [string] $commandArguments
       )
  Try {
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $commandPath
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $commandArguments
    $pinfo.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $pinfo.CreateNoWindow = $true
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    [pscustomobject]@{
        commandTitle = $commandTitle
        stdout = $p.StandardOutput.ReadToEnd()
        stderr = $p.StandardError.ReadToEnd()
        ExitCode = $p.ExitCode
    }
    $p.WaitForExit()
  }
  Catch {
     exit
  }
}

function ReadCabal-Config {
  param( [string] $key )

  $prog = "$cabal"
  $cmd  = "user-config diff -a ${key}:"

  $proc = Execute-Command "Reading cabal config key '${key}'." $prog $cmd

  if ($proc.ExitCode -ne 0) {
    Write-Error $proc.stdout
    Write-Error $proc.stderr
    throw ("Could not read cabal configuration key '${key}'.")
  }

  $option = [System.StringSplitOptions]::RemoveEmptyEntries
  $procout = $proc.stdout.Split([Environment]::NewLine) | Select-String "- ${key}" | Select-Object -First 1
  if (!$procout) {
    Write-Debug "No Cabal config for ${key}"
    return {@()}.Invoke()
  } else {
    $value = $procout.ToString().Split(@(':'), 2, $option)[1].ToString()
    $value = $value.Split([Environment]::NewLine)[0].Trim()
    Write-Debug "Read Cabal config ${key}: ${value}"
    return {$value.Split(@(';'), $option)}.Invoke()
  }
}

function UpdateCabal-Config {
  param( [string] $key
       , [string[]] $values
       )

  if ((!$values) -or ($values.Count -eq 0)) {
    $values = ""
  }
  $prog = "$cabal"
  $value = [String]::Join(";", $values)
  $cmd  = "user-config update -a `"${key}: $value`""

  $proc = Execute-Command "Update cabal config key '${key}'." $prog $cmd

  if ($proc.ExitCode -ne 0) {
    Write-Error $proc.stdout
    Write-Error $proc.stderr
    throw ("Could not update cabal configuration key '${key}'.")
  }

  Write-Debug "Wrote Cabal config ${key}: ${value}"
}

function Configure-Cabal {
  param()

  $ErrorActionPreference = 'Stop'
  UpdateCabal-Config "hoogle" "True"

  Write-Host "Updated cabal configuration."
}

function Install-Ext {
  param( [string] $key )
  Write-Debug "Installing vscode extension $key"
  vscode --install-extension $key
}

function Configure-Extensions {
  param()

}

refreshenv
# Now execute cabal configuration updates
Configure-Cabal
Install-Ext 'alanz.vscode-hie-server'
Install-Ext 'justusadam.language-haskell'
Install-Ext 'phoityne.phoityne-vscode'
Install-Ext 'jcanero.hoogle-vscode'
Install-Ext 'aaron-bond.better-comments'
Install-Ext 'alefragnani.Bookmarks'
Install-Ext 'eamodio.gitlens'
Install-Ext 'spywhere.guides'
Install-Ext 'emmanuelbeziat.vscode-great-icons'
Install-Ext 'CoenraadS.bracket-pair-colorizer-2'
Install-Ext 'byi8220.indented-block-highlighting'
Install-Ext 'oderwat.indent-rainbow'
Configure-Extensions