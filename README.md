# Swagcov
[![Gem Version](https://img.shields.io/gem/v/swagcov)](https://rubygems.org/gems/swagcov)
![Gem Downloads](https://img.shields.io/gem/dt/swagcov)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
[![GitHub License](https://img.shields.io/github/license/smridge/swagcov.svg)](https://github.com/smridge/swagcov/blob/main/LICENSE)

See OpenAPI documentation coverage report for Rails Routes.

## Usages
- See overview of different endpoints covered, missing and what you choose to ignore.
- Add pass/fail to your build pipeline when missing Documentation Coverage.

## Installation
Add this line to your application's Gemfile:
```ruby
gem "swagcov"
```

Execute:
```shell
bundle
```

Install `.swagcov.yml` config file from the root of your Rails Application:
```shell
bundle exec rake swagcov:install
```

- Add the paths of your `openapi` yml files (**required**):
  ```yml
  docs:
    paths:
      - swagger.yaml
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
  ```

Execute:
```shell
bundle exec rake swagcov
```

### Example configurations and output from running `bundle exec rake swagcov` from the root of your Rails Application:
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
  ```
  <img src="https://raw.githubusercontent.com/smridge/swagcov/main/images/ignore-and-only-endpoints.png">

## Development
```shell
git clone git@github.com:smridge/swagcov.git
```

Add this line to your application's Gemfile:
```ruby
 # Use the relative path from your application, to the swagcov folder
gem "swagcov", path: "../swagcov"
```

```shell
bundle
```

Run Tests
```
bundle exec rspec spec --exclude-pattern spec/sandbox_**/**/*_spec.rb
```

### Test via Sandbox Application
- Go to any sandbox application within the `spec` directory
  - For example, `cd spec/sandbox_5_2/`
- Install the ruby version specified in `.ruby-version` file
- Install gems: `bundle install`
- Run tests: `bundle exec rspec spec`
- Run `bundle exec rake swagcov`
  - This will run against any changes made to your branch.

## Publish (internal)
> Note: Publishing a new version of this gem is only meant for maintainers.
- Ensure you have access to publish on [rubygems](https://rubygems.org/gems/swagcov).
- Update [CHANGELOG](https://github.com/smridge/swagcov/blob/main/CHANGELOG.md).
- Update [`VERSION`](https://github.com/smridge/swagcov/blob/main/lib/swagcov/version.rb).
- Run `bundle update` for each sandbox application to reflect new swagcov version in each `Gemfile.lock`
- Open a Pull Request to ensure all specs pass, then merge to `main`.
- Checkout the latest `main` on your machine.
- Run: `rake release`
  - This command builds the gem, creates a tag and publishes to rubygems, see [bundler docs](https://bundler.io/guides/creating_gem.html#releasing-the-gem).

## TODO
- Add autogeneration of ignore paths
- Add `CONTRIBUTING.md`

## Credit
To [@lonelyelk](https://github.com/lonelyelk) for initial development!

## Contributors
<a href="https://github.com/smridge/swagcov/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=smridge/swagcov" />
</a>
