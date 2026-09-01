# Omarchy Workspace Preview

A user-owned Omarchy Shell workspace widget that displays small live visual
window previews when you hover over a workspace number.

The preview combines Hyprland's window geometry with Quickshell's Wayland
screencopy support. It shows actual window contents in their relative positions,
including inactive workspaces when supported by the compositor. Application
class/title cards remain as a fallback when a window cannot be captured. Click
anywhere in the preview to switch to that workspace.

## Install

```bash
chmod +x install.sh
./install.sh
```

The installer copies the plugin to
`~/.config/omarchy/plugins/codefarmer.workspace-preview`, backs up the current
plugin under `~/.config/omarchy/plugin-backups` (when present), backs up
`shell.json`, replaces `omarchy.workspaces` in the bar layout, and asks Omarchy
Shell to rescan plugins.

Plugin changes hot-reload. To force a reload:

```bash
omarchy restart shell
```

## Restore after reinstalling Linux

Clone this repository and run `./install.sh`. Omarchy and `jq` must be installed.

## Remove

Change `codefarmer.workspace-preview` back to `omarchy.workspaces` in
`~/.config/omarchy/shell.json`, then remove the copied plugin directory.
