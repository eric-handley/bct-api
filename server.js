import http from 'node:http';
import worker from './worker.js';

const PORT = Number(process.env.PORT) || 8000;
const HOST = process.env.HOST || '0.0.0.0';

const server = http.createServer(async (req, res) => {
  try {
    const bodyChunks = [];
    for await (const chunk of req) {
      bodyChunks.push(chunk);
    }
    const rawBody = Buffer.concat(bodyChunks);
    const method = req.method || 'GET';
    const headers = new Headers();
    for (const [key, value] of Object.entries(req.headers)) {
      if (value === undefined) continue;
      if (Array.isArray(value)) {
        value.forEach(v => headers.append(key, v));
      } else {
        headers.set(key, value);
      }
    }

    const request = new Request(new URL(req.url || '/', `http://localhost:${PORT}`), {
      method,
      headers,
      body: method === 'GET' || method === 'HEAD' || rawBody.length === 0 ? undefined : rawBody
    });

    const response = await worker.fetch(request);

    res.writeHead(response.status, Object.fromEntries(response.headers));
    if (response.body) {
      const arrayBuffer = await response.arrayBuffer();
      res.end(Buffer.from(arrayBuffer));
    } else {
      res.end();
    }
  } catch (error) {
    console.error('Server error:', error);
    res.writeHead(500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Internal server error' }));
  }
});

server.listen(PORT, HOST, () => {
  console.log(`Server listening on http://${HOST}:${PORT}`);
});
