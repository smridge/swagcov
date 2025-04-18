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

## Console Session
```shell
$ chmod +x bin/console
$ ./bin/console
> # use `reload!` to capture code changes in existing console session
```

## Run Tests
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
- Ensure you have access to publish on [rubygems](https://rubygems.org/gems/swagcov)
- Update [CHANGELOG](/CHANGELOG.md)
- Update [`Swagcov::Version::STRING`](/lib/swagcov/version.rb)
- Run `bundle update` at the gem root and for each sandbox application to reflect new swagcov version in each `Gemfile.lock`
- Open a Pull Request to ensure all specs pass, then merge to `main`
- Checkout the latest `main` on your machine
- Run: `rake release`
  - This command builds the gem, creates a tag and publishes to rubygems, see [bundler docs](https://bundler.io/guides/creating_gem.html#releasing-the-gem).

---

## TODO
- Add autogeneration of ignore paths
- Skip new/edit GET routes designed as rails default html forms (for non api_only apps)
