# frozen_string_literal: true

RSpec.describe Swagcov::Coverage do
  subject(:init) { described_class.new }

  let(:rails_root) { instance_double(Pathname) }
  let(:irrelevant_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/anything") }
  let(:articles_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles(.:format)") }
  let(:article_path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/articles/:id(.:format)") }

  let(:fake_routes) do
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

  before do
    allow(Rails).to receive(:root).and_return(rails_root)
    allow(Rails).to receive(:application) do
      double.tap do |application|
        allow(application).to receive(:routes) do
          double.tap { |routes| allow(routes).to receive(:routes).and_return(fake_routes) }
        end
      end
    end
  end

  describe "#report" do
    # suppress output in specs
    before { allow($stdout).to receive(:puts) }

    context "when internal route only" do
      before { allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov.yml")) }

      let(:fake_routes) do
        [
          instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "GET", internal: true)
        ]
      end

      it { expect { init.report }.to raise_exception(SystemExit) }

      it "exits normally" do
        init.report
      rescue SystemExit => e
        expect(e.status).to eq(0)
      end
    end

    context "when route without verb (mounted applications)" do
      before { allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov.yml")) }

      let(:fake_routes) do
        [
          instance_double(ActionDispatch::Journey::Route, path: irrelevant_path, verb: "", internal: nil)
        ]
      end

      it { expect { init.report }.to raise_exception(SystemExit) }

      it "exits normally" do
        init.report
      rescue SystemExit => e
        expect(e.status).to eq(0)
      end
    end

    context "with full documentation coverage and minimal configuration" do
      before { allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov.yml")) }

      it { expect { init.report }.to raise_exception(SystemExit) }

      it "exits normally" do
        init.report
      rescue SystemExit => e
        expect(e.status).to eq(0)
      end
    end

    context "without full documentation coverage and minimal configuration" do
      before do
        allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov_missing_paths.yml"))
      end

      it { expect { init.report }.to raise_exception(SystemExit) }

      it "signals error condition" do
        init.report
      rescue SystemExit => e
        expect(e.status).not_to eq(0)
      end
    end

    context "with full documentation coverage and ignore routes configured" do
      before do
        allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov_with_ignore.yml"))
      end

      it { expect { init.report }.to raise_exception(SystemExit) }

      it "exits normally" do
        init.report
      rescue SystemExit => e
        expect(e.status).to eq(0)
      end
    end

    context "without full documentation coverage and ignore routes configured" do
      before do
        allow(rails_root).to receive(:join).and_return(
          Pathname.new("spec/fixtures/files/swagcov_missing_paths_ignore.yml")
        )
      end

      it { expect { init.report }.to raise_exception(SystemExit) }

      it "signals error condition" do
        init.report
      rescue SystemExit => e
        expect(e.status).not_to eq(0)
      end
    end

    context "with full documentation coverage and only routes configured" do
      before do
        allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov_with_only.yml"))
      end

      it { expect { init.report }.to raise_exception(SystemExit) }

      it "exits normally" do
        init.report
      rescue SystemExit => e
        expect(e.status).to eq(0)
      end
    end

    context "without full documentation coverage and only routes configured" do
      before do
        allow(rails_root).to receive(:join).and_return(
          Pathname.new("spec/fixtures/files/swagcov_missing_paths_only.yml")
        )
      end

      it { expect { init.report }.to raise_exception(SystemExit) }

      it "signals error condition" do
        init.report
      rescue SystemExit => e
        expect(e.status).not_to eq(0)
      end
    end
  end

  describe "#collect_coverage" do
    context "when internal route" do
      before do
        allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov.yml"))
        init.send(:collect_coverage)
      end

      let(:fake_routes) do
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
      before do
        allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov.yml"))
        init.send(:collect_coverage)
      end

      let(:fake_routes) do
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
      before do
        allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov.yml"))
        init.send(:collect_coverage)
      end

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
      before do
        allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov_with_ignore.yml"))
        init.send(:collect_coverage)
      end

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
      before do
        allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov_with_only.yml"))
        init.send(:collect_coverage)
      end

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
  end
end
