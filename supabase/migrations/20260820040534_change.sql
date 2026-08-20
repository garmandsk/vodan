UPDATE auth.users
SET raw_user_meta_data = (raw_user_meta_data - 'display_name') || jsonb_build_object('name', raw_user_meta_data->>'display_name')
WHERE raw_user_meta_data ? 'display_name';