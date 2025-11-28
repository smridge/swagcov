# Swagcov
[![Gem Version](https://img.shields.io/gem/v/swagcov?logo=rubygems)](https://rubygems.org/gems/swagcov)
[![GitHub Top Language](https://img.shields.io/github/languages/top/smridge/swagcov)](https://rubygems.org/gems/swagcov)
[![Gem Downloads](https://img.shields.io/gem/dt/swagcov)](https://rubygems.org/gems/swagcov)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
[![GitHub License](https://img.shields.io/github/license/smridge/swagcov.svg)](https://github.com/smridge/swagcov/blob/main/LICENSE)

![Tests Build](https://github.com/smridge/swagcov/actions/workflows/tests.yml/badge.svg)
![Linting Build](https://github.com/smridge/swagcov/actions/workflows/linting.yml/badge.svg)
![CodeQL Build](https://github.com/smridge/swagcov/actions/workflows/codeql-analysis.yml/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/smridge/swagcov/badge.svg?branch=main)](https://coveralls.io/github/smridge/swagcov?branch=main)

OpenAPI documentation coverage report for Rails Routes.

## Usages
- See overview of different endpoints covered, missing and what you choose to ignore.
- Add pass/fail to your build pipeline when missing documentation coverage.

### Usage Options
`swagcov` can be used with a few different approachs.
The approaches below are listed in the following order:
- via executable
- via rake task
- via rails console

#### View OpenAPI documentation coverage report for Rails Route endpoints
- `swagcov`
- `rake swagcov`
- `Swagcov::Runner.new.run`

#### Generate required `.swagcov.yml` config file
- `swagcov --init`
- `rake swagcov -- --init`
- `Swagcov::Runner.new(args: ["--init"]).run`

#### Generate optional `.swagcov_todo.yml` config file
- `swagcov --todo`
- `rake swagcov -- --todo`
- `Swagcov::Runner.new(args: ["--todo"]).run`

#### View `swagcov` version
- `swagcov -v`
- `rake swagcov -- -v`
- `Swagcov::Runner.new(args: ["-v"]).run`

#### View command line usage options
- `swagcov --help`
- `rake swagcov -- --help`
- `Swagcov::Runner.new(args: ["--help"]).run`

### Environment Variables
The following default environment variables are automatically set (and can optionally be changed to your needs)
| Key                | Value               |
| :---               | :---                |
| `SWAGCOV_DOTFILE`  | `.swagcov.yml`      |
| `SWAGCOV_TODOFILE` | `.swagcov_todo.yml` |

For example `SWAGCOV_DOTFILE=".openapi_coverage_config.yml" bundle exec swagcov`

### Exit Codes
`swagcov` exits with the following status codes:
- `0` - (`success`) if no missing documentation coverage is detected
- `1` - (`offenses`) if missing documentation coverage is detected
- `2` - (`error`) if abnormal termination due to invalid configuration, cli options, or an internal error

## Ruby and Rails Version Support
Versioning support from a test coverage perspective, see [tests.yml](/.github/workflows/tests.yml) for detail
| `ruby -v` | `rails 8.1` | `rails 8.0` | `rails 7.2` | `rails 7.1` | `rails 7.0` | `rails 6.1` | `rails 6.0` | `rails 5.2` | `rails 5.1` | `rails 5.0` | `rails 4.2` |
| ---       | ---         | ---         | ---         | ---         | ---         | ---         | ---         | ---         | ---         | ---         | ---         |
| `4.0`     | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ❌          |
| `3.5`     | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ❌          |
| `3.4`     | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ❌          |
| `3.3`     | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ❌          |
| `3.2`     | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ❌          |
| `3.1`     | ❌          | ❌          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          |
| `3.0`     | ❌          | ❌          | ❌          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          |
| `2.7`     | ❌          | ❌          | ❌          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          |
| `2.6`     | ❌          | ❌          | ❌          | ❌          | ❌          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          |
| `2.5`     | ❌          | ❌          | ❌          | ❌          | ❌          | ✅          | ✅          | ✅          | ✅          | ✅          | ✅          |


## Installation
- Add this line to your application's Gemfile:
  ```ruby
  gem "swagcov"
  ```

- Execute `bundle install` to install the gem

- Generate the required `.swagcov.yml` configuration file in the root of your Rails application by executing one of the following commands:
  ```
  bundle exec swagcov --init
  bundle exec rake swagcov -- --init
  ```

  You should now see the following file to configure to your needs:
  ```yaml
  ## Required field:
  # List your OpenAPI documentation file(s) (accepts json or yaml)
  docs:
    paths:
      - swagger.yaml
      - swagger.json

  ## Optional fields:
  # routes:
  #   paths:
  #     only:
  #       - ^/v2 # only track v2 endpoints
  #     ignore:
  #       - /v2/users # do not track certain endpoints
  #       - /v2/users/:id: # ignore only certain actions (verbs)
  #         - GET
  ```

- Execute one of the following commands:
  ```
  bundle exec swagcov
  bundle exec rake swagcov
  ```

  Example Output:
  ```
       GET /articles         200
     PATCH /articles/:id     200
    DELETE /articles/:id     204
       GET /users            200
      POST /users            201
       GET /users/:id        200
       PUT /users/:id        200
    DELETE /users/:id        204
       GET /v1/articles      200
      POST /v1/articles      201
       GET /v1/articles/:id  200
     PATCH /v1/articles/:id  200
       PUT /v1/articles/:id  200
    DELETE /v1/articles/:id  204
       GET /v2/articles      200
      POST /v2/articles      201
     PATCH /v2/articles/:id  200
    DELETE /v2/articles/:id  204
       GET /v2/articles/:id  ignored
       PUT /v2/articles/:id  ignored
      POST /articles         none
       GET /articles/:id     none
       PUT /articles/:id     none
     PATCH /users/:id        none

  OpenAPI documentation coverage 81.82% (18/22)
  2 ignored endpoints
  22 total endpoints
  18 covered endpoints
  4 uncovered endpoints
  ```

- Optionally generate a `.swagcov_todo.yml` config file acting as a TODO list
  ```
  bundle exec swagcov --todo
  bundle exec rake swagcov -- --todo
  ```

## Examples
Configurations and output from running `swagcov` / `rake swagcov` from the root of your Rails Application
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
