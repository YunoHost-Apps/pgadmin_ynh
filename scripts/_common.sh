#=================================================
# SET ALL CONSTANTS
#=================================================

python_version="$(python3 -V | cut -d' ' -f2 | cut -d. -f1-2)"

# dependencies used by the app
pkg_dependencies="python3-pip build-essential python3-dev python3-venv postgresql uwsgi uwsgi-plugin-python3 expect libpq-dev libkrb5-dev"

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

setup_dir() {
    # Create empty dir for pgadmin
    mkdir -p /var/lib/pgadmin
    mkdir -p /var/log/pgadmin
    mkdir -p $final_path
}

install_source() {
    # Clean venv is it was on python with an old version in case major upgrade of debian
    if [ ! -e $final_path/lib/python$python_version ]; then
        ynh_secure_remove --file=$final_path/bin
        ynh_secure_remove --file=$final_path/lib
        ynh_secure_remove --file=$final_path/lib64
        ynh_secure_remove --file=$final_path/include
        ynh_secure_remove --file=$final_path/share
        ynh_secure_remove --file=$final_path/pyvenv.cfg
    fi

    mkdir -p $final_path
    chown $pgadmin_user:root -R $final_path

    if [ -n "$(uname -m | grep arm)" ]
    then
        # Clean old file, sometime it could make some big issues if we don't do this !!
        ynh_secure_remove --file=$final_path/bin
        ynh_secure_remove --file=$final_path/lib
        ynh_secure_remove --file=$final_path/include
        ynh_secure_remove --file=$final_path/share
        ynh_setup_source --dest_dir $final_path/ --source_id "armv7_$(lsb_release --codename --short)"
    else
        # Install rustup is not already installed
        # We need this to be able to install cryptgraphy
        export PATH="$PATH:$final_path/.cargo/bin:$final_path/.local/bin:/usr/local/sbin"
        if [ -e $final_path/.rustup ]; then
            sudo -u "$pgadmin_user" env PATH=$PATH rustup update
        else
            sudo -u "$pgadmin_user" bash -c 'curl -sSf -L https://static.rust-lang.org/rustup.sh | sh -s -- -y --default-toolchain=stable --profile=minimal'
        fi

# 		Install virtualenv if it don't exist
        test -e $final_path/bin/python3 || python3 -m venv $final_path

# 		Install pgadmin in virtualenv
        u_arg='u'
        set +$u_arg;
        source $final_path/bin/activate
        set -$u_arg;
        pip3 install --upgrade pip
        pip3 install --upgrade 'Werkzeug<1.0'
        pip3 install --upgrade pgadmin$app_main_version==$app_sub_version
        set +$u_arg;
        deactivate
        set -$u_arg;
    fi
}

set_permission() {
    # Set permission
    chown $pgadmin_user:root -R $final_path
    chown $pgadmin_user:root -R /var/lib/pgadmin
    chown $pgadmin_user:root -R /var/log/pgadmin
    chown $pgadmin_user:root /var/log/uwsgi/$app
    chown $pgadmin_user:root /etc/uwsgi/apps-available/$app.ini
    chmod u=rwX,g=rX,o= -R /var/lib/pgadmin
}

config_pgadmin() {
    cp ../conf/config_local.py $final_path/lib/python$python_version/site-packages/pgadmin4/config_local.py
    ynh_replace_string --match_string __USER__ --replace_string $pgadmin_user --target_file $final_path/lib/python$python_version/site-packages/pgadmin4/config_local.py
    ynh_replace_string --match_string __DOMAIN__ --replace_string $domain --target_file $final_path/lib/python$python_version/site-packages/pgadmin4/config_local.py
}
