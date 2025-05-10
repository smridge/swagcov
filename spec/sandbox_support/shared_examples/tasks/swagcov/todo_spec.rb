# frozen_string_literal: true

describe "rake swagcov -- --todo", type: :task do
  subject(:rake_task) { system %(rake swagcov -- --todo) }

  let(:basename) { ".swagcov_test.yml" }

  before { ENV["SWAGCOV_TODOFILE"] = basename }

  after do
    ENV["SWAGCOV_TODOFILE"] = nil
    FileUtils.rm_f(basename)
  end

  context "with uncovered routes" do
    before { ENV["SWAGCOV_DOTFILE"] = "../sandbox_fixtures/dotfiles/only_and_ignore_config.yml" }
    after { ENV["SWAGCOV_DOTFILE"] = nil }

    it "generates a todo configuration file" do
      rake_task

      expect(File.read(basename)).to eq(
        <<~YAML
          # This configuration was auto generated
          # The intent is to remove these route configurations as documentation is added
          ---
          routes:
            paths:
              ignore:
              - "/v1/articles/:id":
                - GET
                - PATCH
                - PUT
                - DELETE
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

  context "without uncovered routes" do
    it "generates a todo configuration file" do
      rake_task

      expect(File.read(basename)).to eq(
        <<~YAML
          # This configuration was auto generated
          # The intent is to remove these route configurations as documentation is added

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
