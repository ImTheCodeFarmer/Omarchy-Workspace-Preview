# Omarchy Workspace Preview

<img width="1043" height="363" alt="image" src="https://github.com/user-attachments/assets/ac052e9a-3c05-4dbe-8d48-2738dab6d377" />

## Overview

An Omarchy Shell workspace widget that displays small live visual window
previews when you hover over a workspace number.

The preview combines Hyprland's window geometry with Quickshell's Wayland
screencopy support. It shows actual window contents in their relative positions,
including inactive workspaces when supported by the compositor. Application
class/title cards remain as a fallback when a window cannot be captured. Click
anywhere in the preview to switch to that workspace.

## Usage Preview

<img width="2560" height="1440" alt="preview-usage" src="https://github.com/user-attachments/assets/03ce1e9d-3153-41e8-8cf9-9170906cb288" />

## Install

Install and enable the plugin with Omarchy's native plugin manager:

```bash
omarchy plugin add https://github.com/ImTheCodeFarmer/Omarchy-Workspace-Preview.git --enable
```

Omarchy will warn that plugins run inside the shell and ask you to confirm the
repository. Once confirmed, it clones the plugin to
`~/.config/omarchy/plugins/imthecodefarmer.workspace-preview` and replaces the
stock workspace widget in its current bar position.

For an unattended installation after reviewing the repository, add `--yes`:

```bash
omarchy plugin add https://github.com/ImTheCodeFarmer/Omarchy-Workspace-Preview.git --enable --yes
```

## Update

```bash
omarchy plugin update imthecodefarmer.workspace-preview
```

Run `omarchy plugin update` without an ID to check every Git-managed plugin.

## Existing installations

If you installed a release that used `codefarmer.workspace-preview` or a
username-generated plugin ID, pull the latest repository and run:

```bash
./install.sh
```

The compatibility installer restores the stock workspace slot, moves the old
plugin into `~/.config/omarchy/plugin-backups`, and reinstalls this repository
through Omarchy's native plugin manager. Your previous shell configuration is
also retained as a timestamped backup.

## Restore after reinstalling Linux

Run the native installation command from the Install section. There is no need
to clone the repository manually.

## Remove

```bash
omarchy plugin remove imthecodefarmer.workspace-preview
```

Omarchy will restore the stock workspace widget because this plugin declares
itself as a replacement for `omarchy.workspaces`.
