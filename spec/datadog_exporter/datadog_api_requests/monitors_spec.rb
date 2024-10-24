RSpec.describe DatadogExporter::DatadogApiRequests::Monitors do
  subject(:request) do
    described_class.new(config: config, client: client, monitors_api: monitors_api)
  end

  let(:config) { instance_double(DatadogExporter::Client::Config) }
  let(:client) { instance_double(DatadogExporter::Client) }
  let(:monitors_api) { instance_double(DatadogAPIClient::V1::MonitorsAPI) }
  let(:datadog_client) { DatadogAPIClient::APIClient.new }

  let(:monitor_a) { DatadogAPIClient::V1::Monitor.new(tags: ["tag1"]) }
  let(:monitor_b) { DatadogAPIClient::V1::Monitor.new(tags: ["tag2"]) }

  before do
    allow(client).to receive(:datadog_client).and_return(datadog_client)
    allow(DatadogAPIClient::V1::MonitorsAPI).to receive(:new).with(datadog_client).and_return(
      monitors_api,
    )
  end

  describe "#list_monitors" do
    let(:monitors) { [monitor_a, monitor_b] }

    before { allow(monitors_api).to receive(:list_monitors).and_return(monitors) }

    context "when no tag is provided" do
      it "returns the list of monitors" do
        list = request.list_monitors
        expect(list.count).to eq(2)
      end
    end

    context "when the tag is provided" do
      it "returns the list of monitors filtered by tag" do
        list = request.list_monitors(tag: "tag2")
        expect(list.count).to eq(1)
        expect(list.first[:tags]).to eq(["tag2"])
      end
    end
  end

  describe "#monitor" do
    before { allow(monitors_api).to receive(:get_monitor).and_return(monitor_a) }

    it "returns the monitor" do
      expect(request.monitor("monitor_id")).to eq(monitor_a.to_hash)
    end
  end
end
