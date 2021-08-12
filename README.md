pgAdmin for yunohost
====================

[![Integration level](https://dash.yunohost.org/integration/pgadmin.svg)](https://dash.yunohost.org/appci/app/pgadmin) ![](https://ci-apps.yunohost.org/ci/badges/pgadmin.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/pgadmin.maintain.svg)  
[![Install pgadmin with YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=pgadmin)

> *This package allow you to install pgadmin quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

Overview
--------

pgAdmin is a feature rich Open Source administration and development platform for PostgreSQL.

**Shipped version:** 4-5.6

Screenshots
-----------

![](https://www.pgadmin.org/static/COMPILED/assets/img/screenshots/pgadmin4-welcome-light.png)

Documentation
-------------

 * Official documentation: https://www.pgadmin.org/docs/
 * YunoHost documentation: There no other documentations, feel free to contribute.

YunoHost specific features
--------------------------

### Multi-users support

This app actually don't support the SSO and don't support LDAP. After the install of the app you can create a other user. So this app is multi-users but independently of the LDAP database.

### Supported architectures

* x86-64 - [![Build Status](https://ci-apps.yunohost.org/ci/logs/pgadmin%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/pgadmin/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/pgadmin%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/pgadmin/)

<!--Limitations
-----------

* Any known limitations.-->

<!--Additional informations
-----------------------

* Other informations you would add about this application-->

Links
-----

 * Report a bug: https://github.com/YunoHost-Apps/pgadmin_ynh/issues
 * App website: https://www.pgadmin.org/
 * YunoHost website: https://yunohost.org/

---

Install
-------

From command line:

`sudo yunohost app install -l pgAdmin https://github.com/YunoHost-Apps/pgadmin_ynh`

Upgrade
-------

From command line:

`sudo yunohost app upgrade pgadmin -u https://github.com/YunoHost-Apps/pgadmin_ynh`

Developers infos
----------------

Please do your pull request to the [testing branch](https://github.com/YunoHost-Apps/pgadmin_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/pgadmin_ynh/tree/testing --debug
or
sudo yunohost app upgrade pgadmin -u https://github.com/YunoHost-Apps/pgadmin_ynh/tree/testing --debug
```

License
-------

pgAdmin is published under the  the PostgreSQL licence : https://www.pgadmin.org/licence/

TODO
----

- Add sso auth
