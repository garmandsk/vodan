ALTER TABLE public.workspaces
  ADD COLUMN IF NOT EXISTS qris_image_url TEXT,
  ADD COLUMN IF NOT EXISTS transfer_accounts JSONB NOT NULL DEFAULT '[]'::jsonb;

DROP POLICY IF EXISTS "Workspace owners can update payment configuration"
  ON public.workspaces;
CREATE POLICY "Workspace owners can update payment configuration"
ON public.workspaces FOR UPDATE TO authenticated
USING (owner_id = auth.uid())
WITH CHECK (owner_id = auth.uid());

INSERT INTO storage.buckets (id, name, public)
VALUES ('workspace-qris', 'workspace-qris', true)
ON CONFLICT (id) DO UPDATE SET public = true;

CREATE POLICY "Workspace owners can upload QRIS"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'workspace-qris'
  AND (storage.foldername(name))[1] IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM public.workspaces
    WHERE id::text = split_part(name, '/', 1)
      AND owner_id = auth.uid()
  )
);

CREATE POLICY "Workspace owners can update QRIS"
ON storage.objects FOR UPDATE TO authenticated
USING (
  bucket_id = 'workspace-qris'
  AND EXISTS (
    SELECT 1 FROM public.workspaces
    WHERE id::text = split_part(name, '/', 1)
      AND owner_id = auth.uid()
  )
);

CREATE POLICY "Workspace owners can delete QRIS"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'workspace-qris'
  AND EXISTS (
    SELECT 1 FROM public.workspaces
    WHERE id::text = split_part(name, '/', 1)
      AND owner_id = auth.uid()
  )
);