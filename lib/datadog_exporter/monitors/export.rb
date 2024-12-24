module DatadogExporter
  module Monitors
    ##
    # This class provide export tools for Datadog Monitors
    class Export
      attr_reader :config

      def initialize(
        config: DatadogExporter::Client::Config.new,
        client: DatadogExporter::Client.new(config:),
        request: DatadogExporter::DatadogApiRequests::Monitors.new(config:, client:),
        name_transformer: Utilities::NameTransformer.new,
        template_creator: Utilities::TemplateManager.new(config:),
        file_class: File
      )
        @config = config
        @request = request
        @monitors_base_path = config.base_path.join(DatadogExporter::Monitors::EXPORT_FOLDER)
        @name_transformer = name_transformer
        @template_creator = template_creator
        @file_class = file_class
      end

      ##
      # Exports Datadog monitors configuration in YAML files.
      # If no tag is provided, it exports all the monitors.
      #
      # @param [String] tag (optional) A tag defined in the Datadog monitors
      #
      # @return [String] Output message
      def export(tag: nil)
        reset_monitors_dir

        monitors(tag:).each { |exported_datadog_hash| save_original(exported_datadog_hash) }

        config.logger.info("Exported #{@monitors.count} monitors to #{@monitors_base_path}")
      end

      ##
      # Exports Datadog monitors configuration in YAML files as templates.
      # If no tag is provided, it exports all the monitors.
      #
      # See TemplateManager for more information about the transformation.
      #
      # @param [String] tag (optional) A tag defined in the Datadog monitors
      #
      # @return [String] Output message
      def export_as_template(tag: nil)
        reset_monitors_dir

        monitors(tag:).each { |exported_datadog_hash| save_template(exported_datadog_hash) }

        config.logger.info(
          "Exported #{@monitors.count} monitor templates to #{@monitors_base_path}",
        )
      end

      private

      def monitors(tag:)
        @monitors ||= @request.list_monitors(tag:)
      end

      def reset_monitors_dir
        @monitors_base_path.mkpath unless @file_class.exist?(@monitors_base_path)

        @monitors_base_path.glob("*.yml").each(&:delete)
      end

      def save_template(exported_datadog_hash)
        save!(
          "template.#{@name_transformer.transform(exported_datadog_hash[:name])}",
          @template_creator.create_template(exported_datadog_hash).to_yaml,
        )
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
