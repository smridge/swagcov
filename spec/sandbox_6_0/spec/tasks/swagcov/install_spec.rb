# frozen_string_literal: true

describe "rake swagcov:install", type: :task do
  it { expect(task.prerequisites).to include "environment" }

  context "when dotfile exists" do
    it "does not overwrite existing file" do
      allow($stdout).to receive(:puts) # suppress output in spec

      task.execute
      expect(File.read(Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME)).to eq(
        <<~YAML
          docs:
            paths:
              - swagger/openapi.yaml
        YAML
      )
    end

    it "has message" do
      expect { task.execute }.to output(
        <<~MESSAGE
          #{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME} already exists
        MESSAGE
      ).to_stdout
    end
  end

  context "when dotfile does not exist" do
    let(:dotfile) { ".swagcov_test.yml" }

    before { stub_const("Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME", dotfile) }
    after { FileUtils.rm_f(dotfile) }

    it "creates a minimum configuration file" do
      allow($stdout).to receive(:puts) # suppress output in spec

      task.execute

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
      expect { task.execute }.to output(
        <<~MESSAGE
          created #{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME}
        MESSAGE
      ).to_stdout
    end
  end
end
