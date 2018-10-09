pgAdmin for yunohost
====================

[![Integration level](https://dash.yunohost.org/integration/pgadmin.svg)](https://ci-apps.yunohost.org/jenkins/job/pgadmin%20%28Community%29/lastBuild/consoleFull)  
[![Install pgadmin with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=pgadmin)

> *This package allow you to install pgadmin quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

Overview
--------

pgAdmin is a feature rich Open Source administration and development platform for PostgreSQL.

**Shipped version:** 4-3.4

Screenshots
-----------

![](https://www.pgadmin.org/static/img/screenshots/pgadmin4-welcome.png)

Documentation
-------------

 * Official documentation: https://www.pgadmin.org/docs/
 * YunoHost documentation: There no other documentations, feel free to contribute.

YunoHost specific features
--------------------------

### Multi-users support

This app actually don't support the SSO and don't support LDAP. After the install of the app you can create a other user. So this app is multi-users but independently of the LDAP database.

### Supported architectures

* x86-64b - [![Build Status](https://ci-apps.yunohost.org/jenkins/job/pgadmin%20(Community)/badge/icon)](https://ci-apps.yunohost.org/jenkins/job/pgadmin%20(Community)/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/jenkins/job/pgadmin%20(Community)%20(%7EARM%7E)/badge/icon)](https://ci-apps-arm.yunohost.org/jenkins/job/pgadmin%20(Community)%20(%7EARM%7E)/)
* Jessie x86-64b - [![Build Status](https://ci-stretch.nohost.me/jenkins/job/pgadmin%20(Community)/badge/icon)](https://ci-stretch.nohost.me/jenkins/job/pgadmin%20(Community)/)

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