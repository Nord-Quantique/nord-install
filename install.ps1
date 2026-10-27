# Nord installer for Windows. In PowerShell:
#
#   irm https://raw.githubusercontent.com/Nord-Quantique/nord-install/main/install.ps1 | iex
#
# Installs what the Nord harness needs (Git for Windows, Python 3, the GitHub CLI, Node.js, Claude Code),
# signs you in to GitHub in the browser, then runs the Nord installer from the private
# Nord-Quantique/Nord-Context-Harness repository through that sign-in. Anything already
# installed (Git, Python, gh, Claude Code, wherever they are) is used as it is. A previous Nord
# install, even one that stopped halfway, is listed with what removing it would lose, and you
# choose: type wipe to remove it and install fresh, or press Enter to keep it and update it.
# To try the installer from a branch of the harness, set $env:NORD_REF = '<branch>' first.
#
# `iex` runs this in your own PowerShell session; the script block keeps its settings and
# variables out of it, and it never calls `exit`, which would close your window.

& {
    $ErrorActionPreference = 'Stop'

    function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

    # winget changes the registry PATH, not this session's; read it back after each install, keeping
    # what this window added of its own (a virtual environment, say) after it.
    function Update-SessionPath {
        $parts = @([Environment]::GetEnvironmentVariable('Path', 'Machine'),
                   [Environment]::GetEnvironmentVariable('Path', 'User'),
                   (Join-Path $HOME '.local\bin'), $env:Path) -join ';' -split ';'
        $env:Path = ($parts | Where-Object { $_ } | Select-Object -Unique) -join ';'
    }

    # Installs $id unless $find already finds $name (it returns where). winget answers a package it
    # already has (in another version or scope) with an error code, so what counts is whether $find
    # finds it afterwards.
    function Ensure($name, $id, [scriptblock]$find) {
        $at = & $find
        if ($at) { Write-Host "$name already here: $at"; return }
        Write-Host "Installing $name ($id)"
        winget install -e --id $id --source winget --accept-package-agreements --accept-source-agreements
        $code = $LASTEXITCODE
        Update-SessionPath
        if (& $find) { return }
        throw "winget could not install $id (exit $code)"
    }

    # Git's bash: in Program Files, a per-user install, or beside whichever git is on PATH
    # (git.exe sits in <Git>\cmd or <Git>\mingw64\bin, bash.exe in <Git>\bin).
    function Find-Bash {
        $spots = @((Join-Path $env:ProgramFiles 'Git\bin\bash.exe'),
                   (Join-Path $env:LOCALAPPDATA 'Programs\Git\bin\bash.exe'))
        $git = Get-Command git -ErrorAction SilentlyContinue
        if ($git) {
            $d = Split-Path $git.Source
            foreach ($i in 1..3) { $spots += Join-Path $d 'bin\bash.exe'; $d = Split-Path $d }
        }
        $spots | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
    }

    # A Python 3 that runs: `py -3` (python.org), then `python` and `python3`, which may also be
    # the Microsoft Store stub that only prints a hint. Returns its python.exe.
    function Find-Python {
        $ErrorActionPreference = 'Continue'      # a native program's stderr must not stop the script
        $probe = 'import sys; print(sys.executable) if sys.version_info[0] == 3 else sys.exit(1)'
        foreach ($c in 'py', 'python', 'python3') {
            if (-not (Have $c)) { continue }
            $out = if ($c -eq 'py') { & py -3 -c $probe 2>$null } else { & $c -c $probe 2>$null }
            if ($LASTEXITCODE -eq 0 -and $out) { return @($out)[-1].Trim() }
        }
    }

    if (-not (Have winget)) {
        throw 'winget is missing: install "App Installer" from the Microsoft Store, then run this again.'
    }
    Update-SessionPath

    Ensure 'Git' 'Git.Git' { Find-Bash }
    $bash = Find-Bash

    Ensure 'Python 3' 'Python.Python.3.13' { Find-Python }
    $python = Find-Python
    $env:Path = (Split-Path $python) + ';' + $env:Path

    Ensure 'GitHub CLI' 'GitHub.cli' { (Get-Command gh -ErrorAction SilentlyContinue).Source }

    # Node runs the pages' own code (artifact views, the OKR map, page and slide checks) and the Nord MCP
    Ensure 'Node.js' 'OpenJS.NodeJS.LTS' { (Get-Command node -ErrorAction SilentlyContinue).Source }

    # Claude Code, unless a claude is already here (native or from npm). Its installer puts
    # claude.exe in ~\.local\bin but leaves that folder off PATH, so add it to the user's PATH
    # once, and new windows find `claude`.
    $claudeBin = Join-Path $HOME '.local\bin'
    if (Have claude) { Write-Host "Claude Code already here: $((Get-Command claude).Source)" }
    else {
        Write-Host 'Installing Claude Code'
        Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
    }
    $userPath = "$([Environment]::GetEnvironmentVariable('Path', 'User'))"
    if ((Test-Path (Join-Path $claudeBin 'claude.exe')) -and (($userPath -split ';') -notcontains $claudeBin)) {
        [Environment]::SetEnvironmentVariable('Path', ($userPath.TrimEnd(';') + ";$claudeBin").TrimStart(';'), 'User')
    }
    Update-SessionPath
    $env:Path = (Split-Path $python) + ';' + $env:Path

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
