#!/usr/bin/env bash
set -euo pipefail

plugin_id="codefarmer.workspace-preview"
source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/plugin"
target_dir="${HOME}/.config/omarchy/plugins/${plugin_id}"
backup_dir="${HOME}/.config/omarchy/plugin-backups"
shell_config="${HOME}/.config/omarchy/shell.json"

if [[ ! -f "${shell_config}" ]]; then
  echo "Omarchy shell config not found: ${shell_config}" >&2
  exit 1
fi

mkdir -p "$(dirname -- "${target_dir}")"
if [[ -d "${target_dir}" ]]; then
  mkdir -p "${backup_dir}"
  backup="${backup_dir}/${plugin_id}.$(date +%s)"
  cp -a "${target_dir}" "${backup}"
  echo "Backed up existing plugin to ${backup}"
fi

mkdir -p "${target_dir}"
cp -a "${source_dir}/." "${target_dir}/"

config_backup="${shell_config}.bak.$(date +%s)"
cp -a "${shell_config}" "${config_backup}"
jq --arg plugin_id "${plugin_id}" '
  .bar.layout |= with_entries(
    .value |= map(if .id == "omarchy.workspaces" or .id == $plugin_id then .id = $plugin_id else . end)
  )
' "${shell_config}" > "${shell_config}.tmp"
mv "${shell_config}.tmp" "${shell_config}"

omarchy-shell shell rescanPlugins >/dev/null
echo "Installed ${plugin_id}. Shell config backup: ${config_backup}"
