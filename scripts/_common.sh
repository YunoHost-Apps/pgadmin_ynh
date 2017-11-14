app=$YNH_APP_INSTANCE_NAME
db_user="$app"

install_dependance() {
	ynh_install_app_dependencies postgresql php5-pgsql
}

psql_create_admin() {
        ynh_psql_execute_as_root \
        "CREATE USER ${1} WITH PASSWORD '${2}';"
}




















