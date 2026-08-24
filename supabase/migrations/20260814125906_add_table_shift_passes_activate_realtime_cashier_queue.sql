CREATE TABLE shift_passes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id UUID NOT NULL,
    pass_code TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);