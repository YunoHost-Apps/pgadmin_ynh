app=$YNH_APP_INSTANCE_NAME
final_path=/opt/yunohost/$app
pgadmin_user="pgadmin"

get_app_version_from_json() {
   manifest_path="../manifest.json"
    if [ ! -e "$manifest_path" ]; then
    	manifest_path="../settings/manifest.json"	# Into the restore script, the manifest is not at the same place
    fi
    echo $(grep '\"version\": ' "$manifest_path" | cut -d '"' -f 4)	# Retrieve the version number in the manifest file.
}
APP_VERSION=$(get_app_version_from_json)
app_main_version=$(echo $APP_VERSION | cut -d'-' -f1)
app_sub_version=$(echo $APP_VERSION | cut -d'-' -f2)

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
		ynh_setup_source $final_path/ "armv7"
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
}

config_pgadmin() {
    ynh_replace_string __USER__ $pgadmin_user ../conf/config_local.py
    ynh_replace_string __DOMAIN__ $domain ../conf/config_local.py
    cp ../conf/config_local.py $final_path/lib/python2.7/site-packages/pgadmin4/config_local.py
}

config_uwsgi() {
	ynh_replace_string __USER__ $pgadmin_user ../conf/pgadmin.ini
	ynh_replace_string __FINALPATH__ $final_path ../conf/pgadmin.ini
	ynh_replace_string __PATH__ $path_url ../conf/pgadmin.ini
	cp ../conf/pgadmin.ini /etc/uwsgi/apps-enabled/
}

