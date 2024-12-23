RSpec.describe DatadogExporter::Monitors::Utilities::TemplateManager do
  subject(:templator) { described_class.new(config: config) }

  let(:config) do
    DatadogExporter::Client::Config.new(
      site: "",
      api_key: "",
      application_key: "",
      base_path: "spec/datadog_exporter/monitors/utilities/fixtures",
    )
  end

  describe "#create_template" do
    let(:original_datadog_hash) do
      YAML.load_file("spec/datadog_exporter/monitors/utilities/fixtures/original_monitor.yml")
    end
    let(:output_datadog_hash) do
      YAML.load_file("spec/datadog_exporter/monitors/utilities/fixtures/template.monitor.yml")
    end

    it "creates a template with placeholders" do
      expect(templator.create_template(original_datadog_hash, environment: :base)).to eq(
        output_datadog_hash,
      )
    end
  end

  describe "#create_monitor" do
    let(:template_datadog_hash) do
      YAML.load_file("spec/datadog_exporter/monitors/utilities/fixtures/template.monitor.yml")
    end
    let(:staging_datadog_hash) do
      YAML.load_file("spec/datadog_exporter/monitors/utilities/fixtures/staging.monitor.yml")
    end

    it "creates a new monitor with the placeholders replaced" do
      expect(templator.create_monitor(template_datadog_hash, environment: :staging)).to eq(
        staging_datadog_hash,
      )
    end
  end
end
