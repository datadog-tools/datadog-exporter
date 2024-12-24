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

#### Configuration

- Configure an "organizations_config.yml" file in your base path. This file will define the keys you want to import and the placeholders you want to replace. This way, the importer tool will replace the placeholders with the values of your environment and will only use the defined template keys when importing a monitor.

```yaml
:monitors:
  :template_keys:
    - :name
    - :type
    - :query
    - :options
    - :tags
    - :message

  :placeholders:
    :base:
      :dbname: dbname:production
      :namespace: namespace:production
      :environment: env:production

    :staging:
      :dbname: dbname:staging
      :namespace: namespace:staging
      :environment: env:staging
```

Before running any of the tools, you need to configure the library with your Datadog credentials. The following code will configure the library to use your Datadog credentials.

```ruby
require "datadog_export"

DatadogExporter.configure do |config|
  config.site = "your_datadog_site"
  config.api_key = "your_api_key"
  config.application_key = "your_application_key"
  config.base_path = ENV["HOME"]
end
```

#### Export

You can export the current configuration of your montors to keep a safe copy of their configuration. The next piece of code will export all your monitors in your home folder.

```ruby
DatadogExporter::Monitors.export
```

#### Import

You can import monitors to Datadog, by using previously exported monitors and replacing the configured placeholders with the values of your environment.

```ruby
DatadogExporter::Monitors::Import.new.import(to: :staging)
```

## Development

Useful commands are defined in the [`Justfile`](Justfile) and can be listed with [`just`](https://github.com/casey/just).

E.g. execute the setup: `just setup`.
