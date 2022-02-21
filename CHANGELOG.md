# CHANGELOG
## main (unreleased)
### Code Coverage
  - Add Sandbox Application and specs for Rails 5.1 ([#20](https://github.com/smridge/swagcov/pull/20))
  - Add specs for Rails 5.2 ([#14](https://github.com/smridge/swagcov/pull/14))
  - Add Sandbox Application and specs for Rails 6.0 ([#17](https://github.com/smridge/swagcov/pull/17))
  - Add GitHub CodeQL ([#13](https://github.com/smridge/swagcov/pull/13))
### Security
  - Require Multi-Factor Authentication for RubyGems privileged operations ([#16](https://github.com/smridge/swagcov/pull/16))

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
