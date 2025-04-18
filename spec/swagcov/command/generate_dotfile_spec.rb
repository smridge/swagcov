# frozen_string_literal: true

RSpec.describe Swagcov::Command::GenerateDotfile do
  subject(:install) { described_class.new(basename: dotfile) }

  let(:dotfile) { "rails_root/#{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME}" }

  before { allow($stdout).to receive(:puts) } # suppress output in spec

  describe "#run" do
    context "when dotfile does not exist" do
      before { FileUtils.mkdir_p("rails_root") }

      after do
        FileUtils.rm_f(dotfile)
        FileUtils.rmdir("rails_root")
      end

      it "creates a minimum configuration file" do
        install.run

        expect(File.read(dotfile)).to eq(
          <<~YAML
            ## Required field:
            # List your OpenAPI documentation files
            docs:
              paths:
                - swagger.yaml

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
        FileUtils.mkdir_p("rails_root")
        install.run # create existing
        File.truncate(dotfile, 0)
      end

      after do
        FileUtils.rm_f(dotfile)
        FileUtils.rmdir("rails_root")
      end

      it "does not overwrite existing file" do
        install.run
        expect(File.read(dotfile)).to eq("")
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
