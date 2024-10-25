require "datadog_api_client"

module DatadogExporter
  class Client
    ##
    # The configuration for the DatadogExporter::Client.
    class Config
      ORGANIZATIONS_CONFIG_FILE = "organizations_config.yml".freeze
      DEFAULT_ORGANIZATIONS_CONFIGURATIONS = {
        monitors: {
          export_tag: "",
          template_keys: [],
          placeholders: {
            base: {
            },
          },
        },
      }.freeze

      attr_reader :logger

      # NOTE: See DatadogExporter::Configurations to see the available options
      def initialize(**options)
        @site = options[:site] || DatadogExporter.configuration.site
        @api_key = options[:api_key] || DatadogExporter.configuration.api_key
        @application_key =
          options[:application_key] || DatadogExporter.configuration.application_key
        @logger = options[:logger] || DatadogExporter.configuration.logger
        @base_path = options[:base_path] || DatadogExporter.configuration.base_path
      end

      def base_path
        Pathname.new(@base_path)
      end

      # Creates the Datadog API global configuration
      #
      # See https://github.com/DataDog/datadog-api-client-ruby/blob/master/lib/datadog_api_client/configuration.rb
      def datadog_api_configuration
        DatadogAPIClient::Configuration.new do |client_config|
          client_config.server_variables[:site] = @site
          client_config.api_key = @api_key
          client_config.application_key = @application_key
        end
      end

      def organizations_config
        organizations_config_file = base_path.join(ORGANIZATIONS_CONFIG_FILE)

        return DEFAULT_ORGANIZATIONS_CONFIGURATIONS unless File.exist?(organizations_config_file)

        DEFAULT_ORGANIZATIONS_CONFIGURATIONS.merge(YAML.load_file(organizations_config_file))
      end
    end
  end
end
