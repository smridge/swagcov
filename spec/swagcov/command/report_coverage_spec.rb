# frozen_string_literal: true

require "action_dispatch/routing/inspector" if Rails::VERSION::STRING < "5"

RSpec.describe Swagcov::Command::ReportCoverage do
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

  before { allow($stdout).to receive(:puts) } # suppress output in spec

  describe "#run" do
    subject(:result) { init.run }

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

      it { expect(result).to eq(0) }
    end

    context "with full documentation coverage and minimal configuration (no only or ignores)" do
      let(:basename) { "spec/fixtures/dotfiles/no_versions.yml" }

      it { expect(result).to eq(0) }
    end

    context "without full documentation coverage and minimal configuration" do
      let(:basename) { "spec/fixtures/dotfiles/missing_paths.yml" }

      it { expect(result).not_to eq(0) }
    end

    context "with full documentation coverage and ignore routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/no_versions_with_ignore.yml" }

      it { expect(result).to eq(0) }
    end

    context "without full documentation coverage and ignore routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/missing_paths_with_ignore.yml" }

      it { expect(result).not_to eq(0) }
    end

    context "with ignored routes configured with actions (verbs)" do
      let(:basename) { "spec/fixtures/dotfiles/ignored_verbs.yml" }

      it { expect(result).to eq(0) }
    end

    context "with full documentation coverage and only routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/no_versions_with_only.yml" }

      it { expect(result).to eq(0) }
    end

    context "without full documentation coverage and only routes configured" do
      let(:basename) { "spec/fixtures/dotfiles/missing_paths_with_only.yml" }

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

      it { expect(result).not_to eq(0) }
    end

    context "when malformed openapi yaml" do
      let(:basename) { "spec/fixtures/dotfiles/malformed_openapi.yml" }

      it { expect { result }.to raise_error(Swagcov::Errors::BadConfiguration) }
    end
  end
end
