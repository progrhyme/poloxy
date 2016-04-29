# poloxy
[![Build Status](https://travis-ci.org/key-amb/poloxy.svg?branch=master)](https://travis-ci.org/key-amb/poloxy)

Server-side proxy software for delivering system alerts.

### Table of Contents

* [What is "poloxy"?](#what-is-poloxy)
* [Components](#components)
* [How to use "poloxy"](#how-to-use-poloxy)
  * [Requirements](#requirements)
  * [Install](#install)
  * [Configure](#configure)
  * [Usage](#usage)
* [Additional Resources of "poloxy"](#additional-resources-of-poloxy)
* [Authors](#authors)
* [License](#license)

# What is "poloxy"?

The image bellow illustrates the concept of **"poloxy"**.

1. **API** receives alerts from monitoring systems and enqueues them.
1. **Worker** summarizes alerts.
1. Worker delivers them to recipients.

It prevents bursting alerts flood to recipients' phones or any devices.

<div align="center" style="border: 2px solid #aaa; padding: 10px;">
<img src="https://raw.githubusercontent.com/key-amb/poloxy/resource/image/concept.png" alt="poloxy-concept">
</div>

# Components

- **API**
  - Receives alerts from monitoring systems and enqueues them
- **Worker**
  - Dequeues alerts, summarizes them and delivers them to recipients
- **Web Dashboard**
  - Viewer for incoming alerts and delivered notifications
  - One can check original alerts on this dashboard
  - Integrated with **API**

# How to use "poloxy"

## Requirements

- Ruby ... _v2.0.0_ or later
- An RDBMS supported by [Sequel](https://github.com/jeremyevans/sequel) ORM
  - Tested by SQLite3 and developed with MySQL. Hopefully other RDBs will do.

## Install

```
gem install bundler
git clone https://github.com/key-amb/poloxy.git
cd poloxy
bundle install
```

## Configure

### Configuration File

Default configuration file is `config/poloxy.toml`.  
And this file is included in this repository as a sample.

You can change its path by `POLOXY_CONFIG` environment variable.

Here are configuration items:

| Item | Type | Default | Description |
|:-----|:----:|:-------:|:------------|
| log.level | String | `INFO` | Log level for std-lib `Logger` class |
| log.rotate | String | \- | `shift_age` param for `Logger#new` |
| log.file | String | \- | Path to log output file |
| deliver.min_interval | Integer | 60 | Seconds of minimum interval to deliver summarized alerts to recipients |
| deliver.item.merger | String | `PerItem` | Method to summarize alerts |
| database.connect | Hash | \- | Params to connect database. These params are passed to `Sequel#connect`. |
| message.default_expire | Integer | `7200` | Seconds to expire alerts. Expired alerts are taken as "CLEAR". |

NOTE:

- `PerItem` is the only method to summarize alerts for now.

### Database Schema

Database schema is bundled under `db/migrate/` directory in the repository.  
And migration task is defined in `Rakefile`.

Run:

```
bundle exec rake db:migrate
```

Then you will get prepared with `poloxy` database.

NOTE:

- You should prepare `database.connect` parameter in configuration file beforehand.
- Run `bundle exec rake db:reset` to destroy `poloxy` database.

## Usage

### Start Server

```
# Start Web/API
bundle exec bin/poloxy-webapi

# Start Worker
bundle exec bin/poloxy-worker
```

### HTTP API to send alerts

Endpoint: `POST /v1/item`

Parameters:

| Key | Type | Default | Description |
|:----|:----:|:-------:|:------------|
| name | String | \- | Name of alert. Used for message title. Should be unique in _"group"_ to distinguish from others. |
| group | String | `default` | Group to categorize alerts. Nested groups are supported with delimiter `/`. |
| level | Integer | 1 | Alert level. Higher is severer. Recommended to be lower than 10. |
| type | String | \- | Method to deliver message to recipients |
| address | String | \- | Recipient address |
| message | String | \- | Message body of alert |

NOTE:

- `Slack` is the only available **_type_** as method to deliver alerts for now.
  - Maybe you can use raw `HttpPost` **_type_**, but I'm afraid it would tire you.

Example of cURL request:

```
curl -X POST http://poloxy.yourdomain.com/v1/item -d '{
    "name": "CPU",
    "type": "Slack",
    "level": "3",
    "address": "https://hooks.slack.com/services/XXXXXXXXXX",
    "message": "CPU is WARNING 50%"
}'
```

# Additional Resources of "poloxy"

## Presentations

### 2016 Apr. 28th - "Introduction to poloxy" in [Nishi-Nippori.rb](https://nishinipporirb.doorkeeper.jp/)

<div align="center">
<a href="http://www.slideshare.net/YasutakeKiyoshi/introduction-to-poloxy-proxy-for-alerting" target="_blank">
<img src="https://raw.githubusercontent.com/key-amb/poloxy/resource/image/ninirb_20160428-screenshot.png" alt="ninirb_20160428-screenshot">
</a>
</div>

# Authors

YASUTAKE Kiyoshi <yasutake.kiyoshi@gmail.com>

# License

The MIT License (MIT)

Copyright (c) 2016 YASUTAKE Kiyoshi

