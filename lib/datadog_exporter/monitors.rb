require_relative "monitors/utilities/name_transformer"
require_relative "monitors/utilities/template_creator"
require_relative "monitors/export"

module DatadogExporter
  ##
  # The module that contains all the Datadog Monitors related classes
  module Monitors
    EXPORT_FOLDER = "monitors".freeze
  end
end
