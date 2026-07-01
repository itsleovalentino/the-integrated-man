// The Integrated Man — Oura proxy (Supabase Edge Function)
//
// Why this exists: the Oura API does not send CORS headers, so the browser can't
// call it directly. This tiny function forwards the request server-side and adds CORS.
//
// It stores nothing. The client passes the user's own Oura Personal Access Token
// with each request (over HTTPS), and we relay it to Oura. Fine for personal use.
//
// Deploy (from the repo root, once the Supabase CLI is installed + logged in):
//   supabase functions deploy oura --project-ref rrhslltmkkvlveztylsi --no-verify-jwt
//
// (Using --no-verify-jwt keeps it simple for a personal build; the token itself
//  is the credential. Lock it down with JWT verification later for multi-user.)

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "content-type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  let token = "", start = "", end = "";
  try {
    const body = await req.json();
    token = (body.token || "").trim();
    start = body.start || "";
    end = body.end || "";
  } catch (_e) {
    return json({ error: "Bad request body" }, 400);
  }
  if (!token) return json({ error: "Missing Oura token" }, 400);

  const base = "https://api.ouraring.com/v2/usercollection";
  const q = `?start_date=${start}&end_date=${end}`;
  const headers = { Authorization: `Bearer ${token}` };

  try {
    const [rdRes, slRes, acRes] = await Promise.all([
      fetch(`${base}/daily_readiness${q}`, { headers }),
      fetch(`${base}/daily_sleep${q}`, { headers }),
      fetch(`${base}/daily_activity${q}`, { headers }),   // steps live here
    ]);

    if (rdRes.status === 401 || slRes.status === 401 || acRes.status === 401) {
      return json({ error: "Oura token was rejected — check it and try again." }, 401);
    }
    const readiness = await rdRes.json().catch(() => ({}));
    const sleep = await slRes.json().catch(() => ({}));
    const activity = await acRes.json().catch(() => ({}));

    return json({
      readiness: readiness.data || [],
      sleep: sleep.data || [],
      activity: activity.data || [],
    });
  } catch (e) {
    return json({ error: "Couldn't reach Oura: " + String(e) }, 502);
  }
});
