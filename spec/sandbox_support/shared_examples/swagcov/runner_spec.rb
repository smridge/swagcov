# frozen_string_literal: true

describe Swagcov::Runner do
  subject(:runner) { described_class.new(args: args).run }

  context "without optional arguments" do
    let(:args) { [] }

    context "with minimal configuration and full documentation coverage" do
      it "outputs coverage" do
        expect { runner }.to raise_exception(SystemExit).and output(
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

      it { expect { runner }.to exit_with_code(0) }
    end

    context "with full configuration and partial documentation coverage" do
      before do
        stub_const(
          "Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME",
          "../sandbox_fixtures/dotfiles/only_and_ignore_config.yml"
        )
      end

      it "outputs coverage" do
        expect { runner }.to raise_exception(SystemExit).and output(
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

      it { expect { runner }.to exit_with_code(1) }
    end

    context "without required configuration" do
      before { stub_const("Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME", "../sandbox_fixtures/dotfiles/no-dotfile.yml") }

      it "prints message" do
        expect { runner }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            Swagcov::Errors::BadConfiguration: Missing config file (#{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME})
          MESSAGE
        ).to_stderr
      end

      it { expect { runner }.to exit_with_code(2) }
    end
  end

  context "with --help option" do
    let(:args) { ["--help"] }

    it "prints options" do
      expect { runner }.to raise_exception(SystemExit).and output(
        <<~MESSAGE
          Usage:
          * as executable: swagcov [options]
          * as rake task: rake swagcov -- [options]
              -i, --init                       Generate required .swagcov.yml config file
              -t, --todo                       Generate optional .swagcov_todo.yml config file
        MESSAGE
      ).to_stdout
    end
  end

  context "with --init option" do
    let(:args) { ["--init"] }

    context "when dotfile exists" do
      it "does not overwrite existing file" do
        runner
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
        expect { runner }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            #{Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME} already exists at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect { runner }.to exit_with_code(2) }
      it { expect { described_class.new(args: ["-i"]).run }.to exit_with_code(2) }
    end

    context "when dotfile does not exist" do
      let(:basename) { ".swagcov_test.yml" }

      before { stub_const("Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME", basename) }
      after { FileUtils.rm_f(basename) }

      it "creates a minimum configuration file" do
        runner
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
            #       - /v2/users # do not track certain endpoints
            #       - /v2/users/:id: # ignore only certain actions (verbs)
            #         - GET
          YAML
        )
      end

      it "has message" do
        expect { runner }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect { runner }.to exit_with_code(0) }
      it { expect { described_class.new(args: ["-i"]).run }.to exit_with_code(0) }
    end
  end

  context "with --todo option" do
    let(:args) { ["--todo"] }
    let(:basename) { ".swagcov_test.yml" }

    before { stub_const("Swagcov::Dotfile::TODO_CONFIG_FILE_NAME", basename) }
    after { FileUtils.rm_f(basename) }

    context "with uncovered routes" do
      before do
        stub_const(
          "Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME",
          "../sandbox_fixtures/dotfiles/only_and_ignore_config.yml"
        )
      end

      it "generates a todo configuration file" do
        runner
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
        expect { runner }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect { runner }.to exit_with_code(0) }
      it { expect { described_class.new(args: ["-t"]).run }.to exit_with_code(0) }
    end

    context "without uncovered routes" do
      it "generates a todo configuration file" do
        runner
      rescue SystemExit => _e
        expect(File.read(Swagcov::Dotfile::TODO_CONFIG_FILE_NAME)).to eq(
          <<~YAML
            # This configuration was auto generated
            # The intent is to remove these route configurations as documentation is added

          YAML
        )
      end

      it "has message" do
        expect { runner }.to raise_exception(SystemExit).and output(
          <<~MESSAGE
            created #{Swagcov::Dotfile::TODO_CONFIG_FILE_NAME} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout
      end

      it { expect { runner }.to exit_with_code(0) }
      it { expect { described_class.new(args: ["-t"]).run }.to exit_with_code(0) }
    end
  end
end
