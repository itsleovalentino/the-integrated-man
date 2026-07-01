// The Integrated Man — API.Bible proxy (Supabase Edge Function)
//
// Why: API.Bible blocks browser CORS and the api-key must stay server-side.
// This relays chapter text + audio URLs and adds CORS. The key lives in a
// Supabase secret, never in the client or the repo.
//
// Deploy:
//   supabase functions deploy bible --project-ref rrhslltmkkvlveztylsi --no-verify-jwt
//   supabase secrets set BIBLE_API_KEY=your_api_bible_key --project-ref rrhslltmkkvlveztylsi

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { ...CORS, "content-type": "application/json" } });
}

const API = "https://api.scripture.api.bible/v1";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  const KEY = Deno.env.get("BIBLE_API_KEY");
  if (!KEY) return json({ error: "BIBLE_API_KEY is not set on the server." }, 500);

  let body: any;
  try { body = await req.json(); } catch { return json({ error: "Bad request body" }, 400); }
  const headers = { "api-key": KEY };

  try {
    if (body.action === "chapter") {
      if (!body.bibleId || !body.chapterId) return json({ error: "Missing bibleId/chapterId" }, 400);
      const r = await fetch(`${API}/bibles/${body.bibleId}/chapters/${body.chapterId}?content-type=text`, { headers });
      const d = await r.json().catch(() => ({}));
      if (!d.data) return json({ error: d.message || "Chapter not found" }, r.status);
      return json({ reference: d.data.reference, content: d.data.content });
    }
    if (body.action === "audio") {
      if (!body.audioId || !body.chapterId) return json({ error: "Missing audioId/chapterId" }, 400);
      const r = await fetch(`${API}/audio-bibles/${body.audioId}/chapters/${body.chapterId}`, { headers });
      const d = await r.json().catch(() => ({}));
      if (!d.data || !d.data.resourceUrl) return json({ error: "No audio for this chapter" }, r.status);
      return json({ url: d.data.resourceUrl });
    }
    return json({ error: "Unknown action" }, 400);
  } catch (e) {
    return json({ error: "Couldn't reach API.Bible: " + String(e) }, 502);
  }
});
