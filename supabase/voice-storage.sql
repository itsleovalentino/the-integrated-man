-- ============================================================
--  VOICE MEMO CLOUD BACKUP (closes the last known data-loss hole).
--  Run ONCE in Supabase → SQL Editor. 100% additive.
--
--  Today, memo AUDIO lives only in the device's IndexedDB; the cloud holds tiny
--  "aud:*" references. New phone / cleared browser = references with nothing
--  behind them. This creates a private Storage bucket where each man's audio
--  backs up automatically (path: <his-uid>/<ref>), readable and writable ONLY
--  by him. The app uploads after each save and re-downloads on a new device.
-- ============================================================

insert into storage.buckets (id, name, public, file_size_limit)
values ('voice', 'voice', false, 26214400)   -- 25MB per file, plenty for any memo
on conflict (id) do nothing;

create policy "voice: own read"
on storage.objects for select to authenticated
using (bucket_id = 'voice' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "voice: own write"
on storage.objects for insert to authenticated
with check (bucket_id = 'voice' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "voice: own update"
on storage.objects for update to authenticated
using (bucket_id = 'voice' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "voice: own delete"
on storage.objects for delete to authenticated
using (bucket_id = 'voice' and (storage.foldername(name))[1] = auth.uid()::text);
