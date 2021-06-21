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
    end

    context "with minimal configuration (no only or ignores)" do
      before do
        allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov.yml"))
        init.send(:collect_coverage)
      end

      it { expect(init.total).to eq(6) }
      it { expect(init.covered).to eq(6) }
      it { expect(init.ignored).to eq(0) }
    end

    context "with ignore routes configured" do
      before do
        allow(rails_root).to receive(:join).and_return(Pathname.new("spec/fixtures/files/swagcov_with_ignore.yml"))
        init.send(:collect_coverage)
      end

      it { expect(init.total).to eq(2) }
      it { expect(init.covered).to eq(2) }
      it { expect(init.ignored).to eq(4) }
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
