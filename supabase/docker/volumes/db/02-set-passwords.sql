-- Set passwords for all service users (LOCAL DEVELOPMENT)
ALTER ROLE authenticator WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_auth_admin WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_admin WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_storage_admin WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_realtime_admin WITH PASSWORD 'supabase_local_dev_pass_2025';

-- Grant authenticator the ability to switch roles
GRANT anon TO authenticator;
GRANT authenticated TO authenticator;
GRANT service_role TO authenticator;

-- Allow service users to access their schemas
GRANT ALL ON SCHEMA public TO authenticator;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticator;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticator;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO authenticator;
