RSpec.describe DatadogExporter::Client::Config do
  subject(:config) do
    described_class.new(
      site:, api_key:, application_key:, logger:,
    )
  end

  let(:site) { nil }
  let(:api_key) { nil }
  let(:application_key) { nil }
  let(:logger) { nil }

  describe "#logger" do
    subject(:config_logger) { config.logger }

    context "when the looger is sent to the initializer" do
      let(:logger) { "logger" }

      it "sets the api-key sent" do
        expect(config_logger).to eq("logger")
      end
    end

    context "when the global config is set" do
      before do
        DatadogExporter.configure { |config| config.logger = "global-logger" }
      end

      it "sets the looger global value" do
        expect(config_logger).to eq("global-logger")
      end
    end
  end

  describe "#datadog_api_configuration" do
    subject(:datadog_configuration) { config.datadog_api_configuration }

    describe "config.api_key" do
      context "when the site is sent to the initializer" do
        let(:api_key) { "api-key" }

        it "sets the api-key sent" do
          expect(datadog_configuration.api_key["apiKeyAuth"]).to eq("api-key")
        end
      end

      context "when the environment variable is not set" do
        it "sets the api_key to nil" do
          expect(datadog_configuration.api_key["apiKeyAuth"]).to be(nil)
        end
      end

      context "when the environment variable is set" do
        before { stub_const("ENV", ENV.to_hash.merge("DATADOG_API_KEY" => "env-api-key")) }

        it "sets the api_key to env value" do
          expect(datadog_configuration.api_key["apiKeyAuth"]).to eq("env-api-key")
        end
      end

      context "when the global config is set" do
        before do
          DatadogExporter.configure { |config| config.api_key = "global-api-key" }
        end

        after do
          DatadogExporter.configure { |config| config.api_key = ENV.fetch("DATADOG_API_KEY", nil) }
        end

        it "sets the api_key global value" do
          expect(datadog_configuration.api_key["apiKeyAuth"]).to eq("global-api-key")
        end
      end
    end

    describe "config.application_key" do
      context "when the key is sent to the initializer" do
        let(:application_key) { "initializer-app-key" }

        it "sets the application_key sent" do
          expect(datadog_configuration.api_key["appKeyAuth"]).to eq("initializer-app-key")
        end
      end

      context "when the environment variable is not set" do
        it "sets the application_key to nil" do
          expect(datadog_configuration.api_key["appKeyAuth"]).to be(nil)
        end
      end

      context "when the environment variable is set" do
        before { stub_const("ENV", ENV.to_hash.merge("DATADOG_APPLICATION_KEY" => "env-app-key")) }

        it "sets the application_key to env value" do
          expect(datadog_configuration.api_key["appKeyAuth"]).to eq("env-app-key")
        end
      end

      context "when the global config is set" do
        before do
          DatadogExporter.configure { |config| config.application_key = "global-app-key" }
        end

        after do
          DatadogExporter.configure { |config| config.application_key = ENV.fetch("DATADOG_APPLICATION_KEY", nil) }
        end

        it "sets the application_key global value" do
          expect(datadog_configuration.api_key["appKeyAuth"]).to eq("global-app-key")
        end
      end
    end

    describe "config.site" do
      context "when the site is sent to the initializer" do
        let(:site) { "site" }

        it "sets the site sent" do
          expect(datadog_configuration.server_variables[:site]).to eq("site")
        end
      end

      context "when the environment variable is not set" do
        it "sets the site to nil" do
          expect(datadog_configuration.server_variables[:site]).to be(nil)
        end
      end

      context "when the environment variable is set" do
        before { stub_const("ENV", ENV.to_hash.merge("DATADOG_API_SITE" => "datadoghq.eu")) }

        it "sets the site to env value" do
          expect(datadog_configuration.server_variables[:site]).to eq("datadoghq.eu")
        end
      end

      context "when the global config is set" do
        before do
          DatadogExporter.configure { |config| config.site = "datadoghq.eu" }
        end

        after do
          DatadogExporter.configure { |config| config.site = ENV.fetch("DATADOG_API_SITE", nil) }
        end

        it "sets the site global value" do
          expect(datadog_configuration.server_variables[:site]).to eq("datadoghq.eu")
        end
      end
    end
  end
end
