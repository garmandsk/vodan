DROP POLICY IF EXISTS "Workspace owners can upload QRIS" ON storage.objects;
CREATE POLICY "Workspace owners can upload QRIS"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'workspace-qris'
  AND (storage.foldername(name))[1] IN (
    SELECT w.id::text
    FROM public.workspaces AS w
    WHERE w.owner_id = (SELECT auth.uid())
  )
);

DROP POLICY IF EXISTS "Workspace owners can read QRIS" ON storage.objects;
CREATE POLICY "Workspace owners can read QRIS"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'workspace-qris'
  AND (storage.foldername(name))[1] IN (
    SELECT w.id::text
    FROM public.workspaces AS w
    WHERE w.owner_id = (SELECT auth.uid())
  )
);

DROP POLICY IF EXISTS "Workspace owners can update QRIS" ON storage.objects;
CREATE POLICY "Workspace owners can update QRIS"
ON storage.objects FOR UPDATE TO authenticated
USING (
  bucket_id = 'workspace-qris'
  AND (storage.foldername(name))[1] IN (
    SELECT w.id::text
    FROM public.workspaces AS w
    WHERE w.owner_id = (SELECT auth.uid())
  )
)
WITH CHECK (
  bucket_id = 'workspace-qris'
  AND (storage.foldername(name))[1] IN (
    SELECT w.id::text
    FROM public.workspaces AS w
    WHERE w.owner_id = (SELECT auth.uid())
  )
);