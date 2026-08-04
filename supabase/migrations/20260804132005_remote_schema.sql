-- Migration unit 1: schema_changes
-- Transaction mode: transactional
-- Boundary reason: default

DROP EXTENSION IF EXISTS pg_net;

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT DELETE, INSERT, SELECT, UPDATE ON TABLES TO anon;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT, USAGE ON SEQUENCES TO anon;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON ROUTINES TO anon;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT DELETE, INSERT, SELECT, UPDATE ON TABLES TO authenticated;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT, USAGE ON SEQUENCES TO authenticated;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON ROUTINES TO authenticated;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT DELETE, INSERT, SELECT, UPDATE ON TABLES TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT, USAGE ON SEQUENCES TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON ROUTINES TO service_role;

CREATE TYPE public.payment_method_enum AS ENUM (
  'cash',
  'qris',
  'transfer'
);

CREATE TYPE public.queue_status_enum AS ENUM (
  'pending',
  'approved',
  'rejected'
);

CREATE TYPE public.transaction_status_enum AS ENUM (
  'pending',
  'paid',
  'rejected'
);

CREATE TABLE public.users (
  id         uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  email text UNIQUE NOT NULL,
  name TEXT NOT NULL,
  password_hash TEXT,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.users
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.users
  ADD CONSTRAINT users_pkey PRIMARY KEY (id);

CREATE TABLE public.cashier_queue (
  id           uuid                     DEFAULT gen_random_uuid() NOT NULL,
  workspace_id uuid                     NOT NULL,
  cashier_name character varying(100)   NOT NULL,
  status       public.queue_status_enum DEFAULT 'pending'::public.queue_status_enum NOT NULL,
  qr_token     character varying(255),
  last_active  timestamp with time zone DEFAULT now() NOT NULL,
  updated_at   timestamp with time zone DEFAULT now() NOT NULL,
  created_at   timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.cashier_queue
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.cashier_queue
  ADD CONSTRAINT cashier_queue_pkey PRIMARY KEY (id);

GRANT ALL ON public.cashier_queue TO anon;

GRANT ALL ON public.cashier_queue TO authenticated;

GRANT ALL ON public.cashier_queue TO service_role;

CREATE INDEX idx_workspace_queue ON public.cashier_queue (workspace_id);

CREATE POLICY "Allow public read-write antrean MVP" ON public.cashier_queue
  USING (true)
  WITH CHECK (true);

CREATE TABLE public.products (
  id           uuid                           DEFAULT gen_random_uuid() NOT NULL,
  workspace_id uuid                     NOT NULL,
  name character varying(150)   NOT NULL,
  category     character varying(100)   DEFAULT 'Uncategorized'::character varying,
  nlp_alias    text[]                   DEFAULT '{}'::text[] NOT NULL,
  price        numeric(15,2)            DEFAULT 0.00 NOT NULL,
  currency     character varying(7)     DEFAULT 'IDR'::character varying NOT NULL,
  stock  integer                  DEFAULT 0 NOT NULL,
  sold   integer                  DEFAULT 0 NOT NULL,
  is_active    boolean                  DEFAULT true NOT NULL,
  updated_at   timestamp with time zone DEFAULT now() NOT NULL,
  created_at   timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.products
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.products
  ADD CONSTRAINT pk_products_catalogue PRIMARY KEY (id, workspace_id);

GRANT ALL ON public.products TO anon;

GRANT ALL ON public.products TO authenticated;

GRANT ALL ON public.products TO service_role;

CREATE INDEX idx_workspace_catalogue ON public.products (workspace_id);

CREATE POLICY "Allow public read-write katalog MVP" ON public.products
  USING (true)
  WITH CHECK (true);

CREATE TABLE public.transaction_log (
  id               uuid                           DEFAULT gen_random_uuid() NOT NULL,
  workspace_id     uuid                           NOT NULL,
  transaction_time timestamp with time zone       DEFAULT now() NOT NULL,
  items            jsonb                          DEFAULT '[]'::jsonb NOT NULL,
  total_price      numeric(15,2)                  DEFAULT 0.00 NOT NULL,
  discount         numeric(15,2)                  DEFAULT 0.00 NOT NULL,
  currency         character varying(7)           DEFAULT 'IDR'::character varying NOT NULL,
  payment_method   public.payment_method_enum     DEFAULT 'cash'::public.payment_method_enum NOT NULL,
  status           public.transaction_status_enum DEFAULT 'paid'::public.transaction_status_enum NOT NULL,
  cashier_name     character varying(100)         DEFAULT 'Kasir-Unknown'::character varying,
  updated_at       timestamp with time zone       DEFAULT now() NOT NULL,
  created_at       timestamp with time zone       DEFAULT now() NOT NULL
);

ALTER PUBLICATION supabase_realtime ADD TABLE public.cashier_queue, TABLE public.transaction_log;

ALTER TABLE public.transaction_log
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.transaction_log
  ADD CONSTRAINT transaction_log_pkey PRIMARY KEY (id);

GRANT ALL ON public.transaction_log TO anon;

GRANT ALL ON public.transaction_log TO authenticated;

GRANT ALL ON public.transaction_log TO service_role;

CREATE INDEX idx_transaction_time ON public.transaction_log (transaction_time DESC);

CREATE INDEX idx_workspace_transaction ON public.transaction_log (workspace_id);

CREATE POLICY "Allow public read-write transaksi MVP" ON public.transaction_log
  USING (true)
  WITH CHECK (true);

CREATE TABLE public.workspaces (
  id             uuid                     DEFAULT gen_random_uuid() NOT NULL,
  owner_id uuid NOT NULL,
  name character varying(150)   NOT NULL,
  admin_pin      character varying(50)    DEFAULT '123456'::character varying,
  ai_keys        jsonb                    DEFAULT '[]'::jsonb NOT NULL,
  updated_at     timestamp with time zone DEFAULT now() NOT NULL,
  created_at     timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.workspaces
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.workspaces
  ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);

ALTER TABLE public.cashier_queue
  ADD CONSTRAINT cashier_queue_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;

ALTER TABLE public.products
  ADD CONSTRAINT products_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;

ALTER TABLE public.transaction_log
  ADD CONSTRAINT transaction_log_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;

ALTER TABLE public.workspaces
  ADD CONSTRAINT workspaces_user_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;

GRANT ALL ON public.workspaces TO anon;

GRANT ALL ON public.workspaces TO authenticated;

GRANT ALL ON public.workspaces TO service_role;

CREATE POLICY "Allow public read-write workspaces MVP" ON public.workspaces
  USING (true)
  WITH CHECK (true);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name)
  VALUES (
    new.id, 
    new.email, 
    COALESCE(new.raw_user_meta_data ->> 'name', 'No Name')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();