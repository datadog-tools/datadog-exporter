module DatadogExporter
  module Monitors
    ##
    # This class provide import tools for Datadog Monitors
    #
    # Whether they are templates or original monitors, it imports them from the base_path/monitors folder.
    class Import
      def initialize(
        config: DatadogExporter::Client::Config.new,
        client: DatadogExporter::Client.new(config:),
        request: DatadogExporter::DatadogApiRequests::Monitors.new(config:, client:),
        template_manager: Utilities::TemplateManager.new(config:),
        file_class: File,
        existent_monitors_service: DatadogExporter::Monitors::Export.new
      )
        @config = config
        @request = request
        @monitors_base_path = config.base_path.join(DatadogExporter::Monitors::EXPORT_FOLDER)
        @template_manager = template_manager
        @file_class = file_class
        @existent_monitors_service = existent_monitors_service
      end

      def list(tag: nil, &)
        monitors.select { |monitor| tag.nil? || monitor[:tags].include?(tag) }.each(&)
      end

      ##
      # Imports Datadog monitors configuration from YAML files.
      #
      #   * Loops all exported monitors in the base_path/monitors folder.
      #   * Transforms the monitor into a template with placeholders.
      #   * Replace the placeholders with the environment values
      #   * Checks if the monitor already exists in the Datadog environment.
      #   * Creates the monitor in the Datadog environment.
      #
      # If a tag is provided, it imports only the monitors with that tag.
      #
      # @param [Symbol] to The environment (defined in your organizations_config_filename) where the monitors will be imported
      # @param [Symbol] from (optional) The environment (defined in your organizations_config_filename) where the placeholders are defined
      # @param [String] tag (optional) A tag defined in the Datadog monitors
      def import(to:, from: :base, tag: nil)
        monitors = []

        list(tag: tag) do |monitor|
          template = @template_manager.create_template(monitor, environment: from)
          monitor = @template_manager.create_monitor(template, environment: to)

          if exists?(monitor)
            puts "Monitor `#{monitor[:name]}` already exists on #{to}"
          elsif accepted?(monitor, to)
            monitors << @request.create(monitor)
          end
        end

        puts "monitors created: #{monitors.count}"
      end

      private

      def exists?(monitor_to_import)
        existent_monitor =
          existent_monitors.find { |monitor| monitor[:name] == monitor_to_import[:name] }

        existent_monitor.inspect == monitor_to_import.inspect
      end

      def existent_monitors
        @existent_monitors ||=
          @existent_monitors_service.list.map do |monitor|
            @template_manager.filter_by_template_keys(monitor)
          end
      end

      def monitors
        @monitors_base_path
          .glob("*.yml")
          .map do |file|
            YAML.load_file(file, permitted_classes: [Symbol, Time, Date, DateTime, Object])
          end
      end

      def accepted?(monitor, to)
        puts monitor.to_yaml

        print "Save to #{to} (y/n): "
        input = gets.chomp.downcase
        input == "y"
      end
    end
  end
end
