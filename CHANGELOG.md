# CHANGELOG
## main (unreleased)
### Enhancement
- Add support for `.json` OpenAPI file types ([#112](https://github.com/smridge/swagcov/pull/112), [#113](https://github.com/smridge/swagcov/pull/113))
- Update rake task descriptions ([#114](https://github.com/smridge/swagcov/pull/114))
- Improve performance of OpenAPI response key matching for route paths ([#115](https://github.com/smridge/swagcov/pull/115))

## 0.8.1 (2025-04-29)
### Fix
- Performance of coverage output by memoizing path string length ([#108](https://github.com/smridge/swagcov/pull/108))

## 0.8.0 (2025-04-22)
### Enhancement
- Reduce gem dependencies by replacing `rails` with `railties` ([#101](https://github.com/smridge/swagcov/pull/101))
- Remove unnecessary file from gem package ([#105](https://github.com/smridge/swagcov/pull/105))

## 0.7.0 (2025-04-18)
### Enhancement
- Add support for Ruby 3.5 ([#98](https://github.com/smridge/swagcov/pull/98))
- Add rake task for auto-generation of `.swagcov_todo.yml` file ([#93](https://github.com/smridge/swagcov/pull/93), [#96](https://github.com/smridge/swagcov/pull/96))
  ```shell
  bundle exec rake swagcov:generate_todo
  ```

### Refactor
- Add `Swagcov.project_root` method ([#86](https://github.com/smridge/swagcov/pull/86))
- Separate coverage collection and output ([#83](https://github.com/smridge/swagcov/pull/83))
- Replace ActiveSupport string method with ruby string method ([#85](https://github.com/smridge/swagcov/pull/85))
- Replace `Swagcov::Coverage.new.report` with `Swagcov::Command::ReportCoverage.new.run` ([#89](https://github.com/smridge/swagcov/pull/89))
- Rename `Swagcov::Install` to `Swagcov::Command::GenerateDotfile` ([#88](https://github.com/smridge/swagcov/pull/88))
- Refactor `GenerateDotfile` to be consistent with `GenerateTodoFile` ([#97](https://github.com/smridge/swagcov/pull/97))

### Fix
- Add exit code to install task + update messaging ([#87](https://github.com/smridge/swagcov/pull/87))
- Ignored path verb matching when duplicate path keys are present ([#92](https://github.com/smridge/swagcov/pull/92))
- Fix exit code error handling ([#95](https://github.com/smridge/swagcov/pull/95))

### Development
- Add irb console for local development ([#94](https://github.com/smridge/swagcov/pull/94))

## 0.6.0 (2025-04-09)
### Fix
- Grammatical number for endpoint(s) count output ([#78](https://github.com/smridge/swagcov/pull/78))

### Enhancement
- Add support for Rails 4.2 ([#72](https://github.com/smridge/swagcov/pull/72))

### Refactor
- `BREAKING CHANGE`: `Swagcov::BadConfigurationError` is now `Swagcov::Errors::BadConfiguration` ([#74](https://github.com/smridge/swagcov/pull/74))
- `BREAKING CHANGE`: `Swagcov::VERSION` is now `Swagcov::Version::STRING` ([#77](https://github.com/smridge/swagcov/pull/77))
- Improve path matching processing for `ignore` and `only` routes ([#65](https://github.com/smridge/swagcov/pull/65))

### Code Coverage
- Add test coverage reporting ([#68](https://github.com/smridge/swagcov/pull/68), [#69](https://github.com/smridge/swagcov/pull/69))

## 0.5.0 (2025-03-26)
### Enhancement
- Add rake task for configuration installation ([#59](https://github.com/smridge/swagcov/pull/59))
  ```shell
  bundle exec rake swagcov:install
  ```
- Extend `ignore` routes configuration to exclude only specific actions ([#60](https://github.com/smridge/swagcov/pull/60))
  ```yml
  routes:
    paths:
      ignore:
        - /v2/users # existing configuration that ignores all associated actions (verbs)
        - /v2/users/:id: # new option to extend to specific actions
          - GET
  ```

## 0.4.1 (2025-03-18)
### Fix
- Output width for better layout alignment ([#48](https://github.com/smridge/swagcov/pull/48))

### Code Coverage
  - Added official support for ruby 3.3 and 3.4 and rails 7.1, 7.2, 8.0. See [tests.yml](/.github/workflows/tests.yml) for detail

## 0.4.0 (2022-08-11)
  - Improve OpenAPI file processing ([#26](https://github.com/smridge/swagcov/pull/26))

## 0.3.0 (2022-02-21)
### Enhancement
- Raise specific `Swagcov::BadConfigurationError` for malformed yaml files ([#23](https://github.com/smridge/swagcov/pull/23))

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
