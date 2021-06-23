# Swagcov
See coverage report for openapi docs for Rails Routes.

## Installation
Add this line to your application's Gemfile:
```ruby
gem "swagcov"
```

Execute:
```shell
bundle
```

Create a `.swagcov.yml` in root of your Rails application.
- Add the paths of your `openapi` yml files (**required**):
  ```yml
  docs:
    paths:
      - swagger/v1/swagger.yaml
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

- Example `.swagcov.yml` Config File:
  ```yml
  docs:
    paths:
      - swagger/v1/swagger.yaml

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

## Example configurations and output from running `bundle exec rake swagcov` from the root of your Rails Application:
- All Routes (minimal configuration):
  ```yml
  docs:
    paths:
      - swagger.yaml
  ```
  <img src="https://raw.githubusercontent.com/smridge/swagcov/main/images/all-endpoints.png" width="400">


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
  <img src="https://raw.githubusercontent.com/smridge/swagcov/main/images/only-endpoints.png" width="400">

- With `ignore` and `only` endpoint configurations:
  ```yml
  docs:
    paths:
      - swagger/v1/swagger.yaml

  routes:
    paths:
      only:
        - ^/v2
      ignore:
        - /v2/users
  ```
  <img src="https://raw.githubusercontent.com/smridge/swagcov/main/images/ignore-and-only-endpoints.png" width="400">

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
bundle exec rspec spec --exclude-pattern spec/sandbox_5_2/**/*_spec.rb
```

### Test via Sandbox Application
For Rails 5
- `cd spec/sandbox_5_2/`
- Run tests: `bundle exec rspec spec`
- Run `bundle exec rake swagcov`
  - This will run against any changes made to your branch.

## Publish (internal)
> Note: Publishing a new version of this gem is only meant for maintainers.
- Ensure you have access to publish on [rubygems](https://rubygems.org/gems/swagcov).
- Update [CHANGELOG](https://github.com/smridge/swagcov/blob/main/CHANGELOG.md).
- Update [`VERSION`](https://github.com/smridge/swagcov/blob/main/lib/swagcov/version.rb).
- Commit changes to `main` branch locally.
- Run: `rake release`
  - This command builds the gem, creates a tag and publishes to rubygems, see [bundler docs](https://bundler.io/guides/creating_gem.html#releasing-the-gem).

## TODO
- Add specs
- Test against different rails versions
- Create Sandbox App for Rails 6
- Add autogeneration of ignore paths
- Add `CONTRIBUTING.md`
- Add GitHub Actions for specs/linting

## Credit
To [@lonelyelk](https://github.com/lonelyelk) for initial development!
