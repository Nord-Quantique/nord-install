#!/bin/bash
# Nord installer for macOS and Linux. In a terminal:
#
#   curl -fsSL https://raw.githubusercontent.com/Nord-Quantique/nord-install/main/install.sh | bash
#
# Installs what the Nord harness needs (git, Python 3, the GitHub CLI, Node.js, Claude Code), signs you
# in to GitHub in the browser, then runs the Nord installer from the private
# Nord-Quantique/Nord-Context-Harness repository through that sign-in. Anything already
# installed is left alone, so running it again is safe.
set -euo pipefail

have() { command -v "$1" >/dev/null 2>&1; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

BIN="$HOME/.local/bin"
mkdir -p "$BIN"
export PATH="$BIN:$PATH"

# The GitHub CLI's latest release binary into ~/.local/bin, where there is no package for it.
install_gh_release() {
  local os=$1 arch tag v tmp
  case "$(uname -m)" in arm64|aarch64) arch=arm64 ;; x86_64|amd64) arch=amd64 ;; *) die "unsupported CPU $(uname -m)" ;; esac
  tag=$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | sed -n 's/.*"tag_name": *"\(v[^"]*\)".*/\1/p')
  [ -n "$tag" ] || die "could not find the latest GitHub CLI release"
  v=${tag#v}
  tmp=$(mktemp -d)
  if [ "$os" = macOS ]; then
    curl -fsSL "https://github.com/cli/cli/releases/download/$tag/gh_${v}_macOS_${arch}.zip" -o "$tmp/gh.zip"
    unzip -q "$tmp/gh.zip" -d "$tmp"
  else
    curl -fsSL "https://github.com/cli/cli/releases/download/$tag/gh_${v}_linux_${arch}.tar.gz" | tar -xz -C "$tmp"
  fi
  install -m 755 "$tmp"/gh_*/bin/gh "$BIN/gh"
  rm -rf "$tmp"
}

# Everything runs from main, called on the last line: piped into bash, the whole script is read
# before any step runs, so a command that reads stdin (brew, apt) cannot swallow the rest of it.
main() {
  case "$(uname -s)" in
    Darwin)
      # /usr/bin/git and python3 are stubs until Apple's Command Line Tools are installed.
      if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install || true
        die "click Install in the window that opened, wait for it to finish, then run this again"
      fi
      if ! have gh; then
        if have brew; then brew install gh; else install_gh_release macOS; fi
      fi
      ;;
    Linux)
      if ! have git || ! have python3; then
        if have apt-get; then sudo apt-get update && sudo apt-get install -y git python3
        elif have dnf; then sudo dnf install -y git python3
        else die "install git and python3 with your package manager, then run this again"
        fi
      fi
      have gh || install_gh_release linux
      ;;
    *) die "unsupported system $(uname -s); on Windows use install.ps1" ;;
  esac

  # Node runs the pages' own code (artifact views, the OKR map, page and slide checks) and the Nord
  # MCP; without it the install goes on, and nord doctor says how to add it
  if ! have node; then
    if have brew; then brew install node || true
    elif have apt-get; then sudo apt-get install -y nodejs || true
    elif have dnf; then sudo dnf install -y nodejs || true
    else echo "Node.js not found: some Nord skills need it (https://nodejs.org)"
    fi
  fi

  if ! have claude; then
    echo "Installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
  fi

  if ! gh auth status >/dev/null 2>&1; then
    echo "Signing in to GitHub (a browser window opens)"
    # The script itself arrives on stdin, so the sign-in reads from the terminal.
    gh auth login --web --git-protocol https --hostname github.com </dev/tty
  fi

  echo "Running the Nord installer"
  gh api "repos/Nord-Quantique/Nord-Context-Harness/contents/install.sh?ref=${NORD_REF:-main}" \
    -H "Accept: application/vnd.github.raw" | bash
}

main "$@"
