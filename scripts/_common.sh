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
    # Clean venv is it was on python with an old version in case major upgrade of debian
    if [ ! -e $install_dir/venv/lib/python$python_version ] || ! grep -qF "$install_dir/venv/bin/python" "$install_dir"/venv/bin/pip; then
        ynh_secure_remove --file=$install_dir/venv/bin
        ynh_secure_remove --file=$install_dir/venv/lib
        ynh_secure_remove --file=$install_dir/venv/lib64
        ynh_secure_remove --file=$install_dir/venv/include
        ynh_secure_remove --file=$install_dir/venv/share
        ynh_secure_remove --file=$install_dir/venv/pyvenv.cfg
    fi

    if uname -m | grep -q arm
    then
        # Clean old file, sometime it could make some big issues if we don't do this !!
        ynh_secure_remove --file=$install_dir/venv/bin
        ynh_secure_remove --file=$install_dir/venv/lib
        ynh_secure_remove --file=$install_dir/venv/include
        ynh_secure_remove --file=$install_dir/venv/share
        ynh_setup_source --dest_dir $install_dir/ --source_id "pgadmin_prebuilt_armv7_$(lsb_release --codename --short)"
    else
        # Install virtualenv if it don't exist
        test -e $install_dir/venv/bin/python3 || python3 -m venv $install_dir/venv

        # Install pgadmin in virtualenv
        pip=$install_dir/venv/bin/pip
        $pip install --upgrade pip wheel
        $pip install --upgrade -r "$YNH_APP_BASEDIR"/conf/requirement_$(lsb_release --codename --short).txt
    fi

    # Apply patchs if needed
    # Note that we put patch into scripts dir because /source are not stored and can't be used on restore
    if ! grep -F -q '# BEGIN Yunohost Patch' $install_dir/venv/lib/python$python_version/site-packages/pgadmin4/migrations/versions/fdc58d9bd449_.py; then
        pushd $install_dir/venv/lib/python$python_version/site-packages/pgadmin4
        patch -p1 < "$YNH_APP_BASEDIR"/scripts/patch/avoid_create_user_on_setup_db.patch
        popd
    fi
    if ! grep -F -q '# BEGIN Yunohost Patch' $install_dir/venv/lib/python$python_version/site-packages/pgadmin4/pgadmin/__init__.py; then
        pushd $install_dir/venv/lib/python$python_version/site-packages/pgadmin4
        patch -p1 < "$YNH_APP_BASEDIR"/scripts/patch/fix_add_local_db.patch
        popd
    fi
    if ! grep -F -q '# BEGIN Yunohost Patch' $install_dir/venv/lib/python$python_version/site-packages/pgadmin4/pgadmin/authenticate/webserver.py; then
        pushd $install_dir/venv/lib/python$python_version/site-packages/pgadmin4
        patch -p1 < "$YNH_APP_BASEDIR"/scripts/patch/change_default_webserver_new_user_role_to_admin.patch
        popd
    fi
}

set_permission() {
    # Set permission
    chown $app:$app -R $install_dir
    chmod u+rw,o= -R $install_dir
    chown $app:$app -R $data_dir
    chmod u+rw,o= -R $data_dir
    chown $app:$app -R /var/log/$app
    chmod u=rwX,g=rX,o= -R /var/log/$app
    # Criticals files
    chown $app:root $data_dir/master_pwd
    chmod u=r,g=,o= $data_dir/master_pwd
    chown $app:root $install_dir/postgres-reg.ini
    chmod u=r,g=,o= $install_dir/postgres-reg.ini
}

