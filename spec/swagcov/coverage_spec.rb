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
    let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions.yml") }

    # suppress output in specs
    before { allow($stdout).to receive(:puts) }

    context "when internal route only" do
      let(:routes) do
        [
          instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "GET", internal: true)
        ]
      end

      it { expect { init.report }.to raise_exception(SystemExit) }
      it { expect { init.report }.to exit_with_code(0) }
    end

    context "when route without verb (mounted applications)" do
      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions.yml") }
      let(:routes) do
        [
          instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "", internal: nil)
        ]
      end

      it { expect { init.report }.to raise_exception(SystemExit) }
      it { expect { init.report }.to exit_with_code(0) }
    end

    context "with full documentation coverage and minimal configuration" do
      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions.yml") }

      it { expect { init.report }.to raise_exception(SystemExit) }
      it { expect { init.report }.to exit_with_code(0) }
    end

    context "without full documentation coverage and minimal configuration" do
      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/missing_paths.yml") }

      it { expect { init.report }.to raise_exception(SystemExit) }
      it { expect { init.report }.not_to exit_with_code(0) }
    end

    context "with full documentation coverage and ignore routes configured" do
      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions_with_ignore.yml") }

      it { expect { init.report }.to raise_exception(SystemExit) }
      it { expect { init.report }.to exit_with_code(0) }
    end

    context "without full documentation coverage and ignore routes configured" do
      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/missing_paths_with_ignore.yml") }

      it { expect { init.report }.to raise_exception(SystemExit) }
      it { expect { init.report }.not_to exit_with_code(0) }
    end

    context "with full documentation coverage and only routes configured" do
      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions_with_only.yml") }

      it { expect { init.report }.to raise_exception(SystemExit) }
      it { expect { init.report }.to exit_with_code(0) }
    end

    context "without full documentation coverage and only routes configured" do
      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/missing_paths_with_only.yml") }

      it { expect { init.report }.to raise_exception(SystemExit) }
      it { expect { init.report }.not_to exit_with_code(0) }
    end
  end

  describe "#collect_coverage" do
    before { init.send(:collect_coverage) }

    context "when internal route" do
      let(:pathname) { Pathname.new("spec/fixtures/dotfiles/no_versions.yml") }
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
    end

    context "when route without verb (mounted applications)" do
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
    end

    context "with minimal configuration (no only or ignores)" do
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
    end

    context "with ignore routes configured" do
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
    end

    context "with only routes configured" do
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
    end

    context "when path name partially exists in swagger file" do
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
    end
  end
end
