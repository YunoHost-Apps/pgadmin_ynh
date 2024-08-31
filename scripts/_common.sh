#!/usr/bin/env bash

#=================================================
# SET ALL CONSTANTS
#=================================================

python_version="$(python3 -V | cut -d' ' -f2 | cut -d. -f1-2)"
postgresql_version="$(psql -V | cut -d' ' -f3 | cut -d. -f1)"

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
}

set_permission() {
    # Set permission
    #REMOVEME? Assuming the install dir is setup using ynh_setup_source, the proper chmod/chowns are now already applied and it shouldn't be necessary to tweak perms | chown "$app:$app" -R "$install_dir"
    #REMOVEME? Assuming the install dir is setup using ynh_setup_source, the proper chmod/chowns are now already applied and it shouldn't be necessary to tweak perms | chmod u+rw,o= -R "$install_dir"
    chown "$app:$app" -R "$data_dir"
    chmod u+rw,o= -R "$data_dir"
    #REMOVEME? Assuming ynh_config_add_logrotate is called, the proper chmod/chowns are now already applied and it shouldn't be necessary to tweak perms | chown "$app:$app" -R /var/log/"$app"
    #REMOVEME? Assuming ynh_config_add_logrotate is called, the proper chmod/chowns are now already applied and it shouldn't be necessary to tweak perms | chmod u=rwX,g=rX,o= -R /var/log/"$app"
    # Criticals files
    #REMOVEME? Assuming the file is setup using ynh_config_add, the proper chmod/chowns are now already applied and it shouldn't be necessary to tweak perms | chown "$app":root "$data_dir"/master_pwd
    #REMOVEME? Assuming the file is setup using ynh_config_add, the proper chmod/chowns are now already applied and it shouldn't be necessary to tweak perms | chmod u=r,g=,o= "$data_dir"/master_pwd
    chown "$app":root "$install_dir"/postgres-reg.ini
    chmod u=r,g=,o= "$install_dir"/postgres-reg.ini
}
