# frozen_string_literal: true

describe "rake swagcov:install", type: :task do
  it { expect(task.prerequisites).to include "environment" }

  context "when dotfile exists" do
    it "does not overwrite existing file" do
      task.execute
    rescue SystemExit => _e
      expect(File.read(Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME)).to eq(
        <<~YAML
          docs:
            paths:
              - swagger/openapi.yaml
              - swagger/v2_openapi.json
        YAML
      )
    end

    it "has message" do
      expect { task.execute }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
          #{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME} already exists at #{Swagcov.project_root}
        MESSAGE
      ).to_stdout
    end

    it { expect { task.execute }.to exit_with_code(2) }
  end

  context "when dotfile does not exist" do
    let(:basename) { ".swagcov_test.yml" }

    before { stub_const("Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME", basename) }
    after { FileUtils.rm_f(basename) }

    it "creates a minimum configuration file" do
      task.execute
    rescue SystemExit => _e
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
      expect { task.execute }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
          created #{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME} at #{Swagcov.project_root}
        MESSAGE
      ).to_stdout
    end

    it { expect { task.execute }.to exit_with_code(0) }
  end
end
