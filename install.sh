#!/usr/bin/env bash
set -euo pipefail

# Compatibility installer for releases before native Omarchy plugin support.
# New users should use `omarchy plugin add` as documented in README.md.
plugin_id="imthecodefarmer.workspace-preview"
repo_url="https://github.com/ImTheCodeFarmer/Omarchy-Workspace-Preview.git"
plugins_dir="${HOME}/.config/omarchy/plugins"
target_dir="${plugins_dir}/${plugin_id}"
backup_dir="${HOME}/.config/omarchy/plugin-backups"
shell_config="${HOME}/.config/omarchy/shell.json"
account_name="${USER:-$(id -un)}"
legacy_user_id="${account_name}.workspace-preview"
legacy_author_id="codefarmer.workspace-preview"

if [[ ! -f "${shell_config}" ]]; then
  echo "Omarchy shell config not found: ${shell_config}" >&2
  exit 1
fi

mkdir -p "${plugins_dir}" "${backup_dir}"

# Restore the stock widget in every legacy slot. Native plugin enablement then
# replaces it in-place via the manifest's clonedFrom metadata. This leaves the
# stock widget working if the network installation fails.
config_backup="${shell_config}.bak.$(date +%s)"
cp -a "${shell_config}" "${config_backup}"
jq \
  --arg legacy_user_id "${legacy_user_id}" \
  --arg legacy_author_id "${legacy_author_id}" '
    .bar.layout |= with_entries(
      .value |= (
        map(
          if .id == $legacy_user_id or .id == $legacy_author_id
          then .id = "omarchy.workspaces"
          else .
          end
        )
        | reduce .[] as $entry ([];
            if any(.[]; .id == $entry.id) then . else . + [$entry] end)
      )
    )
  ' "${shell_config}" > "${shell_config}.tmp"
mv "${shell_config}.tmp" "${shell_config}"

for legacy_id in "${legacy_author_id}" "${legacy_user_id}"; do
  [[ "${legacy_id}" != "${plugin_id}" ]] || continue
  legacy_dir="${plugins_dir}/${legacy_id}"
  [[ -d "${legacy_dir}" ]] || continue
  legacy_backup="${backup_dir}/${legacy_id}.$(date +%s)"
  mv "${legacy_dir}" "${legacy_backup}"
  echo "Moved legacy plugin to ${legacy_backup}"
done

omarchy-shell shell rescanPlugins >/dev/null

if [[ -d "${target_dir}/.git" ]]; then
  omarchy plugin update "${plugin_id}" --yes
  omarchy plugin enable "${plugin_id}"
elif [[ -e "${target_dir}" ]]; then
  target_backup="${backup_dir}/${plugin_id}.$(date +%s)"
  mv "${target_dir}" "${target_backup}"
  echo "Moved non-Git installation to ${target_backup}"
  omarchy plugin add "${repo_url}" --enable --yes
else
  omarchy plugin add "${repo_url}" --enable --yes
fi

echo "Installed ${plugin_id}. Shell config backup: ${config_backup}"
