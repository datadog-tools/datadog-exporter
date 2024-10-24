require "datadog_exporter/configuration"
require "datadog_exporter/client"
require "datadog_exporter/datadog_api_requests"
require "datadog_exporter/monitors"

##
# The DatadogExporter tool
module DatadogExporter
  # Returns the global `DatadogExporter::Configuration` object. While
  # you _can_ use this method to access the configuration, the more common
  # convention is to use `DatadogExporter.configure``
  #
  # @example
  #     DatadogExporter.configuration.logger = Logger.new($stdout)
  # @see DatadogExporter.configure
  # @see DatadogExporter::Configuration
  def self.configuration
    @configuration ||= DatadogExporter::Configuration.new
  end

  # Yields the global configuration to a block.
  # @yield [Configuration] global configuration
  #
  # @example
  #     DatadogExporter.configure do |config|
  #       config.logger = Logger.new($stdout)
  #     end
  # @see DatadogExporter::Configuration
  def self.configure
    raise ArgumentError, "Please provide a block to configure" unless block_given?

    yield configuration
  end
end
