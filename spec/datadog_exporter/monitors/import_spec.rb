RSpec.describe DatadogExporter::Monitors::Import do
  subject(:import_monitors) { described_class.new(config:, client:, request:) }

  let(:config) { DatadogExporter::Client::Config.new(base_path: config_base_path) }
  let(:client) { instance_double(DatadogExporter::Client) }
  let(:request) { instance_double(DatadogExporter::DatadogApiRequests::Monitors) }

  let(:config_base_path) { "spec/datadog_exporter/monitors/import" }
  let(:monitors_base_path) { import_monitors.instance_variable_get(:@monitors_base_path) }

  let(:monitor_files) { monitors_base_path.glob("*.yml") }

  before { allow(request).to receive(:create) }

  describe "#import" do
    it "gets the monitors from the base path and creates them in datadog" do
      import_monitors.import

      expect(request).to have_received(:create).exactly(monitor_files.count).times
    end

    context "when the monitors directory does not exist" do
      let(:error_message) { "Monitors directory does not exist" }
      let(:config_base_path) { nil }

      it "raises an error" do
        expect { import_monitors.import }.to raise_error(
          DatadogExporter::Monitors::Import::DirectoryNotExisting,
          error_message,
        )
      end
    end

    context "when the monitors directory is empty" do
      let(:error_message) { "Monitors directory is empty" }

      before { allow(monitors_base_path).to receive(:glob).with("*.yml").and_return([]) }

      it "raises and error" do
        expect { import_monitors.import }.to raise_error(
          DatadogExporter::Monitors::Import::DirectoryEmptyError,
          error_message,
        )
      end
    end
  end
end
