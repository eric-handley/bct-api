# Bus Display API

A Node.js HTTP service that exposes the Bus Display Cloudflare Worker logic over a traditional server interface so it can run anywhere, including inside Docker or as a system service. The API accepts `POST /` with a JSON body containing `stopIds` and responds with arrival information for each requested stop.

## Local development

```bash
npm install
npm start           # starts on http://0.0.0.0:8000
```

Override defaults with `PORT` and `HOST` environment variables when needed.

## API usage

```bash
curl -X POST http://localhost:8000/ \
  -H 'content-type: application/json' \
  -d '{"stopIds":["101028","101039"]}'
```

## Docker image

```bash
# Build the image
docker build -t bus-display .

# Run the container
docker run --rm -p 8000:8000 --name bus-display bus-display
```

Set `PORT` or `HOST` via `docker run -e PORT=9000` if ports must change.

## Systemd service (Docker)

1. Copy `deploy/bus-display.service` to `/etc/systemd/system/bus-display.service`.
2. Edit the `Environment=IMAGE=...` line if you push the image to a registry.
3. Reload and enable:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now bus-display
```

The unit stops any previous container, publishes port `8000`, and restarts the service on failure.

## Testing

Tests require live requests to the GTFS feed:

```bash
npm test
```

If the environment blocks outbound network traffic the suite will fail while fetching real data.
