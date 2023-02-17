#!/usr/bin/python

import imp
import sqlite3
import sys

# Import crypto from pgadmin project
crypto = imp.load_source('crypt', '/opt/yunohost/pgadmin/lib/python__PYTHON_VERSION__/site-packages/pgadmin4/pgadmin/utils/crypto.py')

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
data = {'id': 1,'user_id': 1, 'servergroup_id' : 1, 'name': 'Yunohost Server', 'host': 'localhost', 'port': 5432,'maintenance_db':'postgres','username':username,
    'comment' : '', 'password' :crypted_password,'role':'', 'discovery_id':'', 'hostaddr':'','db_res':'','passfile':'',
    'sslcert' :'','sslkey':'','sslrootcert':'','sslcrl':''}

# Insert new data in database
cursor = conn.cursor()
cursor.execute('''INSERT INTO `server`(
            `id`,`user_id`,`servergroup_id`,`name`,`host`,`port`,`maintenance_db`,`username`,
            `comment`,`password`,`role`,`discovery_id`,`hostaddr`,`db_res`,`passfile`,`sslcert`,`sslkey`,`sslrootcert`,`sslcrl`
        ) VALUES(
            :id,:user_id,:servergroup_id,:name,:host,:port,:maintenance_db,:username,
            :comment,:password,:role,:discovery_id,:hostaddr,:db_res,:passfile,:sslcert,:sslkey,:sslrootcert,:sslcrl
        )''', data)
conn.commit()

# Close connection
conn.close()
