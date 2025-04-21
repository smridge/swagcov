# frozen_string_literal: true

require "action_dispatch/routing/inspector" if Rails::VERSION::STRING < "5"

RSpec.describe Swagcov::Coverage do
  subject(:init) do
    described_class.new(dotfile: Swagcov::Dotfile.new(basename: basename), routes: routes)
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

  describe "#collect" do
    subject(:result) { init.collect }

    before do
      if Rails::VERSION::STRING < "5"
        dbl = instance_double(ActionDispatch::Routing::RouteWrapper, internal?: nil)
        routes.each { |_route| allow(ActionDispatch::Routing::RouteWrapper).to receive(:new).and_return(dbl) }
      end
    end

    context "when internal route only" do
      let(:basename) { "spec/fixtures/dotfiles/no_versions.yml" }
      let(:routes) do
        if Rails::VERSION::STRING > "5"
          [instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "GET", internal: true)]
        else
          [instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: /^GET$/)]
        end
      end

      before do
        if Rails::VERSION::STRING < "5"
          dbl = instance_double(ActionDispatch::Routing::RouteWrapper, internal?: 0)
          routes.each { |_route| allow(ActionDispatch::Routing::RouteWrapper).to receive(:new).and_return(dbl) }
        end
      end

      it "collects route data" do
        expect(result).to eq(
          {
            covered: [],
            ignored: [],
            uncovered: [],
            total_count: 0,
            covered_count: 0,
            ignored_count: 0,
            uncovered_count: 0
          }
        )
      end
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

      it "collects route data" do
        expect(result).to eq(
          {
            covered: [],
            ignored: [],
            uncovered: [],
            total_count: 0,
            covered_count: 0,
            ignored_count: 0,
            uncovered_count: 0
          }
        )
      end
    end

    context "with full documentation coverage and minimal configuration (no only or ignores)" do
      let(:basename) { "spec/fixtures/dotfiles/no_versions.yml" }

      it "collects route data" do
        expect(result).to eq(
          {
            covered:
              [
                { verb: "GET", path: "/articles", status: "200" },
                { verb: "POST", path: "/articles", status: "201" },
                { verb: "GET", path: "/articles/:id", status: "200" },
                { verb: "PATCH", path: "/articles/:id", status: "200" },
                { verb: "PUT", path: "/articles/:id", status: "200" },
                { verb: "DELETE", path: "/articles/:id", status: "204" }
              ],
            ignored: [],
            uncovered: [],
            total_count: 6,
            covered_count: 6,
            ignored_count: 0,
            uncovered_count: 0
          }
        )
      end
    end

    context "without full documentation coverage and minimal configuration" do
      let(:basename) { "spec/fixtures/dotfiles/missing_paths.yml" }

      it "collects route data" do
        expect(result).to eq(
          {
            covered:
              [
                { verb: "GET", path: "/articles", status: "200" },
                { verb: "POST", path: "/articles", status: "201" }
              ],
            ignored: [],
            uncovered:
              [
                { verb: "GET", path: "/articles/:id", status: "none" },
                { verb: "PATCH", path: "/articles/:id", status: "none" },
                { verb: "PUT", path: "/articles/:id", status: "none" },
                { verb: "DELETE", path: "/articles/:id", status: "none" }
              ],
            total_count: 6,
            covered_count: 2,
            ignored_count: 0,
            uncovered_count: 4
          }
        )
      end
    end

    context "with full documentation coverage and ignore routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/no_versions_with_ignore.yml" }

      it "collects route data" do
        expect(result).to eq(
          {
            covered:
              [
                { verb: "GET", path: "/articles", status: "200" },
                { verb: "POST", path: "/articles", status: "201" }
              ],
            ignored:
              [
                { verb: "GET", path: "/articles/:id", status: "ignored" },
                { verb: "PATCH", path: "/articles/:id", status: "ignored" },
                { verb: "PUT", path: "/articles/:id", status: "ignored" },
                { verb: "DELETE", path: "/articles/:id", status: "ignored" }
              ],
            uncovered: [],
            total_count: 2,
            covered_count: 2,
            ignored_count: 4,
            uncovered_count: 0
          }
        )
      end
    end

    context "without full documentation coverage and ignore routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/missing_paths_with_ignore.yml" }

      it "collects route data" do
        expect(result).to eq(
          {
            covered: [],
            ignored:
              [
                { verb: "GET", path: "/articles", status: "ignored" },
                { verb: "POST", path: "/articles", status: "ignored" }
              ],
            uncovered:
              [
                { verb: "GET", path: "/articles/:id", status: "none" },
                { verb: "PATCH", path: "/articles/:id", status: "none" },
                { verb: "PUT", path: "/articles/:id", status: "none" },
                { verb: "DELETE", path: "/articles/:id", status: "none" }
              ],
            total_count: 4,
            covered_count: 0,
            ignored_count: 2,
            uncovered_count: 4
          }
        )
      end
    end

    context "with ignored routes configured with actions (verbs)" do
      before { result }

      let(:basename) { "spec/fixtures/dotfiles/ignored_verbs.yml" }

      it "collects route data" do
        expect(result).to eq(
          {
            covered:
              [
                { verb: "GET", path: "/articles/:id", status: "200" },
                { verb: "PATCH", path: "/articles/:id", status: "200" }
              ],
            ignored:
              [
                { verb: "GET", path: "/articles", status: "ignored" },
                { verb: "POST", path: "/articles", status: "ignored" },
                { verb: "PUT", path: "/articles/:id", status: "ignored" },
                { verb: "DELETE", path: "/articles/:id", status: "ignored" }
              ],
            uncovered: [],
            total_count: 2,
            covered_count: 2,
            ignored_count: 4,
            uncovered_count: 0
          }
        )
      end
    end

    context "with full documentation coverage and only routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/no_versions_with_only.yml" }

      it "collects route data" do
        expect(result).to eq(
          {
            covered:
              [
                { verb: "GET", path: "/articles/:id", status: "200" },
                { verb: "PATCH", path: "/articles/:id", status: "200" },
                { verb: "PUT", path: "/articles/:id", status: "200" },
                { verb: "DELETE", path: "/articles/:id", status: "204" }
              ],
            ignored: [],
            uncovered: [],
            total_count: 4,
            covered_count: 4,
            ignored_count: 0,
            uncovered_count: 0
          }
        )
      end
    end

    context "without full documentation coverage and only routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/missing_paths_with_only.yml" }

      it "collects route data" do
        expect(result).to eq(
          {
            covered: [],
            ignored: [],
            uncovered:
              [
                { verb: "GET", path: "/articles/:id", status: "none" },
                { verb: "PATCH", path: "/articles/:id", status: "none" },
                { verb: "PUT", path: "/articles/:id", status: "none" },
                { verb: "DELETE", path: "/articles/:id", status: "none" }
              ],
            total_count: 4,
            covered_count: 0,
            ignored_count: 0,
            uncovered_count: 4
          }
        )
      end
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

      it "collects route data" do
        expect(result).to eq(
          {
            covered: [],
            ignored: [],
            uncovered: [{ verb: "GET", path: "/articles", status: "none" }],
            total_count: 1,
            covered_count: 0,
            ignored_count: 0,
            uncovered_count: 1
          }
        )
      end
    end

    context "when malformed openapi yaml" do
      let(:basename) { "spec/fixtures/dotfiles/malformed_openapi.yml" }

      it { expect { result }.to raise_error(Swagcov::Errors::BadConfiguration) }
    end

    context "without rails routes" do
      subject(:init) do
        described_class.new(dotfile: Swagcov::Dotfile.new(basename: basename))
      end

      let(:basename) { "spec/fixtures/dotfiles/dotfile.yml" }

      it "does not fail" do
        expect(result).to eq(
          {
            covered: [],
            ignored: [],
            uncovered: [],
            total_count: 0,
            covered_count: 0,
            ignored_count: 0,
            uncovered_count: 0
          }
        )
      end
    end
  end
end
