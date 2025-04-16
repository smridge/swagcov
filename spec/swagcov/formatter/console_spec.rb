# frozen_string_literal: true

require "action_dispatch/routing/inspector" if Rails::VERSION::STRING < "5"

RSpec.describe Swagcov::Formatter::Console do
  subject(:init) do
    described_class.new(
      data: Swagcov::Coverage.new(dotfile: Swagcov::Dotfile.new(basename: basename), routes: routes).collect
    )
  end

  let(:irrelevant_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/anything") }
  let(:articles_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles(.:format)") }
  let(:article_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles/:id(.:format)") }

  let(:routes) do
    if Rails::VERSION::STRING > "5"
      [
        instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "GET", internal: true),
        instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "", internal: nil),
        instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: "GET", internal: nil),
        instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: "POST", internal: nil),
        instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "GET", internal: nil),
        instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "PATCH", internal: nil),
        instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "PUT", internal: nil),
        instance_double(ActionDispatch::Journey::Route, path: article_path, verb: "DELETE", internal: nil)
      ]
    else
      [
        instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: ""),
        instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: /^GET$/),
        instance_double(ActionDispatch::Journey::Route, path: articles_path, verb: /^POST$/),
        instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^GET$/),
        instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^PATCH$/),
        instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^PUT$/),
        instance_double(ActionDispatch::Journey::Route, path: article_path, verb: /^DELETE$/)
      ]
    end
  end

  before { allow($stdout).to receive(:puts) }

  describe "#run" do
    subject(:result) { init.run }

    let(:basename) { "spec/fixtures/dotfiles/no_versions.yml" }

    before do
      if Rails::VERSION::STRING < "5"
        dbl = instance_double(ActionDispatch::Routing::RouteWrapper, internal?: nil)
        routes.each { |_route| allow(ActionDispatch::Routing::RouteWrapper).to receive(:new).and_return(dbl) }
      end
    end

    context "when internal route only" do
      before do
        if Rails::VERSION::STRING < "5"
          dbl = instance_double(ActionDispatch::Routing::RouteWrapper, internal?: 0)
          routes.each { |_route| allow(ActionDispatch::Routing::RouteWrapper).to receive(:new).and_return(dbl) }
        end
      end

      let(:routes) do
        if Rails::VERSION::STRING > "5"
          [instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "GET", internal: true)]
        else
          [instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: /^GET$/)]
        end
      end

      # rubocop:disable Layout/EmptyLinesAroundArguments
      it "outputs coverage" do
        expect { result }.to output(
          <<~MESSAGE

            OpenAPI documentation coverage NaN% (0/0)
            #{0.to_s.yellow} ignored endpoints
            #{0.to_s.blue} total endpoints
            #{0.to_s.green} covered endpoints
            #{0.to_s.red} uncovered endpoints
          MESSAGE
        ).to_stdout
      end

      it { expect(result).to eq(0) }
    end

    context "when route without verb (mounted applications)" do
      let(:basename) { "spec/fixtures/dotfiles/no_versions.yml" }
      let(:routes) do
        if Rails::VERSION::STRING > "5"
          [instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "", internal: nil)]
        else
          [instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "")]
        end
      end

      it "outputs coverage" do
        expect { result }.to output(
          <<~MESSAGE

            OpenAPI documentation coverage NaN% (0/0)
            #{0.to_s.yellow} ignored endpoints
            #{0.to_s.blue} total endpoints
            #{0.to_s.green} covered endpoints
            #{0.to_s.red} uncovered endpoints
          MESSAGE
        ).to_stdout
      end
      # rubocop:enable Layout/EmptyLinesAroundArguments

      it { expect(result).to eq(0) }
    end

    context "with full documentation coverage and minimal configuration (no only or ignores)" do
      let(:basename) { "spec/fixtures/dotfiles/no_versions.yml" }

      it "outputs coverage" do
        expect { result }.to output(
          <<~MESSAGE
                   GET /articles      #{200.to_s.green}
                  POST /articles      #{201.to_s.green}
                   GET /articles/:id  #{200.to_s.green}
                 PATCH /articles/:id  #{200.to_s.green}
                   PUT /articles/:id  #{200.to_s.green}
                DELETE /articles/:id  #{204.to_s.green}

            OpenAPI documentation coverage 100.00% (6/6)
            #{0.to_s.yellow} ignored endpoints
            #{6.to_s.blue} total endpoints
            #{6.to_s.green} covered endpoints
            #{0.to_s.red} uncovered endpoints
          MESSAGE
        ).to_stdout
      end

      it { expect(result).to eq(0) }
    end

    context "without full documentation coverage and minimal configuration" do
      let(:basename) { "spec/fixtures/dotfiles/missing_paths.yml" }

      it "outputs coverage" do
        expect { result }.to output(
          <<~MESSAGE
                   GET /articles      #{200.to_s.green}
                  POST /articles      #{201.to_s.green}
                   GET /articles/:id  #{'none'.red}
                 PATCH /articles/:id  #{'none'.red}
                   PUT /articles/:id  #{'none'.red}
                DELETE /articles/:id  #{'none'.red}

            OpenAPI documentation coverage 33.33% (2/6)
            #{0.to_s.yellow} ignored endpoints
            #{6.to_s.blue} total endpoints
            #{2.to_s.green} covered endpoints
            #{4.to_s.red} uncovered endpoints
          MESSAGE
        ).to_stdout
      end

      it { expect(result).not_to eq(0) }
    end

    context "with full documentation coverage and ignore routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/no_versions_with_ignore.yml" }

      it "outputs coverage" do
        expect { result }.to output(
          <<~MESSAGE
                   GET /articles      #{200.to_s.green}
                  POST /articles      #{201.to_s.green}
                   GET /articles/:id  #{'ignored'.yellow}
                 PATCH /articles/:id  #{'ignored'.yellow}
                   PUT /articles/:id  #{'ignored'.yellow}
                DELETE /articles/:id  #{'ignored'.yellow}

            OpenAPI documentation coverage 100.00% (2/2)
            #{4.to_s.yellow} ignored endpoints
            #{2.to_s.blue} total endpoints
            #{2.to_s.green} covered endpoints
            #{0.to_s.red} uncovered endpoints
          MESSAGE
        ).to_stdout
      end

      it { expect(result).to eq(0) }
    end

    context "without full documentation coverage and ignore routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/missing_paths_with_ignore.yml" }

      it "outputs coverage" do
        expect { result }.to output(
          <<~MESSAGE
                   GET /articles      #{'ignored'.yellow}
                  POST /articles      #{'ignored'.yellow}
                   GET /articles/:id  #{'none'.red}
                 PATCH /articles/:id  #{'none'.red}
                   PUT /articles/:id  #{'none'.red}
                DELETE /articles/:id  #{'none'.red}

            OpenAPI documentation coverage 0.00% (0/4)
            #{2.to_s.yellow} ignored endpoints
            #{4.to_s.blue} total endpoints
            #{0.to_s.green} covered endpoints
            #{4.to_s.red} uncovered endpoints
          MESSAGE
        ).to_stdout
      end

      it { expect(result).not_to eq(0) }
    end

    context "with ignored routes configured with actions (verbs)" do
      let(:basename) { "spec/fixtures/dotfiles/ignored_verbs.yml" }

      it "outputs coverage" do
        expect { result }.to output(
          <<~MESSAGE
                   GET /articles/:id  #{'200'.green}
                 PATCH /articles/:id  #{'200'.green}
                   GET /articles      #{'ignored'.yellow}
                  POST /articles      #{'ignored'.yellow}
                   PUT /articles/:id  #{'ignored'.yellow}
                DELETE /articles/:id  #{'ignored'.yellow}

            OpenAPI documentation coverage 100.00% (2/2)
            #{4.to_s.yellow} ignored endpoints
            #{2.to_s.blue} total endpoints
            #{2.to_s.green} covered endpoints
            #{0.to_s.red} uncovered endpoints
          MESSAGE
        ).to_stdout
      end

      it { expect(result).to eq(0) }
    end

    context "with full documentation coverage and only routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/no_versions_with_only.yml" }

      it "outputs coverage" do
        expect { result }.to output(
          <<~MESSAGE
                   GET /articles/:id  #{'200'.green}
                 PATCH /articles/:id  #{'200'.green}
                   PUT /articles/:id  #{'200'.green}
                DELETE /articles/:id  #{'204'.green}

            OpenAPI documentation coverage 100.00% (4/4)
            #{0.to_s.yellow} ignored endpoints
            #{4.to_s.blue} total endpoints
            #{4.to_s.green} covered endpoints
            #{0.to_s.red} uncovered endpoints
          MESSAGE
        ).to_stdout
      end

      it { expect(result).to eq(0) }
    end

    context "without full documentation coverage and only routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/missing_paths_with_only.yml" }

      it "outputs coverage" do
        expect { result }.to output(
          <<~MESSAGE
                   GET /articles/:id  #{'none'.red}
                 PATCH /articles/:id  #{'none'.red}
                   PUT /articles/:id  #{'none'.red}
                DELETE /articles/:id  #{'none'.red}

            OpenAPI documentation coverage 0.00% (0/4)
            #{0.to_s.yellow} ignored endpoints
            #{4.to_s.blue} total endpoints
            #{0.to_s.green} covered endpoints
            #{4.to_s.red} uncovered endpoints
          MESSAGE
        ).to_stdout
      end

      it { expect(result).not_to eq(0) }
    end

    context "when path name partially exists in swagger file" do
      let(:basename) { "spec/fixtures/dotfiles/v1.yml" }

      let(:routes) do
        if Rails::VERSION::STRING > "5"
          [
            instance_double(
              ActionDispatch::Journey::Route,
              path: instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles(.:format)"),
              verb: "GET",
              internal: nil
            )
          ]
        else
          [
            instance_double(
              ActionDispatch::Journey::Route,
              path: instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles(.:format)"),
              verb: /^GET$/
            )
          ]
        end
      end

      it "outputs coverage" do
        expect { result }.to output(
          <<~MESSAGE
                   GET /articles  #{'none'.red}

            OpenAPI documentation coverage 0.00% (0/1)
            #{0.to_s.yellow} ignored endpoints
            #{1.to_s.blue} total endpoint
            #{0.to_s.green} covered endpoints
            #{1.to_s.red} uncovered endpoint
          MESSAGE
        ).to_stdout
      end

      it { expect(result).not_to eq(0) }
    end

    context "when malformed openapi yaml" do
      let(:basename) { "spec/fixtures/dotfiles/malformed_openapi.yml" }

      it { expect { result }.to raise_error(Swagcov::Errors::BadConfiguration) }
    end
  end
end
