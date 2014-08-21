Phabricator Cookbook
====================
Installs, upgrades and configures [Phabricator](http://phabricator.org/).

The default recipe will install Nginx, PHP-FPM and MySQL in addition to the
Phabricator software itself, adds a Nginx site and a PHP-FPM pool, creates a
database user, and migrates the Phabricator databases.

Requirements
------------
This cookbook has been tested on Ubuntu 12.04 and Debian 7.

#### Cookbooks
- `php` == 1.4.6
- `php-fpm` == 0.6.8
- `nginx` == 2.7.4
- `mysql` == 5.3.0
- `database` == 2.2.0

Attributes
----------

| Key                                           | Type      | Default                   | Description |
|-----------------------------------------------|-----------|---------------------------|-------------|
| ['phabricator']['path']                       | String    | /opt/phabricator          | Install path |
| ['phabricator']['user']                       | String    | phabricator               | Phabricator user |
| ['phabricator']['group']                      | String    | www-data                  | Phabricator group |
| ['phabricator']['domain']                     | String    | phabricator.example.com   | FQDN of site |
| ['phabricator']['revision']['phabricator']    | String    | master                    | Phabricator git revision |
| ['phabricator']['revision']['arcanist']       | String    | master                    | Arcanist git revision |
| ['phabricator']['revision']['libphutil']      | String    | master                    | libphutil git revision |
| ['phabricator']['repository_path']            | String    | /var/repo                 | Source code repository path |
| ['phabricator']['ssl']                        | Boolean   | false                     | Set to true to use/force HTTPS in nginx |
| ['phabricator']['ssl_cert_path']              | String    |                           | Path to SSL certificate |
| ['phabricator']['ssl_key_path']               | String    |                           | Path to SSL key |
| ['phabricator']['mysql_host']                 | String    | localhost                 | MySQL host |
| ['phabricator']['mysql_port']                 | String    | 3306                      | MySQL port |
| ['phabricator']['mysql_user']                 | String    | phabricator               | MySQL user |
| ['phabricator']['mysql_password']             | String    | changeme                  | MySQL password |
| ['phabricator']['php_memory_limit']           | String    | '128M'                    | PHP memory limit |
| ['phabricator']['config']                     | Hash      |                           | Hash with Phabricator configuration |
| ['phabricator']['packages']                   | Array     |                           | List of packages required |

Usage
-----
#### phabricator::default
Just include `phabricator` in your node's `run_list`:

```json
{
  "name": "my_node",
  "run_list": [
    "recipe[phabricator]"
  ]
}
```

Bugs
----
It's not yet possible to use an external MySQL server, but feel free to submit patches.

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
This cookbook is licensed under GPL version 2 or (at your option) any later version.

Authors: Kim Tore Jensen &lt;kimtj@met.no&gt;, MET Norway
