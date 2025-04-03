# frozen_string_literal: true

describe "rake swagcov", type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  context "with minimal configuration and full documentation coverage" do
    it "outputs coverage" do
      expect do
        task.execute
      rescue SystemExit => e # ignore to test output
        e.inspect
      end.to output(<<~MESSAGE).to_stdout
               GET /articles         #{200.to_s.green}
              POST /articles         #{201.to_s.green}
               GET /articles/:id     #{200.to_s.green}
             PATCH /articles/:id     #{200.to_s.green}
               PUT /articles/:id     #{200.to_s.green}
            DELETE /articles/:id     #{204.to_s.green}
               GET /users            #{200.to_s.green}
              POST /users            #{201.to_s.green}
               GET /users/:id        #{200.to_s.green}
             PATCH /users/:id        #{200.to_s.green}
               PUT /users/:id        #{200.to_s.green}
            DELETE /users/:id        #{204.to_s.green}
               GET /v1/articles      #{200.to_s.green}
              POST /v1/articles      #{201.to_s.green}
               GET /v1/articles/:id  #{200.to_s.green}
             PATCH /v1/articles/:id  #{200.to_s.green}
               PUT /v1/articles/:id  #{200.to_s.green}
            DELETE /v1/articles/:id  #{204.to_s.green}
               GET /v2/articles      #{200.to_s.green}
              POST /v2/articles      #{201.to_s.green}
               GET /v2/articles/:id  #{200.to_s.green}
             PATCH /v2/articles/:id  #{200.to_s.green}
               PUT /v2/articles/:id  #{200.to_s.green}
            DELETE /v2/articles/:id  #{204.to_s.green}

        OpenAPI documentation coverage 100.00% (24/24)
        #{0.to_s.yellow} endpoints ignored
        #{24.to_s.blue} endpoints checked
        #{24.to_s.green} endpoints covered
        #{0.to_s.red} endpoints missing documentation
      MESSAGE
    end

    context "when testing final result" do
      # suppress output in specs
      before { allow($stdout).to receive(:puts) }

      it { expect { task.execute }.to raise_exception(SystemExit) }
      it { expect { task.execute }.to exit_with_code(0) }
    end
  end

  context "with full configuration and partial documentation coverage" do
    before do
      stub_const("Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME", "spec/fixtures/dotfiles/only_and_ignore_config.yml")
    end

    it "outputs coverage" do
      expect do
        task.execute
      rescue SystemExit => e # ignore to test output
        e.inspect
      end.to output(<<~MESSAGE).to_stdout
              POST /v1/articles      #{201.to_s.green}
               GET /v1/articles      #{'ignored'.yellow}
               GET /v2/articles/:id  #{'ignored'.yellow}
             PATCH /v2/articles/:id  #{'ignored'.yellow}
               PUT /v2/articles/:id  #{'ignored'.yellow}
            DELETE /v2/articles/:id  #{'ignored'.yellow}
               GET /v1/articles/:id  #{'none'.red}
             PATCH /v1/articles/:id  #{'none'.red}
               PUT /v1/articles/:id  #{'none'.red}
            DELETE /v1/articles/:id  #{'none'.red}

        OpenAPI documentation coverage 20.00% (1/5)
        #{5.to_s.yellow} endpoints ignored
        #{5.to_s.blue} endpoints checked
        #{1.to_s.green} endpoints covered
        #{4.to_s.red} endpoints missing documentation
      MESSAGE
    end

    context "when testing final result" do
      # suppress output in specs
      before { allow($stdout).to receive(:puts) }

      it { expect { task.execute }.to raise_exception(SystemExit) }
      it { expect { task.execute }.not_to exit_with_code(0) }
    end
  end
end
