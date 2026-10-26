# Nord installer for Windows. In PowerShell:
#
#   irm https://raw.githubusercontent.com/paisible/nord-install/main/install.ps1 | iex
#
# Installs what the Nord harness needs (Git for Windows, Python 3, the GitHub CLI, Claude Code),
# signs you in to GitHub in the browser, then runs the Nord installer from the private
# Nord-Quantique/Nord-Context-Harness repository through that sign-in. Anything already
# installed is left alone, so running it again is safe. To try the installer from a branch of
# the harness, set $env:NORD_REF = '<branch>' first (default: main).
#
# `iex` runs this in your own PowerShell session; the script block keeps its settings and
# variables out of it, and it never calls `exit`, which would close your window.

& {
    $ErrorActionPreference = 'Stop'

    function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

    # winget changes the registry PATH, not this session's; read it back after each install.
    function Update-SessionPath {
        $env:Path = @(
            [Environment]::GetEnvironmentVariable('Path', 'Machine'),
            [Environment]::GetEnvironmentVariable('Path', 'User'),
            (Join-Path $HOME '.local\bin')
        ) -join ';'
    }

    function Install-Package($id) {
        Write-Host "Installing $id"
        winget install -e --id $id --source winget --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) { throw "winget could not install $id (exit $LASTEXITCODE)" }
        Update-SessionPath
    }

    if (-not (Have winget)) {
        throw 'winget is missing: install "App Installer" from the Microsoft Store, then run this again.'
    }

    $bash = Join-Path $env:ProgramFiles 'Git\bin\bash.exe'
    if (-not (Test-Path $bash)) { Install-Package 'Git.Git' }

    # `py` is the launcher a real Python installs; `python` alone may be the Microsoft Store stub.
    if (-not (Have py)) { Install-Package 'Python.Python.3.13' }
    $python = & py -3 -c 'import sys; print(sys.executable)'
    if ($LASTEXITCODE -ne 0) { throw 'Python 3 is installed but `py -3` does not run.' }
    $env:Path = (Split-Path $python) + ';' + $env:Path

    if (-not (Have gh)) { Install-Package 'GitHub.cli' }

    # Claude's installer puts claude.exe in ~\.local\bin but leaves that folder off PATH, so look
    # for the file, and add the folder to the user's PATH once so new windows find `claude`.
    $claudeBin = Join-Path $HOME '.local\bin'
    if (-not (Test-Path (Join-Path $claudeBin 'claude.exe'))) {
        Write-Host 'Installing Claude Code'
        Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
    }
    $userPath = "$([Environment]::GetEnvironmentVariable('Path', 'User'))"
    if (($userPath -split ';') -notcontains $claudeBin) {
        [Environment]::SetEnvironmentVariable('Path', ($userPath.TrimEnd(';') + ";$claudeBin").TrimStart(';'), 'User')
    }
    Update-SessionPath

    # Through cmd: Windows PowerShell turns a redirected native stderr into a terminating error.
    cmd /c 'gh auth status >nul 2>&1'
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'Signing in to GitHub: press Enter when asked, and a browser window opens'
        gh auth login --web --git-protocol https --hostname github.com
        if ($LASTEXITCODE -ne 0) { throw 'GitHub sign-in did not complete.' }
    }

    # The Nord installer installs into the folder it runs from (~/Nord from the home folder);
    # a PowerShell window may be anywhere, an administrator one in C:\Windows\system32.
    # Single quotes inside: Windows PowerShell drops embedded double quotes when it passes an
    # argument to a program, which would split the Accept header and fetch JSON, not the script.
    Write-Host 'Running the Nord installer'
    $ref = if ($env:NORD_REF) { $env:NORD_REF } else { 'main' }
    if ($ref -notmatch '^[\w./-]+$') { throw "NORD_REF '$ref' is not a branch name." }
    & $bash -c "cd ~ && gh api 'repos/Nord-Quantique/Nord-Context-Harness/contents/install.sh?ref=$ref' -H 'Accept: application/vnd.github.raw' | bash"
    if ($LASTEXITCODE -ne 0) { Write-Host "The Nord installer stopped (exit $LASTEXITCODE)." -ForegroundColor Red }

    # The installer put a session hook in the PowerShell profile, which only windows opened from now
    # on read; this one loads just that block, so `claude` in the Nord folder here is a Nord session too.
    # Claude's installer, run above in this same scope, can leave strict mode on.
    Set-StrictMode -Off
    $profileFile = $PROFILE.CurrentUserAllHosts
    if ((Test-Path $profileFile) -and ((Get-Content -Raw $profileFile) -match '(?s)# >>> nord: PowerShell session hook.*?# <<< nord <<<')) {
        Invoke-Expression $Matches[0]
    }
}
