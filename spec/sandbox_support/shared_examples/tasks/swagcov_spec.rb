# frozen_string_literal: true

describe "rake swagcov", type: :task do
  it { expect(task.prerequisites).to include "environment" }

  context "with minimal configuration and full documentation coverage" do
    it "outputs coverage" do
      expect { task.execute }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
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
          #{0.to_s.yellow} ignored endpoints
          #{24.to_s.blue} total endpoints
          #{24.to_s.green} covered endpoints
          #{0.to_s.red} uncovered endpoints
        MESSAGE
      ).to_stdout
    end

    it { expect { task.execute }.to exit_with_code(0) }
  end

  context "with full configuration and partial documentation coverage" do
    before { stub_const("Swagcov::DOTFILE", "../sandbox_fixtures/dotfiles/only_and_ignore_config.yml") }

    it "outputs coverage" do
      expect { task.execute }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
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
          #{5.to_s.yellow} ignored endpoints
          #{5.to_s.blue} total endpoints
          #{1.to_s.green} covered endpoint
          #{4.to_s.red} uncovered endpoints
        MESSAGE
      ).to_stdout
    end

    it { expect { task.execute }.to exit_with_code(1) }
  end

  context "without required configuration" do
    before { stub_const("Swagcov::DOTFILE", "../sandbox_fixtures/dotfiles/no-dotfile.yml") }

    it "prints message" do
      expect { task.execute }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
          Swagcov::Errors::BadConfiguration: Missing config file (#{Swagcov::DOTFILE})
        MESSAGE
      ).to_stderr
    end

    it { expect { task.execute }.to exit_with_code(2) }
  end

  context "with -- --init option" do
    before { stub_const("ARGV", ["swagcov", "--", "--init"]) }

    context "when dotfile exists" do
      it "does not overwrite existing file" do
        task.execute
      rescue SystemExit => _e
        expect(File.read(Swagcov::DOTFILE)).to eq(
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
            #{Swagcov::DOTFILE} already exists at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect { task.execute }.to exit_with_code(2) }
    end

    context "when dotfile does not exist" do
      let(:basename) { ".swagcov_test.yml" }

      before { stub_const("Swagcov::DOTFILE", basename) }
      after { FileUtils.rm_f(basename) }

      it "creates a minimum configuration file" do
        task.execute
      rescue SystemExit => _e
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
            #       - /: # root
            #         - GET
            #       - /up: # health check
            #         - GET
            #       - /v2/users # do not track certain endpoints
            #       - /v2/users/:id: # ignore only certain actions (verbs)
            #         - PUT
          YAML
        )
      end

      it "has message" do
        expect { task.execute }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect { task.execute }.to exit_with_code(0) }
    end
  end

  describe "with -- --todo option" do
    let(:basename) { ".swagcov_test.yml" }

    before do
      stub_const("ARGV", ["swagcov", "--", "--todo"])
      stub_const("Swagcov::TODOFILE", basename)
    end

    after { FileUtils.rm_f(basename) }

    context "with uncovered routes" do
      before { stub_const("Swagcov::DOTFILE", "../sandbox_fixtures/dotfiles/only_and_ignore_config.yml") }

      it "generates a todo configuration file" do
        task.execute
      rescue SystemExit => _e
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
        expect { task.execute }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect { task.execute }.to exit_with_code(0) }
    end

    context "without uncovered routes" do
      it "generates a todo configuration file" do
        task.execute
      rescue SystemExit => _e
        expect(File.read(basename)).to eq(
          <<~YAML
            # This configuration was auto generated
            # The intent is to remove these route configurations as documentation is added

          YAML
        )
      end

      it "has message" do
        expect { task.execute }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect { task.execute }.to exit_with_code(0) }
    end
  end

  context "with -- --version option" do
    before { stub_const("ARGV", ["swagcov", "--", "--version"]) }

    it "has message" do
      expect { task.execute }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
          #{Swagcov::Version::STRING}
        MESSAGE
      ).to_stdout
    end

    it { expect { task.execute }.to exit_with_code(0) }
  end

  context "with -- -v option" do
    before { stub_const("ARGV", ["swagcov", "--", "-v"]) }

    it "has message" do
      expect { task.execute }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
          #{Swagcov::Version::STRING}
        MESSAGE
      ).to_stdout
    end

    it { expect { task.execute }.to exit_with_code(0) }
  end
end
