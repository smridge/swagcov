# Swagcov
See coverage report for openapi docs for Rails Routes.

## Installation
Add this line to your application's Gemfile:
```ruby
gem "swagcov", github: "smridge/swagcov", branch: "main"
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
        - /sidekiq
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
        - /sidekiq
  ```

Execute:
```shell
bundle exec rake swagcov
```

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

## TODO
- Add specs
- Test against different rails versions
- Add autogeneration of ignore paths

## Credit
To [@lonelyelk](https://github.com/lonelyelk) for initial development!
