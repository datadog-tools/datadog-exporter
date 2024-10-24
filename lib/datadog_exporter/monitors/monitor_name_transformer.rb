module DatadogExporter
  module Monitors
    ##
    # This class transform the monitor name to a valid file name
    class MonitorNameTransformer
      # Transforms the monitor name to a valid file name
      #
      # @param [String] name The monitor name
      #
      # @return [String] The transformed name
      def transform(name)
        name.downcase.gsub(/\s*\|\s*/, "_").tr("/", "_").gsub(/\s+/, "_")
      end
    end
  end
end
