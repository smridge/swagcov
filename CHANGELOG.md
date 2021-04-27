# CHANGELOG
## main (unreleased)
- Work in Progress
- If a route path does not start with "^" match the entire path
- Raise specific Swagcov::BadConfigurationError error if bad or missing configuration

## 0.2.3 (2021-04-23)
- Fix: Exclude ActiveStorage and ActionMailer routes ([#3](https://github.com/smridge/swagcov/pull/3))

## 0.2.2 (2021-04-22)
- Fix: Exclude Rails Internal Routes and Mounted Applications ([#2](https://github.com/smridge/swagcov/pull/2))

## 0.2.1 (2021-04-21)
- Fix exceptions caused by missing dependency for strings. ([#1](https://github.com/smridge/swagcov/pull/1))
## 0.2.0 (2021-04-20)
- Add exit status to easily build a pass/fail into build pipeline

## 0.1.0 (2021-02-24)
- Create Rake Task for checking documentation coverage (rails only)
