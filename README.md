# Swagcov
[![Gem Version](https://img.shields.io/gem/v/swagcov)](https://rubygems.org/gems/swagcov)
![Gem Downloads](https://img.shields.io/gem/dt/swagcov)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
[![GitHub License](https://img.shields.io/github/license/smridge/swagcov.svg)](https://github.com/smridge/swagcov/blob/main/LICENSE)

![Tests Build](https://github.com/smridge/swagcov/actions/workflows/tests.yml/badge.svg)
![Linting Build](https://github.com/smridge/swagcov/actions/workflows/linting.yml/badge.svg)
![CodeQL Build](https://github.com/smridge/swagcov/actions/workflows/codeql-analysis.yml/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/smridge/swagcov/badge.svg?branch=main)](https://coveralls.io/github/smridge/swagcov?branch=main)

See OpenAPI documentation coverage report for Rails Routes.

## Usages
- See overview of different endpoints covered, missing and what you choose to ignore.
- Add pass/fail to your build pipeline when missing Documentation Coverage.

| `rake task` | `rails console` | Description |
| :--- | :--- | :--- |
| `rake swagcov` | `Swagcov::Command::ReportCoverage.new.run` | Check documentation coverage |
| `rake swagcov:install` | `Swagcov::Command::GenerateDotfile.new.run` | Install required `.swagcov.yml` config file |
| `rake swagcov:generate_todo` | `Swagcov::Command::GenerateTodoFile.new.run` | Generate `.swagcov_todo.yml` |

## Ruby and Rails Version Support
Versioning support from a test coverage perspective, see [tests.yml](/.github/workflows/tests.yml) for detail
| `ruby -v` | `rails 4.2` | `rails 5.0` | `rails 5.1` | `rails 5.2` | `rails 6.0` | `rails 6.1` | `rails 7.0` | `rails 7.1` | `rails 7.2` | `rails 8.0` |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `2.5` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| `2.6` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| `2.7` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| `3.0` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| `3.1` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| `3.2` | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `3.3` | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `3.4` | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `3.5` | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Installation
Add this line to your application's Gemfile:
```ruby
gem "swagcov"
```

Execute:
```shell
bundle
```

Create a `.swagcov.yml` in root of your Rails application. Alternatively, run:
```shell
bundle exec rake swagcov:install
```

- Add the paths of your OpenAPI `.yml` and/or `.json` files (**required**):
  ```yml
  docs:
    paths:
      - swagger.yaml
      - swagger.json
  ```

- Add `only` routes (**optional**) :
  ```yml
  routes:
    paths:
      only:
        - ^/v1
  ```

- Add `ignore` routes (**optional**) :
  ```yml
  routes:
    paths:
      ignore:
        - /v1/foobar/:token
  ```

- Full Example `.swagcov.yml` Config File:
  ```yml
  docs:
    paths:
      - swagger.yaml

  routes:
    paths:
      only:
        - ^/v1
      ignore:
        - /v1/foobar/:token
        - /v1/foobar:
          - GET
  ```

Execute:
```shell
bundle exec rake swagcov
```

## Examples
Configurations and output from running `bundle exec rake swagcov` from the root of your Rails Application
- All Routes (minimal configuration):
  ```yml
  docs:
    paths:
      - swagger.yaml
  ```
  <img src="https://raw.githubusercontent.com/smridge/swagcov/main/images/all-endpoints.png">


- With `only` endpoint configuration:
  ```yml
  docs:
    paths:
      - swagger.yaml

  routes:
    paths:
      only:
        - ^/v2
  ```
  <img src="https://raw.githubusercontent.com/smridge/swagcov/main/images/only-endpoints.png">

- With `ignore` and `only` endpoint configurations:
  ```yml
  docs:
    paths:
      - swagger.yaml

  routes:
    paths:
      only:
        - ^/v2
      ignore:
        - /v2/users
        - /v2/users/:id:
          - GET
  ```
  <img src="https://raw.githubusercontent.com/smridge/swagcov/main/images/ignore-and-only-endpoints.png">

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for detail

### Credit
To [@lonelyelk](https://github.com/lonelyelk) for initial development!

### Contributors
<a href="https://github.com/smridge/swagcov/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=smridge/swagcov" />
</a>
