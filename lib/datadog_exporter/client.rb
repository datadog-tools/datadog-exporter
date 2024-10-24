require_relative "client/config"

module DatadogExporter
  ##
  # The client that makes the actual requests to the DatadogAPIClient.
  # `config` is an instance of `DatadogApi::Client::Config::Base`
  class Client
    def initialize(config: DatadogExporter::Client::Config.new)
      @datadog_config = config.datadog_api_configuration
    end

    # Creates the Datadog API client
    #
    # See https://github.com/DataDog/datadog-api-client-ruby/blob/master/lib/datadog_api_client/api_client.rb
    #
    # @return [DatadogAPIClient::APIClient]
    def datadog_client
      @datadog_client ||= DatadogAPIClient::APIClient.new(@datadog_config)
    end
  end
end
