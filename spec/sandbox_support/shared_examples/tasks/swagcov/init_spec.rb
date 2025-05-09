# frozen_string_literal: true

describe "rake swagcov -- --init", type: :task do
  subject(:rake_task) { system %(rake swagcov -- --init) }

  context "when dotfile exists" do
    it "does not overwrite existing file" do
      rake_task

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
      expect { rake_task }.to output(
        <<~MESSAGE
          #{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME} already exists at #{Swagcov.project_root}
        MESSAGE
      ).to_stdout_from_any_process
    end
  end

  context "when dotfile does not exist" do
    let(:basename) { ".swagcov_test.yml" }

    before { ENV["SWAGCOV_DOTFILE"] = basename }

    after do
      ENV["SWAGCOV_DOTFILE"] = nil
      FileUtils.rm_f(basename)
    end

    it "creates a minimum configuration file" do
      rake_task

      expect(File.read(basename)).to eq(
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
      expect { rake_task }.to output(
        <<~MESSAGE
          created #{basename} at #{Swagcov.project_root}
        MESSAGE
      ).to_stdout_from_any_process
    end
  end
end
