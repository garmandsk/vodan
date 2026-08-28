DROP POLICY IF EXISTS "Workspace owners can update payment configuration"
  ON public.workspaces;
CREATE POLICY "Workspace owners can update payment configuration"
ON public.workspaces FOR UPDATE TO authenticated
USING (owner_id = auth.uid())
WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Workspace owners can upload QRIS"
  ON storage.objects;
CREATE POLICY "Workspace owners can upload QRIS"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'workspace-qris'
  AND EXISTS (
    SELECT 1 FROM public.workspaces
    WHERE id::text = (storage.foldername(name))[1]
      AND owner_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Workspace owners can read QRIS"
  ON storage.objects;
CREATE POLICY "Workspace owners can read QRIS"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'workspace-qris'
  AND EXISTS (
    SELECT 1 FROM public.workspaces
    WHERE id::text = (storage.foldername(name))[1]
      AND owner_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Workspace owners can update QRIS"
  ON storage.objects;
CREATE POLICY "Workspace owners can update QRIS"
ON storage.objects FOR UPDATE TO authenticated
USING (
  bucket_id = 'workspace-qris'
  AND EXISTS (
    SELECT 1 FROM public.workspaces
    WHERE id::text = (storage.foldername(name))[1]
      AND owner_id = auth.uid()
  )
)
WITH CHECK (
  bucket_id = 'workspace-qris'
  AND EXISTS (
    SELECT 1 FROM public.workspaces
    WHERE id::text = (storage.foldername(name))[1]
      AND owner_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Workspace owners can delete QRIS"
  ON storage.objects;
CREATE POLICY "Workspace owners can delete QRIS"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'workspace-qris'
  AND EXISTS (
    SELECT 1 FROM public.workspaces
    WHERE id::text = (storage.foldername(name))[1]
      AND owner_id = auth.uid()
  )
);