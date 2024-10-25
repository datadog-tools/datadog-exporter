RSpec.describe DatadogExporter::Monitors::Utilities::NameTransformer do
  subject(:transformer) { described_class.new }

  describe "#transform" do
    [
      "My Monitor Name",
      "My | Monitor | Name",
      "My | Monitor | Name | P99",
      "My | Monitor/Name",
      "My Monitor | Name",
      "My_Monitor_Name",
      "my_monitor_name",
    ].each do |name|
      it "transforms the name" do
        name = "My Monitor Name"
        expect(transformer.transform(name)).to eq("my_monitor_name")
      end
    end
  end
end
