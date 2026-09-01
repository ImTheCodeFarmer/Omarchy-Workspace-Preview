# Omarchy Workspace Preview

A user-owned Omarchy Shell workspace widget that displays a small window-layout
preview when you hover over a workspace number.

The preview uses Hyprland's live window metadata, so it also works for inactive
workspaces without switching to or screenshotting them. It shows relative window
positions, application classes, titles, active/urgent state, and an empty state.

## Install

```bash
chmod +x install.sh
./install.sh
```

The installer copies the plugin to
`~/.config/omarchy/plugins/codefarmer.workspace-preview`, backs up the current
plugin (when present) and `shell.json`, replaces `omarchy.workspaces` in the bar
layout, and asks Omarchy Shell to rescan plugins.

Plugin changes hot-reload. To force a reload:

```bash
omarchy restart shell
```

## Restore after reinstalling Linux

Clone this repository and run `./install.sh`. Omarchy and `jq` must be installed.

## Remove

Change `codefarmer.workspace-preview` back to `omarchy.workspaces` in
`~/.config/omarchy/shell.json`, then remove the copied plugin directory.
