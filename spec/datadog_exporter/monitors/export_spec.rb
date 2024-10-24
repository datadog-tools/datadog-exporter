RSpec.describe DatadogExporter::Monitors::Export do
  subject(:export_monitors) do
    described_class.new(config: config, client: client, request: request, file_class: file_class)
  end

  let(:config) { instance_double(DatadogExporter::Client::Config) }
  let(:client) { instance_double(DatadogExporter::Client) }
  let(:request) { instance_double(DatadogExporter::DatadogApiRequests::Monitors) }
  let(:file_class) { class_double(File) }

  let(:config_base_path) { Pathname.new(__FILE__) }
  let(:monitors_base_path) { config_base_path.join("monitors") }

  before do
    allow(config).to receive(:base_path).and_return(config_base_path)
    allow(config_base_path).to receive(:join).and_return(monitors_base_path)
  end

  describe "#export" do
    let(:tag) { "my-tag" }
    let(:monitors_data) do
      [
        { name: "monitor-1", key: "value1", tags: ["my-tag"] },
        { name: "monitor-2", key: "value2", tags: ["my-tag"] },
      ]
    end
    let(:folder_exists) { true }

    before do
      allow(request).to receive(:list_monitors).with(tag:).and_return(monitors_data)
      allow(monitors_base_path).to receive(:mkpath)

      allow(file_class).to receive(:exist?).and_return(folder_exists)
      allow(file_class).to receive(:write).with(
        monitors_base_path.join("monitor-1.yml"),
        monitors_data[0].to_yaml,
      )
      allow(file_class).to receive(:write).with(
        monitors_base_path.join("monitor-2.yml"),
        monitors_data[1].to_yaml,
      )
    end

    it "creates the original monitors and templates" do
      export_monitors.export(tag:)

      expect(file_class).to have_received(:write).with(
        monitors_base_path.join("monitor-1.yml"),
        monitors_data[0].to_yaml,
      )
      expect(file_class).to have_received(:write).with(
        monitors_base_path.join("monitor-2.yml"),
        monitors_data[1].to_yaml,
      )
    end

    context "when the monitors directory does not exists" do
      let(:folder_exists) { false }

      it "creates the monitors directory" do
        export_monitors.export(tag:)

        expect(monitors_base_path).to have_received(:mkpath)
      end
    end
  end
end
