RSpec.describe DatadogExporter::Client::Config do
  subject(:config) { described_class.new(site:, api_key:, application_key:, logger:, base_path:) }

  let(:site) { nil }
  let(:api_key) { nil }
  let(:application_key) { nil }
  let(:logger) { nil }
  let(:base_path) { nil }

  before do
    stub_const("ENV", ENV.to_hash.merge("DATADOG_API_KEY" => nil))
    stub_const("ENV", ENV.to_hash.merge("DATADOG_APPLICATION_KEY" => nil))
    stub_const("ENV", ENV.to_hash.merge("DATADOG_API_SITE" => nil))
  end

  after do
    DatadogExporter.configure do |config|
      config.api_key = nil
      config.application_key = nil
      config.site = nil
      config.logger = nil
      config.base_path = nil
    end
  end

  describe "#base_path" do
    subject(:config_base_path) { config.base_path }

    let(:base_path) { nil }

    context "when the base path is sent to the initializer" do
      let(:base_path) { Dir.pwd }

      it "sets the base path sent" do
        expect(config_base_path).to eq(Pathname.new(base_path))
      end
    end

    context "when the global config is set" do
      before { DatadogExporter.configure { |config| config.base_path = "#{Dir.pwd}/global" } }

      it "sets the base path global value" do
        expect(config_base_path).to eq(Pathname.new("#{Dir.pwd}/global"))
      end
    end
  end

  describe "#logger" do
    subject(:config_logger) { config.logger }

    context "when the looger is sent to the initializer" do
      let(:logger) { "logger" }

      it "sets the logger sent" do
        expect(config_logger).to eq("logger")
      end
    end

    context "when the global config is set" do
      before { DatadogExporter.configure { |config| config.logger = "global-logger" } }

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
        before { DatadogExporter.configure { |config| config.api_key = "global-api-key" } }

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
        before { DatadogExporter.configure { |config| config.application_key = "global-app-key" } }

        after do
          DatadogExporter.configure do |config|
            config.application_key = ENV.fetch("DATADOG_APPLICATION_KEY", nil)
          end
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
        before { DatadogExporter.configure { |config| config.site = "datadoghq.eu" } }

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
