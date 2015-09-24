Phabricator Cookbook
====================
Installs, upgrades and configures [Phabricator](http://phabricator.org/).

The default recipe will install Nginx, PHP-FPM and MySQL in addition to the
Phabricator software itself, adds a Nginx site and a PHP-FPM pool, creates a
database user, and migrates the Phabricator databases.

Requirements
------------
This cookbook has been tested on Ubuntu 12.04 and 14.04.

#### Cookbooks
- `apt ~> 2.6`
- `php ~> 1.5`
- `php-fpm ~> 0.7`
- `nginx ~> 2.7`
- `mysql ~> 6.0`
- `database ~> 3.1`

Attributes
----------
See `attributes/default.rb`.

Usage
-----
Just include `phabricator` in your node's `run_list`:

```json
{
  "name": "my_node",
  "run_list": [
    "recipe[phabricator]"
  ]
}
```

MySQL Installation
------------------

If `node['phabricator]['mysql_host']` is set to `localhost`, the cookbook will
install and configure the MySQL server appropriately. Otherwise, it will
configure Phabricator to connect to an external database. In the latter case, a
MySQL database user will //not// be managed by this cookbook.

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

* Kim Tore Jensen (kimtj@met.no)
* Martin Grønlien Pejcoch (mgp@met.no)
* Michael Akinde (michael.akinde@met.no)
* Andrew Mulholland (andrew.mulholland@aetion.com)
