#!/usr/bin/env bash

#=================================================
# SET ALL CONSTANTS
#=================================================

python_version="$(python3 -V | cut -d' ' -f2 | cut -d. -f1-2)"

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

ynh_install_venv() {
    if [ -f "$install_dir/venv/bin/python" ]; then
        ynh_exec_as "$app" python3 -m venv "$install_dir/venv" --upgrade
    else
        ynh_exec_as "$app" python3 -m venv "$install_dir/venv"
    fi
    ynh_use_venv

    ynh_exec_as "$app" "$venvpy" -m pip install --upgrade --no-cache-dir pip wheel
}
ynh_use_venv() {
    venvpy="$install_dir/venv/bin/python3"
}

_install_pgadmin_pip() {
    ynh_exec_as "$app" "$venvpy" -m pip install --upgrade "pgadmin4==7.7"
}
