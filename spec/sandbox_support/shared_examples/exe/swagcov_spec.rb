# frozen_string_literal: true

describe "[executable] swagcov" do
  context "without optional arguments" do
    subject(:swagcov) { system %(swagcov) }

    context "with minimal configuration and full documentation coverage" do
      it "outputs coverage" do
        expect { swagcov }.to output(
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
        ).to_stdout_from_any_process
      end
    end

    context "with full configuration and partial documentation coverage" do
      before { ENV["SWAGCOV_DOTFILE"] = "../sandbox_fixtures/dotfiles/only_and_ignore_config.yml" }
      after { ENV["SWAGCOV_DOTFILE"] = nil }

      it "outputs coverage" do
        expect { swagcov }.to output(
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
        ).to_stdout_from_any_process
      end
    end

    context "without required configuration" do
      let(:basename) { "../sandbox_fixtures/dotfiles/no-dotfile.yml" }

      before { ENV["SWAGCOV_DOTFILE"] = basename }
      after { ENV["SWAGCOV_DOTFILE"] = nil }

      it "prints message" do
        expect { swagcov }.to output(
          a_string_including(
            <<~MESSAGE
              Swagcov::Errors::BadConfiguration: Missing config file (#{basename})
            MESSAGE
          )
        ).to_stderr_from_any_process
      end
    end
  end

  context "with --help option" do
    subject(:swagcov) { system %(swagcov --help) }

    it "prints options" do
      expect { swagcov }.to output(
        <<~MESSAGE
          Usage:
          * as executable: swagcov [options]
          * as rake task: rake swagcov -- [options]
              -i, --init                       Generate required .swagcov.yml config file
              -t, --todo                       Generate optional .swagcov_todo.yml config file
              -v, --version                    Display version
        MESSAGE
      ).to_stdout_from_any_process
    end
  end

  context "with --init option" do
    subject(:swagcov) { system %(swagcov --init) }

    context "when dotfile exists" do
      it "does not overwrite existing file" do
        swagcov

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
        expect { swagcov }.to output(
          <<~MESSAGE
            #{Swagcov::DOTFILE} already exists at #{Swagcov.project_root}
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
        swagcov

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
        expect { swagcov }.to output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout_from_any_process
      end
    end
  end

  context "with --todo option" do
    subject(:swagcov) { system %(swagcov --todo) }

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
        swagcov

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
        expect { swagcov }.to output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout_from_any_process
      end
    end

    context "without uncovered routes" do
      it "generates a todo configuration file" do
        swagcov

        expect(File.read(basename)).to eq(
          <<~YAML
            # This configuration was auto generated
            # The intent is to remove these route configurations as documentation is added

          YAML
        )
      end

      it "has message" do
        expect { swagcov }.to output(
          <<~MESSAGE
            created #{basename} at #{Swagcov.project_root}
          MESSAGE
        ).to_stdout_from_any_process
      end
    end
  end

  context "with --version option" do
    subject(:swagcov) { system %(swagcov --version) }

    it "prints message" do
      expect { swagcov }.to output(
        <<~MESSAGE
          #{Swagcov::Version::STRING}
        MESSAGE
      ).to_stdout_from_any_process
    end
  end

  context "with --v option" do
    subject(:swagcov) { system %(swagcov -v) }

    it "prints message" do
      expect { swagcov }.to output(
        <<~MESSAGE
          #{Swagcov::Version::STRING}
        MESSAGE
      ).to_stdout_from_any_process
    end
  end
end
