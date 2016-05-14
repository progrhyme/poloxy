# poloxy
[![Build Status](https://travis-ci.org/key-amb/poloxy.svg?branch=master)](https://travis-ci.org/key-amb/poloxy)

Server-side proxy software for delivering system alerts.

[Documentation site](http://key-amb.github.io/poloxy-doc/) is now available.

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
- **CLI**
  - Utility tool for manual tasks such as data purge

# How to use "poloxy"

See [documentation site](http://key-amb.github.io/poloxy-doc/) for guide to get started and detailed usage of **poloxy**.

## Requirements

- Ruby ... _v2.0.0_ or later
- An RDBMS supported by [Sequel](https://github.com/jeremyevans/sequel) ORM
  - Tested by SQLite3 and developed with MySQL. Hopefully other RDBs will do.

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
