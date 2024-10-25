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
        file_class: File
      )
        @config = config
        @request = request
        @monitors_base_path = config.base_path.join(DatadogExporter::Monitors::EXPORT_FOLDER)
        @template_manager = template_manager
        @file_class = file_class
      end

      ##
      # Imports Datadog monitors configuration from YAML files.
      #
      #   * Loops all exported monitors in the base_path/monitors folder.
      #   * Transforms the monitor into a template with placeholders.
      #   * Replace the placeholders with the environment values
      #   * Creates the monitor in the Datadog environment.
      #
      # If a tag is provided, it imports only the monitors with that tag.
      #
      # @param [Symbol] to The environment (defined in your organizations_config_filename) where the monitors will be imported
      # @param [String] tag (optional) A tag defined in the Datadog monitors
      def import(to:, tag: nil)
        monitors
          .select { |monitor| tag.nil? || monitor[:tags].include?(tag) }
          .each do |monitor|
            template = @template_manager.create_template(monitor)
            target_monitor = @template_manager.create_monitor(template, environment: to)
            @request.create(target_monitor) if accepted?(target_monitor, to)
        end
      end

      private

      def monitors
        @monitors_base_path.glob("*.yml").map do |file|
          YAML.load_file(
            file,
            permitted_classes: [Symbol, Time, Date, DateTime, Object],
          )
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
