# README
This is a sandbox application meant to test `swagcov` in a true Rails application environment and for issue debugging.
- All generic controllers and corresponding rspec rswag tests _should_ essentially be copied and pasted to generate the minimum `swagger.yml` file needed to test.

## Generate Swagger Docs
- Setup Test Database: `bundle exec rails db:create`
- Run Tests: `bundle exec rspec spec`
- Run: `bundle exec rspec spec/requests/ --format documentation --format Rswag::Specs::SwaggerFormatter`
