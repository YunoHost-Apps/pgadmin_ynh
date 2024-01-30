#=================================================
# SET ALL CONSTANTS
#=================================================

python_version="$(python3 -V | cut -d' ' -f2 | cut -d. -f1-2)"

# dependencies used by the app
#REMOVEME? pkg_dependencies="python3-pip build-essential python3-dev python3-venv postgresql uwsgi uwsgi-plugin-python3 expect libpq-dev libkrb5-dev"

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

setup_dir() {
    # Create empty dir for pgadmin
    mkdir -p /var/lib/pgadmin
    mkdir -p /var/log/pgadmin
    mkdir -p $install_dir
}

install_source() {
    # Clean venv is it was on python with an old version in case major upgrade of debian
    if [ ! -e $install_dir/lib/python$python_version ]; then
#REMOVEME?         ynh_secure_remove --file=$install_dir/bin
#REMOVEME?         ynh_secure_remove --file=$install_dir/lib
#REMOVEME?         ynh_secure_remove --file=$install_dir/lib64
#REMOVEME?         ynh_secure_remove --file=$install_dir/include
#REMOVEME?         ynh_secure_remove --file=$install_dir/share
#REMOVEME?         ynh_secure_remove --file=$install_dir/pyvenv.cfg
    fi

    mkdir -p $install_dir
    chown $app:root -R $install_dir

    if [ -n "$(uname -m | grep arm)" ]
    then
        # Clean old file, sometime it could make some big issues if we don't do this !!
#REMOVEME?         ynh_secure_remove --file=$install_dir/bin
#REMOVEME?         ynh_secure_remove --file=$install_dir/lib
#REMOVEME?         ynh_secure_remove --file=$install_dir/include
#REMOVEME?         ynh_secure_remove --file=$install_dir/share
        ynh_setup_source --dest_dir $install_dir/ --source_id "armv7_$(lsb_release --codename --short)"
    else
# 		Install virtualenv if it don't exist
#REMOVEME?         test -e $install_dir/bin/python3 || python3 -m venv $install_dir

# 		Install pgadmin in virtualenv
        u_arg='u'
        set +$u_arg;
        source $install_dir/bin/activate
        set -$u_arg;
        pip3 install --upgrade pip wheel
        pip3 install -I --upgrade "psycopg[c]"
        pip3 install --upgrade -r $YNH_APP_BASEDIR/conf/requirement_$(lsb_release --codename --short).txt
        set +$u_arg;
        deactivate
        set -$u_arg;
    fi
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

config_pgadmin() {
    cp ../conf/config_local.py $install_dir/lib/python$python_version/site-packages/pgadmin4/config_local.py
    ynh_replace_string --match_string __USER__ --replace_string $app --target_file $install_dir/lib/python$python_version/site-packages/pgadmin4/config_local.py
    ynh_replace_string --match_string __DOMAIN__ --replace_string $domain --target_file $install_dir/lib/python$python_version/site-packages/pgadmin4/config_local.py
}
