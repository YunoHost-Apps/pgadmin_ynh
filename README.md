<!--
N.B.: This README was automatically generated by https://github.com/YunoHost/apps/tree/master/tools/README-generator
It shall NOT be edited by hand.
-->

# pgAdmin for YunoHost

[![Integration level](https://dash.yunohost.org/integration/pgadmin.svg)](https://dash.yunohost.org/appci/app/pgadmin) ![Working status](https://ci-apps.yunohost.org/ci/badges/pgadmin.status.svg) ![Maintenance status](https://ci-apps.yunohost.org/ci/badges/pgadmin.maintain.svg)  
[![Install pgAdmin with YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=pgadmin)

*[Lire ce readme en français.](./README_fr.md)*

> *This package allows you to install pgAdmin quickly and simply on a YunoHost server.
If you don't have YunoHost, please consult [the guide](https://yunohost.org/#/install) to learn how to install it.*

## Overview

pgAdmin is a feature rich Open Source administration and development platform for PostgreSQL.


**Shipped version:** 4-5.7~ynh1

## Screenshots

![Screenshot of pgAdmin](./doc/screenshots/pgadmin4-welcome-light.png)

## Disclaimers / important information

### Multi-users support

This app actually don't support the SSO and don't support LDAP. After the install of the app you can create a other user. So this app is multi-users but independently of the LDAP database.

## Documentation and resources

* Official app website: <https://www.pgadmin.org>
* Official admin documentation: <https://www.pgadmin.org/docs>
* YunoHost documentation for this app: <https://yunohost.org/app_pgadmin>
* Report a bug: <https://github.com/YunoHost-Apps/pgadmin_ynh/issues>

## Developer info

Please send your pull request to the [testing branch](https://github.com/YunoHost-Apps/pgadmin_ynh/tree/testing).

To try the testing branch, please proceed like that.

``` bash
sudo yunohost app install https://github.com/YunoHost-Apps/pgadmin_ynh/tree/testing --debug
or
sudo yunohost app upgrade pgadmin -u https://github.com/YunoHost-Apps/pgadmin_ynh/tree/testing --debug
```

**More info regarding app packaging:** <https://yunohost.org/packaging_apps>
