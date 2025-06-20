#!/usr/bin/env bash

#=================================================
# SET ALL CONSTANTS
#=================================================

readonly python_version="$(python3 -V | cut -d' ' -f2 | cut -d. -f1-2)"
readonly postgresql_version="$(psql -V | cut -d' ' -f3 | cut -d. -f1)"
readonly config_dir="/etc/$app"

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

install_source() {
    # Cleanup old venv files
    ynh_safe_rm "$install_dir"/bin
    ynh_safe_rm "$install_dir"/lib
    ynh_safe_rm "$install_dir"/lib64
    ynh_safe_rm "$install_dir"/include
    ynh_safe_rm "$install_dir"/share
    ynh_safe_rm "$install_dir"/pyvenv.cfg

    # Clean venv is it was on python with an old version in case major upgrade of debian
    if [ ! -e "$install_dir/venv/lib/python$python_version" ] || ! grep -qF "$install_dir/venv/bin/python" "$install_dir"/venv/bin/pip; then
        ynh_safe_rm "$install_dir"/venv/bin
        ynh_safe_rm "$install_dir"/venv/lib
        ynh_safe_rm "$install_dir"/venv/lib64
        ynh_safe_rm "$install_dir"/venv/include
        ynh_safe_rm "$install_dir"/venv/share
        ynh_safe_rm "$install_dir"/venv/pyvenv.cfg
    fi

    if uname -m | grep -q arm
    then
        ynh_setup_source --dest_dir "$install_dir"/venv/ --source_id "pgadmin_prebuilt_armv7_$(lsb_release --codename --short)" --full_replace

        # Fix multi-instance support
        for f in "$install_dir"/venv/bin/*; do
            if ! [[ $f =~ "__" ]]; then
                ynh_replace_regex --match='#!'/opt/yunohost/pgadmin/venv --replace='#!'"$install_dir"/venv --file="$f"
            fi
        done
    else
        # Install virtualenv if it don't exist
        test -e "$install_dir"/venv/bin/python3 || python3 -m venv "$install_dir"/venv

        # Install pgadmin in virtualenv
        pip="$install_dir"/venv/bin/pip
        $pip install --upgrade 'pip<24.1' wheel
        $pip install --upgrade -r "$YNH_APP_BASEDIR/conf/requirement_$(lsb_release --codename --short).txt"
    fi

    # Apply patchs if needed
    # Note that we put patch into scripts dir because /source are not stored and can't be used on restore
    if ! grep -F -q '# BEGIN Yunohost Patch' "$install_dir/venv/lib/python$python_version/site-packages/pgadmin4/migrations/versions/fdc58d9bd449_.py"; then
        pushd "$install_dir/venv/lib/python$python_version/site-packages/pgadmin4"
        patch -p1 < "$YNH_APP_BASEDIR"/scripts/patch/avoid_create_user_on_setup_db.patch
        popd
    fi
    if ! grep -F -q '# BEGIN Yunohost Patch' "$install_dir/venv/lib/python$python_version/site-packages/pgadmin4/pgadmin/__init__.py"; then
        pushd "$install_dir/venv/lib/python$python_version/site-packages/pgadmin4"
        patch -p1 < "$YNH_APP_BASEDIR"/scripts/patch/fix_add_local_db.patch
        popd
    fi
    if ! grep -F -q '# BEGIN Yunohost Patch' "$install_dir/venv/lib/python$python_version/site-packages/pgadmin4/pgadmin/authenticate/webserver.py"; then
        pushd "$install_dir/venv/lib/python$python_version/site-packages/pgadmin4"
        patch -p1 < "$YNH_APP_BASEDIR"/scripts/patch/change_default_webserver_new_user_role_to_admin.patch
        popd
    fi
    if ! grep -F -q '# BEGIN Yunohost Patch' "$install_dir/venv/lib/python$python_version/site-packages/pgadmin4/pgadmin/browser/__init__.py"; then
        pushd "$install_dir/venv/lib/python$python_version/site-packages/pgadmin4"
        patch -p1 < "$YNH_APP_BASEDIR"/scripts/patch/fix_master_key_management.patch
        popd
    fi
    # Customize system config file
    ynh_replace_regex --match="system_config_dir = '/etc/pgadmin'" --replace="system_config_dir = '$config_dir'" --file="$install_dir/venv/lib/python$python_version/site-packages/pgadmin4/pgadmin/evaluate_config.py"
}

set_permission() {
    # Set permission
    chown "$app:$app" -R "$install_dir"
    chmod u+rwX,g+rX-w,o= -R "$install_dir"
    chown "$app:$app" -R "$data_dir"
    chmod u+rwX,g+rX-w,o= -R "$data_dir"
    chown "$app:$app" -R "$config_dir"
    chmod u+rwX,g+rX-w,o= -R "$config_dir"
    chown "$app:$app" -R /var/log/"$app"
    chmod u=rwX,g=rX,o= -R /var/log/"$app"
    # Criticals files
    chown "$app":root "$data_dir"/master_pwd
    chmod u=r,g=,o= "$data_dir"/master_pwd
    chown "$app":root "$config_dir"/postgres-reg.ini
    chmod u=r,g=,o= "$config_dir"/postgres-reg.ini
}
