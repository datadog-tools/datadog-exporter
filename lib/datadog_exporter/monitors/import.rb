module DatadogExporter
  module Monitors
    ##
    # This class provides import tools for Datadog Monitors
    class Import
      class DirectoryNotExisting < StandardError
      end
      class DirectoryEmptyError < StandardError
      end

      attr_reader :config

      DATADOG_CREATE_MONITOR_FIELDS = %i[
        matching_downtimes
        message
        name
        options
        priority
        query
        restricted_roles
        tags
        type
      ].freeze

      def initialize(
        config: DatadogExporter::Client::Config.new,
        client: DatadogExporter::Client.new(config:),
        request: DatadogExporter::DatadogApiRequests::Monitors.new(config:, client:)
      )
        @config = config
        @request = request
        @monitors_base_path = config.base_path.join(DatadogExporter::Monitors::EXPORT_FOLDER)
      end

      ##
      # Imports monitors from YAML files stored under the monitors_base_path to datadog.
      #
      # @param [Number] id (optional) import only a monitor by id
      # @param [Hash] request_options (optional) pass additional options to the request
      #
      # @return [String] Output message
      def import(id: nil, **request_options)
        select_monitors(id: id)
          .map { |monitor| monitor_request_body(monitor, request_options: request_options) }
          .each { |monitor| create_monitor(monitor) }

        config.logger.info("Imported monitors from #{@monitors_base_path} directory to datadog")
      end

      private

      def create_monitor(file_monitor)
        @request.create(file_monitor)
      end

      def monitor_request_body(monitor, request_options: {})
        monitor.slice(*DATADOG_CREATE_MONITOR_FIELDS).merge(request_options)
      end

      def select_monitors(id: nil)
        return monitors unless id

        monitors.select { |monitor| monitor[:id] == id }
      end

      def monitors
        unless @monitors_base_path.exist?
          raise DirectoryNotExisting, "Monitors directory does not exist"
        end

        if @monitors_base_path.glob("*.yml").empty?
          raise DirectoryEmptyError, "Monitors directory is empty"
        end

        @monitors ||=
          @monitors_base_path
            .glob("*.yml")
            .map do |monitor_yaml|
              YAML.safe_load_file(monitor_yaml, permitted_classes: [Symbol, Time])
            end
      end
    end
  end
end
