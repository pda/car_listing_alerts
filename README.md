Car Listing Alerts
==================

Gathers car listings from a paginated set of pages, storing details
to a PostgreSQL database. New and updated listings are emailed to the
mail recipient configured in the environment.

This is a personal project, unlikely to be of use to anybody else.

It's also been an excuse to use PostgreSQL without an ORM/framework,
and to test out [RDO](https://github.com/d11wtq/rdo).


Configuration
-------------

```ruby
ENV["DATABASE_URL"]    # PostgreSQL DSN
ENV["MAIL_RECIPIENT"]  # Email address to send to (and from).
```

```sh
# Set up environment, create database, and then:
rake db:migrate             # creates table
ruby -I ./lib bin/fetch.rb  # goes forth and does things.
```


Dependencies
------------

* Ruby 1.9+
* PostgreSQL database.
* Local sendmail server, works by default on Mac OS X 10.8 Mountain Lion.
* [RDO](https://github.com/d11wtq/rdo) and its [PostgreSQL adapter](https://github.com/d11wtq/rdo-postgres).
* See `Gemfile` for other gem dependencies.


License
-------

© 2012 Paul Annesley, MIT license.
