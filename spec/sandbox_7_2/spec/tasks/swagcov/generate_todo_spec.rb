# frozen_string_literal: true

describe "rake swagcov:generate_todo", type: :task do
  let(:basename) { ".swagcov_test.yml" }

  before do
    allow($stdout).to receive(:puts) # suppress output in spec
    stub_const("Swagcov::Dotfile::TODO_CONFIG_FILE_NAME", basename)
  end

  after { FileUtils.rm_f(basename) }

  it { expect(task.prerequisites).to include "environment" }

  context "with uncovered routes" do
    before do
      stub_const("Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME", "spec/fixtures/dotfiles/only_and_ignore_config.yml")
    end

    it "generates a todo configuration file" do
      task.execute
    rescue SystemExit => _e
      expect(File.read(Swagcov::Dotfile::TODO_CONFIG_FILE_NAME)).to eq(
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
      expect do
        task.execute
      rescue SystemExit => e
        e.inspect
      end.to output(
        <<~MESSAGE
          created #{Swagcov::Dotfile::TODO_CONFIG_FILE_NAME} at #{Swagcov.project_root}
        MESSAGE
      ).to_stdout
    end

    it { expect { task.execute }.to raise_exception(SystemExit) }
    it { expect { task.execute }.to exit_with_code(0) }
  end

  context "without uncovered routes" do
    it "generates a todo configuration file" do
      task.execute
    rescue SystemExit => _e
      expect(File.read(Swagcov::Dotfile::TODO_CONFIG_FILE_NAME)).to eq(
        <<~YAML
          # This configuration was auto generated
          # The intent is to remove these route configurations as documentation is added

        YAML
      )
    end

    it "has message" do
      expect do
        task.execute
      rescue SystemExit => e
        e.inspect
      end.to output(
        <<~MESSAGE
          created #{Swagcov::Dotfile::TODO_CONFIG_FILE_NAME} at #{Swagcov.project_root}
        MESSAGE
      ).to_stdout
    end

    it { expect { task.execute }.to raise_exception(SystemExit) }
    it { expect { task.execute }.to exit_with_code(0) }
  end
end
