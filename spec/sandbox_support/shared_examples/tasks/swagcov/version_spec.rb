# frozen_string_literal: true

describe "rake swagcov -- --version", type: :task do
  subject(:rake_task) { system %(rake swagcov -- --version) }

  it "prints message" do
    expect { rake_task }.to output(
      <<~MESSAGE
        #{Swagcov::Version::STRING}
      MESSAGE
    ).to_stdout_from_any_process
  end

  context "with shorthand -v option" do
    subject(:rake_task) { system %(rake swagcov -- -v) }

    it "prints message" do
      expect { rake_task }.to output(
        <<~MESSAGE
          #{Swagcov::Version::STRING}
        MESSAGE
      ).to_stdout_from_any_process
    end
  end
end
