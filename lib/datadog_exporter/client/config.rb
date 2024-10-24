require "datadog_api_client"

module DatadogExporter
  class Client
    ##
    # The configuration for the DatadogExporter::Client.
    class Config
      attr_reader :logger

      # NOTE: See DatadogExporter::Configurations to see the available options
      def initialize(**options)
        @site = options[:site] || DatadogExporter.configuration.site
        @api_key = options[:api_key] || DatadogExporter.configuration.api_key
        @application_key =
          options[:application_key] || DatadogExporter.configuration.application_key
        @logger = options[:logger] || DatadogExporter.configuration.logger
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
    end
  end
end
