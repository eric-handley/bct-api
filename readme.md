# BC Transit Bus Display API

Simple Cloudflare Worker that fetches and formats real-time BC Transit bus arrival data from GTFS realtime feeds.

## Usage

Send a POST request with BC Transit stop IDs:

```bash
curl -X POST https://your-worker.workers.dev \
  -H "Content-Type: application/json" \
  -d '{"stopIds": ["101011", "100991"]}'
```

Response:
```json
[
  {
    "stopId": "101011",
    "arrivals": [
      {
        "routeId": "7N",
        "arriving": "5 min",
        "deviation": 0
      },
      {
        "routeId": "4",
        "arriving": "10 min",
        "deviation": 0
      }
    ]
  }
]
```

## Development

```bash
npm install
npm test
```

## Deployment

Deploy to Cloudflare Worker:

```bash
wrangler deploy
```

**Note:** For server deployment with Node.js/Docker, see the `server` branch.
