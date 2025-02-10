lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "datadog_exporter/version"

Gem::Specification.new do |spec|
  spec.name                  = "datadog-exporter"
  spec.version               = DatadogExporter::VERSION
  spec.platform              = Gem::Platform::RUBY
  spec.authors               = ["Fran Martinez"]
  spec.email                 = ["martinezcoder@gmail.com"]
  spec.summary               = "Exporting tools for Datadog"
  spec.homepage              = "https://github.com/datadog-exporter/datadog-exporter"
  spec.license               = "MIT"

  spec.metadata = {
    "rubygems_mfa_required" => "true",
  }

  spec.files                 = `git ls-files -- lib/*`.split("\n")
  spec.require_paths         = ["lib"]

  spec.required_ruby_version = ">= 3.3"

  spec.add_dependency "datadog_api_client", ">= 2.29.1", "< 2.31.0"
  spec.add_dependency "faraday", "~> 2.0", ">= 2.0.0"
end
