# frozen_string_literal: true

require "action_dispatch/routing/inspector" if Rails::VERSION::STRING < "5"

RSpec.describe Swagcov::Command::GenerateTodoFile do
  subject(:init) { described_class.new(basename: basename, data: data) }

  let(:basename) { ".swagcov_todo_test.yml" }

  before { allow($stdout).to receive(:puts) } # suppress output in spec
  after { FileUtils.rm_f(basename) }

  describe "#run" do
    context "when uncovered routes are empty" do
      let(:data) { [] }

      it "generates a todo configuration file" do
        init.run

        expect(File.read(basename)).to eq(
          <<~YAML
            # This configuration was auto generated
            # The intent is to remove these route configurations as documentation is added

          YAML
        )
      end

      it "has message" do
        expect { init.run }.to output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect(init.run).to eq(0) }
    end

    context "with uncovered routes" do
      let(:data) do
        [
          { verb: "GET", path: "/articles", status: "none" },
          { verb: "PATCH", path: "/articles/:id", status: "none" },
          { verb: "PUT", path: "/articles/:id", status: "none" }
        ]
      end

      it "generates a todo configuration file" do
        init.run

        expect(File.read(basename)).to eq(
          <<~YAML
            # This configuration was auto generated
            # The intent is to remove these route configurations as documentation is added
            ---
            routes:
              paths:
                ignore:
                - "/articles":
                  - GET
                - "/articles/:id":
                  - PATCH
                  - PUT
          YAML
        )
      end

      it "has message" do
        expect { init.run }.to output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect(init.run).to eq(0) }
    end

    context "with existing empty .swavcov_todo.yml file" do
      let(:data) { [] }

      before { init.run } # create existing

      it "generates a todo configuration file" do
        init.run

        expect(File.read(basename)).to eq(
          <<~YAML
            # This configuration was auto generated
            # The intent is to remove these route configurations as documentation is added

          YAML
        )
      end

      it "has message" do
        expect { init.run }.to output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect(init.run).to eq(0) }
    end

    context "with existing ignore config in .swagcov.yml and without full documentation coverage" do
      let(:data) do
        Swagcov::Coverage.new(
          dotfile: Swagcov::Dotfile.new(
            basename: "spec/fixtures/dotfiles/missing_paths_with_ignore.yml", todo_basename: basename, skip_todo: true
          ), routes: routes
        ).collect[:uncovered]
      end

      let(:articles_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles(.:format)") }
      let(:article_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles/:id(.:format)") }

      let(:routes) do
        if Rails::VERSION::STRING > "5"
          [
            instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: "GET", internal: nil),
            instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: "POST", internal: nil),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "GET", internal: nil),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "PATCH", internal: nil),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "PUT", internal: nil),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "DELETE", internal: nil)
          ]
        else
          [
            instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: /^GET$/),
            instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: /^POST$/),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^GET$/),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^PATCH$/),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^PUT$/),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^DELETE$/)
          ]
        end
      end

      before do
        if Rails::VERSION::STRING < "5"
          dbl = instance_double(ActionDispatch::Routing::RouteWrapper, internal?: nil)
          routes.each { |_route| allow(ActionDispatch::Routing::RouteWrapper).to receive(:new).and_return(dbl) }
        end
      end

      it "generates a todo configuration file" do
        init.run

        expect(File.read(basename)).to eq(
          <<~YAML
            # This configuration was auto generated
            # The intent is to remove these route configurations as documentation is added
            ---
            routes:
              paths:
                ignore:
                - "/articles/:id":
                  - GET
                  - PATCH
                  - PUT
                  - DELETE
          YAML
        )
      end

      it "has message" do
        expect { init.run }.to output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect(init.run).to eq(0) }
    end

    context "with existing ignore config in .swagcov_todo.yml" do
      let(:data) do
        Swagcov::Coverage.new(
          dotfile: Swagcov::Dotfile.new(
            basename: "spec/fixtures/dotfiles/missing_paths_with_ignore.yml", todo_basename: basename, skip_todo: true
          ), routes: routes
        ).collect[:uncovered]
      end

      let(:articles_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles(.:format)") }
      let(:article_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles/:id(.:format)") }

      let(:routes) do
        if Rails::VERSION::STRING > "5"
          [
            instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: "GET", internal: nil),
            instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: "POST", internal: nil),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "GET", internal: nil),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "PATCH", internal: nil),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "PUT", internal: nil),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "DELETE", internal: nil)
          ]
        else
          [
            instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: /^GET$/),
            instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: /^POST$/),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^GET$/),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^PATCH$/),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^PUT$/),
            instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^DELETE$/)
          ]
        end
      end

      before do
        if Rails::VERSION::STRING < "5"
          dbl = instance_double(ActionDispatch::Routing::RouteWrapper, internal?: nil)
          routes.each { |_route| allow(ActionDispatch::Routing::RouteWrapper).to receive(:new).and_return(dbl) }
        end

        described_class.new(
          basename: basename,
          data:
            [
              { verb: "GET", path: "/non-existing", status: "200" },
              { verb: "GET", path: "/articles/:id", status: "200" },
              { verb: "PATCH", path: "/articles/:id", status: "200" }
            ]
        ).run # create existing
      end

      it "regenerates a todo configuration file" do
        init.run

        expect(File.read(basename)).to eq(
          <<~YAML
            # This configuration was auto generated
            # The intent is to remove these route configurations as documentation is added
            ---
            routes:
              paths:
                ignore:
                - "/articles/:id":
                  - GET
                  - PATCH
                  - PUT
                  - DELETE
          YAML
        )
      end

      it "has message" do
        expect { init.run }.to output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect(init.run).to eq(0) }
    end
  end
end
