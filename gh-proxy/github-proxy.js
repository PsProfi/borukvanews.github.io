// ─────────────────────────────────────────────────────────────────────────────
// Cloudflare Worker — GitHub Contents API proxy
//
// Supports multiple JSON files via ?file=filename.json query param.
//
// Setup:
//   1. Paste this into the Cloudflare Worker editor and Deploy.
//   2. Worker Settings → Variables → Add secret:
//        Name:  GITHUB_TOKEN
//        Value: your GitHub token (mark as Secret)
//   3. Copy the Worker URL into kWorkerBase in hotspot_shared.dart.
// ─────────────────────────────────────────────────────────────────────────────

const GITHUB_OWNER = 'PsProfi';
const GITHUB_REPO  = 'news-data';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Methods': 'GET, PUT, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

export default {
  async fetch(request, env) {
    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS_HEADERS });
    }

    // Get the file name from ?file= query param
   const url  = new URL(request.url);
const file = url.searchParams.get('file');
if (!file) {
  return new Response(
    `Missing ?file= param. Received URL: ${request.url}`,
    { status: 400, headers: CORS_HEADERS }
  );
}

    const apiUrl = `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/contents/${file}`;

    const ghHeaders = {
      'Authorization': `token ${env.GITHUB_TOKEN}`,
      'Accept':        'application/vnd.github+json',
      'Content-Type':  'application/json',
      'User-Agent':    'cf-worker-gh-proxy',
    };

    if (request.method === 'GET') {
      const resp = await fetch(apiUrl, { headers: ghHeaders });
      const body = await resp.text();
      return new Response(body, {
        status: resp.status,
        headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
      });
    }

    if (request.method === 'PUT') {
      const body = await request.text();
      // Inject commit message if not present
      const parsed = JSON.parse(body);
      if (!parsed.message) parsed.message = `update ${file}`;
      const resp = await fetch(apiUrl, {
        method:  'PUT',
        headers: ghHeaders,
        body:    JSON.stringify(parsed),
      });
      const respBody = await resp.text();
      return new Response(respBody, {
        status: resp.status,
        headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
      });
    }

    return new Response('Method not allowed', { status: 405, headers: CORS_HEADERS });
  },
};
