module DatadogExporter
  module Monitors
    module Utilities
      ##
      # This class transform the monitor into a template
      class TemplateManager
        ##
        # This class replaces the matching text with a placeholder
        class StringToPlaceholder
          attr_reader :original_string, :placeholders

          def initialize(original_string, placeholders)
            @original_string = original_string
            @placeholders = placeholders
          end

          def replace
            replaced_string = original_string.dup

            placeholders.each do |placeholder_name, matching_text|
              placeholder = "#{placeholder_name}_placeholder"
              original_string.include?(matching_text) &&
                replaced_string.gsub!(matching_text, placeholder)
            end

            replaced_string
          end
        end

        ##
        # This class replaces the matching placeholder with text
        class PlaceholderToString
          attr_reader :target_string, :placeholders

          def initialize(placeholders, target_string)
            @placeholders = placeholders
            @target_string = target_string
          end

          def replace
            replaced_string = target_string.dup

            placeholders.each do |placeholder_name, target_text|
              placeholder = "#{placeholder_name}_placeholder"
              target_string.include?(placeholder) && replaced_string.gsub!(placeholder, target_text)
            end

            replaced_string
          end
        end

        def initialize(config: DatadogExporter::Client::Config.new)
          @config = config.organizations_config[:monitors]
        end

        # Transforms the monitor to a template
        #
        # @param [Hash] datadog_hash The monitor configuration
        #
        # @param [Symbol] environment (optional) The env tag name where the placeholders are defined
        # Placeholders can be defined in a "organizations_config.yml" file
        # See "organizations_config.example.yml" to see an example
        #
        # @return [Hash] The transformed monitor into a template with placeholders
        # If no placeholder is defined, it returns the monitor as it is
        def create_template(datadog_hash, environment: :base)
          placeholders = @config[:placeholders][environment]

          replace_values_with_placeholders(filter_by_template_keys(datadog_hash), placeholders)
        end

        def create_monitor(template, environment: :base)
          placeholders = @config[:placeholders][environment]

          replace_placeholders_with_values(placeholders, filter_by_template_keys(template))
        end

        private

        def filter_by_template_keys(datadog_hash)
          return datadog_hash if template_keys.empty?

          datadog_hash.slice(*template_keys)
        end

        def replace_values_with_placeholders(hash_data, placeholders)
          return hash_data if placeholders.nil?

          hash_data.each do |key, value|
            case value
            when Hash
              replace_values_with_placeholders(value, placeholders)
            when String
              hash_data[key] = StringToPlaceholder.new(value, placeholders).replace
            when Array
              hash_data[key] = value.map do |value|
                StringToPlaceholder.new(value, placeholders).replace
              end
            end
          end
        end

        def replace_placeholders_with_values(placeholders, hash_data)
          return hash_data if placeholders.nil?

          hash_data.each do |key, value|
            case value
            when Hash
              replace_placeholders_with_values(placeholders, value)
            when String
              hash_data[key] = PlaceholderToString.new(placeholders, value).replace
            when Array
              hash_data[key] = value.map do |value|
                PlaceholderToString.new(placeholders, value).replace
              end
            end
          end
        end

        def template_keys
          @config[:template_keys]
        end
      end
    end
  end
end
