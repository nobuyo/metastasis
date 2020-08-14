# Metastasis

Metastasis(転移) is a tool for copying queries/dashboards to metabase.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'metastasis'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install metastasis

## Usage

To execute metastasis, please run command below:

```bash
% metastasis apply [OPTIONS]
```

### Options

- `-e`, `--enviroment`: specity environment
- `-c`, `--config-file`: specity config file path
- `-f`, `--definition-file`: specity definition file
- `-t`, `--timezone`: specity ActiveRecord timezone

### Prepare

Please create a directory and place files in there like below.
It is just an example. These file or directory names can be changed.

```bash
./metastasis
  ├ config.yml
  ├ Radiograph
  └ queries/
　    ├ card1.sql
　    ├ dashboard1.sql
　    └ ...
```

### Config

The format may change in the future.  
Default config file name is `config.yml`. It contains the database connection information. Environments can be separated using the same format as `dayabase.yml` of `rails`.

In addition, this is not included in the normal rails' database.yml, but you can give a default value to the query definition by writing a `query_config` section.
This is useful when you want to specify common values across queries and different values for different environments, such as database_id as seen from metabase

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  user: <%= ENV['POSTGRES_USER'] %>
  username: <%= ENV['POSTGRES_USER'] %>
  password: <%= ENV['POSTGRES_PASSWORD'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  port: 5432
  reaping_frequency: nil

development:
  <<: *default
  host: <%= ENV['POSTGRES_HOST'] %>
  database: metabase
  query_config:
    database_id: 1

staging:
  <<: *default
  host: <%= ENV['POSTGRES_HOST'] %>
  database: metabase
  query_config:
    database_id: 3

(...)
```

### Definitions List

Default file name is `Radiograph`.
For indexing and loading individually defined queries and dashboards.

`require` in this file resolves the path based on the directory where this file exists.

Card definitions must be required before Dashboard definitions for now.

```ruby
require './queries/card1.query'
require './queries/card2.query'
.
.
.

require './queries/dashboard1.query'
.
.
.
```

### Card Definition

It contains the DSL that defines the Card.
The extension does not have to be `.query`.

```ruby
register_card :unique_name_to_describe_card do |c|
  c.database_id 1
  c.collection_id 1
  c.name 'Reservations'
  c.query_type 'native'
  c.query <<~QUERY
    SELECT status, count(*)
    FROM reservations
    GROUP BY status
    [[ where DATE_TRUNC('day', created_at) = {{ apply_date }} ]]
  QUERY

  c.parameter :apply_date, type: 'date/single', display_name: 'Applied Date'
end
```

### Dashboard Definition

It contains the DSL that defines the Dashboard.
The extension does not have to be `.query`.

Definition order must be `parameter` > (`layout` > `visualize`).

```ruby
register_dashboard :unique_name_for_dashboard do |c|
  c.name 'Dashboard Name'

  c.parameter :date, slug: :date, type: 'date/single'

  # settings for the card which has name `unique_name_to_describe_card`
  c.layout :unique_name_to_describe_card, col: 0, row: 0, sizeX: 10, sizeY: 8, parameter: { name: :date, target: :apply_date }
  c.visualize :unique_name_to_describe_card, graph: { dimensions: ['status'], metrics: ['count'] }
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nobuyo/metastasis.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
