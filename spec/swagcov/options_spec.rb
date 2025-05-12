# frozen_string_literal: true

RSpec.describe Swagcov::Options do
  subject(:init) do
    described_class.new(args: args)
  end

  describe "#define" do
    context "without options" do
      let(:args) { [] }

      it { expect(init.define).to eq({}) }
    end

    context "with invalid options" do
      let(:args) { ["--foobar"] }

      it "prints message" do
        expect { init.define }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            invalid option: --foobar
            For usage information, use --help
          MESSAGE
        ).to_stderr
      end

      it { expect { init.define }.to exit_with_code(2) }
    end

    context "with -h" do
      let(:args) { ["-h"] }

      it "prints options" do
        expect { init.define }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            Usage:
            * as executable: swagcov [options]
            * as rake task: rake swagcov -- [options]
                -i, --init                       Generate required .swagcov.yml config file
                -t, --todo                       Generate optional .swagcov_todo.yml config file
                -v, --version                    Display version
          MESSAGE
        ).to_stdout
      end

      it { expect { init.define }.to exit_with_code(0) }
    end

    context "with --help" do
      let(:args) { ["--help"] }

      it "prints options" do
        expect { init.define }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            Usage:
            * as executable: swagcov [options]
            * as rake task: rake swagcov -- [options]
                -i, --init                       Generate required .swagcov.yml config file
                -t, --todo                       Generate optional .swagcov_todo.yml config file
                -v, --version                    Display version
          MESSAGE
        ).to_stdout
      end

      it { expect { init.define }.to exit_with_code(0) }
    end

    context "with valid shorthand options" do
      let(:args) { ["-i", "-t", "-v"] }

      it { expect(init.define).to eq({ init: true, todo: true, version: true }) }
      it { expect(described_class.new(args: ["-i"]).define).to eq({ init: true }) }
      it { expect(described_class.new(args: ["-t"]).define).to eq({ todo: true }) }
      it { expect(described_class.new(args: ["-v"]).define).to eq({ version: true }) }
    end

    context "with valid explicit options" do
      let(:args) { ["--init", "--todo", "--version"] }

      it { expect(init.define).to eq({ init: true, todo: true, version: true }) }
      it { expect(described_class.new(args: ["--init"]).define).to eq({ init: true }) }
      it { expect(described_class.new(args: ["--todo"]).define).to eq({ todo: true }) }
      it { expect(described_class.new(args: ["--version"]).define).to eq({ version: true }) }
    end
  end
end
