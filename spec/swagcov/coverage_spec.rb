# frozen_string_literal: true

RSpec.describe Swagcov::Coverage do
  subject(:init) do
    described_class.new(dotfile: Swagcov::Dotfile.new(pathname: pathname), routes: routes)
  end

  let(:irrelevant_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/anything") }
  let(:articles_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles(.:format)") }
  let(:article_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles/:id(.:format)") }

  let(:routes) do
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
  end

  describe "#report" do
    subject(:result) { init.report }

    let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions.yml") }

    # suppress output in specs
    before { allow($stdout).to receive(:puts) }

    context "when internal route only" do
      before { result }

      let(:routes) do
        [
          instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "GET", internal: true)
        ]
      end

      it { expect(init.total).to eq(0) }
      it { expect(init.covered).to eq(0) }
      it { expect(init.ignored).to eq(0) }
      it { expect(init.routes_not_covered).to eq([]) }
      it { expect(init.routes_ignored).to eq([]) }
      it { expect(init.routes_covered).to eq([]) }
      it { expect(result).to eq(0) }
    end

    context "when route without verb (mounted applications)" do
      before { result }

      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions.yml") }
      let(:routes) do
        [
          instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "", internal: nil)
        ]
      end

      it { expect(init.total).to eq(0) }
      it { expect(init.covered).to eq(0) }
      it { expect(init.ignored).to eq(0) }
      it { expect(init.routes_not_covered).to eq([]) }
      it { expect(init.routes_ignored).to eq([]) }
      it { expect(init.routes_covered).to eq([]) }
      it { expect(result).to eq(0) }
    end

    context "with full documentation coverage and minimal configuration (no only or ignores)" do
      before { result }

      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions.yml") }

      it { expect(init.total).to eq(6) }
      it { expect(init.covered).to eq(6) }
      it { expect(init.ignored).to eq(0) }
      it { expect(init.routes_not_covered).to eq([]) }
      it { expect(init.routes_ignored).to eq([]) }

      it "has array of covered routes" do
        expect(init.routes_covered).to eq(
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

      it { expect(init.total).to eq(6) }
      it { expect(init.covered).to eq(2) }
      it { expect(init.ignored).to eq(0) }
      it { expect(init.routes_ignored).to eq([]) }

      it "has array of uncovered routes" do
        expect(init.routes_not_covered).to eq(
          [
            { verb: "GET", path: "/articles/:id", status: "none" },
            { verb: "PATCH", path: "/articles/:id", status: "none" },
            { verb: "PUT", path: "/articles/:id", status: "none" },
            { verb: "DELETE", path: "/articles/:id", status: "none" }
          ]
        )
      end

      it "has array of covered routes" do
        expect(init.routes_covered).to eq(
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

      it { expect(init.total).to eq(2) }
      it { expect(init.covered).to eq(2) }
      it { expect(init.ignored).to eq(4) }
      it { expect(init.routes_not_covered).to eq([]) }

      it "has array of ignored routes" do
        expect(init.routes_ignored).to eq(
          [
            { verb: "GET", path: "/articles/:id", status: "ignored" },
            { verb: "PATCH", path: "/articles/:id", status: "ignored" },
            { verb: "PUT", path: "/articles/:id", status: "ignored" },
            { verb: "DELETE", path: "/articles/:id", status: "ignored" }
          ]
        )
      end

      it "has array of covered routes" do
        expect(init.routes_covered).to eq(
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

      it { expect(init.total).to eq(4) }
      it { expect(init.covered).to eq(0) }
      it { expect(init.ignored).to eq(2) }
      it { expect(init.routes_covered).to eq([]) }

      it "has array of uncovered routes" do
        expect(init.routes_not_covered).to eq(
          [
            { verb: "GET", path: "/articles/:id", status: "none" },
            { verb: "PATCH", path: "/articles/:id", status: "none" },
            { verb: "PUT", path: "/articles/:id", status: "none" },
            { verb: "DELETE", path: "/articles/:id", status: "none" }
          ]
        )
      end

      it "has array of ignored routes" do
        expect(init.routes_ignored).to eq(
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

      it { expect(init.total).to eq(2) }
      it { expect(init.covered).to eq(2) }
      it { expect(init.ignored).to eq(4) }
      it { expect(init.routes_not_covered).to eq([]) }

      it "has array of ignored routes" do
        expect(init.routes_ignored).to eq(
          [
            { verb: "GET", path: "/articles", status: "ignored" },
            { verb: "POST", path: "/articles", status: "ignored" },
            { verb: "PUT", path: "/articles/:id", status: "ignored" },
            { verb: "DELETE", path: "/articles/:id", status: "ignored" }
          ]
        )
      end

      it "has array of covered routes" do
        expect(init.routes_covered).to eq(
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

      it { expect(init.total).to eq(4) }
      it { expect(init.covered).to eq(4) }
      it { expect(init.ignored).to eq(0) }
      it { expect(init.routes_not_covered).to eq([]) }
      it { expect(init.routes_ignored).to eq([]) }

      it "has array of covered routes" do
        expect(init.routes_covered).to eq(
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

      it { expect(init.total).to eq(4) }
      it { expect(init.covered).to eq(0) }
      it { expect(init.ignored).to eq(0) }
      it { expect(init.routes_ignored).to eq([]) }
      it { expect(init.routes_covered).to eq([]) }

      it "has array of uncovered routes" do
        expect(init.routes_not_covered).to eq(
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
        [
          instance_double(
            ActionDispatch::Journey::Route,
            path: instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles(.:format)"),
            verb: "GET",
            internal: nil
          )
        ]
      end

      it { expect(init.total).to eq(1) }
      it { expect(init.covered).to eq(0) }
      it { expect(init.ignored).to eq(0) }
      it { expect(init.routes_not_covered).to eq([{ verb: "GET", path: "/articles", status: "none" }]) }
      it { expect(init.routes_ignored).to eq([]) }
      it { expect(init.routes_covered).to eq([]) }
      it { expect(result).not_to eq(0) }
    end

    context "when maliformed openapi yaml" do
      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/malinformed_openapi.yml") }

      it { expect { result }.to raise_error(Swagcov::BadConfigurationError) }
    end
  end
end
