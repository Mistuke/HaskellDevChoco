# CabalChoco
Chocolatey sources the cabal based Haskell dev environment.

This repository contains the sources for the Haskell-Dev and Haskell-Dev-IDE
Chocolatey packages.

To use these get Chocolatey https://chocolatey.org/

and then just install the version of Haskell-Dev[-IDE] you want.

    cinst haskell-dev[-ide]

for the latest version

    cinst haskell-dev[-ide] -pre

for the latest pre-release version

    cinst haskell-dev[-ide] -version 0.0.1

for  specific version, e.g. `0.0.1`

The installer will automatically pick the right bitness for your OS, but if you would
like to force it to get `x86` on `x86_64` you can:

    cinst haskell-dev[-ide] -x86

uninstalling can be done with

    cuninst haskell-dev[-ide]

If more than one version of `Haskell-Dev[-IDE]` is present then you will be presented with prompt on which version you
would like to install.

     Note: Unfortunately because of a how Chocolatey currently works, you will have
           to restart the console in order for the PATH variables to be correct.
           The current section cannot be updated. or call `refreshenv`.
