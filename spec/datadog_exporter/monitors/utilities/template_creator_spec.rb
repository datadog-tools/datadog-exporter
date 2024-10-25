RSpec.describe DatadogExporter::Monitors::Utilities::TemplateCreator do
  subject(:templator) { described_class.new(config: config) }

  let(:config) do
    DatadogExporter::Client::Config.new(
      site: "",
      api_key: "",
      application_key: "",
      base_path: "spec/datadog_exporter/monitors/utilities/fixtures",
    )
  end

  describe "#create" do
    let(:original_datadog_hash) do
      YAML.load_file("spec/datadog_exporter/monitors/utilities/fixtures/original_monitor.yml")
    end
    let(:output_datadog_hash) do
      YAML.load_file("spec/datadog_exporter/monitors/utilities/fixtures/template.monitor.yml")
    end

    it "creates a template with placeholders" do
      expect(templator.create(original_datadog_hash, environment: :base)).to eq(output_datadog_hash)
    end
  end
end
