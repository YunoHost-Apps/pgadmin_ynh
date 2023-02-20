#!/usr/bin/python

from importlib.machinery import SourceFileLoader
import sqlite3
import sys

# Import crypto from pgadmin project __PYTHON_VERSION__
python_version = str(sys.version_info[0]) + "." + str(sys.version_info[1])
crypto = SourceFileLoader('crypto', '/opt/yunohost/pgadmin/lib/python' +
                          python_version + '/site-packages/pgadmin4/pgadmin/utils/crypto.py').load_module()

# Get arguments
username = sys.argv[1]
password = sys.argv[2]

# Connect to sqlite3
conn = sqlite3.connect('/var/lib/pgadmin/pgadmin4.db')

# Get encrypte user password from the database
cursor = conn.execute('SELECT `password`,1 FROM `user`')
user_encrypted_password = cursor.fetchone()[0]

# Encrypt database password
crypted_password = crypto.encrypt(password, user_encrypted_password)

# Declare database data to put in database
data = {'id': 1, 'user_id': 1, 'servergroup_id': 1, 'name': 'Yunohost Server', 'host': 'localhost', 'port': 5432, 'maintenance_db': 'postgres',
        'username': username, 'comment': '', 'password': crypted_password, 'role': '', 'discovery_id': '',
        'db_res': '', 'bgcolor': '', 'fgcolor': '', 'service': '',
        'use_ssh_tunnel': '', 'tunnel_host': '', 'tunnel_port': 22, 'tunnel_username': '', 'tunnel_authentication': '', 'tunnel_identity_file': '', 'tunnel_password': '',
        'save_password': 1, 'shared': '', 'kerberos_conn': 0, 'cloud_status': 0, 'passexec_cmd': '', 'passexec_expiration': '',
        'connection_params': '''{"sslmode": "prefer", "connect_timeout": 10, "sslcert": "<STORAGE_DIR>/.postgresql/postgresql.crt", "sslkey": "<STORAGE_DIR>/.postgresql/postgresql.key"}'''}

# Insert new data in database
cursor = conn.cursor()
cursor.execute('''
    `server` (
        `id`,`user_id`,`servergroup_id`,`name`,`host`,`port`,`maintenance_db`,
        `username`,`comment`,`password`,`role`,`discovery_id`,
        `db_res`,`bgcolor`,`fgcolor`,`service`,
        `use_ssh_tunnel`,`tunnel_host`,`tunnel_port`,`tunnel_username`,`tunnel_authentication`,`tunnel_identity_file`,`tunnel_password`,
        `save_password`,`shared`,`kerberos_conn`,`cloud_status`,`passexec_cmd`,`passexec_expiration`,
        `connection_params`
    ) VALUES (
        :id,:user_id,:servergroup_id,:name,:host,:port,:maintenance_db,
        :username,:comment,:password,:role,:discovery_id,
        :db_res,:bgcolor,:fgcolor,:service,
        :use_ssh_tunnel,:tunnel_host,:tunnel_port,:tunnel_username,:tunnel_authentication,:tunnel_identity_file,:tunnel_password,
        :save_password,:shared,:kerberos_conn,:cloud_status,:passexec_cmd,:passexec_expiration,
        :connection_params
        )''', data)
conn.commit()

# Close connection
conn.close()
