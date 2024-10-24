require "logger"

module DatadogExporter
  ##
  # The global configuration of the DatadogExporter client.
  #
  # @see DatadogExporter.configure
  class Configuration
    def initialize
      @config = {}
    end

    ##
    # Create a getter and a setter for a setting.
    #
    # If the default value is a Proc, it will be called on initialize.
    #
    # @param name: Symbol
    # @param default: Proc | Object
    def self.add_setting(name, default)
      define_method name do
        @config[name] ||= default.is_a?(Proc) ? default.call : default
      end

      define_method :"#{name}=" do |value|
        @config[name] = value
      end
    end

    add_setting :logger, -> { Logger.new($stdout) }
    add_setting :config_path, -> { File.expand_path(__FILE__, "datadog_exporter.yml") }
    add_setting :site, -> { ENV.fetch("DATADOG_API_SITE", nil) }
    add_setting :api_key, -> { ENV.fetch("DATADOG_API_KEY", nil) }
    add_setting :application_key, -> { ENV.fetch("DATADOG_APPLICATION_KEY", nil) }
  end
end
