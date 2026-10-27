# Installing Nord

One line in PowerShell installs everything Nord needs, signs you in to GitHub and installs the Nord
harness. Then you set Nord up once in the Claude desktop app. This guide shows each screen on Windows 11
and what to do on it. It takes about 5 minutes.

**What you need**

- A GitHub account with access to the **Nord-Quantique** organization (the Nord harness is private).
- A paid Claude plan (Pro, Max, Team or Enterprise) for the Code tab of the Claude desktop app.
- Windows 10 or 11. On a Mac or Linux, see [macOS and Linux](#macos-and-linux).

**Contents**

1. [Run the install line](#1-run-the-install-line)
2. [Step 1 of 2: the tools and your GitHub sign-in](#2-step-1-of-2-the-tools-and-your-github-sign-in)
3. [Step 2 of 2: the Nord harness](#3-step-2-of-2-the-nord-harness)
4. [The Claude desktop app](#4-the-claude-desktop-app)
5. [The Nord environment in the app](#5-the-nord-environment-in-the-app)
6. [The Nord plugins](#6-the-nord-plugins)
7. [Your first Nord session](#7-your-first-nord-session)

## 1. Run the install line

Open the Start menu, type `powershell` and open **Windows PowerShell**. A normal window is fine; you don't
need "Run as administrator".

![The Start menu with Windows PowerShell as the best match](docs/img/01-start-powershell.png)

Copy this line, paste it into the window (Ctrl+V or right-click) and press **Enter**:

```powershell
irm https://raw.githubusercontent.com/Nord-Quantique/nord-install/main/install.ps1 | iex
```

![The install line pasted in PowerShell](docs/img/02-paste.png)

## 2. Step 1 of 2: the tools and your GitHub sign-in

The installer says which step it is at. Step 1 installs Git, Python 3, the GitHub CLI, Node.js and Claude
Code. Tools you already have are kept as they are ("already here").

![Step 1 of 2 starts by installing Git](docs/img/03-step1-starts.png)

**Windows asks for permission** three times, for Git for Windows, the GitHub CLI and Node.js. Click **Yes**
each time. The screen dims while it asks. If it asks for an administrator's password instead, your
computer is managed: ask your IT team to install these tools, then run the line again.

![Windows asks: Do you want to allow this app to make changes to your device? Git for Windows](docs/img/04-permission-git.png)

Each tool says "Successfully installed", then Claude Code installs.

![Git, Python 3, the GitHub CLI and Node.js installed; Claude Code installing](docs/img/05-tools-installed.png)

### Sign in to GitHub

When GitHub asks **"Authenticate Git with your GitHub credentials? (Y/n)"**, press **Enter** (yes).

![Claude Code installed; GitHub asks to authenticate Git](docs/img/06-github-question.png)

It then shows a **one-time code** (already copied for you). Press **Enter** to open GitHub in your
browser.

![The one-time code and Press Enter to open github.com/login/device](docs/img/07-github-code.png)

GitHub shows the account you are signed in with. Click **Continue** if it's the account with Nord access,
or **Use a different account**.

![GitHub Device Activation: Continue with the signed-in account](docs/img/08-github-account.png)

Paste the code (Ctrl+V) into the boxes, then click **Continue**.

![Authorize your device, with the code filled in](docs/img/09-github-code-entered.png)

Scroll down and click **Authorize github**. **Nord-Quantique** should be listed under "Organization
access".

![Authorize GitHub CLI, with Organization access and the Authorize button](docs/img/10-github-authorize.png)

**"Congratulations, you're all set!"** You can close this tab and go back to PowerShell.

![Congratulations, you're all set](docs/img/11-github-done.png)

## 3. Step 2 of 2: the Nord harness

Step 2 runs by itself. It fetches the Nord harness and the shared Nord folders into your user folder
(`C:\Users\<you>\Nord`), and makes your private folder there, which is never pushed anywhere.

![Step 2 of 2: fetching the harness and the Nord folders](docs/img/12-step2.png)

It ends with **"Nord is installed and running."**

![Nord is installed and running](docs/img/13-step2-done.png)

The Nord welcome page opens in your browser (`http://localhost:8137/welcome.html`). Its **Your setup** list
shows what is done and what is left: connectors such as Asana and Microsoft 365, and two Chrome
extensions. Later, open it again from the Start menu: type `Nord` and press Enter.

![Welcome to the Nord harness, with the Your setup checklist](docs/img/14-welcome.png)

### If something fails, run the same line again

A download that times out, or a slow connection, can stop the installer with a red message. Run the same
line again: what is installed already is kept, and it carries on from where it stopped.

![A Claude Code download that timed out, then the line run again: the tools are already here](docs/img/15-run-again.png)

## 4. The Claude desktop app

Skip this part if you already have the Claude desktop app.

Go to [claude.com/download](https://claude.com/download). Click **Download for Windows**. On an ARM computer
(Snapdragon, for example) click **Windows (arm64)**. Settings → System → About → System type says which you
have.

![claude.com/download: Download for Windows, Windows (arm64), Microsoft Store](docs/img/16-download.png)

Open the downloaded **Claude Setup.exe**, from the browser's downloads or your Downloads folder.

![Chrome's recent downloads: Claude Setup.exe](docs/img/17-run-setup.png)

Windows asks for permission for **Claude Setup** (Anthropic, PBC): click **Yes**.

![Windows asks: Claude Setup, Verified publisher Anthropic, PBC](docs/img/18-permission-claude.png)

The app opens by itself. Click **Get started**.

![Claude for Windows: Get started](docs/img/19-app-get-started.png)

Sign in the way you usually sign in to Claude.

![Sign In: Continue with Google, or with email](docs/img/20-app-sign-in.png)

With Google, choose your account in the browser, then click **Open Claude** to go back to the app.

![Google: Choose an account to continue to Claude](docs/img/21-google-account.png)

![Open Claude? Finish sign-in in the Claude app](docs/img/22-open-claude.png)

If you belong to several Claude organizations, pick the one with your plan in the account menu at the bottom
left of the app.

## 5. The Nord environment in the app

This is done once. The app opens in **Code** (the `</>` button at the top left). Under the message box, click
**This computer**, then **New environment**.

![The environment menu: This computer, Cloud, Remote Control, New environment](docs/img/23-environment-menu.png)

On the **Local** tab, type `Nord` as the name. Under Folders, click **Add**, then **Choose…**.

![New environment: Name Nord; Add, Choose…](docs/img/24-new-environment.png)

Select the **Nord** folder in your user folder (`C:\Users\<you>\Nord`) and click **Select Folder**.

![Select folder: Nord](docs/img/25-select-folder.png)

Leave **Worktree** unticked and click **Create environment**.

![New environment Nord with the Nord folder, Create environment](docs/img/26-create-environment.png)

The app asks **"Trust this workspace?"** for your Nord folder. Click **Trust workspace**. Nord's settings run
small scripts at the start of each session, such as keeping the harness up to date, and they need this.

![Trust this workspace? C:\Users\Greg\Nord, Trust workspace](docs/img/27-trust-workspace.png)

The environment selector now shows **Nord**. Choose it whenever you start a Nord session.

![The environment selector shows Nord](docs/img/28-nord-selected.png)

## 6. The Nord plugins

Click **Customize** in the sidebar, then **Plugins**. Under **In this project** you should see the five Nord
plugins: Nord core, Nord pages, Nord sources, Nord slides and Nord harness dev. They come with the Nord
folder and update with it; there is nothing to add.

![Customize, Plugins: In this project, the five Nord plugins](docs/img/29-plugins.png)

## 7. Your first Nord session

Click **New**, check that the environment says **Nord**, type a question and press Enter.

![A new session in the Nord environment: What can Nord do for me here](docs/img/30-first-question.png)

Nord answers from your Nord folders. The panel on the right shows the environment and the connected
services.

![Nord's answer: what it can do, grouped by job](docs/img/31-first-answer.png)

When Nord needs you to choose, it asks in a box: pick an option and click **Submit**, type your own under
**Other**, or **Skip**.

![Nord asks what to do next: Ask about OKRs, What changed in Asana, Pull my meetings, Check for updates](docs/img/32-first-choices.png)

**Day to day**

- Start sessions from the **Nord** environment in the Claude app.
- The Nord home page: Start menu, type `Nord`, Enter.
- Nord updates itself every 4 hours and at the start of each Claude session.
- To ask whether everything works, ask Claude in a Nord session to run `nord doctor`.

## macOS and Linux

Open Terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/Nord-Quantique/nord-install/main/install.sh | bash
```

The same two steps follow. On a Mac without Apple's Command Line Tools (which bring Git and Python 3), a
window opens first: click **Install**, wait for it to finish, then run the line again. The GitHub CLI and
Node.js come from Homebrew if you have it; without Homebrew, the GitHub CLI comes from GitHub's releases and
the installer says if Node.js is missing. On Linux, Git, Python 3 and Node.js come from apt or dnf (it asks
for your password). The GitHub sign-in works as in [part 2](#sign-in-to-github), then the harness goes into
`~/Nord`. Then do parts [4](#4-the-claude-desktop-app) to [7](#7-your-first-nord-session) with the Claude
desktop app for macOS, choosing the `Nord` folder in your home folder.
