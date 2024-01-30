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
    chown $app:root /var/log/uwsgi/$app
    chown $app:root /etc/uwsgi/apps-available/$app.ini
    chmod u=rwX,g=rX,o= -R /var/lib/pgadmin
}

_install_pgadmin_venv() {
    ynh_exec_as "$app" python3 -m venv --upgrade "$install_dir/venv"
    venvpy="$install_dir/venv/bin/python3"

    ynh_exec_as "$app" "$venvpy" -m pip install --upgrade --no-cache-dir pip wheel
    ynh_exec_as "$app" "$venvpy" -m pip install --upgrade --no-cache-dir --ignore-installed "psycopg[c]"

    ynh_exec_as "$app" "$venvpy" -m pip install --upgrade -r "$YNH_APP_BASEDIR/conf/requirement_$(lsb_release --codename --short).txt"
}

config_pgadmin() {
    ynh_add_config --template="config_local.py" --destination="$install_dir/venv/lib/python$python_version/site-packages/pgadmin4/config_local.py"
}
