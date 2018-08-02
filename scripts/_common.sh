#=================================================
# SET ALL CONSTANTS
#=================================================

app=$YNH_APP_INSTANCE_NAME
final_path=/opt/yunohost/$app
pgadmin_user="pgadmin"

[[ -e "../settings/manifest.json" ]] || [[ -e "../manifest.json" ]] && \
    APP_VERSION=$(ynh_app_upstream_version)
app_main_version=$(echo $APP_VERSION | cut -d'-' -f1)
app_sub_version=$(echo $APP_VERSION | cut -d'-' -f2)

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

install_dependance() {
    ynh_install_app_dependencies python-pip build-essential python-dev python-virtualenv postgresql uwsgi uwsgi-plugin-python expect
}

psql_create_admin() {
        ynh_psql_execute_as_root \
        "CREATE USER ${1} WITH PASSWORD '${2}';"
}

setup_dir() {
    # Create empty dir for pgadmin
    mkdir -p /var/lib/pgadmin
    mkdir -p /var/log/pgadmin
    mkdir -p $final_path
}

install_source() {
    if [ -n "$(uname -m | grep arm)" ]
    then
        if [ "$(lsb_release --codename --short)" != "jessie" ]
        then
            ynh_setup_source $final_path/ "armv7_jessie"
        else
            ynh_setup_source $final_path/ "armv7_stretch"
        fi
    else
# 		Install virtualenv if it don't exist
        test -e $final_path/bin || virtualenv -p python2.7 $final_path

# 		Install pgadmin in virtualenv
        PS1=""
        cp ../conf/virtualenv_activate $final_path/bin/activate
        source $final_path/bin/activate
        pip install --upgrade pip
        pip install --upgrade https://ftp.postgresql.org/pub/pgadmin/pgadmin$app_main_version/v$app_sub_version/pip/pgadmin${APP_VERSION}-py2.py3-none-any.whl
        deactivate
    fi
}

set_permission() {
    # Set permission
    chown $pgadmin_user:root -R $final_path
    chown $pgadmin_user:root -R /var/lib/pgadmin
    chown $pgadmin_user:root -R /var/log/pgadmin
    chmod u=rwX,g=rX,o= -R /var/lib/pgadmin
}

config_pgadmin() {
    cp ../conf/config_local.py $final_path/lib/python2.7/site-packages/pgadmin4/config_local.py
    ynh_replace_string __USER__ $pgadmin_user $final_path/lib/python2.7/site-packages/pgadmin4/config_local.py
    ynh_replace_string __DOMAIN__ $domain $final_path/lib/python2.7/site-packages/pgadmin4/config_local.py
}

config_uwsgi() {
    cp ../conf/pgadmin.ini /etc/uwsgi/apps-enabled/
    ynh_replace_string __USER__ $pgadmin_user /etc/uwsgi/apps-enabled/pgadmin.ini
    ynh_replace_string __FINALPATH__ $final_path /etc/uwsgi/apps-enabled/pgadmin.ini
    ynh_replace_string __PATH__ $path_url /etc/uwsgi/apps-enabled/pgadmin.ini
}

