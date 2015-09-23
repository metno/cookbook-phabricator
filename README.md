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

###### MySQL Installation

If node['phabricator]['mysql_host'] is set to `localhost` then the cookbook
will also install and configure the mysql server appropriately.

Otherwise setting to a remote host (e.g. Amazon RDS) will configure phabricator
to connect to that.

Bugs
----


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
