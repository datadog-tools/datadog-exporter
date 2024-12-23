<h1 align="center">
  Export configuration tools for <a href="https://www.datadoghq.com/">Datadog</a>
</h1>

<p align="center">
  <a href="https://github.com/datadog-tools/datadog-exporter/actions?query=branch%3Amain+">
    <img alt="CI" src="https://github.com/datadog-tools/datadog-exporter/actions/workflows/ci.yml/badge.svg" \>
  </a>

  <a href="https://codecov.io/gh/datadog-tools/datadog-exporter" >
    <img src="https://codecov.io/gh/datadog-tools/datadog-exporter/graph/badge.svg?token=RC9T5DVSW8"/>
  </a>

  <!--
  <a href="https://rubygems.org/gems/datadog-export">
    <img src="https://badge.fury.io/rb/datadog-export.svg" alt="Gem Version" height="18">
  </a>
  -->
</p>

<p align="center">
  This library provides tools to easily export/import configurations from <a href="https://www.datadoghq.com/">Datadog</a>
</p>

## Usage

### Monitors

Find your datadog site in the "SITE PARAMETER" column of the table [Getting started with Datadog Sites](https://docs.datadoghq.com/getting_started/site/#access-the-datadog-site).

Learn how to create your own api key and application key in your [Datadog API and Application Keys documentation](https://docs.datadoghq.com/account_management/api-app-keys/).

#### Export

You can export the current configuration of your montors to keep a safe copy of their configuration. The next piece of code will export all your monitors in your home folder.

```ruby
require "datadog_export"

DatadogExporter.configure do |config|
  config.site = "your_datadog_site"
  config.api_key = "your_api_key"
  config.application_key = "your_application_key"
  config.base_path = ENV["HOME"]
end

DatadogExporter::Monitors.export
```

## Development

Useful commands are defined in the [`Justfile`](Justfile) and can be listed with [`just`](https://github.com/casey/just).

E.g. execute the setup: `just setup`.
