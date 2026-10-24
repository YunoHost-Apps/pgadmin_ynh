#!/bin/bash

set -eu

readonly app_name=pgadmin

readonly deb1_py_version=3.11.2
readonly deb2_py_version=3.13.5
readonly deb1_name=bookworm
readonly deb2_name=trixie

source auto_update_config.sh

get_from_manifest() {
    result=$(python3 <<EOL
import toml
import json
with open("../manifest.toml", "r") as f:
    file_content = f.read()
loaded_toml = toml.loads(file_content)
json_str = json.dumps(loaded_toml)
print(json_str)
EOL
    )
    echo $result | jq -r "$1"
}

check_app_version() {
    local regex='https://www.postgresql.org/ftp/pgadmin/pgadmin4/v([[:digit:]]+\.[[:digit:]]+)/pip'
    local request_result=$(curl https://www.pgadmin.org/download/pgadmin-4-python/ | egrep -m1 -o "$regex")
    if [[ "$request_result" =~ $regex ]]; then
        app_remote_version=${BASH_REMATCH[1]}
    else
        echo "Can't get pgadmin version"
        exit 1
    fi

    ## Check if new build is needed
    if [[ "$app_version" != "$app_remote_version" ]]
    then
        app_version="$app_remote_version"
        return 0
    else
        return 1
    fi
}

build_requirement() {
    local deb_py_version="$1"
    local deb_name="$2"

    venv_dir="/tmp/pgadmin_py_${deb_py_version}"
    ~/.pyenv/versions/"${deb_py_version}"/bin/python -m venv "$venv_dir"
    "$venv_dir/bin/pip3" install --upgrade pip pip-tools
    cat << EOF > "$venv_dir/requirements.in"
pgadmin4==$app_version
gunicorn
EOF
    "$venv_dir/bin/pip-compile" "$venv_dir/requirements.in" --upgrade --output-file "../conf/requirements_${deb_name}.txt"
    rm -r "$venv_dir"
}

upgrade_app() {
    (
        set -eu

        # Update manifest
        sed -r -i 's|version = "[[:alnum:].]{3,10}~ynh[[:alnum:].]{1,2}"|version = "'${app_version}'~ynh1"|' ../manifest.toml

        # Update requirements.txt
        build_requirement $deb1_py_version ${deb1_name}
        build_requirement $deb2_py_version ${deb2_name}

        git commit -a -m "Upgrade $app_name to $app_version"
        git push origin auto_update:auto_update
    ) 2>&1 | tee "${app_name}_build_temp.log"
    return ${PIPESTATUS[0]}
}

app_version=$(get_from_manifest ".version" |  cut -d'~' -f1)

if check_app_version
then
    set +eu
    upgrade_app
    res=$?
    set -eu
    if [ $res -eq 0 ]; then
        result="Success"
    else
        result="Failed"
    fi
    msg="Build: $app_name version $app_version"

    echo "$msg" | mail.mailutils --content-type="text/plain; charset=UTF-8" -A "${app_name}_build_temp.log" -s "Autoupgrade $app_name : $result" "$notify_email"
fi
