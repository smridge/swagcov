# frozen_string_literal: true

RSpec.describe Swagcov::Command::GenerateDotfile do
  subject(:install) { described_class.new(basename: basename) }

  let(:basename) { ".swagcov_test.yml" }

  before { stub_const("Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME", basename) }

  after { FileUtils.rm_f(basename) }

  describe "#run" do
    context "when dotfile does not exist" do
      it "creates a minimum configuration file" do
        install.run

        expect(File.read(Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME)).to eq(
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

      it "has message" do
        expect { install.run }.to output(
          <<~MESSAGE
            created #{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect(install.run).to eq(0) }
    end

    context "when dotfile exists" do
      before do
        install.run # create existing
        File.truncate(basename, 0)
      end

      it "does not overwrite existing file" do
        install.run
        expect(File.read(Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME)).to eq("")
      end

      it "has message" do
        expect { install.run }.to output(
          <<~MESSAGE
            #{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME} already exists at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect(install.run).to eq(2) }
    end
  end
end
