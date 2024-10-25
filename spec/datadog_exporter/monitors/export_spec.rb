RSpec.describe DatadogExporter::Monitors::Export do
  subject(:export_monitors) do
    described_class.new(config:, client:, request:, file_class:, template_creator:)
  end

  let(:config) { DatadogExporter::Client::Config.new(base_path: config_base_path) }
  let(:client) { instance_double(DatadogExporter::Client) }
  let(:request) { instance_double(DatadogExporter::DatadogApiRequests::Monitors) }
  let(:file_class) { class_double(File) }
  let(:template_creator) { instance_double(DatadogExporter::Monitors::Utilities::TemplateCreator) }

  let(:config_base_path) { Dir.pwd }
  let(:monitors_base_path) { export_monitors.instance_variable_get(:@monitors_base_path) }

  before do
    allow(request).to receive(:list_monitors).with(tag:).and_return(monitors_data)
    allow(monitors_base_path).to receive(:mkpath)

    allow(file_class).to receive(:exist?).and_return(folder_exists)
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
      allow(file_class).to receive(:write).with(
        monitors_base_path.join("monitor-1.yml"),
        monitors_data[0].to_yaml,
      )
      allow(file_class).to receive(:write).with(
        monitors_base_path.join("monitor-2.yml"),
        monitors_data[1].to_yaml,
      )
    end

    it "creates the original monitors" do
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

  describe "#export_as_template" do
    let(:tag) { "my-tag" }
    let(:monitors_data) do
      [
        { name: "monitor-1", key: "value1", tags: ["my-tag"] },
        { name: "monitor-2", key: "value2", tags: ["my-tag"] },
      ]
    end
    let(:folder_exists) { true }

    before do
      allow(template_creator).to receive(:create).with(monitors_data[0]).and_return(
        monitors_data[0],
      )
      allow(template_creator).to receive(:create).with(monitors_data[1]).and_return(
        monitors_data[1],
      )

      allow(file_class).to receive(:write).with(
        monitors_base_path.join("template.monitor-1.yml"),
        monitors_data[0].to_yaml,
      )
      allow(file_class).to receive(:write).with(
        monitors_base_path.join("template.monitor-2.yml"),
        monitors_data[1].to_yaml,
      )
    end

    it "creates the template monitors" do
      export_monitors.export_as_template(tag:)

      expect(file_class).to have_received(:write).with(
        monitors_base_path.join("template.monitor-1.yml"),
        monitors_data[0].to_yaml,
      )
      expect(file_class).to have_received(:write).with(
        monitors_base_path.join("template.monitor-2.yml"),
        monitors_data[1].to_yaml,
      )
    end
  end
end
