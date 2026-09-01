# Omarchy Workspace Preview

<img width="1043" height="363" alt="image" src="https://github.com/user-attachments/assets/ac052e9a-3c05-4dbe-8d48-2738dab6d377" />

## Overview
A user-owned Omarchy Shell workspace widget that displays small live visual
window previews when you hover over a workspace number.

The preview combines Hyprland's window geometry with Quickshell's Wayland
screencopy support. It shows actual window contents in their relative positions,
including inactive workspaces when supported by the compositor. Application
class/title cards remain as a fallback when a window cannot be captured. Click
anywhere in the preview to switch to that workspace.

## Usage Preview
<img width="2560" height="1440" alt="preview-usage" src="https://github.com/user-attachments/assets/03ce1e9d-3153-41e8-8cf9-9170906cb288" />


## Install

```bash
chmod +x install.sh
./install.sh
```

The installer copies the plugin to
`~/.config/omarchy/plugins/<username>.workspace-preview`, using the username of
the account running the installer. It rewrites the plugin manifest to the same
namespaced ID, backs up the current plugin under
`~/.config/omarchy/plugin-backups` (when present), backs up `shell.json`,
replaces `omarchy.workspaces` in the bar layout, and asks Omarchy Shell to
rescan plugins.

For example, user `alex` gets the plugin ID `alex.workspace-preview`. The
installer does not depend on a particular username. Existing installations
using the old `codefarmer.workspace-preview` ID are migrated automatically and
the old plugin files are retained in the backup directory.

Plugin changes hot-reload. To force a reload:

```bash
omarchy restart shell
```

## Restore after reinstalling Linux

Clone this repository and run `./install.sh`. Omarchy and `jq` must be installed.

## Remove

Change `<username>.workspace-preview` back to `omarchy.workspaces` in
`~/.config/omarchy/shell.json`, then remove
`~/.config/omarchy/plugins/<username>.workspace-preview`.
