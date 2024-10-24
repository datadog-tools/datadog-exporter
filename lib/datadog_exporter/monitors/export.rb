module DatadogExporter
  module Monitors
    ##
    # This class provide export tools for Datadog Monitors
    class Export
      def initialize(
        config: DatadogExporter::Client::Config.new,
        client: DatadogExporter::Client.new(config:),
        request: DatadogExporter::DatadogApiRequests::Monitors.new(config:, client:),
        name_transformer: MonitorNameTransformer.new,
        file_class: File
      )
        @config = config
        @request = request
        @monitors_base_path = config.base_path.join("monitors")
        @name_transformer = name_transformer
        @file_class = file_class
      end

      def export(tag:)
        reset_monitors_dir

        monitors = @request.list_monitors(tag:)

        monitors.each { |exported_datadog_hash| save_original(exported_datadog_hash) }

        monitors.count
      end

      private

      def reset_monitors_dir
        return if @file_class.exist?(@monitors_base_path)

        @monitors_base_path.glob("*.yml").each(&:delete)
        @monitors_base_path.mkpath
      end

      def save_original(exported_datadog_hash)
        save!(
          @name_transformer.transform(exported_datadog_hash[:name]),
          exported_datadog_hash.to_yaml,
        )
      end

      def save!(name, yaml_data)
        filepath = @monitors_base_path.join("#{name}.yml")
        @file_class.write(filepath, yaml_data)
      end
    end
  end
end
