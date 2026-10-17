const assetLinks = [
  {
    "relation": [
      "delegate_permission/common.handle_all_urls"
    ],
    "target": {
      "namespace": "android_app",
      "package_name": "com.davidlledo.trueke",
      "sha256_cert_fingerprints": [
        "a5:e4:48:a1:be:97:ea:1a:ae:53:e0:ef:59:cf:ef:19:b7:86:c9:42:3b:c6:b8:79:fa:9b:1d:56:27:05:48:13"
      ]
    }
  }
];

Deno.serve(async (req) => {
  const timestamp = new Date().toISOString();
  const url = new URL(req.url);
  const userAgent = req.headers.get("user-agent") || "Unknown UA";
  const originIp = req.headers.get("x-forwarded-for") || "Unknown IP";

  // LOG ESTRUCTURADO: Visible en tiempo real en tu Supabase Dashboard
  console.log(`[${timestamp}] 🚀 APP_LINKS_REQUEST | Path: ${url.pathname} | Method: ${req.method} | IP: ${originIp} | UA: ${userAgent}`);

  return new Response(JSON.stringify(assetLinks), {
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, OPTIONS",
      "X-Trueke-Telemetry": "active"
    },
    status: 200,
  });
})
