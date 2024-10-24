module DatadogExporter
  module DatadogApiRequests
    # The class that contains all the Datadog API client requests for Monitors
    class Monitors
      attr_reader :monitors_api

      def initialize(
        config: DatadogExporter::Client::Config.new,
        client: DatadogExporter::Client.new(config:),
        monitors_api: DatadogAPIClient::V1::MonitorsAPI.new(client.datadog_client)
      )
        @client = client
        @monitors_api = monitors_api
      end

      ##
      # Returns a list of Hashes containing Datadog monitor configuration.
      # If no tag is provided, it returns all the monitors.
      #
      # @param [String] tag (optional) A tag defined in the Datadog monitors
      #
      # @return [Array<Hash>] A list of monitor configurations
      def list_monitors(tag: nil)
        monitors =
          @monitors_api
            .list_monitors # NOTE: Unfortunately, the filter provided by the API is not working https://github.com/DataDog/datadog-api-client-ruby/issues/2063
            .select { |monitor| tag.nil? || monitor.tags.include?(tag) }

        monitors.map(&:to_hash)
      end

      ##
      # Returns a Datadog monitor configuration.
      #
      # @param [Integer] monitor_id The monitor ID in Datadog
      #
      # @return [Hash] The monitor configuration
      def monitor(monitor_id)
        monitor = @monitors_api.get_monitor(monitor_id)
        monitor.to_hash
      end
    end
  end
end
