# frozen_string_literal: true

# require "action_dispatch/routing/inspector" if Rails::VERSION::STRING < "5"

RSpec.describe Swagcov::Runner do
  subject(:init) do
    described_class.new(args: args)
  end

  context "with --help" do
    let(:args) { ["--help"] }

    it "prints options" do
      expect { init.run }.to raise_exception(SystemExit).and output(
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

    it { expect { init.run }.to exit_with_code(0) }
    it { expect { described_class.new(args: ["-h"]).run }.to exit_with_code(0) }
  end

  context "with --init" do
    let(:args) { ["--init"] }
    let(:dotfile_basename) { ".swagcov_test.yml" }

    before { stub_const("Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME", dotfile_basename) }
    after { FileUtils.rm_f(dotfile_basename) }

    context "when dotfile does not exist" do
      it "creates a minimum configuration file" do
        init.run
      rescue SystemExit => _e
        expect(File.read(dotfile_basename)).to eq(
          <<~YAML
            ## Required field:
            # List your OpenAPI documentation file(s) (accepts json or yaml)
            docs:
              paths:
                - swagger.yaml
                - swagger.json

            ## Optional fields:
            # routes:
            #   paths:
            #     only:
            #       - ^/v2 # only track v2 endpoints
            #     ignore:
            #       - /v2/users # do not track certain endpoints
            #       - /v2/users/:id: # ignore only certain actions (verbs)
            #         - GET
          YAML
        )
      end

      it "outputs message" do
        expect { init.run }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            created #{dotfile_basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect { init.run }.to exit_with_code(0) }
      it { expect { described_class.new(args: ["-i"]).run }.to exit_with_code(0) }
    end

    context "when dotfile exists" do
      before do
        Swagcov::Command::GenerateDotfile.new(basename: dotfile_basename).run # create existing
        File.truncate(dotfile_basename, 0)
      end

      after { FileUtils.rm_f(dotfile_basename) }

      it "does not overwrite existing file" do
        init.run
      rescue SystemExit => _e
        expect(File.read(dotfile_basename)).to eq("")
      end

      it "has message" do
        expect { init.run }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            #{dotfile_basename} already exists at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect { init.run }.to exit_with_code(2) }
      it { expect { described_class.new(args: ["-i"]).run }.to exit_with_code(2) }
    end
  end

  context "with --todo" do
    let(:args) { ["--todo"] }
    let(:todo_basename) { ".swagcov_todo_test.yml" }
    let(:dotfile_basename) { ".swagcov_test.yml" }

    before do
      stub_const("Swagcov::Dotfile::TODO_CONFIG_FILE_NAME", todo_basename)
      stub_const("Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME", dotfile_basename)
      Swagcov::Command::GenerateDotfile.new(basename: dotfile_basename).run
    end

    after do
      [todo_basename, dotfile_basename].each { |basename| FileUtils.rm_f(basename) }
    end

    it "generates a todo configuration file" do
      init.run
    rescue SystemExit => _e
      expect(File.read(todo_basename)).to eq(
        <<~YAML
          # This configuration was auto generated
          # The intent is to remove these route configurations as documentation is added

        YAML
      )
    end

    it "prints message" do
      expect { init.run }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
          created #{todo_basename} at #{Swagcov.project_root}
        MESSAGE
      ).to_stdout
    end

    it { expect { init.run }.to exit_with_code(0) }
    it { expect { described_class.new(args: ["-t"]).run }.to exit_with_code(0) }
  end

  context "with an invalid option" do
    let(:args) { ["--foobar"] }

    it "prints message" do
      expect { init.run }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
          invalid option: --foobar
          For usage information, use --help
        MESSAGE
      ).to_stderr
    end

    it { expect { init.run }.to exit_with_code(2) }
  end

  context "without options and with minimum required configuration" do
    let(:args) { [] }
    let(:dotfile_basename) { ".swagcov_test.yml" }

    before do
      stub_const("Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME", dotfile_basename)
      Swagcov::Command::GenerateDotfile.new(basename: dotfile_basename).run # create for minimum required config
    end

    after { FileUtils.rm_f(dotfile_basename) }

    # rubocop:disable Layout/EmptyLinesAroundArguments
    it "prints coverage" do
      expect { init.run }.to raise_exception(SystemExit).and output(
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

    it { expect { init.run }.to exit_with_code(0) }
  end

  context "without options and without required configuration" do
    let(:args) { [] }

    it "prints message" do
      expect { init.run }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
          Swagcov::Errors::BadConfiguration: Missing config file (.swagcov.yml)
        MESSAGE
      ).to_stderr
    end

    it { expect { init.run }.to exit_with_code(2) }
  end

  context "with --version option" do
    let(:args) { ["--version"] }

    it "prints message" do
      expect { init.run }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
          #{Swagcov::Version::STRING}
        MESSAGE
      ).to_stdout
    end

    it { expect { init.run }.to exit_with_code(0) }
  end

  context "with -v option" do
    let(:args) { ["-v"] }

    it "prints message" do
      expect { init.run }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
          #{Swagcov::Version::STRING}
        MESSAGE
      ).to_stdout
    end

    it { expect { init.run }.to exit_with_code(0) }
  end
end
