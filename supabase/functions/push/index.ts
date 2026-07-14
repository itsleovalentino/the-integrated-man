// Edge function: send a web push to the CALLING user's own devices.
// Deploy: Supabase Dashboard → Edge Functions → Deploy new function → name it `push`,
// paste this file. Then set two secrets (Project Settings → Edge Functions → Secrets):
//   VAPID_PUBLIC_KEY  / VAPID_PRIVATE_KEY   (values in Leo's VAPID key printout)
// Test body: { "wait": 10, "title": "...", "body": "..." } — wait lets you lock the
// phone first so you see the banner arrive with the app fully closed.

import webpush from "npm:web-push@3.6.7";
import { createClient } from "npm:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  try {
    const url = Deno.env.get("SUPABASE_URL")!;
    const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
    const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const pub = Deno.env.get("VAPID_PUBLIC_KEY")!;
    const priv = Deno.env.get("VAPID_PRIVATE_KEY")!;

    // who is asking? (send only to the caller's own devices — no cross-user sends)
    const authHeader = req.headers.get("Authorization") ?? "";
    const asUser = createClient(url, anon, { global: { headers: { Authorization: authHeader } } });
    const { data: userData, error: userErr } = await asUser.auth.getUser();
    if (userErr || !userData?.user) return new Response("not signed in", { status: 401 });
    const uid = userData.user.id;

    const { wait = 0, title = "The Integrated Man", body = "Push works. Your rhythm can reach you now." } =
      await req.json().catch(() => ({}));
    if (wait > 0) await new Promise((r) => setTimeout(r, Math.min(wait, 25) * 1000));

    webpush.setVapidDetails("mailto:leo@truka.com", pub, priv);
    const admin = createClient(url, service);
    const { data: subs } = await admin.from("push_subs").select("id, sub").eq("user_id", uid);
    if (!subs?.length) return Response.json({ sent: 0, note: "no subscriptions for this user" });

    let sent = 0, dead = 0;
    for (const row of subs) {
      try {
        await webpush.sendNotification(row.sub, JSON.stringify({ title, body }));
        sent++;
      } catch (e) {
        // 404/410 = the device unsubscribed or the token expired — clean it up
        if (e?.statusCode === 404 || e?.statusCode === 410) { await admin.from("push_subs").delete().eq("id", row.id); dead++; }
      }
    }
    return Response.json({ sent, cleaned: dead });
  } catch (e) {
    return new Response("push error: " + (e?.message ?? e), { status: 500 });
  }
});
