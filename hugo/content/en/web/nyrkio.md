---
id: nyrkio
title: "Nyrkiö: Harness the Power of Change Point Detection"
weburl: "https://nyrkio.com/"
tags:
- Change Point Detection
hasNotes: true
---

Change point detection as a service.
Benchmarking as a service is on the way.

Based on {{< link github-hunter >}} and {{< link github-signal-processing-algorithms >}}.

API example:

```sh
curl -s -X POST -H "Content-type: application/json" -H "Authorization: Bearer $TOKEN" https://nyrkio.com/api/v0/result/benchmark1 \
           -d '[{"timestamp": 1706220908,
             "metrics": [
               {"name": "p50", "unit": "us", "value": 56 },
               {"name": "p90", "unit": "us", "value": 125 },
               {"name": "p99", "unit": "us", "value": 280 }
             ],
             "attributes": {
               "git_repo": "https://github.com/nyrkio/nyrkio",
               "branch": "main",
               "git_commit": "6995e2de6891c724bfeb2db33d7b87775f913ad1",
             }
       }]'
```
