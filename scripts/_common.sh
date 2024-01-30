#!/usr/bin/env bash

#=================================================
# SET ALL CONSTANTS
#=================================================

python_version="$(python3 -V | cut -d' ' -f2 | cut -d. -f1-2)"

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

setup_dir() {
    # Create empty dir for pgadmin
    mkdir -p /var/lib/pgadmin
    mkdir -p /var/log/pgadmin
}

set_permission() {
    # Set permission
    chown $app:root -R $install_dir
    chown $app:root -R /var/lib/pgadmin
    mkdir -p /var/log/pgadmin
    chown $app:root -R /var/log/pgadmin
    chmod u=rwX,g=rX,o= -R /var/lib/pgadmin
}

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
    # ynh_exec_as "$app" "$venvpy" -m pip install --upgrade --no-cache-dir --ignore-installed "psycopg[c]"

    # cp "$YNH_APP_BASEDIR/conf/requirement_$(lsb_release --codename --short).txt" "$install_dir/requirements.txt"
    cp "$YNH_APP_BASEDIR/conf/requirements_orig.txt" "$install_dir/requirements.txt"
    ynh_exec_as "$app" "$venvpy" -m pip install --upgrade -r "$install_dir/requirements.txt"
}
