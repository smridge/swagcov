# frozen_string_literal: true

require "action_dispatch/routing/inspector"

RSpec.describe Swagcov::Coverage do
  subject(:init) do
    described_class.new(dotfile: Swagcov::Dotfile.new(pathname: pathname), routes: routes)
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

  describe "#report" do
    subject(:result) { init.report }

    let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions.yml") }

    # before { allow($stdout).to receive(:puts) } # suppress output in specs
    before do
      allow($stdout).to receive(:puts)

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

        result
      end

      let(:routes) do
        if Rails::VERSION::STRING > "5"
          [instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "GET", internal: true)]
        else
          [instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: /^GET$/)]
        end
      end

      it { expect(init.data[:total_count]).to eq(0) }
      it { expect(init.data[:covered_count]).to eq(0) }
      it { expect(init.data[:ignored_count]).to eq(0) }
      it { expect(init.data[:uncovered_count]).to eq(0) }
      it { expect(init.data[:uncovered]).to eq([]) }
      it { expect(init.data[:ignored]).to eq([]) }
      it { expect(init.data[:covered]).to eq([]) }
      it { expect(result).to eq(0) }
    end

    context "when route without verb (mounted applications)" do
      before { result }

      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions.yml") }
      let(:routes) do
        if Rails::VERSION::STRING > "5"
          [instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "", internal: nil)]
        else
          [instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "")]
        end
      end

      it { expect(init.data[:total_count]).to eq(0) }
      it { expect(init.data[:covered_count]).to eq(0) }
      it { expect(init.data[:ignored_count]).to eq(0) }
      it { expect(init.data[:uncovered_count]).to eq(0) }
      it { expect(init.data[:uncovered]).to eq([]) }
      it { expect(init.data[:ignored]).to eq([]) }
      it { expect(init.data[:covered]).to eq([]) }
      it { expect(result).to eq(0) }
    end

    context "with full documentation coverage and minimal configuration (no only or ignores)" do
      before { result }

      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions.yml") }

      it { expect(init.data[:total_count]).to eq(6) }
      it { expect(init.data[:covered_count]).to eq(6) }
      it { expect(init.data[:ignored_count]).to eq(0) }
      it { expect(init.data[:uncovered_count]).to eq(0) }
      it { expect(init.data[:uncovered]).to eq([]) }
      it { expect(init.data[:ignored]).to eq([]) }

      it "has array of covered routes" do
        expect(init.data[:covered]).to eq(
          [
            { verb: "GET", path: "/articles", status: "200" },
            { verb: "POST", path: "/articles", status: "201" },
            { verb: "GET", path: "/articles/:id", status: "200" },
            { verb: "PATCH", path: "/articles/:id", status: "200" },
            { verb: "PUT", path: "/articles/:id", status: "200" },
            { verb: "DELETE", path: "/articles/:id", status: "204" }
          ]
        )
      end

      it { expect(result).to eq(0) }
    end

    context "without full documentation coverage and minimal configuration" do
      before { result }

      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/missing_paths.yml") }

      it { expect(init.data[:total_count]).to eq(6) }
      it { expect(init.data[:covered_count]).to eq(2) }
      it { expect(init.data[:ignored_count]).to eq(0) }
      it { expect(init.data[:uncovered_count]).to eq(4) }
      it { expect(init.data[:ignored]).to eq([]) }

      it "has array of uncovered routes" do
        expect(init.data[:uncovered]).to eq(
          [
            { verb: "GET", path: "/articles/:id", status: "none" },
            { verb: "PATCH", path: "/articles/:id", status: "none" },
            { verb: "PUT", path: "/articles/:id", status: "none" },
            { verb: "DELETE", path: "/articles/:id", status: "none" }
          ]
        )
      end

      it "has array of covered routes" do
        expect(init.data[:covered]).to eq(
          [
            { verb: "GET", path: "/articles", status: "200" },
            { verb: "POST", path: "/articles", status: "201" }
          ]
        )
      end

      it { expect(result).not_to eq(0) }
    end

    context "with full documentation coverage and ignore routes configured" do
      before { result }

      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions_with_ignore.yml") }

      it { expect(init.data[:total_count]).to eq(2) }
      it { expect(init.data[:covered_count]).to eq(2) }
      it { expect(init.data[:ignored_count]).to eq(4) }
      it { expect(init.data[:uncovered_count]).to eq(0) }
      it { expect(init.data[:uncovered]).to eq([]) }

      it "has array of ignored routes" do
        expect(init.data[:ignored]).to eq(
          [
            { verb: "GET", path: "/articles/:id", status: "ignored" },
            { verb: "PATCH", path: "/articles/:id", status: "ignored" },
            { verb: "PUT", path: "/articles/:id", status: "ignored" },
            { verb: "DELETE", path: "/articles/:id", status: "ignored" }
          ]
        )
      end

      it "has array of covered routes" do
        expect(init.data[:covered]).to eq(
          [
            { verb: "GET", path: "/articles", status: "200" },
            { verb: "POST", path: "/articles", status: "201" }
          ]
        )
      end

      it { expect(result).to eq(0) }
    end

    context "without full documentation coverage and ignore routes configured" do
      before { result }

      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/missing_paths_with_ignore.yml") }

      it { expect(init.data[:total_count]).to eq(4) }
      it { expect(init.data[:covered_count]).to eq(0) }
      it { expect(init.data[:ignored_count]).to eq(2) }
      it { expect(init.data[:uncovered_count]).to eq(4) }
      it { expect(init.data[:covered]).to eq([]) }

      it "has array of uncovered routes" do
        expect(init.data[:uncovered]).to eq(
          [
            { verb: "GET", path: "/articles/:id", status: "none" },
            { verb: "PATCH", path: "/articles/:id", status: "none" },
            { verb: "PUT", path: "/articles/:id", status: "none" },
            { verb: "DELETE", path: "/articles/:id", status: "none" }
          ]
        )
      end

      it "has array of ignored routes" do
        expect(init.data[:ignored]).to eq(
          [
            { verb: "GET", path: "/articles", status: "ignored" },
            { verb: "POST", path: "/articles", status: "ignored" }
          ]
        )
      end

      it { expect(result).not_to eq(0) }
    end

    context "with ignored routes configured with actions (verbs)" do
      before { result }

      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/ignored_verbs.yml") }

      it { expect(init.data[:total_count]).to eq(2) }
      it { expect(init.data[:covered_count]).to eq(2) }
      it { expect(init.data[:ignored_count]).to eq(4) }
      it { expect(init.data[:uncovered_count]).to eq(0) }
      it { expect(init.data[:uncovered]).to eq([]) }

      it "has array of ignored routes" do
        expect(init.data[:ignored]).to eq(
          [
            { verb: "GET", path: "/articles", status: "ignored" },
            { verb: "POST", path: "/articles", status: "ignored" },
            { verb: "PUT", path: "/articles/:id", status: "ignored" },
            { verb: "DELETE", path: "/articles/:id", status: "ignored" }
          ]
        )
      end

      it "has array of covered routes" do
        expect(init.data[:covered]).to eq(
          [
            { verb: "GET", path: "/articles/:id", status: "200" },
            { verb: "PATCH", path: "/articles/:id", status: "200" }
          ]
        )
      end

      it { expect(result).to eq(0) }
    end

    context "with full documentation coverage and only routes configured" do
      before { result }

      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions_with_only.yml") }

      it { expect(init.data[:total_count]).to eq(4) }
      it { expect(init.data[:covered_count]).to eq(4) }
      it { expect(init.data[:ignored_count]).to eq(0) }
      it { expect(init.data[:uncovered_count]).to eq(0) }
      it { expect(init.data[:uncovered]).to eq([]) }
      it { expect(init.data[:ignored]).to eq([]) }

      it "has array of covered routes" do
        expect(init.data[:covered]).to eq(
          [
            { verb: "GET", path: "/articles/:id", status: "200" },
            { verb: "PATCH", path: "/articles/:id", status: "200" },
            { verb: "PUT", path: "/articles/:id", status: "200" },
            { verb: "DELETE", path: "/articles/:id", status: "204" }
          ]
        )
      end

      it { expect(result).to eq(0) }
    end

    context "without full documentation coverage and only routes configured" do
      before { result }

      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/missing_paths_with_only.yml") }

      it { expect(init.data[:total_count]).to eq(4) }
      it { expect(init.data[:covered_count]).to eq(0) }
      it { expect(init.data[:ignored_count]).to eq(0) }
      it { expect(init.data[:uncovered_count]).to eq(4) }
      it { expect(init.data[:ignored]).to eq([]) }
      it { expect(init.data[:covered]).to eq([]) }

      it "has array of uncovered routes" do
        expect(init.data[:uncovered]).to eq(
          [
            { verb: "GET", path: "/articles/:id", status: "none" },
            { verb: "PATCH", path: "/articles/:id", status: "none" },
            { verb: "PUT", path: "/articles/:id", status: "none" },
            { verb: "DELETE", path: "/articles/:id", status: "none" }
          ]
        )
      end

      it { expect(result).not_to eq(0) }
    end

    context "when path name partially exists in swagger file" do
      before { result }

      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/v1.yml") }

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

      it { expect(init.data[:total_count]).to eq(1) }
      it { expect(init.data[:covered_count]).to eq(0) }
      it { expect(init.data[:ignored_count]).to eq(0) }
      it { expect(init.data[:uncovered_count]).to eq(1) }
      it { expect(init.data[:uncovered]).to eq([{ verb: "GET", path: "/articles", status: "none" }]) }
      it { expect(init.data[:ignored]).to eq([]) }
      it { expect(init.data[:covered]).to eq([]) }
      it { expect(result).not_to eq(0) }
    end

    context "when maliformed openapi yaml" do
      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/malinformed_openapi.yml") }

      it { expect { result }.to raise_error(Swagcov::Errors::BadConfiguration) }
    end
  end
end
