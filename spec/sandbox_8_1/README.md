# README
This is a sandbox application meant to test `swagcov` in a true Rails application environment and for issue debugging.

## Generate Swagger Docs
- Setup: `bundle install`
- Run Tests: `bundle exec rspec spec`
- Run: `bundle exec rspec spec/requests/ --format documentation --format Rswag::Specs::SwaggerFormatter`
