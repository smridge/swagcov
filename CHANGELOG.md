# CHANGELOG
## main (unreleased)

## 0.4.1 (2025-03-18)
### Fix
- Output width for better layout alignment ([#48](https://github.com/smridge/swagcov/pull/48))

### Code Coverage
  - Added official support for ruby 3.3 and 3.4 and rails 7.1, 7.2, 8.0. See [unit_tests.yml](/.github/workflows/unit_tests.yml) and [system_tests.yml](/.github/workflows/system_tests.yml) for detail

## 0.4.0 (2022-08-11)
  - Improve OpenAPI file processing ([#26](https://github.com/smridge/swagcov/pull/26))

## 0.3.0 (2022-02-21)
### Enhancement
  - Raise specific `Swagcov::BadConfigurationError` for malinformed yaml files ([#23](https://github.com/smridge/swagcov/pull/23))

### Security
  - Require Multi-Factor Authentication for RubyGems privileged operations ([#16](https://github.com/smridge/swagcov/pull/16))

### Code Coverage
  - Add Sandbox Application and specs for Rails 5.1 ([#20](https://github.com/smridge/swagcov/pull/20))
  - Add specs for Rails 5.2 ([#7](https://github.com/smridge/swagcov/pull/7)), ([#14](https://github.com/smridge/swagcov/pull/14))
  - Add Sandbox Application and specs for Rails 6.0 ([#17](https://github.com/smridge/swagcov/pull/17))
  - Add Sandbox Application and specs for Rails 6.1 ([#22](https://github.com/smridge/swagcov/pull/22))
  - Add GitHub Actions to run specs ([#18](https://github.com/smridge/swagcov/pull/18))
  - Add GitHub CodeQL ([#13](https://github.com/smridge/swagcov/pull/13))

### Refactor
  - Move `SystemExit` to rake task for easier testing ([#24](https://github.com/smridge/swagcov/pull/24))
  - Reduce complexity when matching routes ([#15](https://github.com/smridge/swagcov/pull/15))

## 0.2.5 (2021-09-14)
### Fix
  - Matching routes against swagger paths. Previously, partial paths could result in a match ([#12](https://github.com/smridge/swagcov/pull/12))

## 0.2.4 (2021-04-30)
### Fix
  - If a route path does not start with "^" match the entire path ([#5](https://github.com/smridge/swagcov/pull/5))
### Enhancement
  - Raise specific `Swagcov::BadConfigurationError` error if bad or missing configuration ([#5](https://github.com/smridge/swagcov/pull/5))

## 0.2.3 (2021-04-23)
### Fix
  - Exclude ActiveStorage and ActionMailer routes ([#3](https://github.com/smridge/swagcov/pull/3))

## 0.2.2 (2021-04-22)
### Fix
  - Exclude Rails Internal Routes and Mounted Applications ([#2](https://github.com/smridge/swagcov/pull/2))

## 0.2.1 (2021-04-21)
### Fix
  - Exceptions caused by missing dependency for strings. ([#1](https://github.com/smridge/swagcov/pull/1))

## 0.2.0 (2021-04-20)
### Enhancement
  - Add Exit status to easily build a pass/fail into build pipeline

## 0.1.0 (2021-02-24)
- Create Rake Task for checking documentation coverage (rails only)
