module DatadogExporter
  module DatadogApiRequests
    # The class that contains all the Datadog API client requests for Synthetic tests
    class Synthetics
      attr_reader :synthetics_api

      def initialize(
        config: DatadogExporter::Client::Config.new,
        client: DatadogExporter::Client.new(config:),
        synthetics_api: DatadogAPIClient::V1::SyntheticsAPI.new(client.datadog_client)
      )
        @client = client
        @synthetics_api = synthetics_api
      end

      ##
      # Returns a list of Hashes containing Datadog Global Variables.
      #
      # @return [Array<Hash>] A list of Global Variables
      def list_global_variables(tag: nil)
        global_variables =
          @synthetics_api
            .list_global_variables
            .variables
            .select { |test| tag.nil? || test.tags.include?(tag) }

        global_variables
          .map(&:to_body)
          .map { |body| sanitize_global_variable(body) }
      end

      ##
      # Creates a global variable in Datadog
      #
      # @param [Hash] global_variable_body The global variable configuration as returned from `list_global_variables`
      #
      # @return [uuid] The global variable ID
      def create_global_variable(global_variable_body)
        global_variable = @synthetics_api.create_global_variable(global_variable_body)

        global_variable.id
      end

      ##
      # Returns a list of Hashes containing Datadog syntetics tests configuration.
      # If no tag is provided, it returns all the synthetics.
      #
      # @param [String] tag (optional) A tag defined in the Datadog synthetics
      #
      # @return [Array<Hash>] A list of monitor configurations
      def list_browser_tests(tag: nil)
        syntetic_tests_public_ids(tag: tag).map do |public_id|
          body = @synthetics_api.get_browser_test(public_id).to_body
          sanitize_browser_test(body)
        end
      end

      private

      def syntetic_tests_public_ids(tag: nil)
        synthetics =
          @synthetics_api
            .list_tests
            .tests
            .select { |test| tag.nil? || test.tags.include?(tag) }

        synthetics
          .map(&:to_body)
          .map { |body| body[:public_id] }
      end

      def sanitize_browser_test(body)
        keys_to_delete = %I[public_id monitor_id creator editor created_at modified_at]
        keys_to_delete.each { |key| body.delete(key) }

        body[:steps]&.each { |step| step.delete(:public_id) }

        body
      end

      def sanitize_global_variable(body)
        keys_to_delete = %I[id creator editor created_at modified_at last_error]
        keys_to_delete.each { |key| body.delete(key) }

        # Values that are secured are not returned by the API hence not known
        # Then, we create them as not secure and with an empty value
        # The Datadog user might want to set the value and secure it
        if body.dig(:value, :secure) == true
          body[:value][:secure] = false
          body[:value][:value] = ""
        end

        body
      end
    end
  end
end
