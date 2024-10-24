RSpec.describe DatadogExporter::Client do
  subject(:client) do
    described_class.new(
      config: config,
    )
  end

  let(:config) { instance_double(DatadogExporter::Client::Config) }
  let(:datadog_api_configuration) { DatadogAPIClient::Configuration.default }

  before do
    allow(config).to receive(:datadog_api_configuration).and_return(datadog_api_configuration)
  end

  describe "#datadog_client" do
    it "returns the DatadogAPIClient::APIClient object with the configuration" do
      datadog_client = client.datadog_client
      expect(datadog_client).to be_a(DatadogAPIClient::APIClient)
      expect(datadog_client.config).to eq(datadog_api_configuration)
    end
  end
end
